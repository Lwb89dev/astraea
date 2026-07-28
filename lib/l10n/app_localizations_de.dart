// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Astraea';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get delete => 'Löschen';

  @override
  String get continueLabel => 'Weiter';

  @override
  String get next => 'Weiter';

  @override
  String get back => 'Zurück';

  @override
  String get loading => 'Wird geladen…';

  @override
  String get settingsTooltip => 'Einstellungen';

  @override
  String get newEventButton => 'Neuer Termin';

  @override
  String couldNotLoadEvents(String error) {
    return 'Termine konnten nicht geladen werden:\n$error';
  }

  @override
  String get viewMonth => 'Monat';

  @override
  String get viewWeek => 'Woche';

  @override
  String get viewDay => 'Tag';

  @override
  String get viewList => 'Liste';

  @override
  String get noEventsToday => 'Keine Termine an diesem Tag.';

  @override
  String get noUpcomingEvents =>
      'Keine anstehenden Termine in den nächsten 60 Tagen.';

  @override
  String get untitledEvent => '(ohne Titel)';

  @override
  String get allDay => 'Ganztägig';

  @override
  String get addAccountToSyncTooltip =>
      'Nostr-Konto zum Synchronisieren hinzufügen';

  @override
  String get syncNowTooltip => 'Jetzt synchronisieren';

  @override
  String get addNostrAccountTitle => 'Nostr-Konto hinzufügen';

  @override
  String get eventNotFound => 'Termin nicht gefunden.';

  @override
  String get eventAppBarTitle => 'Termin';

  @override
  String get editTooltip => 'Bearbeiten';

  @override
  String get deleteTooltip => 'Löschen';

  @override
  String allDayLabel(String date) {
    return '$date · Ganztägig';
  }

  @override
  String recurrenceUntilLabel(String recurrence, String date) {
    return '$recurrence · bis $date';
  }

  @override
  String get syncedToRelays => 'Mit Relays synchronisiert';

  @override
  String get notYetSynced => 'Noch nicht synchronisiert';

  @override
  String get deleteEventTitle => 'Termin löschen?';

  @override
  String get deleteEventBody =>
      'Dies entfernt den Termin von diesem Gerät und fordert die Löschung bei den Relays an.';

  @override
  String get editEventTitle => 'Termin bearbeiten';

  @override
  String get newEventTitle => 'Neuer Termin';

  @override
  String get fieldTitle => 'Titel';

  @override
  String get allDaySwitch => 'Ganztägig';

  @override
  String get startsLabel => 'Beginn';

  @override
  String get endsLabel => 'Ende';

  @override
  String get timezoneLabel => 'Zeitzone';

  @override
  String get repeatsLabel => 'Wiederholung';

  @override
  String get untilLabel => 'Bis';

  @override
  String get foreverLabel => 'Für immer';

  @override
  String get remindersLabel => 'Erinnerungen';

  @override
  String get addChip => 'Hinzufügen';

  @override
  String get colorLabel => 'Farbe';

  @override
  String get locationLabel => 'Ort';

  @override
  String get descriptionLabel => 'Beschreibung';

  @override
  String couldNotSaveEvent(String error) {
    return 'Termin konnte nicht gespeichert werden: $error';
  }

  @override
  String get recurrenceNone => 'Wiederholt sich nicht';

  @override
  String get recurrenceDaily => 'Täglich';

  @override
  String get recurrenceWeekly => 'Wöchentlich';

  @override
  String get recurrenceMonthly => 'Monatlich';

  @override
  String get recurrenceYearly => 'Jährlich';

  @override
  String get reminderAtStart => 'Zu Beginn';

  @override
  String reminderMinutesBefore(int count) {
    return '$count Min. vorher';
  }

  @override
  String reminderHoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Stunden vorher',
      one: '1 Stunde vorher',
    );
    return '$_temp0';
  }

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage vorher',
      one: '1 Tag vorher',
    );
    return '$_temp0';
  }

  @override
  String get getStarted => 'Loslegen';

  @override
  String get useOffline => 'Offline nutzen';

  @override
  String get welcomeTitle => 'Willkommen bei Astraea';

  @override
  String get welcomeSubtitle =>
      'Ein privater, offline-first Kalender, der dir die Kontrolle überlässt.';

  @override
  String get featureLocalTitle => 'Dein Kalender bleibt auf deinem Gerät';

  @override
  String get featureLocalBody =>
      'Erstelle Termine, Wiederholungen und Erinnerungen ohne Konto oder Internetverbindung.';

  @override
  String get featureSyncTitle => 'Optionale Synchronisierung über Nostr';

  @override
  String get featureSyncBody =>
      'Verbinde ein Konto, um deinen Kalender zu sichern und auf mehreren Geräten über selbst gewählte Relays zu nutzen.';

  @override
  String get featureEncryptedTitle => 'Immer verschlüsselt vor dem Hochladen';

  @override
  String get featureEncryptedBody =>
      'Kalenderinhalte werden Ende-zu-Ende verschlüsselt, bevor sie dieses Gerät verlassen. Relay-Betreiber können sie nicht lesen.';

  @override
  String get featureAmberTitle => 'Bewahre deinen Schlüssel in Amber auf';

  @override
  String get featureAmberBody =>
      'Unter Android kann ein externer Signierer den Zugriff genehmigen, ohne deinen privaten Schlüssel gegenüber Astraea offenzulegen.';

  @override
  String get featureRemindersTitle => 'Private lokale Erinnerungen';

  @override
  String get featureRemindersBody =>
      'Benachrichtigungen werden von deinem Gerät geplant und hängen nicht von einem Cloud-Kalenderdienst ab.';

  @override
  String get connectNostrAccountTitle => 'Nostr-Konto verbinden';

  @override
  String get connectNostrAccountBody =>
      'Dies wird nur für die verschlüsselte Synchronisierung benötigt. Du kannst Astraea auch vollständig offline nutzen.';

  @override
  String get chooseRelaysTitle => 'Relays für die Synchronisierung wählen';

  @override
  String get chooseRelaysBody =>
      'Relays speichern deinen verschlüsselten Kalender und stellen ihn auf deinen anderen Geräten bereit. Füge einen oder mehrere hinzu, oder lasse die Liste leer und konfiguriere sie später.';

  @override
  String couldNotLoadRelaySettings(String error) {
    return 'Relay-Einstellungen konnten nicht geladen werden: $error';
  }

  @override
  String get suggestedRelays => 'Vorgeschlagen';

  @override
  String get addRelayTooltip => 'Relay hinzufügen';

  @override
  String get customRelayLabel => 'Eigenes Relay';

  @override
  String get customRelayHint => 'wss://relay.example.com';

  @override
  String get selectedRelays => 'Ausgewählt';

  @override
  String get removeRelayTooltip => 'Relay entfernen';

  @override
  String get invalidRelayUrl =>
      'Gib eine gültige wss://-URL ein (oder ws:// für ein privates Relay).';

  @override
  String get insecureRelayWarning =>
      'ws:// ist beim Transport unverschlüsselt — nutze es nur für ein Relay, dem du vertraust.';

  @override
  String get nostrAccountConnected => 'Nostr-Konto verbunden';

  @override
  String get invalidPrivateKey =>
      'Dieser private Schlüssel ist ungültig. Überprüfe ihn und versuche es erneut.';

  @override
  String couldNotSignIn(String error) {
    return 'Anmeldung fehlgeschlagen: $error';
  }

  @override
  String get signInWithAmber => 'Mit Amber anmelden';

  @override
  String get createNewAccount => 'Neues Konto erstellen';

  @override
  String get generatedAccountWarning =>
      'Ein generiertes Konto kann nur mit seinem privaten Schlüssel wiederhergestellt werden. Sichere ihn nach der Einrichtung in den Einstellungen.';

  @override
  String get importExistingKey => 'Vorhandenen Schlüssel importieren';

  @override
  String get privateKeyFieldLabel =>
      'nsec oder hexadezimaler privater Schlüssel';

  @override
  String get importButton => 'Importieren';

  @override
  String get followDeviceTimezone => 'Zeitzone des Geräts übernehmen';

  @override
  String get searchCityRegion => 'Stadt oder Region suchen';

  @override
  String get noMatchingTimezone => 'Keine passende Zeitzone.';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String couldNotLoadSettings(String error) {
    return 'Einstellungen konnten nicht geladen werden:\n$error';
  }

  @override
  String get sectionAccount => 'Konto';

  @override
  String get sectionSync => 'Synchronisierung';

  @override
  String get sectionRelays => 'Relays';

  @override
  String get sectionAppearance => 'Erscheinungsbild';

  @override
  String get sectionData => 'Daten';

  @override
  String get sectionRemindersTimezone => 'Erinnerungen & Zeitzone';

  @override
  String get sectionSupport => 'Unterstützung';

  @override
  String somethingWentWrong(String error) {
    return 'Etwas ist schiefgelaufen: $error';
  }

  @override
  String get offlineNoAccount => 'Offline — kein Konto';

  @override
  String get signInToSyncAcrossDevices =>
      'Melde dich an, um deinen verschlüsselten Kalender geräteübergreifend zu synchronisieren.';

  @override
  String get signIn => 'Anmelden';

  @override
  String get signedInWithAmber => 'Mit Amber angemeldet';

  @override
  String get signedIn => 'Angemeldet';

  @override
  String get signOut => 'Abmelden';

  @override
  String get backUpPrivateKey => 'Privaten Schlüssel sichern';

  @override
  String get revealNsecSubtitle =>
      'Deine nsec anzeigen, um sie sicher aufzubewahren';

  @override
  String get signOutTitle => 'Abmelden?';

  @override
  String get signOutBody =>
      'Deine Termine bleiben auf diesem Gerät und auf den Relays. Stelle sicher, dass du deinen privaten Schlüssel gesichert hast — ohne ihn kann ein generiertes Konto nicht wiederhergestellt werden.';

  @override
  String get noPrivateKeyStored =>
      'Kein privater Schlüssel für diese Sitzung gespeichert.';

  @override
  String get yourPrivateKeyTitle => 'Dein privater Schlüssel (nsec)';

  @override
  String get nsecWarning =>
      'Wer diesen Schlüssel besitzt, kontrolliert dein Konto. Teile ihn niemals; bewahre ihn in einem Passwort-Manager auf.';

  @override
  String get copy => 'Kopieren';

  @override
  String get done => 'Fertig';

  @override
  String get syncNowTitle => 'Jetzt synchronisieren';

  @override
  String get signInToSyncSubtitle =>
      'Melde dich an, um deinen verschlüsselten Kalender zu synchronisieren.';

  @override
  String get addRelayToSyncSubtitle =>
      'Füge mindestens ein Relay hinzu, um zu synchronisieren.';

  @override
  String get syncingEllipsis => 'Synchronisierung läuft…';

  @override
  String get synced => 'Synchronisiert';

  @override
  String lastSyncedLabel(String when) {
    return 'Zuletzt synchronisiert am $when';
  }

  @override
  String lastSyncFailedLabel(String error) {
    return 'Letzte Synchronisierung fehlgeschlagen: $error';
  }

  @override
  String get pullMergePublish =>
      'Ruft deine Termine ab, führt sie zusammen und veröffentlicht sie';

  @override
  String get publicRelays => 'Öffentliche Relays';

  @override
  String relaysConfiguredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count konfiguriert',
      one: '1 konfiguriert',
    );
    return '$_temp0';
  }

  @override
  String get addRelay => 'Relay hinzufügen';

  @override
  String get suggestedRelaysTitle => 'Vorgeschlagene Relays';

  @override
  String get addOnlyRelaysYouWant =>
      'Füge nur Relays hinzu, die du nutzen möchtest.';

  @override
  String get homeRelayBackup => 'Persönliches Relay (Sicherung)';

  @override
  String get homeRelayNotConfigured =>
      'Nicht konfiguriert — ein zusätzliches persönliches Relay zur Sicherung deiner Termine';

  @override
  String get homeRelayDialogTitle => 'Persönliches Relay';

  @override
  String get lightTheme => 'Helles Design';

  @override
  String get darkThemeDefault =>
      'Astraea verwendet standardmäßig das dunkle Design';

  @override
  String get languageLabel => 'Sprache';

  @override
  String get systemLanguage => 'Systemsprache';

  @override
  String get accentColorLabel => 'Akzentfarbe';

  @override
  String get accentNavy => 'Marineblau';

  @override
  String get accentBitcoin => 'Bitcoin-Orange';

  @override
  String get accentNostr => 'Nostr-Lila';

  @override
  String get exportEvents => 'Termine exportieren';

  @override
  String get exportEventsSubtitle =>
      'Eine .ics-Datei speichern — optional passwortgeschützt';

  @override
  String get importEvents => 'Termine importieren';

  @override
  String get importEventsSubtitle =>
      'Aus einer .ics-Datei oder einem verschlüsselten Astraea-Export';

  @override
  String get encryptExportTitle => 'Diesen Export verschlüsseln?';

  @override
  String get encryptExportBody =>
      'Eine einfache .ics-Datei kann von jeder Kalender-App geöffnet werden — und von jedem, der sie erhält. Lege ein Passwort fest, um sie zu verschlüsseln (nur Astraea kann sie dann wieder importieren).';

  @override
  String get exportPasswordLabel =>
      'Passwort (leer lassen für eine einfache .ics-Datei)';

  @override
  String get export => 'Exportieren';

  @override
  String get encryptedExportSaved => 'Verschlüsselter Export gespeichert.';

  @override
  String get exportSaved => 'Export gespeichert.';

  @override
  String exportFailed(String error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String get couldNotReadSelectedFile =>
      'Die ausgewählte Datei konnte nicht gelesen werden.';

  @override
  String get selectedFileTooLarge =>
      'Die ausgewählte Datei ist größer als 10 MB.';

  @override
  String importedEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Termine importiert.',
      one: '1 Termin importiert.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(String error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String get thisExportIsEncrypted => 'Dieser Export ist verschlüsselt';

  @override
  String get passwordLabel => 'Passwort';

  @override
  String get wrongPassword => 'Falsches Passwort.';

  @override
  String get invalidEncryptedExport =>
      'Dieser verschlüsselte Export ist ungültig.';

  @override
  String get reminders => 'Erinnerungen';

  @override
  String get scheduleLocalNotifications =>
      'Lokale Benachrichtigungen für Termin-Erinnerungen planen';

  @override
  String get timezone => 'Zeitzone';

  @override
  String followDeviceTimezoneWithName(String zone) {
    return 'Zeitzone des Geräts übernehmen ($zone)';
  }

  @override
  String get supportAstraea => 'Astraea unterstützen';

  @override
  String noLightningWalletFound(String address) {
    return 'Kein Lightning-Wallet gefunden — Adresse kopiert: $address';
  }

  @override
  String get desktopServiceUnreachableTitle =>
      'Astraea-Hintergrunddienst nicht erreichbar';

  @override
  String get desktopServiceUnreachableBody =>
      'Die Desktop-App kommuniziert für Speicherung, Synchronisierung und Benachrichtigungen über D-Bus mit astraea-service, konnte es aber nicht erreichen. Wenn du aus dem Quellcode ausführst, installiere es mit:\n\n./scripts/install-dev.sh';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get calendarsLabel => 'Kalender';

  @override
  String calendarsUnavailable(String error) {
    return 'Kalender nicht verfügbar: $error';
  }

  @override
  String get serviceUnreachable => 'Dienst nicht erreichbar';

  @override
  String syncStatusLabel(String status) {
    return 'Synchronisierung: $status';
  }

  @override
  String syncPendingSuffix(int count) {
    return ' ($count ausstehend)';
  }

  @override
  String get localOnlyMode => 'Nur lokaler Modus (keine Nostr-Identität)';

  @override
  String get syncStarted => 'Synchronisierung gestartet';

  @override
  String syncUnavailable(String error) {
    return 'Synchronisierung nicht verfügbar: $error';
  }

  @override
  String get notSignedIn => 'Nicht angemeldet';

  @override
  String get signInWithBrowserSubtitle =>
      'Melde dich mit deinem Browser (NIP-07) an, um diesen Kalender über Nostr zu synchronisieren.';

  @override
  String get signedInBackgroundSigning =>
      'Angemeldet — Signierung im Hintergrund über einen delegierten Schlüssel';

  @override
  String get signedInRemoteSigner => 'Angemeldet — externer Signierer (NIP-46)';

  @override
  String get signedInNoBackgroundSigner =>
      'Angemeldet, aber kein Hintergrund-Signierer konfiguriert — die Synchronisierung bleibt pausiert. Führe „astraea-service auth provision-key“ in einem Terminal aus.';

  @override
  String couldNotStartLogin(String error) {
    return 'Anmeldung konnte nicht gestartet werden: $error';
  }

  @override
  String get signOutConfirmDesktopBody =>
      'Dies vergisst das Konto nur auf diesem Gerät — deine Termine bleiben auf den Relays. Ein bereitgestellter Signierschlüssel wird, falls vorhanden, aus dem Schlüsselbund entfernt.';

  @override
  String get signInWithBrowserTitle => 'Mit deinem Browser anmelden';

  @override
  String get loginSessionExpired =>
      'Diese Anmeldesitzung ist abgelaufen. Versuche es erneut.';

  @override
  String get loginWaitingBody =>
      'Ein Browser-Tab wurde geöffnet, um deine Nostr-Identität zu bestätigen (NIP-07). Bestätige sie dort — dieses Fenster schließt sich automatisch. Dein privater Schlüssel wird nie angefragt.';

  @override
  String get openAgain => 'Erneut öffnen';

  @override
  String get offlineWillRetry => 'Offline — wird automatisch erneut versucht.';

  @override
  String get upToDate => 'Aktuell';

  @override
  String operationsFailingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fehlgeschlagene Vorgänge',
      one: '1 fehlgeschlagener Vorgang',
    );
    return '$_temp0';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ausstehend',
      one: '1 ausstehend',
    );
    return '$_temp0';
  }

  @override
  String pendingFailingCount(String pending, String failing) {
    return '$pending, $failing';
  }

  @override
  String get relayStatus => 'Relay-Status';

  @override
  String get relaysLabel => 'Relays';

  @override
  String relaysConfiguredLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count konfiguriert',
      one: '1 konfiguriert',
    );
    return '$_temp0';
  }

  @override
  String get unencryptedTransport => 'Unverschlüsselte Übertragung';

  @override
  String couldNotReachService(String error) {
    return 'astraea-service konnte nicht erreicht werden: $error';
  }

  @override
  String get inviteSectionTitle => 'Teilnehmer';

  @override
  String get inviteButtonLabel => 'Einladen';

  @override
  String get noAttendeesYet => 'Noch niemand eingeladen';

  @override
  String get inviteDialogTitle => 'Jemanden einladen';

  @override
  String get inviteDialogHint =>
      'npub, Name@Domain oder öffentlicher Schlüssel';

  @override
  String resolvePersonFailed(String error) {
    return 'Diese Person konnte nicht aufgelöst werden: $error';
  }

  @override
  String get confirmNip05Title => 'Empfänger bestätigen';

  @override
  String confirmNip05Body(String query, String pubkey) {
    return '$query wurde über NIP-05 zu $pubkey aufgelöst. Diese Zuordnung wird von der Domain kontrolliert – stellen Sie sicher, dass es die erwartete Person ist.';
  }

  @override
  String get attendeeStatusInvited => 'Eingeladen';

  @override
  String get attendeeStatusAccepted => 'Angenommen';

  @override
  String get attendeeStatusDeclined => 'Abgelehnt';

  @override
  String inviteFailed(String error) {
    return 'Die Einladung konnte nicht gesendet werden: $error';
  }

  @override
  String get pendingInvitationsTooltip => 'Einladungen';

  @override
  String get pendingInvitationsTitle => 'Einladungen';

  @override
  String get pendingInvitationsEmpty => 'Keine ausstehenden Einladungen';

  @override
  String invitationFromLabel(String pubkey) {
    return 'Von $pubkey';
  }

  @override
  String get acceptInvitation => 'Annehmen';

  @override
  String get declineInvitation => 'Ablehnen';

  @override
  String respondToInvitationFailed(String error) {
    return 'Antwort konnte nicht gesendet werden: $error';
  }

  @override
  String get invitationAccepted => 'Einladung angenommen';

  @override
  String get invitationDeclined => 'Einladung abgelehnt';
}
