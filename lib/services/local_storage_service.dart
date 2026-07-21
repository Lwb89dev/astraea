import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/ics.dart';
import '../utils/relay_url.dart';
import 'export_encryption_service.dart';

/// Single facade for all local persistence: events (Hive), settings and the
/// relay/home-relay config (SharedPreferences), and the account private key
/// (flutter_secure_storage). Also owns event export/import (.ics).
///
/// Offline-first: every event write goes through here *before* being handed
/// to [CalendarSyncService] for relay publishing — the user must never lose
/// an event just because there is no network connection.
class LocalStorageService {
  LocalStorageService({
    required ExportEncryptionService exportEncryptionService,
  }) : _exportEncryption = exportEncryptionService;

  final ExportEncryptionService _exportEncryption;

  Box<Map>? _eventsBox;

  /// Must be called once at app startup, before any event read/write —
  /// typically in `main()` right after `WidgetsFlutterBinding.ensureInitialized()`.
  Future<void> init() async {
    developer.log(
      'LocalStorageService.init called',
      name: 'LocalStorageService',
    );
    await Hive.initFlutter();
    _eventsBox = await Hive.openBox<Map>(AppConstants.eventsBoxName);
  }

  Box<Map> get _requireEventsBox {
    final box = _eventsBox;
    if (box == null) {
      throw StateError('LocalStorageService.init() has not been called yet.');
    }
    return box;
  }

  // ---------------------------------------------------------------------
  // Events (Hive). Stored as JSON Maps (manual toJson/fromJson, no codegen).
  // ---------------------------------------------------------------------

  /// Returns all cached events (including local deletion tombstones, so the
  /// sync layer can reconcile them). Callers that render the calendar
  /// should filter out `deleted` events.
  Future<List<Event>> loadEvents() async {
    developer.log(
      'LocalStorageService.loadEvents called',
      name: 'LocalStorageService',
    );
    final box = _requireEventsBox;
    final events = <Event>[];
    for (final stored in box.values) {
      events.add(Event.fromJson(_asStringKeyedMap(stored)));
    }
    events.sort((a, b) => a.startTimeUtc.compareTo(b.startTimeUtc));
    return events;
  }

  /// Creates or updates an event in the local cache. Idempotent on [Event.id].
  Future<void> saveEvent(Event event) async {
    developer.log(
      'LocalStorageService.saveEvent called: ${event.id}',
      name: 'LocalStorageService',
    );
    await _requireEventsBox.put(event.id, event.toJson());
  }

  /// Hard-removes an event from the local cache. (Sync-aware deletion keeps
  /// a tombstone instead — see [CalendarSyncService.deleteEvent].)
  Future<void> deleteEvent(String eventId) async {
    developer.log(
      'LocalStorageService.deleteEvent called: $eventId',
      name: 'LocalStorageService',
    );
    await _requireEventsBox.delete(eventId);
  }

  /// Hive deserializes maps as `Map<dynamic, dynamic>`, including maps nested
  /// inside lists (for example event reminders). Normalize the complete value
  /// tree before handing it to the JSON factories.
  Map<String, dynamic> _asStringKeyedMap(Map<dynamic, dynamic> raw) {
    return raw.map(
      (key, value) => MapEntry(key.toString(), _normalizeStoredValue(value)),
    );
  }

  dynamic _normalizeStoredValue(dynamic value) {
    if (value is Map) {
      return _asStringKeyedMap(value);
    }
    if (value is List) {
      return value.map(_normalizeStoredValue).toList();
    }
    return value;
  }

  // ---------------------------------------------------------------------
  // Export / import (.ics — RFC 5545), optionally password-encrypted.
  // ---------------------------------------------------------------------

  /// Serializes the local events (deletion tombstones excluded) into an
  /// iCalendar document, for backup or transfer to another device/app.
  ///
  /// Without [password] the result is a plain, standards-compliant `.ics` any
  /// calendar app can open. With one, the .ics is encrypted (PBKDF2 +
  /// AES-256-GCM, see [ExportEncryptionService]) and wrapped in a JSON
  /// envelope instead: a calendar export is exactly as sensitive as every
  /// title, location and time it contains, so this is the option for files
  /// going into cloud storage. The trade-off is that only Astraea can read it
  /// back.
  Future<String> exportEventsAsIcs({String? password}) async {
    developer.log(
      'LocalStorageService.exportEventsAsIcs called',
      name: 'LocalStorageService',
    );
    final ics = IcsCodec.encode((await loadEvents()).where((e) => !e.deleted));

    if (password == null) return ics;

    final encrypted = await _exportEncryption.encryptWithPassword(
      ics,
      password,
    );
    return jsonEncode({
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'encrypted': true,
      ...encrypted,
    });
  }

  /// Peeks at an export (without decrypting) to tell whether
  /// [importEventsFromIcs] will need a password — lets the UI prompt upfront
  /// instead of failing once first. False for anything that isn't a
  /// recognizable encrypted envelope, including a plain .ics.
  static bool isExportEncrypted(String raw) {
    final trimmed = raw.trimLeft();
    if (!trimmed.startsWith('{')) return false;
    try {
      return (jsonDecode(trimmed) as Map<String, dynamic>)['encrypted'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Imports events from a plain `.ics` or an encrypted envelope produced by
  /// [exportEventsAsIcs]. [password] is required if (and only if) the export
  /// is encrypted — see [isExportEncrypted]; a wrong one surfaces as
  /// [SecretBoxAuthenticationError].
  ///
  /// Merges by [Event.id] with the same last-write-wins rule used for relay
  /// sync, so re-importing an old backup can't clobber newer local edits.
  /// Events from other apps get fresh ids (see [IcsCodec.decode]) and are
  /// always added. Returns how many events were actually written.
  Future<int> importEventsFromIcs(
    String raw, {
    String? password,
    required String defaultTimezone,
  }) async {
    developer.log(
      'LocalStorageService.importEventsFromIcs called',
      name: 'LocalStorageService',
    );
    final String ics;
    if (isExportEncrypted(raw)) {
      if (password == null) {
        throw StateError(
          'This export is encrypted: a password is required to import it.',
        );
      }
      final envelope = jsonDecode(raw) as Map<String, dynamic>;
      ics = await _exportEncryption.decryptWithPassword(envelope, password);
    } else {
      ics = raw;
    }

    final incoming = IcsCodec.decode(ics, defaultTimezone: defaultTimezone);
    final existingById = {for (final e in await loadEvents()) e.id: e};
    var written = 0;
    for (final event in incoming) {
      final existing = existingById[event.id];
      if (existing == null || event.updatedAt.isAfter(existing.updatedAt)) {
        await saveEvent(event);
        written++;
      }
    }
    return written;
  }

  // ---------------------------------------------------------------------
  // Account private key (flutter_secure_storage — NEVER plaintext prefs).
  // ---------------------------------------------------------------------

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> savePrivateKey(String privateKeyHex) async {
    developer.log(
      'LocalStorageService.savePrivateKey called',
      name: 'LocalStorageService',
    );
    await _secureStorage.write(
      key: AppConstants.secureStoragePrivateKeyKey,
      value: privateKeyHex,
    );
  }

  Future<String?> loadPrivateKey() async {
    developer.log(
      'LocalStorageService.loadPrivateKey called',
      name: 'LocalStorageService',
    );
    return _secureStorage.read(key: AppConstants.secureStoragePrivateKeyKey);
  }

  Future<void> clearPrivateKey() async {
    developer.log(
      'LocalStorageService.clearPrivateKey called',
      name: 'LocalStorageService',
    );
    await _secureStorage.delete(key: AppConstants.secureStoragePrivateKeyKey);
  }

  /// Clears the whole local session (private key + pubkey + login method).
  Future<void> clearSession() async {
    developer.log(
      'LocalStorageService.clearSession called',
      name: 'LocalStorageService',
    );
    await clearPrivateKey();
    final prefs = await _prefs;
    await prefs.remove(AppConstants.prefsPublicKeyKey);
    await prefs.remove(AppConstants.prefsLoginMethodKey);
  }

  /// One-time forward migration for events written before sync ownership was
  /// stored explicitly. A previously synced event necessarily belonged to the
  /// account that was persisted alongside it; offline/never-synced events stay
  /// unclaimed so linking an account can still upload them intentionally.
  Future<void> claimLegacySyncedEvents(String publicKeyHex) async {
    for (final event in await loadEvents()) {
      if (event.syncOwnerPubkey == null &&
          (event.synced || event.nostrEventId != null)) {
        await saveEvent(event.copyWith(syncOwnerPubkey: publicKeyHex));
      }
    }
  }

  // ---------------------------------------------------------------------
  // Public key + login method (SharedPreferences — the pubkey is public).
  // ---------------------------------------------------------------------

  Future<void> savePublicKey(String publicKeyHex) async {
    final prefs = await _prefs;
    await prefs.setString(AppConstants.prefsPublicKeyKey, publicKeyHex);
  }

  Future<String?> loadPublicKey() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.prefsPublicKeyKey);
  }

  Future<void> saveLoginMethod(LoginMethod method) async {
    final prefs = await _prefs;
    await prefs.setString(AppConstants.prefsLoginMethodKey, method.name);
  }

  Future<LoginMethod?> loadLoginMethod() async {
    final prefs = await _prefs;
    final raw = prefs.getString(AppConstants.prefsLoginMethodKey);
    if (raw == null) return null;
    try {
      return LoginMethod.values.byName(raw);
    } on ArgumentError {
      return null;
    }
  }

  // ---------------------------------------------------------------------
  // Onboarding completion flag. Kept separate from the account so a user can
  // finish in local-only mode and a successful login cannot skip relay setup.
  // ---------------------------------------------------------------------

  Future<bool> hasEntered() async {
    final prefs = await _prefs;
    return prefs.getBool(AppConstants.prefsEnteredKey) ?? false;
  }

  Future<void> setEntered() async {
    developer.log(
      'LocalStorageService.setEntered called',
      name: 'LocalStorageService',
    );
    final prefs = await _prefs;
    await prefs.setBool(AppConstants.prefsEnteredKey, true);
  }

  // ---------------------------------------------------------------------
  // App settings (relays, home relay, timezone, notifications toggle).
  // ---------------------------------------------------------------------

  Future<AppSettings> loadSettings() async {
    developer.log(
      'LocalStorageService.loadSettings called',
      name: 'LocalStorageService',
    );
    final prefs = await _prefs;
    final rawRelays = prefs.getString(AppConstants.prefsRelaysKey);
    // Before relay selection existed, a missing preference meant the two
    // built-in defaults. Preserve that behavior for upgraded installations,
    // while a genuinely fresh onboarding starts with no implicit selection.
    final relays = rawRelays == null && await hasEntered()
        ? AppConstants.defaultRelays
        : _decodeRelayUrls(rawRelays);
    return AppSettings(
      relays: relays,
      homeRelayUrl: prefs.getString(AppConstants.prefsHomeRelayKey),
      timezone: prefs.getString(AppConstants.prefsTimezoneKey),
      notificationsEnabled:
          prefs.getBool(AppConstants.prefsNotificationsEnabledKey) ?? true,
    );
  }

  /// Preferences can outlive several app versions and may be edited by
  /// backup/restore tools. Treat a malformed relay value as an empty choice
  /// instead of making the entire Settings provider (and sync) fail to load.
  List<String> _decodeRelayUrls(String? raw) {
    if (raw == null) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      final relays = <String>{};
      for (final value in decoded) {
        if (value is! String) continue;
        final normalized = normalizeRelayUrl(value);
        if (normalized != null) relays.add(normalized);
      }
      return relays.toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    developer.log(
      'LocalStorageService.saveSettings called',
      name: 'LocalStorageService',
    );
    final prefs = await _prefs;
    await prefs.setString(
      AppConstants.prefsRelaysKey,
      jsonEncode(settings.relays),
    );
    final home = settings.homeRelayUrl;
    if (home == null || home.isEmpty) {
      await prefs.remove(AppConstants.prefsHomeRelayKey);
    } else {
      await prefs.setString(AppConstants.prefsHomeRelayKey, home);
    }
    final tz = settings.timezone;
    if (tz == null || tz.isEmpty) {
      await prefs.remove(AppConstants.prefsTimezoneKey);
    } else {
      await prefs.setString(AppConstants.prefsTimezoneKey, tz);
    }
    await prefs.setBool(
      AppConstants.prefsNotificationsEnabledKey,
      settings.notificationsEnabled,
    );
  }

  // ---------------------------------------------------------------------
  // Scheduled-notification bookkeeping (SharedPreferences).
  //
  // [NotificationService] schedules one OS notification per (occurrence,
  // reminder), so an event owns a varying set of ids. Persisting the exact set
  // — rather than deriving ids from a hash of the event id — is what makes
  // cancel-on-edit/delete reliable across app restarts and collision-free
  // between events.
  // ---------------------------------------------------------------------

  Future<Map<String, List<int>>> _loadNotificationIdMap() async {
    final prefs = await _prefs;
    final raw = prefs.getString(AppConstants.prefsNotificationIdsKey);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (k, v) => MapEntry(k, (v as List<dynamic>).cast<int>()),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveNotificationIdMap(Map<String, List<int>> map) async {
    final prefs = await _prefs;
    await prefs.setString(
      AppConstants.prefsNotificationIdsKey,
      jsonEncode(map),
    );
  }

  /// The notification ids currently scheduled for [eventId] (empty if none).
  Future<List<int>> loadNotificationIds(String eventId) async {
    return (await _loadNotificationIdMap())[eventId] ?? const [];
  }

  Future<void> saveNotificationIds(String eventId, List<int> ids) async {
    final map = await _loadNotificationIdMap();
    if (ids.isEmpty) {
      map.remove(eventId);
    } else {
      map[eventId] = ids;
    }
    await _saveNotificationIdMap(map);
  }

  Future<void> clearNotificationIds(String eventId) =>
      saveNotificationIds(eventId, const []);

  /// Every scheduled id across all events — used to cancel everything when the
  /// reminders toggle is switched off.
  Future<List<int>> loadAllNotificationIds() async {
    final map = await _loadNotificationIdMap();
    return [for (final ids in map.values) ...ids];
  }

  Future<void> clearAllNotificationIds() async {
    final prefs = await _prefs;
    await prefs.remove(AppConstants.prefsNotificationIdsKey);
  }

  /// Allocates [count] fresh, never-before-used notification ids. Wraps well
  /// below 2^31 so the ids stay valid Android request codes.
  Future<List<int>> allocateNotificationIds(int count) async {
    final prefs = await _prefs;
    final next = prefs.getInt(AppConstants.prefsNotificationNextIdKey) ?? 1;
    final ids = [for (var i = 0; i < count; i++) (next + i) % 0x7FFFFFF];
    await prefs.setInt(
      AppConstants.prefsNotificationNextIdKey,
      (next + count) % 0x7FFFFFF,
    );
    return ids;
  }
}
