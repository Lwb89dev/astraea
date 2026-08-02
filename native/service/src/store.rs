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
    Recurrence, Reminder, RemotePayload, SyncState,
};

/// One pending sync operation (a `sync_queue` row).
#[derive(Debug, Clone)]
pub struct QueueItem {
    pub id: i64,
    pub event_id: String,
    pub op: String,
    pub attempts: i64,
}

/// A configured relay with its stored health snapshot.
#[derive(Debug, Clone)]
pub struct RelayRow {
    pub url: String,
    pub read: bool,
    pub write: bool,
    pub state: String,
    pub last_ok_ms: Option<i64>,
}

/// Lifecycle of one attendee-event relationship (ADR-007). Shared between
/// the `attendees` table (my events, other people's status) and the
/// `invitations` table (other people's events, my status).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum AttendeeStatus {
    Invited,
    Accepted,
    Declined,
}

impl AttendeeStatus {
    pub fn as_str(self) -> &'static str {
        match self {
            AttendeeStatus::Invited => "invited",
            AttendeeStatus::Accepted => "accepted",
            AttendeeStatus::Declined => "declined",
        }
    }

    pub fn parse(s: &str) -> Option<Self> {
        Some(match s {
            "invited" | "pending" => AttendeeStatus::Invited,
            "accepted" => AttendeeStatus::Accepted,
            "declined" => AttendeeStatus::Declined,
            _ => return None,
        })
    }
}

/// One row of `attendees`: someone I invited to an event I own.
#[derive(Debug, Clone)]
pub struct Attendee {
    pub event_id: String,
    pub pubkey: String,
    pub status: AttendeeStatus,
    pub invited_at_ms: i64,
    pub responded_at_ms: Option<i64>,
}

/// An invitation to someone else's event, addressed to me.
#[derive(Debug, Clone)]
pub struct Invitation {
    pub id: String,
    pub event_id: String,
    pub inviter_pubkey: String,
    pub title: String,
    pub description: String,
    pub location: Option<String>,
    pub start: DateTime<Utc>,
    pub end: DateTime<Utc>,
    pub timezone: String,
    pub all_day: bool,
    pub status: AttendeeStatus,
    pub received_at_ms: i64,
}

/// Deterministic invitation id: the same `(event_id, inviter_pubkey)` pair
/// always yields the same id, so a resent invite updates its existing row
/// (see `upsert_invitation`) instead of piling up, and the sync engine can
/// look an invitation up from an outbox row's `(event_id, peer_pubkey)`
/// without a separate index.
pub fn invitation_id(event_id: &str, inviter_pubkey: &str) -> String {
    format!("{event_id}:{inviter_pubkey}")
}

/// What the sync engine has to hand `Store::upsert_invitation` after
/// decrypting and verifying an incoming invite event.
pub struct NewInvitation {
    pub id: String,
    pub event_id: String,
    pub inviter_pubkey: String,
    pub title: String,
    pub description: String,
    pub location: Option<String>,
    pub start: DateTime<Utc>,
    pub end: DateTime<Utc>,
    pub timezone: String,
    pub all_day: bool,
}

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
    Utc.timestamp_millis_opt(ms)
        .single()
        .unwrap_or_else(Utc::now)
}

impl Store {
    pub fn open(path: PathBuf) -> Result<Self, StoreError> {
        let conn = db::open(&path)?;
        Ok(Store {
            conn: Mutex::new(conn),
            db_path: path,
        })
    }

    /// In-memory database (unit + integration tests, `db doctor` dry runs).
    pub fn open_in_memory() -> Result<Self, StoreError> {
        let conn = Connection::open_in_memory()?;
        conn.pragma_update(None, "foreign_keys", "ON")?;
        db::migrate(&conn, false, std::path::Path::new(":memory:"))?;
        Ok(Store {
            conn: Mutex::new(conn),
            db_path: PathBuf::from(":memory:"),
        })
    }

    fn with_conn<T>(
        &self,
        f: impl FnOnce(&Connection) -> Result<T, StoreError>,
    ) -> Result<T, StoreError> {
        let guard = self.conn.lock().map_err(|_| StoreError::Poisoned)?;
        f(&guard)
    }

    // ------------------------------------------------------------------
    // Events
    // ------------------------------------------------------------------

    pub fn create_event(
        &self,
        draft: EventDraft,
        source_device: &str,
    ) -> Result<Event, StoreError> {
        let timezone = draft.timezone.clone().unwrap_or_else(|| "UTC".to_owned());
        validate_event_fields(
            &draft.title,
            &draft.description,
            draft.start,
            draft.end,
            &timezone,
        )
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
            calendar_id: draft
                .calendar_id
                .clone()
                .unwrap_or_else(|| "default".to_owned()),
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
                return Err(StoreError::NotFound(format!(
                    "calendar {}",
                    event.calendar_id
                )));
            }
            let duplicate: i64 = conn.query_row(
                "SELECT COUNT(*) FROM events WHERE id = ?1",
                [&event.id],
                |r| r.get(0),
            )?;
            if duplicate > 0 {
                return Err(StoreError::Invalid(format!(
                    "event id {} already exists",
                    event.id
                )));
            }
            insert_event_row(conn, &event)?;
            enqueue(conn, &event.id, "publish")?;
            Ok(())
        })?;
        Ok(event)
    }

    pub fn get_event(&self, id: &str) -> Result<Event, StoreError> {
        self.with_conn(|conn| {
            conn.query_row(
                &format!("SELECT {EVENT_COLS} FROM events WHERE id = ?1"),
                [id],
                event_from_row,
            )
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
        validate_event_fields(
            &event.title,
            &event.description,
            event.start,
            event.end,
            &event.timezone,
        )
        .map_err(StoreError::Invalid)?;

        // Replaceable-event ordering has one-second resolution on the wire:
        // guarantee a strictly newer updatedAt (see docs/nostr-sync.md).
        let min_next = event.updated_at + chrono::Duration::seconds(1);
        event.updated_at = std::cmp::max(Utc::now(), min_next);
        event.local_revision += 1;
        event.sync_state = match event.sync_state {
            SyncState::Synced | SyncState::Failed | SyncState::Conflict => {
                SyncState::PendingPublish
            }
            other => other,
        };

        self.with_conn(|conn| {
            let calendar_exists: i64 = conn.query_row(
                "SELECT COUNT(*) FROM calendars WHERE id = ?1 AND deleted = 0",
                [&event.calendar_id],
                |r| r.get(0),
            )?;
            if calendar_exists == 0 {
                return Err(StoreError::NotFound(format!(
                    "calendar {}",
                    event.calendar_id
                )));
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
                let placeholders: Vec<String> = (0..calendar_ids.len())
                    .map(|i| format!("?{}", i + 3))
                    .collect();
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
            return Err(StoreError::Invalid(
                "calendar name must not be empty".into(),
            ));
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
                    return Err(StoreError::Invalid(
                        "calendar name must not be empty".into(),
                    ));
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
            return Err(StoreError::Invalid(
                "the default calendar cannot be deleted".into(),
            ));
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
                .query_row(
                    "SELECT value FROM app_settings WHERE key = ?1",
                    [key],
                    |r| r.get(0),
                )
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
        self.with_conn(|conn| {
            Ok(conn.query_row("SELECT COUNT(*) FROM sync_queue", [], |r| r.get(0))?)
        })
    }

    // ------------------------------------------------------------------
    // Sync engine surface (relays, queue, remote merge) — phase 7.
    // The engine is the only caller; nothing here does network I/O.
    // ------------------------------------------------------------------

    pub fn relays(&self) -> Result<Vec<RelayRow>, StoreError> {
        self.with_conn(|conn| {
            let mut stmt = conn.prepare(
                "SELECT url, read, write, state, last_ok_ms FROM nostr_relays ORDER BY url",
            )?;
            let rows = stmt.query_map([], |row| {
                Ok(RelayRow {
                    url: row.get(0)?,
                    read: row.get::<_, i64>(1)? != 0,
                    write: row.get::<_, i64>(2)? != 0,
                    state: row.get(3)?,
                    last_ok_ms: row.get(4)?,
                })
            })?;
            let mut out = Vec::new();
            for row in rows {
                out.push(row?);
            }
            Ok(out)
        })
    }

    /// Replaces the configured relay set, preserving health data for URLs
    /// that stay. Validation happens at the D-Bus boundary.
    pub fn set_relays(&self, urls: &[String]) -> Result<(), StoreError> {
        self.with_conn(|conn| {
            if urls.is_empty() {
                conn.execute("DELETE FROM nostr_relays", [])?;
                return Ok(());
            }
            let placeholders: Vec<String> =
                (0..urls.len()).map(|i| format!("?{}", i + 1)).collect();
            conn.execute(
                &format!(
                    "DELETE FROM nostr_relays WHERE url NOT IN ({})",
                    placeholders.join(",")
                ),
                rusqlite::params_from_iter(urls.iter()),
            )?;
            for url in urls {
                conn.execute(
                    "INSERT INTO nostr_relays (url) VALUES (?1) ON CONFLICT(url) DO NOTHING",
                    [url],
                )?;
            }
            Ok(())
        })
    }

    pub fn update_relay_health(&self, url: &str, connected: bool) -> Result<(), StoreError> {
        self.with_conn(|conn| {
            if connected {
                conn.execute(
                    "UPDATE nostr_relays SET state = 'connected', last_ok_ms = ?2 WHERE url = ?1",
                    params![url, now_ms()],
                )?;
            } else {
                conn.execute(
                    "UPDATE nostr_relays SET state = 'disconnected' WHERE url = ?1",
                    [url],
                )?;
            }
            Ok(())
        })
    }

    /// Queue items whose backoff window has elapsed, oldest first.
    pub fn due_queue_items(&self, limit: i64) -> Result<Vec<QueueItem>, StoreError> {
        self.with_conn(|conn| {
            let mut stmt = conn.prepare(
                "SELECT id, event_id, op, attempts FROM sync_queue
                 WHERE next_attempt_ms <= ?1 ORDER BY created_at_ms LIMIT ?2",
            )?;
            let rows = stmt.query_map(params![now_ms(), limit], |row| {
                Ok(QueueItem {
                    id: row.get(0)?,
                    event_id: row.get(1)?,
                    op: row.get(2)?,
                    attempts: row.get(3)?,
                })
            })?;
            let mut out = Vec::new();
            for row in rows {
                out.push(row?);
            }
            Ok(out)
        })
    }

    pub fn queue_done(&self, item_id: i64) -> Result<(), StoreError> {
        self.with_conn(|conn| {
            conn.execute("DELETE FROM sync_queue WHERE id = ?1", [item_id])?;
            Ok(())
        })
    }

    /// Records a failed attempt: bumps the counter and schedules the retry
    /// at `next_attempt_ms`. The item is never dropped — publishing is
    /// idempotent and the queue must survive long offline periods.
    pub fn queue_retry(
        &self,
        item_id: i64,
        next_attempt_ms: i64,
        error: &str,
    ) -> Result<(), StoreError> {
        self.with_conn(|conn| {
            conn.execute(
                "UPDATE sync_queue SET attempts = attempts + 1, next_attempt_ms = ?2, last_error = ?3
                 WHERE id = ?1",
                params![item_id, next_attempt_ms, error],
            )?;
            Ok(())
        })
    }

    /// Defers an item without counting an attempt (signer unavailable is a
    /// wait-for-the-user situation, not a failure).
    pub fn queue_defer(
        &self,
        item_id: i64,
        next_attempt_ms: i64,
        reason: &str,
    ) -> Result<(), StoreError> {
        self.with_conn(|conn| {
            conn.execute(
                "UPDATE sync_queue SET next_attempt_ms = ?2, last_error = ?3 WHERE id = ?1",
                params![item_id, next_attempt_ms, reason],
            )?;
            Ok(())
        })
    }

    /// Operations that keep failing (used by the sync status `failed` count).
    pub fn failing_operations(&self, min_attempts: i64) -> Result<i64, StoreError> {
        self.with_conn(|conn| {
            Ok(conn.query_row(
                "SELECT COUNT(*) FROM sync_queue WHERE attempts >= ?1",
                [min_attempts],
                |r| r.get(0),
            )?)
        })
    }

    pub fn record_sync_failure(
        &self,
        event_id: &str,
        op: &str,
        error: &str,
    ) -> Result<(), StoreError> {
        self.with_conn(|conn| {
            conn.execute(
                "INSERT INTO sync_failures (event_id, op, error, failed_at_ms) VALUES (?1, ?2, ?3, ?4)",
                params![event_id, op, error, now_ms()],
            )?;
            // Bounded history: this is diagnostics, not an audit log.
            conn.execute(
                "DELETE FROM sync_failures WHERE id NOT IN
                     (SELECT id FROM sync_failures ORDER BY id DESC LIMIT 500)",
                [],
            )?;
            Ok(())
        })
    }

    pub fn set_event_sync_state(&self, event_id: &str, state: SyncState) -> Result<(), StoreError> {
        self.with_conn(|conn| {
            let n = conn.execute(
                "UPDATE events SET sync_state = ?2 WHERE id = ?1",
                params![event_id, state.as_str()],
            )?;
            if n == 0 {
                return Err(StoreError::NotFound(format!("event {event_id}")));
            }
            Ok(())
        })
    }

    /// Marks a queue op as accepted by every relay: records the concrete
    /// Nostr event id and flips the state to synced / deleted_synced.
    pub fn mark_event_published(
        &self,
        event_id: &str,
        nostr_event_id: &str,
        owner_pubkey: &str,
        deleted: bool,
    ) -> Result<(), StoreError> {
        let state = if deleted {
            SyncState::DeletedSynced
        } else {
            SyncState::Synced
        };
        self.with_conn(|conn| {
            let n = conn.execute(
                "UPDATE events SET nostr_event_id = ?2, owner_pubkey = ?3, remote_revision = ?2,
                     sync_state = ?4
                 WHERE id = ?1",
                params![event_id, nostr_event_id, owner_pubkey, state.as_str()],
            )?;
            if n == 0 {
                return Err(StoreError::NotFound(format!("event {event_id}")));
            }
            Ok(())
        })
    }

    /// Last-write-wins merge of one pulled payload (docs/nostr-sync.md):
    /// strictly-newer `updatedAt` wins, ties keep local. Returns the event id
    /// when the local database changed.
    pub fn merge_remote_event(
        &self,
        payload: &RemotePayload,
        remote_concrete_id: &str,
        owner_pubkey: &str,
    ) -> Result<Option<String>, StoreError> {
        self.with_conn(|conn| {
            let local = conn
                .query_row(
                    &format!("SELECT {EVENT_COLS} FROM events WHERE id = ?1"),
                    [&payload.id],
                    event_from_row,
                )
                .optional()?;

            match local {
                // Unknown event: adopt it (tombstones included — the contract
                // says readers keep them and hide them).
                None => adopt_remote_event(conn, payload, remote_concrete_id, owner_pubkey),
                Some(event) => {
                    apply_remote_update(conn, event, payload, remote_concrete_id, owner_pubkey)
                }
            }
        })
    }

    // ------------------------------------------------------------------
    // Accounts (identity metadata only — pubkeys are public; secrets live
    // exclusively in the Secret Service, never in this database)
    // ------------------------------------------------------------------

    /// Inserts (or refreshes) an account and makes it the active one — the
    /// browser-login completion path, so `pubkey` can legitimately be a
    /// different account than whatever was active before (sign out, sign
    /// into a different Nostr identity).
    pub fn activate_account(
        &self,
        pubkey: &str,
        npub: &str,
        signer: &str,
    ) -> Result<String, StoreError> {
        self.with_conn(|conn| {
            let now = now_ms();
            let previous_pubkey: Option<String> = conn
                .query_row("SELECT pubkey FROM accounts WHERE is_active = 1", [], |r| {
                    r.get(0)
                })
                .optional()?;
            conn.execute("UPDATE accounts SET is_active = 0", [])?;
            conn.execute(
                "INSERT INTO accounts (id, pubkey, npub, label, signer, is_active, created_at_ms, updated_at_ms)
                 VALUES (?1, ?2, ?3, '', ?4, 1, ?5, ?5)
                 ON CONFLICT(pubkey) DO UPDATE SET
                     is_active = 1, signer = excluded.signer, npub = excluded.npub,
                     updated_at_ms = excluded.updated_at_ms",
                params![Uuid::new_v4().to_string(), pubkey, npub, signer, now],
            )?;
            if previous_pubkey.as_deref() != Some(pubkey) {
                reset_pull_cursors(conn)?;
            }
            let id: String =
                conn.query_row("SELECT id FROM accounts WHERE pubkey = ?1", [pubkey], |r| r.get(0))?;
            Ok(id)
        })
    }

    pub fn active_account(&self) -> Result<Option<Account>, StoreError> {
        self.with_conn(|conn| {
            Ok(conn
                .query_row(
                    "SELECT id, pubkey, npub, label, signer FROM accounts WHERE is_active = 1",
                    [],
                    account_from_row,
                )
                .optional()?)
        })
    }

    pub fn accounts(&self) -> Result<Vec<Account>, StoreError> {
        self.with_conn(|conn| {
            let mut stmt = conn.prepare(
                "SELECT id, pubkey, npub, label, signer FROM accounts ORDER BY created_at_ms",
            )?;
            let rows = stmt.query_map([], account_from_row)?;
            let mut out = Vec::new();
            for row in rows {
                out.push(row?);
            }
            Ok(out)
        })
    }

    pub fn deactivate_accounts(&self) -> Result<(), StoreError> {
        self.with_conn(|conn| {
            conn.execute("UPDATE accounts SET is_active = 0", [])?;
            Ok(())
        })
    }

    pub fn set_active_account_signer(&self, signer: &str) -> Result<(), StoreError> {
        self.with_conn(|conn| {
            let n = conn.execute(
                "UPDATE accounts SET signer = ?1, updated_at_ms = ?2 WHERE is_active = 1",
                params![signer, now_ms()],
            )?;
            if n == 0 {
                return Err(StoreError::NotFound("no active account".into()));
            }
            Ok(())
        })
    }

    pub fn switch_account(&self, account_id: &str) -> Result<Account, StoreError> {
        self.with_conn(|conn| {
            let account = conn
                .query_row(
                    "SELECT id, pubkey, npub, label, signer FROM accounts WHERE id = ?1",
                    [account_id],
                    account_from_row,
                )
                .optional()?
                .ok_or_else(|| StoreError::NotFound(format!("account {account_id}")))?;
            let was_already_active: bool = conn.query_row(
                "SELECT is_active FROM accounts WHERE id = ?1",
                [account_id],
                |r| r.get(0),
            )?;
            conn.execute("UPDATE accounts SET is_active = 0", [])?;
            conn.execute(
                "UPDATE accounts SET is_active = 1 WHERE id = ?1",
                [account_id],
            )?;
            // See reset_pull_cursors's doc. `sync_queue` is deliberately not
            // touched here: push_one() now checks each item's owner_pubkey
            // against the active identity itself, which is the correct
            // place to guard a queue that legitimately holds a
            // never-yet-published (ownerless) event for whichever account
            // created it.
            if !was_already_active {
                reset_pull_cursors(conn)?;
            }
            Ok(account)
        })
    }

    // ------------------------------------------------------------------
    // Attendee invites (ADR-007, docs/nostr-sync.md "Attendee invites").
    // ------------------------------------------------------------------

    /// Adds an attendee row for an event I own, in `invited` state, and
    /// queues the invite event for publishing. Both happen in one
    /// transaction: an attendee row without a queued invite would silently
    /// never reach them.
    pub fn add_attendee(&self, event_id: &str, pubkey: &str) -> Result<(), StoreError> {
        self.with_conn(|conn| {
            conn.execute(
                "INSERT INTO attendees (event_id, pubkey, status, invited_at_ms)
                 VALUES (?1, ?2, 'invited', ?3)
                 ON CONFLICT(event_id, pubkey) DO NOTHING",
                params![event_id, pubkey, now_ms()],
            )?;
            enqueue_invite(conn, "invite", event_id, pubkey)?;
            Ok(())
        })
    }

    /// Due outbox items (invites and responses still to publish).
    pub fn due_invite_outbox_items(&self, limit: i64) -> Result<Vec<InviteOutboxItem>, StoreError> {
        self.with_conn(|conn| {
            let mut stmt = conn.prepare(
                "SELECT id, kind, event_id, peer_pubkey, attempts FROM invite_outbox
                 WHERE next_attempt_ms <= ?1 ORDER BY created_at_ms LIMIT ?2",
            )?;
            let rows = stmt.query_map(params![now_ms(), limit], |row| {
                Ok(InviteOutboxItem {
                    id: row.get(0)?,
                    kind: row.get(1)?,
                    event_id: row.get(2)?,
                    peer_pubkey: row.get(3)?,
                    attempts: row.get(4)?,
                })
            })?;
            let mut out = Vec::new();
            for row in rows {
                out.push(row?);
            }
            Ok(out)
        })
    }

    pub fn invite_outbox_done(&self, item_id: i64) -> Result<(), StoreError> {
        self.with_conn(|conn| {
            conn.execute("DELETE FROM invite_outbox WHERE id = ?1", [item_id])?;
            Ok(())
        })
    }

    pub fn invite_outbox_retry(
        &self,
        item_id: i64,
        next_attempt_ms: i64,
        error: &str,
    ) -> Result<(), StoreError> {
        self.with_conn(|conn| {
            conn.execute(
                "UPDATE invite_outbox SET attempts = attempts + 1, next_attempt_ms = ?2,
                     last_error = ?3 WHERE id = ?1",
                params![item_id, next_attempt_ms, error],
            )?;
            Ok(())
        })
    }

    pub fn attendees_for_event(&self, event_id: &str) -> Result<Vec<Attendee>, StoreError> {
        self.with_conn(|conn| {
            let mut stmt = conn.prepare(
                "SELECT event_id, pubkey, status, invited_at_ms, responded_at_ms
                 FROM attendees WHERE event_id = ?1 ORDER BY invited_at_ms",
            )?;
            let rows = stmt.query_map([event_id], attendee_from_row)?;
            let mut out = Vec::new();
            for row in rows {
                out.push(row?);
            }
            Ok(out)
        })
    }

    /// Updates an attendee's status when their response event arrives.
    /// Returns the event id so the caller can notify/refresh, or `None` if
    /// this pubkey was never actually invited to that event (a spoofed or
    /// stale response — ignored, not an error).
    pub fn record_attendee_response(
        &self,
        event_id: &str,
        pubkey: &str,
        status: AttendeeStatus,
    ) -> Result<Option<String>, StoreError> {
        self.with_conn(|conn| {
            let n = conn.execute(
                "UPDATE attendees SET status = ?3, responded_at_ms = ?4
                 WHERE event_id = ?1 AND pubkey = ?2",
                params![event_id, pubkey, status.as_str(), now_ms()],
            )?;
            Ok((n > 0).then(|| event_id.to_owned()))
        })
    }

    /// Records an incoming invitation addressed to me. Deterministic on
    /// `(event_id, inviter_pubkey)` via `id` so a re-sent/duplicate invite
    /// updates the same row instead of piling up.
    pub fn upsert_invitation(&self, invitation: &NewInvitation) -> Result<(), StoreError> {
        self.with_conn(|conn| {
            conn.execute(
                "INSERT INTO invitations
                     (id, event_id, inviter_pubkey, title, description, location,
                      start_utc, end_utc, timezone, all_day, status, received_at_ms)
                 VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, 'pending', ?11)
                 ON CONFLICT(id) DO UPDATE SET
                     title = excluded.title, description = excluded.description,
                     location = excluded.location, start_utc = excluded.start_utc,
                     end_utc = excluded.end_utc, timezone = excluded.timezone,
                     all_day = excluded.all_day
                 WHERE invitations.status = 'pending'",
                params![
                    invitation.id,
                    invitation.event_id,
                    invitation.inviter_pubkey,
                    invitation.title,
                    invitation.description,
                    invitation.location,
                    invitation.start.to_rfc3339(),
                    invitation.end.to_rfc3339(),
                    invitation.timezone,
                    invitation.all_day as i64,
                    now_ms(),
                ],
            )?;
            Ok(())
        })
    }

    pub fn pending_invitations(&self) -> Result<Vec<Invitation>, StoreError> {
        self.with_conn(|conn| {
            let mut stmt = conn.prepare(
                "SELECT id, event_id, inviter_pubkey, title, description, location,
                        start_utc, end_utc, timezone, all_day, status, received_at_ms
                 FROM invitations WHERE status = 'pending' ORDER BY received_at_ms",
            )?;
            let rows = stmt.query_map([], invitation_from_row)?;
            let mut out = Vec::new();
            for row in rows {
                out.push(row?);
            }
            Ok(out)
        })
    }

    pub fn get_invitation(&self, id: &str) -> Result<Invitation, StoreError> {
        self.with_conn(|conn| {
            conn.query_row(
                "SELECT id, event_id, inviter_pubkey, title, description, location,
                        start_utc, end_utc, timezone, all_day, status, received_at_ms
                 FROM invitations WHERE id = ?1",
                [id],
                invitation_from_row,
            )
            .optional()?
            .ok_or_else(|| StoreError::NotFound(format!("invitation {id}")))
        })
    }

    /// Accepts or declines a pending invitation, transactionally:
    /// accepting also creates an independent local copy of the event (a
    /// one-time snapshot owned by this account — the organizer's later
    /// edits are not propagated automatically, since that would need a
    /// live-shared-event mechanism ADR-007 deliberately did not take on;
    /// tracked as a follow-up in docs/nostr-sync.md), and either outcome
    /// queues the response event back to the organizer.
    pub fn respond_to_invitation(
        &self,
        id: &str,
        accept: bool,
        source_device: &str,
    ) -> Result<Option<Event>, StoreError> {
        self.with_conn(|conn| {
            let invitation = conn
                .query_row(
                    "SELECT id, event_id, inviter_pubkey, title, description, location,
                            start_utc, end_utc, timezone, all_day, status, received_at_ms
                     FROM invitations WHERE id = ?1",
                    [id],
                    invitation_from_row,
                )
                .optional()?
                .ok_or_else(|| StoreError::NotFound(format!("invitation {id}")))?;
            if invitation.status != AttendeeStatus::Invited {
                return Err(StoreError::Invalid(format!(
                    "invitation {id} already answered"
                )));
            }

            let created = if accept {
                let now = Utc::now();
                let event = Event {
                    id: Uuid::new_v4().to_string(),
                    calendar_id: "default".to_owned(),
                    nostr_event_id: None,
                    owner_pubkey: None,
                    title: invitation.title.clone(),
                    description: invitation.description.clone(),
                    location: invitation.location.clone(),
                    url: None,
                    start: invitation.start,
                    end: invitation.end,
                    timezone: invitation.timezone.clone(),
                    all_day: invitation.all_day,
                    recurrence: Recurrence::None,
                    recurrence_end: None,
                    reminders: Vec::new(),
                    status: "confirmed".to_owned(),
                    visibility: "private".to_owned(),
                    color: "0xFF2196F3".to_owned(),
                    created_at: now,
                    updated_at: now,
                    deleted_at: None,
                    local_revision: 1,
                    remote_revision: None,
                    sync_state: SyncState::LocalOnly,
                    source_device: Some(source_device.to_owned()),
                    metadata: serde_json::Map::new(),
                };
                insert_event_row(conn, &event)?;
                Some(event)
            } else {
                None
            };

            let status = if accept {
                AttendeeStatus::Accepted
            } else {
                AttendeeStatus::Declined
            };
            conn.execute(
                "UPDATE invitations SET status = ?2, responded_at_ms = ?3 WHERE id = ?1",
                params![id, status.as_str(), now_ms()],
            )?;
            enqueue_invite(
                conn,
                "response",
                &invitation.event_id,
                &invitation.inviter_pubkey,
            )?;
            Ok(created)
        })
    }
}

/// One pending outbox item: an invite or response event still to publish.
#[derive(Debug, Clone)]
pub struct InviteOutboxItem {
    pub id: i64,
    pub kind: String,
    pub event_id: String,
    pub peer_pubkey: String,
    pub attempts: i64,
}

/// Queues an invite/response event, collapsing duplicates for the same
/// (kind, event, peer) — mirrors `enqueue` for the calendar sync_queue.
fn enqueue_invite(
    conn: &Connection,
    kind: &str,
    event_id: &str,
    peer_pubkey: &str,
) -> Result<(), StoreError> {
    conn.execute(
        "DELETE FROM invite_outbox WHERE kind = ?1 AND event_id = ?2 AND peer_pubkey = ?3",
        params![kind, event_id, peer_pubkey],
    )?;
    conn.execute(
        "INSERT INTO invite_outbox (kind, event_id, peer_pubkey, created_at_ms)
         VALUES (?1, ?2, ?3, ?4)",
        params![kind, event_id, peer_pubkey, now_ms()],
    )?;
    Ok(())
}

#[derive(Debug, Clone)]
pub struct Account {
    pub id: String,
    pub pubkey: String,
    pub npub: String,
    pub label: String,
    pub signer: String,
}

fn account_from_row(row: &Row<'_>) -> rusqlite::Result<Account> {
    Ok(Account {
        id: row.get(0)?,
        pubkey: row.get(1)?,
        npub: row.get(2)?,
        label: row.get(3)?,
        signer: row.get(4)?,
    })
}

fn attendee_from_row(row: &Row<'_>) -> rusqlite::Result<Attendee> {
    let status: String = row.get(2)?;
    Ok(Attendee {
        event_id: row.get(0)?,
        pubkey: row.get(1)?,
        status: AttendeeStatus::parse(&status).unwrap_or(AttendeeStatus::Invited),
        invited_at_ms: row.get(3)?,
        responded_at_ms: row.get(4)?,
    })
}

fn invitation_from_row(row: &Row<'_>) -> rusqlite::Result<Invitation> {
    let invalid = |i: usize, e: String| {
        rusqlite::Error::FromSqlConversionFailure(
            i,
            rusqlite::types::Type::Text,
            Box::new(std::io::Error::new(std::io::ErrorKind::InvalidData, e)),
        )
    };
    let start: String = row.get(6)?;
    let end: String = row.get(7)?;
    let status: String = row.get(10)?;
    Ok(Invitation {
        id: row.get(0)?,
        event_id: row.get(1)?,
        inviter_pubkey: row.get(2)?,
        title: row.get(3)?,
        description: row.get(4)?,
        location: row.get(5)?,
        start: DateTime::parse_from_rfc3339(&start)
            .map(|d| d.with_timezone(&Utc))
            .map_err(|e| invalid(6, e.to_string()))?,
        end: DateTime::parse_from_rfc3339(&end)
            .map(|d| d.with_timezone(&Utc))
            .map_err(|e| invalid(7, e.to_string()))?,
        timezone: row.get(8)?,
        all_day: row.get::<_, i64>(9)? != 0,
        status: AttendeeStatus::parse(&status).unwrap_or(AttendeeStatus::Invited),
        received_at_ms: row.get(11)?,
    })
}

// Column list shared by every event SELECT so row mapping stays in one place.
const EVENT_COLS: &str =
    "id, calendar_id, nostr_event_id, owner_pubkey, title, description, location, url, \
     start_utc, end_utc, timezone, all_day, recurrence, recurrence_end_utc, reminders, status, \
     visibility, color, created_at_ms, updated_at_ms, deleted_at_ms, local_revision, \
     remote_revision, sync_state, source_device, metadata";

/// True when `id` names a calendar that still exists. A pulled payload can
/// reference a calendar this device has never seen (or has deleted), and
/// adopting that id would leave the event unreachable in the UI.
fn calendar_exists(conn: &Connection, id: &str) -> Result<bool, StoreError> {
    let n: i64 = conn.query_row(
        "SELECT COUNT(*) FROM calendars WHERE id = ?1 AND deleted = 0",
        [id],
        |r| r.get(0),
    )?;
    Ok(n > 0)
}

/// Inserts a pulled event this device has never seen before.
///
/// Split out of [`Store::merge_remote_event`] rather than living as a match
/// arm: it is a straight-line "build the row and write it", and inlining it
/// buried that behind three levels of nesting.
fn adopt_remote_event(
    conn: &Connection,
    payload: &RemotePayload,
    remote_concrete_id: &str,
    owner_pubkey: &str,
) -> Result<Option<String>, StoreError> {
    let calendar_id = match &payload.calendar_id {
        Some(id) if calendar_exists(conn, id)? => id.clone(),
        _ => "default".to_owned(),
    };
    let event = Event {
        id: payload.id.clone(),
        calendar_id,
        nostr_event_id: Some(remote_concrete_id.to_owned()),
        owner_pubkey: Some(owner_pubkey.to_owned()),
        title: payload.title.clone(),
        description: payload.description.clone(),
        location: payload.location.clone(),
        url: payload.url.clone(),
        start: payload.start,
        end: payload.end,
        timezone: payload.timezone.clone(),
        all_day: payload.all_day,
        recurrence: payload.recurrence,
        recurrence_end: payload.recurrence_end,
        reminders: payload.reminders.clone(),
        status: "confirmed".to_owned(),
        visibility: "private".to_owned(),
        color: payload.color.clone(),
        created_at: payload.created_at,
        updated_at: payload.updated_at,
        deleted_at: payload.deleted.then_some(payload.updated_at),
        local_revision: 1,
        remote_revision: Some(remote_concrete_id.to_owned()),
        sync_state: remote_sync_state(payload.deleted),
        source_device: None,
        metadata: serde_json::Map::new(),
    };
    insert_event_row(conn, &event)?;
    Ok(Some(event.id))
}

/// Applies a pulled payload over an event this device already has, under the
/// last-write-wins rule: strictly-newer `updatedAt` wins, ties keep local.
fn apply_remote_update(
    conn: &Connection,
    mut event: Event,
    payload: &RemotePayload,
    remote_concrete_id: &str,
    owner_pubkey: &str,
) -> Result<Option<String>, StoreError> {
    if payload.updated_at <= event.updated_at {
        // Local wins (or tie): nothing changes; a pending local publish will
        // replace the remote version.
        return Ok(None);
    }
    // Remote wins: local pending ops for this event are stale.
    conn.execute("DELETE FROM sync_queue WHERE event_id = ?1", [&event.id])?;

    // A payload without calendarId keeps the local assignment (ADR-005:
    // membership is local-first). A database error here is propagated, not
    // swallowed into "calendar missing": that would silently re-home the
    // event under `default`.
    if let Some(id) = &payload.calendar_id {
        if calendar_exists(conn, id)? {
            event.calendar_id = id.clone();
        }
    }

    event.title = payload.title.clone();
    event.description = payload.description.clone();
    event.location = payload.location.clone();
    event.url = payload.url.clone().or(event.url);
    event.start = payload.start;
    event.end = payload.end;
    event.timezone = payload.timezone.clone();
    event.all_day = payload.all_day;
    event.recurrence = payload.recurrence;
    event.recurrence_end = payload.recurrence_end;
    event.reminders = payload.reminders.clone();
    event.color = payload.color.clone();
    event.updated_at = payload.updated_at;
    event.deleted_at = payload.deleted.then_some(payload.updated_at);
    event.local_revision += 1;
    event.remote_revision = Some(remote_concrete_id.to_owned());
    event.nostr_event_id = Some(remote_concrete_id.to_owned());
    event.owner_pubkey = Some(owner_pubkey.to_owned());
    event.sync_state = remote_sync_state(payload.deleted);
    update_event_row(conn, &event)?;
    Ok(Some(event.id))
}

fn remote_sync_state(deleted: bool) -> SyncState {
    if deleted {
        SyncState::DeletedSynced
    } else {
        SyncState::Synced
    }
}

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

/// Clears the pull cursors (`sync.cursor_s`, `sync.invite_cursor_s` — see
/// `sync::engine::CURSOR_KEY`/`INVITE_CURSOR_KEY`). Both are a single global
/// `app_settings` row, not scoped per account. Left alone across a login or
/// switch to a *different* account, the next pull would resume from
/// wherever the *previous* account's sync had gotten to, silently skipping
/// anything older than that on the new account's own relays. Clearing both
/// makes the new account's first pull a full resync — the only actually-safe
/// default. Called from `activate_account` and `switch_account`, only when
/// the active pubkey is genuinely changing.
fn reset_pull_cursors(conn: &Connection) -> Result<(), StoreError> {
    conn.execute(
        "DELETE FROM app_settings WHERE key IN ('sync.cursor_s', 'sync.invite_cursor_s')",
        [],
    )?;
    Ok(())
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
        Utc.with_ymd_and_hms(y, mo, d, h, 0, 0)
            .single()
            .expect("valid test date")
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
            .create_event(
                draft("Standup", utc(2026, 7, 20, 9), utc(2026, 7, 20, 10)),
                "test",
            )
            .expect("create");
        assert_eq!(created.sync_state, SyncState::LocalOnly);
        assert_eq!(store.pending_operations().expect("pending"), 1);

        let fetched = store.get_event(&created.id).expect("get");
        assert_eq!(fetched.title, "Standup");
        assert_eq!(fetched.timezone, "Europe/Rome");

        let patch: EventPatch =
            serde_json::from_str(r#"{"title":"Daily standup","location":"Room 1"}"#)
                .expect("patch");
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
        assert!(store
            .get_event(&created.id)
            .expect("get tombstone")
            .is_deleted());
    }

    #[test]
    fn range_query_includes_recurring_events_anchored_before_window() {
        let store = Store::open_in_memory().expect("open");
        let mut d = draft("Weekly", utc(2026, 1, 5, 9), utc(2026, 1, 5, 10));
        d.recurrence = Some(crate::model::RecurrenceDraft {
            kind: "weekly".into(),
            until: None,
        });
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
            .create_event(
                draft("A", utc(2026, 7, 20, 9), utc(2026, 7, 20, 10)),
                "test",
            )
            .expect("create");
        let u1 = store
            .update_event(
                &created.id,
                serde_json::from_str(r#"{"title":"B"}"#).expect("p"),
            )
            .expect("u1");
        let u2 = store
            .update_event(
                &created.id,
                serde_json::from_str(r#"{"title":"C"}"#).expect("p"),
            )
            .expect("u2");
        assert!(u2.updated_at.timestamp() > u1.updated_at.timestamp());
        assert!(u1.updated_at.timestamp() > created.updated_at.timestamp());
    }

    #[test]
    fn delete_supersedes_pending_publish_in_queue() {
        let store = Store::open_in_memory().expect("open");
        let created = store
            .create_event(
                draft("X", utc(2026, 7, 20, 9), utc(2026, 7, 20, 10)),
                "test",
            )
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
        assert!(matches!(
            store.create_event(d, "test"),
            Err(StoreError::NotFound(_))
        ));
    }

    #[test]
    fn attendee_invite_and_response_round_trip() {
        let store = Store::open_in_memory().expect("open");
        let event = store
            .create_event(
                draft("Lunch", utc(2026, 7, 20, 12), utc(2026, 7, 20, 13)),
                "test",
            )
            .expect("create");
        let bob = "b".repeat(64);

        store.add_attendee(&event.id, &bob).expect("invite");
        let attendees = store.attendees_for_event(&event.id).expect("list");
        assert_eq!(attendees.len(), 1);
        assert_eq!(attendees[0].status, AttendeeStatus::Invited);
        assert!(attendees[0].responded_at_ms.is_none());

        // Re-inviting the same pubkey is a no-op, not a duplicate row.
        store.add_attendee(&event.id, &bob).expect("re-invite");
        assert_eq!(store.attendees_for_event(&event.id).expect("list").len(), 1);

        let updated = store
            .record_attendee_response(&event.id, &bob, AttendeeStatus::Accepted)
            .expect("record");
        assert_eq!(updated, Some(event.id.clone()));
        let attendees = store.attendees_for_event(&event.id).expect("list");
        assert_eq!(attendees[0].status, AttendeeStatus::Accepted);
        assert!(attendees[0].responded_at_ms.is_some());

        // A response from someone never invited is silently ignored.
        let stranger = "c".repeat(64);
        let ignored = store
            .record_attendee_response(&event.id, &stranger, AttendeeStatus::Accepted)
            .expect("record");
        assert_eq!(ignored, None);
    }

    #[test]
    fn incoming_invitation_lifecycle() {
        let store = Store::open_in_memory().expect("open");
        let invitation = NewInvitation {
            id: "inv-1".into(),
            event_id: "evt-1".into(),
            inviter_pubkey: "a".repeat(64),
            title: "Team lunch".into(),
            description: String::new(),
            location: None,
            start: utc(2026, 7, 20, 12),
            end: utc(2026, 7, 20, 13),
            timezone: "Europe/Rome".into(),
            all_day: false,
        };
        store.upsert_invitation(&invitation).expect("upsert");

        let pending = store.pending_invitations().expect("pending");
        assert_eq!(pending.len(), 1);
        assert_eq!(pending[0].title, "Team lunch");
        assert_eq!(pending[0].status, AttendeeStatus::Invited);

        let fetched = store.get_invitation("inv-1").expect("get");
        assert_eq!(fetched.event_id, "evt-1");

        let created = store
            .respond_to_invitation("inv-1", true, "test")
            .expect("accept");
        let created = created.expect("accepting creates a local event");
        assert_eq!(created.title, "Team lunch");
        assert_eq!(
            store.get_event(&created.id).expect("get event").title,
            "Team lunch"
        );
        assert!(store.pending_invitations().expect("pending").is_empty());
        assert_eq!(
            store.get_invitation("inv-1").expect("get").status,
            AttendeeStatus::Accepted
        );
        // Queued a response to the organizer.
        assert_eq!(store.due_invite_outbox_items(10).expect("outbox").len(), 1);

        // Responding twice is rejected: only a pending invitation can move.
        assert!(store.respond_to_invitation("inv-1", false, "test").is_err());
    }

    #[test]
    fn declining_an_invitation_creates_no_local_event() {
        let store = Store::open_in_memory().expect("open");
        store
            .upsert_invitation(&NewInvitation {
                id: "inv-2".into(),
                event_id: "evt-2".into(),
                inviter_pubkey: "a".repeat(64),
                title: "Skip this".into(),
                description: String::new(),
                location: None,
                start: utc(2026, 7, 20, 12),
                end: utc(2026, 7, 20, 13),
                timezone: "UTC".into(),
                all_day: false,
            })
            .expect("upsert");

        let created = store
            .respond_to_invitation("inv-2", false, "test")
            .expect("decline");
        assert!(created.is_none());
        assert_eq!(
            store.get_invitation("inv-2").expect("get").status,
            AttendeeStatus::Declined
        );
        assert_eq!(store.due_invite_outbox_items(10).expect("outbox").len(), 1);
    }

    #[test]
    fn inviting_an_attendee_queues_the_invite_event() {
        let store = Store::open_in_memory().expect("open");
        let event = store
            .create_event(
                draft("Lunch", utc(2026, 7, 20, 12), utc(2026, 7, 20, 13)),
                "test",
            )
            .expect("create");
        let bob = "b".repeat(64);
        store.add_attendee(&event.id, &bob).expect("invite");

        let due = store.due_invite_outbox_items(10).expect("outbox");
        assert_eq!(due.len(), 1);
        assert_eq!(due[0].kind, "invite");
        assert_eq!(due[0].event_id, event.id);
        assert_eq!(due[0].peer_pubkey, bob);
    }

    #[test]
    fn resending_a_pending_invitation_updates_it_in_place() {
        let store = Store::open_in_memory().expect("open");
        let mut invitation = NewInvitation {
            id: "inv-1".into(),
            event_id: "evt-1".into(),
            inviter_pubkey: "a".repeat(64),
            title: "Lunch".into(),
            description: String::new(),
            location: None,
            start: utc(2026, 7, 20, 12),
            end: utc(2026, 7, 20, 13),
            timezone: "UTC".into(),
            all_day: false,
        };
        store.upsert_invitation(&invitation).expect("first");
        invitation.title = "Lunch (moved)".into();
        store.upsert_invitation(&invitation).expect("resend");

        let pending = store.pending_invitations().expect("pending");
        assert_eq!(pending.len(), 1, "must update, not duplicate");
        assert_eq!(pending[0].title, "Lunch (moved)");
    }

    /// Regression for the cross-account leak this session's audit found:
    /// signing into a different Nostr account must not resume the previous
    /// account's pull cursor — see reset_pull_cursors's doc.
    #[test]
    fn logging_into_a_different_account_resets_the_pull_cursors() {
        let store = Store::open_in_memory().expect("open");
        let a = "a".repeat(64);
        let b = "b".repeat(64);
        store
            .activate_account(&a, "npub_a", "local_delegated")
            .expect("activate a");
        store
            .set_setting("sync.cursor_s", "1700000000")
            .expect("cursor");
        store
            .set_setting("sync.invite_cursor_s", "1700000000")
            .expect("invite cursor");

        store
            .activate_account(&b, "npub_b", "local_delegated")
            .expect("activate b");

        assert_eq!(store.get_setting("sync.cursor_s").expect("get"), None);
        assert_eq!(
            store.get_setting("sync.invite_cursor_s").expect("get"),
            None
        );
    }

    /// Re-authenticating as the *same* account (e.g. a token refresh) must
    /// not throw away real sync progress.
    #[test]
    fn relogging_into_the_same_account_keeps_the_pull_cursor() {
        let store = Store::open_in_memory().expect("open");
        let a = "a".repeat(64);
        store
            .activate_account(&a, "npub_a", "local_delegated")
            .expect("activate");
        store
            .set_setting("sync.cursor_s", "1700000000")
            .expect("cursor");

        store
            .activate_account(&a, "npub_a", "local_delegated")
            .expect("re-activate");

        assert_eq!(
            store.get_setting("sync.cursor_s").expect("get"),
            Some("1700000000".to_owned()),
        );
    }

    /// Same regression as above, via the explicit multi-account switch path
    /// rather than a fresh browser login.
    #[test]
    fn switching_accounts_resets_the_shared_pull_cursors() {
        let store = Store::open_in_memory().expect("open");
        let a = "a".repeat(64);
        let b = "b".repeat(64);
        let a_id = store
            .activate_account(&a, "npub_a", "local_delegated")
            .expect("activate a");
        // Now that B is active, this cursor value represents B's own sync
        // progress — A must not inherit it when we switch back.
        store
            .activate_account(&b, "npub_b", "local_delegated")
            .expect("activate b");
        store
            .set_setting("sync.cursor_s", "1700000000")
            .expect("cursor");
        store
            .set_setting("sync.invite_cursor_s", "1700000000")
            .expect("invite cursor");

        store.switch_account(&a_id).expect("switch back to a");

        assert_eq!(store.get_setting("sync.cursor_s").expect("get"), None);
        assert_eq!(
            store.get_setting("sync.invite_cursor_s").expect("get"),
            None
        );
    }

    /// Re-selecting the already-active account is a no-op for the cursors —
    /// otherwise every redundant SwitchAccount call would force a full
    /// resync for no reason.
    #[test]
    fn switching_to_the_already_active_account_keeps_the_cursor() {
        let store = Store::open_in_memory().expect("open");
        let a = "a".repeat(64);
        let a_id = store
            .activate_account(&a, "npub_a", "local_delegated")
            .expect("activate");
        store
            .set_setting("sync.cursor_s", "1700000000")
            .expect("cursor");

        store.switch_account(&a_id).expect("switch to self");

        assert_eq!(
            store.get_setting("sync.cursor_s").expect("get"),
            Some("1700000000".to_owned()),
        );
    }
}
