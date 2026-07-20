//! The sync engine: pulls the account's kind-30078 events, merges them
//! last-write-wins, then drains the persistent `sync_queue` (publish /
//! delete) through the active signer. Every network call is bounded by a
//! timeout; every failure path leaves the queue in a retryable state.
//!
//! Concurrency model: one engine, one `run_once` at a time (a Mutex-guarded
//! run). D-Bus handlers only *request* work and read status snapshots — they
//! never wait on the network.

use std::collections::HashMap;
use std::sync::Arc;
use std::time::Duration;

use async_trait::async_trait;
use chrono::Utc;
use nostr::{Filter, Kind, Timestamp};
use tokio::sync::{Mutex, Notify, OnceCell};
use tracing::{info, warn};
use uuid::Uuid;

use crate::account::signer::{SignerBackend, SignerError};
use crate::account::AccountManager;
use crate::model::SCHEMA_VERSION;
use crate::store::{QueueItem, Store};
use crate::sync::transport::{PublishOutcome, RelayTransport};
use crate::sync::wire;

/// How the engine paces itself.
const PERIODIC_SYNC: Duration = Duration::from_secs(5 * 60);
const FETCH_TIMEOUT: Duration = Duration::from_secs(15);
const PUBLISH_TIMEOUT: Duration = Duration::from_secs(30);
/// Backoff: 5s · 2^attempts, capped at one hour. Items are never dropped.
const BACKOFF_BASE_SECS: i64 = 5;
const BACKOFF_CAP_SECS: i64 = 3600;
/// Parked "waiting for the user's signer" items re-check this often.
const SIGNER_DEFER: Duration = Duration::from_secs(15 * 60);
/// After this many failed attempts an op also counts in `failed` and lands
/// in `sync_failures` (it still retries — publishing is idempotent).
const FAILING_THRESHOLD: i64 = 5;
/// Pull overlap to absorb clock skew between devices.
const PULL_OVERLAP_SECS: i64 = 3600;
const CURSOR_KEY: &str = "sync.cursor_s";
const LAST_SYNC_KEY: &str = "last_sync_at";
const QUEUE_BATCH: i64 = 50;

/// The active account's identity as the engine needs it. Provided by
/// [AccountManager] in production, by stubs in tests.
pub struct ActiveIdentity {
    pub pubkey: nostr::PublicKey,
    pub signer: Box<dyn SignerBackend>,
}

#[async_trait]
pub trait IdentitySource: Send + Sync {
    async fn active(&self) -> Option<ActiveIdentity>;
}

#[async_trait]
impl IdentitySource for AccountManager {
    async fn active(&self) -> Option<ActiveIdentity> {
        let (pubkey, signer) = self.active_identity().await.ok()??;
        let pubkey = nostr::PublicKey::from_hex(&pubkey).ok()?;
        Some(ActiveIdentity { pubkey, signer })
    }
}

#[derive(Debug, Clone, Default)]
struct StatusInner {
    state: String,
    operation_id: Option<String>,
    last_error: Option<String>,
    network: String,
}

pub struct SyncEngine {
    store: Arc<Store>,
    identity: Arc<dyn IdentitySource>,
    transport: Arc<dyn RelayTransport>,
    status: Mutex<StatusInner>,
    /// Serializes runs; `request_sync` never blocks on it.
    run_lock: Mutex<()>,
    notify: Notify,
    connection: OnceCell<zbus::Connection>,
}

impl SyncEngine {
    pub fn new(
        store: Arc<Store>,
        identity: Arc<dyn IdentitySource>,
        transport: Arc<dyn RelayTransport>,
    ) -> Arc<Self> {
        Arc::new(Self {
            store,
            identity,
            transport,
            status: Mutex::new(StatusInner {
                state: "idle".into(),
                network: "unknown".into(),
                ..Default::default()
            }),
            run_lock: Mutex::new(()),
            notify: Notify::new(),
            connection: OnceCell::new(),
        })
    }

    pub fn set_connection(&self, connection: zbus::Connection) {
        let _ = self.connection.set(connection);
    }

    /// Fire-and-forget wake-up (local mutation happened, signer changed, …).
    /// Cheap and non-async so D-Bus handlers can call it inline.
    pub fn nudge(&self) {
        self.notify.notify_one();
    }

    /// Requests a sync and returns the operation id immediately. Completion
    /// is observable through `SyncStatusChanged`.
    pub async fn request_sync(&self) -> String {
        let operation_id = Uuid::new_v4().to_string();
        self.status.lock().await.operation_id = Some(operation_id.clone());
        self.notify.notify_one();
        operation_id
    }

    /// Periodic loop the daemon spawns: syncs on request and every
    /// [PERIODIC_SYNC] while an account is active.
    pub async fn run_loop(self: Arc<Self>) {
        loop {
            tokio::select! {
                _ = self.notify.notified() => {}
                _ = tokio::time::sleep(PERIODIC_SYNC) => {}
            }
            self.run_once().await;
        }
    }

    /// One full pull + push cycle. Never panics; all failures end up in the
    /// status JSON and the queue's retry bookkeeping.
    pub async fn run_once(&self) {
        let _guard = self.run_lock.lock().await;

        let Some(identity) = self.identity.active().await else {
            self.finish("idle", Some("not authenticated".into()), "unknown").await;
            return;
        };
        let relays = match self.blocking_store(|s| s.relays()).await {
            Ok(relays) if !relays.is_empty() => relays,
            Ok(_) => {
                self.finish("idle", Some("no relays configured".into()), "unknown").await;
                return;
            }
            Err(e) => {
                self.finish("error", Some(e), "unknown").await;
                return;
            }
        };

        self.set_state("syncing").await;
        self.emit_sync_status().await;

        let urls: Vec<String> = relays.iter().map(|r| r.url.clone()).collect();
        if let Err(e) = self.transport.configure(&urls).await {
            self.finish("error", Some(e.to_string()), "offline").await;
            return;
        }

        let mut changed: Vec<String> = Vec::new();
        let mut last_error: Option<String> = None;
        let mut network = "online";

        match self.pull(&identity, &mut changed).await {
            Ok(()) => {}
            Err(PullError::Offline(e)) => {
                network = "offline";
                last_error = Some(e);
            }
            Err(PullError::SignerUnavailable) => {
                last_error = Some("pull skipped: signer holds no decryption key".into());
            }
        }

        if network == "online" {
            if let Some(e) = self.push(&identity, &urls, &mut changed).await {
                last_error = Some(e);
            }
        }

        // Persist health + the last-sync marker.
        for health in self.transport.health().await {
            let _ = self
                .blocking_store(move |s| s.update_relay_health(&health.url, health.connected))
                .await;
        }
        let now = Utc::now().to_rfc3339();
        let _ = self.blocking_store(move |s| s.set_setting(LAST_SYNC_KEY, &now)).await;

        if !changed.is_empty() {
            self.emit_events_changed(changed).await;
        }
        let state = if last_error.is_some() { "error" } else { "idle" };
        self.finish(state, last_error, network).await;
    }

    // ------------------------------------------------------------------
    // Pull
    // ------------------------------------------------------------------

    async fn pull(
        &self,
        identity: &ActiveIdentity,
        changed: &mut Vec<String>,
    ) -> Result<(), PullError> {
        // Incremental cursor with an overlap window; a fresh device pulls
        // everything. Replaceable events guarantee created_at == updatedAt,
        // so the cursor is exactly the LWW merge key.
        let cursor: Option<i64> = self
            .blocking_store(|s| s.get_setting(CURSOR_KEY))
            .await
            .ok()
            .flatten()
            .and_then(|v| v.parse().ok());
        let mut filter = Filter::new()
            .kind(Kind::from_u16(wire::CALENDAR_KIND))
            .author(identity.pubkey)
            .limit(wire::MAX_PULL_EVENTS);
        if let Some(cursor) = cursor {
            let since = (cursor - PULL_OVERLAP_SECS).max(0) as u64;
            filter = filter.since(Timestamp::from_secs(since));
        }

        let events = self
            .transport
            .fetch(filter, FETCH_TIMEOUT)
            .await
            .map_err(|e| PullError::Offline(e.to_string()))?;

        // Newest per event UUID (relays already keep one per d tag, but
        // multiple relays can disagree).
        let mut newest: HashMap<String, nostr::Event> = HashMap::new();
        for event in events.into_iter().take(wire::MAX_PULL_EVENTS) {
            let Some(uuid) = wire::screen_envelope(&event, &identity.pubkey) else { continue };
            match newest.get(&uuid) {
                Some(seen) if seen.created_at >= event.created_at => {}
                _ => {
                    newest.insert(uuid, event);
                }
            }
        }

        let mut max_seen: i64 = cursor.unwrap_or(0);
        for event in newest.into_values() {
            let plaintext = match identity.signer.nip44_self_decrypt(&event.content).await {
                Ok(plaintext) => plaintext,
                Err(SignerError::Unavailable(_)) => return Err(PullError::SignerUnavailable),
                // Contract: skip payloads that fail to decrypt, never fail.
                Err(_) => continue,
            };
            let Some(payload) = wire::parse_payload(&plaintext) else { continue };
            let remote_id = event.id.to_hex();
            let owner = identity.pubkey.to_hex();
            match self
                .blocking_store(move |s| s.merge_remote_event(&payload, &remote_id, &owner))
                .await
            {
                Ok(Some(id)) => changed.push(id),
                Ok(None) => {}
                Err(e) => warn!("merge failed: {e}"),
            }
            max_seen = max_seen.max(event.created_at.as_secs() as i64);
        }

        if max_seen > 0 {
            let value = max_seen.to_string();
            let _ = self.blocking_store(move |s| s.set_setting(CURSOR_KEY, &value)).await;
        }
        Ok(())
    }

    // ------------------------------------------------------------------
    // Push
    // ------------------------------------------------------------------

    /// Drains due queue items. Returns the last error for the status line.
    async fn push(
        &self,
        identity: &ActiveIdentity,
        configured: &[String],
        changed: &mut Vec<String>,
    ) -> Option<String> {
        let items = match self.blocking_store(|s| s.due_queue_items(QUEUE_BATCH)).await {
            Ok(items) => items,
            Err(e) => return Some(e),
        };
        let mut last_error = None;
        for item in items {
            if let Err(e) = self.push_one(identity, configured, &item, changed).await {
                match e {
                    PushError::Parked(reason) => {
                        let next = Utc::now().timestamp_millis() + SIGNER_DEFER.as_millis() as i64;
                        let _ = self
                            .blocking_store({
                                let event_id = item.event_id.clone();
                                let reason = reason.clone();
                                move |s| {
                                    s.set_event_sync_state(
                                        &event_id,
                                        crate::model::SyncState::PendingSignature,
                                    )?;
                                    s.queue_defer(item.id, next, &reason)
                                }
                            })
                            .await;
                        last_error = Some(reason);
                    }
                    PushError::Retry(reason) => {
                        let backoff = BACKOFF_BASE_SECS
                            .saturating_mul(1_i64 << item.attempts.clamp(0, 10))
                            .min(BACKOFF_CAP_SECS);
                        let next = Utc::now().timestamp_millis() + backoff * 1000;
                        let _ = self
                            .blocking_store({
                                let reason = reason.clone();
                                move |s| s.queue_retry(item.id, next, &reason)
                            })
                            .await;
                        if item.attempts + 1 >= FAILING_THRESHOLD {
                            let _ = self
                                .blocking_store({
                                    let event_id = item.event_id.clone();
                                    let op = item.op.clone();
                                    let reason = reason.clone();
                                    move |s| {
                                        s.record_sync_failure(&event_id, &op, &reason)?;
                                        s.set_event_sync_state(
                                            &event_id,
                                            crate::model::SyncState::Failed,
                                        )
                                    }
                                })
                                .await;
                        }
                        last_error = Some(reason);
                    }
                    PushError::Drop => {
                        let _ = self.blocking_store(move |s| s.queue_done(item.id)).await;
                    }
                }
            }
        }
        last_error
    }

    async fn push_one(
        &self,
        identity: &ActiveIdentity,
        configured: &[String],
        item: &QueueItem,
        changed: &mut Vec<String>,
    ) -> Result<(), PushError> {
        let event_id = item.event_id.clone();
        let event = match self.blocking_store(move |s| s.get_event(&event_id)).await {
            Ok(event) => event,
            // The row is gone: the op is meaningless, drop it.
            Err(_) => return Err(PushError::Drop),
        };
        let deleting = item.op == "delete";
        if !deleting && event.is_deleted() {
            // A later delete superseded this publish.
            return Err(PushError::Drop);
        }

        // Encrypt + sign through the signer; both can be interactive-only.
        let owner = identity.pubkey.to_hex();
        let plaintext = wire::payload_json(&event, &owner, deleting).to_string();
        let ciphertext = match identity.signer.nip44_self_encrypt(&plaintext).await {
            Ok(c) => c,
            Err(SignerError::Unavailable(m)) => return Err(PushError::Parked(m)),
            Err(SignerError::Failed(m)) => return Err(PushError::Retry(m)),
        };
        let unsigned = wire::build_unsigned(identity.pubkey, &event, ciphertext);
        let signed = match identity.signer.sign_event(unsigned).await {
            Ok(s) => s,
            Err(SignerError::Unavailable(m)) => return Err(PushError::Parked(m)),
            Err(SignerError::Failed(m)) => return Err(PushError::Retry(m)),
        };
        let concrete_id = signed.id.to_hex();

        {
            let event_id = event.id.clone();
            let _ = self
                .blocking_store(move |s| {
                    s.set_event_sync_state(&event_id, crate::model::SyncState::Publishing)
                })
                .await;
        }

        if let Err(e) = self.publish_to_all(configured, signed).await {
            // Roll the visible state back to its pending flavour.
            let rollback = if deleting {
                crate::model::SyncState::DeletedPending
            } else {
                crate::model::SyncState::PendingPublish
            };
            let event_id = event.id.clone();
            let _ = self
                .blocking_store(move |s| s.set_event_sync_state(&event_id, rollback))
                .await;
            return Err(PushError::Retry(e));
        }

        // Deletion also publishes NIP-09 for the previous concrete id (both
        // mechanisms are required by the contract). Idempotent on retry.
        if deleting {
            if let Some(previous) = event
                .nostr_event_id
                .as_deref()
                .and_then(|hex| nostr::EventId::from_hex(hex).ok())
            {
                let unsigned = wire::build_deletion_unsigned(identity.pubkey, previous);
                match identity.signer.sign_event(unsigned).await {
                    Ok(deletion) => self
                        .publish_to_all(configured, deletion)
                        .await
                        .map_err(PushError::Retry)?,
                    Err(SignerError::Unavailable(m)) => return Err(PushError::Parked(m)),
                    Err(SignerError::Failed(m)) => return Err(PushError::Retry(m)),
                }
            }
        }

        let event_id = event.id.clone();
        let owner_hex = identity.pubkey.to_hex();
        let item_id = item.id;
        self.blocking_store(move |s| {
            s.mark_event_published(&event_id, &concrete_id, &owner_hex, deleting)?;
            s.queue_done(item_id)
        })
        .await
        .map_err(PushError::Retry)?;
        changed.push(event.id);
        Ok(())
    }

    /// Publishes and enforces the all-relays acceptance rule.
    async fn publish_to_all(
        &self,
        configured: &[String],
        event: nostr::Event,
    ) -> Result<(), String> {
        let outcome: PublishOutcome =
            match tokio::time::timeout(PUBLISH_TIMEOUT, self.transport.publish(event)).await {
                Ok(Ok(outcome)) => outcome,
                Ok(Err(e)) => return Err(e.to_string()),
                Err(_) => return Err("publish timed out".into()),
            };
        let normalize = |u: &str| u.trim_end_matches('/').to_owned();
        let accepted: Vec<String> = outcome.accepted.iter().map(|u| normalize(u)).collect();
        let missing: Vec<String> = configured
            .iter()
            .map(|u| normalize(u))
            .filter(|u| !accepted.contains(u))
            .collect();
        if missing.is_empty() {
            Ok(())
        } else {
            let detail = outcome
                .rejected
                .iter()
                .map(|(u, reason)| format!("{u}: {reason}"))
                .collect::<Vec<_>>()
                .join("; ");
            Err(if detail.is_empty() {
                format!("not accepted by: {}", missing.join(", "))
            } else {
                detail
            })
        }
    }

    // ------------------------------------------------------------------
    // Status + signals
    // ------------------------------------------------------------------

    pub async fn status_json(&self) -> String {
        let inner = self.status.lock().await.clone();
        let pending = self.blocking_store(|s| s.pending_operations()).await.unwrap_or(0);
        let failed = self
            .blocking_store(|s| s.failing_operations(FAILING_THRESHOLD))
            .await
            .unwrap_or(0);
        let relays = self.blocking_store(|s| s.relays()).await.unwrap_or_default();
        let last_sync = self
            .blocking_store(|s| s.get_setting(LAST_SYNC_KEY))
            .await
            .ok()
            .flatten();
        serde_json::json!({
            "schemaVersion": SCHEMA_VERSION,
            "state": inner.state,
            "operationId": inner.operation_id,
            "lastSyncAt": last_sync,
            "pending": pending,
            "failed": failed,
            "networkStatus": inner.network,
            "lastError": inner.last_error,
            "relays": relays.iter().map(|r| serde_json::json!({
                "url": r.url,
                "state": r.state,
                "lastOkAt": r.last_ok_ms,
            })).collect::<Vec<_>>(),
        })
        .to_string()
    }

    pub async fn network_status(&self) -> String {
        self.status.lock().await.network.clone()
    }

    async fn set_state(&self, state: &str) {
        self.status.lock().await.state = state.into();
    }

    async fn finish(&self, state: &str, error: Option<String>, network: &str) {
        {
            let mut inner = self.status.lock().await;
            inner.state = state.into();
            inner.network = network.into();
            inner.last_error = error.clone();
        }
        if let Some(e) = error {
            info!("sync finished with state {state}: {e}");
        }
        self.emit_sync_status().await;
    }

    async fn emit_sync_status(&self) {
        let Some(connection) = self.connection.get() else { return };
        let status = self.status_json().await;
        if let Ok(iface) = connection
            .object_server()
            .interface::<_, crate::bus::Calendar1>(crate::bus::OBJECT_PATH)
            .await
        {
            let _ = crate::bus::Calendar1::sync_status_changed(iface.signal_emitter(), status).await;
        }
    }

    async fn emit_events_changed(&self, ids: Vec<String>) {
        let Some(connection) = self.connection.get() else { return };
        if let Ok(iface) = connection
            .object_server()
            .interface::<_, crate::bus::Calendar1>(crate::bus::OBJECT_PATH)
            .await
        {
            let _ = crate::bus::Calendar1::events_changed(iface.signal_emitter(), ids).await;
        }
    }

    /// Store access without blocking the async runtime; returns the store
    /// error as a display string (the engine only reports, never unwraps).
    async fn blocking_store<T: Send + 'static>(
        &self,
        f: impl FnOnce(&Store) -> Result<T, crate::store::StoreError> + Send + 'static,
    ) -> Result<T, String> {
        let store = self.store.clone();
        tokio::task::spawn_blocking(move || f(&store))
            .await
            .map_err(|e| e.to_string())?
            .map_err(|e| e.to_string())
    }
}

enum PullError {
    Offline(String),
    SignerUnavailable,
}

enum PushError {
    /// Waiting on the user (interactive signer): defer without counting
    /// an attempt and park the event as pending_signature.
    Parked(String),
    /// Transient failure: exponential backoff, never dropped.
    Retry(String),
    /// The operation no longer makes sense; remove it.
    Drop,
}
