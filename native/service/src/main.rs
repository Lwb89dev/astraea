//! astraea-service: Astraea's Linux background service.
//!
//! Default invocation runs the daemon (this is what systemd/D-Bus activation
//! executes). Subcommands are a thin CLI over the D-Bus API plus local
//! database/diagnostic helpers. See docs/linux-architecture.md.

mod bus;
mod daemon;
mod db;
mod model;
mod paths;
mod recurrence;
mod store;

use clap::{Parser, Subcommand};
use tracing_subscriber::EnvFilter;

#[derive(Parser)]
#[command(name = "astraea-service", version, about = "Astraea calendar background service")]
struct Cli {
    #[command(subcommand)]
    command: Option<Command>,
}

#[derive(Subcommand)]
enum Command {
    /// Run the daemon (default when no subcommand is given).
    Run,
    /// Show service status via D-Bus (starts the service if activatable).
    Status,
    /// Trigger a sync cycle via D-Bus.
    Sync,
    /// Print environment/diagnostic information (no changes).
    Diagnostics,
    /// Check the installation and suggest fixes (no destructive changes).
    Doctor,
    /// Database maintenance.
    Db {
        #[command(subcommand)]
        command: DbCommand,
    },
    /// Authentication management (browser login lands in a later phase).
    Auth {
        #[command(subcommand)]
        command: AuthCommand,
    },
}

#[derive(Subcommand)]
enum DbCommand {
    /// Apply pending schema migrations (takes a backup first).
    Migrate,
}

#[derive(Subcommand)]
enum AuthCommand {
    Login,
    Status,
    Logout,
}

fn main() -> anyhow::Result<()> {
    tracing_subscriber::fmt()
        .with_env_filter(EnvFilter::try_from_default_env().unwrap_or_else(|_| EnvFilter::new("info")))
        .with_writer(std::io::stderr)
        .init();

    let cli = Cli::parse();
    let runtime = tokio::runtime::Runtime::new()?;
    match cli.command.unwrap_or(Command::Run) {
        Command::Run => runtime.block_on(run_daemon()),
        Command::Status => runtime.block_on(cli_status()),
        Command::Sync => runtime.block_on(cli_sync()),
        Command::Diagnostics => runtime.block_on(cli_diagnostics()),
        Command::Doctor => runtime.block_on(cli_doctor()),
        Command::Db { command: DbCommand::Migrate } => cli_db_migrate(),
        Command::Auth { command } => runtime.block_on(cli_auth(command)),
    }
}

async fn run_daemon() -> anyhow::Result<()> {
    let store = store::Store::open(paths::database_path())?;
    daemon::run(store).await
}

/// Proxy for the CLI subcommands. Auto-start is intentional: `status` etc.
/// should work through D-Bus activation.
async fn calendar_proxy(connection: &zbus::Connection) -> anyhow::Result<zbus::Proxy<'static>> {
    Ok(zbus::proxy::Builder::new(connection)
        .destination(bus::BUS_NAME)?
        .path(bus::OBJECT_PATH)?
        .interface("com.lwb89dev.Astraea.Calendar1")?
        .build()
        .await?)
}

async fn account_proxy(connection: &zbus::Connection) -> anyhow::Result<zbus::Proxy<'static>> {
    Ok(zbus::proxy::Builder::new(connection)
        .destination(bus::BUS_NAME)?
        .path(bus::OBJECT_PATH)?
        .interface("com.lwb89dev.NostrAccount1")?
        .build()
        .await?)
}

async fn cli_status() -> anyhow::Result<()> {
    let connection = zbus::Connection::session().await?;
    let proxy = calendar_proxy(&connection).await?;
    let status: String = proxy.call("GetServiceStatus", &()).await?;
    println!("{}", pretty(&status));
    Ok(())
}

async fn cli_sync() -> anyhow::Result<()> {
    let connection = zbus::Connection::session().await?;
    let proxy = calendar_proxy(&connection).await?;
    match proxy.call::<_, _, String>("SyncNow", &()).await {
        Ok(op) => println!("sync started: {op}"),
        Err(e) => println!("sync not started: {e}"),
    }
    Ok(())
}

async fn cli_auth(command: AuthCommand) -> anyhow::Result<()> {
    let connection = zbus::Connection::session().await?;
    let proxy = account_proxy(&connection).await?;
    match command {
        AuthCommand::Login => match proxy.call::<_, _, String>("BeginBrowserLogin", &()).await {
            Ok(session) => println!("{}", pretty(&session)),
            Err(e) => println!("login not started: {e}"),
        },
        AuthCommand::Status => {
            let status: String = proxy.call("GetAuthenticationStatus", &()).await?;
            println!("{}", pretty(&status));
        }
        AuthCommand::Logout => {
            proxy.call::<_, _, ()>("Logout", &()).await?;
            println!("logged out");
        }
    }
    Ok(())
}

fn cli_db_migrate() -> anyhow::Result<()> {
    let path = paths::database_path();
    let conn = db::open(&path)?;
    println!("database: {}", path.display());
    println!("schema version: {}", db::schema_version(&conn)?);
    Ok(())
}

async fn cli_diagnostics() -> anyhow::Result<()> {
    println!("astraea-service {}", env!("CARGO_PKG_VERSION"));
    println!("distro: {}", read_os_release());
    println!(
        "desktop environment: {}",
        std::env::var("XDG_CURRENT_DESKTOP").unwrap_or_else(|_| "unknown".into())
    );
    println!(
        "session type: {}",
        std::env::var("XDG_SESSION_TYPE").unwrap_or_else(|_| "unknown".into())
    );

    match zbus::Connection::session().await {
        Ok(connection) => {
            println!("session D-Bus: ok");
            let dbus = zbus::fdo::DBusProxy::new(&connection).await?;
            let owned = dbus.name_has_owner(bus::BUS_NAME.try_into()?).await?;
            println!("service on bus: {}", if owned { "running" } else { "not running (activatable on demand)" });
            let secrets = dbus.name_has_owner("org.freedesktop.secrets".try_into()?).await
                .unwrap_or(false);
            let activatable = dbus
                .list_activatable_names()
                .await
                .map(|names| names.iter().any(|n| n.as_str() == "org.freedesktop.secrets"))
                .unwrap_or(false);
            println!(
                "secret service: {}",
                if secrets || activatable { "available" } else { "NOT available" }
            );
        }
        Err(e) => println!("session D-Bus: UNAVAILABLE ({e})"),
    }

    println!("data dir:    {}", paths::data_dir().display());
    println!("config dir:  {}", paths::config_dir().display());
    println!("cache dir:   {}", paths::cache_dir().display());
    println!("state dir:   {}", paths::state_dir().display());
    println!("log dir:     {}", paths::log_dir().display());
    println!(
        "runtime dir: {}",
        paths::runtime_dir().map(|p| p.display().to_string()).unwrap_or_else(|| "unset".into())
    );

    let db_path = paths::database_path();
    println!("database path: {}", db_path.display());
    if db_path.exists() {
        match db::open(&db_path) {
            Ok(conn) => {
                let events: i64 = conn.query_row(
                    "SELECT COUNT(*) FROM events WHERE deleted_at_ms IS NULL",
                    [],
                    |r| r.get(0),
                )?;
                let calendars: i64 = conn.query_row(
                    "SELECT COUNT(*) FROM calendars WHERE deleted = 0",
                    [],
                    |r| r.get(0),
                )?;
                println!(
                    "database: ok (schema v{}, {events} events, {calendars} calendars)",
                    db::schema_version(&conn)?
                );
            }
            Err(e) => println!("database: ERROR ({e})"),
        }
    } else {
        println!("database: not created yet");
    }

    let unit = std::process::Command::new("systemctl")
        .args(["--user", "is-enabled", "astraea.service"])
        .output();
    match unit {
        Ok(out) => println!(
            "systemd user unit: {}",
            String::from_utf8_lossy(&out.stdout).trim()
        ),
        Err(_) => println!("systemd user unit: systemctl not available (non-systemd system?)"),
    }
    Ok(())
}

async fn cli_doctor() -> anyhow::Result<()> {
    println!("astraea-service doctor — checks only, no changes are made\n");
    let mut suggestions: Vec<String> = Vec::new();

    match zbus::Connection::session().await {
        Ok(connection) => {
            let dbus = zbus::fdo::DBusProxy::new(&connection).await?;
            let activatable = dbus
                .list_activatable_names()
                .await
                .map(|names| names.iter().any(|n| n.as_str() == bus::BUS_NAME))
                .unwrap_or(false);
            if !activatable {
                suggestions.push(
                    "D-Bus activation file missing: install the package, or copy \
                     packaging/common/com.lwb89dev.Astraea.Service.service to \
                     ~/.local/share/dbus-1/services/ (scripts/install-dev.sh does this)"
                        .into(),
                );
            }
            let secrets = dbus
                .name_has_owner("org.freedesktop.secrets".try_into()?)
                .await
                .unwrap_or(false);
            if !secrets {
                suggestions.push(
                    "No Secret Service on the bus: install/enable GNOME Keyring or KWallet \
                     (needed for authentication; calendar features work without it)"
                        .into(),
                );
            }
        }
        Err(e) => suggestions.push(format!(
            "No session D-Bus connection ({e}). Astraea requires a desktop session bus."
        )),
    }

    let db_path = paths::database_path();
    if db_path.exists() {
        if let Err(e) = db::open(&db_path) {
            suggestions.push(format!(
                "Database check failed: {e}. A quarantined copy (if any) is next to {}",
                db_path.display()
            ));
        }
    }

    if suggestions.is_empty() {
        println!("everything looks good");
    } else {
        for (i, s) in suggestions.iter().enumerate() {
            println!("{}. {s}", i + 1);
        }
    }
    Ok(())
}

fn read_os_release() -> String {
    std::fs::read_to_string("/etc/os-release")
        .ok()
        .and_then(|content| {
            content
                .lines()
                .find(|l| l.starts_with("PRETTY_NAME="))
                .map(|l| l.trim_start_matches("PRETTY_NAME=").trim_matches('"').to_owned())
        })
        .unwrap_or_else(|| "unknown".into())
}

fn pretty(raw: &str) -> String {
    serde_json::from_str::<serde_json::Value>(raw)
        .and_then(|v| serde_json::to_string_pretty(&v))
        .unwrap_or_else(|_| raw.to_owned())
}
