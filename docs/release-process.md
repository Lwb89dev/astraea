# Release process — Linux

Android has its own signing-focused checklist (docs/RELEASING.md). This
document covers the Linux artifacts. Nothing here publishes automatically;
every push to a store/AUR/repository is a deliberate manual act.

## Versioning

One version number, owned by `pubspec.yaml` (`version: X.Y.Z+build`).
Everything else must match its `X.Y.Z`:

- `native/service/Cargo.toml` and `native/cosmic-applet/Cargo.toml`
- `assets/appstream/com.lwb89dev.Astraea.metainfo.xml` (newest `<release>`)
- `packaging/rpm/astraea.spec` (`Version:`)
- `packaging/arch/PKGBUILD` (`pkgver=`)

`./scripts/check-versions.sh` enforces this (CI runs it; run it before
tagging). The GNOME extension is versioned by the extensions
infrastructure and deliberately carries no number in `metadata.json`.

## Cutting a release

1. `./scripts/check-versions.sh`
2. Full test pass:
   ```sh
   flutter analyze && flutter test
   cargo fmt --check --manifest-path native/service/Cargo.toml
   cargo clippy --all-targets --manifest-path native/service/Cargo.toml -- -D warnings
   cargo test --manifest-path native/service/Cargo.toml --all-targets
   cargo test --manifest-path native/cosmic-applet/Cargo.toml
   ```
3. Update the AppStream `<release>` entry (version, date, notes).
4. Build + validate artifacts:
   ```sh
   ./scripts/build-deb.sh && ./scripts/build-tarball.sh --no-build
   ./scripts/test-packages.sh
   ```
5. Distro matrix spot-check (docs/packaging.md, containers/VMs).
6. Tag `vX.Y.Z`, push the tag. The release workflow (dry-run by default)
   assembles: three .deb, tarball + sha256, SBOM. RPMs are built on a
   Fedora runner/container from the same staged tree.
7. Create the GitHub release from those artifacts with the checksums in
   the release notes. Only then, and manually: AUR update, extension
   upload to extensions.gnome.org, Flathub PR.

## Upgrade guarantees

- Package upgrades never touch `$XDG_DATA_HOME/astraea`; schema migrations
  run on next service start with an automatic pre-migration backup.
- Never reuse a version number; never force-push a release tag.
- D-Bus API breaking changes require bumping the interface name
  (`Calendar1` → `Calendar2`) and a deprecation window, not a silent change
  (ADR-002).
