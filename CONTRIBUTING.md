# Contributing to Astraea

Thank you for helping improve Astraea. Contributions should preserve its core
properties: offline-first behavior, explicit network use, authenticated
encryption and safe handling of calendar data.

## Before opening an issue

- Search existing issues first.
- Use the bug template for reproducible defects.
- Use the feature template for product proposals and describe the privacy
  impact of any new network, storage or permission requirement.
- Report vulnerabilities privately as described in [SECURITY.md](SECURITY.md).

## Development setup

Install Flutter stable, JDK 17 and the Android toolchain, then run:

```bash
flutter pub get --enforce-lockfile
flutter analyze
flutter test
flutter run
```

Do not add real keys, calendar exports, signing files, service credentials or
machine-specific configuration to the repository.

## Pull requests

Keep changes focused and explain both the user-visible behavior and the design
trade-offs. A pull request should:

- format changed Dart files with `dart format`;
- pass `bash tool/check_repository_hygiene.sh`;
- pass `flutter analyze` and `flutter test`;
- add or update tests for changed behavior;
- preserve local writes before network operations;
- validate all relay and file input at the trust boundary;
- avoid logging private keys, decrypted event data or calendar contents;
- update README, architecture, privacy or changelog documentation when needed.

Major dependency upgrades should be isolated from feature work and include an
Android build. Cryptographic changes require official vectors or independently
verifiable fixtures.

## Style

- Follow `analysis_options.yaml` and `.editorconfig`.
- Prefer small, composable widgets and services with explicit responsibilities.
- Keep protocol and security rationale near the code that enforces it.
- Use UTC for persisted instants and convert only at display/scheduling edges.

## Commit hygiene

Use clear imperative subjects, for example `Fix recurring reminder rollover`.
Do not include generated editor metadata, local paths, private work logs or
secret material in commits. Review `git diff --staged` before every push.

By contributing, you agree that your work is licensed under GPL-3.0-or-later.
