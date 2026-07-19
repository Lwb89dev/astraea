import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'providers/app_entry_provider.dart';
import 'providers/events_provider.dart';
import 'providers/service_providers.dart';
import 'providers/theme_provider.dart';
import 'screens/calendar_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/widgets/widget_launch_handler.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the IANA timezone database and set the device's local zone,
  // so all UTC↔local conversions (display + reminder scheduling) are correct.
  await _initTimezones();

  // Read the persisted theme before the first frame so it can be seeded into
  // the container below and the app never flashes the wrong theme.
  final initialThemeMode = await ThemeModeNotifier.loadInitialThemeMode();

  // Manually created container (instead of a bare ProviderScope) so the Hive
  // box and the notification channel are ready *before* the first frame,
  // avoiding a race on startup reads.
  final container = ProviderContainer(
    overrides: [
      themeModeProvider.overrideWith(() => ThemeModeNotifier(initialThemeMode)),
    ],
  );
  await container.read(localStorageServiceProvider).init();
  await container.read(notificationServiceProvider).init();

  runApp(
    UncontrolledProviderScope(container: container, child: const AstraeaApp()),
  );

  // Deliberately not awaited: neither of these needs to block the first frame.
  unawaited(_refreshBackgroundState(container));
}

/// Startup housekeeping that has no UI of its own.
///
/// Reminders are only ever scheduled a bounded window ahead (see
/// [NotificationService]), so every app open rolls that window forward; the
/// home-screen widgets get the same treatment, since the day may well have
/// rolled over since they were last drawn.
Future<void> _refreshBackgroundState(ProviderContainer container) async {
  try {
    final events = await container.read(eventsProvider.future);
    await container.read(notificationServiceProvider).rescheduleAll(events);
    await container.read(homeWidgetServiceProvider).updateAll(events);
  } catch (error, stackTrace) {
    developer.log(
      'Startup refresh failed',
      name: 'main',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

Future<void> _initTimezones() async {
  tzdata.initializeTimeZones();
  try {
    final localName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localName));
    developer.log('Local timezone set to $localName', name: 'main');
  } catch (error) {
    // Fall back to UTC if the device zone can't be resolved — display stays
    // consistent, just not localized to the device offset.
    developer.log(
      'Failed to resolve local timezone, defaulting to UTC',
      name: 'main',
      error: error,
    );
    tz.setLocalLocation(tz.getLocation('UTC'));
  }
}

class AstraeaApp extends ConsumerWidget {
  const AstraeaApp({super.key});

  /// Brand seed color for both light and dark schemes.
  static const _brandSeed = Color(0xFF3F51B5);

  /// Lets [WidgetLaunchHandler] push a screen for a home-widget tap, which can
  /// arrive before any screen's context exists.
  static final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      // GrapheneOS/privacy-friendly default: dark theme (see
      // [ThemeModeNotifier]) — light is available from Settings.
      themeMode: themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _brandSeed,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _brandSeed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: WidgetLaunchHandler(
        navigatorKey: _navigatorKey,
        child: const _AppRoot(),
      ),
    );
  }
}

/// Routes between first-run onboarding and the calendar. The completion flag
/// is independent from account presence because Astraea remains fully usable
/// in local-only mode.
class _AppRoot extends ConsumerWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entered = ref.watch(appEntryProvider);
    return entered.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const OnboardingScreen(),
      data: (hasEntered) =>
          hasEntered ? const CalendarScreen() : const OnboardingScreen(),
    );
  }
}
