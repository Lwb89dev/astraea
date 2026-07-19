import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'service_providers.dart';

/// Whether the first-run onboarding has been completed. This is deliberately
/// independent from account presence: Astraea is fully usable without a Nostr
/// identity, while signing in must not skip the relay-selection step.
class AppEntryNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    developer.log('AppEntryNotifier.build called', name: 'AppEntryNotifier');
    return ref.read(localStorageServiceProvider).hasEntered();
  }

  /// Completes onboarding and enters the calendar. Idempotent.
  Future<void> completeOnboarding() async {
    developer.log(
      'AppEntryNotifier.completeOnboarding called',
      name: 'AppEntryNotifier',
    );
    await ref.read(localStorageServiceProvider).setEntered();
    state = const AsyncData(true);
  }
}

final appEntryProvider = AsyncNotifierProvider<AppEntryNotifier, bool>(
  AppEntryNotifier.new,
);
