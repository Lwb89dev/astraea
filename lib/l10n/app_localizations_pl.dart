// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Astraea';

  @override
  String get cancel => 'Anuluj';

  @override
  String get save => 'Zapisz';

  @override
  String get delete => 'Usuń';

  @override
  String get continueLabel => 'Dalej';

  @override
  String get next => 'Dalej';

  @override
  String get back => 'Wstecz';

  @override
  String get loading => 'Ładowanie…';

  @override
  String get settingsTooltip => 'Ustawienia';

  @override
  String get newEventButton => 'Nowe wydarzenie';

  @override
  String couldNotLoadEvents(String error) {
    return 'Nie udało się wczytać wydarzeń:\n$error';
  }

  @override
  String get viewMonth => 'Miesiąc';

  @override
  String get viewWeek => 'Tydzień';

  @override
  String get viewDay => 'Dzień';

  @override
  String get viewList => 'Lista';

  @override
  String get noEventsToday => 'Brak wydarzeń tego dnia.';

  @override
  String get noUpcomingEvents =>
      'Brak nadchodzących wydarzeń w ciągu najbliższych 60 dni.';

  @override
  String get untitledEvent => '(bez tytułu)';

  @override
  String get allDay => 'Cały dzień';

  @override
  String get addAccountToSyncTooltip => 'Dodaj konto Nostr, aby synchronizować';

  @override
  String get syncNowTooltip => 'Synchronizuj teraz';

  @override
  String get addNostrAccountTitle => 'Dodaj konto Nostr';

  @override
  String get eventNotFound => 'Nie znaleziono wydarzenia.';

  @override
  String get eventAppBarTitle => 'Wydarzenie';

  @override
  String get editTooltip => 'Edytuj';

  @override
  String get deleteTooltip => 'Usuń';

  @override
  String allDayLabel(String date) {
    return '$date · Cały dzień';
  }

  @override
  String recurrenceUntilLabel(String recurrence, String date) {
    return '$recurrence · do $date';
  }

  @override
  String get syncedToRelays => 'Zsynchronizowane z przekaźnikami';

  @override
  String get notYetSynced => 'Jeszcze niezsynchronizowane';

  @override
  String get deleteEventTitle => 'Usunąć wydarzenie?';

  @override
  String get deleteEventBody =>
      'To usuwa wydarzenie z tego urządzenia i zgłasza żądanie usunięcia z przekaźników.';

  @override
  String get editEventTitle => 'Edytuj wydarzenie';

  @override
  String get newEventTitle => 'Nowe wydarzenie';

  @override
  String get fieldTitle => 'Tytuł';

  @override
  String get allDaySwitch => 'Cały dzień';

  @override
  String get startsLabel => 'Rozpoczyna się';

  @override
  String get endsLabel => 'Kończy się';

  @override
  String get timezoneLabel => 'Strefa czasowa';

  @override
  String get repeatsLabel => 'Powtarzanie';

  @override
  String get untilLabel => 'Do';

  @override
  String get foreverLabel => 'Zawsze';

  @override
  String get remindersLabel => 'Przypomnienia';

  @override
  String get addChip => 'Dodaj';

  @override
  String get colorLabel => 'Kolor';

  @override
  String get locationLabel => 'Lokalizacja';

  @override
  String get descriptionLabel => 'Opis';

  @override
  String couldNotSaveEvent(String error) {
    return 'Nie udało się zapisać wydarzenia: $error';
  }

  @override
  String get recurrenceNone => 'Nie powtarza się';

  @override
  String get recurrenceDaily => 'Codziennie';

  @override
  String get recurrenceWeekly => 'Co tydzień';

  @override
  String get recurrenceMonthly => 'Co miesiąc';

  @override
  String get recurrenceYearly => 'Co rok';

  @override
  String get reminderAtStart => 'Na początku';

  @override
  String reminderMinutesBefore(int count) {
    return '$count min wcześniej';
  }

  @override
  String reminderHoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count godziny wcześniej',
      many: '$count godzin wcześniej',
      few: '$count godziny wcześniej',
      one: '1 godzinę wcześniej',
    );
    return '$_temp0';
  }

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dnia wcześniej',
      many: '$count dni wcześniej',
      few: '$count dni wcześniej',
      one: '1 dzień wcześniej',
    );
    return '$_temp0';
  }

  @override
  String get getStarted => 'Rozpocznij';

  @override
  String get useOffline => 'Użyj offline';

  @override
  String get welcomeTitle => 'Witamy w Astraea';

  @override
  String get welcomeSubtitle =>
      'Prywatny kalendarz, offline w pierwszej kolejności, który pozostawia kontrolę tobie.';

  @override
  String get featureLocalTitle =>
      'Twój kalendarz pozostaje na twoim urządzeniu';

  @override
  String get featureLocalBody =>
      'Twórz wydarzenia, powtarzalności i przypomnienia bez konta czy połączenia z internetem.';

  @override
  String get featureSyncTitle => 'Opcjonalna synchronizacja przez Nostr';

  @override
  String get featureSyncBody =>
      'Połącz konto, aby utworzyć kopię zapasową kalendarza i używać go na wielu urządzeniach przez wybrane przez ciebie przekaźniki.';

  @override
  String get featureEncryptedTitle => 'Zawsze zaszyfrowane przed wysłaniem';

  @override
  String get featureEncryptedBody =>
      'Zawartość kalendarza jest szyfrowana end-to-end, zanim opuści to urządzenie. Operatorzy przekaźników nie mogą jej odczytać.';

  @override
  String get featureAmberTitle => 'Przechowuj swój klucz w Amber';

  @override
  String get featureAmberBody =>
      'Na Androidzie zewnętrzny podpisujący może zatwierdzić dostęp bez ujawniania klucza prywatnego Astraea.';

  @override
  String get featureRemindersTitle => 'Prywatne lokalne przypomnienia';

  @override
  String get featureRemindersBody =>
      'Powiadomienia są planowane przez urządzenie i nie zależą od usługi kalendarza w chmurze.';

  @override
  String get connectNostrAccountTitle => 'Połącz konto Nostr';

  @override
  String get connectNostrAccountBody =>
      'Jest to potrzebne tylko do zaszyfrowanej synchronizacji. Astraea można też używać całkowicie offline.';

  @override
  String get chooseRelaysTitle => 'Wybierz przekaźniki do synchronizacji';

  @override
  String get chooseRelaysBody =>
      'Przekaźniki przechowują twój zaszyfrowany kalendarz i udostępniają go na innych urządzeniach. Dodaj jeden lub więcej albo zostaw listę pustą i skonfiguruj to później.';

  @override
  String couldNotLoadRelaySettings(String error) {
    return 'Nie udało się wczytać ustawień przekaźników: $error';
  }

  @override
  String get suggestedRelays => 'Sugerowane';

  @override
  String get addRelayTooltip => 'Dodaj przekaźnik';

  @override
  String get customRelayLabel => 'Niestandardowy przekaźnik';

  @override
  String get customRelayHint => 'wss://relay.example.com';

  @override
  String get selectedRelays => 'Wybrane';

  @override
  String get removeRelayTooltip => 'Usuń przekaźnik';

  @override
  String get invalidRelayUrl =>
      'Wprowadź prawidłowy adres URL wss:// (lub ws:// dla prywatnego przekaźnika).';

  @override
  String get insecureRelayWarning =>
      'ws:// nie jest szyfrowane podczas transmisji — używaj go tylko dla zaufanego przekaźnika.';

  @override
  String get nostrAccountConnected => 'Konto Nostr połączone';

  @override
  String get invalidPrivateKey =>
      'Ten klucz prywatny jest nieprawidłowy. Sprawdź go i spróbuj ponownie.';

  @override
  String couldNotSignIn(String error) {
    return 'Nie udało się zalogować: $error';
  }

  @override
  String get signInWithAmber => 'Zaloguj się przez Amber';

  @override
  String get createNewAccount => 'Utwórz nowe konto';

  @override
  String get generatedAccountWarning =>
      'Wygenerowane konto można odzyskać tylko za pomocą jego klucza prywatnego. Wykonaj kopię zapasową w Ustawieniach po konfiguracji.';

  @override
  String get importExistingKey => 'Zaimportuj istniejący klucz';

  @override
  String get privateKeyFieldLabel => 'nsec lub szesnastkowy klucz prywatny';

  @override
  String get importButton => 'Importuj';

  @override
  String get followDeviceTimezone => 'Użyj strefy czasowej urządzenia';

  @override
  String get searchCityRegion => 'Wyszukaj miasto lub region';

  @override
  String get noMatchingTimezone => 'Brak pasującej strefy czasowej.';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String couldNotLoadSettings(String error) {
    return 'Nie udało się wczytać ustawień:\n$error';
  }

  @override
  String get sectionAccount => 'Konto';

  @override
  String get sectionSync => 'Synchronizacja';

  @override
  String get sectionRelays => 'Przekaźniki';

  @override
  String get sectionAppearance => 'Wygląd';

  @override
  String get sectionData => 'Dane';

  @override
  String get sectionRemindersTimezone => 'Przypomnienia i strefa czasowa';

  @override
  String get sectionSupport => 'Wsparcie';

  @override
  String somethingWentWrong(String error) {
    return 'Coś poszło nie tak: $error';
  }

  @override
  String get offlineNoAccount => 'Offline — brak konta';

  @override
  String get signInToSyncAcrossDevices =>
      'Zaloguj się, aby synchronizować zaszyfrowany kalendarz między urządzeniami.';

  @override
  String get signIn => 'Zaloguj się';

  @override
  String get signedInWithAmber => 'Zalogowano przez Amber';

  @override
  String get signedIn => 'Zalogowano';

  @override
  String get signOut => 'Wyloguj się';

  @override
  String get backUpPrivateKey => 'Kopia zapasowa klucza prywatnego';

  @override
  String get revealNsecSubtitle =>
      'Pokaż swój nsec, aby zapisać go w bezpiecznym miejscu';

  @override
  String get signOutTitle => 'Wylogować się?';

  @override
  String get signOutBody =>
      'Twoje wydarzenia pozostają na tym urządzeniu i na przekaźnikach. Upewnij się, że wykonałeś kopię zapasową klucza prywatnego — bez niego wygenerowanego konta nie można odzyskać.';

  @override
  String get noPrivateKeyStored =>
      'Brak zapisanego klucza prywatnego dla tej sesji.';

  @override
  String get yourPrivateKeyTitle => 'Twój klucz prywatny (nsec)';

  @override
  String get nsecWarning =>
      'Każdy, kto ma ten klucz, kontroluje twoje konto. Nigdy go nie udostępniaj; przechowuj go w menedżerze haseł.';

  @override
  String get copy => 'Kopiuj';

  @override
  String get done => 'Gotowe';

  @override
  String get syncNowTitle => 'Synchronizuj teraz';

  @override
  String get signInToSyncSubtitle =>
      'Zaloguj się, aby synchronizować zaszyfrowany kalendarz.';

  @override
  String get addRelayToSyncSubtitle =>
      'Dodaj co najmniej jeden przekaźnik, aby synchronizować.';

  @override
  String get syncingEllipsis => 'Synchronizowanie…';

  @override
  String get synced => 'Zsynchronizowano';

  @override
  String lastSyncedLabel(String when) {
    return 'Ostatnio zsynchronizowano $when';
  }

  @override
  String lastSyncFailedLabel(String error) {
    return 'Ostatnia synchronizacja nie powiodła się: $error';
  }

  @override
  String get pullMergePublish => 'Pobiera, scala i publikuje twoje wydarzenia';

  @override
  String get publicRelays => 'Publiczne przekaźniki';

  @override
  String relaysConfiguredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skonfigurowanego',
      many: '$count skonfigurowanych',
      few: '$count skonfigurowane',
      one: '1 skonfigurowany',
    );
    return '$_temp0';
  }

  @override
  String get addRelay => 'Dodaj przekaźnik';

  @override
  String get suggestedRelaysTitle => 'Sugerowane przekaźniki';

  @override
  String get addOnlyRelaysYouWant =>
      'Dodawaj tylko przekaźniki, których chcesz używać.';

  @override
  String get homeRelayBackup => 'Przekaźnik osobisty (kopia zapasowa)';

  @override
  String get homeRelayNotConfigured =>
      'Nieskonfigurowany — dodatkowy osobisty przekaźnik do tworzenia kopii zapasowej wydarzeń';

  @override
  String get homeRelayDialogTitle => 'Przekaźnik osobisty';

  @override
  String get lightTheme => 'Jasny motyw';

  @override
  String get darkThemeDefault => 'Astraea domyślnie używa ciemnego motywu';

  @override
  String get languageLabel => 'Język';

  @override
  String get systemLanguage => 'Język systemu';

  @override
  String get accentColorLabel => 'Kolor akcentu';

  @override
  String get accentNavy => 'Granatowy';

  @override
  String get accentBitcoin => 'Pomarańczowy Bitcoin';

  @override
  String get accentNostr => 'Fioletowy Nostr';

  @override
  String get exportEvents => 'Eksportuj wydarzenia';

  @override
  String get exportEventsSubtitle =>
      'Zapisz plik .ics — opcjonalnie chroniony hasłem';

  @override
  String get importEvents => 'Importuj wydarzenia';

  @override
  String get importEventsSubtitle =>
      'Z pliku .ics lub zaszyfrowanego eksportu Astraea';

  @override
  String get encryptExportTitle => 'Zaszyfrować ten eksport?';

  @override
  String get encryptExportBody =>
      'Zwykły plik .ics może otworzyć dowolna aplikacja kalendarza — i każdy, kto go zdobędzie. Ustaw hasło, aby go zaszyfrować (tylko Astraea będzie mogła go ponownie zaimportować).';

  @override
  String get exportPasswordLabel =>
      'Hasło (zostaw puste dla zwykłego pliku .ics)';

  @override
  String get export => 'Eksportuj';

  @override
  String get encryptedExportSaved => 'Zaszyfrowany eksport zapisany.';

  @override
  String get exportSaved => 'Eksport zapisany.';

  @override
  String exportFailed(String error) {
    return 'Eksport nie powiódł się: $error';
  }

  @override
  String get couldNotReadSelectedFile =>
      'Nie udało się odczytać wybranego pliku.';

  @override
  String get selectedFileTooLarge => 'Wybrany plik jest większy niż 10 MB.';

  @override
  String importedEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zaimportowano $count wydarzenia.',
      many: 'Zaimportowano $count wydarzeń.',
      few: 'Zaimportowano $count wydarzenia.',
      one: 'Zaimportowano 1 wydarzenie.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(String error) {
    return 'Import nie powiódł się: $error';
  }

  @override
  String get thisExportIsEncrypted => 'Ten eksport jest zaszyfrowany';

  @override
  String get passwordLabel => 'Hasło';

  @override
  String get wrongPassword => 'Nieprawidłowe hasło.';

  @override
  String get invalidEncryptedExport =>
      'Ten zaszyfrowany eksport jest nieprawidłowy.';

  @override
  String get reminders => 'Przypomnienia';

  @override
  String get scheduleLocalNotifications =>
      'Planuj lokalne powiadomienia dla przypomnień o wydarzeniach';

  @override
  String get timezone => 'Strefa czasowa';

  @override
  String followDeviceTimezoneWithName(String zone) {
    return 'Użyj strefy czasowej urządzenia ($zone)';
  }

  @override
  String get supportAstraea => 'Wesprzyj Astraea';

  @override
  String noLightningWalletFound(String address) {
    return 'Nie znaleziono portfela Lightning — adres skopiowany: $address';
  }

  @override
  String get desktopServiceUnreachableTitle =>
      'Usługa w tle Astraea niedostępna';

  @override
  String get desktopServiceUnreachableBody =>
      'Aplikacja desktopowa komunikuje się z astraea-service przez D-Bus w celu przechowywania danych, synchronizacji i powiadomień, ale nie udało się jej połączyć. Jeśli uruchamiasz ją ze źródeł, zainstaluj ją za pomocą:\n\n./scripts/install-dev.sh';

  @override
  String get retry => 'Spróbuj ponownie';

  @override
  String get calendarsLabel => 'Kalendarze';

  @override
  String calendarsUnavailable(String error) {
    return 'Kalendarze niedostępne: $error';
  }

  @override
  String get serviceUnreachable => 'Usługa niedostępna';

  @override
  String syncStatusLabel(String status) {
    return 'Synchronizacja: $status';
  }

  @override
  String syncPendingSuffix(int count) {
    return ' ($count oczekujących)';
  }

  @override
  String get localOnlyMode => 'Tryb tylko lokalny (brak tożsamości Nostr)';

  @override
  String get syncStarted => 'Synchronizacja rozpoczęta';

  @override
  String syncUnavailable(String error) {
    return 'Synchronizacja niedostępna: $error';
  }

  @override
  String get notSignedIn => 'Niezalogowano';

  @override
  String get signInWithBrowserSubtitle =>
      'Zaloguj się przez przeglądarkę (NIP-07), aby synchronizować ten kalendarz przez Nostr.';

  @override
  String get signedInBackgroundSigning =>
      'Zalogowano — podpisywanie w tle za pomocą delegowanego klucza';

  @override
  String get signedInRemoteSigner => 'Zalogowano — zdalny podpisujący (NIP-46)';

  @override
  String get signedInNoBackgroundSigner =>
      'Zalogowano, ale nie skonfigurowano podpisującego w tle — synchronizacja pozostaje wstrzymana. Uruchom „astraea-service auth provision-key” w terminalu.';

  @override
  String couldNotStartLogin(String error) {
    return 'Nie udało się rozpocząć logowania: $error';
  }

  @override
  String get signOutConfirmDesktopBody =>
      'To zapomina konto tylko na tym urządzeniu — twoje wydarzenia pozostają na przekaźnikach. Ewentualny udostępniony klucz podpisujący zostanie usunięty z pęku kluczy.';

  @override
  String get signInWithBrowserTitle => 'Zaloguj się przez przeglądarkę';

  @override
  String get loginSessionExpired =>
      'Ta sesja logowania wygasła. Spróbuj ponownie.';

  @override
  String get loginWaitingBody =>
      'Otwarto kartę przeglądarki, aby potwierdzić twoją tożsamość Nostr (NIP-07). Zatwierdź ją tam — to okno zamknie się automatycznie. Twój klucz prywatny nigdy nie jest wymagany.';

  @override
  String get openAgain => 'Otwórz ponownie';

  @override
  String get offlineWillRetry => 'Offline — spróbuje ponownie automatycznie.';

  @override
  String get upToDate => 'Aktualne';

  @override
  String operationsFailingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count operacji nieudanej',
      many: '$count operacji nieudanych',
      few: '$count operacje nieudane',
      one: '1 operacja nieudana',
    );
    return '$_temp0';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count oczekującego',
      many: '$count oczekujących',
      few: '$count oczekujące',
      one: '1 oczekujące',
    );
    return '$_temp0';
  }

  @override
  String pendingFailingCount(String pending, String failing) {
    return '$pending, $failing';
  }

  @override
  String get relayStatus => 'Stan przekaźników';

  @override
  String get relaysLabel => 'Przekaźniki';

  @override
  String relaysConfiguredLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skonfigurowanego',
      many: '$count skonfigurowanych',
      few: '$count skonfigurowane',
      one: '1 skonfigurowany',
    );
    return '$_temp0';
  }

  @override
  String get unencryptedTransport => 'Niezaszyfrowana transmisja';

  @override
  String couldNotReachService(String error) {
    return 'Nie udało się połączyć z astraea-service: $error';
  }

  @override
  String get inviteSectionTitle => 'Uczestnicy';

  @override
  String get inviteButtonLabel => 'Zaproś';

  @override
  String get noAttendeesYet => 'Nikt jeszcze nie został zaproszony';

  @override
  String get inviteDialogTitle => 'Zaproś kogoś';

  @override
  String get inviteDialogHint => 'npub, nazwa@domena lub klucz publiczny';

  @override
  String resolvePersonFailed(String error) {
    return 'Nie udało się rozpoznać tej osoby: $error';
  }

  @override
  String get confirmNip05Title => 'Potwierdź odbiorcę';

  @override
  String confirmNip05Body(String query, String pubkey) {
    return '$query rozpoznano jako $pubkey za pomocą NIP-05. To mapowanie jest kontrolowane przez domenę — upewnij się, że to oczekiwana osoba.';
  }

  @override
  String get attendeeStatusInvited => 'Zaproszono';

  @override
  String get attendeeStatusAccepted => 'Zaakceptowano';

  @override
  String get attendeeStatusDeclined => 'Odrzucono';

  @override
  String inviteFailed(String error) {
    return 'Nie udało się wysłać zaproszenia: $error';
  }

  @override
  String get pendingInvitationsTooltip => 'Zaproszenia';

  @override
  String get pendingInvitationsTitle => 'Zaproszenia';

  @override
  String get pendingInvitationsEmpty => 'Brak oczekujących zaproszeń';

  @override
  String invitationFromLabel(String pubkey) {
    return 'Od $pubkey';
  }

  @override
  String get acceptInvitation => 'Akceptuj';

  @override
  String get declineInvitation => 'Odrzuć';

  @override
  String respondToInvitationFailed(String error) {
    return 'Nie udało się wysłać odpowiedzi: $error';
  }

  @override
  String get invitationAccepted => 'Zaproszenie zaakceptowane';

  @override
  String get invitationDeclined => 'Zaproszenie odrzucone';
}
