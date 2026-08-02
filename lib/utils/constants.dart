/// App-wide constants shared across services/providers/UI.
class AppConstants {
  AppConstants._();

  static const String appName = 'Astraea';

  // ---------------------------------------------------------------------
  // Nostr event kinds
  // ---------------------------------------------------------------------

  /// Nostr kind used for encrypted calendar events. 30078 = "Application-
  /// specific Data" (parameterized replaceable event, NIP-78): the relay
  /// keeps only the latest version per `d` tag, so updating an event =
  /// republishing the same `d` tag. Each Astraea event JSON is NIP-44
  /// self-encrypted (conversation key with the user's own keypair) before
  /// being placed in `content`.
  static const int calendarEventKind = 30078;

  /// NIP-09 event deletion request kind, used to retract a calendar event
  /// from the relays. Relays may ignore deletion requests, so deletion is
  /// also tracked with a local `deleted` flag (see [CalendarSyncService]).
  static const int deletionEventKind = 5;

  /// The `d`-tag prefix that scopes our parameterized replaceable events to
  /// Astraea, so the sync REQ can filter to just this app's data
  /// (`#d` values starting with this) and ignore other kind-30078 apps
  /// sharing the same keypair. Full tag remains `epochs:<event-uuid>` for
  /// wire compatibility with calendars created before the Astraea rename.
  static const String dTagPrefix = 'epochs:';

  // ---------------------------------------------------------------------
  // Default relays
  // ---------------------------------------------------------------------

  /// The implicit relay set for installations that chose relays before this
  /// list existed (see [LocalStorageService.loadSettings]) — must stay
  /// exactly what it always was, or an in-place app update would silently
  /// start talking to relay operators the user never actually chose.
  static const List<String> defaultRelays = [
    'wss://nos.lol',
    'wss://relay.damus.io',
  ];

  /// Public relays suggested during onboarding and in Settings. They are
  /// deliberately not selected on the user's behalf — each is only added if
  /// the user taps it — since choosing a relay reveals the user's IP address
  /// and Nostr public key to its operator. A longer list than
  /// [defaultRelays] on purpose: redundancy against any one of them being
  /// slow or temporarily unreachable.
  static const List<String> suggestedRelays = [
    ...defaultRelays,
    'wss://relay.primal.net',
    'wss://relay.nostr.band',
    'wss://nostr.mom',
    'wss://relay.snort.social',
  ];

  /// Well-known metadata-oriented relays always queried (in addition to the
  /// user's own) when fetching the account's public kind-0 profile. The user's
  /// relays are chosen for *event storage*: there's no reason to expect they
  /// also carry a profile that was very likely published by a different Nostr
  /// client to that client's own defaults.
  static const List<String> profileMetadataFallbackRelayUrls = [
    'wss://relay.damus.io',
    'wss://nos.lol',
    'wss://purplepag.es',
  ];

  /// The developer's Lightning address, offered in Settings > Support.
  static const String lightningAddress = 'lwb89@blink.sv';

  // ---------------------------------------------------------------------
  // SharedPreferences keys (non-sensitive settings)
  // ---------------------------------------------------------------------

  // These persisted values intentionally retain their historical `epochs.*`
  // names. Renaming them would log users out and hide local calendars after an
  // in-place app update.
  static const String prefsRelaysKey = 'epochs.relays';
  static const String prefsHomeRelayKey = 'epochs.home_relay';
  static const String prefsPublicKeyKey = 'epochs.pubkey';
  static const String prefsLoginMethodKey = 'epochs.login_method';
  static const String prefsTimezoneKey = 'epochs.timezone';
  static const String prefsNotificationsEnabledKey =
      'epochs.notifications_enabled';

  /// IETF BCP-47 tag ("it", "pt-BR" is not used here — the supported set is
  /// flat language codes, see AppLocalizations.supportedLocales). Null/absent
  /// means "follow the system language".
  static const String prefsLocaleKey = 'astraea.locale';

  /// [AppAccent.prefsValue]. Null/absent means the default (navy).
  static const String prefsAccentKey = 'astraea.accent';

  /// Last-fetched profile metadata (name/avatar URL) for the signed-in
  /// account, so Settings shows something immediately on launch instead of a
  /// blank state while [ProfileNotifier] re-fetches from the relays.
  static const String prefsProfileCacheKey = 'epochs.profile_cache';

  /// Set once first-run onboarding is complete. The historical key name is
  /// retained so upgrades do not show onboarding again to existing users.
  static const String prefsEnteredKey = 'epochs.entered';

  /// Maps an event id to the OS notification ids currently scheduled for it,
  /// so they can be cancelled exactly (across app restarts) when the event is
  /// edited or deleted — deriving ids from a hash of the event id instead
  /// would risk collisions between events.
  static const String prefsNotificationIdsKey = 'epochs.notification_ids';

  /// Monotonic allocator for the ids above.
  static const String prefsNotificationNextIdKey =
      'epochs.notification_next_id';

  /// flutter_secure_storage key for the account private key (nsec/hex).
  /// The legacy value is part of the on-device data migration contract.
  static const String secureStoragePrivateKeyKey = 'epochs.privkey';

  /// flutter_secure_storage key for the NIP-46 remote-signer session JSON
  /// (ephemeral client key + bunker secret + signer/relay coordinates). It is
  /// secret material — the client key authorizes this device against the
  /// user's signer — so it lives beside the private key, never in
  /// SharedPreferences.
  static const String secureStorageRemoteSignerKey = 'astraea.nip46_session';

  /// Name of the Hive box that holds the calendar events. Kept stable across
  /// the Astraea rename so existing calendars remain available.
  static const String eventsBoxName = 'epochs_events';

  // ---------------------------------------------------------------------
  // Notifications
  // ---------------------------------------------------------------------

  /// Android notification channel for scheduled event reminders. Channel IDs
  /// are immutable on Android, so this historical id must remain stable.
  static const String reminderChannelId = 'epochs.reminders';
  static const String reminderChannelName = 'Event reminders';
  static const String reminderChannelDescription =
      'Scheduled reminders for your upcoming calendar events.';

  // ---------------------------------------------------------------------
  // Sync
  // ---------------------------------------------------------------------

  /// Upper bound on how long a REQ waits for stored events before the
  /// relay's EOSE ("end of stored events"), after which we treat the
  /// initial fetch as complete even if a slow relay never sent EOSE.
  static const Duration syncEoseTimeout = Duration(seconds: 10);

  /// Upper bound on how long we wait for a NIP-46 remote signer to answer one
  /// request. Generous on purpose: a bunker typically has to wake the user's
  /// phone and show an approval prompt. Without it a silent signer would hang
  /// the calling screen indefinitely.
  static const Duration remoteSignerRequestTimeout = Duration(seconds: 90);

  /// Upper bound on how long we wait for Amber to respond to a request
  /// (get_public_key, sign_event, nip44_*). `amberflutter`'s Android side
  /// only resolves the method channel on RESULT_OK: if the user cancels in
  /// Amber it never resolves or rejects, so this timeout is our only way to
  /// recover from a hung request (same rationale as Echoes).
  static const Duration amberInteractionTimeout = Duration(seconds: 60);
}
