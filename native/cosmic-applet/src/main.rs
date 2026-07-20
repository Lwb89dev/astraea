//! Terminal frontend for the Astraea COSMIC applet crate.
//!
//! This is NOT the panel applet — it is the honest, working proof of the
//! two pieces the panel will reuse (`client`, `state`) against the live
//! service, and a useful `astraea agenda` for COSMIC users meanwhile:
//!
//!   astraea-cosmic-applet            today's agenda + status line
//!   astraea-cosmic-applet 2026-07-21 that day's agenda
//!   astraea-cosmic-applet --open     open the desktop app on today
//!
//! Panel integration status and plan: docs/cosmic-applet.md.

mod client;
mod state;

use chrono::{Local, NaiveDate};
use state::AppletState;

#[tokio::main(flavor = "current_thread")]
async fn main() -> std::process::ExitCode {
    let mut date = Local::now().date_naive();
    let mut open = false;
    for arg in std::env::args().skip(1) {
        match arg.as_str() {
            "--open" => open = true,
            "--help" | "-h" => {
                eprintln!("usage: astraea-cosmic-applet [YYYY-MM-DD] [--open]");
                return std::process::ExitCode::SUCCESS;
            }
            other => match NaiveDate::parse_from_str(other, "%Y-%m-%d") {
                Ok(parsed) => date = parsed,
                Err(_) => {
                    eprintln!("not a date (YYYY-MM-DD): {other}");
                    return std::process::ExitCode::from(2);
                }
            },
        }
    }

    let mut applet = AppletState::default();
    match client::connect().await {
        Ok(proxy) => {
            if open {
                if let Err(e) = proxy
                    .open_desktop("day".into(), String::new(), date.to_string())
                    .await
                {
                    eprintln!("could not open the desktop app: {e}");
                }
            }
            match proxy.get_service_status().await {
                Ok(status) => applet.apply_status(&status),
                Err(_) => applet.service_unreachable(),
            }
            if applet.service.is_some() {
                match proxy.get_day(date.to_string(), Vec::new()).await {
                    Ok(day) => applet.apply_day(date, &day),
                    Err(e) => eprintln!("agenda unavailable: {e}"),
                }
            }
        }
        Err(_) => applet.service_unreachable(),
    }

    println!("Astraea — {date}  [{}]", applet.indicator_label());
    for item in &applet.items {
        let location = item
            .location
            .as_deref()
            .map(|l| format!("  ({l})"))
            .unwrap_or_default();
        println!("  {:<15} {}{}", item.time_label(), item.title, location);
    }
    if applet.service.is_none() {
        eprintln!(
            "{} ({}) is not reachable on the session bus.",
            client::BUS_NAME,
            client::OBJECT_PATH
        );
        eprintln!("Install astraea-service; D-Bus activation starts it on demand.");
        return std::process::ExitCode::FAILURE;
    }
    std::process::ExitCode::SUCCESS
}
