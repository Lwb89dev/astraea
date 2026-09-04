# Troubleshooting — Astraea on Linux

Start with the two built-in commands (both are read-only):

```sh
astraea-service diagnostics   # versions, paths, D-Bus, database, relays
astraea-service doctor        # suggests fixes, changes nothing
```

## The desktop app says "service unreachable"

1. Is the activation file installed?
   `ls /usr/share/dbus-1/services/com.lwb89dev.Astraea.Service.service`
   (or `~/.local/share/dbus-1/services/` for dev installs).
2. Call it directly — this also starts it on demand:
   ```sh
   busctl --user call com.lwb89dev.Astraea.Service /com/lwb89dev/Astraea \
     com.lwb89dev.Astraea.Calendar1 GetVersion
   ```
3. Logs: `journalctl --user -u astraea.service -f` (systemd) or run in the
   foreground: `RUST_LOG=debug astraea-service run`.
4. Flatpak GUI: the sandbox only has `--talk-name` for the service — the
   service itself must be installed natively (docs/packaging.md).

## Login never completes

Start it from the desktop app (Settings → Account → Sign in) or the CLI
(`astraea-service auth login`) — both open the same browser bridge.

- The browser must have a NIP-07 extension (Alby, nos2x, …); the login
  page says so explicitly if `window.nostr` is missing.
- The session expires after 5 minutes; the app's waiting dialog says so and
  lets you retry, or run `astraea-service auth login` again.
- Corporate browsers that block loopback HTTP will break the flow; check
  the printed `http://127.0.0.1:<port>/login?...` opens at all (the app's
  dialog has an "Open again" button for this).
- Signed in but sync stays parked (`pending_signature`)? Browser login only
  proves identity — background signing needs a delegated key:
  `astraea-service auth provision-key` (never through the GUI or D-Bus —
  the key is typed once into a terminal and stored only in the Secret
  Service, docs/authentication.md).

## Events stay "pending"

`astraea-service status` (or the GUI status tile) explains which case:

- **No relays configured** — set them once from the app, or:
  ```sh
  busctl --user call com.lwb89dev.Astraea.Service /com/lwb89dev/Astraea \
    com.lwb89dev.Astraea.Calendar1 UpdateSettings \
    s '{"relays":["wss://relay.damus.io","wss://nos.lol"]}'
  ```
- **`pending_signature`** — the active signer is interactive-only
  (browser). Provision a calendar signing key
  (`astraea-service auth provision-key`) or wait for NIP-46 support.
- **A relay keeps rejecting** — an event is synced only when *every*
  configured relay accepts it; `GetSyncStatus` lists per-relay state.
  Remove the dead relay from settings if it is gone for good.
- **Offline** — expected; the queue drains automatically on reconnect
  (exponential backoff, nothing is dropped).

## Secret Service errors on login/provision

Install and unlock a keyring: GNOME Keyring (usually present on GNOME) or
KWallet with the Secret Service bridge. `astraea-service doctor` checks
availability. Calendar browsing works without one; signing does not.

## GNOME extension not showing

```sh
gnome-extensions list | grep astraea
gnome-extensions enable astraea@lwb89dev
```

After GNOME upgrades, check `shell-version` in the extension's
`metadata.json` covers your shell (45–48 today). The extension logs to
`journalctl --user /usr/bin/gnome-shell`.

## Database problems

Migrations back up the database automatically first
(`astraea.db.backup-v<N>` next to it). An unreadable database is
quarantined, a fresh one is created, and the next sync repopulates it from
the relays (events live encrypted there). Paths: `astraea-service
diagnostics`.

## Deep links do nothing

`xdg-open astraea://calendar/day/2026-07-20` should focus/start the app.
If not: `update-desktop-database` must have run (package postinst does),
and `xdg-mime query default x-scheme-handler/astraea` should print
`com.lwb89dev.Astraea.desktop`.

## Filing a bug

Attach `astraea-service diagnostics` output (it contains no secrets) and
the journal excerpt around the failure.
