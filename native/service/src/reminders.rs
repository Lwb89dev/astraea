//! Small, service-owned reminder scheduler for Linux.
//!
//! The Flutter desktop process is deliberately not the owner of alarms: it
//! can be closed while the D-Bus service stays available. The loop therefore
//! checks the durable event store, fires freedesktop notifications, and keeps
//! a short in-memory dedupe window so the same reminder is not shown on every
//! tick.

use std::collections::HashMap;
use std::sync::Arc;
use std::time::Duration as StdDuration;

use chrono::{DateTime, Duration, Utc};
use tracing::debug;
use zbus::Connection;

use crate::model::Event;
use crate::recurrence;
use crate::store::Store;

const TICK: StdDuration = StdDuration::from_secs(15);
const LOOK_AROUND: Duration = Duration::days(7);
const DEDUPE_RETENTION: Duration = Duration::days(8);

/// Runs until the service process exits. A missing notification daemon is
/// harmless: [crate::notify::notify] deliberately swallows that failure.
pub async fn run(store: Arc<Store>, connection: Connection) {
    let mut fired: HashMap<String, DateTime<Utc>> = HashMap::new();
    loop {
        let now = Utc::now();
        fired.retain(|_, seen_at| *seen_at > now - DEDUPE_RETENTION);

        if notifications_enabled(&store) {
            let window_start = now - LOOK_AROUND;
            let window_end = now + LOOK_AROUND;
            match load_events(&store, window_start, window_end).await {
                Ok(events) => {
                    for event in events {
                        fire_due_reminders(&connection, &event, now, &mut fired).await;
                    }
                }
                Err(error) => debug!(%error, "reminder scan failed"),
            }
        }

        tokio::time::sleep(TICK).await;
    }
}

async fn load_events(
    store: &Arc<Store>,
    start: DateTime<Utc>,
    end: DateTime<Utc>,
) -> anyhow::Result<Vec<Event>> {
    let store = Arc::clone(store);
    Ok(tokio::task::spawn_blocking(move || store.events_in_range(start, end, &[])).await??)
}

fn notifications_enabled(store: &Store) -> bool {
    store
        .get_setting("settings")
        .ok()
        .flatten()
        .and_then(|raw| serde_json::from_str::<serde_json::Value>(&raw).ok())
        .and_then(|settings| {
            settings
                .get("notificationsEnabled")
                .and_then(|v| v.as_bool())
        })
        .unwrap_or(true)
}

async fn fire_due_reminders(
    connection: &Connection,
    event: &Event,
    now: DateTime<Utc>,
    fired: &mut HashMap<String, DateTime<Utc>>,
) {
    let occurrences = recurrence::expand(event, now - LOOK_AROUND, now + LOOK_AROUND);
    for occurrence in occurrences {
        for reminder in &event.reminders {
            let fire_at =
                occurrence.occurrence_start - Duration::minutes(reminder.minutes_before.max(0));
            // The scan cadence is 15 seconds. The one-minute slack handles a
            // busy desktop without replaying an old reminder after restart.
            if fire_at > now || fire_at <= now - Duration::minutes(1) {
                continue;
            }
            let key = format!(
                "{}:{}:{}",
                event.id,
                occurrence.occurrence_start.timestamp(),
                reminder.minutes_before
            );
            if fired.insert(key, now).is_some() {
                continue;
            }
            let body = if reminder.minutes_before <= 0 {
                "Starting now".to_owned()
            } else {
                format!("Starts in {} min", reminder.minutes_before)
            };
            crate::notify::notify(
                connection,
                if event.title.is_empty() {
                    "Astraea"
                } else {
                    &event.title
                },
                &body,
            )
            .await;
        }
    }
}

/// Used by the daemon idle policy: a service with a future reminder must stay
/// alive even if no D-Bus client is currently connected.
pub fn has_upcoming_reminder(store: &Store, now: DateTime<Utc>) -> bool {
    let Ok(events) = store.events_in_range(now, now + LOOK_AROUND, &[]) else {
        return true;
    };
    events.iter().any(|event| !event.reminders.is_empty())
}
