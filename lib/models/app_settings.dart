/// User-configurable app settings surfaced in [SettingsScreen]: the relay
/// list, an optional personal/home relay used as an additional sync backup,
/// the display timezone, and the master notifications toggle.
///
/// Persisted in SharedPreferences (non-sensitive) via [LocalStorageService].
class AppSettings {
  /// Public relays events are synced to/from.
  final List<String> relays;

  /// Optional personal/home relay URL used as an *additional* backup target
  /// (events are published here too). Null/empty means "not configured".
  final String? homeRelayUrl;

  /// IANA timezone name used for display. Null means "follow the device
  /// timezone" (resolved at startup via flutter_timezone).
  final String? timezone;

  /// Master switch for scheduling local reminder notifications.
  final bool notificationsEnabled;

  const AppSettings({
    this.relays = const [],
    this.homeRelayUrl,
    this.timezone,
    this.notificationsEnabled = true,
  });

  /// Every relay we should publish to: the public list plus the home relay
  /// (de-duplicated) when one is configured.
  List<String> get allSyncRelays {
    final home = homeRelayUrl?.trim();
    if (home == null || home.isEmpty) return relays;
    return {...relays, home}.toList();
  }

  AppSettings copyWith({
    List<String>? relays,
    String? homeRelayUrl,
    bool clearHomeRelay = false,
    String? timezone,
    bool clearTimezone = false,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      relays: relays ?? this.relays,
      homeRelayUrl: clearHomeRelay ? null : (homeRelayUrl ?? this.homeRelayUrl),
      timezone: clearTimezone ? null : (timezone ?? this.timezone),
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
