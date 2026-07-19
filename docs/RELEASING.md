# Releasing Astraea for Android

This checklist deliberately separates public source preparation from signing.
Signing secrets must never enter the repository.

## One-time decisions

Before the first public build:

1. Replace the development application ID `com.example.epochs` with an owned,
   permanent reverse-DNS identifier.
2. Align the Android namespace, Kotlin package paths, widget provider class
   names and privacy method-channel name with the chosen namespace.
3. Create a dedicated release keystore and store it outside the repository.
4. Back up the keystore, alias and passwords in a protected recovery location.

The application ID and signing certificate are permanent upgrade identities.
Changing either after release prevents normal in-place updates.

## Signing configuration

Copy the tracked template without committing the result:

```bash
cp android/key.properties.example android/key.properties
```

Point `storeFile` at the protected keystore and fill in the four required
values. `android/key.properties`, `*.jks` and related formats are ignored by
Git. Release Gradle tasks fail if any signing value or the keystore is missing;
there is no debug-key fallback.

In CI, generate `android/key.properties` at build time from secret variables
and decode the keystore into an ephemeral workspace path. Do not print values
or upload the keystore as a build artifact.

## Release checklist

1. Update `version:` in `pubspec.yaml` and the release date in `CHANGELOG.md`.
2. Review `git status` and `git diff --staged` for secrets and local metadata.
3. Run:

   ```bash
   dart format --output=none --set-exit-if-changed lib test
   flutter pub get --enforce-lockfile
   flutter analyze
   flutter test
   flutter build appbundle --release
   ```

4. Test onboarding, offline use, local-key sync, Amber sync, reminders, reboot
   restoration, import/export and all three widget sizes on a physical device.
5. Verify the final manifest, application ID, version and signing certificate.
6. Archive mapping/symbol files privately when obfuscation is enabled.
7. Tag the exact reviewed commit and attach only intended public artifacts.

## Suggested Git commands

```bash
git tag -s v0.1.0 -m "Astraea 0.1.0"
git push origin v0.1.0
```

Use a signed tag when the maintainer's signing setup is available.
