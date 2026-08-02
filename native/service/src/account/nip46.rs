//! NIP-46 ("Nostr Connect" / bunker) remote signer.
//!
//! This is the only signer backend that can sign in the background without
//! any key material on the machine: the account key stays inside the user's
//! own signer (a phone app, a self-hosted bunker, a hosted service), and
//! astraea-service holds nothing but a throwaway *client* key that the signer
//! authorizes by pubkey and can revoke at any time.
//!
//! Wire format, spelled out so this file can be audited without the spec:
//!
//! ```text
//!  astraea-service (client key)                remote signer (account key)
//!        │ kind 24133, p-tagged to the signer, content = NIP-44 v2 under
//!        │ the conversation key (client_sk, signer_pk), of
//!        │ {"id":"<random>","method":"sign_event","params":["<json>"]}
//!        │─────────────── relays from the bunker:// URI ───────────────►
//!        │ kind 24133 back, p-tagged to the client, same encryption,
//!        │ {"id":"<same>","result":"<value>"} | {"id":..,"error":".."}
//!        ◄────────────────────────────────────────────────────────────
//! ```
//!
//! ## Why this is hand-rolled rather than pulling in a NIP-46 client crate
//!
//! Everything cryptographic here is delegated to `nostr::nips::nip44` and to
//! the `nostr-sdk` relay pool, both already dependencies and both audited.
//! What is left is JSON envelope handling and request/response matching —
//! roughly the code below. The published client crate would instead add a
//! dependency subtree that includes NIP-04 (deprecated, unauthenticated
//! AES-CBC) purely as a feature-flag side effect. Fewer dependencies and no
//! deprecated crypto compiled into the daemon is the better trade for a
//! background service that runs on the user's session bus.
//!
//! ## Hostile-input rules (a relay is untrusted transport)
//!
//! - every inbound frame must be kind 24133, authored by the configured
//!   signer pubkey, and pass `Event::verify()` (id **and** signature) before
//!   it is decrypted;
//! - replies are matched only against request ids this process generated and
//!   is still waiting for, so a relay cannot answer an unasked question;
//! - inbound content is length-capped before decryption and the pending map
//!   is capped, so neither a hostile relay nor a hostile signer can grow
//!   memory without bound;
//! - every request is bounded by [`REQUEST_TIMEOUT`];
//! - nothing here logs parameters, results, plaintext, the client key or the
//!   bunker secret.

use std::collections::HashMap;
use std::sync::Arc;
use std::time::Duration;

use async_trait::async_trait;
use nostr::nips::nip44;
use nostr::{Event, EventBuilder, Filter, Keys, Kind, PublicKey, SecretKey, Tag, UnsignedEvent};
use nostr_sdk::{Client, RelayPoolNotification, Timestamp};
use rand::Rng as _;
use serde::{Deserialize, Serialize};
use tokio::sync::{oneshot, Mutex, OnceCell};
use tracing::debug;

use super::signer::{SignerBackend, SignerError, SignerKind};

/// How long one request may wait for the signer. Generous: a bunker often has
/// to wake a phone and show an approval prompt.
const REQUEST_TIMEOUT: Duration = Duration::from_secs(90);

/// The handshake runs while a user is watching a dialog, so it gets a shorter
/// bound than a background signature.
const CONNECT_TIMEOUT: Duration = Duration::from_secs(60);

/// A reply is a small JSON document; the largest realistic one is a signed
/// event, itself bounded by what we asked to have signed. Anything larger is
/// a relay flooding us, not a signer answering us.
const MAX_RESPONSE_BYTES: usize = 256 * 1024;

/// Sync decrypts events one at a time, so a handful of in-flight requests is
/// already generous. The cap bounds the pending map.
const MAX_PENDING: usize = 64;

/// Upper bound on relays taken from a pasted connection string: a bunker
/// publishes one or two, and every extra relay is another operator learning
/// this machine's IP address.
const MAX_RELAYS: usize = 4;

/// Clock-skew tolerance when asking relays for "replies from now on".
const SUBSCRIPTION_SKEW_SECS: u64 = 120;

// ---------------------------------------------------------------------
// bunker:// connection string
// ---------------------------------------------------------------------

/// A parsed `bunker://<signer-pubkey>?relay=…&relay=…&secret=…` string.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct BunkerUri {
    pub signer: PublicKey,
    pub relays: Vec<String>,
    pub secret: Option<String>,
}

impl BunkerUri {
    /// Parses a connection string. The error is deliberately detail-free: the
    /// input embeds a single-use secret and must never be echoed into a log,
    /// a D-Bus error message or a CLI diagnostic.
    pub fn parse(raw: &str) -> Result<Self, SignerError> {
        let raw = raw.trim();
        let parsed = url::Url::parse(raw).map_err(|_| Self::malformed())?;
        if parsed.scheme() != "bunker" {
            return Err(Self::malformed());
        }

        // `bunker://<pubkey>` puts the key in the authority; some signers emit
        // `bunker:<pubkey>` and it lands in the path instead.
        let host = parsed.host_str().unwrap_or_default();
        let key = if host.is_empty() {
            parsed.path().trim_matches('/')
        } else {
            host
        };
        let signer = PublicKey::from_hex(key).map_err(|_| Self::malformed())?;

        let mut relays = Vec::new();
        let mut secret = None;
        for (name, value) in parsed.query_pairs() {
            match name.as_ref() {
                "relay" if relays.len() < MAX_RELAYS => {
                    let url = value.into_owned();
                    // Same relay rules as the sync transport: one definition
                    // of "a valid relay URL" for the whole service.
                    if crate::sync::transport::validate_relay_url(&url).is_ok()
                        && !relays.contains(&url)
                    {
                        relays.push(url);
                    }
                }
                "secret" if !value.is_empty() => secret = Some(value.into_owned()),
                _ => {}
            }
        }
        if relays.is_empty() {
            return Err(Self::malformed());
        }

        Ok(Self {
            signer,
            relays,
            secret,
        })
    }

    fn malformed() -> SignerError {
        SignerError::Failed("not a valid bunker:// connection string".into())
    }
}

// ---------------------------------------------------------------------
// Persisted session
// ---------------------------------------------------------------------

/// What has to survive a service restart to keep the connection usable. It
/// contains the client key and the bunker secret, so it is stored *only* in
/// the freedesktop Secret Service — never in SQLite, config files or logs.
///
/// The field names match the mobile client's stored session byte for byte, so
/// the two implementations stay auditable against one description.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StoredSession {
    pub version: u8,
    pub signer: String,
    pub relays: Vec<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub secret: Option<String>,
    #[serde(rename = "clientKey")]
    pub client_key: String,
    pub user: String,
}

impl StoredSession {
    pub fn to_json(&self) -> String {
        // Serializing a struct of owned Strings cannot fail; a broken
        // serializer must not take signing down with it.
        serde_json::to_string(self).unwrap_or_default()
    }

    /// Re-validates every field. A half-readable blob is rejected outright:
    /// the caller then treats the signer as unconfigured rather than trusting
    /// part of a tampered-with session.
    pub fn parse(raw: &str) -> Option<(BunkerUri, SecretKey, PublicKey)> {
        let stored: StoredSession = serde_json::from_str(raw).ok()?;
        if stored.version != 1 {
            return None;
        }
        let signer = PublicKey::from_hex(&stored.signer).ok()?;
        let user = PublicKey::from_hex(&stored.user).ok()?;
        let client_key = SecretKey::from_hex(&stored.client_key).ok()?;

        let relays: Vec<String> = stored
            .relays
            .into_iter()
            .filter(|url| crate::sync::transport::validate_relay_url(url).is_ok())
            .take(MAX_RELAYS)
            .collect();
        if relays.is_empty() {
            return None;
        }

        Some((
            BunkerUri {
                signer,
                relays,
                secret: stored.secret.filter(|s| !s.is_empty()),
            },
            client_key,
            user,
        ))
    }
}

// ---------------------------------------------------------------------
// Signer
// ---------------------------------------------------------------------

type PendingMap = Arc<Mutex<HashMap<String, oneshot::Sender<Result<String, String>>>>>;

pub struct Nip46Signer {
    client: Client,
    /// The throwaway identity this install presents to the signer. NOT the
    /// account key: it can sign nothing but NIP-46 request envelopes.
    keys: Keys,
    uri: BunkerUri,
    /// The account key the signer acts for, confirmed during the handshake.
    user_pubkey: PublicKey,
    pending: PendingMap,
    /// Latches the relay connection + subscription + reply pump, so every
    /// request can call it and only the first one does any work.
    started: OnceCell<()>,
}

impl Nip46Signer {
    /// Opens a brand-new connection from a pasted `bunker://` string.
    ///
    /// Returns the connected signer plus the session blob the caller must
    /// persist. The account pubkey comes from the signer itself — this is
    /// simultaneously a login: nobody can produce a `get_public_key` reply for
    /// an identity whose key they do not hold.
    pub async fn connect(uri: BunkerUri) -> Result<(Arc<Self>, StoredSession), SignerError> {
        let keys = Keys::generate();
        // Until `get_public_key` answers, the account key is unknown. The
        // handshake below never touches `user_pubkey`, and the connected
        // signer returned at the end is rebuilt with the confirmed value, so
        // the invariant "user_pubkey is what the signer confirmed" holds for
        // every signer instance callers can observe.
        let handshake = Arc::new(Self::build(uri.clone(), keys.clone(), keys.public_key()));

        // The `connect` handshake presents the client key and the single-use
        // secret from the URI; the signer answers "ack" once it has authorized
        // this client.
        let params = vec![uri.signer.to_hex(), uri.secret.clone().unwrap_or_default()];
        handshake
            .request_with_timeout("connect", params, CONNECT_TIMEOUT)
            .await?;

        let user_hex = handshake
            .request_with_timeout("get_public_key", Vec::new(), CONNECT_TIMEOUT)
            .await?;
        let user_pubkey = PublicKey::parse(user_hex.trim())
            .map_err(|_| SignerError::Failed("the remote signer returned no usable key".into()))?;

        let session = StoredSession {
            version: 1,
            signer: uri.signer.to_hex(),
            relays: uri.relays.clone(),
            secret: uri.secret.clone(),
            client_key: keys.secret_key().to_secret_hex(),
            user: user_pubkey.to_hex(),
        };
        Ok((Arc::new(Self::build(uri, keys, user_pubkey)), session))
    }

    /// Rebuilds a signer from a stored session. No network I/O happens here:
    /// the relay connection is opened lazily on the first request, so a signer
    /// that is currently offline never blocks service start-up.
    pub fn restore(uri: BunkerUri, client_key: SecretKey, user_pubkey: PublicKey) -> Arc<Self> {
        Arc::new(Self::build(uri, Keys::new(client_key), user_pubkey))
    }

    fn build(uri: BunkerUri, keys: Keys, user_pubkey: PublicKey) -> Self {
        Self {
            client: Client::default(),
            keys,
            uri,
            user_pubkey,
            pending: Arc::new(Mutex::new(HashMap::new())),
            started: OnceCell::new(),
        }
    }

    pub fn user_pubkey(&self) -> PublicKey {
        self.user_pubkey
    }

    // -----------------------------------------------------------------
    // Transport
    // -----------------------------------------------------------------

    async fn ensure_started(&self) -> Result<(), SignerError> {
        self.started
            .get_or_try_init(|| async {
                for url in &self.uri.relays {
                    self.client
                        .add_relay(url.as_str())
                        .await
                        .map_err(|e| SignerError::Unavailable(format!("bunker relay: {e}")))?;
                }
                self.client.connect().await;

                let filter = Filter::new()
                    .kind(Kind::NostrConnect)
                    .author(self.uri.signer)
                    .pubkey(self.keys.public_key())
                    .since(Timestamp::now() - SUBSCRIPTION_SKEW_SECS);
                self.client
                    .subscribe(filter, None)
                    .await
                    .map_err(|e| SignerError::Unavailable(format!("bunker subscribe: {e}")))?;

                spawn_reply_pump(
                    self.client.notifications(),
                    self.keys.clone(),
                    self.uri.signer,
                    Arc::clone(&self.pending),
                );
                Ok(())
            })
            .await
            .map(|_| ())
    }

    async fn request(&self, method: &str, params: Vec<String>) -> Result<String, SignerError> {
        self.request_with_timeout(method, params, REQUEST_TIMEOUT)
            .await
    }

    async fn request_with_timeout(
        &self,
        method: &str,
        params: Vec<String>,
        timeout: Duration,
    ) -> Result<String, SignerError> {
        self.ensure_started().await?;

        let id = random_request_id();
        let (tx, rx) = oneshot::channel();
        {
            let mut pending = self.pending.lock().await;
            if pending.len() >= MAX_PENDING {
                return Err(SignerError::Unavailable(
                    "too many pending remote-signer requests".into(),
                ));
            }
            pending.insert(id.clone(), tx);
        }

        let outcome = self.dispatch(&id, method, params, rx, timeout).await;
        // Always reclaim the slot, including on timeout: otherwise a signer
        // that goes quiet would fill the pending map one dead entry at a time.
        self.pending.lock().await.remove(&id);
        outcome
    }

    async fn dispatch(
        &self,
        id: &str,
        method: &str,
        params: Vec<String>,
        rx: oneshot::Receiver<Result<String, String>>,
        timeout: Duration,
    ) -> Result<String, SignerError> {
        let envelope = serde_json::json!({ "id": id, "method": method, "params": params });
        let content = nip44::encrypt(
            self.keys.secret_key(),
            &self.uri.signer,
            envelope.to_string(),
            nip44::Version::V2,
        )
        .map_err(|e| SignerError::Failed(format!("nip44: {e}")))?;

        let event = EventBuilder::new(Kind::NostrConnect, content)
            .tag(Tag::public_key(self.uri.signer))
            .sign_with_keys(&self.keys)
            .map_err(|e| SignerError::Failed(e.to_string()))?;
        self.client
            .send_event(&event)
            .await
            .map_err(|e| SignerError::Unavailable(format!("bunker relay: {e}")))?;
        debug!(method, "nip46 request sent");

        // The reply pump owns the sender; the only ways this resolves are a
        // matched reply, the pump going away, or the timeout.
        let Ok(received) = tokio::time::timeout(timeout, rx).await else {
            return Err(SignerError::Unavailable(
                "the remote signer did not respond in time".into(),
            ));
        };
        match received {
            Ok(Ok(result)) => Ok(result),
            Ok(Err(message)) => Err(SignerError::Failed(format!("remote signer: {message}"))),
            Err(_) => Err(SignerError::Unavailable(
                "the remote signer connection was closed".into(),
            )),
        }
    }
}

/// Reads relay notifications and completes waiting requests.
///
/// Holds no reference to [`Nip46Signer`], so dropping the signer drops the
/// client, closes the broadcast channel and ends this task — no leak, no
/// reference cycle.
fn spawn_reply_pump(
    mut notifications: tokio::sync::broadcast::Receiver<RelayPoolNotification>,
    keys: Keys,
    signer_pubkey: PublicKey,
    pending: PendingMap,
) {
    tokio::spawn(async move {
        while let Ok(notification) = notifications.recv().await {
            let RelayPoolNotification::Event { event, .. } = notification else {
                continue;
            };
            let Some((id, outcome)) = decode_reply(&event, &keys, signer_pubkey) else {
                continue;
            };
            if let Some(sender) = pending.lock().await.remove(&id) {
                let _ = sender.send(outcome);
            }
        }
    });
}

/// Validates, decrypts and parses one inbound frame.
///
/// Returns `None` for anything that is not a well-formed reply from the
/// configured signer — silently, because a relay can deliver arbitrary events
/// to this subscription and none of them should produce a log line, let alone
/// an error path.
fn decode_reply(
    event: &Event,
    keys: &Keys,
    signer_pubkey: PublicKey,
) -> Option<(String, Result<String, String>)> {
    if event.kind != Kind::NostrConnect || event.pubkey != signer_pubkey {
        return None;
    }
    if event.content.len() > MAX_RESPONSE_BYTES || event.verify().is_err() {
        return None;
    }
    let plaintext = nip44::decrypt(keys.secret_key(), &signer_pubkey, &event.content).ok()?;
    let reply: serde_json::Value = serde_json::from_str(&plaintext).ok()?;

    let id = reply.get("id")?.as_str()?.to_owned();
    let result = reply.get("result").and_then(|v| v.as_str());
    // `auth_url` is not an answer: the signer wants the user to approve this
    // client in a browser and will send the real reply afterwards. The
    // background service has no way to show that page, so the request is
    // failed with an actionable message instead of hanging until the timeout.
    if result == Some("auth_url") {
        return Some((
            id,
            Err("the signer needs interactive approval; connect it again from the app".into()),
        ));
    }
    if let Some(error) = reply.get("error").and_then(|v| v.as_str()) {
        if !error.is_empty() {
            return Some((id, Err(error.to_owned())));
        }
    }
    Some((id, Ok(result?.to_owned())))
}

/// 16 bytes from the OS CSPRNG, hex-encoded. Request ids must be
/// unguessable: they are what stops a relay from matching a fabricated reply
/// to a request it never saw. Same source as the browser login bridge's
/// state/challenge nonces.
fn random_request_id() -> String {
    let mut bytes = [0u8; 16];
    rand::rng().fill_bytes(&mut bytes);
    bytes.iter().map(|b| format!("{b:02x}")).collect()
}

#[async_trait]
impl SignerBackend for Arc<Nip46Signer> {
    fn kind(&self) -> SignerKind {
        SignerKind::Remote
    }

    /// Once connected, NIP-46 signs in the background: the user approved this
    /// client once, at connection time. That is exactly what makes it the
    /// preferred backend for unattended sync.
    fn is_interactive_only(&self) -> bool {
        false
    }

    async fn sign_event(&self, unsigned: UnsignedEvent) -> Result<Event, SignerError> {
        let request = serde_json::to_string(&unsigned)
            .map_err(|e| SignerError::Failed(format!("serialize: {e}")))?;
        let raw = self.request("sign_event", vec![request]).await?;
        let signed: Event = serde_json::from_str(&raw)
            .map_err(|_| SignerError::Failed("the signer returned no signed event".into()))?;

        // A remote signer is trusted to hold the key, not to be honest about
        // what it signed. Re-check the id + signature and that the identity is
        // the account we asked for; the caller cannot inspect this itself.
        signed
            .verify()
            .map_err(|_| SignerError::Failed("the signer returned an invalid event".into()))?;
        if signed.pubkey != self.user_pubkey || signed.kind != unsigned.kind {
            return Err(SignerError::Failed(
                "the signer returned an event for a different identity".into(),
            ));
        }
        Ok(signed)
    }

    async fn nip44_self_encrypt(&self, plaintext: &str) -> Result<String, SignerError> {
        self.request(
            "nip44_encrypt",
            vec![self.user_pubkey.to_hex(), plaintext.to_owned()],
        )
        .await
    }

    async fn nip44_self_decrypt(&self, ciphertext: &str) -> Result<String, SignerError> {
        self.request(
            "nip44_decrypt",
            vec![self.user_pubkey.to_hex(), ciphertext.to_owned()],
        )
        .await
    }

    async fn nip44_encrypt_to(
        &self,
        recipient: PublicKey,
        plaintext: &str,
    ) -> Result<String, SignerError> {
        self.request(
            "nip44_encrypt",
            vec![recipient.to_hex(), plaintext.to_owned()],
        )
        .await
    }

    async fn nip44_decrypt_from(
        &self,
        sender: PublicKey,
        ciphertext: &str,
    ) -> Result<String, SignerError> {
        self.request(
            "nip44_decrypt",
            vec![sender.to_hex(), ciphertext.to_owned()],
        )
        .await
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const SIGNER_HEX: &str = "3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d";

    #[test]
    fn parses_a_well_formed_bunker_uri() {
        let uri = BunkerUri::parse(&format!(
            "bunker://{SIGNER_HEX}?relay=wss://relay.example.com&secret=abc123"
        ))
        .expect("uri");
        assert_eq!(uri.signer.to_hex(), SIGNER_HEX);
        assert_eq!(uri.relays, vec!["wss://relay.example.com".to_string()]);
        assert_eq!(uri.secret.as_deref(), Some("abc123"));
    }

    #[test]
    fn rejects_uris_that_cannot_be_used() {
        // Wrong scheme, no relay, bad key, and a relay URL that the shared
        // transport rules reject — every one of these must fail closed.
        assert!(BunkerUri::parse(&format!("https://{SIGNER_HEX}?relay=wss://r.io")).is_err());
        assert!(BunkerUri::parse(&format!("bunker://{SIGNER_HEX}")).is_err());
        assert!(BunkerUri::parse("bunker://not-a-key?relay=wss://r.io").is_err());
        assert!(BunkerUri::parse(&format!("bunker://{SIGNER_HEX}?relay=https://r.io")).is_err());
    }

    #[test]
    fn caps_the_relay_list() {
        let relays: String = (0..10)
            .map(|i| format!("&relay=wss://relay{i}.example.com"))
            .collect();
        let uri = BunkerUri::parse(&format!("bunker://{SIGNER_HEX}?a=1{relays}")).expect("uri");
        assert_eq!(uri.relays.len(), MAX_RELAYS);
    }

    #[test]
    fn stored_sessions_round_trip_and_reject_tampering() {
        let keys = Keys::generate();
        let session = StoredSession {
            version: 1,
            signer: SIGNER_HEX.to_string(),
            relays: vec!["wss://relay.example.com".to_string()],
            secret: Some("abc123".to_string()),
            client_key: keys.secret_key().to_secret_hex(),
            user: keys.public_key().to_hex(),
        };
        let (uri, client_key, user) = StoredSession::parse(&session.to_json()).expect("parsed");
        assert_eq!(uri.signer.to_hex(), SIGNER_HEX);
        assert_eq!(client_key.to_secret_hex(), session.client_key);
        assert_eq!(user, keys.public_key());

        // An unknown version, or a session whose only relay is unusable, is
        // treated as absent rather than partially trusted.
        let mut bad = session.clone();
        bad.version = 2;
        assert!(StoredSession::parse(&bad.to_json()).is_none());
        let mut no_relays = session;
        no_relays.relays = vec!["https://relay.example.com".to_string()];
        assert!(StoredSession::parse(&no_relays.to_json()).is_none());
    }

    #[test]
    fn request_ids_are_unique_and_hex() {
        let a = random_request_id();
        let b = random_request_id();
        assert_eq!(a.len(), 32);
        assert_ne!(a, b);
        assert!(a.chars().all(|c| c.is_ascii_hexdigit()));
    }
}
