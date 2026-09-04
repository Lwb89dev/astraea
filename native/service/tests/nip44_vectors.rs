//! NIP-44 v2 official test vectors — the same file the Dart implementation
//! validates (test/nip44_test.dart), per ADR-001: both sides must pass the
//! identical vectors or the self-encrypted wire format has diverged.

use base64::Engine;
use nostr::nips::nip44::{self, v2, v2::ConversationKey};
use nostr::{Keys, PublicKey, SecretKey};
use serde_json::Value;

fn vectors() -> Value {
    let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("../../test/fixtures/nip44.vectors.json");
    let raw = std::fs::read_to_string(path).expect("shared vectors file");
    serde_json::from_str(&raw).expect("vectors JSON")
}

fn b64(s: &str) -> Vec<u8> {
    base64::engine::general_purpose::STANDARD
        .decode(s)
        .expect("base64 payload")
}

#[test]
fn conversation_key_derivation_matches_the_vectors() {
    let doc = vectors();
    let cases = doc["v2"]["valid"]["get_conversation_key"]
        .as_array()
        .expect("cases");
    assert!(!cases.is_empty());
    for case in cases {
        let sec1 = SecretKey::from_hex(case["sec1"].as_str().expect("sec1")).expect("sec1 parses");
        let pub2 = PublicKey::from_hex(case["pub2"].as_str().expect("pub2")).expect("pub2 parses");
        let key = ConversationKey::derive(&sec1, &pub2).expect("derives");
        assert_eq!(
            hex::encode(key.as_bytes()),
            case["conversation_key"].as_str().expect("expected key"),
            "{}",
            case["note"].as_str().unwrap_or("")
        );
    }
}

#[test]
fn encrypt_decrypt_vectors_decrypt_and_round_trip() {
    let doc = vectors();
    let cases = doc["v2"]["valid"]["encrypt_decrypt"]
        .as_array()
        .expect("cases");
    assert!(!cases.is_empty());
    for case in cases {
        let sec1 = SecretKey::from_hex(case["sec1"].as_str().expect("sec1")).expect("sec1");
        let sec2 = SecretKey::from_hex(case["sec2"].as_str().expect("sec2")).expect("sec2");
        let pub1 = Keys::new(sec1.clone()).public_key();
        let pub2 = Keys::new(sec2.clone()).public_key();
        let plaintext = case["plaintext"].as_str().expect("plaintext");

        // Key derivation is symmetric and matches the vector.
        let key = ConversationKey::derive(&sec1, &pub2).expect("derive 1→2");
        let key_rev = ConversationKey::derive(&sec2, &pub1).expect("derive 2→1");
        assert_eq!(key.as_bytes(), key_rev.as_bytes());
        assert_eq!(
            hex::encode(key.as_bytes()),
            case["conversation_key"].as_str().expect("key")
        );

        // Decrypt direction against the fixed vector ciphertext.
        let decrypted =
            v2::decrypt_to_bytes(&key, &b64(case["ciphertext"].as_str().expect("ciphertext")))
                .expect("vector ciphertext decrypts");
        assert_eq!(String::from_utf8(decrypted).expect("utf8"), plaintext);

        // Encrypt direction through the public API (random nonce), decrypted
        // back with the peer's view of the conversation.
        let ciphertext =
            nip44::encrypt(&sec1, &pub2, plaintext, nip44::Version::V2).expect("encrypts");
        let round = nip44::decrypt(&sec2, &pub1, &ciphertext).expect("round trip decrypts");
        assert_eq!(round, plaintext);
    }
}

#[test]
fn invalid_vectors_are_rejected() {
    let doc = vectors();

    let cases = doc["v2"]["invalid"]["decrypt"]
        .as_array()
        .expect("decrypt cases");
    assert!(!cases.is_empty());
    for case in cases {
        let key_bytes =
            hex::decode(case["conversation_key"].as_str().expect("key")).expect("key hex");
        let key = ConversationKey::from_slice(&key_bytes).expect("key length");
        let payload = base64::engine::general_purpose::STANDARD
            .decode(case["ciphertext"].as_str().expect("ciphertext"));
        let outcome = payload.map(|bytes| v2::decrypt_to_bytes(&key, &bytes));
        assert!(
            matches!(outcome, Err(_) | Ok(Err(_))),
            "must reject: {}",
            case["note"].as_str().unwrap_or("")
        );
    }

    let cases = doc["v2"]["invalid"]["get_conversation_key"]
        .as_array()
        .expect("derivation cases");
    assert!(!cases.is_empty());
    for case in cases {
        let sec1 = SecretKey::from_hex(case["sec1"].as_str().expect("sec1"));
        let pub2 = PublicKey::from_hex(case["pub2"].as_str().expect("pub2"));
        let derivable = match (sec1, pub2) {
            (Ok(sec1), Ok(pub2)) => ConversationKey::derive(&sec1, &pub2).is_ok(),
            _ => false,
        };
        assert!(
            !derivable,
            "must reject: {}",
            case["note"].as_str().unwrap_or("")
        );
    }
}
