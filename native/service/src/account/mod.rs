//! Identity module (ADR-004). Product-neutral by design: nothing in here
//! imports calendar types, so it can be extracted into a future shared
//! `lwb-nostr-account-service` for Astraea/Echoes/Kairos by moving the
//! module and re-pointing the bus name.

pub mod login;
pub mod secrets;
pub mod signer;

use std::sync::Arc;

use nostr::nips::nip19::ToBech32;
use tokio::sync::Mutex;
use tracing::{info, warn};

use crate::model::SCHEMA_VERSION;
use crate::store::Store;
use secrets::SecretStore;
use signer::SignerKind;

pub struct AccountManager {
    store: Arc<Store>,
    secrets: SecretStore,
    active_login: Mutex<Option<login::LoginSession>>,
    /// Set once the daemon connection exists; used to emit
    /// AuthenticationChanged from async completions (browser callback).
    connection: tokio::sync::OnceCell<zbus::Connection>,
}

#[derive(Debug, thiserror::Error)]
pub enum AccountError {
    #[error("{0}")]
    Store(#[from] crate::store::StoreError),
    #[error("no such login session")]
    NoSuchSession,
    #[error("login failed: {0}")]
    Login(String),
}

impl AccountManager {
    pub fn new(store: Arc<Store>) -> Arc<Self> {
        Arc::new(Self {
            store,
            secrets: SecretStore,
            active_login: Mutex::new(None),
            connection: tokio::sync::OnceCell::new(),
        })
    }

    pub fn set_connection(&self, connection: zbus::Connection) {
        let _ = self.connection.set(connection);
    }

    pub fn secrets(&self) -> SecretStore {
        self.secrets.clone()
    }

    /// The signer backend for the active account (ReadOnly when logged out).
    pub async fn active_signer(&self) -> Result<Box<dyn signer::SignerBackend>, AccountError> {
        Ok(match self.active_identity().await? {
            Some((_, backend)) => backend,
            None => Box::new(signer::ReadOnlySigner),
        })
    }

    /// The active account's pubkey (hex) with its signer backend, or `None`
    /// when logged out. Product-neutral: callers decide what to do with it.
    pub async fn active_identity(
        &self,
    ) -> Result<Option<(String, Box<dyn signer::SignerBackend>)>, AccountError> {
        let store = self.store.clone();
        let account = tokio::task::spawn_blocking(move || store.active_account())
            .await
            .map_err(|e| AccountError::Login(e.to_string()))??;
        Ok(account.map(|account| {
            let backend =
                signer::backend_for(&account.signer, self.secrets.clone(), &account.pubkey);
            (account.pubkey, backend)
        }))
    }

    /// Changes the active account's signer mode. The secret material itself
    /// never crosses D-Bus: provisioning writes to the Secret Service
    /// directly (see `astraea-service auth provision-key`); this only flips
    /// which backend the service uses.
    pub async fn set_signer(&self, signer_name: &str) -> Result<(), AccountError> {
        let valid = matches!(
            signer_name,
            "read_only" | "browser_nip07" | "remote_nip46" | "local_delegated"
        );
        if !valid {
            return Err(AccountError::Login(format!("unknown signer: {signer_name}")));
        }
        let store = self.store.clone();
        let name = signer_name.to_owned();
        tokio::task::spawn_blocking(move || store.set_active_account_signer(&name))
            .await
            .map_err(|e| AccountError::Login(e.to_string()))??;
        self.emit_authentication_changed().await;
        Ok(())
    }

    /// Starts a browser login session (cancelling any previous one) and
    /// returns the session JSON for the D-Bus reply.
    pub async fn begin_browser_login(self: &Arc<Self>) -> Result<String, AccountError> {
        let mut guard = self.active_login.lock().await;
        if let Some(previous) = guard.as_mut() {
            previous.cancel();
        }

        let (session, done) = login::begin(true)
            .await
            .map_err(|e| AccountError::Login(e.to_string()))?;
        let reply = serde_json::json!({
            "schemaVersion": SCHEMA_VERSION,
            "sessionId": session.session_id,
            "url": session.url,
            "expiresAt": session.expires_at.to_rfc3339(),
        })
        .to_string();
        *guard = Some(session);
        drop(guard);

        // Completion runs detached: verify → persist account → emit signal.
        let manager = Arc::clone(self);
        tokio::spawn(async move {
            match done.await {
                Ok(Ok(outcome)) => {
                    if let Err(e) = manager.complete_login(&outcome.pubkey).await {
                        warn!("could not persist login: {e}");
                    }
                }
                Ok(Err(reason)) => info!("browser login ended without success: {reason}"),
                Err(_) => {}
            }
            *manager.active_login.lock().await = None;
        });

        Ok(reply)
    }

    async fn complete_login(&self, pubkey: &str) -> Result<(), AccountError> {
        let npub = nostr::PublicKey::from_hex(pubkey)
            .ok()
            .and_then(|pk| pk.to_bech32().ok())
            .unwrap_or_default();
        let store = self.store.clone();
        let pubkey_owned = pubkey.to_owned();
        let npub_clone = npub.clone();
        tokio::task::spawn_blocking(move || {
            store.activate_account(&pubkey_owned, &npub_clone, SignerKind::BrowserNip07.as_str())
        })
        .await
        .map_err(|e| AccountError::Login(e.to_string()))??;
        info!("account activated via browser login");
        self.emit_authentication_changed().await;
        Ok(())
    }

    pub async fn cancel_browser_login(&self, session_id: &str) -> Result<(), AccountError> {
        let mut guard = self.active_login.lock().await;
        match guard.as_mut() {
            Some(session) if session.session_id == session_id => {
                session.cancel();
                *guard = None;
                Ok(())
            }
            _ => Err(AccountError::NoSuchSession),
        }
    }

    pub async fn status_json(&self) -> Result<String, AccountError> {
        let store = self.store.clone();
        let account = tokio::task::spawn_blocking(move || store.active_account())
            .await
            .map_err(|e| AccountError::Login(e.to_string()))??;
        let json = match account {
            None => serde_json::json!({
                "schemaVersion": SCHEMA_VERSION,
                "authenticated": false,
                "pubkey": serde_json::Value::Null,
                "npub": serde_json::Value::Null,
                "signer": "none",
                "signerState": "unavailable",
                "readOnly": true,
            }),
            Some(account) => {
                let backend =
                    signer::backend_for(&account.signer, self.secrets.clone(), &account.pubkey);
                let interactive_only = backend.is_interactive_only();
                serde_json::json!({
                    "schemaVersion": SCHEMA_VERSION,
                    "authenticated": true,
                    "pubkey": account.pubkey,
                    "npub": account.npub,
                    "signer": backend.kind().as_str(),
                    "signerState": if interactive_only { "interactive_only" } else { "ready" },
                    "readOnly": interactive_only,
                })
            }
        };
        Ok(json.to_string())
    }

    pub async fn logout(&self) -> Result<(), AccountError> {
        let store = self.store.clone();
        let account = tokio::task::spawn_blocking(move || store.active_account())
            .await
            .map_err(|e| AccountError::Login(e.to_string()))??;
        if let Some(account) = account {
            // Best-effort: a missing Secret Service must not block logout.
            if let Err(e) = self.secrets.clear_account(&account.pubkey).await {
                warn!("could not clear keyring items on logout: {e}");
            }
        }
        let store = self.store.clone();
        tokio::task::spawn_blocking(move || store.deactivate_accounts())
            .await
            .map_err(|e| AccountError::Login(e.to_string()))??;
        self.emit_authentication_changed().await;
        Ok(())
    }

    pub async fn accounts_json(&self) -> Result<String, AccountError> {
        let store = self.store.clone();
        let accounts = tokio::task::spawn_blocking(move || store.accounts())
            .await
            .map_err(|e| AccountError::Login(e.to_string()))??;
        let list: Vec<_> = accounts
            .into_iter()
            .map(|account| {
                serde_json::json!({
                    "id": account.id,
                    "pubkey": account.pubkey,
                    "npub": account.npub,
                    "label": account.label,
                    "signer": account.signer,
                })
            })
            .collect();
        Ok(serde_json::json!(list).to_string())
    }

    pub async fn switch_account(&self, account_id: &str) -> Result<(), AccountError> {
        let store = self.store.clone();
        let id = account_id.to_owned();
        tokio::task::spawn_blocking(move || store.switch_account(&id))
            .await
            .map_err(|e| AccountError::Login(e.to_string()))??;
        self.emit_authentication_changed().await;
        Ok(())
    }

    async fn emit_authentication_changed(&self) {
        let Some(connection) = self.connection.get() else { return };
        let Ok(status) = self.status_json().await else { return };
        let iface_ref = connection
            .object_server()
            .interface::<_, crate::bus::NostrAccount1>(crate::bus::OBJECT_PATH)
            .await;
        if let Ok(iface_ref) = iface_ref {
            let _ = crate::bus::NostrAccount1::authentication_changed(
                iface_ref.signal_emitter(),
                status,
            )
            .await;
        }
    }
}
