// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Croatian (`hr`).
class AppLocalizationsHr extends AppLocalizations {
  AppLocalizationsHr([String locale = 'hr']) : super(locale);

  @override
  String get appTitle => 'Astraea';

  @override
  String get cancel => 'Odustani';

  @override
  String get save => 'Spremi';

  @override
  String get delete => 'Izbriši';

  @override
  String get continueLabel => 'Nastavi';

  @override
  String get next => 'Dalje';

  @override
  String get back => 'Natrag';

  @override
  String get loading => 'Učitavanje…';

  @override
  String get settingsTooltip => 'Postavke';

  @override
  String get newEventButton => 'Novi događaj';

  @override
  String couldNotLoadEvents(String error) {
    return 'Događaji se nisu mogli učitati:\n$error';
  }

  @override
  String get viewMonth => 'Mjesec';

  @override
  String get viewWeek => 'Tjedan';

  @override
  String get viewDay => 'Dan';

  @override
  String get viewList => 'Popis';

  @override
  String get noEventsToday => 'Nema događaja ovog dana.';

  @override
  String get noUpcomingEvents =>
      'Nema nadolazećih događaja u sljedećih 60 dana.';

  @override
  String get untitledEvent => '(bez naslova)';

  @override
  String get allDay => 'Cijeli dan';

  @override
  String get addAccountToSyncTooltip => 'Dodaj Nostr račun za sinkronizaciju';

  @override
  String get syncNowTooltip => 'Sinkroniziraj sada';

  @override
  String get addNostrAccountTitle => 'Dodaj Nostr račun';

  @override
  String get eventNotFound => 'Događaj nije pronađen.';

  @override
  String get eventAppBarTitle => 'Događaj';

  @override
  String get editTooltip => 'Uredi';

  @override
  String get deleteTooltip => 'Izbriši';

  @override
  String allDayLabel(String date) {
    return '$date · Cijeli dan';
  }

  @override
  String recurrenceUntilLabel(String recurrence, String date) {
    return '$recurrence · do $date';
  }

  @override
  String get syncedToRelays => 'Sinkronizirano s relejima';

  @override
  String get notYetSynced => 'Još nije sinkronizirano';

  @override
  String get deleteEventTitle => 'Izbrisati događaj?';

  @override
  String get deleteEventBody =>
      'Ovo uklanja događaj s ovog uređaja i traži brisanje s releja.';

  @override
  String get editEventTitle => 'Uredi događaj';

  @override
  String get newEventTitle => 'Novi događaj';

  @override
  String get fieldTitle => 'Naslov';

  @override
  String get allDaySwitch => 'Cijeli dan';

  @override
  String get startsLabel => 'Počinje';

  @override
  String get endsLabel => 'Završava';

  @override
  String get timezoneLabel => 'Vremenska zona';

  @override
  String get repeatsLabel => 'Ponavljanje';

  @override
  String get untilLabel => 'Do';

  @override
  String get foreverLabel => 'Zauvijek';

  @override
  String get remindersLabel => 'Podsjetnici';

  @override
  String get addChip => 'Dodaj';

  @override
  String get colorLabel => 'Boja';

  @override
  String get locationLabel => 'Lokacija';

  @override
  String get descriptionLabel => 'Opis';

  @override
  String couldNotSaveEvent(String error) {
    return 'Događaj se nije mogao spremiti: $error';
  }

  @override
  String get recurrenceNone => 'Ne ponavlja se';

  @override
  String get recurrenceDaily => 'Svakodnevno';

  @override
  String get recurrenceWeekly => 'Svaki tjedan';

  @override
  String get recurrenceMonthly => 'Svaki mjesec';

  @override
  String get recurrenceYearly => 'Svake godine';

  @override
  String get reminderAtStart => 'Na početku';

  @override
  String reminderMinutesBefore(int count) {
    return '$count min prije';
  }

  @override
  String reminderHoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sati prije',
      few: '$count sata prije',
      one: '1 sat prije',
    );
    return '$_temp0';
  }

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dana prije',
      few: '$count dana prije',
      one: '1 dan prije',
    );
    return '$_temp0';
  }

  @override
  String get getStarted => 'Započni';

  @override
  String get useOffline => 'Koristi izvanmrežno';

  @override
  String get welcomeTitle => 'Dobrodošli u Astraea';

  @override
  String get welcomeSubtitle =>
      'Privatni kalendar, prvenstveno izvanmrežni, koji vama ostavlja kontrolu.';

  @override
  String get featureLocalTitle => 'Vaš kalendar ostaje na vašem uređaju';

  @override
  String get featureLocalBody =>
      'Kreirajte događaje, ponavljanja i podsjetnike bez računa ili internetske veze.';

  @override
  String get featureSyncTitle => 'Neobavezna sinkronizacija putem Nostra';

  @override
  String get featureSyncBody =>
      'Povežite račun kako biste izradili sigurnosnu kopiju kalendara i koristili ga na više uređaja putem releja koje odaberete.';

  @override
  String get featureEncryptedTitle => 'Uvijek šifrirano prije prijenosa';

  @override
  String get featureEncryptedBody =>
      'Sadržaj kalendara šifrira se od kraja do kraja prije nego što napusti ovaj uređaj. Operateri releja ne mogu ga čitati.';

  @override
  String get featureAmberTitle => 'Čuvajte svoj ključ u Amberu';

  @override
  String get featureAmberBody =>
      'Na Androidu vanjski potpisnik može odobriti pristup bez izlaganja vašeg privatnog ključa Astraei.';

  @override
  String get featureRemindersTitle => 'Privatni lokalni podsjetnici';

  @override
  String get featureRemindersBody =>
      'Obavijesti planira vaš uređaj i ne ovise o kalendarskoj usluzi u oblaku.';

  @override
  String get connectNostrAccountTitle => 'Poveži Nostr račun';

  @override
  String get connectNostrAccountBody =>
      'Ovo je potrebno samo za šifriranu sinkronizaciju. Astraea također možete koristiti potpuno izvanmrežno.';

  @override
  String get chooseRelaysTitle => 'Odaberite releje za sinkronizaciju';

  @override
  String get chooseRelaysBody =>
      'Releji pohranjuju vaš šifrirani kalendar i čine ga dostupnim na vašim drugim uređajima. Dodajte jedan ili više, ili ostavite popis praznim i konfigurirajte kasnije.';

  @override
  String couldNotLoadRelaySettings(String error) {
    return 'Postavke releja nisu se mogle učitati: $error';
  }

  @override
  String get suggestedRelays => 'Predloženi';

  @override
  String get addRelayTooltip => 'Dodaj relej';

  @override
  String get customRelayLabel => 'Prilagođeni relej';

  @override
  String get customRelayHint => 'wss://relay.example.com';

  @override
  String get selectedRelays => 'Odabrani';

  @override
  String get removeRelayTooltip => 'Ukloni relej';

  @override
  String get invalidRelayUrl =>
      'Unesite valjani wss:// URL (ili ws:// za privatni relej).';

  @override
  String get insecureRelayWarning =>
      'ws:// nije šifriran tijekom prijenosa — koristite ga samo za relej kojem vjerujete.';

  @override
  String get nostrAccountConnected => 'Nostr račun povezan';

  @override
  String get invalidPrivateKey =>
      'Taj privatni ključ nije valjan. Provjerite ga i pokušajte ponovno.';

  @override
  String couldNotSignIn(String error) {
    return 'Prijava nije uspjela: $error';
  }

  @override
  String get signInWithAmber => 'Prijavi se putem Ambera';

  @override
  String get createNewAccount => 'Kreiraj novi račun';

  @override
  String get generatedAccountWarning =>
      'Generirani račun može se oporaviti samo pomoću svog privatnog ključa. Izradite sigurnosnu kopiju iz Postavki nakon postavljanja.';

  @override
  String get importExistingKey => 'Uvezi postojeći ključ';

  @override
  String get privateKeyFieldLabel => 'nsec ili heksadecimalni privatni ključ';

  @override
  String get importButton => 'Uvezi';

  @override
  String get followDeviceTimezone => 'Prati vremensku zonu uređaja';

  @override
  String get searchCityRegion => 'Pretraži grad ili regiju';

  @override
  String get noMatchingTimezone => 'Nema odgovarajuće vremenske zone.';

  @override
  String get settingsTitle => 'Postavke';

  @override
  String couldNotLoadSettings(String error) {
    return 'Postavke se nisu mogle učitati:\n$error';
  }

  @override
  String get sectionAccount => 'Račun';

  @override
  String get sectionSync => 'Sinkronizacija';

  @override
  String get sectionRelays => 'Releji';

  @override
  String get sectionAppearance => 'Izgled';

  @override
  String get sectionData => 'Podaci';

  @override
  String get sectionRemindersTimezone => 'Podsjetnici i vremenska zona';

  @override
  String get sectionSupport => 'Podrška';

  @override
  String somethingWentWrong(String error) {
    return 'Nešto je pošlo po zlu: $error';
  }

  @override
  String get offlineNoAccount => 'Izvanmrežno — bez računa';

  @override
  String get signInToSyncAcrossDevices =>
      'Prijavite se za sinkronizaciju šifriranog kalendara među uređajima.';

  @override
  String get signIn => 'Prijava';

  @override
  String get signedInWithAmber => 'Prijavljeni putem Ambera';

  @override
  String get signedIn => 'Prijavljeni';

  @override
  String get signOut => 'Odjava';

  @override
  String get backUpPrivateKey => 'Izradi sigurnosnu kopiju privatnog ključa';

  @override
  String get revealNsecSubtitle =>
      'Otkrijte svoj nsec kako biste ga spremili na sigurno mjesto';

  @override
  String get signOutTitle => 'Odjaviti se?';

  @override
  String get signOutBody =>
      'Vaši događaji ostaju na ovom uređaju i na relejima. Provjerite jeste li izradili sigurnosnu kopiju privatnog ključa — bez njega se generirani račun ne može oporaviti.';

  @override
  String get noPrivateKeyStored =>
      'Nema spremljenog privatnog ključa za ovu sesiju.';

  @override
  String get yourPrivateKeyTitle => 'Vaš privatni ključ (nsec)';

  @override
  String get nsecWarning =>
      'Svatko tko ima ovaj ključ kontrolira vaš račun. Nikada ga ne dijelite; čuvajte ga u upravitelju lozinki.';

  @override
  String get copy => 'Kopiraj';

  @override
  String get done => 'Gotovo';

  @override
  String get syncNowTitle => 'Sinkroniziraj sada';

  @override
  String get signInToSyncSubtitle =>
      'Prijavite se za sinkronizaciju šifriranog kalendara.';

  @override
  String get addRelayToSyncSubtitle =>
      'Dodajte barem jedan relej za sinkronizaciju.';

  @override
  String get syncingEllipsis => 'Sinkronizacija…';

  @override
  String get synced => 'Sinkronizirano';

  @override
  String lastSyncedLabel(String when) {
    return 'Posljednja sinkronizacija $when';
  }

  @override
  String lastSyncFailedLabel(String error) {
    return 'Posljednja sinkronizacija nije uspjela: $error';
  }

  @override
  String get pullMergePublish => 'Dohvaća, spaja i objavljuje vaše događaje';

  @override
  String get publicRelays => 'Javni releji';

  @override
  String relaysConfiguredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count konfigurirano',
      few: '$count konfigurirana',
      one: '1 konfiguriran',
    );
    return '$_temp0';
  }

  @override
  String get addRelay => 'Dodaj relej';

  @override
  String get suggestedRelaysTitle => 'Predloženi releji';

  @override
  String get addOnlyRelaysYouWant =>
      'Dodajte samo releje koje želite koristiti.';

  @override
  String get homeRelayBackup => 'Osobni relej (sigurnosna kopija)';

  @override
  String get homeRelayNotConfigured =>
      'Nije konfiguriran — dodatni osobni relej za sigurnosnu kopiju vaših događaja';

  @override
  String get homeRelayDialogTitle => 'Osobni relej';

  @override
  String get lightTheme => 'Svijetla tema';

  @override
  String get darkThemeDefault =>
      'Astraea prema zadanim postavkama koristi tamnu temu';

  @override
  String get languageLabel => 'Jezik';

  @override
  String get systemLanguage => 'Jezik sustava';

  @override
  String get exportEvents => 'Izvezi događaje';

  @override
  String get exportEventsSubtitle =>
      'Spremi .ics datoteku — po izboru zaštićenu lozinkom';

  @override
  String get importEvents => 'Uvezi događaje';

  @override
  String get importEventsSubtitle =>
      'Iz .ics datoteke ili šifriranog Astraea izvoza';

  @override
  String get encryptExportTitle => 'Šifrirati ovaj izvoz?';

  @override
  String get encryptExportBody =>
      'Obična .ics datoteka može se otvoriti bilo kojom kalendarskom aplikacijom — i bilo kime tko je dobije. Postavite lozinku za njeno šifriranje (samo će je Astraea moći ponovno uvesti).';

  @override
  String get exportPasswordLabel =>
      'Lozinka (ostavite prazno za običnu .ics datoteku)';

  @override
  String get export => 'Izvezi';

  @override
  String get encryptedExportSaved => 'Šifrirani izvoz spremljen.';

  @override
  String get exportSaved => 'Izvoz spremljen.';

  @override
  String exportFailed(String error) {
    return 'Izvoz nije uspio: $error';
  }

  @override
  String get couldNotReadSelectedFile =>
      'Odabrana datoteka nije se mogla pročitati.';

  @override
  String get selectedFileTooLarge => 'Odabrana datoteka veća je od 10 MB.';

  @override
  String importedEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Uvezeno je $count događaja.',
      few: 'Uvezena su $count događaja.',
      one: 'Uvezen je 1 događaj.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(String error) {
    return 'Uvoz nije uspio: $error';
  }

  @override
  String get thisExportIsEncrypted => 'Ovaj izvoz je šifriran';

  @override
  String get passwordLabel => 'Lozinka';

  @override
  String get wrongPassword => 'Pogrešna lozinka.';

  @override
  String get invalidEncryptedExport => 'Ovaj šifrirani izvoz nije valjan.';

  @override
  String get reminders => 'Podsjetnici';

  @override
  String get scheduleLocalNotifications =>
      'Rasporedi lokalne obavijesti za podsjetnike događaja';

  @override
  String get timezone => 'Vremenska zona';

  @override
  String followDeviceTimezoneWithName(String zone) {
    return 'Prati vremensku zonu uređaja ($zone)';
  }

  @override
  String get supportAstraea => 'Podrži Astraea';

  @override
  String noLightningWalletFound(String address) {
    return 'Nije pronađen Lightning novčanik — adresa kopirana: $address';
  }

  @override
  String get desktopServiceUnreachableTitle =>
      'Pozadinska usluga Astraea nije dostupna';

  @override
  String get desktopServiceUnreachableBody =>
      'Aplikacija za radnu površinu komunicira s astraea-service putem D-Bus za pohranu, sinkronizaciju i obavijesti, ali nije bilo moguće uspostaviti vezu. Ako je pokrećete iz izvornog koda, instalirajte je pomoću:\n\n./scripts/install-dev.sh';

  @override
  String get retry => 'Pokušaj ponovno';

  @override
  String get calendarsLabel => 'Kalendari';

  @override
  String calendarsUnavailable(String error) {
    return 'Kalendari nisu dostupni: $error';
  }

  @override
  String get serviceUnreachable => 'Usluga nije dostupna';

  @override
  String syncStatusLabel(String status) {
    return 'Sinkronizacija: $status';
  }

  @override
  String syncPendingSuffix(int count) {
    return ' ($count na čekanju)';
  }

  @override
  String get localOnlyMode => 'Samo lokalni način rada (bez Nostr identiteta)';

  @override
  String get syncStarted => 'Sinkronizacija pokrenuta';

  @override
  String syncUnavailable(String error) {
    return 'Sinkronizacija nije dostupna: $error';
  }

  @override
  String get notSignedIn => 'Niste prijavljeni';

  @override
  String get signInWithBrowserSubtitle =>
      'Prijavite se putem preglednika (NIP-07) za sinkronizaciju ovog kalendara putem Nostra.';

  @override
  String get signedInBackgroundSigning =>
      'Prijavljeni — pozadinsko potpisivanje putem delegiranog ključa';

  @override
  String get signedInRemoteSigner =>
      'Prijavljeni — udaljeni potpisnik (NIP-46)';

  @override
  String get signedInNoBackgroundSigner =>
      'Prijavljeni, ali nije konfiguriran pozadinski potpisnik — sinkronizacija ostaje pauzirana. Pokrenite \"astraea-service auth provision-key\" u terminalu.';

  @override
  String couldNotStartLogin(String error) {
    return 'Prijava se nije mogla pokrenuti: $error';
  }

  @override
  String get signOutConfirmDesktopBody =>
      'Ovo zaboravlja račun samo na ovom uređaju — vaši događaji ostaju na relejima. Eventualni pruženi ključ za potpisivanje uklanja se iz privjeska za ključeve.';

  @override
  String get signInWithBrowserTitle => 'Prijavite se putem preglednika';

  @override
  String get loginSessionExpired =>
      'Ova sesija prijave je istekla. Pokušajte ponovno.';

  @override
  String get loginWaitingBody =>
      'Otvorena je kartica preglednika za potvrdu vašeg Nostr identiteta (NIP-07). Odobrite je ondje — ovaj dijalog zatvara se automatski. Vaš privatni ključ nikada se ne traži.';

  @override
  String get openAgain => 'Otvori ponovno';

  @override
  String get offlineWillRetry =>
      'Izvanmrežno — automatski će pokušati ponovno.';

  @override
  String get upToDate => 'Ažurirano';

  @override
  String operationsFailingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count neuspjelih operacija',
      few: '$count neuspjele operacije',
      one: '1 neuspjela operacija',
    );
    return '$_temp0';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count na čekanju',
      few: '$count na čekanju',
      one: '1 na čekanju',
    );
    return '$_temp0';
  }

  @override
  String pendingFailingCount(String pending, String failing) {
    return '$pending, $failing';
  }

  @override
  String get relayStatus => 'Status releja';

  @override
  String get relaysLabel => 'Releji';

  @override
  String relaysConfiguredLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count konfigurirano',
      few: '$count konfigurirana',
      one: '1 konfiguriran',
    );
    return '$_temp0';
  }

  @override
  String get unencryptedTransport => 'Nešifrirani prijenos';

  @override
  String couldNotReachService(String error) {
    return 'Nije bilo moguće uspostaviti vezu s astraea-service: $error';
  }

  @override
  String get inviteSectionTitle => 'Sudionici';

  @override
  String get inviteButtonLabel => 'Pozovi';

  @override
  String get noAttendeesYet => 'Još nitko nije pozvan';

  @override
  String get inviteDialogTitle => 'Pozovi nekoga';

  @override
  String get inviteDialogHint => 'npub, ime@domena ili javni ključ';

  @override
  String resolvePersonFailed(String error) {
    return 'Tu osobu nije bilo moguće pronaći: $error';
  }

  @override
  String get confirmNip05Title => 'Potvrdi primatelja';

  @override
  String confirmNip05Body(String query, String pubkey) {
    return '$query je razriješen na $pubkey putem NIP-05. Ovim mapiranjem upravlja domena — provjerite je li riječ o očekivanoj osobi.';
  }

  @override
  String get attendeeStatusInvited => 'Pozvan';

  @override
  String get attendeeStatusAccepted => 'Prihvaćeno';

  @override
  String get attendeeStatusDeclined => 'Odbijeno';

  @override
  String inviteFailed(String error) {
    return 'Poziv nije moguće poslati: $error';
  }

  @override
  String get pendingInvitationsTooltip => 'Pozivi';

  @override
  String get pendingInvitationsTitle => 'Pozivi';

  @override
  String get pendingInvitationsEmpty => 'Nema pozivâ na čekanju';

  @override
  String invitationFromLabel(String pubkey) {
    return 'Od $pubkey';
  }

  @override
  String get acceptInvitation => 'Prihvati';

  @override
  String get declineInvitation => 'Odbij';

  @override
  String respondToInvitationFailed(String error) {
    return 'Odgovor nije moguće poslati: $error';
  }

  @override
  String get invitationAccepted => 'Poziv prihvaćen';

  @override
  String get invitationDeclined => 'Poziv odbijen';
}
