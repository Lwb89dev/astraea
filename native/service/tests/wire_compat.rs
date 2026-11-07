//! Cross-implementation wire-compat tests: the same fixtures are asserted by
//! the Dart suite (test/wire_compat_test.dart). See docs/nostr-sync.md.

use astraea_service::sync::wire;
use serde_json::Value;

fn fixtures() -> Value {
    let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("../../test/fixtures/wire_payloads.json");
    let raw = std::fs::read_to_string(path).expect("shared fixture file");
    serde_json::from_str(&raw).expect("fixture JSON")
}

#[test]
fn shared_parse_cases_produce_the_expected_values() {
    let doc = fixtures();
    let cases = doc["parseCases"].as_array().expect("parseCases");
    assert!(!cases.is_empty());
    for case in cases {
        let name = case["name"].as_str().expect("name");
        let payload_json = case["payload"].to_string();
        let expect = &case["expect"];
        let payload =
            wire::parse_payload(&payload_json).unwrap_or_else(|| panic!("{name}: must parse"));

        assert_eq!(payload.id, expect["id"].as_str().expect("id"), "{name}: id");
        assert_eq!(
            payload.title,
            expect["title"].as_str().expect("title"),
            "{name}: title"
        );
        assert_eq!(
            payload.start.timestamp_millis(),
            expect["startMs"].as_i64().expect("startMs"),
            "{name}: start"
        );
        assert_eq!(
            payload.end.timestamp_millis(),
            expect["endMs"].as_i64().expect("endMs"),
            "{name}: end"
        );
        assert_eq!(
            payload.timezone,
            expect["timezone"].as_str().expect("timezone"),
            "{name}: tz"
        );
        assert_eq!(
            payload.all_day,
            expect["allDay"].as_bool().expect("allDay"),
            "{name}: allDay"
        );
        assert_eq!(
            payload.recurrence.as_wire(),
            expect["recurrence"].as_str(),
            "{name}: recurrence"
        );
        assert_eq!(
            payload.recurrence_end.map(|t| t.timestamp_millis()),
            expect["recurrenceEndMs"].as_i64(),
            "{name}: recurrenceEnd"
        );
        let minutes: Vec<i64> = payload.reminders.iter().map(|r| r.minutes_before).collect();
        let expected_minutes: Vec<i64> = expect["reminderMinutes"]
            .as_array()
            .expect("reminderMinutes")
            .iter()
            .filter_map(Value::as_i64)
            .collect();
        assert_eq!(minutes, expected_minutes, "{name}: reminders");
        assert_eq!(
            payload.location.as_deref(),
            expect["location"].as_str(),
            "{name}: location"
        );
        assert_eq!(
            payload.deleted,
            expect["deleted"].as_bool().expect("deleted"),
            "{name}: deleted"
        );
        assert_eq!(
            payload.created_at.timestamp_millis(),
            expect["createdAtMs"].as_i64().expect("createdAtMs"),
            "{name}: createdAt"
        );
        assert_eq!(
            payload.updated_at.timestamp_millis(),
            expect["updatedAtMs"].as_i64().expect("updatedAtMs"),
            "{name}: updatedAt"
        );

        // Linux-side extension fields, asserted only by this suite.
        if let Some(rust_only) = case.get("rustOnly") {
            assert_eq!(
                payload.calendar_id.as_deref(),
                rust_only["calendarId"].as_str(),
                "{name}: calendarId"
            );
            assert_eq!(
                payload.url.as_deref(),
                rust_only["url"].as_str(),
                "{name}: url"
            );
        }
    }
}

/// The produce direction: a payload written by this implementation must be
/// parseable by itself (and, via the Dart suite reading the same fixture
/// semantics, by the mobile app) with identical values.
#[test]
fn produced_payloads_round_trip() {
    let doc = fixtures();
    for case in doc["parseCases"].as_array().expect("parseCases") {
        let payload_json = case["payload"].to_string();
        let Some(parsed) = wire::parse_payload(&payload_json) else {
            continue;
        };
        // Rebuild a service event from the parsed payload and re-serialize.
        let event: astraea_service::model::Event = serde_json::from_value(serde_json::json!({
            "id": parsed.id,
            "calendarId": parsed.calendar_id.clone().unwrap_or_else(|| "default".into()),
            "title": parsed.title,
            "description": parsed.description,
            "location": parsed.location,
            "url": parsed.url,
            "start": parsed.start.to_rfc3339(),
            "end": parsed.end.to_rfc3339(),
            "timezone": parsed.timezone,
            "allDay": parsed.all_day,
            "recurrence": serde_json::to_value(parsed.recurrence).expect("recurrence"),
            "recurrenceEnd": parsed.recurrence_end.map(|t| t.to_rfc3339()),
            "reminders": parsed.reminders,
            "createdAt": parsed.created_at.to_rfc3339(),
            "updatedAt": parsed.updated_at.to_rfc3339(),
            "localRevision": 1,
            "syncState": "pending_publish"
        }))
        .expect("event from parsed payload");
        let produced = wire::payload_json(&event, &"ab".repeat(32), parsed.deleted).to_string();
        let reparsed = wire::parse_payload(&produced).expect("round trip parses");
        assert_eq!(reparsed.id, parsed.id);
        assert_eq!(reparsed.start, parsed.start);
        assert_eq!(reparsed.end, parsed.end);
        assert_eq!(reparsed.recurrence, parsed.recurrence);
        assert_eq!(reparsed.updated_at, parsed.updated_at);
        assert_eq!(reparsed.deleted, parsed.deleted);
        assert_eq!(reparsed.calendar_id, parsed.calendar_id);
        assert_eq!(reparsed.url, parsed.url);
    }
}
