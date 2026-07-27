// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get appTitle => 'Astraea';

  @override
  String get cancel => 'Annuller';

  @override
  String get save => 'Gem';

  @override
  String get delete => 'Slet';

  @override
  String get continueLabel => 'Fortsæt';

  @override
  String get next => 'Næste';

  @override
  String get back => 'Tilbage';

  @override
  String get loading => 'Indlæser…';

  @override
  String get settingsTooltip => 'Indstillinger';

  @override
  String get newEventButton => 'Ny begivenhed';

  @override
  String couldNotLoadEvents(String error) {
    return 'Kunne ikke indlæse begivenheder:\n$error';
  }

  @override
  String get viewMonth => 'Måned';

  @override
  String get viewWeek => 'Uge';

  @override
  String get viewDay => 'Dag';

  @override
  String get viewList => 'Liste';

  @override
  String get noEventsToday => 'Ingen begivenheder denne dag.';

  @override
  String get noUpcomingEvents =>
      'Ingen kommende begivenheder de næste 60 dage.';

  @override
  String get untitledEvent => '(uden titel)';

  @override
  String get allDay => 'Hele dagen';

  @override
  String get addAccountToSyncTooltip =>
      'Tilføj en Nostr-konto for at synkronisere';

  @override
  String get syncNowTooltip => 'Synkroniser nu';

  @override
  String get addNostrAccountTitle => 'Tilføj en Nostr-konto';

  @override
  String get eventNotFound => 'Begivenhed ikke fundet.';

  @override
  String get eventAppBarTitle => 'Begivenhed';

  @override
  String get editTooltip => 'Rediger';

  @override
  String get deleteTooltip => 'Slet';

  @override
  String allDayLabel(String date) {
    return '$date · Hele dagen';
  }

  @override
  String recurrenceUntilLabel(String recurrence, String date) {
    return '$recurrence · indtil $date';
  }

  @override
  String get syncedToRelays => 'Synkroniseret med relæer';

  @override
  String get notYetSynced => 'Endnu ikke synkroniseret';

  @override
  String get deleteEventTitle => 'Slet begivenhed?';

  @override
  String get deleteEventBody =>
      'Dette fjerner begivenheden fra denne enhed og anmoder om sletning fra relæerne.';

  @override
  String get editEventTitle => 'Rediger begivenhed';

  @override
  String get newEventTitle => 'Ny begivenhed';

  @override
  String get fieldTitle => 'Titel';

  @override
  String get allDaySwitch => 'Hele dagen';

  @override
  String get startsLabel => 'Starter';

  @override
  String get endsLabel => 'Slutter';

  @override
  String get timezoneLabel => 'Tidszone';

  @override
  String get repeatsLabel => 'Gentagelse';

  @override
  String get untilLabel => 'Indtil';

  @override
  String get foreverLabel => 'For altid';

  @override
  String get remindersLabel => 'Påmindelser';

  @override
  String get addChip => 'Tilføj';

  @override
  String get colorLabel => 'Farve';

  @override
  String get locationLabel => 'Sted';

  @override
  String get descriptionLabel => 'Beskrivelse';

  @override
  String couldNotSaveEvent(String error) {
    return 'Kunne ikke gemme begivenheden: $error';
  }

  @override
  String get recurrenceNone => 'Gentages ikke';

  @override
  String get recurrenceDaily => 'Dagligt';

  @override
  String get recurrenceWeekly => 'Ugentligt';

  @override
  String get recurrenceMonthly => 'Månedligt';

  @override
  String get recurrenceYearly => 'Årligt';

  @override
  String get reminderAtStart => 'Ved start';

  @override
  String reminderMinutesBefore(int count) {
    return '$count min. før';
  }

  @override
  String reminderHoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count timer før',
      one: '1 time før',
    );
    return '$_temp0';
  }

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dage før',
      one: '1 dag før',
    );
    return '$_temp0';
  }

  @override
  String get getStarted => 'Kom i gang';

  @override
  String get useOffline => 'Brug offline';

  @override
  String get welcomeTitle => 'Velkommen til Astraea';

  @override
  String get welcomeSubtitle =>
      'En privat, offline-først kalender, der giver dig kontrollen.';

  @override
  String get featureLocalTitle => 'Din kalender forbliver på din enhed';

  @override
  String get featureLocalBody =>
      'Opret begivenheder, gentagelser og påmindelser uden en konto eller internetforbindelse.';

  @override
  String get featureSyncTitle => 'Valgfri synkronisering via Nostr';

  @override
  String get featureSyncBody =>
      'Tilslut en konto for at sikkerhedskopiere din kalender og bruge den på flere enheder via relæer, du selv vælger.';

  @override
  String get featureEncryptedTitle => 'Altid krypteret før upload';

  @override
  String get featureEncryptedBody =>
      'Kalenderindhold krypteres end-to-end, før det forlader denne enhed. Relæoperatører kan ikke læse det.';

  @override
  String get featureAmberTitle => 'Opbevar din nøgle i Amber';

  @override
  String get featureAmberBody =>
      'På Android kan en ekstern underskriver godkende adgang uden at eksponere din private nøgle for Astraea.';

  @override
  String get featureRemindersTitle => 'Private lokale påmindelser';

  @override
  String get featureRemindersBody =>
      'Notifikationer planlægges af din enhed og afhænger ikke af en cloudkalendertjeneste.';

  @override
  String get connectNostrAccountTitle => 'Tilslut en Nostr-konto';

  @override
  String get connectNostrAccountBody =>
      'Dette er kun nødvendigt for krypteret synkronisering. Du kan også bruge Astraea helt offline.';

  @override
  String get chooseRelaysTitle => 'Vælg relæer til synkronisering';

  @override
  String get chooseRelaysBody =>
      'Relæer gemmer din krypterede kalender og gør den tilgængelig på dine andre enheder. Tilføj en eller flere, eller lad listen være tom og konfigurer det senere.';

  @override
  String couldNotLoadRelaySettings(String error) {
    return 'Kunne ikke indlæse relæindstillinger: $error';
  }

  @override
  String get suggestedRelays => 'Foreslåede';

  @override
  String get addRelayTooltip => 'Tilføj relæ';

  @override
  String get customRelayLabel => 'Brugerdefineret relæ';

  @override
  String get customRelayHint => 'wss://relay.example.com';

  @override
  String get selectedRelays => 'Valgte';

  @override
  String get removeRelayTooltip => 'Fjern relæ';

  @override
  String get invalidRelayUrl =>
      'Indtast en gyldig wss://-URL (eller ws:// for et privat relæ).';

  @override
  String get insecureRelayWarning =>
      'ws:// er ukrypteret under transport — brug det kun til et relæ, du stoler på.';

  @override
  String get nostrAccountConnected => 'Nostr-konto tilsluttet';

  @override
  String get invalidPrivateKey =>
      'Den private nøgle er ikke gyldig. Tjek den, og prøv igen.';

  @override
  String couldNotSignIn(String error) {
    return 'Kunne ikke logge ind: $error';
  }

  @override
  String get signInWithAmber => 'Log ind med Amber';

  @override
  String get createNewAccount => 'Opret en ny konto';

  @override
  String get generatedAccountWarning =>
      'En genereret konto kan kun gendannes med sin private nøgle. Sikkerhedskopiér den fra Indstillinger efter opsætningen.';

  @override
  String get importExistingKey => 'Importer en eksisterende nøgle';

  @override
  String get privateKeyFieldLabel => 'nsec eller hexadecimal privat nøgle';

  @override
  String get importButton => 'Importer';

  @override
  String get followDeviceTimezone => 'Følg enhedens tidszone';

  @override
  String get searchCityRegion => 'Søg efter en by eller region';

  @override
  String get noMatchingTimezone => 'Ingen matchende tidszone.';

  @override
  String get settingsTitle => 'Indstillinger';

  @override
  String couldNotLoadSettings(String error) {
    return 'Kunne ikke indlæse indstillinger:\n$error';
  }

  @override
  String get sectionAccount => 'Konto';

  @override
  String get sectionSync => 'Synkronisering';

  @override
  String get sectionRelays => 'Relæer';

  @override
  String get sectionAppearance => 'Udseende';

  @override
  String get sectionData => 'Data';

  @override
  String get sectionRemindersTimezone => 'Påmindelser og tidszone';

  @override
  String get sectionSupport => 'Support';

  @override
  String somethingWentWrong(String error) {
    return 'Noget gik galt: $error';
  }

  @override
  String get offlineNoAccount => 'Offline — ingen konto';

  @override
  String get signInToSyncAcrossDevices =>
      'Log ind for at synkronisere din krypterede kalender på tværs af enheder.';

  @override
  String get signIn => 'Log ind';

  @override
  String get signedInWithAmber => 'Logget ind med Amber';

  @override
  String get signedIn => 'Logget ind';

  @override
  String get signOut => 'Log ud';

  @override
  String get backUpPrivateKey => 'Sikkerhedskopiér privat nøgle';

  @override
  String get revealNsecSubtitle =>
      'Vis din nsec for at gemme den et sikkert sted';

  @override
  String get signOutTitle => 'Log ud?';

  @override
  String get signOutBody =>
      'Dine begivenheder forbliver på denne enhed og på relæerne. Sørg for, at du har sikkerhedskopieret din private nøgle — uden den kan en genereret konto ikke gendannes.';

  @override
  String get noPrivateKeyStored => 'Ingen privat nøgle gemt for denne session.';

  @override
  String get yourPrivateKeyTitle => 'Din private nøgle (nsec)';

  @override
  String get nsecWarning =>
      'Enhver med denne nøgle har kontrol over din konto. Del den aldrig; opbevar den i en adgangskodeadministrator.';

  @override
  String get copy => 'Kopiér';

  @override
  String get done => 'Færdig';

  @override
  String get syncNowTitle => 'Synkroniser nu';

  @override
  String get signInToSyncSubtitle =>
      'Log ind for at synkronisere din krypterede kalender.';

  @override
  String get addRelayToSyncSubtitle =>
      'Tilføj mindst ét relæ for at synkronisere.';

  @override
  String get syncingEllipsis => 'Synkroniserer…';

  @override
  String get synced => 'Synkroniseret';

  @override
  String lastSyncedLabel(String when) {
    return 'Sidst synkroniseret $when';
  }

  @override
  String lastSyncFailedLabel(String error) {
    return 'Sidste synkronisering mislykkedes: $error';
  }

  @override
  String get pullMergePublish =>
      'Henter, sammenfletter og udgiver dine begivenheder';

  @override
  String get publicRelays => 'Offentlige relæer';

  @override
  String relaysConfiguredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count konfigureret',
      one: '1 konfigureret',
    );
    return '$_temp0';
  }

  @override
  String get addRelay => 'Tilføj relæ';

  @override
  String get suggestedRelaysTitle => 'Foreslåede relæer';

  @override
  String get addOnlyRelaysYouWant => 'Tilføj kun de relæer, du vil bruge.';

  @override
  String get homeRelayBackup => 'Personligt relæ (backup)';

  @override
  String get homeRelayNotConfigured =>
      'Ikke konfigureret — et ekstra personligt relæ til at sikkerhedskopiere dine begivenheder';

  @override
  String get homeRelayDialogTitle => 'Personligt relæ';

  @override
  String get lightTheme => 'Lyst tema';

  @override
  String get darkThemeDefault => 'Astraea bruger mørkt tema som standard';

  @override
  String get languageLabel => 'Sprog';

  @override
  String get systemLanguage => 'Systemsprog';

  @override
  String get exportEvents => 'Eksporter begivenheder';

  @override
  String get exportEventsSubtitle =>
      'Gem en .ics-fil — valgfrit adgangskodebeskyttet';

  @override
  String get importEvents => 'Importer begivenheder';

  @override
  String get importEventsSubtitle =>
      'Fra en .ics-fil eller en krypteret Astraea-eksport';

  @override
  String get encryptExportTitle => 'Kryptér denne eksport?';

  @override
  String get encryptExportBody =>
      'En almindelig .ics-fil kan åbnes af enhver kalenderapp — og af alle, der får fat i filen. Angiv en adgangskode for at kryptere den (kun Astraea vil kunne importere den igen).';

  @override
  String get exportPasswordLabel =>
      'Adgangskode (lad stå tom for en almindelig .ics-fil)';

  @override
  String get export => 'Eksporter';

  @override
  String get encryptedExportSaved => 'Krypteret eksport gemt.';

  @override
  String get exportSaved => 'Eksport gemt.';

  @override
  String exportFailed(String error) {
    return 'Eksport mislykkedes: $error';
  }

  @override
  String get couldNotReadSelectedFile => 'Kunne ikke læse den valgte fil.';

  @override
  String get selectedFileTooLarge => 'Den valgte fil er større end 10 MB.';

  @override
  String importedEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count begivenheder importeret.',
      one: '1 begivenhed importeret.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(String error) {
    return 'Import mislykkedes: $error';
  }

  @override
  String get thisExportIsEncrypted => 'Denne eksport er krypteret';

  @override
  String get passwordLabel => 'Adgangskode';

  @override
  String get wrongPassword => 'Forkert adgangskode.';

  @override
  String get invalidEncryptedExport =>
      'Denne krypterede eksport er ikke gyldig.';

  @override
  String get reminders => 'Påmindelser';

  @override
  String get scheduleLocalNotifications =>
      'Planlæg lokale notifikationer for begivenhedspåmindelser';

  @override
  String get timezone => 'Tidszone';

  @override
  String followDeviceTimezoneWithName(String zone) {
    return 'Følg enhedens tidszone ($zone)';
  }

  @override
  String get supportAstraea => 'Støt Astraea';

  @override
  String noLightningWalletFound(String address) {
    return 'Ingen Lightning-tegnebog fundet — adresse kopieret: $address';
  }

  @override
  String get desktopServiceUnreachableTitle =>
      'Astraeas baggrundstjeneste er ikke tilgængelig';

  @override
  String get desktopServiceUnreachableBody =>
      'Skrivebordsappen kommunikerer med astraea-service via D-Bus for lagring, synkronisering og notifikationer, og den kunne ikke nås. Hvis du kører fra kildekoden, skal du installere den med:\n\n./scripts/install-dev.sh';

  @override
  String get retry => 'Prøv igen';

  @override
  String get calendarsLabel => 'Kalendere';

  @override
  String calendarsUnavailable(String error) {
    return 'Kalendere ikke tilgængelige: $error';
  }

  @override
  String get serviceUnreachable => 'Tjenesten er utilgængelig';

  @override
  String syncStatusLabel(String status) {
    return 'Synkronisering: $status';
  }

  @override
  String syncPendingSuffix(int count) {
    return ' ($count afventer)';
  }

  @override
  String get localOnlyMode => 'Kun lokal tilstand (ingen Nostr-identitet)';

  @override
  String get syncStarted => 'Synkronisering startet';

  @override
  String syncUnavailable(String error) {
    return 'Synkronisering ikke tilgængelig: $error';
  }

  @override
  String get notSignedIn => 'Ikke logget ind';

  @override
  String get signInWithBrowserSubtitle =>
      'Log ind med din browser (NIP-07) for at synkronisere denne kalender via Nostr.';

  @override
  String get signedInBackgroundSigning =>
      'Logget ind — baggrundssignering via en delegeret nøgle';

  @override
  String get signedInRemoteSigner =>
      'Logget ind — ekstern underskriver (NIP-46)';

  @override
  String get signedInNoBackgroundSigner =>
      'Logget ind, men ingen baggrundsunderskriver er konfigureret — synkronisering forbliver på pause. Kør \"astraea-service auth provision-key\" i en terminal.';

  @override
  String couldNotStartLogin(String error) {
    return 'Kunne ikke starte login: $error';
  }

  @override
  String get signOutConfirmDesktopBody =>
      'Dette glemmer kun kontoen på denne enhed — dine begivenheder forbliver på relæerne. En eventuel klargjort signeringsnøgle fjernes fra nøgleringen.';

  @override
  String get signInWithBrowserTitle => 'Log ind med din browser';

  @override
  String get loginSessionExpired => 'Denne loginsession er udløbet. Prøv igen.';

  @override
  String get loginWaitingBody =>
      'Der blev åbnet en browserfane for at bekræfte din Nostr-identitet (NIP-07). Godkend det der — denne dialog lukker automatisk. Din private nøgle bliver aldrig anmodet om.';

  @override
  String get openAgain => 'Åbn igen';

  @override
  String get offlineWillRetry => 'Offline — prøver automatisk igen.';

  @override
  String get upToDate => 'Opdateret';

  @override
  String operationsFailingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mislykkede handlinger',
      one: '1 mislykket handling',
    );
    return '$_temp0';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count afventer',
      one: '1 afventer',
    );
    return '$_temp0';
  }

  @override
  String pendingFailingCount(String pending, String failing) {
    return '$pending, $failing';
  }

  @override
  String get relayStatus => 'Relæstatus';

  @override
  String get relaysLabel => 'Relæer';

  @override
  String relaysConfiguredLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count konfigureret',
      one: '1 konfigureret',
    );
    return '$_temp0';
  }

  @override
  String get unencryptedTransport => 'Ukrypteret transport';

  @override
  String couldNotReachService(String error) {
    return 'Kunne ikke få forbindelse til astraea-service: $error';
  }
}
