//! Synchronous data-access layer over SQLite. The D-Bus layer calls this via
//! `tokio::task::spawn_blocking`; nothing here performs network I/O.

use std::path::PathBuf;
use std::sync::Mutex;

use chrono::{DateTime, TimeZone, Utc};
use rusqlite::{params, Connection, OptionalExtension, Row};
use uuid::Uuid;

use crate::db::{self, DbError};
use crate::model::{
    validate_event_fields, Calendar, CalendarDraft, CalendarPatch, Event, EventDraft, EventPatch,
    Recurrence, Reminder, SyncState,
};

#[derive(Debug, thiserror::Error)]
pub enum StoreError {
    #[error("{0}")]
    Db(#[from] DbError),
    #[error("sqlite error: {0}")]
    Sqlite(#[from] rusqlite::Error),
    #[error("not found: {0}")]
    NotFound(String),
    #[error("invalid argument: {0}")]
    Invalid(String),
    #[error("store mutex poisoned")]
    Poisoned,
}

pub struct Store {
    conn: Mutex<Connection>,
    pub db_path: PathBuf,
}

fn now_ms() -> i64 {
    Utc::now().timestamp_millis()
}

fn ms_to_dt(ms: i64) -> DateTime<Utc> {
    Utc.timestamp_millis_opt(ms).single().unwrap_or_else(Utc::now)
}

impl Store {
    pub fn open(path: PathBuf) -> Result<Self, StoreError> {
        let conn = db::open(&path)?;
        Ok(Store { conn: Mutex::new(conn), db_path: path })
    }

    #[cfg(test)]
    pub fn open_in_memory() -> Result<Self, StoreError> {
        let conn = Connection::open_in_memory()?;
        conn.pragma_update(None, "foreign_keys", "ON")?;
        db::migrate(&conn, false, std::path::Path::new(":memory:"))?;
        Ok(Store { conn: Mutex::new(conn), db_path: PathBuf::from(":memory:") })
    }

    fn with_conn<T>(&self, f: impl FnOnce(&Connection) -> Result<T, StoreError>) -> Result<T, StoreError> {
        let guard = self.conn.lock().map_err(|_| StoreError::Poisoned)?;
        f(&guard)
    }

    // ------------------------------------------------------------------
    // Events
    // ------------------------------------------------------------------

    pub fn create_event(&self, draft: EventDraft, source_device: &str) -> Result<Event, StoreError> {
        let timezone = draft.timezone.clone().unwrap_or_else(|| "UTC".to_owned());
        validate_event_fields(&draft.title, &draft.description, draft.start, draft.end, &timezone)
            .map_err(StoreError::Invalid)?;

        let (recurrence, recurrence_end) = match &draft.recurrence {
            None => (Recurrence::None, None),
            Some(r) => (Recurrence::from_wire(Some(r.kind.as_str())), r.until),
        };
        let id = match draft.id {
            Some(ref requested) => {
                let parsed = Uuid::parse_str(requested)
                    .map_err(|_| StoreError::Invalid("id must be a UUID".into()))?;
                parsed.to_string()
            }
            None => Uuid::new_v4().to_string(),
        };
        let now = Utc::now();
        let event = Event {
            id,
            calendar_id: draft.calendar_id.clone().unwrap_or_else(|| "default".to_owned()),
            nostr_event_id: None,
            owner_pubkey: None,
            title: draft.title,
            description: draft.description,
            location: draft.location.filter(|s| !s.is_empty()),
            url: draft.url.filter(|s| !s.is_empty()),
            start: draft.start,
            end: draft.end,
            timezone,
            all_day: draft.all_day,
            recurrence,
            recurrence_end,
            reminders: draft.reminders,
            status: "confirmed".to_owned(),
            visibility: "private".to_owned(),
            color: draft.color.unwrap_or_else(|| "0xFF2196F3".to_owned()),
            created_at: now,
            updated_at: now,
            deleted_at: None,
            local_revision: 1,
            remote_revision: None,
            sync_state: SyncState::LocalOnly,
            source_device: Some(source_device.to_owned()),
            metadata: serde_json::Map::new(),
        };

        self.with_conn(|conn| {
            let calendar_exists: i64 = conn.query_row(
                "SELECT COUNT(*) FROM calendars WHERE id = ?1 AND deleted = 0",
                [&event.calendar_id],
                |r| r.get(0),
            )?;
            if calendar_exists == 0 {
                return Err(StoreError::NotFound(format!("calendar {}", event.calendar_id)));
            }
            let duplicate: i64 =
                conn.query_row("SELECT COUNT(*) FROM events WHERE id = ?1", [&event.id], |r| {
                    r.get(0)
                })?;
            if duplicate > 0 {
                return Err(StoreError::Invalid(format!("event id {} already exists", event.id)));
            }
            insert_event_row(conn, &event)?;
            enqueue(conn, &event.id, "publish")?;
            Ok(())
        })?;
        Ok(event)
    }

    pub fn get_event(&self, id: &str) -> Result<Event, StoreError> {
        self.with_conn(|conn| {
            conn.query_row(&format!("SELECT {EVENT_COLS} FROM events WHERE id = ?1"), [id], event_from_row)
                .optional()?
                .ok_or_else(|| StoreError::NotFound(format!("event {id}")))
        })
    }

    pub fn update_event(&self, id: &str, patch: EventPatch) -> Result<Event, StoreError> {
        let mut event = self.get_event(id)?;
        if event.is_deleted() {
            return Err(StoreError::NotFound(format!("event {id}")));
        }

        if let Some(v) = patch.title {
            event.title = v;
        }
        if let Some(v) = patch.description {
            event.description = v;
        }
        if let Some(v) = patch.location {
            event.location = v.filter(|s| !s.is_empty());
        }
        if let Some(v) = patch.url {
            event.url = v.filter(|s| !s.is_empty());
        }
        if let Some(v) = patch.start {
            event.start = v;
        }
        if let Some(v) = patch.end {
            event.end = v;
        }
        if let Some(v) = patch.timezone {
            event.timezone = v;
        }
        if let Some(v) = patch.all_day {
            event.all_day = v;
        }
        if let Some(v) = patch.calendar_id {
            event.calendar_id = v;
        }
        if let Some(v) = patch.color {
            event.color = v;
        }
        if let Some(v) = patch.status {
            event.status = v;
        }
        if let Some(v) = patch.reminders {
            event.reminders = v;
        }
        if let Some(v) = patch.recurrence {
            match v {
                None => {
                    event.recurrence = Recurrence::None;
                    event.recurrence_end = None;
                }
                Some(r) => {
                    event.recurrence = Recurrence::from_wire(Some(r.kind.as_str()));
                    event.recurrence_end = r.until;
                }
            }
        }
        validate_event_fields(&event.title, &event.description, event.start, event.end, &event.timezone)
            .map_err(StoreError::Invalid)?;

        // Replaceable-event ordering has one-second resolution on the wire:
        // guarantee a strictly newer updatedAt (see docs/nostr-sync.md).
        let min_next = event.updated_at + chrono::Duration::seconds(1);
        event.updated_at = std::cmp::max(Utc::now(), min_next);
        event.local_revision += 1;
        event.sync_state = match event.sync_state {
            SyncState::Synced | SyncState::Failed | SyncState::Conflict => SyncState::PendingPublish,
            other => other,
        };

        self.with_conn(|conn| {
            let calendar_exists: i64 = conn.query_row(
                "SELECT COUNT(*) FROM calendars WHERE id = ?1 AND deleted = 0",
                [&event.calendar_id],
                |r| r.get(0),
            )?;
            if calendar_exists == 0 {
                return Err(StoreError::NotFound(format!("calendar {}", event.calendar_id)));
            }
            update_event_row(conn, &event)?;
            enqueue(conn, &event.id, "publish")?;
            Ok(())
        })?;
        Ok(event)
    }

    /// Tombstones the event (never a hard delete: other devices must learn
    /// the deletion through sync) and queues the NIP-09 + tombstone publish.
    pub fn delete_event(&self, id: &str) -> Result<Event, StoreError> {
        let mut event = self.get_event(id)?;
        if event.is_deleted() {
            return Ok(event);
        }
        let min_next = event.updated_at + chrono::Duration::seconds(1);
        event.updated_at = std::cmp::max(Utc::now(), min_next);
        event.deleted_at = Some(event.updated_at);
        event.local_revision += 1;
        event.sync_state = SyncState::DeletedPending;
        self.with_conn(|conn| {
            update_event_row(conn, &event)?;
            enqueue(conn, &event.id, "delete")?;
            Ok(())
        })?;
        Ok(event)
    }

    /// Live (non-tombstoned) events overlapping `[start, end)`, optionally
    /// restricted to `calendar_ids`. The recurrence pre-filter keeps every
    /// recurring event whose series could reach the window.
    pub fn events_in_range(
        &self,
        start: DateTime<Utc>,
        end: DateTime<Utc>,
        calendar_ids: &[String],
    ) -> Result<Vec<Event>, StoreError> {
        self.with_conn(|conn| {
            let mut sql = format!(
                "SELECT {EVENT_COLS} FROM events
                 WHERE deleted_at_ms IS NULL
                   AND sync_state NOT IN ('deleted_pending','deleted_synced')
                   AND start_utc < ?1
                   AND (end_utc > ?2 OR recurrence IS NOT NULL)
                   AND (recurrence_end_utc IS NULL OR recurrence_end_utc > ?2)"
            );
            let mut args: Vec<Box<dyn rusqlite::types::ToSql>> =
                vec![Box::new(end.to_rfc3339()), Box::new(start.to_rfc3339())];
            if !calendar_ids.is_empty() {
                let placeholders: Vec<String> =
                    (0..calendar_ids.len()).map(|i| format!("?{}", i + 3)).collect();
                sql.push_str(&format!(" AND calendar_id IN ({})", placeholders.join(",")));
                for id in calendar_ids {
                    args.push(Box::new(id.clone()));
                }
            }
            sql.push_str(" ORDER BY start_utc");
            let mut stmt = conn.prepare(&sql)?;
            let rows = stmt.query_map(rusqlite::params_from_iter(args), event_from_row)?;
            let mut out = Vec::new();
            for row in rows {
                out.push(row?);
            }
            Ok(out)
        })
    }

    // ------------------------------------------------------------------
    // Calendars
    // ------------------------------------------------------------------

    pub fn calendars(&self) -> Result<Vec<Calendar>, StoreError> {
        self.with_conn(|conn| {
            let mut stmt = conn.prepare(
                "SELECT id, name, color, is_default, position, created_at_ms, updated_at_ms
                 FROM calendars WHERE deleted = 0 ORDER BY position, name",
            )?;
            let rows = stmt.query_map([], calendar_from_row)?;
            let mut out = Vec::new();
            for row in rows {
                out.push(row?);
            }
            Ok(out)
        })
    }

    pub fn create_calendar(&self, draft: CalendarDraft) -> Result<Calendar, StoreError> {
        if draft.name.trim().is_empty() {
            return Err(StoreError::Invalid("calendar name must not be empty".into()));
        }
        let now = Utc::now();
        let calendar = Calendar {
            id: Uuid::new_v4().to_string(),
            name: draft.name,
            color: draft.color.unwrap_or_else(|| "0xFF3F51B5".to_owned()),
            is_default: false,
            position: 0,
            created_at: now,
            updated_at: now,
        };
        self.with_conn(|conn| {
            conn.execute(
                "INSERT INTO calendars (id, name, color, is_default, position, created_at_ms, updated_at_ms)
                 VALUES (?1, ?2, ?3, 0, (SELECT COALESCE(MAX(position),0)+1 FROM calendars), ?4, ?4)",
                params![calendar.id, calendar.name, calendar.color, now.timestamp_millis()],
            )?;
            Ok(())
        })?;
        Ok(calendar)
    }

    pub fn update_calendar(&self, id: &str, patch: CalendarPatch) -> Result<Calendar, StoreError> {
        self.with_conn(|conn| {
            let mut calendar = conn
                .query_row(
                    "SELECT id, name, color, is_default, position, created_at_ms, updated_at_ms
                     FROM calendars WHERE id = ?1 AND deleted = 0",
                    [id],
                    calendar_from_row,
                )
                .optional()?
                .ok_or_else(|| StoreError::NotFound(format!("calendar {id}")))?;
            if let Some(v) = patch.name {
                if v.trim().is_empty() {
                    return Err(StoreError::Invalid("calendar name must not be empty".into()));
                }
                calendar.name = v;
            }
            if let Some(v) = patch.color {
                calendar.color = v;
            }
            if let Some(v) = patch.position {
                calendar.position = v;
            }
            calendar.updated_at = Utc::now();
            conn.execute(
                "UPDATE calendars SET name=?2, color=?3, position=?4, updated_at_ms=?5 WHERE id=?1",
                params![
                    calendar.id,
                    calendar.name,
                    calendar.color,
                    calendar.position,
                    calendar.updated_at.timestamp_millis()
                ],
            )?;
            Ok(calendar)
        })
    }

    /// Soft-deletes a calendar; its events move to the default calendar.
    pub fn delete_calendar(&self, id: &str) -> Result<(), StoreError> {
        if id == "default" {
            return Err(StoreError::Invalid("the default calendar cannot be deleted".into()));
        }
        self.with_conn(|conn| {
            let n = conn.execute(
                "UPDATE calendars SET deleted = 1, updated_at_ms = ?2 WHERE id = ?1 AND deleted = 0",
                params![id, now_ms()],
            )?;
            if n == 0 {
                return Err(StoreError::NotFound(format!("calendar {id}")));
            }
            conn.execute(
                "UPDATE events SET calendar_id = 'default' WHERE calendar_id = ?1",
                [id],
            )?;
            Ok(())
        })
    }

    // ------------------------------------------------------------------
    // Settings / status / queue
    // ------------------------------------------------------------------

    pub fn get_setting(&self, key: &str) -> Result<Option<String>, StoreError> {
        self.with_conn(|conn| {
            Ok(conn
                .query_row("SELECT value FROM app_settings WHERE key = ?1", [key], |r| r.get(0))
                .optional()?)
        })
    }

    pub fn set_setting(&self, key: &str, value: &str) -> Result<(), StoreError> {
        self.with_conn(|conn| {
            conn.execute(
                "INSERT INTO app_settings (key, value) VALUES (?1, ?2)
                 ON CONFLICT(key) DO UPDATE SET value = excluded.value",
                params![key, value],
            )?;
            Ok(())
        })
    }

    pub fn pending_operations(&self) -> Result<i64, StoreError> {
        self.with_conn(|conn| Ok(conn.query_row("SELECT COUNT(*) FROM sync_queue", [], |r| r.get(0))?))
    }
}

// Column list shared by every event SELECT so row mapping stays in one place.
const EVENT_COLS: &str = "id, calendar_id, nostr_event_id, owner_pubkey, title, description, location, url, \
     start_utc, end_utc, timezone, all_day, recurrence, recurrence_end_utc, reminders, status, \
     visibility, color, created_at_ms, updated_at_ms, deleted_at_ms, local_revision, \
     remote_revision, sync_state, source_device, metadata";

fn event_from_row(row: &Row<'_>) -> rusqlite::Result<Event> {
    let invalid = |i: usize, e: String| {
        rusqlite::Error::FromSqlConversionFailure(
            i,
            rusqlite::types::Type::Text,
            Box::new(std::io::Error::new(std::io::ErrorKind::InvalidData, e)),
        )
    };
    let start: String = row.get(8)?;
    let end: String = row.get(9)?;
    let recurrence: Option<String> = row.get(12)?;
    let recurrence_end: Option<String> = row.get(13)?;
    let reminders_json: String = row.get(14)?;
    let sync_state: String = row.get(23)?;
    let metadata_json: String = row.get(25)?;

    let parse = |i: usize, s: &str| {
        DateTime::parse_from_rfc3339(s)
            .map(|d| d.with_timezone(&Utc))
            .map_err(|e| invalid(i, e.to_string()))
    };

    Ok(Event {
        id: row.get(0)?,
        calendar_id: row.get(1)?,
        nostr_event_id: row.get(2)?,
        owner_pubkey: row.get(3)?,
        title: row.get(4)?,
        description: row.get(5)?,
        location: row.get(6)?,
        url: row.get(7)?,
        start: parse(8, &start)?,
        end: parse(9, &end)?,
        timezone: row.get(10)?,
        all_day: row.get::<_, i64>(11)? != 0,
        recurrence: Recurrence::from_wire(recurrence.as_deref()),
        recurrence_end: match recurrence_end {
            Some(s) => Some(parse(13, &s)?),
            None => None,
        },
        reminders: serde_json::from_str::<Vec<Reminder>>(&reminders_json).unwrap_or_default(),
        status: row.get(15)?,
        visibility: row.get(16)?,
        color: row.get(17)?,
        created_at: ms_to_dt(row.get(18)?),
        updated_at: ms_to_dt(row.get(19)?),
        deleted_at: row.get::<_, Option<i64>>(20)?.map(ms_to_dt),
        local_revision: row.get(21)?,
        remote_revision: row.get(22)?,
        sync_state: SyncState::parse(&sync_state).unwrap_or(SyncState::LocalOnly),
        source_device: row.get(24)?,
        metadata: serde_json::from_str(&metadata_json).unwrap_or_default(),
    })
}

fn calendar_from_row(row: &Row<'_>) -> rusqlite::Result<Calendar> {
    Ok(Calendar {
        id: row.get(0)?,
        name: row.get(1)?,
        color: row.get(2)?,
        is_default: row.get::<_, i64>(3)? != 0,
        position: row.get(4)?,
        created_at: ms_to_dt(row.get(5)?),
        updated_at: ms_to_dt(row.get(6)?),
    })
}

fn insert_event_row(conn: &Connection, e: &Event) -> Result<(), StoreError> {
    conn.execute(
        "INSERT INTO events (id, calendar_id, nostr_event_id, owner_pubkey, title, description,
             location, url, start_utc, end_utc, timezone, all_day, recurrence, recurrence_end_utc,
             reminders, status, visibility, color, created_at_ms, updated_at_ms, deleted_at_ms,
             local_revision, remote_revision, sync_state, source_device, metadata)
         VALUES (?1,?2,?3,?4,?5,?6,?7,?8,?9,?10,?11,?12,?13,?14,?15,?16,?17,?18,?19,?20,?21,?22,?23,?24,?25,?26)",
        rusqlite::params_from_iter(event_params(e)?),
    )?;
    Ok(())
}

fn update_event_row(conn: &Connection, e: &Event) -> Result<(), StoreError> {
    let n = conn.execute(
        "UPDATE events SET calendar_id=?2, nostr_event_id=?3, owner_pubkey=?4, title=?5,
             description=?6, location=?7, url=?8, start_utc=?9, end_utc=?10, timezone=?11,
             all_day=?12, recurrence=?13, recurrence_end_utc=?14, reminders=?15, status=?16,
             visibility=?17, color=?18, created_at_ms=?19, updated_at_ms=?20, deleted_at_ms=?21,
             local_revision=?22, remote_revision=?23, sync_state=?24, source_device=?25, metadata=?26
         WHERE id=?1",
        rusqlite::params_from_iter(event_params(e)?),
    )?;
    if n == 0 {
        return Err(StoreError::NotFound(format!("event {}", e.id)));
    }
    Ok(())
}

fn event_params(e: &Event) -> Result<Vec<Box<dyn rusqlite::types::ToSql>>, StoreError> {
    let reminders = serde_json::to_string(&e.reminders)
        .map_err(|err| StoreError::Invalid(format!("reminders serialization: {err}")))?;
    let metadata = serde_json::to_string(&e.metadata)
        .map_err(|err| StoreError::Invalid(format!("metadata serialization: {err}")))?;
    Ok(vec![
        Box::new(e.id.clone()),
        Box::new(e.calendar_id.clone()),
        Box::new(e.nostr_event_id.clone()),
        Box::new(e.owner_pubkey.clone()),
        Box::new(e.title.clone()),
        Box::new(e.description.clone()),
        Box::new(e.location.clone()),
        Box::new(e.url.clone()),
        Box::new(e.start.to_rfc3339()),
        Box::new(e.end.to_rfc3339()),
        Box::new(e.timezone.clone()),
        Box::new(e.all_day as i64),
        Box::new(e.recurrence.as_wire().map(str::to_owned)),
        Box::new(e.recurrence_end.map(|d| d.to_rfc3339())),
        Box::new(reminders),
        Box::new(e.status.clone()),
        Box::new(e.visibility.clone()),
        Box::new(e.color.clone()),
        Box::new(e.created_at.timestamp_millis()),
        Box::new(e.updated_at.timestamp_millis()),
        Box::new(e.deleted_at.map(|d| d.timestamp_millis())),
        Box::new(e.local_revision),
        Box::new(e.remote_revision.clone()),
        Box::new(e.sync_state.as_str().to_owned()),
        Box::new(e.source_device.clone()),
        Box::new(metadata),
    ])
}

/// Queues a sync operation, collapsing duplicates for the same event+op.
fn enqueue(conn: &Connection, event_id: &str, op: &str) -> Result<(), StoreError> {
    conn.execute(
        "DELETE FROM sync_queue WHERE event_id = ?1 AND op = ?2",
        params![event_id, op],
    )?;
    // A delete supersedes any pending publish for the same event.
    if op == "delete" {
        conn.execute(
            "DELETE FROM sync_queue WHERE event_id = ?1 AND op = 'publish'",
            [event_id],
        )?;
    }
    conn.execute(
        "INSERT INTO sync_queue (event_id, op, created_at_ms) VALUES (?1, ?2, ?3)",
        params![event_id, op, now_ms()],
    )?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use chrono::TimeZone;

    fn utc(y: i32, mo: u32, d: u32, h: u32) -> DateTime<Utc> {
        Utc.with_ymd_and_hms(y, mo, d, h, 0, 0).single().expect("valid test date")
    }

    fn draft(title: &str, start: DateTime<Utc>, end: DateTime<Utc>) -> EventDraft {
        serde_json::from_value(serde_json::json!({
            "title": title,
            "start": start.to_rfc3339(),
            "end": end.to_rfc3339(),
            "timezone": "Europe/Rome"
        }))
        .expect("valid draft")
    }

    #[test]
    fn create_get_update_delete_round_trip() {
        let store = Store::open_in_memory().expect("open");
        let created = store
            .create_event(draft("Standup", utc(2026, 7, 20, 9), utc(2026, 7, 20, 10)), "test")
            .expect("create");
        assert_eq!(created.sync_state, SyncState::LocalOnly);
        assert_eq!(store.pending_operations().expect("pending"), 1);

        let fetched = store.get_event(&created.id).expect("get");
        assert_eq!(fetched.title, "Standup");
        assert_eq!(fetched.timezone, "Europe/Rome");

        let patch: EventPatch =
            serde_json::from_str(r#"{"title":"Daily standup","location":"Room 1"}"#).expect("patch");
        let updated = store.update_event(&created.id, patch).expect("update");
        assert_eq!(updated.title, "Daily standup");
        assert_eq!(updated.location.as_deref(), Some("Room 1"));
        assert!(updated.updated_at > fetched.updated_at);
        assert_eq!(updated.local_revision, 2);

        let deleted = store.delete_event(&created.id).expect("delete");
        assert_eq!(deleted.sync_state, SyncState::DeletedPending);
        // Tombstones disappear from range queries but stay fetchable.
        let in_range = store
            .events_in_range(utc(2026, 7, 20, 0), utc(2026, 7, 21, 0), &[])
            .expect("range");
        assert!(in_range.is_empty());
        assert!(store.get_event(&created.id).expect("get tombstone").is_deleted());
    }

    #[test]
    fn range_query_includes_recurring_events_anchored_before_window() {
        let store = Store::open_in_memory().expect("open");
        let mut d = draft("Weekly", utc(2026, 1, 5, 9), utc(2026, 1, 5, 10));
        d.recurrence = Some(crate::model::RecurrenceDraft { kind: "weekly".into(), until: None });
        store.create_event(d, "test").expect("create");
        let events = store
            .events_in_range(utc(2026, 7, 1, 0), utc(2026, 8, 1, 0), &[])
            .expect("range");
        assert_eq!(events.len(), 1, "recurring event must be pre-filtered in");
    }

    #[test]
    fn update_bumps_updated_at_strictly_by_a_second_on_rapid_saves() {
        let store = Store::open_in_memory().expect("open");
        let created = store
            .create_event(draft("A", utc(2026, 7, 20, 9), utc(2026, 7, 20, 10)), "test")
            .expect("create");
        let u1 = store
            .update_event(&created.id, serde_json::from_str(r#"{"title":"B"}"#).expect("p"))
            .expect("u1");
        let u2 = store
            .update_event(&created.id, serde_json::from_str(r#"{"title":"C"}"#).expect("p"))
            .expect("u2");
        assert!(u2.updated_at.timestamp() > u1.updated_at.timestamp());
        assert!(u1.updated_at.timestamp() > created.updated_at.timestamp());
    }

    #[test]
    fn delete_supersedes_pending_publish_in_queue() {
        let store = Store::open_in_memory().expect("open");
        let created = store
            .create_event(draft("X", utc(2026, 7, 20, 9), utc(2026, 7, 20, 10)), "test")
            .expect("create");
        store.delete_event(&created.id).expect("delete");
        // Only the delete op remains.
        assert_eq!(store.pending_operations().expect("pending"), 1);
    }

    #[test]
    fn calendars_crud_and_event_reassignment() {
        let store = Store::open_in_memory().expect("open");
        let cal = store
            .create_calendar(serde_json::from_str(r#"{"name":"Work"}"#).expect("draft"))
            .expect("create calendar");
        let mut d = draft("Meeting", utc(2026, 7, 20, 9), utc(2026, 7, 20, 10));
        d.calendar_id = Some(cal.id.clone());
        let ev = store.create_event(d, "test").expect("create event");

        store.delete_calendar(&cal.id).expect("delete calendar");
        assert_eq!(store.get_event(&ev.id).expect("get").calendar_id, "default");
        assert!(store.delete_calendar("default").is_err());
    }

    #[test]
    fn unknown_calendar_is_rejected() {
        let store = Store::open_in_memory().expect("open");
        let mut d = draft("Nope", utc(2026, 7, 20, 9), utc(2026, 7, 20, 10));
        d.calendar_id = Some("missing".into());
        assert!(matches!(store.create_event(d, "test"), Err(StoreError::NotFound(_))));
    }
}
