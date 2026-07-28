import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart' as intl;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'desktop/desktop_bootstrap_stub.dart'
    if (dart.library.io) 'desktop/desktop_bootstrap.dart'
    as desktop;
import 'l10n/app_localizations.dart';
import 'providers/app_entry_provider.dart';
import 'providers/events_provider.dart';
import 'providers/service_providers.dart';
import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/calendar_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/widgets/widget_launch_handler.dart';
import 'utils/app_accent.dart';
import 'utils/constants.dart';

Future<void> main(List<String> args) async {
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
      // On Linux desktop the events backend is the astraea-service D-Bus API
      // (ADR-003); everywhere else this adds nothing.
      ...desktop.platformOverrides(),
    ],
  );
  await container.read(localStorageServiceProvider).init();
  if (!desktop.isLinuxDesktop) {
    // Mobile-only: on Linux, reminders/notifications belong to the
    // background service, not to the UI process.
    await container.read(notificationServiceProvider).init();
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: AstraeaApp(launchArgs: args),
    ),
  );

  // Deliberately not awaited: neither of these needs to block the first frame.
  if (!desktop.isLinuxDesktop) {
    unawaited(_refreshBackgroundState(container));
  }
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
  const AstraeaApp({super.key, this.launchArgs = const []});

  /// Process arguments, used on Linux desktop to receive the initial
  /// astraea:// deep link from the GTK runner.
  final List<String> launchArgs;

  /// Lets [WidgetLaunchHandler] push a screen for a home-widget tap, which can
  /// arrive before any screen's context exists.
  static final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final accent = AppAccent.fromPrefsValue(
      ref.watch(settingsProvider).value?.accent,
    );
    // Null (loading/error, or no explicit choice saved) means "follow the
    // system language" — MaterialApp's own default resolution against
    // supportedLocales, same fallback rule as the timezone setting.
    final localeTag = ref.watch(settingsProvider).value?.locale;
    final locale = localeTag == null ? null : Locale(localeTag);
    // Formatter's DateFormat calls take no explicit locale (mirrors intl's
    // own convention); this keeps them in step with the resolved app locale,
    // including the "follow system" case where Flutter itself resolves it.
    intl.Intl.defaultLocale =
        (locale ?? View.of(context).platformDispatcher.locale).toLanguageTag();

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      // GrapheneOS/privacy-friendly default: dark theme (see
      // [ThemeModeNotifier]) — light is available from Settings.
      themeMode: themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent.seed,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent.seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: desktop.isLinuxDesktop
          // Desktop: astraea:// deep links + desktop chrome. The Android
          // home-widget launch handler stays out of this path entirely.
          ? desktop.wrapHome(
              navigatorKey: _navigatorKey,
              launchArgs: launchArgs,
              child: const _AppRoot(),
            )
          : WidgetLaunchHandler(
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
