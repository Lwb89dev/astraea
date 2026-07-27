// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get appTitle => 'Astraea';

  @override
  String get cancel => 'Avbryt';

  @override
  String get save => 'Spara';

  @override
  String get delete => 'Ta bort';

  @override
  String get continueLabel => 'Fortsätt';

  @override
  String get next => 'Nästa';

  @override
  String get back => 'Tillbaka';

  @override
  String get loading => 'Laddar…';

  @override
  String get settingsTooltip => 'Inställningar';

  @override
  String get newEventButton => 'Ny händelse';

  @override
  String couldNotLoadEvents(String error) {
    return 'Det gick inte att läsa in händelser:\n$error';
  }

  @override
  String get viewMonth => 'Månad';

  @override
  String get viewWeek => 'Vecka';

  @override
  String get viewDay => 'Dag';

  @override
  String get viewList => 'Lista';

  @override
  String get noEventsToday => 'Inga händelser den här dagen.';

  @override
  String get noUpcomingEvents =>
      'Inga kommande händelser de närmaste 60 dagarna.';

  @override
  String get untitledEvent => '(utan titel)';

  @override
  String get allDay => 'Hela dagen';

  @override
  String get addAccountToSyncTooltip =>
      'Lägg till ett Nostr-konto för att synkronisera';

  @override
  String get syncNowTooltip => 'Synkronisera nu';

  @override
  String get addNostrAccountTitle => 'Lägg till ett Nostr-konto';

  @override
  String get eventNotFound => 'Händelsen hittades inte.';

  @override
  String get eventAppBarTitle => 'Händelse';

  @override
  String get editTooltip => 'Redigera';

  @override
  String get deleteTooltip => 'Ta bort';

  @override
  String allDayLabel(String date) {
    return '$date · Hela dagen';
  }

  @override
  String recurrenceUntilLabel(String recurrence, String date) {
    return '$recurrence · till $date';
  }

  @override
  String get syncedToRelays => 'Synkroniserad med reläer';

  @override
  String get notYetSynced => 'Ännu inte synkroniserad';

  @override
  String get deleteEventTitle => 'Ta bort händelsen?';

  @override
  String get deleteEventBody =>
      'Detta tar bort händelsen från den här enheten och begär borttagning från reläerna.';

  @override
  String get editEventTitle => 'Redigera händelse';

  @override
  String get newEventTitle => 'Ny händelse';

  @override
  String get fieldTitle => 'Titel';

  @override
  String get allDaySwitch => 'Hela dagen';

  @override
  String get startsLabel => 'Börjar';

  @override
  String get endsLabel => 'Slutar';

  @override
  String get timezoneLabel => 'Tidszon';

  @override
  String get repeatsLabel => 'Upprepning';

  @override
  String get untilLabel => 'Till';

  @override
  String get foreverLabel => 'För alltid';

  @override
  String get remindersLabel => 'Påminnelser';

  @override
  String get addChip => 'Lägg till';

  @override
  String get colorLabel => 'Färg';

  @override
  String get locationLabel => 'Plats';

  @override
  String get descriptionLabel => 'Beskrivning';

  @override
  String couldNotSaveEvent(String error) {
    return 'Det gick inte att spara händelsen: $error';
  }

  @override
  String get recurrenceNone => 'Upprepas inte';

  @override
  String get recurrenceDaily => 'Dagligen';

  @override
  String get recurrenceWeekly => 'Varje vecka';

  @override
  String get recurrenceMonthly => 'Varje månad';

  @override
  String get recurrenceYearly => 'Varje år';

  @override
  String get reminderAtStart => 'Vid start';

  @override
  String reminderMinutesBefore(int count) {
    return '$count min innan';
  }

  @override
  String reminderHoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count timmar innan',
      one: '1 timme innan',
    );
    return '$_temp0';
  }

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dagar innan',
      one: '1 dag innan',
    );
    return '$_temp0';
  }

  @override
  String get getStarted => 'Kom igång';

  @override
  String get useOffline => 'Använd offline';

  @override
  String get welcomeTitle => 'Välkommen till Astraea';

  @override
  String get welcomeSubtitle =>
      'En privat kalender, offline-först, som ger dig kontrollen.';

  @override
  String get featureLocalTitle => 'Din kalender stannar på din enhet';

  @override
  String get featureLocalBody =>
      'Skapa händelser, upprepningar och påminnelser utan konto eller internetanslutning.';

  @override
  String get featureSyncTitle => 'Valfri synkronisering via Nostr';

  @override
  String get featureSyncBody =>
      'Anslut ett konto för att säkerhetskopiera din kalender och använda den på flera enheter via reläer du själv väljer.';

  @override
  String get featureEncryptedTitle => 'Alltid krypterad före uppladdning';

  @override
  String get featureEncryptedBody =>
      'Kalenderinnehåll krypteras end-to-end innan det lämnar den här enheten. Reläoperatörer kan inte läsa det.';

  @override
  String get featureAmberTitle => 'Förvara din nyckel i Amber';

  @override
  String get featureAmberBody =>
      'På Android kan en extern signerare godkänna åtkomst utan att exponera din privata nyckel för Astraea.';

  @override
  String get featureRemindersTitle => 'Privata lokala påminnelser';

  @override
  String get featureRemindersBody =>
      'Aviseringar schemaläggs av din enhet och är inte beroende av en molnkalendertjänst.';

  @override
  String get connectNostrAccountTitle => 'Anslut ett Nostr-konto';

  @override
  String get connectNostrAccountBody =>
      'Detta behövs bara för krypterad synkronisering. Du kan även använda Astraea helt offline.';

  @override
  String get chooseRelaysTitle => 'Välj reläer för synkronisering';

  @override
  String get chooseRelaysBody =>
      'Reläer lagrar din krypterade kalender och gör den tillgänglig på dina andra enheter. Lägg till en eller flera, eller lämna listan tom och konfigurera det senare.';

  @override
  String couldNotLoadRelaySettings(String error) {
    return 'Det gick inte att läsa in reläinställningar: $error';
  }

  @override
  String get suggestedRelays => 'Föreslagna';

  @override
  String get addRelayTooltip => 'Lägg till relä';

  @override
  String get customRelayLabel => 'Anpassat relä';

  @override
  String get customRelayHint => 'wss://relay.example.com';

  @override
  String get selectedRelays => 'Valda';

  @override
  String get removeRelayTooltip => 'Ta bort relä';

  @override
  String get invalidRelayUrl =>
      'Ange en giltig wss://-URL (eller ws:// för ett privat relä).';

  @override
  String get insecureRelayWarning =>
      'ws:// är okrypterat under överföring — använd det bara för ett relä du litar på.';

  @override
  String get nostrAccountConnected => 'Nostr-konto anslutet';

  @override
  String get invalidPrivateKey =>
      'Den privata nyckeln är inte giltig. Kontrollera den och försök igen.';

  @override
  String couldNotSignIn(String error) {
    return 'Det gick inte att logga in: $error';
  }

  @override
  String get signInWithAmber => 'Logga in med Amber';

  @override
  String get createNewAccount => 'Skapa ett nytt konto';

  @override
  String get generatedAccountWarning =>
      'Ett genererat konto kan bara återställas med sin privata nyckel. Säkerhetskopiera den från Inställningar efter konfigurationen.';

  @override
  String get importExistingKey => 'Importera en befintlig nyckel';

  @override
  String get privateKeyFieldLabel => 'nsec eller hexadecimal privat nyckel';

  @override
  String get importButton => 'Importera';

  @override
  String get followDeviceTimezone => 'Följ enhetens tidszon';

  @override
  String get searchCityRegion => 'Sök efter en stad eller region';

  @override
  String get noMatchingTimezone => 'Ingen matchande tidszon.';

  @override
  String get settingsTitle => 'Inställningar';

  @override
  String couldNotLoadSettings(String error) {
    return 'Det gick inte att läsa in inställningar:\n$error';
  }

  @override
  String get sectionAccount => 'Konto';

  @override
  String get sectionSync => 'Synkronisering';

  @override
  String get sectionRelays => 'Reläer';

  @override
  String get sectionAppearance => 'Utseende';

  @override
  String get sectionData => 'Data';

  @override
  String get sectionRemindersTimezone => 'Påminnelser och tidszon';

  @override
  String get sectionSupport => 'Support';

  @override
  String somethingWentWrong(String error) {
    return 'Något gick fel: $error';
  }

  @override
  String get offlineNoAccount => 'Offline — inget konto';

  @override
  String get signInToSyncAcrossDevices =>
      'Logga in för att synkronisera din krypterade kalender mellan enheter.';

  @override
  String get signIn => 'Logga in';

  @override
  String get signedInWithAmber => 'Inloggad med Amber';

  @override
  String get signedIn => 'Inloggad';

  @override
  String get signOut => 'Logga ut';

  @override
  String get backUpPrivateKey => 'Säkerhetskopiera privat nyckel';

  @override
  String get revealNsecSubtitle =>
      'Visa din nsec för att spara den på ett säkert ställe';

  @override
  String get signOutTitle => 'Logga ut?';

  @override
  String get signOutBody =>
      'Dina händelser finns kvar på den här enheten och på reläerna. Se till att du har säkerhetskopierat din privata nyckel — utan den kan ett genererat konto inte återställas.';

  @override
  String get noPrivateKeyStored =>
      'Ingen privat nyckel sparad för den här sessionen.';

  @override
  String get yourPrivateKeyTitle => 'Din privata nyckel (nsec)';

  @override
  String get nsecWarning =>
      'Alla som har den här nyckeln har kontroll över ditt konto. Dela den aldrig; förvara den i en lösenordshanterare.';

  @override
  String get copy => 'Kopiera';

  @override
  String get done => 'Klar';

  @override
  String get syncNowTitle => 'Synkronisera nu';

  @override
  String get signInToSyncSubtitle =>
      'Logga in för att synkronisera din krypterade kalender.';

  @override
  String get addRelayToSyncSubtitle =>
      'Lägg till minst ett relä för att synkronisera.';

  @override
  String get syncingEllipsis => 'Synkroniserar…';

  @override
  String get synced => 'Synkroniserad';

  @override
  String lastSyncedLabel(String when) {
    return 'Senast synkroniserad $when';
  }

  @override
  String lastSyncFailedLabel(String error) {
    return 'Senaste synkroniseringen misslyckades: $error';
  }

  @override
  String get pullMergePublish =>
      'Hämtar, sammanfogar och publicerar dina händelser';

  @override
  String get publicRelays => 'Offentliga reläer';

  @override
  String relaysConfiguredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count konfigurerade',
      one: '1 konfigurerat',
    );
    return '$_temp0';
  }

  @override
  String get addRelay => 'Lägg till relä';

  @override
  String get suggestedRelaysTitle => 'Föreslagna reläer';

  @override
  String get addOnlyRelaysYouWant =>
      'Lägg bara till de reläer du vill använda.';

  @override
  String get homeRelayBackup => 'Personligt relä (säkerhetskopia)';

  @override
  String get homeRelayNotConfigured =>
      'Inte konfigurerat — ett extra personligt relä för att säkerhetskopiera dina händelser';

  @override
  String get homeRelayDialogTitle => 'Personligt relä';

  @override
  String get lightTheme => 'Ljust tema';

  @override
  String get darkThemeDefault => 'Astraea använder mörkt tema som standard';

  @override
  String get languageLabel => 'Språk';

  @override
  String get systemLanguage => 'Systemspråk';

  @override
  String get exportEvents => 'Exportera händelser';

  @override
  String get exportEventsSubtitle =>
      'Spara en .ics-fil — valfritt lösenordsskyddad';

  @override
  String get importEvents => 'Importera händelser';

  @override
  String get importEventsSubtitle =>
      'Från en .ics-fil eller en krypterad Astraea-export';

  @override
  String get encryptExportTitle => 'Kryptera denna export?';

  @override
  String get encryptExportBody =>
      'En vanlig .ics-fil kan öppnas av vilken kalenderapp som helst — och av alla som får tag i filen. Ange ett lösenord för att kryptera den (endast Astraea kan importera den igen).';

  @override
  String get exportPasswordLabel =>
      'Lösenord (lämna tomt för en vanlig .ics-fil)';

  @override
  String get export => 'Exportera';

  @override
  String get encryptedExportSaved => 'Krypterad export sparad.';

  @override
  String get exportSaved => 'Export sparad.';

  @override
  String exportFailed(String error) {
    return 'Export misslyckades: $error';
  }

  @override
  String get couldNotReadSelectedFile =>
      'Det gick inte att läsa den valda filen.';

  @override
  String get selectedFileTooLarge => 'Den valda filen är större än 10 MB.';

  @override
  String importedEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count händelser importerade.',
      one: '1 händelse importerad.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(String error) {
    return 'Import misslyckades: $error';
  }

  @override
  String get thisExportIsEncrypted => 'Den här exporten är krypterad';

  @override
  String get passwordLabel => 'Lösenord';

  @override
  String get wrongPassword => 'Fel lösenord.';

  @override
  String get invalidEncryptedExport =>
      'Den här krypterade exporten är inte giltig.';

  @override
  String get reminders => 'Påminnelser';

  @override
  String get scheduleLocalNotifications =>
      'Schemalägg lokala aviseringar för händelsepåminnelser';

  @override
  String get timezone => 'Tidszon';

  @override
  String followDeviceTimezoneWithName(String zone) {
    return 'Följ enhetens tidszon ($zone)';
  }

  @override
  String get supportAstraea => 'Stöd Astraea';

  @override
  String noLightningWalletFound(String address) {
    return 'Ingen Lightning-plånbok hittades — adress kopierad: $address';
  }

  @override
  String get desktopServiceUnreachableTitle =>
      'Astraeas bakgrundstjänst är inte tillgänglig';

  @override
  String get desktopServiceUnreachableBody =>
      'Skrivbordsappen kommunicerar med astraea-service via D-Bus för lagring, synkronisering och aviseringar, och den gick inte att nå. Om du kör från källkoden installerar du den med:\n\n./scripts/install-dev.sh';

  @override
  String get retry => 'Försök igen';

  @override
  String get calendarsLabel => 'Kalendrar';

  @override
  String calendarsUnavailable(String error) {
    return 'Kalendrar inte tillgängliga: $error';
  }

  @override
  String get serviceUnreachable => 'Tjänsten är inte nåbar';

  @override
  String syncStatusLabel(String status) {
    return 'Synkronisering: $status';
  }

  @override
  String syncPendingSuffix(int count) {
    return ' ($count väntande)';
  }

  @override
  String get localOnlyMode => 'Endast lokalt läge (ingen Nostr-identitet)';

  @override
  String get syncStarted => 'Synkronisering startad';

  @override
  String syncUnavailable(String error) {
    return 'Synkronisering inte tillgänglig: $error';
  }

  @override
  String get notSignedIn => 'Inte inloggad';

  @override
  String get signInWithBrowserSubtitle =>
      'Logga in med din webbläsare (NIP-07) för att synkronisera den här kalendern via Nostr.';

  @override
  String get signedInBackgroundSigning =>
      'Inloggad — bakgrundssignering via en delegerad nyckel';

  @override
  String get signedInRemoteSigner => 'Inloggad — extern signerare (NIP-46)';

  @override
  String get signedInNoBackgroundSigner =>
      'Inloggad, men ingen bakgrundssignerare är konfigurerad — synkroniseringen förblir pausad. Kör \"astraea-service auth provision-key\" i en terminal.';

  @override
  String couldNotStartLogin(String error) {
    return 'Det gick inte att starta inloggningen: $error';
  }

  @override
  String get signOutConfirmDesktopBody =>
      'Detta glömmer kontot endast på den här enheten — dina händelser finns kvar på reläerna. En eventuell tillhandahållen signeringsnyckel tas bort från nyckelringen.';

  @override
  String get signInWithBrowserTitle => 'Logga in med din webbläsare';

  @override
  String get loginSessionExpired =>
      'Den här inloggningssessionen har gått ut. Försök igen.';

  @override
  String get loginWaitingBody =>
      'En webbläsarflik öppnades för att bekräfta din Nostr-identitet (NIP-07). Godkänn den där — dialogrutan stängs automatiskt. Din privata nyckel efterfrågas aldrig.';

  @override
  String get openAgain => 'Öppna igen';

  @override
  String get offlineWillRetry => 'Offline — försöker igen automatiskt.';

  @override
  String get upToDate => 'Uppdaterad';

  @override
  String operationsFailingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count misslyckade åtgärder',
      one: '1 misslyckad åtgärd',
    );
    return '$_temp0';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count väntande',
      one: '1 väntande',
    );
    return '$_temp0';
  }

  @override
  String pendingFailingCount(String pending, String failing) {
    return '$pending, $failing';
  }

  @override
  String get relayStatus => 'Relästatus';

  @override
  String get relaysLabel => 'Reläer';

  @override
  String relaysConfiguredLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count konfigurerade',
      one: '1 konfigurerat',
    );
    return '$_temp0';
  }

  @override
  String get unencryptedTransport => 'Okrypterad överföring';

  @override
  String couldNotReachService(String error) {
    return 'Det gick inte att nå astraea-service: $error';
  }

  @override
  String get inviteSectionTitle => 'Deltagare';

  @override
  String get inviteButtonLabel => 'Bjud in';

  @override
  String get noAttendeesYet => 'Ingen har bjudits in ännu';

  @override
  String get inviteDialogTitle => 'Bjud in någon';

  @override
  String get inviteDialogHint => 'npub, namn@domän eller publik nyckel';

  @override
  String resolvePersonFailed(String error) {
    return 'Kunde inte hitta den personen: $error';
  }

  @override
  String get confirmNip05Title => 'Bekräfta mottagare';

  @override
  String confirmNip05Body(String query, String pubkey) {
    return '$query matchades till $pubkey via NIP-05. Denna koppling styrs av domänen — se till att det är den förväntade personen.';
  }

  @override
  String get attendeeStatusInvited => 'Inbjuden';

  @override
  String get attendeeStatusAccepted => 'Accepterad';

  @override
  String get attendeeStatusDeclined => 'Avböjd';

  @override
  String inviteFailed(String error) {
    return 'Kunde inte skicka inbjudan: $error';
  }

  @override
  String get pendingInvitationsTooltip => 'Inbjudningar';

  @override
  String get pendingInvitationsTitle => 'Inbjudningar';

  @override
  String get pendingInvitationsEmpty => 'Inga väntande inbjudningar';

  @override
  String invitationFromLabel(String pubkey) {
    return 'Från $pubkey';
  }

  @override
  String get acceptInvitation => 'Acceptera';

  @override
  String get declineInvitation => 'Avböj';

  @override
  String respondToInvitationFailed(String error) {
    return 'Kunde inte svara: $error';
  }

  @override
  String get invitationAccepted => 'Inbjudan accepterad';

  @override
  String get invitationDeclined => 'Inbjudan avböjd';
}
