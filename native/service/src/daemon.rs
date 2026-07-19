//! Daemon lifecycle: own the bus name (singleton by construction), serve the
//! interfaces, exit gracefully on SIGTERM/SIGINT or after the idle period.

use std::sync::atomic::Ordering;
use std::sync::Arc;
use std::time::Duration;

use chrono::Utc;
use tracing::info;
use zbus::connection;

use crate::bus::{AppState, Calendar1, NostrAccount1, BUS_NAME, OBJECT_PATH};
use crate::store::Store;

/// Exit when idle for this long with nothing pending. D-Bus activation
/// restarts the service transparently on the next call.
const IDLE_EXIT: Duration = Duration::from_secs(30 * 60);
const IDLE_CHECK_EVERY: Duration = Duration::from_secs(60);

pub async fn run(store: Store) -> anyhow::Result<()> {
    let store = Arc::new(store);
    let state = AppState::new(store.clone());

    let connection = connection::Builder::session()?
        .name(BUS_NAME)?
        .serve_at(OBJECT_PATH, Calendar1 { state: state.clone() })?
        .serve_at(OBJECT_PATH, NostrAccount1 { state: state.clone() })?
        .build()
        .await?;
    info!(
        bus = BUS_NAME,
        path = OBJECT_PATH,
        db = %state.store.db_path.display(),
        "astraea-service ready on the session bus"
    );

    let mut sigterm = tokio::signal::unix::signal(tokio::signal::unix::SignalKind::terminate())?;
    let mut sigint = tokio::signal::unix::signal(tokio::signal::unix::SignalKind::interrupt())?;

    loop {
        tokio::select! {
            _ = sigterm.recv() => {
                info!("SIGTERM received, shutting down");
                break;
            }
            _ = sigint.recv() => {
                info!("SIGINT received, shutting down");
                break;
            }
            _ = tokio::time::sleep(IDLE_CHECK_EVERY) => {
                if should_idle_exit(&state).await {
                    info!("idle for {}s with no pending work, exiting (D-Bus activation will restart on demand)", IDLE_EXIT.as_secs());
                    break;
                }
            }
        }
    }

    // Graceful shutdown: release the name so activation works immediately,
    // then close the database cleanly (WAL checkpoint on drop).
    connection.graceful_shutdown().await;
    info!("shutdown complete");
    Ok(())
}

async fn should_idle_exit(state: &AppState) -> bool {
    let last = state.last_activity_ms.load(Ordering::Relaxed);
    let idle_ms = Utc::now().timestamp_millis() - last;
    if idle_ms < IDLE_EXIT.as_millis() as i64 {
        return false;
    }
    // Never exit while local changes still need publishing.
    let store = state.store.clone();
    match tokio::task::spawn_blocking(move || store.pending_operations()).await {
        Ok(Ok(0)) => true,
        Ok(Ok(_)) => false,
        _ => false,
    }
}
