//! Domain model. The wire contract with the mobile app is documented in
//! docs/nostr-sync.md; the richer local fields (sync_state machine,
//! calendar_id, revisions) exist only in the service database and the D-Bus
//! JSON payloads (docs/dbus-api.md, schemaVersion 1).

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

pub const SCHEMA_VERSION: u32 = 1;

/// Hard input bounds (docs/dbus-api.md). Anything larger is rejected.
pub const MAX_JSON_ARG_BYTES: usize = 1024 * 1024;
pub const MAX_TITLE_CHARS: usize = 2048;
pub const MAX_TEXT_CHARS: usize = 65536;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum SyncState {
    LocalOnly,
    PendingSignature,
    PendingPublish,
    Publishing,
    Synced,
    Conflict,
    Failed,
    DeletedPending,
    DeletedSynced,
}

impl SyncState {
    pub fn as_str(self) -> &'static str {
        match self {
            SyncState::LocalOnly => "local_only",
            SyncState::PendingSignature => "pending_signature",
            SyncState::PendingPublish => "pending_publish",
            SyncState::Publishing => "publishing",
            SyncState::Synced => "synced",
            SyncState::Conflict => "conflict",
            SyncState::Failed => "failed",
            SyncState::DeletedPending => "deleted_pending",
            SyncState::DeletedSynced => "deleted_synced",
        }
    }

    pub fn parse(s: &str) -> Option<Self> {
        Some(match s {
            "local_only" => SyncState::LocalOnly,
            "pending_signature" => SyncState::PendingSignature,
            "pending_publish" => SyncState::PendingPublish,
            "publishing" => SyncState::Publishing,
            "synced" => SyncState::Synced,
            "conflict" => SyncState::Conflict,
            "failed" => SyncState::Failed,
            "deleted_pending" => SyncState::DeletedPending,
            "deleted_synced" => SyncState::DeletedSynced,
            _ => return None,
        })
    }

    pub fn is_deleted(self) -> bool {
        matches!(self, SyncState::DeletedPending | SyncState::DeletedSynced)
    }
}

/// Recurrence presets, mirroring the Dart model (`RecurrenceType`).
/// Unknown wire values degrade to `None` rather than erroring.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Recurrence {
    #[default]
    None,
    Daily,
    Weekly,
    Monthly,
    Yearly,
}

impl Recurrence {
    pub fn as_wire(self) -> Option<&'static str> {
        match self {
            Recurrence::None => None,
            Recurrence::Daily => Some("daily"),
            Recurrence::Weekly => Some("weekly"),
            Recurrence::Monthly => Some("monthly"),
            Recurrence::Yearly => Some("yearly"),
        }
    }

    pub fn from_wire(value: Option<&str>) -> Self {
        match value {
            Some("daily") => Recurrence::Daily,
            Some("weekly") => Recurrence::Weekly,
            Some("monthly") => Recurrence::Monthly,
            Some("yearly") => Recurrence::Yearly,
            _ => Recurrence::None,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub struct Reminder {
    #[serde(rename = "minutesBefore")]
    pub minutes_before: i64,
}

/// A calendar event as stored by the service. Times are UTC instants;
/// `timezone` is the IANA zone the event was authored in (display + reminder
/// wall-clock math), exactly like the Dart model.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Event {
    pub id: String,
    pub calendar_id: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub nostr_event_id: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub owner_pubkey: Option<String>,
    pub title: String,
    #[serde(default)]
    pub description: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub location: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub url: Option<String>,
    pub start: DateTime<Utc>,
    pub end: DateTime<Utc>,
    pub timezone: String,
    #[serde(default)]
    pub all_day: bool,
    #[serde(default)]
    pub recurrence: Recurrence,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub recurrence_end: Option<DateTime<Utc>>,
    #[serde(default)]
    pub reminders: Vec<Reminder>,
    /// "confirmed" | "tentative" | "cancelled"
    #[serde(default = "default_status")]
    pub status: String,
    /// "private" (default; everything is E2E-encrypted on the wire anyway)
    #[serde(default = "default_visibility")]
    pub visibility: String,
    /// Legacy Flutter ARGB literal, e.g. "0xFF2196F3" (wire contract).
    #[serde(default = "default_color")]
    pub color: String,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub deleted_at: Option<DateTime<Utc>>,
    pub local_revision: i64,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub remote_revision: Option<String>,
    pub sync_state: SyncState,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub source_device: Option<String>,
    #[serde(default, skip_serializing_if = "serde_json::Map::is_empty")]
    pub metadata: serde_json::Map<String, serde_json::Value>,
}

fn default_status() -> String {
    "confirmed".to_owned()
}
fn default_visibility() -> String {
    "private".to_owned()
}
fn default_color() -> String {
    "0xFF2196F3".to_owned()
}

impl Event {
    pub fn is_deleted(&self) -> bool {
        self.sync_state.is_deleted() || self.deleted_at.is_some()
    }

    /// The `d` tag of this event's kind-30078 replaceable event
    /// (legacy `epochs:` prefix — see docs/nostr-sync.md).
    /// Consumed by the sync worker (phase 7); already part of the wire
    /// contract and covered by tests, hence the targeted allow.
    #[allow(dead_code)]
    pub fn d_tag(&self) -> String {
        format!("epochs:{}", self.id)
    }
}

/// Draft accepted by `CreateEvent` (docs/dbus-api.md).
#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct EventDraft {
    pub title: String,
    #[serde(default)]
    pub description: String,
    #[serde(default)]
    pub location: Option<String>,
    #[serde(default)]
    pub url: Option<String>,
    pub start: DateTime<Utc>,
    pub end: DateTime<Utc>,
    #[serde(default)]
    pub timezone: Option<String>,
    #[serde(default)]
    pub all_day: bool,
    #[serde(default)]
    pub calendar_id: Option<String>,
    #[serde(default)]
    pub color: Option<String>,
    #[serde(default)]
    pub recurrence: Option<RecurrenceDraft>,
    #[serde(default)]
    pub reminders: Vec<Reminder>,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct RecurrenceDraft {
    #[serde(rename = "type")]
    pub kind: String,
    #[serde(default)]
    pub until: Option<DateTime<Utc>>,
}

/// JSON merge patch for `UpdateEvent`: only present fields change.
/// `null` clears nullable fields where that is meaningful.
#[derive(Debug, Clone, Default, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct EventPatch {
    pub title: Option<String>,
    pub description: Option<String>,
    #[serde(default, deserialize_with = "double_option")]
    pub location: Option<Option<String>>,
    #[serde(default, deserialize_with = "double_option")]
    pub url: Option<Option<String>>,
    pub start: Option<DateTime<Utc>>,
    pub end: Option<DateTime<Utc>>,
    pub timezone: Option<String>,
    pub all_day: Option<bool>,
    pub calendar_id: Option<String>,
    pub color: Option<String>,
    #[serde(default, deserialize_with = "double_option")]
    pub recurrence: Option<Option<RecurrenceDraft>>,
    pub reminders: Option<Vec<Reminder>>,
    pub status: Option<String>,
}

/// Distinguishes "field absent" from "field explicitly null".
fn double_option<'de, T, D>(de: D) -> Result<Option<Option<T>>, D::Error>
where
    T: Deserialize<'de>,
    D: serde::Deserializer<'de>,
{
    Deserialize::deserialize(de).map(Some)
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Calendar {
    pub id: String,
    pub name: String,
    pub color: String,
    pub is_default: bool,
    pub position: i64,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CalendarDraft {
    pub name: String,
    #[serde(default)]
    pub color: Option<String>,
}

#[derive(Debug, Clone, Default, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CalendarPatch {
    pub name: Option<String>,
    pub color: Option<String>,
    pub position: Option<i64>,
}

/// One concrete occurrence of a (possibly recurring) event inside a queried
/// range — the D-Bus agenda item (docs/dbus-api.md).
#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct Occurrence {
    pub schema_version: u32,
    pub event_id: String,
    pub occurrence_start: DateTime<Utc>,
    pub occurrence_end: DateTime<Utc>,
    pub title: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub location: Option<String>,
    pub all_day: bool,
    pub calendar_id: String,
    pub color: String,
    pub timezone: String,
    pub sync_state: SyncState,
    pub status: String,
    pub recurring: bool,
}

impl Occurrence {
    pub fn from_event(event: &Event, start: DateTime<Utc>, end: DateTime<Utc>) -> Self {
        Occurrence {
            schema_version: SCHEMA_VERSION,
            event_id: event.id.clone(),
            occurrence_start: start,
            occurrence_end: end,
            title: event.title.clone(),
            location: event.location.clone(),
            all_day: event.all_day,
            calendar_id: event.calendar_id.clone(),
            color: event.color.clone(),
            timezone: event.timezone.clone(),
            sync_state: event.sync_state,
            status: event.status.clone(),
            recurring: event.recurrence != Recurrence::None,
        }
    }
}

/// Validation shared by create/update paths.
pub fn validate_event_fields(
    title: &str,
    description: &str,
    start: DateTime<Utc>,
    end: DateTime<Utc>,
    timezone: &str,
) -> Result<(), String> {
    if title.trim().is_empty() {
        return Err("title must not be empty".into());
    }
    if title.chars().count() > MAX_TITLE_CHARS {
        return Err("title too long".into());
    }
    if description.chars().count() > MAX_TEXT_CHARS {
        return Err("description too long".into());
    }
    if end < start {
        return Err("end must not be before start".into());
    }
    if timezone.parse::<chrono_tz::Tz>().is_err() {
        return Err(format!("unknown IANA timezone: {timezone}"));
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use chrono::TimeZone;

    fn utc(y: i32, mo: u32, d: u32, h: u32, mi: u32) -> DateTime<Utc> {
        Utc.with_ymd_and_hms(y, mo, d, h, mi, 0).single().expect("valid test date")
    }

    #[test]
    fn recurrence_wire_round_trip() {
        for (r, s) in [
            (Recurrence::Daily, Some("daily")),
            (Recurrence::Weekly, Some("weekly")),
            (Recurrence::Monthly, Some("monthly")),
            (Recurrence::Yearly, Some("yearly")),
            (Recurrence::None, None),
        ] {
            assert_eq!(r.as_wire(), s);
            assert_eq!(Recurrence::from_wire(s), r);
        }
        // Unknown values degrade to None (wire contract).
        assert_eq!(Recurrence::from_wire(Some("fortnightly")), Recurrence::None);
    }

    #[test]
    fn validation_rejects_bad_input() {
        let s = utc(2026, 7, 19, 9, 0);
        let e = utc(2026, 7, 19, 10, 0);
        assert!(validate_event_fields("ok", "", s, e, "Europe/Rome").is_ok());
        assert!(validate_event_fields("  ", "", s, e, "Europe/Rome").is_err());
        assert!(validate_event_fields("ok", "", e, s, "Europe/Rome").is_err());
        assert!(validate_event_fields("ok", "", s, e, "Mars/Olympus").is_err());
    }

    #[test]
    fn d_tag_uses_the_legacy_epochs_prefix() {
        // Wire contract (docs/nostr-sync.md): the d tag keeps the historical
        // `epochs:` prefix for compatibility with pre-rename calendars.
        let json = serde_json::json!({
            "id": "abc-123", "calendarId": "default", "title": "t",
            "start": "2026-07-19T09:00:00Z", "end": "2026-07-19T10:00:00Z",
            "timezone": "UTC", "createdAt": "2026-07-19T09:00:00Z",
            "updatedAt": "2026-07-19T09:00:00Z", "localRevision": 1,
            "syncState": "local_only"
        });
        let event: Event = serde_json::from_value(json).expect("parse");
        assert_eq!(event.d_tag(), "epochs:abc-123");
    }

    #[test]
    fn event_patch_distinguishes_absent_from_null() {
        let patch: EventPatch = serde_json::from_str(r#"{"location":null}"#).expect("parse");
        assert_eq!(patch.location, Some(None));
        assert!(patch.url.is_none());
    }
}
