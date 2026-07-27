//! Integration tests for the sync engine: real store + real crypto, fake
//! relays. Cover the offline-first contract — publish, tombstone + NIP-09,
//! all-relays acceptance, retry/backoff, signer parking and LWW pulls.

use std::sync::Arc;
use std::time::Duration;

use astraea_service::account::signer::{ReadOnlySigner, SignerBackend, SignerError, SignerKind};
use astraea_service::model::SyncState;
use astraea_service::store::{AttendeeStatus, Store};
use astraea_service::sync::engine::{ActiveIdentity, IdentitySource, SyncEngine};
use astraea_service::sync::transport::{
    PublishOutcome, RelayHealth, RelayTransport, TransportError,
};
use astraea_service::sync::wire;
use async_trait::async_trait;
use nostr::{Filter, JsonUtil, Keys};
use tokio::sync::Mutex;

// ---------------------------------------------------------------------
// Test doubles
// ---------------------------------------------------------------------

/// A signer with a real in-memory key: real signatures, real NIP-44.
struct TestSigner {
    keys: Keys,
}

#[async_trait]
impl SignerBackend for TestSigner {
    fn kind(&self) -> SignerKind {
        SignerKind::LocalDelegated
    }

    fn is_interactive_only(&self) -> bool {
        false
    }

    async fn sign_event(
        &self,
        unsigned: nostr::UnsignedEvent,
    ) -> Result<nostr::Event, SignerError> {
        unsigned
            .sign_with_keys(&self.keys)
            .map_err(|e| SignerError::Failed(e.to_string()))
    }

    async fn nip44_self_encrypt(&self, plaintext: &str) -> Result<String, SignerError> {
        nostr::nips::nip44::encrypt(
            self.keys.secret_key(),
            &self.keys.public_key(),
            plaintext,
            nostr::nips::nip44::Version::V2,
        )
        .map_err(|e| SignerError::Failed(e.to_string()))
    }

    async fn nip44_self_decrypt(&self, ciphertext: &str) -> Result<String, SignerError> {
        nostr::nips::nip44::decrypt(self.keys.secret_key(), &self.keys.public_key(), ciphertext)
            .map_err(|e| SignerError::Failed(e.to_string()))
    }

    async fn nip44_encrypt_to(
        &self,
        recipient: nostr::PublicKey,
        plaintext: &str,
    ) -> Result<String, SignerError> {
        nostr::nips::nip44::encrypt(
            self.keys.secret_key(),
            &recipient,
            plaintext,
            nostr::nips::nip44::Version::V2,
        )
        .map_err(|e| SignerError::Failed(e.to_string()))
    }

    async fn nip44_decrypt_from(
        &self,
        sender: nostr::PublicKey,
        ciphertext: &str,
    ) -> Result<String, SignerError> {
        nostr::nips::nip44::decrypt(self.keys.secret_key(), &sender, ciphertext)
            .map_err(|e| SignerError::Failed(e.to_string()))
    }
}

struct FixedIdentity {
    pubkey: nostr::PublicKey,
    keys: Option<Keys>,
}

#[async_trait]
impl IdentitySource for FixedIdentity {
    async fn active(&self) -> Option<ActiveIdentity> {
        let signer: Box<dyn SignerBackend> = match &self.keys {
            Some(keys) => Box::new(TestSigner { keys: keys.clone() }),
            None => Box::new(ReadOnlySigner),
        };
        Some(ActiveIdentity {
            pubkey: self.pubkey,
            signer,
        })
    }
}

#[derive(Default)]
struct FakeRelayState {
    /// Everything successfully published (in order).
    published: Vec<nostr::Event>,
    /// Events served to the next fetch.
    remote: Vec<nostr::Event>,
    /// Relay URLs that refuse writes ("blocked" simulates a dead relay).
    rejecting: Vec<String>,
    /// When true every network call fails (offline).
    offline: bool,
    configured: Vec<String>,
}

#[derive(Default)]
struct FakeRelays {
    state: Mutex<FakeRelayState>,
}

#[async_trait]
impl RelayTransport for FakeRelays {
    async fn configure(&self, urls: &[String]) -> Result<(), TransportError> {
        self.state.lock().await.configured = urls.to_vec();
        Ok(())
    }

    async fn publish(&self, event: nostr::Event) -> Result<PublishOutcome, TransportError> {
        let mut state = self.state.lock().await;
        if state.offline {
            return Err(TransportError::Failed("connection refused".into()));
        }
        let mut outcome = PublishOutcome::default();
        for url in state.configured.clone() {
            if state.rejecting.contains(&url) {
                outcome.rejected.push((url, "blocked: policy".into()));
            } else {
                outcome.accepted.push(url);
            }
        }
        if !outcome.accepted.is_empty() {
            state.published.push(event);
        }
        Ok(outcome)
    }

    async fn fetch(
        &self,
        _filter: Filter,
        _timeout: Duration,
    ) -> Result<Vec<nostr::Event>, TransportError> {
        let state = self.state.lock().await;
        if state.offline {
            return Err(TransportError::Failed("connection refused".into()));
        }
        Ok(state.remote.clone())
    }

    async fn health(&self) -> Vec<RelayHealth> {
        let state = self.state.lock().await;
        state
            .configured
            .iter()
            .map(|url| RelayHealth {
                url: url.clone(),
                connected: !state.offline,
            })
            .collect()
    }
}

// ---------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------

fn setup(keys: Option<Keys>) -> (Arc<Store>, Arc<SyncEngine>, Arc<FakeRelays>, Keys) {
    let identity_keys = keys.clone().unwrap_or_else(Keys::generate);
    let store = Arc::new(Store::open_in_memory().expect("store"));
    store
        .set_relays(&["wss://one.example".into(), "wss://two.example".into()])
        .expect("relays");
    let transport = Arc::new(FakeRelays::default());
    let identity = Arc::new(FixedIdentity {
        pubkey: identity_keys.public_key(),
        keys,
    });
    let engine = SyncEngine::new(store.clone(), identity, transport.clone());
    (store, engine, transport, identity_keys)
}

fn create_event(store: &Store, title: &str) -> astraea_service::model::Event {
    let draft = serde_json::from_value(serde_json::json!({
        "title": title,
        "start": "2026-07-20T09:00:00Z",
        "end": "2026-07-20T10:00:00Z",
        "timezone": "Europe/Rome"
    }))
    .expect("draft");
    store.create_event(draft, "test").expect("create")
}

/// A signed remote kind-30078 event carrying `payload` (self-encrypted).
fn remote_event(keys: &Keys, payload: serde_json::Value, updated_at_s: i64) -> nostr::Event {
    let ciphertext = nostr::nips::nip44::encrypt(
        keys.secret_key(),
        &keys.public_key(),
        payload.to_string(),
        nostr::nips::nip44::Version::V2,
    )
    .expect("encrypt");
    let uuid = payload["id"].as_str().expect("payload id");
    nostr::EventBuilder::new(nostr::Kind::from_u16(wire::CALENDAR_KIND), ciphertext)
        .tag(nostr::Tag::identifier(format!("epochs:{uuid}")))
        .custom_created_at(nostr::Timestamp::from_secs(updated_at_s as u64))
        .sign_with_keys(keys)
        .expect("sign")
}

fn wire_payload(id: &str, title: &str, updated_ms: i64, deleted: bool) -> serde_json::Value {
    serde_json::json!({
        "id": id,
        "title": title,
        "description": "",
        "startTimeUtc": "2026-07-20T09:00:00.000Z",
        "endTimeUtc": "2026-07-20T10:00:00.000Z",
        "timezone": "Europe/Rome",
        "isAllDay": false,
        "recurrence": null,
        "recurrenceEnd": null,
        "reminders": [],
        "color": "0xFF2196F3",
        "location": null,
        "synced": true,
        "nostrEventId": null,
        "syncOwnerPubkey": null,
        "deleted": deleted,
        "createdAt": 1784448000000_i64,
        "updatedAt": updated_ms
    })
}

// ---------------------------------------------------------------------
// Publish path
// ---------------------------------------------------------------------

#[tokio::test]
async fn create_publishes_an_encrypted_replaceable_event() {
    let keys = Keys::generate();
    let (store, engine, relays, _) = setup(Some(keys.clone()));
    let event = create_event(&store, "Dentist");

    engine.run_once().await;

    let state = relays.state.lock().await;
    assert_eq!(state.published.len(), 1);
    let wire_event = &state.published[0];
    assert_eq!(wire_event.kind.as_u16(), wire::CALENDAR_KIND);
    assert_eq!(
        wire_event.tags.identifier(),
        Some(format!("epochs:{}", event.id).as_str())
    );
    assert!(wire_event.verify().is_ok());

    // created_at is the LWW merge key, in seconds.
    let stored = store.get_event(&event.id).expect("stored");
    assert_eq!(
        wire_event.created_at.as_secs() as i64,
        stored.updated_at.timestamp()
    );

    // Content is NIP-44, decrypts to the contract payload.
    let plaintext =
        nostr::nips::nip44::decrypt(keys.secret_key(), &keys.public_key(), &wire_event.content)
            .expect("decrypts");
    let payload = wire::parse_payload(&plaintext).expect("parses");
    assert_eq!(payload.id, event.id);
    assert_eq!(payload.title, "Dentist");
    assert!(!payload.deleted);

    // Local bookkeeping: synced, concrete id recorded, queue drained.
    assert_eq!(stored.sync_state, SyncState::Synced);
    assert_eq!(
        stored.nostr_event_id.as_deref(),
        Some(wire_event.id.to_hex().as_str())
    );
    assert_eq!(store.pending_operations().expect("count"), 0);
}

#[tokio::test]
async fn delete_publishes_tombstone_and_nip09_for_the_previous_id() {
    let keys = Keys::generate();
    let (store, engine, relays, _) = setup(Some(keys.clone()));
    let event = create_event(&store, "Cancel me");
    engine.run_once().await;
    let first_concrete = store
        .get_event(&event.id)
        .expect("event")
        .nostr_event_id
        .expect("id");

    store.delete_event(&event.id).expect("delete");
    engine.run_once().await;

    let state = relays.state.lock().await;
    assert_eq!(state.published.len(), 3, "live + tombstone + NIP-09");
    let tombstone = &state.published[1];
    let deletion = &state.published[2];

    let plaintext =
        nostr::nips::nip44::decrypt(keys.secret_key(), &keys.public_key(), &tombstone.content)
            .expect("tombstone decrypts");
    assert!(wire::parse_payload(&plaintext).expect("parses").deleted);

    assert_eq!(deletion.kind, nostr::Kind::EventDeletion);
    let tags = deletion.as_json();
    assert!(
        tags.contains(&first_concrete),
        "NIP-09 must reference the previous concrete id"
    );
    assert!(!tags.contains("30078:"), "never the replaceable coordinate");

    assert_eq!(
        store.get_event(&event.id).expect("event").sync_state,
        SyncState::DeletedSynced
    );
    assert_eq!(store.pending_operations().expect("count"), 0);
}

#[tokio::test]
async fn partial_relay_acceptance_keeps_the_event_pending() {
    let (store, engine, relays, _) = setup(Some(Keys::generate()));
    relays
        .state
        .lock()
        .await
        .rejecting
        .push("wss://two.example".into());
    let event = create_event(&store, "Half-accepted");

    engine.run_once().await;

    // The contract: synced only when EVERY configured relay accepted.
    let stored = store.get_event(&event.id).expect("event");
    assert_eq!(stored.sync_state, SyncState::PendingPublish);
    assert_eq!(store.pending_operations().expect("count"), 1);

    // Backoff bookkeeping: not due immediately.
    assert!(store.due_queue_items(10).expect("due").is_empty());

    // The relay recovers → the retry (once due) succeeds. Force the retry
    // window by re-queueing through an edit.
    relays.state.lock().await.rejecting.clear();
    store
        .update_event(
            &event.id,
            serde_json::from_str(r#"{"title":"Half-accepted v2"}"#).expect("patch"),
        )
        .expect("update");
    engine.run_once().await;
    assert_eq!(
        store.get_event(&event.id).expect("event").sync_state,
        SyncState::Synced
    );
}

#[tokio::test]
async fn offline_keeps_the_queue_and_recovers() {
    let (store, engine, relays, _) = setup(Some(Keys::generate()));
    relays.state.lock().await.offline = true;
    let event = create_event(&store, "Written offline");

    engine.run_once().await;
    // Offline is detected at pull time, so push is skipped entirely: the
    // event keeps its local state and the queue item stays immediately due.
    assert_eq!(
        store.get_event(&event.id).expect("event").sync_state,
        SyncState::LocalOnly
    );
    assert_eq!(store.pending_operations().expect("count"), 1);

    relays.state.lock().await.offline = false;
    assert_eq!(store.due_queue_items(10).expect("due").len(), 1);
    engine.run_once().await;
    assert_eq!(
        store.get_event(&event.id).expect("event").sync_state,
        SyncState::Synced
    );
    assert_eq!(store.pending_operations().expect("count"), 0);
}

#[tokio::test]
async fn read_only_signer_parks_events_as_pending_signature() {
    let (store, engine, _, _) = setup(None);
    let event = create_event(&store, "Needs a signer");

    engine.run_once().await;

    let stored = store.get_event(&event.id).expect("event");
    assert_eq!(stored.sync_state, SyncState::PendingSignature);
    // Parked, not dropped and not burning retry attempts.
    assert_eq!(store.pending_operations().expect("count"), 1);
    assert!(store.due_queue_items(10).expect("due").is_empty());
    assert_eq!(store.failing_operations(1).expect("failing"), 0);
}

// ---------------------------------------------------------------------
// Pull path (LWW merge)
// ---------------------------------------------------------------------

#[tokio::test]
async fn pull_adopts_new_remote_events_and_applies_lww() {
    let keys = Keys::generate();
    let (store, engine, relays, _) = setup(Some(keys.clone()));

    // A brand-new remote event, and a remote update to a local synced one.
    let local = create_event(&store, "Local version");
    engine.run_once().await;
    let local_synced = store.get_event(&local.id).expect("event");
    let newer_ms = (local_synced.updated_at.timestamp() + 100) * 1000;

    {
        let mut state = relays.state.lock().await;
        state.remote = vec![
            remote_event(
                &keys,
                wire_payload(
                    "aaaaaaaa-0000-4000-8000-000000000001",
                    "From phone",
                    1784450000000,
                    false,
                ),
                1784450000,
            ),
            remote_event(
                &keys,
                wire_payload(&local.id, "Phone edit wins", newer_ms, false),
                newer_ms / 1000,
            ),
        ];
    }
    engine.run_once().await;

    let adopted = store
        .get_event("aaaaaaaa-0000-4000-8000-000000000001")
        .expect("adopted");
    assert_eq!(adopted.title, "From phone");
    assert_eq!(adopted.sync_state, SyncState::Synced);

    let merged = store.get_event(&local.id).expect("merged");
    assert_eq!(
        merged.title, "Phone edit wins",
        "strictly newer remote wins"
    );
}

#[tokio::test]
async fn pull_keeps_local_when_remote_is_older_or_tied() {
    let keys = Keys::generate();
    let (store, engine, relays, _) = setup(Some(keys.clone()));
    let local = create_event(&store, "Local wins");
    engine.run_once().await;
    let synced = store.get_event(&local.id).expect("event");

    let older_ms = (synced.updated_at.timestamp() - 100) * 1000;
    relays.state.lock().await.remote = vec![remote_event(
        &keys,
        wire_payload(&local.id, "Stale phone edit", older_ms, false),
        older_ms / 1000,
    )];
    engine.run_once().await;

    assert_eq!(
        store.get_event(&local.id).expect("event").title,
        "Local wins"
    );
}

#[tokio::test]
async fn pull_applies_remote_tombstones() {
    let keys = Keys::generate();
    let (store, engine, relays, _) = setup(Some(keys.clone()));
    let local = create_event(&store, "Deleted elsewhere");
    engine.run_once().await;
    let synced = store.get_event(&local.id).expect("event");

    let newer_ms = (synced.updated_at.timestamp() + 60) * 1000;
    relays.state.lock().await.remote = vec![remote_event(
        &keys,
        wire_payload(&local.id, "Deleted elsewhere", newer_ms, true),
        newer_ms / 1000,
    )];
    engine.run_once().await;

    let merged = store.get_event(&local.id).expect("event");
    assert_eq!(merged.sync_state, SyncState::DeletedSynced);
    // Hidden from views.
    let visible = store
        .events_in_range(
            "2026-07-19T00:00:00Z".parse().expect("start"),
            "2026-07-22T00:00:00Z".parse().expect("end"),
            &[],
        )
        .expect("range");
    assert!(visible.iter().all(|e| e.id != local.id));
}

#[tokio::test]
async fn pull_skips_foreign_and_junk_events() {
    let keys = Keys::generate();
    let stranger = Keys::generate();
    let (store, engine, relays, _) = setup(Some(keys.clone()));

    relays.state.lock().await.remote = vec![
        // Authored by someone else entirely.
        remote_event(
            &stranger,
            wire_payload(
                "bbbbbbbb-0000-4000-8000-000000000001",
                "Not yours",
                1784450000000,
                false,
            ),
            1784450000,
        ),
        // Garbage content under our key.
        nostr::EventBuilder::new(nostr::Kind::from_u16(wire::CALENDAR_KIND), "not nip44")
            .tag(nostr::Tag::identifier(
                "epochs:cccccccc-0000-4000-8000-000000000001",
            ))
            .sign_with_keys(&keys)
            .expect("sign"),
    ];
    engine.run_once().await;

    assert!(store
        .get_event("bbbbbbbb-0000-4000-8000-000000000001")
        .is_err());
    assert!(store
        .get_event("cccccccc-0000-4000-8000-000000000001")
        .is_err());
}

/// End-to-end proof of ADR-007's invite/accept flow across two independent
/// accounts sharing one relay: Alice invites Bob to an event she owns, Bob's
/// engine decrypts and stores the invitation (never touching Alice's actual
/// calendar event, which he does not own), Bob accepts, and Alice's engine
/// learns of the acceptance. Every hop is real NIP-44 encryption keyed to
/// the *other* party — this is the test that would fail if invites were
/// accidentally sent through `nip44_self_*` instead of `nip44_*_to`/`_from`.
#[tokio::test]
async fn two_party_invite_is_encrypted_end_to_end_and_reaches_acceptance() {
    let alice_keys = Keys::generate();
    let bob_keys = Keys::generate();
    let relay = "wss://relay.example".to_string();

    let alice_store = Arc::new(Store::open_in_memory().expect("store"));
    alice_store.set_relays(&[relay.clone()]).expect("relays");
    let bob_store = Arc::new(Store::open_in_memory().expect("store"));
    bob_store.set_relays(&[relay]).expect("relays");

    let transport = Arc::new(FakeRelays::default());
    let alice_identity = Arc::new(FixedIdentity {
        pubkey: alice_keys.public_key(),
        keys: Some(alice_keys.clone()),
    });
    let bob_identity = Arc::new(FixedIdentity {
        pubkey: bob_keys.public_key(),
        keys: Some(bob_keys.clone()),
    });
    let alice_engine = SyncEngine::new(alice_store.clone(), alice_identity, transport.clone());
    let bob_engine = SyncEngine::new(bob_store.clone(), bob_identity, transport.clone());

    // Alice creates an event and invites Bob to it.
    let event = create_event(&alice_store, "Team lunch");
    alice_store
        .add_attendee(&event.id, &bob_keys.public_key().to_hex())
        .expect("add attendee");

    // Alice's engine publishes both her calendar event (self-encrypted) and
    // the invite (encrypted to Bob). Relay any events she published so Bob
    // can pull them.
    alice_engine.run_once().await;
    let published = transport.state.lock().await.published.clone();
    // Nothing readable by a network observer: every event's content is
    // ciphertext, never the plaintext title.
    for e in &published {
        assert!(!e.content.contains("Team lunch"));
    }
    transport.state.lock().await.remote = published;

    // Bob's calendar stays empty — he does not own Alice's event — but he
    // gains exactly one pending invitation with the decrypted details.
    bob_engine.run_once().await;
    assert!(bob_store.get_event(&event.id).is_err());
    let pending = bob_store.pending_invitations().expect("pending");
    assert_eq!(pending.len(), 1);
    assert_eq!(pending[0].title, "Team lunch");
    assert_eq!(pending[0].inviter_pubkey, alice_keys.public_key().to_hex());

    // Bob accepts: a local copy of the event is created for him...
    let created = bob_store
        .respond_to_invitation(&pending[0].id, true, "test")
        .expect("respond")
        .expect("accepting creates a local event");
    assert_eq!(created.title, "Team lunch");

    // ...and his engine publishes the acceptance back to Alice.
    bob_engine.run_once().await;
    let published = transport.state.lock().await.published.clone();
    for e in &published {
        assert!(!e.content.contains("accepted"));
    }
    transport.state.lock().await.remote = published;

    // Alice's engine learns Bob accepted.
    alice_engine.run_once().await;
    let attendees = alice_store
        .attendees_for_event(&event.id)
        .expect("attendees");
    assert_eq!(attendees.len(), 1);
    assert_eq!(attendees[0].pubkey, bob_keys.public_key().to_hex());
    assert_eq!(attendees[0].status, AttendeeStatus::Accepted);
}
