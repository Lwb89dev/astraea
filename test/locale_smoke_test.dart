// Smoke test: instantiate every generated AppLocalizations subclass and
// call every getter/method once, to catch ICU-syntax or placeholder-count
// errors that only surface at runtime (gen-l10n's static checks don't
// evaluate plural branches).
import 'package:astraea/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every supported locale resolves and every message renders', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final l10n = lookupAppLocalizations(locale);
      // Plain getters.
      expect(
        l10n.appTitle,
        isNotEmpty,
        reason: '${locale.languageCode}.appTitle',
      );
      expect(l10n.cancel, isNotEmpty);
      expect(l10n.settingsTitle, isNotEmpty);
      // Placeholder methods.
      expect(l10n.couldNotLoadEvents('x'), contains('x'));
      expect(l10n.allDayLabel('D'), contains('D'));
      expect(l10n.recurrenceUntilLabel('R', 'D'), isNotEmpty);
      expect(l10n.couldNotSaveEvent('e'), isNotEmpty);
      // Plural methods across 0/1/2/5/11/22 to exercise every CLDR category
      // (one/two/few/many/other) that any of the 27 locales might select.
      for (final n in [0, 1, 2, 5, 11, 22]) {
        expect(
          l10n.reminderMinutesBefore(n),
          isNotEmpty,
          reason: '${locale.languageCode}.reminderMinutesBefore($n)',
        );
        expect(
          l10n.reminderHoursBefore(n),
          isNotEmpty,
          reason: '${locale.languageCode}.reminderHoursBefore($n)',
        );
        expect(
          l10n.reminderDaysBefore(n),
          isNotEmpty,
          reason: '${locale.languageCode}.reminderDaysBefore($n)',
        );
        expect(
          l10n.relaysConfiguredCount(n),
          isNotEmpty,
          reason: '${locale.languageCode}.relaysConfiguredCount($n)',
        );
        expect(
          l10n.importedEventCount(n),
          isNotEmpty,
          reason: '${locale.languageCode}.importedEventCount($n)',
        );
        expect(
          l10n.operationsFailingCount(n),
          isNotEmpty,
          reason: '${locale.languageCode}.operationsFailingCount($n)',
        );
        expect(
          l10n.pendingCount(n),
          isNotEmpty,
          reason: '${locale.languageCode}.pendingCount($n)',
        );
        expect(
          l10n.relaysConfiguredLabel(n),
          isNotEmpty,
          reason: '${locale.languageCode}.relaysConfiguredLabel($n)',
        );
      }
      expect(l10n.pendingFailingCount('3', '2'), isNotEmpty);
      expect(l10n.lastSyncedLabel('t'), isNotEmpty);
      expect(l10n.lastSyncFailedLabel('e'), isNotEmpty);
      expect(l10n.couldNotSignIn('e'), isNotEmpty);
      expect(l10n.couldNotLoadRelaySettings('e'), isNotEmpty);
      expect(l10n.somethingWentWrong('e'), isNotEmpty);
      expect(l10n.exportFailed('e'), isNotEmpty);
      expect(l10n.importFailed('e'), isNotEmpty);
      expect(l10n.followDeviceTimezoneWithName('Z'), isNotEmpty);
      expect(l10n.noLightningWalletFound('a'), isNotEmpty);
      expect(l10n.calendarsUnavailable('e'), isNotEmpty);
      expect(l10n.syncStatusLabel('s'), isNotEmpty);
      expect(l10n.syncPendingSuffix(3), isNotEmpty);
      expect(l10n.syncUnavailable('e'), isNotEmpty);
      expect(l10n.couldNotStartLogin('e'), isNotEmpty);
      expect(l10n.couldNotReachService('e'), isNotEmpty);
      expect(l10n.couldNotLoadSettings('e'), isNotEmpty);
    }
    // 27 = 24 EU official languages + zh + ja + ru.
    expect(AppLocalizations.supportedLocales.length, 27);
  });
}
