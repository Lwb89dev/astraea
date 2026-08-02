// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Astraea';

  @override
  String get cancel => 'Annuleren';

  @override
  String get save => 'Opslaan';

  @override
  String get delete => 'Verwijderen';

  @override
  String get continueLabel => 'Doorgaan';

  @override
  String get next => 'Volgende';

  @override
  String get back => 'Terug';

  @override
  String get loading => 'Bezig met laden…';

  @override
  String get settingsTooltip => 'Instellingen';

  @override
  String get newEventButton => 'Nieuwe afspraak';

  @override
  String couldNotLoadEvents(String error) {
    return 'Kon afspraken niet laden:\n$error';
  }

  @override
  String get viewMonth => 'Maand';

  @override
  String get viewWeek => 'Week';

  @override
  String get viewDay => 'Dag';

  @override
  String get viewList => 'Lijst';

  @override
  String get noEventsToday => 'Geen afspraken op deze dag.';

  @override
  String get noUpcomingEvents =>
      'Geen aankomende afspraken in de volgende 60 dagen.';

  @override
  String get untitledEvent => '(zonder titel)';

  @override
  String get allDay => 'Hele dag';

  @override
  String get addAccountToSyncTooltip =>
      'Nostr-account toevoegen om te synchroniseren';

  @override
  String get syncNowTooltip => 'Nu synchroniseren';

  @override
  String get addNostrAccountTitle => 'Nostr-account toevoegen';

  @override
  String get eventNotFound => 'Afspraak niet gevonden.';

  @override
  String get eventAppBarTitle => 'Afspraak';

  @override
  String get editTooltip => 'Bewerken';

  @override
  String get deleteTooltip => 'Verwijderen';

  @override
  String allDayLabel(String date) {
    return '$date · Hele dag';
  }

  @override
  String recurrenceUntilLabel(String recurrence, String date) {
    return '$recurrence · tot $date';
  }

  @override
  String get syncedToRelays => 'Gesynchroniseerd met relays';

  @override
  String get notYetSynced => 'Nog niet gesynchroniseerd';

  @override
  String get deleteEventTitle => 'Afspraak verwijderen?';

  @override
  String get deleteEventBody =>
      'Dit verwijdert de afspraak van dit apparaat en vraagt om verwijdering bij de relays.';

  @override
  String get editEventTitle => 'Afspraak bewerken';

  @override
  String get newEventTitle => 'Nieuwe afspraak';

  @override
  String get fieldTitle => 'Titel';

  @override
  String get allDaySwitch => 'Hele dag';

  @override
  String get startsLabel => 'Begint';

  @override
  String get endsLabel => 'Eindigt';

  @override
  String get timezoneLabel => 'Tijdzone';

  @override
  String get repeatsLabel => 'Herhaling';

  @override
  String get untilLabel => 'Tot';

  @override
  String get foreverLabel => 'Voor altijd';

  @override
  String get remindersLabel => 'Herinneringen';

  @override
  String get addChip => 'Toevoegen';

  @override
  String get colorLabel => 'Kleur';

  @override
  String get locationLabel => 'Locatie';

  @override
  String get descriptionLabel => 'Beschrijving';

  @override
  String couldNotSaveEvent(String error) {
    return 'Kon afspraak niet opslaan: $error';
  }

  @override
  String get recurrenceNone => 'Herhaalt niet';

  @override
  String get recurrenceDaily => 'Dagelijks';

  @override
  String get recurrenceWeekly => 'Wekelijks';

  @override
  String get recurrenceMonthly => 'Maandelijks';

  @override
  String get recurrenceYearly => 'Jaarlijks';

  @override
  String get reminderAtStart => 'Bij aanvang';

  @override
  String reminderMinutesBefore(int count) {
    return '$count min. van tevoren';
  }

  @override
  String reminderHoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uur van tevoren',
      one: '1 uur van tevoren',
    );
    return '$_temp0';
  }

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dagen van tevoren',
      one: '1 dag van tevoren',
    );
    return '$_temp0';
  }

  @override
  String get getStarted => 'Aan de slag';

  @override
  String get useOffline => 'Offline gebruiken';

  @override
  String get welcomeTitle => 'Welkom bij Astraea';

  @override
  String get welcomeSubtitle =>
      'Een privé, offline-first agenda die jou de controle geeft.';

  @override
  String get featureLocalTitle => 'Je agenda blijft op je apparaat';

  @override
  String get featureLocalBody =>
      'Maak afspraken, herhalingen en herinneringen zonder account of internetverbinding.';

  @override
  String get featureSyncTitle => 'Optionele synchronisatie via Nostr';

  @override
  String get featureSyncBody =>
      'Verbind een account om je agenda te back-uppen en op meerdere apparaten te gebruiken via relays die jij kiest.';

  @override
  String get featureEncryptedTitle => 'Altijd versleuteld voor het uploaden';

  @override
  String get featureEncryptedBody =>
      'Agenda-inhoud wordt end-to-end versleuteld voordat het dit apparaat verlaat. Relay-beheerders kunnen het niet lezen.';

  @override
  String get featureAmberTitle => 'Bewaar je sleutel in Amber';

  @override
  String get featureAmberBody =>
      'Op Android kan een externe ondertekenaar toegang goedkeuren zonder je privésleutel aan Astraea bloot te stellen.';

  @override
  String get featureRemindersTitle => 'Privé lokale herinneringen';

  @override
  String get featureRemindersBody =>
      'Meldingen worden door je apparaat gepland en zijn niet afhankelijk van een cloudagendadienst.';

  @override
  String get connectNostrAccountTitle => 'Nostr-account verbinden';

  @override
  String get connectNostrAccountBody =>
      'Dit is alleen nodig voor versleutelde synchronisatie. Je kunt Astraea ook volledig offline gebruiken.';

  @override
  String get chooseRelaysTitle => 'Kies relays voor synchronisatie';

  @override
  String get chooseRelaysBody =>
      'Relays bewaren je versleutelde agenda en maken deze beschikbaar op je andere apparaten. Voeg er een of meer toe, of laat de lijst leeg en configureer dit later.';

  @override
  String couldNotLoadRelaySettings(String error) {
    return 'Kon relay-instellingen niet laden: $error';
  }

  @override
  String get suggestedRelays => 'Voorgesteld';

  @override
  String get addRelayTooltip => 'Relay toevoegen';

  @override
  String get customRelayLabel => 'Aangepaste relay';

  @override
  String get customRelayHint => 'wss://relay.example.com';

  @override
  String get selectedRelays => 'Geselecteerd';

  @override
  String get removeRelayTooltip => 'Relay verwijderen';

  @override
  String get invalidRelayUrl =>
      'Voer een geldige wss://-URL in (of ws:// voor een privérelay).';

  @override
  String get insecureRelayWarning =>
      'ws:// is onversleuteld tijdens transport — gebruik dit alleen voor een relay die je vertrouwt.';

  @override
  String get nostrAccountConnected => 'Nostr-account verbonden';

  @override
  String get invalidPrivateKey =>
      'Die privésleutel is niet geldig. Controleer deze en probeer het opnieuw.';

  @override
  String couldNotSignIn(String error) {
    return 'Kon niet inloggen: $error';
  }

  @override
  String get signInWithAmber => 'Inloggen met Amber';

  @override
  String get createNewAccount => 'Nieuw account aanmaken';

  @override
  String get generatedAccountWarning =>
      'Een gegenereerd account kan alleen worden hersteld met de bijbehorende privésleutel. Maak er na het instellen een back-up van via Instellingen.';

  @override
  String get importExistingKey => 'Bestaande sleutel importeren';

  @override
  String get privateKeyFieldLabel => 'nsec of hexadecimale privésleutel';

  @override
  String get importButton => 'Importeren';

  @override
  String get signInWithRemoteSigner => 'Sign in with a remote signer';

  @override
  String get remoteSignerFieldLabel => 'bunker:// connection string';

  @override
  String get remoteSignerHelp =>
      'Paste the bunker:// string from your signer (Amber, nsec.app, nostrify, your own bunker). Astraea only stores a throwaway key for this device — never your private key.';

  @override
  String get remoteSignerConnect => 'Connect';

  @override
  String get remoteSignerConnecting =>
      'Waiting for your signer to approve the connection…';

  @override
  String get invalidBunkerUri =>
      'That is not a valid bunker:// connection string.';

  @override
  String get remoteSignerApprovalOpened =>
      'Approve the connection in the page that just opened, then come back.';

  @override
  String get remoteSignerDisconnected =>
      'The remote signer is not connected. Sign in again.';

  @override
  String get followDeviceTimezone => 'Tijdzone van apparaat volgen';

  @override
  String get searchCityRegion => 'Zoek een stad of regio';

  @override
  String get noMatchingTimezone => 'Geen overeenkomende tijdzone.';

  @override
  String get settingsTitle => 'Instellingen';

  @override
  String couldNotLoadSettings(String error) {
    return 'Kon instellingen niet laden:\n$error';
  }

  @override
  String get sectionAccount => 'Account';

  @override
  String get sectionSync => 'Synchronisatie';

  @override
  String get sectionRelays => 'Relays';

  @override
  String get sectionAppearance => 'Weergave';

  @override
  String get sectionData => 'Gegevens';

  @override
  String get sectionRemindersTimezone => 'Herinneringen en tijdzone';

  @override
  String get sectionSupport => 'Ondersteuning';

  @override
  String somethingWentWrong(String error) {
    return 'Er is iets misgegaan: $error';
  }

  @override
  String get offlineNoAccount => 'Offline — geen account';

  @override
  String get signInToSyncAcrossDevices =>
      'Log in om je versleutelde agenda tussen apparaten te synchroniseren.';

  @override
  String get signIn => 'Inloggen';

  @override
  String get signedInWithAmber => 'Ingelogd met Amber';

  @override
  String get signedIn => 'Ingelogd';

  @override
  String get signOut => 'Uitloggen';

  @override
  String get backUpPrivateKey => 'Privésleutel back-uppen';

  @override
  String get revealNsecSubtitle => 'Toon je nsec om deze veilig te bewaren';

  @override
  String get signOutTitle => 'Uitloggen?';

  @override
  String get signOutBody =>
      'Je afspraken blijven op dit apparaat en op de relays. Zorg dat je een back-up hebt van je privésleutel — zonder deze kan een gegenereerd account niet worden hersteld.';

  @override
  String get noPrivateKeyStored =>
      'Geen privésleutel opgeslagen voor deze sessie.';

  @override
  String get yourPrivateKeyTitle => 'Je privésleutel (nsec)';

  @override
  String get nsecWarning =>
      'Iedereen met deze sleutel heeft controle over je account. Deel deze nooit; bewaar hem in een wachtwoordbeheerder.';

  @override
  String get copy => 'Kopiëren';

  @override
  String get done => 'Klaar';

  @override
  String get syncNowTitle => 'Nu synchroniseren';

  @override
  String get signInToSyncSubtitle =>
      'Log in om je versleutelde agenda te synchroniseren.';

  @override
  String get addRelayToSyncSubtitle =>
      'Voeg minstens één relay toe om te synchroniseren.';

  @override
  String get syncingEllipsis => 'Bezig met synchroniseren…';

  @override
  String get synced => 'Gesynchroniseerd';

  @override
  String lastSyncedLabel(String when) {
    return 'Laatst gesynchroniseerd op $when';
  }

  @override
  String lastSyncFailedLabel(String error) {
    return 'Laatste synchronisatie mislukt: $error';
  }

  @override
  String get pullMergePublish =>
      'Haalt je afspraken op, voegt ze samen en publiceert ze';

  @override
  String get publicRelays => 'Openbare relays';

  @override
  String relaysConfiguredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count geconfigureerd',
      one: '1 geconfigureerd',
    );
    return '$_temp0';
  }

  @override
  String get addRelay => 'Relay toevoegen';

  @override
  String get suggestedRelaysTitle => 'Voorgestelde relays';

  @override
  String get addOnlyRelaysYouWant =>
      'Voeg alleen relays toe die je wilt gebruiken.';

  @override
  String get homeRelayBackup => 'Persoonlijke relay (back-up)';

  @override
  String get homeRelayNotConfigured =>
      'Niet geconfigureerd — een extra persoonlijke relay om je afspraken te back-uppen';

  @override
  String get homeRelayDialogTitle => 'Persoonlijke relay';

  @override
  String get lightTheme => 'Licht thema';

  @override
  String get darkThemeDefault => 'Astraea gebruikt standaard het donkere thema';

  @override
  String get languageLabel => 'Taal';

  @override
  String get systemLanguage => 'Systeemtaal';

  @override
  String get accentColorLabel => 'Accentkleur';

  @override
  String get accentNavy => 'Marineblauw';

  @override
  String get accentBitcoin => 'Bitcoin-oranje';

  @override
  String get accentNostr => 'Nostr-paars';

  @override
  String get exportEvents => 'Afspraken exporteren';

  @override
  String get exportEventsSubtitle =>
      'Een .ics-bestand opslaan — optioneel met wachtwoord beveiligd';

  @override
  String get importEvents => 'Afspraken importeren';

  @override
  String get importEventsSubtitle =>
      'Vanuit een .ics-bestand of een versleutelde Astraea-export';

  @override
  String get encryptExportTitle => 'Deze export versleutelen?';

  @override
  String get encryptExportBody =>
      'Een gewoon .ics-bestand kan door elke agenda-app worden geopend — en door iedereen die het bestand bemachtigt. Stel een wachtwoord in om het te versleutelen (alleen Astraea kan het dan weer importeren).';

  @override
  String get exportPasswordLabel =>
      'Wachtwoord (leeg laten voor een gewoon .ics-bestand)';

  @override
  String get export => 'Exporteren';

  @override
  String get encryptedExportSaved => 'Versleutelde export opgeslagen.';

  @override
  String get exportSaved => 'Export opgeslagen.';

  @override
  String exportFailed(String error) {
    return 'Exporteren mislukt: $error';
  }

  @override
  String get couldNotReadSelectedFile =>
      'Kon het geselecteerde bestand niet lezen.';

  @override
  String get selectedFileTooLarge =>
      'Het geselecteerde bestand is groter dan 10 MB.';

  @override
  String importedEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count afspraken geïmporteerd.',
      one: '1 afspraak geïmporteerd.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(String error) {
    return 'Importeren mislukt: $error';
  }

  @override
  String get thisExportIsEncrypted => 'Deze export is versleuteld';

  @override
  String get passwordLabel => 'Wachtwoord';

  @override
  String get wrongPassword => 'Onjuist wachtwoord.';

  @override
  String get invalidEncryptedExport => 'Deze versleutelde export is ongeldig.';

  @override
  String get reminders => 'Herinneringen';

  @override
  String get scheduleLocalNotifications =>
      'Lokale meldingen plannen voor afspraakherinneringen';

  @override
  String get timezone => 'Tijdzone';

  @override
  String followDeviceTimezoneWithName(String zone) {
    return 'Tijdzone van apparaat volgen ($zone)';
  }

  @override
  String get supportAstraea => 'Astraea ondersteunen';

  @override
  String noLightningWalletFound(String address) {
    return 'Geen Lightning-wallet gevonden — adres gekopieerd: $address';
  }

  @override
  String get desktopServiceUnreachableTitle =>
      'Astraea-achtergrondservice niet beschikbaar';

  @override
  String get desktopServiceUnreachableBody =>
      'De desktop-app communiceert via D-Bus met astraea-service voor opslag, synchronisatie en meldingen, en kon niet worden bereikt. Als je vanuit de broncode draait, installeer het dan met:\n\n./scripts/install-dev.sh';

  @override
  String get retry => 'Opnieuw proberen';

  @override
  String get calendarsLabel => 'Agenda\'s';

  @override
  String calendarsUnavailable(String error) {
    return 'Agenda\'s niet beschikbaar: $error';
  }

  @override
  String get serviceUnreachable => 'Service niet bereikbaar';

  @override
  String syncStatusLabel(String status) {
    return 'Synchronisatie: $status';
  }

  @override
  String syncPendingSuffix(int count) {
    return ' ($count in behandeling)';
  }

  @override
  String get localOnlyMode => 'Alleen-lokale modus (geen Nostr-identiteit)';

  @override
  String get syncStarted => 'Synchronisatie gestart';

  @override
  String syncUnavailable(String error) {
    return 'Synchronisatie niet beschikbaar: $error';
  }

  @override
  String get notSignedIn => 'Niet ingelogd';

  @override
  String get signInWithBrowserSubtitle =>
      'Log in met je browser (NIP-07) om deze agenda via Nostr te synchroniseren.';

  @override
  String get signedInBackgroundSigning =>
      'Ingelogd — ondertekening op de achtergrond via een gedelegeerde sleutel';

  @override
  String get signedInRemoteSigner =>
      'Ingelogd — externe ondertekenaar (NIP-46)';

  @override
  String get signedInNoBackgroundSigner =>
      'Ingelogd, maar er is geen achtergrondondertekenaar geconfigureerd — synchronisatie blijft gepauzeerd. Voer \"astraea-service auth provision-key\" uit in een terminal.';

  @override
  String couldNotStartLogin(String error) {
    return 'Kon inloggen niet starten: $error';
  }

  @override
  String get signOutConfirmDesktopBody =>
      'Dit vergeet het account alleen op dit apparaat — je afspraken blijven op de relays. Een eventueel geconfigureerde ondertekeningssleutel wordt uit de sleutelbos verwijderd.';

  @override
  String get signInWithBrowserTitle => 'Log in met je browser';

  @override
  String get loginSessionExpired =>
      'Deze inlogsessie is verlopen. Probeer het opnieuw.';

  @override
  String get loginWaitingBody =>
      'Er is een browsertabblad geopend om je Nostr-identiteit te bevestigen (NIP-07). Keur dit daar goed — dit venster sluit automatisch. Je privésleutel wordt nooit opgevraagd.';

  @override
  String get openAgain => 'Opnieuw openen';

  @override
  String get offlineWillRetry => 'Offline — probeert automatisch opnieuw.';

  @override
  String get upToDate => 'Up-to-date';

  @override
  String operationsFailingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mislukte bewerkingen',
      one: '1 mislukte bewerking',
    );
    return '$_temp0';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count in behandeling',
      one: '1 in behandeling',
    );
    return '$_temp0';
  }

  @override
  String pendingFailingCount(String pending, String failing) {
    return '$pending, $failing';
  }

  @override
  String get relayStatus => 'Relaystatus';

  @override
  String get relaysLabel => 'Relays';

  @override
  String relaysConfiguredLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count geconfigureerd',
      one: '1 geconfigureerd',
    );
    return '$_temp0';
  }

  @override
  String get unencryptedTransport => 'Onversleuteld transport';

  @override
  String couldNotReachService(String error) {
    return 'Kon astraea-service niet bereiken: $error';
  }

  @override
  String get inviteSectionTitle => 'Deelnemers';

  @override
  String get inviteButtonLabel => 'Uitnodigen';

  @override
  String get noAttendeesYet => 'Nog niemand uitgenodigd';

  @override
  String get inviteDialogTitle => 'Iemand uitnodigen';

  @override
  String get inviteDialogHint => 'npub, naam@domein of publieke sleutel';

  @override
  String resolvePersonFailed(String error) {
    return 'Kon die persoon niet vinden: $error';
  }

  @override
  String get confirmNip05Title => 'Ontvanger bevestigen';

  @override
  String confirmNip05Body(String query, String pubkey) {
    return '$query werd via NIP-05 herleid tot $pubkey. Deze koppeling wordt beheerd door het domein — controleer of dit de verwachte persoon is.';
  }

  @override
  String get attendeeStatusInvited => 'Uitgenodigd';

  @override
  String get attendeeStatusAccepted => 'Geaccepteerd';

  @override
  String get attendeeStatusDeclined => 'Geweigerd';

  @override
  String inviteFailed(String error) {
    return 'Kon de uitnodiging niet versturen: $error';
  }

  @override
  String get pendingInvitationsTooltip => 'Uitnodigingen';

  @override
  String get pendingInvitationsTitle => 'Uitnodigingen';

  @override
  String get pendingInvitationsEmpty => 'Geen openstaande uitnodigingen';

  @override
  String invitationFromLabel(String pubkey) {
    return 'Van $pubkey';
  }

  @override
  String get acceptInvitation => 'Accepteren';

  @override
  String get declineInvitation => 'Weigeren';

  @override
  String respondToInvitationFailed(String error) {
    return 'Kon niet reageren: $error';
  }

  @override
  String get invitationAccepted => 'Uitnodiging geaccepteerd';

  @override
  String get invitationDeclined => 'Uitnodiging geweigerd';
}
