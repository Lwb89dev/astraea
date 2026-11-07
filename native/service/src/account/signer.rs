//! Signer abstraction (docs/authentication.md, ADR-006).
//!
//! Browser login only proves key ownership; producing signatures afterwards
//! is a separate concern with several backends. The service always runs with
//! exactly one active [SignerBackend]; sync (phase 7) requests signatures
//! through it and treats `SignerUnavailable` as "park the event in
//! pending_signature".

use async_trait::async_trait;
use nostr::{Event, Keys, PublicKey, UnsignedEvent};

use super::secrets::SecretStore;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SignerKind {
    /// No signing possible: consultation only.
    ReadOnly,
    /// Per-signature round-trip through the browser (NIP-07). Interactive.
    BrowserNip07,
    /// NIP-46 remote signer (bunker). Preferred for continuous use.
    Remote,
    /// App-scoped delegated key held in the Secret Service. Never the main
    /// nsec; revocable by deleting the secret.
    LocalDelegated,
}

impl SignerKind {
    pub fn as_str(self) -> &'static str {
        match self {
            SignerKind::ReadOnly => "read_only",
            SignerKind::BrowserNip07 => "browser_nip07",
            SignerKind::Remote => "remote_nip46",
            SignerKind::LocalDelegated => "local_delegated",
        }
    }
}

#[derive(Debug, thiserror::Error)]
pub enum SignerError {
    #[error("signer unavailable: {0}")]
    Unavailable(String),
    #[error("signing failed: {0}")]
    Failed(String),
}

#[async_trait]
pub trait SignerBackend: Send + Sync {
    fn kind(&self) -> SignerKind;

    /// Whether the backend can currently produce signatures without user
    /// interaction (drives the `signerState` field of the auth status).
    fn is_interactive_only(&self) -> bool;

    async fn sign_event(&self, unsigned: UnsignedEvent) -> Result<Event, SignerError>;

    /// NIP-44 v2 self-encryption (sender = recipient = the account key).
    /// Backends without key material report `Unavailable` — the caller
    /// parks the operation, exactly like an unavailable signature.
    async fn nip44_self_encrypt(&self, plaintext: &str) -> Result<String, SignerError>;

    async fn nip44_self_decrypt(&self, ciphertext: &str) -> Result<String, SignerError>;

    /// NIP-44 v2 encryption to a third party (ADR-007 attendee invites):
    /// ECDH between the account's secret key and `recipient`. Distinct from
    /// `nip44_self_encrypt` because an invite is, by definition, addressed
    /// to someone else's key, not the sender's own.
    async fn nip44_encrypt_to(
        &self,
        recipient: PublicKey,
        plaintext: &str,
    ) -> Result<String, SignerError>;

    /// NIP-44 v2 decryption of a message from a third party: ECDH between
    /// the account's secret key and `sender`.
    async fn nip44_decrypt_from(
        &self,
        sender: PublicKey,
        ciphertext: &str,
    ) -> Result<String, SignerError>;
}

/// Shared "no key material here" answer for interactive-only backends.
fn nip44_unavailable() -> SignerError {
    SignerError::Unavailable(
        "this signer holds no key material for NIP-44; use a delegated or remote signer".into(),
    )
}

/// Consultation only: every signature request parks the operation.
pub struct ReadOnlySigner;

#[async_trait]
impl SignerBackend for ReadOnlySigner {
    fn kind(&self) -> SignerKind {
        SignerKind::ReadOnly
    }

    fn is_interactive_only(&self) -> bool {
        true
    }

    async fn sign_event(&self, _unsigned: UnsignedEvent) -> Result<Event, SignerError> {
        Err(SignerError::Unavailable(
            "read-only session: connect a signer to publish changes".into(),
        ))
    }

    async fn nip44_self_encrypt(&self, _plaintext: &str) -> Result<String, SignerError> {
        Err(nip44_unavailable())
    }

    async fn nip44_self_decrypt(&self, _ciphertext: &str) -> Result<String, SignerError> {
        Err(nip44_unavailable())
    }

    async fn nip44_encrypt_to(
        &self,
        _recipient: PublicKey,
        _plaintext: &str,
    ) -> Result<String, SignerError> {
        Err(nip44_unavailable())
    }

    async fn nip44_decrypt_from(
        &self,
        _sender: PublicKey,
        _ciphertext: &str,
    ) -> Result<String, SignerError> {
        Err(nip44_unavailable())
    }
}

/// NIP-07 through the browser. Each signature would require opening a browser
/// page and waiting for the user; the background sync path therefore treats
/// this signer as interactive-only and parks events until the user triggers
/// an interactive flow. (The interactive flow itself reuses the login bridge
/// machinery and is not implemented yet — tracked in docs/linux-progress.md.)
pub struct BrowserNip07Signer;

#[async_trait]
impl SignerBackend for BrowserNip07Signer {
    fn kind(&self) -> SignerKind {
        SignerKind::BrowserNip07
    }

    fn is_interactive_only(&self) -> bool {
        true
    }

    async fn sign_event(&self, _unsigned: UnsignedEvent) -> Result<Event, SignerError> {
        Err(SignerError::Unavailable(
            "browser signing requires user interaction; open Astraea to approve pending changes"
                .into(),
        ))
    }

    // `window.nostr.nip44` exists, but only inside an interactive browser
    // page — the background sync path cannot reach it.
    async fn nip44_self_encrypt(&self, _plaintext: &str) -> Result<String, SignerError> {
        Err(nip44_unavailable())
    }

    async fn nip44_self_decrypt(&self, _ciphertext: &str) -> Result<String, SignerError> {
        Err(nip44_unavailable())
    }

    async fn nip44_encrypt_to(
        &self,
        _recipient: PublicKey,
        _plaintext: &str,
    ) -> Result<String, SignerError> {
        Err(nip44_unavailable())
    }

    async fn nip44_decrypt_from(
        &self,
        _sender: PublicKey,
        _ciphertext: &str,
    ) -> Result<String, SignerError> {
        Err(nip44_unavailable())
    }
}

/// App-scoped key stored in the freedesktop Secret Service. This is NOT the
/// user's main nsec: it is a dedicated calendar key the user provisions
/// explicitly (or a future NIP-26 delegated key), revocable by `Logout` or by
/// deleting the item from the keyring.
pub struct LocalDelegatedSigner {
    secrets: SecretStore,
    account_pubkey: String,
}

impl LocalDelegatedSigner {
    pub fn new(secrets: SecretStore, account_pubkey: String) -> Self {
        Self {
            secrets,
            account_pubkey,
        }
    }

    async fn keys(&self) -> Result<Keys, SignerError> {
        let secret = self
            .secrets
            .get_delegated_key(&self.account_pubkey)
            .await
            .map_err(|e| SignerError::Unavailable(format!("secret service: {e}")))?
            .ok_or_else(|| {
                SignerError::Unavailable("no delegated key provisioned for this account".into())
            })?;
        Keys::parse(&secret).map_err(|_| SignerError::Failed("stored key is invalid".into()))
    }
}

#[async_trait]
impl SignerBackend for LocalDelegatedSigner {
    fn kind(&self) -> SignerKind {
        SignerKind::LocalDelegated
    }

    fn is_interactive_only(&self) -> bool {
        false
    }

    async fn sign_event(&self, unsigned: UnsignedEvent) -> Result<Event, SignerError> {
        let keys = self.keys().await?;
        unsigned
            .sign_with_keys(&keys)
            .map_err(|e| SignerError::Failed(e.to_string()))
    }

    async fn nip44_self_encrypt(&self, plaintext: &str) -> Result<String, SignerError> {
        let keys = self.keys().await?;
        nostr::nips::nip44::encrypt(
            keys.secret_key(),
            &keys.public_key(),
            plaintext,
            nostr::nips::nip44::Version::V2,
        )
        .map_err(|e| SignerError::Failed(e.to_string()))
    }

    async fn nip44_self_decrypt(&self, ciphertext: &str) -> Result<String, SignerError> {
        let keys = self.keys().await?;
        nostr::nips::nip44::decrypt(keys.secret_key(), &keys.public_key(), ciphertext)
            .map_err(|e| SignerError::Failed(e.to_string()))
    }

    async fn nip44_encrypt_to(
        &self,
        recipient: PublicKey,
        plaintext: &str,
    ) -> Result<String, SignerError> {
        let keys = self.keys().await?;
        nostr::nips::nip44::encrypt(
            keys.secret_key(),
            &recipient,
            plaintext,
            nostr::nips::nip44::Version::V2,
        )
        .map_err(|e| SignerError::Failed(e.to_string()))
    }

    async fn nip44_decrypt_from(
        &self,
        sender: PublicKey,
        ciphertext: &str,
    ) -> Result<String, SignerError> {
        let keys = self.keys().await?;
        nostr::nips::nip44::decrypt(keys.secret_key(), &sender, ciphertext)
            .map_err(|e| SignerError::Failed(e.to_string()))
    }
}

/// Chooses the backend for a stored signer name (the accounts.signer column).
///
/// `remote_nip46` is deliberately absent: a NIP-46 signer owns a live relay
/// connection, so it cannot be rebuilt statelessly per call. It is resolved by
/// [`crate::account::AccountManager::backend_for_account`], which reuses the
/// cached connection; anything unrecognised here (including `remote_nip46`
/// reaching this function by mistake) falls back to read-only, which parks
/// operations instead of failing them.
pub fn backend_for(
    name: &str,
    secrets: SecretStore,
    account_pubkey: &str,
) -> Box<dyn SignerBackend> {
    match name {
        "local_delegated" => Box::new(LocalDelegatedSigner::new(
            secrets,
            account_pubkey.to_owned(),
        )),
        "browser_nip07" => Box::new(BrowserNip07Signer),
        _ => Box::new(ReadOnlySigner),
    }
}
