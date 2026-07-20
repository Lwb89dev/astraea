//! Wire codec for the kind-30078 calendar events (docs/nostr-sync.md — that
//! document is normative; this file implements it and nothing more).
//!
//! The payload JSON is the Dart `Event.toJson()` shape. Field-level rules the
//! contract requires from every implementation:
//! - `startTimeUtc`/`endTimeUtc`/`recurrenceEnd` are ISO-8601 UTC strings;
//! - `createdAt`/`updatedAt` are epoch milliseconds, but readers must also
//!   tolerate ISO strings (historical payloads);
//! - unknown `recurrence` values degrade to non-recurring, never to an error;
//! - unknown fields are ignored; readers skip payloads that fail to parse.

use chrono::{DateTime, SecondsFormat, TimeZone, Utc};
use nostr::{Event as NostrEvent, EventBuilder, Kind, Tag, Timestamp, UnsignedEvent};
use serde_json::{json, Map, Value};

use crate::model::{Event, Recurrence, Reminder, RemotePayload};

/// NIP-78 application-specific data, parameterized replaceable.
pub const CALENDAR_KIND: u16 = 30078;
/// Legacy `d`-tag prefix (pre-rename wire compatibility).
pub const D_PREFIX: &str = "epochs:";
/// Fetch bounds (docs/nostr-sync.md): ignore oversized ciphertexts, stop
/// collecting past this many events per REQ.
pub const MAX_CONTENT_CHARS: usize = 90_000;
pub const MAX_PULL_EVENTS: usize = 5_000;

/// Builds the plaintext payload JSON for `event` exactly as Dart
/// `Event.toJson()` would (key set and value shapes match the contract).
pub fn payload_json(event: &Event, owner_pubkey: &str, deleted: bool) -> Value {
    let iso = |t: DateTime<Utc>| t.to_rfc3339_opts(SecondsFormat::Millis, true);
    let mut payload = json!({
        "id": event.id,
        "title": event.title,
        "description": event.description,
        "startTimeUtc": iso(event.start),
        "endTimeUtc": iso(event.end),
        "timezone": event.timezone,
        "isAllDay": event.all_day,
        "recurrence": event.recurrence.as_wire(),
        "recurrenceEnd": event.recurrence_end.map(iso),
        "reminders": event.reminders.iter()
            .map(|r| json!({"minutesBefore": r.minutes_before}))
            .collect::<Vec<_>>(),
        "color": event.color,
        "location": event.location,
        "synced": true,
        "nostrEventId": event.nostr_event_id,
        "syncOwnerPubkey": owner_pubkey,
        "deleted": deleted,
        "createdAt": event.created_at.timestamp_millis(),
        "updatedAt": event.updated_at.timestamp_millis(),
    });
    // Optional v1 extension fields (ADR-005). "default" stays implicit so a
    // payload written by the service is byte-compatible with Android's for
    // single-calendar users.
    if let Some(obj) = payload.as_object_mut() {
        if event.calendar_id != "default" {
            obj.insert("calendarId".into(), json!(event.calendar_id));
        }
        if let Some(url) = &event.url {
            obj.insert("url".into(), json!(url));
        }
    }
    payload
}

/// The unsigned kind-30078 envelope for an encrypted payload.
/// `created_at = updatedAt` (seconds) is load-bearing: replaceable-event
/// ordering on relays must match the LWW merge key.
pub fn build_unsigned(
    author: nostr::PublicKey,
    event: &Event,
    ciphertext: String,
) -> UnsignedEvent {
    EventBuilder::new(Kind::from_u16(CALENDAR_KIND), ciphertext)
        .tag(Tag::identifier(event.d_tag()))
        .custom_created_at(Timestamp::from_secs(event.updated_at.timestamp() as u64))
        .build(author)
}

/// The NIP-09 deletion request for the *previous concrete* event id.
/// Never an `a` tag: deleting the replaceable coordinate would delete the
/// tombstone itself and let other devices resurrect the event.
pub fn build_deletion_unsigned(
    author: nostr::PublicKey,
    previous_event_id: nostr::EventId,
) -> UnsignedEvent {
    EventBuilder::delete(nostr::nips::nip09::EventDeletionRequest::new().id(previous_event_id))
        .build(author)
}

/// Envelope-level screening of a pulled event. Returns the `d`-tag event
/// UUID when this is a well-formed calendar event authored by `account`;
/// `None` means "skip silently" (the contract forbids failing on junk).
pub fn screen_envelope(event: &NostrEvent, account: &nostr::PublicKey) -> Option<String> {
    if event.kind != Kind::from_u16(CALENDAR_KIND) || event.pubkey != *account {
        return None;
    }
    if event.content.chars().count() > MAX_CONTENT_CHARS {
        return None;
    }
    if event.verify().is_err() {
        return None;
    }
    let d_tag = event.tags.identifier()?;
    d_tag.strip_prefix(D_PREFIX).map(str::to_owned)
}

/// Parses a decrypted payload. Tolerant by contract: missing fields default,
/// unknown fields are ignored, bad shapes return `None` (reader skips).
pub fn parse_payload(plaintext: &str) -> Option<RemotePayload> {
    let value: Map<String, Value> = serde_json::from_str(plaintext).ok()?;
    let id = value.get("id")?.as_str()?.to_owned();
    let start = parse_iso(value.get("startTimeUtc")?)?;
    let end = parse_iso(value.get("endTimeUtc")?)?;
    let str_or = |key: &str, default: &str| -> String {
        value.get(key).and_then(Value::as_str).unwrap_or(default).to_owned()
    };
    let opt_str = |key: &str| -> Option<String> {
        value.get(key).and_then(Value::as_str).map(str::to_owned)
    };
    let reminders = value
        .get("reminders")
        .and_then(Value::as_array)
        .map(|list| {
            list.iter()
                .filter_map(|r| r.get("minutesBefore")?.as_i64())
                .map(|minutes_before| Reminder { minutes_before })
                .collect()
        })
        .unwrap_or_default();
    Some(RemotePayload {
        id,
        title: str_or("title", ""),
        description: str_or("description", ""),
        start,
        end,
        timezone: str_or("timezone", "UTC"),
        all_day: value.get("isAllDay").and_then(Value::as_bool).unwrap_or(false),
        recurrence: Recurrence::from_wire(value.get("recurrence").and_then(Value::as_str)),
        recurrence_end: value.get("recurrenceEnd").and_then(parse_iso),
        reminders,
        color: str_or("color", "0xFF2196F3"),
        location: opt_str("location").filter(|s| !s.is_empty()),
        deleted: value.get("deleted").and_then(Value::as_bool).unwrap_or(false),
        created_at: value.get("createdAt").and_then(parse_timestamp).unwrap_or(start),
        updated_at: value.get("updatedAt").and_then(parse_timestamp).unwrap_or(start),
        calendar_id: opt_str("calendarId").filter(|s| !s.is_empty()),
        url: opt_str("url").filter(|s| !s.is_empty()),
    })
}

fn parse_iso(value: &Value) -> Option<DateTime<Utc>> {
    DateTime::parse_from_rfc3339(value.as_str()?).ok().map(|t| t.with_timezone(&Utc))
}

/// Epoch milliseconds, tolerating historical ISO-string values.
fn parse_timestamp(value: &Value) -> Option<DateTime<Utc>> {
    if let Some(ms) = value.as_i64() {
        return Utc.timestamp_millis_opt(ms).single();
    }
    parse_iso(value)
}

#[cfg(test)]
mod tests {
    use super::*;
    use chrono::TimeZone;

    fn sample_event() -> Event {
        serde_json::from_value(json!({
            "id": "5f0e8f7a-1111-4222-8333-944444444444",
            "calendarId": "default",
            "title": "Dentist",
            "description": "checkup",
            "start": "2026-07-19T09:00:00Z",
            "end": "2026-07-19T10:00:00Z",
            "timezone": "Europe/Rome",
            "reminders": [{"minutesBefore": 10}],
            "createdAt": "2026-07-19T08:00:00Z",
            "updatedAt": "2026-07-19T08:30:00Z",
            "localRevision": 1,
            "syncState": "pending_publish"
        }))
        .expect("valid event")
    }

    #[test]
    fn payload_matches_the_dart_shape() {
        let payload = payload_json(&sample_event(), "ab".repeat(32).as_str(), false);
        assert_eq!(payload["startTimeUtc"], "2026-07-19T09:00:00.000Z");
        assert_eq!(payload["isAllDay"], false);
        assert_eq!(payload["recurrence"], Value::Null);
        assert_eq!(payload["reminders"][0]["minutesBefore"], 10);
        assert_eq!(payload["createdAt"], 1784448000000_i64);
        assert_eq!(payload["updatedAt"], 1784449800000_i64);
        assert_eq!(payload["synced"], true);
        assert_eq!(payload["deleted"], false);
        // Default calendar stays implicit for Android byte-compatibility.
        assert!(payload.get("calendarId").is_none());
    }

    #[test]
    fn envelope_uses_updated_at_seconds_and_the_epochs_d_tag() {
        let keys = nostr::Keys::generate();
        let event = sample_event();
        let unsigned = build_unsigned(keys.public_key(), &event, "cipher".into());
        assert_eq!(unsigned.kind, Kind::from_u16(30078));
        assert_eq!(unsigned.created_at.as_secs() as i64, event.updated_at.timestamp());
        assert_eq!(
            unsigned.tags.identifier(),
            Some("epochs:5f0e8f7a-1111-4222-8333-944444444444")
        );
    }

    #[test]
    fn parse_payload_tolerates_historical_and_unknown_fields() {
        let plaintext = json!({
            "id": "x-1",
            "title": "t",
            "startTimeUtc": "2026-07-19T09:00:00.000Z",
            "endTimeUtc": "2026-07-19T10:00:00.000Z",
            "recurrence": "fortnightly",
            "createdAt": "2026-07-19T08:00:00.000Z",
            "updatedAt": 1784449800000_i64,
            "someFutureField": {"nested": true}
        })
        .to_string();
        let payload = parse_payload(&plaintext).expect("parses");
        assert_eq!(payload.recurrence, Recurrence::None);
        assert_eq!(payload.created_at, Utc.with_ymd_and_hms(2026, 7, 19, 8, 0, 0).unwrap());
        assert_eq!(payload.updated_at.timestamp_millis(), 1784449800000);
        assert_eq!(payload.timezone, "UTC");
        assert!(!payload.deleted);
    }

    #[test]
    fn parse_payload_skips_junk_instead_of_failing() {
        assert!(parse_payload("not json").is_none());
        assert!(parse_payload("{}").is_none());
        assert!(parse_payload(r#"{"id":"a"}"#).is_none());
    }

    #[test]
    fn deletion_request_targets_the_concrete_id_never_the_coordinate() {
        let keys = nostr::Keys::generate();
        let previous = nostr::EventId::all_zeros();
        let unsigned = build_deletion_unsigned(keys.public_key(), previous);
        assert_eq!(unsigned.kind, Kind::EventDeletion);
        let has_e = unsigned.tags.iter().any(|t| {
            t.as_slice().first().map(|k| k == "e").unwrap_or(false)
                && t.as_slice().get(1).map(|v| v == &previous.to_hex()).unwrap_or(false)
        });
        let has_a = unsigned.tags.iter().any(|t| t.as_slice().first().map(|k| k == "a").unwrap_or(false));
        assert!(has_e && !has_a);
    }
}
