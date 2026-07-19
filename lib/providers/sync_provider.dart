import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
/// Triggered on app open and manually from Settings; there is no background
/// polling — REQ subscriptions run only while the app is foregrounded.
class SyncNotifier extends Notifier<SyncState> {
  @override
  SyncState build() => const SyncState();

  /// Runs one sync cycle if the user is signed in, then refreshes events.
  Future<void> syncNow() async {
    developer.log('SyncNotifier.syncNow called', name: 'SyncNotifier');
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

    state = state.copyWith(status: SyncStatus.syncing, clearError: true);
    try {
      await ref
          .read(calendarSyncServiceProvider)
          .runSyncCycle(settings: settings, author: auth);
      ref.invalidate(eventsProvider);
      // Merged-in events carry reminders and belong on the home widgets too;
      // nothing else observes a sync, so both refresh here.
      final events = (await ref.read(localStorageServiceProvider).loadEvents())
          .where((e) => !e.deleted)
          .toList();
      await ref.read(notificationServiceProvider).rescheduleAll(events);
      await ref.read(homeWidgetServiceProvider).updateAll(events);
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
    }
  }
}

final syncProvider = NotifierProvider<SyncNotifier, SyncState>(
  SyncNotifier.new,
);
