import 'dart:developer' as developer;

import '../models/app_settings.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';
import 'local_storage_service.dart';
import 'nostr_service.dart';

/// Encrypted, offline-first sync of calendar events to Nostr relays
/// (including the optional personal/home relay as an extra backup target).
///
/// Orchestrates the local store and [NostrService]; the actual NIP-44
/// encryption + signing (local key or Amber) live in [NostrService], so this
/// layer is identity-agnostic — it just passes the signed-in [User] through.
///
/// Design:
///  - Each [Event] → NIP-44 self-encrypted → kind-30078 with `d` tag
///    `epochs:<id>` (parameterized replaceable: an edit republishes the same
///    `d` tag, and the relay keeps only the latest).
///  - Delete = NIP-09 deletion request + a local `deleted` tombstone (relays
///    may ignore deletions, so the local flag wins).
///  - Sync = REQ for the user's kind-30078 events with the `epochs:` `d`-tag
///    prefix, decrypt, merge last-write-wins on `updatedAt`, then push any
///    locally-unsynced events and pending deletions.
class CalendarSyncService {
  CalendarSyncService({
    required LocalStorageService localStorageService,
    required NostrService nostrService,
  }) : _localStorage = localStorageService,
       _nostr = nostrService;

  final LocalStorageService _localStorage;
  final NostrService _nostr;

  /// Encrypts and publishes a single event, then persists it as synced.
  Future<void> publishEvent(
    Event event, {
    required AppSettings settings,
    required User author,
  }) async {
    developer.log(
      'CalendarSyncService.publishEvent called: ${event.id}',
      name: 'CalendarSyncService',
    );
    final eventId = await _nostr.publishEvent(
      author: author,
      event: event,
      relayUrls: settings.allSyncRelays,
    );
    await _localStorage.saveEvent(
      event.copyWith(
        synced: true,
        nostrEventId: eventId,
        syncOwnerPubkey: author.publicKeyHex,
      ),
    );
  }

  /// Propagates a deletion. [event] must already be the local tombstone
  /// (`deleted: true`).
  ///
  /// Two mechanisms, deliberately redundant: the encrypted tombstone is
  /// republished under the same `d` tag (a replaceable event, so every relay
  /// overwrites the old content and every other device merges `deleted: true`
  /// on its next sync), and a NIP-09 deletion request asks relays to drop the
  /// preceding concrete version. NIP-09 alone is not enough — relays may ignore it, and
  /// then the other devices would happily resurrect the event.
  Future<void> deleteEvent(
    Event event, {
    required AppSettings settings,
    required User author,
  }) async {
    developer.log(
      'CalendarSyncService.deleteEvent called: ${event.id}',
      name: 'CalendarSyncService',
    );
    final relays = settings.allSyncRelays;
    final previousEventId = event.nostrEventId;
    final eventId = await _nostr.publishEvent(
      author: author,
      event: event,
      relayUrls: relays,
    );
    // Delete only the previous concrete version. Deleting the replaceable
    // coordinate (or the newly published id) would remove the encrypted
    // tombstone too, so another device could never learn the deletion.
    if (previousEventId != null) {
      await _nostr.publishDeletion(
        author: author,
        nostrEventId: previousEventId,
        relayUrls: relays,
      );
    }
    await _localStorage.saveEvent(
      event.copyWith(
        synced: true,
        nostrEventId: eventId,
        syncOwnerPubkey: author.publicKeyHex,
      ),
    );
  }

  /// Full sync cycle: pull + decrypt, merge last-write-wins by `updatedAt`,
  /// then push locally-unsynced events (and pending deletions). Returns how
  /// many local events changed.
  Future<int> runSyncCycle({
    required AppSettings settings,
    required User author,
  }) async {
    developer.log(
      'CalendarSyncService.runSyncCycle called',
      name: 'CalendarSyncService',
    );
    final relays = settings.allSyncRelays;

    final incoming = await _nostr.fetchEvents(
      author: author,
      relayUrls: relays,
    );

    final existingById = {
      for (final e in await _localStorage.loadEvents()) e.id: e,
    };
    var changed = 0;
    for (final event in incoming) {
      if (await mergeIncoming(event, existingById: existingById)) {
        existingById[event.id] = event;
        changed++;
      }
    }

    var pushFailures = 0;
    Object? lastPushError;
    for (final local in existingById.values) {
      if (local.synced) continue;
      final owner = local.syncOwnerPubkey;
      if (owner != null && owner != author.publicKeyHex) {
        developer.log(
          'Skipped event ${local.id}: it belongs to a different sync account',
          name: 'CalendarSyncService',
        );
        continue;
      }
      try {
        if (local.deleted) {
          await deleteEvent(local, settings: settings, author: author);
        } else {
          await publishEvent(local, settings: settings, author: author);
        }
      } catch (e) {
        pushFailures++;
        lastPushError = e;
        developer.log(
          'Failed to push event ${local.id}: $e',
          name: 'CalendarSyncService',
        );
        // Leave it unsynced; the next cycle retries it.
      }
    }
    if (pushFailures > 0) {
      throw StateError(
        'Could not publish $pushFailures event(s). Last error: $lastPushError',
      );
    }
    return changed;
  }

  /// Merges one decrypted incoming event into local storage using
  /// last-write-wins on [Event.updatedAt]. Returns whether local changed.
  Future<bool> mergeIncoming(
    Event incoming, {
    required Map<String, Event> existingById,
  }) async {
    final existing = existingById[incoming.id];
    if (existing == null || incoming.updatedAt.isAfter(existing.updatedAt)) {
      await _localStorage.saveEvent(incoming);
      return true;
    }
    return false;
  }
}
