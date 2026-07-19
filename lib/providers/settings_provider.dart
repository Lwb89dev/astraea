import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';
import 'events_provider.dart';
import 'service_providers.dart';

/// App settings (relay list, home/backup relay, display timezone,
/// notifications toggle), loaded from local storage and persisted on change.
class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    developer.log('SettingsNotifier.build called', name: 'SettingsNotifier');
    return ref.read(localStorageServiceProvider).loadSettings();
  }

  Future<void> save(AppSettings settings) async {
    developer.log('SettingsNotifier.save called', name: 'SettingsNotifier');
    final previous = state.value;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(localStorageServiceProvider).saveSettings(settings);
      return settings;
    });
    if (!state.hasValue) return;

    // The reminders toggle has to act on the alarms already handed to the OS,
    // not just on future ones: turning it off must clear what's pending, and
    // turning it back on must re-schedule everything. Nothing else observes
    // this, so it's driven from here rather than from the UI.
    if (previous != null &&
        previous.notificationsEnabled != settings.notificationsEnabled) {
      final notifications = ref.read(notificationServiceProvider);
      if (settings.notificationsEnabled) {
        await notifications.rescheduleAll(
          ref.read(eventsProvider).value ?? const [],
        );
      } else {
        await notifications.cancelAll();
      }
    }
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
