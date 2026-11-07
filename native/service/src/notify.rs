//! Desktop notifications via the freedesktop.org Notifications spec
//! (`org.freedesktop.Notifications` on the session bus — the same bus
//! astraea-service already owns its own name on).
//!
//! This is deliberately independent of whether the Flutter desktop app is
//! running: an invite response can arrive while the UI is closed, and the
//! background service is exactly the thing that must still tell the user.
//! `Calendar1::NotificationRaised` (docs/dbus-api.md) is emitted alongside
//! for any UI that wants to react too, but delivery does not depend on it.

use zbus::Connection;

const BUS_NAME: &str = "org.freedesktop.Notifications";
const OBJECT_PATH: &str = "/org/freedesktop/Notifications";
const INTERFACE: &str = "org.freedesktop.Notifications";
/// Astraea's own reverse-DNS app name, per the spec's `app_name` argument.
const APP_NAME: &str = "com.lwb89dev.Astraea";

/// Fire-and-forget: a missing/unavailable notification daemon (headless
/// box, minimal WM) must never fail the caller's actual work.
pub async fn notify(connection: &Connection, summary: &str, body: &str) {
    let proxy = match zbus::Proxy::new(connection, BUS_NAME, OBJECT_PATH, INTERFACE).await {
        Ok(p) => p,
        Err(e) => {
            tracing::debug!("notification daemon unavailable: {e}");
            return;
        }
    };
    let result: zbus::Result<u32> = proxy
        .call(
            "Notify",
            &(
                APP_NAME,
                0u32,                // replaces_id: always a new notification
                "x-office-calendar", // icon (freedesktop icon-naming-spec)
                summary,
                body,
                Vec::<&str>::new(), // actions
                std::collections::HashMap::<&str, zbus::zvariant::Value>::new(), // hints
                5_000i32,           // expire_timeout (ms)
            ),
        )
        .await;
    if let Err(e) = result {
        tracing::debug!("could not raise a desktop notification: {e}");
    }
}
