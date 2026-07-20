# COSMIC applet

Crate: `native/cosmic-applet` (`astraea-cosmic-applet`). Same backend as
everything else — the `com.lwb89dev.Astraea.Calendar1` D-Bus API — with no
duplicated Nostr logic, no keys, no database access (same rules as the
GNOME extension).

## What exists today (compilable, tested)

- `src/client.rs` — zbus proxy for the Calendar1 methods the applet needs
  (GetDay, GetServiceStatus, CreateEvent, OpenDesktop, GetSyncStatus) and
  the EventsChanged / SyncStatusChanged signals.
- `src/state.rs` — the toolkit-independent view model: agenda rows from
  Occurrence JSON (all-day first, junk rows skipped), service summary,
  indicator label ("2 events · offline", "not signed in", "service
  unavailable"). This is the part unit tests pin down.
- `src/main.rs` — a working terminal frontend over those two modules:
  `astraea-cosmic-applet [YYYY-MM-DD] [--open]` prints the agenda via the
  live service (D-Bus activation starts it) and exercises the exact code
  paths the panel popup will use.

```sh
cargo run --manifest-path native/cosmic-applet/Cargo.toml -- 2026-07-21
```

## What is deliberately NOT here yet

The panel UI. `libcosmic` (and `cosmic-applet-host` conventions) are
git-only and API-unstable across COSMIC alphas; depending on a moving git
revision would rot immediately and reviewing fake widget code helps
nobody. This is the documented blocked part, per the project rule "no
fictitious code presented as complete".

## Integration plan (when libcosmic is packaged)

1. Add `libcosmic` (applet feature) as an optional dependency behind a
   `panel` feature flag; keep the crate building without it.
2. Panel entry point: `cosmic::applet::run::<AstraeaApplet>()` where
   `AstraeaApplet` holds an `AppletState` and a `Calendar1Proxy`.
3. Popup layout: date selector row (‹ today ›), agenda list from
   `AppletState::items` (`time_label()` + title + location), quick-add
   form (title, start, end, all-day → `CreateEvent` draft JSON), footer
   buttons "Open Astraea" (`OpenDesktop("day", "", date)`) and the
   status line (`indicator_label()`).
4. Refresh on `EventsChanged` / `SyncStatusChanged` signals — no polling
   (the signal streams are already exposed by the proxy).
5. Package as a fourth modular package (`astraea-cosmic-applet`,
   `Depends: astraea-service`, `Recommends: astraea-desktop`) with the
   applet .desktop entry COSMIC expects under
   `/usr/share/applications/` (`X-CosmicApplet=true`).

Until then, COSMIC users get the desktop app + service (both fully
functional on COSMIC — the dev machine runs COSMIC) and the terminal
agenda above.
