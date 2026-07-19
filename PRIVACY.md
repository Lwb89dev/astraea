# Astraea privacy policy

Last updated: 19 July 2026

Astraea is designed to work without a central service. This policy describes
what the application stores and when it communicates with other systems.

## Data stored on the device

Astraea stores calendar events, recurrence rules, reminder settings, relay
configuration and application preferences locally. Android home-screen widgets
receive a local cache of the occurrences they display. A locally held Nostr
private key is stored through the platform secure-storage facility; with Amber,
the private key remains in the external signer.

Android cloud backup is disabled for the application. Users may explicitly
export their calendar as a plain `.ics` file or as a password-encrypted Astraea
export. The user chooses where that file is saved and is responsible for its
protection.

## Network activity

Without a Nostr account, Astraea can be used locally. When sync is enabled, the
application connects only to relays selected by the user, plus documented
metadata relays when looking up the account's public profile. Calendar content
is NIP-44 encrypted before publication.

Nostr encryption protects event content, not transport metadata. A relay may
observe the public key, IP address, timestamps, event kinds, update frequency
and payload sizes. Relays are independent third parties with their own
retention and privacy practices.

If a public profile contains an avatar URL, Astraea may download that image over
HTTPS from the named host. Selecting the support option opens an external
Lightning wallet or copies the published Lightning address. These third-party
applications and hosts operate under their own policies.

## Analytics and advertising

Astraea does not include advertising, analytics SDKs, behavioral tracking or a
developer-operated telemetry backend.

## Notifications and permissions

Reminder notifications are scheduled locally by the operating system. Android
may request notification and exact-alarm permissions. Internet access is used
for optional Nostr sync and public profile/avatar retrieval.

## Data deletion

Local events can be deleted in the app. For synchronized events, Astraea also
publishes an encrypted tombstone and a NIP-09 deletion request. Nostr relays are
independent and may retain data or ignore deletion requests. Removing the app
deletes its app-private local data according to the operating system's normal
uninstallation behavior.

## Changes

Material privacy changes will be documented in the repository changelog and in
an updated version of this policy.
