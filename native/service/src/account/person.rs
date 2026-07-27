//! Person lookup for event invites (ADR-007, docs/authentication.md).
//!
//! Faithfully ports the npub/NIP-05 resolution triad from Echoes'
//! `NostrService` (`echoes/lib/services/nostr_service.dart`), the sibling
//! project's only existing person-to-person Nostr flow — see ADR-007 for why
//! this part, specifically, is worth being consistent about across the
//! family rather than reinventing.
//!
//! Deliberately absent: relay-wide name search (NIP-50) or any directory
//! service. Echoes rejected that for a documented reason that applies
//! unchanged here — an unverified name match is an impersonation risk when
//! the wrong recipient means leaking a calendar event to a stranger. The
//! only "search" surface is the account's own contact list (kind 3),
//! filtered client-side (not implemented in this first version — see
//! docs/nostr-sync.md "Attendee invites" for the tracked follow-up; npub
//! and NIP-05 already cover the two ways of naming someone precisely).

use nostr::PublicKey;
use serde::Deserialize;

#[derive(Debug, thiserror::Error)]
pub enum PersonLookupError {
    #[error("not a valid npub or hex public key")]
    InvalidKey,
    #[error("not a valid NIP-05 identifier (expected name@domain)")]
    InvalidNip05Shape,
    #[error("could not resolve NIP-05 identifier: {0}")]
    Nip05Lookup(String),
    #[error("the domain has no entry for that name")]
    Nip05NotFound,
}

/// A resolved person: the pubkey plus how we got there. `via_nip05` is
/// surfaced to the caller because a NIP-05 identifier is the *domain
/// operator's* claim, not proof of identity — callers must let the user
/// confirm the resolved npub before treating it as their intended
/// recipient, exactly as Echoes' share sheet does.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ResolvedPerson {
    pub pubkey_hex: String,
    pub via_nip05: bool,
}

/// Resolves `query` as either an npub/hex pubkey (local, no network) or a
/// NIP-05 identifier (`name@domain`, one bounded HTTPS request). Dispatch is
/// by shape: anything containing `@` is treated as NIP-05.
pub async fn resolve(query: &str) -> Result<ResolvedPerson, PersonLookupError> {
    let trimmed = query.trim();
    if trimmed.contains('@') {
        let pubkey_hex = resolve_nip05(trimmed).await?;
        return Ok(ResolvedPerson {
            pubkey_hex,
            via_nip05: true,
        });
    }
    let pubkey_hex = resolve_npub_or_hex(trimmed)?;
    Ok(ResolvedPerson {
        pubkey_hex,
        via_nip05: false,
    })
}

/// npub1... (bech32) or 64-char lowercase hex. Local, offline, instant.
fn resolve_npub_or_hex(input: &str) -> Result<String, PersonLookupError> {
    if input.starts_with("npub1") {
        return PublicKey::parse(input)
            .map(|pk| pk.to_hex())
            .map_err(|_| PersonLookupError::InvalidKey);
    }
    let lower = input.to_lowercase();
    if lower.len() == 64 && lower.bytes().all(|b| b.is_ascii_hexdigit()) {
        return Ok(lower);
    }
    Err(PersonLookupError::InvalidKey)
}

#[derive(Deserialize)]
struct Nip05Document {
    names: std::collections::HashMap<String, String>,
}

/// `.well-known/nostr.json?name=<local>` over HTTPS only. Hardened the same
/// way Echoes' `_httpsGetBounded` is: the client never follows redirects
/// automatically (a redirect to a different host would silently exfiltrate
/// the query to an attacker-chosen origin) and both the connect+read and
/// the response body are bounded.
async fn resolve_nip05(identifier: &str) -> Result<String, PersonLookupError> {
    let (local_part, domain) = identifier
        .split_once('@')
        .ok_or(PersonLookupError::InvalidNip05Shape)?;
    if local_part.is_empty()
        || !local_part
            .bytes()
            .all(|b| b.is_ascii_alphanumeric() || matches!(b, b'.' | b'_' | b'-'))
    {
        return Err(PersonLookupError::InvalidNip05Shape);
    }
    if domain.is_empty() || domain.contains('/') || domain.contains(':') {
        return Err(PersonLookupError::InvalidNip05Shape);
    }

    let url = format!(
        "https://{domain}/.well-known/nostr.json?name={}",
        urlencode(local_part)
    );
    let client = reqwest::Client::builder()
        .redirect(reqwest::redirect::Policy::none())
        .timeout(std::time::Duration::from_secs(10))
        .build()
        .map_err(|e| PersonLookupError::Nip05Lookup(e.to_string()))?;
    let response = client
        .get(&url)
        .send()
        .await
        .map_err(|e| PersonLookupError::Nip05Lookup(e.to_string()))?;
    if !response.status().is_success() {
        return Err(PersonLookupError::Nip05NotFound);
    }

    const MAX_BODY_BYTES: usize = 64 * 1024;
    let bytes = response
        .bytes()
        .await
        .map_err(|e| PersonLookupError::Nip05Lookup(e.to_string()))?;
    if bytes.len() > MAX_BODY_BYTES {
        return Err(PersonLookupError::Nip05Lookup("response too large".into()));
    }
    let doc: Nip05Document =
        serde_json::from_slice(&bytes).map_err(|_| PersonLookupError::Nip05NotFound)?;

    let pubkey = doc
        .names
        .get(local_part)
        .or_else(|| {
            doc.names
                .iter()
                .find(|(name, _)| name.eq_ignore_ascii_case(local_part))
                .map(|(_, pk)| pk)
        })
        .ok_or(PersonLookupError::Nip05NotFound)?;

    let lower = pubkey.to_lowercase();
    if lower.len() == 64 && lower.bytes().all(|b| b.is_ascii_hexdigit()) {
        Ok(lower)
    } else {
        Err(PersonLookupError::Nip05Lookup(
            "domain returned a malformed pubkey".into(),
        ))
    }
}

fn urlencode(s: &str) -> String {
    let mut out = String::with_capacity(s.len());
    for byte in s.bytes() {
        if byte.is_ascii_alphanumeric() || matches!(byte, b'-' | b'_' | b'.' | b'~') {
            out.push(byte as char);
        } else {
            out.push_str(&format!("%{byte:02X}"));
        }
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;
    use nostr::ToBech32;

    #[test]
    fn resolves_hex_locally() {
        let hex = "ab".repeat(32);
        let result = resolve_npub_or_hex(&hex).expect("valid hex");
        assert_eq!(result, hex);
    }

    #[test]
    fn resolves_npub_locally() {
        let keys = nostr::Keys::generate();
        let npub = keys.public_key().to_bech32().expect("bech32");
        let result = resolve_npub_or_hex(&npub).expect("valid npub");
        assert_eq!(result, keys.public_key().to_hex());
    }

    #[test]
    fn rejects_garbage_key_input() {
        assert!(resolve_npub_or_hex("not-a-key").is_err());
        assert!(resolve_npub_or_hex("npub1invalid").is_err());
        assert!(resolve_npub_or_hex(&"a".repeat(63)).is_err()); // too short
    }

    #[test]
    fn urlencode_escapes_reserved_characters() {
        assert_eq!(urlencode("a b"), "a%20b");
        assert_eq!(urlencode("bob"), "bob");
        assert_eq!(urlencode("a+b@c"), "a%2Bb%40c");
    }

    #[tokio::test]
    async fn rejects_nip05_shapes_before_any_network_call() {
        // These must fail synchronously on shape, never attempt a connection.
        assert!(matches!(
            resolve("not-an-identifier@").await,
            Err(PersonLookupError::InvalidNip05Shape)
        ));
        assert!(matches!(
            resolve("bob@evil.com/path").await,
            Err(PersonLookupError::InvalidNip05Shape)
        ));
        assert!(matches!(
            resolve("bob@evil.com:8080").await,
            Err(PersonLookupError::InvalidNip05Shape)
        ));
    }
}
