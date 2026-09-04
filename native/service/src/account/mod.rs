//! Identity module (ADR-004). Product-neutral by design: nothing in here
//! imports calendar types, so it can be extracted into a future shared
//! `lwb-nostr-account-service` for Astraea/Echoes/Kairos by moving the
//! module and re-pointing the bus name.

pub mod login;
pub mod nip46;
pub mod person;
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
    /// The live NIP-46 connection, cached for the process lifetime.
    ///
    /// Rebuilding it per call would mean re-opening the bunker relays on every
    /// sync cycle — needless traffic, needless IP exposure to the relay
    /// operator, and a slow first signature each time. Keyed by account pubkey
    /// so switching accounts cannot reuse the previous account's connection.
    remote_signer: Mutex<Option<(String, Arc<nip46::Nip46Signer>)>>,
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
            remote_signer: Mutex::new(None),
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
        let Some(account) = account else {
            return Ok(None);
        };
        let backend = self.backend_for_account(&account).await;
        Ok(Some((account.pubkey, backend)))
    }

    /// Resolves an account row to its signer backend.
    ///
    /// `remote_nip46` is special-cased so the cached, already-connected
    /// [`nip46::Nip46Signer`] is reused; every other mode is stateless and
    /// built on the spot. A stored session that no longer loads falls back to
    /// the read-only signer, which parks operations rather than failing them.
    async fn backend_for_account(
        &self,
        account: &crate::store::Account,
    ) -> Box<dyn signer::SignerBackend> {
        if account.signer != SignerKind::Remote.as_str() {
            return signer::backend_for(&account.signer, self.secrets.clone(), &account.pubkey);
        }
        match self.remote_signer(&account.pubkey).await {
            Some(remote) => Box::new(remote),
            None => Box::new(signer::ReadOnlySigner),
        }
    }

    /// Returns the cached remote signer for `pubkey`, loading it from the
    /// Secret Service on first use. `None` means "not configured or no longer
    /// readable" — never a panic and never a partially-trusted session.
    async fn remote_signer(&self, pubkey: &str) -> Option<Arc<nip46::Nip46Signer>> {
        let mut guard = self.remote_signer.lock().await;
        if let Some((cached_pubkey, signer)) = guard.as_ref() {
            if cached_pubkey == pubkey {
                return Some(Arc::clone(signer));
            }
        }

        let raw = match self.secrets.get_remote_signer_session(pubkey).await {
            Ok(Some(raw)) => raw,
            Ok(None) => return None,
            Err(e) => {
                warn!("could not read the remote-signer session: {e}");
                return None;
            }
        };
        let (uri, client_key, user) = nip46::StoredSession::parse(&raw)?;
        // A session stored for a different identity must never sign for this
        // one: that would silently publish under the wrong account.
        if user.to_hex() != pubkey {
            warn!("stored remote-signer session does not match the active account");
            return None;
        }

        let signer = nip46::Nip46Signer::restore(uri, client_key, user);
        *guard = Some((pubkey.to_owned(), Arc::clone(&signer)));
        Some(signer)
    }

    /// Connects a NIP-46 remote signer from a pasted `bunker://` string.
    ///
    /// This is simultaneously a *login*: only the holder of the account key
    /// can answer `get_public_key` through that signer, so the pubkey it
    /// returns is proof of ownership in exactly the sense the browser bridge
    /// establishes — and unlike the browser bridge it also leaves the service
    /// able to sign in the background, with no key on this machine.
    ///
    /// The connection string is never logged, never echoed into an error and
    /// never written anywhere except the Secret Service: it embeds a
    /// single-use secret.
    pub async fn connect_remote_signer(&self, uri: &str) -> Result<String, AccountError> {
        let parsed =
            nip46::BunkerUri::parse(uri).map_err(|e| AccountError::Login(e.to_string()))?;
        let (signer, session) = nip46::Nip46Signer::connect(parsed)
            .await
            .map_err(|e| AccountError::Login(e.to_string()))?;
        let pubkey = signer.user_pubkey().to_hex();

        self.secrets
            .set_remote_signer_session(&pubkey, &session.to_json())
            .await
            .map_err(|e| {
                AccountError::Login(format!("could not store the session in the keyring: {e}"))
            })?;
        *self.remote_signer.lock().await = Some((pubkey.clone(), signer));

        let npub = nostr::PublicKey::from_hex(&pubkey)
            .ok()
            .and_then(|pk| pk.to_bech32().ok())
            .unwrap_or_default();
        let store = self.store.clone();
        let pubkey_owned = pubkey.clone();
        tokio::task::spawn_blocking(move || {
            store.activate_account(&pubkey_owned, &npub, SignerKind::Remote.as_str())
        })
        .await
        .map_err(|e| AccountError::Login(e.to_string()))??;

        info!("account activated via NIP-46 remote signer");
        self.emit_authentication_changed().await;
        Ok(pubkey)
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
            return Err(AccountError::Login(format!(
                "unknown signer: {signer_name}"
            )));
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
            store.activate_account(
                &pubkey_owned,
                &npub_clone,
                SignerKind::BrowserNip07.as_str(),
            )
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
                let backend = self.backend_for_account(&account).await;
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
            // `clear_account` removes every Astraea item for the pubkey, which
            // includes the delegated key *and* the remote-signer session.
            if let Err(e) = self.secrets.clear_account(&account.pubkey).await {
                warn!("could not clear keyring items on logout: {e}");
            }
        }
        // Drop the live bunker connection too: leaving it cached would keep a
        // websocket open to the signer's relays for an account that has just
        // been signed out.
        *self.remote_signer.lock().await = None;
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
        // The cache is keyed by pubkey, so a stale entry could never be used
        // for the new account — but dropping it also closes the previous
        // account's bunker sockets instead of leaving them open.
        *self.remote_signer.lock().await = None;
        self.emit_authentication_changed().await;
        Ok(())
    }

    async fn emit_authentication_changed(&self) {
        let Some(connection) = self.connection.get() else {
            return;
        };
        let Ok(status) = self.status_json().await else {
            return;
        };
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
