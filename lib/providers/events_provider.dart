import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/event_model.dart';
import '../utils/event_timestamp.dart';
import 'auth_provider.dart';
import 'service_providers.dart';
import 'settings_provider.dart';

/// The source-of-truth list of the user's calendar events (local tombstones
/// excluded from the exposed state). Offline-first: every mutation writes to
/// local storage first, (re)schedules reminders, then best-effort publishes
/// to the relays.
class EventsNotifier extends AsyncNotifier<List<Event>> {
  @override
  Future<List<Event>> build() async {
    developer.log('EventsNotifier.build called', name: 'EventsNotifier');
    final events = await ref.read(localStorageServiceProvider).loadEvents();
    return events.where((e) => !e.deleted).toList();
  }

  /// Creates or updates an event: local save → reschedule reminders →
  /// best-effort relay publish → refresh state.
  Future<void> upsert(Event event) async {
    developer.log(
      'EventsNotifier.upsert called: ${event.id}',
      name: 'EventsNotifier',
    );
    // Nostr replaceable-event ordering has one-second resolution. Ensure two
    // rapid saves never publish with the same created_at and let a relay retain
    // an arbitrary older version.
    final updatedAt = nextEventTimestamp(event.updatedAt);
    final stamped = event.copyWith(synced: false, updatedAt: updatedAt);
    await ref.read(localStorageServiceProvider).saveEvent(stamped);
    await ref.read(notificationServiceProvider).scheduleForEvent(stamped);
    await _publish(stamped);
    await _refresh();
  }

  /// Deletes an event: cancels its reminders, writes a local tombstone, and
  /// best-effort publishes a NIP-09 deletion.
  Future<void> delete(Event event) async {
    developer.log(
      'EventsNotifier.delete called: ${event.id}',
      name: 'EventsNotifier',
    );
    final tombstone = event.copyWith(
      deleted: true,
      synced: false,
      // A rapid edit→delete must still produce a newer replaceable event.
      updatedAt: nextEventTimestamp(event.updatedAt),
    );
    await ref.read(localStorageServiceProvider).saveEvent(tombstone);
    await ref.read(notificationServiceProvider).cancelForEvent(event.id);

    final auth = ref.read(authProvider).value;
    final settings = ref.read(settingsProvider).value;
    final owner = tombstone.syncOwnerPubkey;
    if (auth != null &&
        settings != null &&
        (owner == null || owner == auth.publicKeyHex)) {
      try {
        await ref
            .read(calendarSyncServiceProvider)
            .deleteEvent(tombstone, settings: settings, author: auth);
      } catch (e) {
        // Offline (or local-only with no account) / relay error: the local
        // tombstone stays unsynced and the next sync cycle retries it.
        developer.log(
          'Deletion publish failed for ${event.id}: $e',
          name: 'EventsNotifier',
        );
      }
    }
    await _refresh();
  }

  /// Imports events from a plain `.ics` or an encrypted export (see
  /// [LocalStorageService.importEventsFromIcs]), then refreshes. Imported
  /// events are unsynced, so the next sync cycle publishes them. Returns how
  /// many were written.
  Future<int> importFromIcs(
    String raw, {
    String? password,
    required String defaultTimezone,
  }) async {
    developer.log(
      'EventsNotifier.importFromIcs called',
      name: 'EventsNotifier',
    );
    final written = await ref
        .read(localStorageServiceProvider)
        .importEventsFromIcs(
          raw,
          password: password,
          defaultTimezone: defaultTimezone,
        );
    await _refresh();
    // Imported events carry their own reminders — get them onto the OS.
    final notifications = ref.read(notificationServiceProvider);
    for (final event in state.value ?? const <Event>[]) {
      await notifications.scheduleForEvent(event);
    }
    return written;
  }

  Future<void> _publish(Event event) async {
    final auth = ref.read(authProvider).value;
    final settings = ref.read(settingsProvider).value;
    if (auth == null || settings == null) return; // Local-only / no account.
    final owner = event.syncOwnerPubkey;
    if (owner != null && owner != auth.publicKeyHex) {
      developer.log(
        'Skipped publish for ${event.id}: it belongs to another sync account',
        name: 'EventsNotifier',
      );
      return;
    }
    try {
      await ref
          .read(calendarSyncServiceProvider)
          .publishEvent(event, settings: settings, author: auth);
    } catch (e) {
      // Offline or relay error: the event is already saved locally and stays
      // synced == false, so the next sync cycle retries publishing it.
      developer.log(
        'Publish failed for ${event.id}: $e',
        name: 'EventsNotifier',
      );
    }
  }

  Future<void> _refresh() async {
    final events = await ref.read(localStorageServiceProvider).loadEvents();
    final visible = events.where((e) => !e.deleted).toList();
    state = AsyncData(visible);
    // Keep the home-screen widgets in step with every change. Best-effort:
    // HomeWidgetService swallows its own failures, so a widget that can't be
    // redrawn never breaks the mutation that triggered this.
    await ref.read(homeWidgetServiceProvider).updateAll(visible);
  }
}

final eventsProvider = AsyncNotifierProvider<EventsNotifier, List<Event>>(
  EventsNotifier.new,
);
