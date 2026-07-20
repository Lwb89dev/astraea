//! Applet state model: pure functions from service JSON to the view model
//! the panel popup renders. No I/O here — this is the part the COSMIC UI
//! consumes unchanged once libcosmic is wired in, and the part unit tests
//! pin down today.

use chrono::{DateTime, Local, NaiveDate, Utc};
use serde::Deserialize;

/// One agenda row (from the Occurrence JSON of GetDay, docs/dbus-api.md).
#[derive(Debug, Clone, Deserialize, PartialEq)]
#[serde(rename_all = "camelCase")]
pub struct AgendaItem {
    pub event_id: String,
    pub title: String,
    pub occurrence_start: DateTime<Utc>,
    pub occurrence_end: DateTime<Utc>,
    #[serde(default)]
    pub all_day: bool,
    #[serde(default)]
    pub location: Option<String>,
    pub calendar_id: String,
    pub color: String,
    #[serde(default)]
    pub recurring: bool,
}

impl AgendaItem {
    /// "all day" or a local "HH:MM – HH:MM" label.
    pub fn time_label(&self) -> String {
        if self.all_day {
            "all day".to_owned()
        } else {
            format!(
                "{} – {}",
                self.occurrence_start.with_timezone(&Local).format("%H:%M"),
                self.occurrence_end.with_timezone(&Local).format("%H:%M"),
            )
        }
    }
}

/// What the panel needs to render, regardless of toolkit.
#[derive(Debug, Clone, Default, PartialEq)]
pub struct AppletState {
    pub selected_date: Option<NaiveDate>,
    pub items: Vec<AgendaItem>,
    /// None = service unreachable (the applet must say so, never crash).
    pub service: Option<ServiceSummary>,
}

#[derive(Debug, Clone, PartialEq)]
pub struct ServiceSummary {
    pub authenticated: bool,
    pub network: String,
    pub pending: i64,
}

impl AppletState {
    pub fn service_unreachable(&mut self) {
        self.service = None;
        self.items.clear();
    }

    /// Applies a GetServiceStatus reply. Unknown fields are ignored;
    /// malformed JSON degrades to "unreachable" rather than erroring.
    pub fn apply_status(&mut self, status_json: &str) {
        #[derive(Deserialize)]
        #[serde(rename_all = "camelCase")]
        struct Raw {
            #[serde(default)]
            authenticated: bool,
            #[serde(default)]
            network_status: Option<String>,
            #[serde(default)]
            pending_operations: i64,
        }
        match serde_json::from_str::<Raw>(status_json) {
            Ok(raw) => {
                self.service = Some(ServiceSummary {
                    authenticated: raw.authenticated,
                    network: raw.network_status.unwrap_or_else(|| "unknown".into()),
                    pending: raw.pending_operations,
                });
            }
            Err(_) => self.service = None,
        }
    }

    /// Applies a GetDay reply for `date`. Skips malformed rows (a bad event
    /// must never blank the whole agenda).
    pub fn apply_day(&mut self, date: NaiveDate, day_json: &str) {
        self.selected_date = Some(date);
        let rows: Vec<serde_json::Value> = serde_json::from_str(day_json).unwrap_or_default();
        self.items = rows
            .into_iter()
            .filter_map(|row| serde_json::from_value::<AgendaItem>(row).ok())
            .collect();
        self.items.sort_by(|a, b| {
            b.all_day
                .cmp(&a.all_day)
                .then(a.occurrence_start.cmp(&b.occurrence_start))
        });
    }

    /// The one-line panel label ("3 events", "offline", …).
    pub fn indicator_label(&self) -> String {
        match &self.service {
            None => "service unavailable".to_owned(),
            Some(s) if !s.authenticated => "not signed in".to_owned(),
            Some(s) => {
                let base = match self.items.len() {
                    0 => "no events".to_owned(),
                    1 => "1 event".to_owned(),
                    n => format!("{n} events"),
                };
                if s.network == "offline" {
                    format!("{base} · offline")
                } else if s.pending > 0 {
                    format!("{base} · {} pending", s.pending)
                } else {
                    base
                }
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn day_json() -> String {
        serde_json::json!([
            {
                "schemaVersion": 1,
                "eventId": "b", "title": "Later",
                "occurrenceStart": "2026-07-20T14:00:00Z",
                "occurrenceEnd": "2026-07-20T15:00:00Z",
                "allDay": false, "calendarId": "default", "color": "0xFF2196F3",
                "timezone": "UTC", "syncState": "synced", "status": "confirmed",
                "recurring": false
            },
            {
                "schemaVersion": 1,
                "eventId": "a", "title": "All-day",
                "occurrenceStart": "2026-07-20T00:00:00Z",
                "occurrenceEnd": "2026-07-21T00:00:00Z",
                "allDay": true, "calendarId": "default", "color": "0xFF2196F3",
                "timezone": "UTC", "syncState": "synced", "status": "confirmed",
                "recurring": false
            },
            {"malformed": true}
        ])
        .to_string()
    }

    #[test]
    fn day_parse_sorts_all_day_first_and_skips_junk() {
        let mut state = AppletState::default();
        let date = NaiveDate::from_ymd_opt(2026, 7, 20).expect("date");
        state.apply_day(date, &day_json());
        assert_eq!(state.items.len(), 2);
        assert_eq!(state.items[0].event_id, "a");
        assert_eq!(state.items[0].time_label(), "all day");
        assert_eq!(state.items[1].event_id, "b");
        assert_eq!(state.selected_date, Some(date));
    }

    #[test]
    fn indicator_label_covers_the_service_states() {
        let mut state = AppletState::default();
        assert_eq!(state.indicator_label(), "service unavailable");

        state.apply_status(
            r#"{"authenticated":false,"networkStatus":"unknown","pendingOperations":0}"#,
        );
        assert_eq!(state.indicator_label(), "not signed in");

        state.apply_status(
            r#"{"authenticated":true,"networkStatus":"online","pendingOperations":0}"#,
        );
        state.apply_day(
            NaiveDate::from_ymd_opt(2026, 7, 20).expect("date"),
            &day_json(),
        );
        assert_eq!(state.indicator_label(), "2 events");

        state.apply_status(
            r#"{"authenticated":true,"networkStatus":"offline","pendingOperations":3}"#,
        );
        assert_eq!(state.indicator_label(), "2 events · offline");

        state.apply_status(
            r#"{"authenticated":true,"networkStatus":"online","pendingOperations":3}"#,
        );
        assert_eq!(state.indicator_label(), "2 events · 3 pending");
    }

    #[test]
    fn malformed_status_degrades_to_unreachable() {
        let mut state = AppletState::default();
        state.apply_status("not json at all");
        assert!(state.service.is_none());
        state.apply_day(
            NaiveDate::from_ymd_opt(2026, 7, 20).expect("date"),
            "also not json",
        );
        assert!(state.items.is_empty());
    }
}
