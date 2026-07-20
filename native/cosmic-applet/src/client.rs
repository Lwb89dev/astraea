//! D-Bus client for com.lwb89dev.Astraea.Calendar1 (docs/dbus-api.md).
//! Shared by the terminal frontend today and the COSMIC panel UI when
//! libcosmic lands. Every call inherits zbus's default method timeout; the
//! applet must always render something when the service is unreachable.

use zbus::proxy;

pub const BUS_NAME: &str = "com.lwb89dev.Astraea.Service";
pub const OBJECT_PATH: &str = "/com/lwb89dev/Astraea";

#[proxy(
    interface = "com.lwb89dev.Astraea.Calendar1",
    default_service = "com.lwb89dev.Astraea.Service",
    default_path = "/com/lwb89dev/Astraea"
)]
pub trait Calendar1 {
    fn get_version(&self) -> zbus::Result<String>;
    fn get_service_status(&self) -> zbus::Result<String>;
    fn get_day(&self, date: String, calendar_ids: Vec<String>) -> zbus::Result<String>;
    fn create_event(&self, draft_json: String) -> zbus::Result<String>;
    fn open_desktop(&self, view: String, target_id: String, date: String) -> zbus::Result<()>;
    fn get_sync_status(&self) -> zbus::Result<String>;

    #[zbus(signal)]
    fn events_changed(&self, event_ids: Vec<String>) -> zbus::Result<()>;

    #[zbus(signal)]
    fn sync_status_changed(&self, status_json: String) -> zbus::Result<()>;
}

/// Connects to the session bus and returns the proxy. D-Bus activation
/// starts the service on the first call if it is not running.
pub async fn connect() -> zbus::Result<Calendar1Proxy<'static>> {
    let connection = zbus::Connection::session().await?;
    Calendar1Proxy::new(&connection).await
}
