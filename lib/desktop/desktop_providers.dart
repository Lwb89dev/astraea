import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import '../providers/app_entry_provider.dart';
import '../providers/events_provider.dart';
import '../providers/service_providers.dart';
import 'dbus_calendar_client.dart';
import 'desktop_events_notifier.dart';

/// Riverpod wiring for the Linux desktop build (ADR-003): the same screens,
/// with the storage/sync backends swapped for D-Bus clients of the Astraea
/// background service.

final dbusCalendarClientProvider = Provider<DbusCalendarClient>((ref) {
  final client = DbusCalendarClient();
  ref.onDispose(client.close);
  return client;
});

/// Decrypts mobile-format encrypted .ics export envelopes on desktop, reusing
/// the exact scheme in [ExportEncryptionService].
class DesktopExportDecryptor {
  DesktopExportDecryptor(this._ref);
  final Ref _ref;

  Future<String> decrypt(String raw, String password) async {
    final envelope = jsonDecode(raw) as Map<String, dynamic>;
    return _ref
        .read(exportEncryptionServiceProvider)
        .decryptWithPassword(envelope, password);
  }
}

final desktopExportDecryptorProvider = Provider<DesktopExportDecryptor>(
  DesktopExportDecryptor.new,
);

/// Health of the background service, refreshed on a slow timer (fallback)
/// and immediately on the signals that actually change it, and exposed to
/// the desktop shell's status bar. [ServiceUnavailableException] surfaces as
/// an error state the shell renders with recovery actions.
class ServiceStatusNotifier extends AsyncNotifier<Map<String, dynamic>> {
  Timer? _timer;
  List<StreamSubscription<void>>? _signals;

  @override
  Future<Map<String, dynamic>> build() async {
    final client = ref.watch(dbusCalendarClientProvider);
    _timer ??= Timer.periodic(const Duration(seconds: 60), (_) {
      ref.invalidateSelf();
    });
    _signals ??= [
      client.authenticationChanged().listen((_) => ref.invalidateSelf()),
      client.syncStatusChanged().listen((_) => ref.invalidateSelf()),
    ];
    ref.onDispose(() {
      _timer?.cancel();
      _timer = null;
      for (final sub in _signals ?? const <StreamSubscription<void>>[]) {
        sub.cancel();
      }
      _signals = null;
    });
    return client.getServiceStatus();
  }

  Future<void> retry() async {
    ref.invalidateSelf();
    await future;
  }
}

/// Live authentication status (`com.lwb89dev.NostrAccount1`), refreshed on
/// `AuthenticationChanged` — the browser login bridge completes
/// asynchronously (outside any D-Bus call), so polling would be laggy or
/// wasteful; the signal is the correct source of truth.
class DesktopAuthStatusNotifier extends AsyncNotifier<Map<String, dynamic>> {
  StreamSubscription<void>? _signal;

  @override
  Future<Map<String, dynamic>> build() async {
    final client = ref.watch(dbusCalendarClientProvider);
    _signal ??= client.authenticationChanged().listen(
      (_) => ref.invalidateSelf(),
    );
    ref.onDispose(() {
      _signal?.cancel();
      _signal = null;
    });
    return client.getAuthenticationStatus();
  }
}

final desktopAuthStatusProvider =
    AsyncNotifierProvider<DesktopAuthStatusNotifier, Map<String, dynamic>>(
      DesktopAuthStatusNotifier.new,
    );

/// Live sync status (`GetSyncStatus`/`SyncStatusChanged`) — state, pending/
/// failed counts, network status and per-relay health.
class DesktopSyncStatusNotifier extends AsyncNotifier<Map<String, dynamic>> {
  StreamSubscription<void>? _signal;

  @override
  Future<Map<String, dynamic>> build() async {
    final client = ref.watch(dbusCalendarClientProvider);
    _signal ??= client.syncStatusChanged().listen(
      (_) => ref.invalidateSelf(),
    );
    ref.onDispose(() {
      _signal?.cancel();
      _signal = null;
    });
    return client.getSyncStatus();
  }
}

final desktopSyncStatusProvider =
    AsyncNotifierProvider<DesktopSyncStatusNotifier, Map<String, dynamic>>(
      DesktopSyncStatusNotifier.new,
    );

/// The service-side relay list (`GetSettings`/`UpdateSettings`), refreshed on
/// `SettingsChanged` so a change from the CLI or another frontend is
/// reflected here too. This is the desktop's *only* relay configuration —
/// unlike mobile, Linux never keeps relay/identity state in the Flutter
/// process (ADR-004/006): it always belongs to astraea-service.
class DesktopRelaysNotifier extends AsyncNotifier<List<String>> {
  StreamSubscription<void>? _signal;

  @override
  Future<List<String>> build() async {
    final client = ref.watch(dbusCalendarClientProvider);
    _signal ??= client.settingsChanged().listen((_) => ref.invalidateSelf());
    ref.onDispose(() {
      _signal?.cancel();
      _signal = null;
    });
    final settings = await client.getSettings();
    final relays = settings['relays'];
    if (relays is! List) return const [];
    return relays.whereType<String>().toList(growable: false);
  }

  Future<void> save(List<String> relays) async {
    await ref.read(dbusCalendarClientProvider).updateSettings({
      'relays': relays,
    });
    ref.invalidateSelf();
    await future;
  }
}

final desktopRelaysProvider =
    AsyncNotifierProvider<DesktopRelaysNotifier, List<String>>(
      DesktopRelaysNotifier.new,
    );

final serviceStatusProvider =
    AsyncNotifierProvider<ServiceStatusNotifier, Map<String, dynamic>>(
      ServiceStatusNotifier.new,
    );

/// Calendars known by the service (sidebar), refreshed on CalendarsChanged.
class DesktopCalendarsNotifier
    extends AsyncNotifier<List<Map<String, dynamic>>> {
  StreamSubscription<void>? _signals;

  @override
  Future<List<Map<String, dynamic>>> build() async {
    final client = ref.watch(dbusCalendarClientProvider);
    _signals ??= client.calendarsChanged().listen((_) => ref.invalidateSelf());
    ref.onDispose(() {
      _signals?.cancel();
      _signals = null;
    });
    return client.getCalendars();
  }
}

final desktopCalendarsProvider =
    AsyncNotifierProvider<DesktopCalendarsNotifier, List<Map<String, dynamic>>>(
      DesktopCalendarsNotifier.new,
    );

/// Desktop skips the mobile onboarding: there is no local relay/key setup —
/// identity and relays belong to the background service (phase 6).
class _DesktopAppEntryNotifier extends AppEntryNotifier {
  @override
  Future<bool> build() async => true;
}

/// The provider overrides that turn the shared app into the desktop client.
List<Override> desktopOverrides() => [
  eventsProvider.overrideWith(DesktopEventsNotifier.new),
  appEntryProvider.overrideWith(_DesktopAppEntryNotifier.new),
];
