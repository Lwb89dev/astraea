# Linux packaging

Every format starts from one staged tree — `dist/stage/` with the final
`/usr` layout — produced by:

```sh
./scripts/build-linux.sh          # cargo release + flutter release + icons
./scripts/build-linux.sh --skip-flutter   # service + extension only
```

Layout (defined once, in that script):

| Path | Content | Package |
| --- | --- | --- |
| `/usr/libexec/astraea/astraea-service` | daemon + CLI | astraea-service |
| `/usr/lib/systemd/user/astraea.service` | user unit (hardened) | astraea-service |
| `/usr/share/dbus-1/services/com.lwb89dev.Astraea.Service.service` | D-Bus activation | astraea-service |
| `/usr/lib/astraea/` + `/usr/bin/astraea` | Flutter bundle + symlink | astraea-desktop |
| `/usr/share/applications`, `metainfo`, `icons/hicolor` | desktop entry, AppStream, icons | astraea-desktop |
| `/usr/share/gnome-shell/extensions/astraea@lwb89dev/` | GNOME extension | astraea-gnome-shell-extension |

## Modular packages

Traditional distros get three real packages so a KDE user installs Astraea
without the GNOME extension (and a headless box can run the service alone):

- **astraea-service** — everything else depends on it.
- **astraea-desktop** — `Depends: astraea-service (= version)`.
- **astraea-gnome-shell-extension** — `Depends: astraea-service`,
  `Recommends: astraea-desktop`.

A fourth, **astraea-all**, is an empty metapackage
(`Depends: astraea-service, astraea-desktop`,
`Recommends: astraea-gnome-shell-extension`) purely for one-command installs
— see `scripts/install-debs.sh` below. It carries no files; removing it
never removes the components it pulled in.

## Debian / Ubuntu / Pop!_OS

```sh
./scripts/build-deb.sh          # builds stage + the four .deb into dist/
./scripts/test-packages.sh      # structural checks + lintian when present
./scripts/install-debs.sh       # sudo apt install <all built .deb>, one call
```

`install-debs.sh` builds (unless `--no-build`) and installs every package
with a **single** `apt install` call. Modern APT (≥ 1.1 — every current
Debian/Ubuntu/Pop!_OS) resolves the `Depends` between local `.deb` files
given together in one invocation and installs them in dependency order
regardless of the order they were listed in — so "priority: service, then
app, then extension" is enforced by the packages' own `Depends`, not by the
script sequencing separate installs. `--no-extension` drops the GNOME
extension (and `astraea-all`, which recommends it) for KDE/COSMIC installs.
Equivalent by hand: `sudo apt install ./dist/astraea-service_*.deb
./dist/astraea-desktop_*.deb ./dist/astraea-gnome-shell-extension_*.deb
./dist/astraea-all_*.deb`.

For people who don't want to clone and build from source, `scripts/install-release.sh`
downloads the `.deb` assets from the latest (or `--tag TAG`) GitHub release and
installs them the same way. It verifies each download against the release's
`SHA256SUMS` asset when one was published, and — unlike `install-debs.sh`,
which just refuses to run without root — it explains why it needs sudo and
asks before invoking it, rather than escalating on its own.

Maintainer scripts only refresh the desktop/icon caches (guarded, `|| true`,
headless-safe); they never touch user homes and never enable services —
D-Bus activation makes enabling unnecessary.

## Fedora / RHEL / openSUSE

`packaging/rpm/astraea.spec` builds the three subpackages from the staged
tree (`Source0` is packed by the script — Fedora has no Flutter toolchain
package, so pretending to build Flutter inside rpmbuild would be fiction;
the spec owns layout, deps, validation):

```sh
./scripts/build-rpm.sh          # requires rpmbuild; runs rpmlint if present
```

openSUSE: the spec only uses cross-family macros (`%{_libexecdir}` is
`/usr/libexec` on Leap ≥ 15.4 and Tumbleweed). Validate with `rpmlint`.
SELinux: all paths are standard and policy-covered — nothing to disable.

## Arch Linux

`packaging/arch/PKGBUILD` is a source build (cargo `--locked` +
`flutter build linux`); `flutter` comes from the AUR. Arch has no
`/usr/libexec`, so the unit points at `/usr/lib/astraea`. Not published to
the AUR automatically; an `astraea-git` variant only needs a `pkgver()`.

```sh
cd packaging/arch && makepkg -si
```

## Flatpak

`packaging/flatpak/com.lwb89dev.Astraea.yml` ships the **GUI only**.
Trade-off, decided and documented:

- *Service inside the sandbox*: would need `--own-name`, a host-visible
  activation file (not possible from a Flatpak), Secret Service access and
  background permission; the GNOME extension and the CLI could not reach it
  reliably. Rejected.
- *Service outside (chosen)*: the Flatpak talks to the native service with
  exactly one bus grant (`--talk-name=com.lwb89dev.Astraea.Service`), no
  network, no filesystem holes, no `--filesystem=host`. Without the native
  service installed the GUI shows its recovery screen.

```sh
./scripts/build-linux.sh
flatpak-builder --user --install dist/flatpak-build packaging/flatpak/com.lwb89dev.Astraea.yml
```

## Tarball

```sh
./scripts/build-tarball.sh      # dist/astraea-<ver>-linux-<arch>.tar.gz + sha256
```

The tarball carries `install.sh`: `--prefix DIR` (default `/usr/local`),
`--user` (no root, wires systemd user + D-Bus activation into XDG paths),
`--dry-run`, and `--uninstall` driven by a recorded manifest
(`$XDG_STATE_HOME/astraea/install-manifest.txt`). Uninstall never deletes
user data.

## AppImage (optional)

`./scripts/build-appimage.sh` (requires `appimagetool`) packages the GUI
alone. An AppImage cannot install D-Bus activation, the user unit or the
shell extension — desktop integration needs a native package or the
tarball installer. It exists for trying the UI, nothing more.

## AppStream screenshots

`assets/appstream/…metainfo.xml` references
`docs/screenshots/linux-month.png` on the `main` branch; until real
captures are committed there, `appstreamcli validate` reports
`screenshot-image-not-found` — the one accepted warning
(`scripts/test-packages.sh` validates with `--no-net`).

## Distro test matrix (manual / CI containers)

For each of Ubuntu LTS, Debian stable, Fedora stable, openSUSE
Leap/Tumbleweed, Arch:

1. install the package(s) for that family;
2. `busctl --user call com.lwb89dev.Astraea.Service /com/lwb89dev/Astraea \
   com.lwb89dev.Astraea.Calendar1 GetVersion` (activation works);
3. `astraea-service diagnostics` (paths, D-Bus, database);
4. desktop entry appears; `xdg-open astraea://calendar/day/2026-07-20`
   reaches the app;
5. uninstall; verify no files left outside user data
   (`~/.local/share/astraea` must survive);
6. upgrade from the previous release; database migrates (backup is taken
   automatically before schema changes).
