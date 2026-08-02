import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import 'auth_provider.dart';
import 'events_provider.dart';
import 'service_providers.dart';
import 'settings_provider.dart';

/// Where a sync cycle currently stands, for the small status affordance in
/// the calendar app bar / settings.
enum SyncStatus { idle, syncing, success, error }

class SyncState {
  final SyncStatus status;
  final DateTime? lastSyncedAt;
  final String? errorMessage;

  const SyncState({
    this.status = SyncStatus.idle,
    this.lastSyncedAt,
    this.errorMessage,
  });

  SyncState copyWith({
    SyncStatus? status,
    DateTime? lastSyncedAt,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SyncState(
      status: status ?? this.status,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Drives full sync cycles (pull-merge-push) and exposes their status.
/// Triggered once automatically at app start and manually from the calendar
/// app bar / Settings; there is no background polling — REQ subscriptions run
/// only while the app is foregrounded.
class SyncNotifier extends Notifier<SyncState> {
  /// Guards against overlapping cycles. Without it, the automatic start-up
  /// sync racing a user tap (or an impatient double tap) would run two full
  /// pull-merge-push passes at once: duplicated relay traffic, and two
  /// last-write-wins merges interleaving over the same Hive box.
  bool _inFlight = false;

  /// The automatic sync is a *start-up* action, not a "whenever the calendar
  /// screen mounts" action. Navigating back to the calendar must not re-fire
  /// it, so it is latched for the lifetime of the process.
  bool _startupSyncStarted = false;

  @override
  SyncState build() => const SyncState();

  /// Forces one sync cycle when the app opens, so the calendar is current
  /// before the user touches anything. Runs at most once per process, and
  /// never blocks the first frame — callers fire and forget.
  ///
  /// Sessions backed by Amber are deliberately excluded: NIP-55 signing is an
  /// Android intent into another app, so an automatic cycle would throw the
  /// user into Amber on every launch. Local keys and NIP-46 remote signers
  /// both complete without any user interaction, so they sync silently.
  Future<void> syncOnStartup() async {
    if (_startupSyncStarted) return;
    _startupSyncStarted = true;

    final method = ref.read(authProvider).value?.loginMethod;
    if (method == null || method == LoginMethod.amber) {
      developer.log(
        'SyncNotifier.syncOnStartup skipped (method: ${method?.name ?? 'none'})',
        name: 'SyncNotifier',
      );
      return;
    }
    await syncNow();
  }

  /// Runs one sync cycle if the user is signed in, then refreshes everything
  /// that derives from the event set (calendar, reminders, home widgets).
  Future<void> syncNow() async {
    developer.log('SyncNotifier.syncNow called', name: 'SyncNotifier');
    if (_inFlight) return;

    final auth = ref.read(authProvider).value;
    final settings = ref.read(settingsProvider).value;
    if (auth == null || settings == null) {
      developer.log(
        'SyncNotifier.syncNow skipped: no account (offline/local-only)',
        name: 'SyncNotifier',
      );
      return;
    }
    if (settings.allSyncRelays.isEmpty) {
      state = state.copyWith(
        status: SyncStatus.error,
        errorMessage: 'No relay configured. Add one in Settings.',
      );
      return;
    }

    _inFlight = true;
    state = state.copyWith(status: SyncStatus.syncing, clearError: true);
    try {
      await ref
          .read(calendarSyncServiceProvider)
          .runSyncCycle(settings: settings, author: auth);
      await _refreshDerivedState();
      state = state.copyWith(
        status: SyncStatus.success,
        lastSyncedAt: DateTime.now(),
      );
    } catch (error, stack) {
      developer.log(
        'SyncNotifier.syncNow failed',
        name: 'SyncNotifier',
        error: error,
        stackTrace: stack,
      );
      state = state.copyWith(
        status: SyncStatus.error,
        errorMessage: error.toString(),
      );
    } finally {
      _inFlight = false;
    }
  }

  /// Merged-in events carry reminders and belong on the home widgets too;
  /// nothing else observes a sync, so both are refreshed from here.
  Future<void> _refreshDerivedState() async {
    ref.invalidate(eventsProvider);
    final events = (await ref.read(localStorageServiceProvider).loadEvents())
        .where((e) => !e.deleted)
        .toList();
    await ref.read(notificationServiceProvider).rescheduleAll(events);
    await ref.read(homeWidgetServiceProvider).updateAll(events);
  }
}

final syncProvider = NotifierProvider<SyncNotifier, SyncState>(
  SyncNotifier.new,
);
