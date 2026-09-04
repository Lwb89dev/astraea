import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/event_model.dart';
import '../services/kairos_local_service.dart';
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
  /// refresh (so the UI reflects the save immediately) → best-effort relay
  /// publish in the background.
  ///
  /// The publish is deliberately *not* awaited here: relay round-trips can
  /// take up to [AppConstants.syncEoseTimeout] each, and offline-first means
  /// the local save (already durable at this point) is what "saved"
  /// actually means — waiting on the network besides would make every save
  /// feel exactly as slow as the flakiest configured relay, for no benefit,
  /// since a publish failure already just leaves the event unsynced for the
  /// next sync cycle to retry.
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
    await _refresh();
    unawaited(_publishInBackground(stamped));
  }

  /// Imports one task handed over by Kairos on the same device. This path is
  /// separate from [upsert]: Kairos already owns the Nostr mirror, so Astraea
  /// must not republish the local hand-off as a second event.
  Future<Event> importKairosTask(String raw) async {
    final message = KairosLocalService.decode(raw);
    final incoming = message.event;
    final storage = ref.read(localStorageServiceProvider);
    final current = (await storage.loadEvents())
        .where((event) => event.id == incoming.id)
        .firstOrNull;

    if (message.operation == 'delete') {
      if (current == null || incoming.updatedAt.isAfter(current.updatedAt)) {
        final tombstone = (current ?? incoming).copyWith(
          deleted: true,
          synced: true,
          updatedAt: incoming.updatedAt,
        );
        await storage.saveEvent(tombstone);
        await ref.read(notificationServiceProvider).cancelForEvent(incoming.id);
        await _refresh();
        return tombstone;
      }
      await ref.read(notificationServiceProvider).cancelForEvent(incoming.id);
      return current;
    }

    if (current == null || incoming.updatedAt.isAfter(current.updatedAt)) {
      final imported = current == null
          ? incoming
          : incoming.copyWith(
              synced: true,
              deleted: false,
              // Preserve the Nostr coordinate if this task was already
              // received through a relay; the local hand-off only changes
              // the task fields.
              nostrEventId: current.nostrEventId,
              syncOwnerPubkey: current.syncOwnerPubkey,
            );
      final persisted = message.showNotification
          ? imported
          : imported.copyWith(reminders: const []);
      await storage.saveEvent(persisted);
      if (message.showNotification) {
        await ref.read(notificationServiceProvider).scheduleForEvent(persisted);
      } else {
        await ref
            .read(notificationServiceProvider)
            .cancelForEvent(persisted.id);
      }
      await _refresh();
      return persisted;
    }

    // Re-delivery is harmless but restores a missing OS alarm after a reboot
    // or permission change.
    if (message.showNotification) {
      await ref.read(notificationServiceProvider).scheduleForEvent(current);
    } else {
      await ref.read(notificationServiceProvider).cancelForEvent(current.id);
      if (current.reminders.isNotEmpty) {
        final withoutReminder = current.copyWith(reminders: const []);
        await storage.saveEvent(withoutReminder);
        await _refresh();
        return withoutReminder;
      }
    }
    return current;
  }

  /// Deletes an event: cancels its reminders, writes a local tombstone,
  /// refreshes, then best-effort publishes a NIP-09 deletion in the
  /// background — see [upsert]'s doc for why publishing isn't awaited here.
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
    await _refresh();
    unawaited(_publishDeletionInBackground(tombstone));
  }

  Future<void> _publishDeletionInBackground(Event tombstone) async {
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
          'Deletion publish failed for ${tombstone.id}: $e',
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

  Future<void> _publishInBackground(Event event) async {
    await _publish(event);
    await _refresh();
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
