import 'dart:async';
import 'dart:developer' as developer;

import '../models/event_model.dart';
import '../providers/events_provider.dart';
import '../utils/ics.dart';
import 'desktop_providers.dart';

/// Linux-desktop replacement for [EventsNotifier]: every read and mutation
/// goes through the Astraea background service over D-Bus (ADR-003). The
/// Flutter process holds no calendar database of its own on desktop.
///
/// Registered via `eventsProvider.overrideWith(DesktopEventsNotifier.new)` in
/// desktop_providers.dart, so all screens keep using `eventsProvider`.
class DesktopEventsNotifier extends EventsNotifier {
  StreamSubscription<List<String>>? _signals;

  /// Wide load window: recurring series are stored as master events, so this
  /// captures everything a user can navigate to without paging.
  static const _windowBack = Duration(days: 365 * 10);
  static const _windowForward = Duration(days: 365 * 10);

  @override
  Future<List<Event>> build() async {
    final client = ref.watch(dbusCalendarClientProvider);

    // Refresh on service-side changes (another frontend, sync, the shell
    // extension…). The subscription lives as long as this notifier.
    _signals ??= client.eventsChanged().listen(
      (_) => ref.invalidateSelf(),
      onError: (Object e) =>
          developer.log('signal stream error: $e', name: 'DesktopEvents'),
    );
    ref.onDispose(() {
      _signals?.cancel();
      _signals = null;
    });

    final now = DateTime.now().toUtc();
    final events = await client.listEvents(
      startUtc: now.subtract(_windowBack),
      endUtc: now.add(_windowForward),
    );
    return events.where((e) => !e.deleted).toList();
  }

  @override
  Future<void> upsert(Event event) async {
    final client = ref.read(dbusCalendarClientProvider);
    final known = (state.value ?? const <Event>[]).any((e) => e.id == event.id);
    if (known) {
      await client.updateEvent(event);
    } else {
      await client.createEvent(event);
    }
    ref.invalidateSelf();
    await future;
  }

  @override
  Future<void> delete(Event event) async {
    await ref.read(dbusCalendarClientProvider).deleteEvent(event.id);
    ref.invalidateSelf();
    await future;
  }

  @override
  Future<int> importFromIcs(
    String raw, {
    String? password,
    required String defaultTimezone,
  }) async {
    if (password != null) {
      // Encrypted Astraea exports embed the mobile envelope; decrypt with the
      // same service the mobile path uses.
      final storage = ref.read(desktopExportDecryptorProvider);
      raw = await storage.decrypt(raw, password);
    }
    final incoming = IcsCodec.decode(raw, defaultTimezone: defaultTimezone);
    final client = ref.read(dbusCalendarClientProvider);
    final existing = {for (final e in state.value ?? const <Event>[]) e.id: e};
    var written = 0;
    for (final event in incoming) {
      final current = existing[event.id];
      if (current == null) {
        await client.createEvent(event);
        written++;
      } else if (event.updatedAt.isAfter(current.updatedAt)) {
        await client.updateEvent(event);
        written++;
      }
    }
    ref.invalidateSelf();
    await future;
    return written;
  }
}
