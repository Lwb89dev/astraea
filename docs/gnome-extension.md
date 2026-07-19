# GNOME Shell extension

Source: `extensions/gnome/astraea@lwb89dev/`. UUID: `astraea@lwb89dev`.
Supported GNOME Shell versions: **45–48** (ESM extensions API).

## What it is (and is not)

A **thin frontend** over `com.lwb89dev.Astraea.Service` (docs/dbus-api.md):

- top-bar indicator with a day agenda popup (‹ / today / ›);
- quick event form (title, start, end, all-day) → `CreateEvent`;
- tap an event → `OpenDesktop("event", id, …)` raises the Flutter app;
- live updates via the `EventsChanged` D-Bus signal — no polling; the only
  extra fetch is a refresh each time the menu opens;
- clear status line when the service is unreachable — the shell never
  crashes or blocks (all calls async with a 10 s timeout).

It never connects to Nostr relays, never signs events, never reads the
database, never stores keys. The service is started on demand by D-Bus
activation the first time a menu action needs it, not at shell login.

## Clock-menu integration decision

The brief prefers embedding the agenda into GNOME's central clock/calendar
menu. `Main.panel.statusArea.dateMenu` has no stable extension API: its
internals (`_calendar`, `_eventsItem`, `_messageList`) are private and have
changed in 44 → 45 → 46. Patching them can and does break shells; extensions
doing it maintain per-version forks. Decision (recorded here as the ADR):

1. ship the standalone indicator (this implementation) — stable across
   45–48 with one codebase;
2. a later `dateMenuAdapter.js` may *add* a section to the clock menu behind
   a per-version capability check, falling back to the indicator when the
   private API doesn't match. It must never replace or reorder the stock
   calendar, and any failure must degrade to the fallback silently.

## Install for development

```bash
ln -s "$PWD/extensions/gnome/astraea@lwb89dev" \
      ~/.local/share/gnome-shell/extensions/astraea@lwb89dev
# Wayland: log out/in. X11: Alt+F2, 'r'.
gnome-extensions enable astraea@lwb89dev
journalctl --user -f -o cat /usr/bin/gnome-shell   # watch for errors
```

Packages install the same directory under
`/usr/share/gnome-shell/extensions/`.

Compile translations (packages do this at build time):

```bash
mkdir -p locale/it/LC_MESSAGES
msgfmt po/it.po -o locale/it/LC_MESSAGES/astraea-gnome.mo
```

## Manual test plan

The development machine for this branch runs COSMIC, so the extension is
validated on GNOME VMs/containers rather than locally. Minimum matrix:
Ubuntu 24.04 (GNOME 46) and Fedora latest (GNOME 47/48).

1. enable extension with the service **not** installed → indicator appears,
   popup shows the "service unavailable" line, shell stays responsive;
2. install the service (`./scripts/install-dev.sh`) → reopen popup → agenda
   loads (empty state: "No events");
3. quick-add an event → it appears in the popup, in `astraea-service status`
   (pendingOperations grows) and in the Flutter app;
4. create an event from the Flutter app → popup updates via signal without
   reopening;
5. `systemctl --user stop astraea.service` while the popup is open → next
   action shows the unavailable state; a later action re-activates the
   service;
6. keyboard-only pass: open popup (Super, arrows), navigate days, open the
   quick form, type, save;
7. disable the extension → indicator disappears, `journalctl` shows no
   errors, shell intact.

## Lint

CI runs `eslint` with the gjs/GNOME profile over `extensions/gnome/`
(see .github/workflows). Locally: `npx eslint extensions/gnome` if you have
node; there is no runtime dependency on node.
