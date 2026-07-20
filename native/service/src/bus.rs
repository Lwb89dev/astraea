//! D-Bus interfaces (docs/dbus-api.md). Thin: parse/validate JSON, call the
//! blocking store on the blocking pool, emit signals. No network I/O here.

use std::sync::atomic::{AtomicI64, Ordering};
use std::sync::Arc;

use chrono::{DateTime, Duration, NaiveDate, TimeZone, Utc};
use tokio::task::spawn_blocking;
use zbus::interface;
use zbus::object_server::SignalEmitter;

use crate::model::{self, CalendarDraft, CalendarPatch, EventDraft, EventPatch, SCHEMA_VERSION};
use crate::recurrence;
use crate::store::{Store, StoreError};

// Note: NOT plain "com.lwb89dev.Astraea" — that is the GApplication id of the
// desktop app, which registers itself on the session bus for single-instance
// behaviour. The service owns a subname, GNOME-style (org.gnome.Shell.* etc.).
pub const BUS_NAME: &str = "com.lwb89dev.Astraea.Service";
pub const OBJECT_PATH: &str = "/com/lwb89dev/Astraea";

/// State shared by both interfaces and the daemon loop.
pub struct AppState {
    pub store: Arc<Store>,
    pub account: Arc<crate::account::AccountManager>,
    /// Set by the daemon once the relay transport exists; None only in
    /// stripped-down test setups.
    pub sync: tokio::sync::OnceCell<Arc<crate::sync::SyncEngine>>,
    pub started_at: DateTime<Utc>,
    /// Unix ms of the last client interaction, for the idle-exit policy.
    pub last_activity_ms: AtomicI64,
}

impl AppState {
    pub fn new(store: Arc<Store>) -> Arc<Self> {
        let account = crate::account::AccountManager::new(store.clone());
        Arc::new(AppState {
            store,
            account,
            sync: tokio::sync::OnceCell::new(),
            started_at: Utc::now(),
            last_activity_ms: AtomicI64::new(Utc::now().timestamp_millis()),
        })
    }

    pub fn touch(&self) {
        self.last_activity_ms
            .store(Utc::now().timestamp_millis(), Ordering::Relaxed);
    }

    /// Wakes the sync engine after a local mutation (offline-first: the
    /// change is already committed; publication should follow promptly).
    pub fn nudge_sync(&self) {
        if let Some(engine) = self.sync.get() {
            engine.nudge();
        }
    }
}

/// Custom D-Bus error namespace (docs/dbus-api.md).
#[derive(Debug, zbus::DBusError)]
#[zbus(prefix = "com.lwb89dev.Astraea.Error")]
pub enum Error {
    #[zbus(error)]
    ZBus(zbus::Error),
    NotFound(String),
    InvalidArgument(String),
    NotAuthenticated(String),
    SignerUnavailable(String),
    Database(String),
    PayloadTooLarge(String),
    Internal(String),
}

impl From<StoreError> for Error {
    fn from(e: StoreError) -> Self {
        match e {
            StoreError::NotFound(m) => Error::NotFound(m),
            StoreError::Invalid(m) => Error::InvalidArgument(m),
            StoreError::Db(m) => Error::Database(m.to_string()),
            StoreError::Sqlite(m) => Error::Database(m.to_string()),
            StoreError::Poisoned => Error::Internal("store lock poisoned".into()),
        }
    }
}

fn parse_json<T: serde::de::DeserializeOwned>(raw: &str, what: &str) -> Result<T, Error> {
    if raw.len() > model::MAX_JSON_ARG_BYTES {
        return Err(Error::PayloadTooLarge(format!("{what} exceeds 1 MiB")));
    }
    serde_json::from_str(raw).map_err(|e| Error::InvalidArgument(format!("invalid {what}: {e}")))
}

fn to_json<T: serde::Serialize>(value: &T) -> Result<String, Error> {
    serde_json::to_string(value).map_err(|e| Error::Internal(format!("serialization: {e}")))
}

fn parse_date(s: &str) -> Result<NaiveDate, Error> {
    NaiveDate::parse_from_str(s, "%Y-%m-%d")
        .map_err(|_| Error::InvalidArgument(format!("invalid date {s:?}, expected YYYY-MM-DD")))
}

async fn blocking<T, F>(f: F) -> Result<T, Error>
where
    T: Send + 'static,
    F: FnOnce() -> Result<T, StoreError> + Send + 'static,
{
    spawn_blocking(f)
        .await
        .map_err(|e| Error::Internal(format!("worker panicked: {e}")))?
        .map_err(Error::from)
}

pub struct Calendar1 {
    pub state: Arc<AppState>,
}

impl Calendar1 {
    async fn agenda_json(
        &self,
        start: DateTime<Utc>,
        end: DateTime<Utc>,
        calendar_ids: Vec<String>,
    ) -> Result<String, Error> {
        self.state.touch();
        if end <= start {
            return Err(Error::InvalidArgument("end must be after start".into()));
        }
        if end - start > Duration::days(366 * 3) {
            return Err(Error::InvalidArgument(
                "range too large (max 3 years)".into(),
            ));
        }
        let store = self.state.store.clone();
        let events = blocking(move || store.events_in_range(start, end, &calendar_ids)).await?;
        let occurrences = recurrence::expand_all(events.iter(), start, end);
        to_json(&occurrences)
    }

    async fn service_status_json(&self) -> Result<String, Error> {
        let store = self.state.store.clone();
        let pending = blocking(move || store.pending_operations()).await?;
        let store = self.state.store.clone();
        let last_sync = blocking(move || store.get_setting("last_sync_at")).await?;
        let store = self.state.store.clone();
        let account = blocking(move || store.active_account()).await?;
        let network = match self.state.sync.get() {
            Some(engine) => engine.network_status().await,
            None => "unknown".to_owned(),
        };
        to_json(&serde_json::json!({
            "schemaVersion": SCHEMA_VERSION,
            "serviceVersion": env!("CARGO_PKG_VERSION"),
            "databaseStatus": "ok",
            "networkStatus": network,
            "syncStatus": if pending > 0 { "pending" } else { "idle" },
            "authenticated": account.is_some(),
            "activeAccount": account.map(|a| serde_json::Value::String(a.npub))
                .unwrap_or(serde_json::Value::Null),
            "lastSync": last_sync,
            "pendingOperations": pending,
            "startedAt": self.state.started_at.to_rfc3339(),
        }))
    }
}

#[interface(name = "com.lwb89dev.Astraea.Calendar1")]
impl Calendar1 {
    async fn get_version(&self) -> String {
        self.state.touch();
        env!("CARGO_PKG_VERSION").to_owned()
    }

    async fn get_service_status(&self) -> Result<String, Error> {
        self.state.touch();
        self.service_status_json().await
    }

    async fn get_agenda(
        &self,
        start_timestamp: i64,
        end_timestamp: i64,
        calendar_ids: Vec<String>,
    ) -> Result<String, Error> {
        let start = Utc
            .timestamp_opt(start_timestamp, 0)
            .single()
            .ok_or_else(|| Error::InvalidArgument("invalid start timestamp".into()))?;
        let end = Utc
            .timestamp_opt(end_timestamp, 0)
            .single()
            .ok_or_else(|| Error::InvalidArgument("invalid end timestamp".into()))?;
        self.agenda_json(start, end, calendar_ids).await
    }

    async fn get_day(&self, date: String, calendar_ids: Vec<String>) -> Result<String, Error> {
        let day = parse_date(&date)?;
        let start = day.and_hms_opt(0, 0, 0).map(|d| Utc.from_utc_datetime(&d));
        let start = start.ok_or_else(|| Error::InvalidArgument("invalid date".into()))?;
        self.agenda_json(start, start + Duration::days(1), calendar_ids)
            .await
    }

    async fn get_week(
        &self,
        start_date: String,
        calendar_ids: Vec<String>,
    ) -> Result<String, Error> {
        let day = parse_date(&start_date)?;
        let start = day.and_hms_opt(0, 0, 0).map(|d| Utc.from_utc_datetime(&d));
        let start = start.ok_or_else(|| Error::InvalidArgument("invalid date".into()))?;
        self.agenda_json(start, start + Duration::days(7), calendar_ids)
            .await
    }

    async fn get_month(
        &self,
        year: u32,
        month: u32,
        calendar_ids: Vec<String>,
    ) -> Result<String, Error> {
        if !(1..=12).contains(&month) || !(1970..=9999).contains(&year) {
            return Err(Error::InvalidArgument("invalid year/month".into()));
        }
        let start = NaiveDate::from_ymd_opt(year as i32, month, 1)
            .and_then(|d| d.and_hms_opt(0, 0, 0))
            .map(|d| Utc.from_utc_datetime(&d))
            .ok_or_else(|| Error::InvalidArgument("invalid year/month".into()))?;
        let (ny, nm) = if month == 12 {
            (year + 1, 1)
        } else {
            (year, month + 1)
        };
        let end = NaiveDate::from_ymd_opt(ny as i32, nm, 1)
            .and_then(|d| d.and_hms_opt(0, 0, 0))
            .map(|d| Utc.from_utc_datetime(&d))
            .ok_or_else(|| Error::InvalidArgument("invalid year/month".into()))?;
        self.agenda_json(start, end, calendar_ids).await
    }

    /// Master events (not expanded occurrences) intersecting `[start, end)`.
    /// This is what full clients (the Flutter desktop app) use so they can
    /// edit recurrence rules; thin frontends should prefer GetAgenda/GetDay.
    async fn list_events(
        &self,
        start_timestamp: i64,
        end_timestamp: i64,
        calendar_ids: Vec<String>,
    ) -> Result<String, Error> {
        self.state.touch();
        let start = Utc
            .timestamp_opt(start_timestamp, 0)
            .single()
            .ok_or_else(|| Error::InvalidArgument("invalid start timestamp".into()))?;
        let end = Utc
            .timestamp_opt(end_timestamp, 0)
            .single()
            .ok_or_else(|| Error::InvalidArgument("invalid end timestamp".into()))?;
        if end <= start {
            return Err(Error::InvalidArgument("end must be after start".into()));
        }
        let store = self.state.store.clone();
        let events = blocking(move || store.events_in_range(start, end, &calendar_ids)).await?;
        let values = events
            .iter()
            .map(with_schema_version)
            .collect::<Result<Vec<_>, _>>()?;
        to_json(&values)
    }

    async fn get_event(&self, event_id: String) -> Result<String, Error> {
        self.state.touch();
        let store = self.state.store.clone();
        let event = blocking(move || store.get_event(&event_id)).await?;
        to_json(&with_schema_version(&event)?)
    }

    async fn create_event(
        &self,
        #[zbus(signal_emitter)] emitter: SignalEmitter<'_>,
        draft_json: String,
    ) -> Result<String, Error> {
        self.state.touch();
        let draft: EventDraft = parse_json(&draft_json, "event draft")?;
        let store = self.state.store.clone();
        let event = blocking(move || store.create_event(draft, "linux-service")).await?;
        let _ = Calendar1::events_changed(&emitter, vec![event.id.clone()]).await;
        self.state.nudge_sync();
        Ok(event.id)
    }

    async fn update_event(
        &self,
        #[zbus(signal_emitter)] emitter: SignalEmitter<'_>,
        event_id: String,
        patch_json: String,
    ) -> Result<String, Error> {
        self.state.touch();
        let patch: EventPatch = parse_json(&patch_json, "event patch")?;
        let store = self.state.store.clone();
        let id = event_id.clone();
        let event = blocking(move || store.update_event(&id, patch)).await?;
        let _ = Calendar1::events_changed(&emitter, vec![event_id]).await;
        self.state.nudge_sync();
        to_json(&with_schema_version(&event)?)
    }

    async fn delete_event(
        &self,
        #[zbus(signal_emitter)] emitter: SignalEmitter<'_>,
        event_id: String,
    ) -> Result<(), Error> {
        self.state.touch();
        let store = self.state.store.clone();
        let id = event_id.clone();
        blocking(move || store.delete_event(&id)).await?;
        let _ = Calendar1::events_changed(&emitter, vec![event_id]).await;
        self.state.nudge_sync();
        Ok(())
    }

    async fn get_calendars(&self) -> Result<String, Error> {
        self.state.touch();
        let store = self.state.store.clone();
        let calendars = blocking(move || store.calendars()).await?;
        to_json(&calendars)
    }

    async fn create_calendar(
        &self,
        #[zbus(signal_emitter)] emitter: SignalEmitter<'_>,
        draft_json: String,
    ) -> Result<String, Error> {
        self.state.touch();
        let draft: CalendarDraft = parse_json(&draft_json, "calendar draft")?;
        let store = self.state.store.clone();
        let calendar = blocking(move || store.create_calendar(draft)).await?;
        let _ = Calendar1::calendars_changed(&emitter).await;
        Ok(calendar.id)
    }

    async fn update_calendar(
        &self,
        #[zbus(signal_emitter)] emitter: SignalEmitter<'_>,
        calendar_id: String,
        patch_json: String,
    ) -> Result<String, Error> {
        self.state.touch();
        let patch: CalendarPatch = parse_json(&patch_json, "calendar patch")?;
        let store = self.state.store.clone();
        let calendar = blocking(move || store.update_calendar(&calendar_id, patch)).await?;
        let _ = Calendar1::calendars_changed(&emitter).await;
        to_json(&calendar)
    }

    async fn delete_calendar(
        &self,
        #[zbus(signal_emitter)] emitter: SignalEmitter<'_>,
        calendar_id: String,
    ) -> Result<(), Error> {
        self.state.touch();
        let store = self.state.store.clone();
        blocking(move || store.delete_calendar(&calendar_id)).await?;
        let _ = Calendar1::calendars_changed(&emitter).await;
        let _ = Calendar1::events_changed(&emitter, Vec::new()).await;
        Ok(())
    }

    async fn sync_now(&self) -> Result<String, Error> {
        self.state.touch();
        match self.state.sync.get() {
            Some(engine) => Ok(engine.request_sync().await),
            None => Err(Error::Internal("sync engine is not running".into())),
        }
    }

    async fn get_sync_status(&self) -> Result<String, Error> {
        self.state.touch();
        if let Some(engine) = self.state.sync.get() {
            return Ok(engine.status_json().await);
        }
        // Degraded answer for setups without an engine (unit-test servers).
        let store = self.state.store.clone();
        let pending = blocking(move || store.pending_operations()).await?;
        let store = self.state.store.clone();
        let last_sync = blocking(move || store.get_setting("last_sync_at")).await?;
        to_json(&serde_json::json!({
            "schemaVersion": SCHEMA_VERSION,
            "state": if pending > 0 { "pending" } else { "idle" },
            "lastSyncAt": last_sync,
            "pending": pending,
            "failed": 0,
            "relays": [],
        }))
    }

    async fn open_desktop(
        &self,
        view: String,
        target_id: String,
        date: String,
    ) -> Result<(), Error> {
        self.state.touch();
        let uri = build_desktop_uri(&view, &target_id, &date)?;
        // Detached, fixed argv — never a shell, never user-controlled args
        // beyond the validated URI.
        std::process::Command::new("xdg-open")
            .arg(&uri)
            .stdin(std::process::Stdio::null())
            .stdout(std::process::Stdio::null())
            .stderr(std::process::Stdio::null())
            .spawn()
            .map_err(|e| Error::Internal(format!("could not launch handler for {uri}: {e}")))?;
        Ok(())
    }

    async fn get_settings(&self) -> Result<String, Error> {
        self.state.touch();
        let store = self.state.store.clone();
        let raw = blocking(move || store.get_setting("settings")).await?;
        Ok(raw.unwrap_or_else(default_settings_json))
    }

    async fn update_settings(
        &self,
        #[zbus(signal_emitter)] emitter: SignalEmitter<'_>,
        patch_json: String,
    ) -> Result<String, Error> {
        self.state.touch();
        let patch: serde_json::Map<String, serde_json::Value> =
            parse_json(&patch_json, "settings patch")?;
        // Relays get real validation + their own table (the sync engine and
        // diagnostics read it); everything else is an opaque preference.
        let relay_urls: Option<Vec<String>> = match patch.get("relays") {
            None => None,
            Some(serde_json::Value::Array(list)) => {
                let mut urls = Vec::with_capacity(list.len());
                for value in list {
                    let url = value
                        .as_str()
                        .ok_or_else(|| Error::InvalidArgument("relays must be strings".into()))?;
                    crate::sync::transport::validate_relay_url(url)
                        .map_err(Error::InvalidArgument)?;
                    let url = url.trim_end_matches('/').to_owned();
                    if !urls.contains(&url) {
                        urls.push(url);
                    }
                }
                Some(urls)
            }
            Some(serde_json::Value::Null) => Some(Vec::new()),
            Some(_) => return Err(Error::InvalidArgument("relays must be a list".into())),
        };
        if let Some(urls) = &relay_urls {
            let store = self.state.store.clone();
            let urls = urls.clone();
            blocking(move || store.set_relays(&urls)).await?;
        }
        let store = self.state.store.clone();
        let merged = blocking(move || {
            let current = store
                .get_setting("settings")?
                .unwrap_or_else(default_settings_json);
            let mut settings: serde_json::Map<String, serde_json::Value> =
                serde_json::from_str(&current).unwrap_or_default();
            for (k, v) in patch {
                if k == "schemaVersion" {
                    continue;
                }
                if v.is_null() {
                    settings.remove(&k);
                } else {
                    settings.insert(k, v);
                }
            }
            settings.insert("schemaVersion".into(), SCHEMA_VERSION.into());
            let merged = serde_json::to_string(&settings)
                .map_err(|e| StoreError::Invalid(format!("settings serialization: {e}")))?;
            store.set_setting("settings", &merged)?;
            Ok(merged)
        })
        .await?;
        let _ = Calendar1::settings_changed(&emitter, merged.clone()).await;
        if relay_urls.is_some() {
            if let Some(engine) = self.state.sync.get() {
                let _ = engine.request_sync().await;
            }
        }
        Ok(merged)
    }

    #[zbus(signal)]
    pub async fn events_changed(
        emitter: &SignalEmitter<'_>,
        event_ids: Vec<String>,
    ) -> zbus::Result<()>;

    #[zbus(signal)]
    pub async fn calendars_changed(emitter: &SignalEmitter<'_>) -> zbus::Result<()>;

    #[zbus(signal)]
    pub async fn sync_status_changed(
        emitter: &SignalEmitter<'_>,
        status_json: String,
    ) -> zbus::Result<()>;

    #[zbus(signal)]
    pub async fn settings_changed(
        emitter: &SignalEmitter<'_>,
        settings_json: String,
    ) -> zbus::Result<()>;

    #[zbus(signal)]
    pub async fn notification_raised(
        emitter: &SignalEmitter<'_>,
        event_id: String,
        title: String,
        fire_at: i64,
    ) -> zbus::Result<()>;

    #[zbus(signal)]
    pub async fn service_error(
        emitter: &SignalEmitter<'_>,
        code: String,
        message: String,
    ) -> zbus::Result<()>;
}

fn default_settings_json() -> String {
    format!(
        r#"{{"schemaVersion":{SCHEMA_VERSION},"relays":[],"notificationsEnabled":true,"timezone":null}}"#
    )
}

fn with_schema_version(event: &crate::model::Event) -> Result<serde_json::Value, Error> {
    let mut value = serde_json::to_value(event).map_err(|e| Error::Internal(e.to_string()))?;
    if let Some(obj) = value.as_object_mut() {
        obj.insert("schemaVersion".into(), SCHEMA_VERSION.into());
    }
    Ok(value)
}

/// Validates and assembles the astraea:// deep link for OpenDesktop.
fn build_desktop_uri(view: &str, target_id: &str, date: &str) -> Result<String, Error> {
    let safe_id = |s: &str| s.chars().all(|c| c.is_ascii_alphanumeric() || c == '-');
    match view {
        "" | "calendar" | "month" | "agenda" => Ok("astraea://calendar".to_owned()),
        "day" | "week" => {
            let d = parse_date(date)?;
            Ok(format!("astraea://calendar/{view}/{d}"))
        }
        "event" => {
            if target_id.is_empty() || !safe_id(target_id) {
                return Err(Error::InvalidArgument("invalid event id".into()));
            }
            Ok(format!("astraea://event/{target_id}"))
        }
        "new-event" => {
            if date.is_empty() {
                Ok("astraea://new-event".to_owned())
            } else {
                let d = parse_date(date)?;
                Ok(format!("astraea://new-event?date={d}"))
            }
        }
        other => Err(Error::InvalidArgument(format!("unknown view {other:?}"))),
    }
}

// ---------------------------------------------------------------------
// com.lwb89dev.NostrAccount1 — identity interface (ADR-004), backed by the
// account module (browser login bridge + Secret Service + signers).
// ---------------------------------------------------------------------

impl From<crate::account::AccountError> for Error {
    fn from(e: crate::account::AccountError) -> Self {
        match e {
            crate::account::AccountError::Store(inner) => Error::from(inner),
            crate::account::AccountError::NoSuchSession => {
                Error::NotFound("no such login session".into())
            }
            crate::account::AccountError::Login(m) => Error::Internal(m),
        }
    }
}

pub struct NostrAccount1 {
    pub state: Arc<AppState>,
}

#[interface(name = "com.lwb89dev.NostrAccount1")]
impl NostrAccount1 {
    async fn begin_browser_login(&self) -> Result<String, Error> {
        self.state.touch();
        Ok(self.state.account.begin_browser_login().await?)
    }

    async fn cancel_browser_login(&self, session_id: String) -> Result<(), Error> {
        self.state.touch();
        Ok(self.state.account.cancel_browser_login(&session_id).await?)
    }

    async fn get_authentication_status(&self) -> Result<String, Error> {
        self.state.touch();
        Ok(self.state.account.status_json().await?)
    }

    async fn logout(&self) -> Result<(), Error> {
        self.state.touch();
        Ok(self.state.account.logout().await?)
    }

    async fn get_accounts(&self) -> Result<String, Error> {
        self.state.touch();
        Ok(self.state.account.accounts_json().await?)
    }

    async fn switch_account(&self, account_id: String) -> Result<(), Error> {
        self.state.touch();
        Ok(self.state.account.switch_account(&account_id).await?)
    }

    /// Switches the active account's signer mode. No secret material crosses
    /// the bus: provisioning happens against the Secret Service directly.
    async fn set_signer(&self, signer_name: String) -> Result<(), Error> {
        self.state.touch();
        self.state.account.set_signer(&signer_name).await?;
        // A newly capable signer can unpark pending_signature events.
        self.state.nudge_sync();
        Ok(())
    }

    #[zbus(signal)]
    pub async fn authentication_changed(
        emitter: &SignalEmitter<'_>,
        status_json: String,
    ) -> zbus::Result<()>;
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn desktop_uri_validation() {
        assert_eq!(
            build_desktop_uri("", "", "").expect("uri"),
            "astraea://calendar"
        );
        assert_eq!(
            build_desktop_uri("day", "", "2026-07-19").expect("uri"),
            "astraea://calendar/day/2026-07-19"
        );
        assert_eq!(
            build_desktop_uri("event", "3d1f4b2a-1111-2222-3333-444455556666", "").expect("uri"),
            "astraea://event/3d1f4b2a-1111-2222-3333-444455556666"
        );
        assert!(build_desktop_uri("day", "", "not-a-date").is_err());
        assert!(build_desktop_uri("event", "../etc/passwd", "").is_err());
        assert!(build_desktop_uri("shell", "", "").is_err());
    }
}
