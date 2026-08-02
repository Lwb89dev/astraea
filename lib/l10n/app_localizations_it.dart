// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Astraea';

  @override
  String get cancel => 'Annulla';

  @override
  String get save => 'Salva';

  @override
  String get delete => 'Elimina';

  @override
  String get continueLabel => 'Continua';

  @override
  String get next => 'Avanti';

  @override
  String get back => 'Indietro';

  @override
  String get loading => 'Caricamento…';

  @override
  String get settingsTooltip => 'Impostazioni';

  @override
  String get newEventButton => 'Nuovo evento';

  @override
  String couldNotLoadEvents(String error) {
    return 'Impossibile caricare gli eventi:\n$error';
  }

  @override
  String get viewMonth => 'Mese';

  @override
  String get viewWeek => 'Settimana';

  @override
  String get viewDay => 'Giorno';

  @override
  String get viewList => 'Elenco';

  @override
  String get noEventsToday => 'Nessun evento in questo giorno.';

  @override
  String get noUpcomingEvents =>
      'Nessun evento in programma nei prossimi 60 giorni.';

  @override
  String get untitledEvent => '(senza titolo)';

  @override
  String get allDay => 'Tutto il giorno';

  @override
  String get addAccountToSyncTooltip =>
      'Aggiungi un account Nostr per sincronizzare';

  @override
  String get syncNowTooltip => 'Sincronizza ora';

  @override
  String get addNostrAccountTitle => 'Aggiungi un account Nostr';

  @override
  String get eventNotFound => 'Evento non trovato.';

  @override
  String get eventAppBarTitle => 'Evento';

  @override
  String get editTooltip => 'Modifica';

  @override
  String get deleteTooltip => 'Elimina';

  @override
  String allDayLabel(String date) {
    return '$date · Tutto il giorno';
  }

  @override
  String recurrenceUntilLabel(String recurrence, String date) {
    return '$recurrence · fino al $date';
  }

  @override
  String get syncedToRelays => 'Sincronizzato sui relay';

  @override
  String get notYetSynced => 'Non ancora sincronizzato';

  @override
  String get deleteEventTitle => 'Eliminare l\'evento?';

  @override
  String get deleteEventBody =>
      'Questo rimuove l\'evento da questo dispositivo e richiede l\'eliminazione dai relay.';

  @override
  String get editEventTitle => 'Modifica evento';

  @override
  String get newEventTitle => 'Nuovo evento';

  @override
  String get fieldTitle => 'Titolo';

  @override
  String get allDaySwitch => 'Tutto il giorno';

  @override
  String get startsLabel => 'Inizio';

  @override
  String get endsLabel => 'Fine';

  @override
  String get timezoneLabel => 'Fuso orario';

  @override
  String get repeatsLabel => 'Ripeti';

  @override
  String get untilLabel => 'Fino al';

  @override
  String get foreverLabel => 'Per sempre';

  @override
  String get remindersLabel => 'Promemoria';

  @override
  String get addChip => 'Aggiungi';

  @override
  String get colorLabel => 'Colore';

  @override
  String get locationLabel => 'Luogo';

  @override
  String get descriptionLabel => 'Descrizione';

  @override
  String couldNotSaveEvent(String error) {
    return 'Impossibile salvare l\'evento: $error';
  }

  @override
  String get recurrenceNone => 'Non si ripete';

  @override
  String get recurrenceDaily => 'Ogni giorno';

  @override
  String get recurrenceWeekly => 'Ogni settimana';

  @override
  String get recurrenceMonthly => 'Ogni mese';

  @override
  String get recurrenceYearly => 'Ogni anno';

  @override
  String get reminderAtStart => 'All\'inizio';

  @override
  String reminderMinutesBefore(int count) {
    return '$count minuti prima';
  }

  @override
  String reminderHoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ore prima',
      one: '1 ora prima',
    );
    return '$_temp0';
  }

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni prima',
      one: '1 giorno prima',
    );
    return '$_temp0';
  }

  @override
  String get getStarted => 'Inizia';

  @override
  String get useOffline => 'Usa offline';

  @override
  String get welcomeTitle => 'Benvenuto in Astraea';

  @override
  String get welcomeSubtitle =>
      'Un calendario privato, offline-first, che ti lascia il controllo.';

  @override
  String get featureLocalTitle => 'Il tuo calendario resta sul tuo dispositivo';

  @override
  String get featureLocalBody =>
      'Crea eventi, ricorrenze e promemoria senza un account o una connessione a internet.';

  @override
  String get featureSyncTitle => 'Sincronizzazione opzionale tramite Nostr';

  @override
  String get featureSyncBody =>
      'Collega un account per fare il backup del calendario e usarlo su più dispositivi tramite i relay che scegli.';

  @override
  String get featureEncryptedTitle => 'Sempre cifrato prima del caricamento';

  @override
  String get featureEncryptedBody =>
      'I contenuti del calendario vengono cifrati end-to-end prima di lasciare questo dispositivo. Gli operatori dei relay non possono leggerli.';

  @override
  String get featureAmberTitle => 'Conserva la tua chiave in Amber';

  @override
  String get featureAmberBody =>
      'Su Android, un signer esterno può approvare l\'accesso senza esporre la tua chiave privata ad Astraea.';

  @override
  String get featureRemindersTitle => 'Promemoria locali privati';

  @override
  String get featureRemindersBody =>
      'Le notifiche vengono pianificate dal tuo dispositivo e non dipendono da un servizio calendario in cloud.';

  @override
  String get connectNostrAccountTitle => 'Collega un account Nostr';

  @override
  String get connectNostrAccountBody =>
      'Serve solo per la sincronizzazione cifrata. Puoi anche usare Astraea completamente offline.';

  @override
  String get chooseRelaysTitle => 'Scegli i relay per la sincronizzazione';

  @override
  String get chooseRelaysBody =>
      'I relay conservano il tuo calendario cifrato e lo rendono disponibile sugli altri dispositivi. Aggiungine uno o più, oppure lascia la lista vuota e configurala più tardi.';

  @override
  String couldNotLoadRelaySettings(String error) {
    return 'Impossibile caricare le impostazioni dei relay: $error';
  }

  @override
  String get suggestedRelays => 'Suggeriti';

  @override
  String get addRelayTooltip => 'Aggiungi relay';

  @override
  String get customRelayLabel => 'Relay personalizzato';

  @override
  String get customRelayHint => 'wss://relay.example.com';

  @override
  String get selectedRelays => 'Selezionati';

  @override
  String get removeRelayTooltip => 'Rimuovi relay';

  @override
  String get invalidRelayUrl =>
      'Inserisci un URL wss:// valido (o ws:// per un relay privato).';

  @override
  String get insecureRelayWarning =>
      'ws:// non è cifrato in transito — usalo solo per un relay di cui ti fidi.';

  @override
  String get nostrAccountConnected => 'Account Nostr collegato';

  @override
  String get invalidPrivateKey =>
      'Quella chiave privata non è valida. Controllala e riprova.';

  @override
  String couldNotSignIn(String error) {
    return 'Impossibile accedere: $error';
  }

  @override
  String get signInWithAmber => 'Accedi con Amber';

  @override
  String get createNewAccount => 'Crea un nuovo account';

  @override
  String get generatedAccountWarning =>
      'Un account generato può essere recuperato solo con la sua chiave privata. Fanne il backup dalle Impostazioni dopo la configurazione.';

  @override
  String get importExistingKey => 'Importa una chiave esistente';

  @override
  String get privateKeyFieldLabel => 'nsec o chiave privata esadecimale';

  @override
  String get importButton => 'Importa';

  @override
  String get signInWithRemoteSigner => 'Accedi con un signer remoto';

  @override
  String get remoteSignerFieldLabel => 'stringa di connessione bunker://';

  @override
  String get remoteSignerHelp =>
      'Incolla la stringa bunker:// del tuo signer (Amber, nsec.app, nostrify, il tuo bunker). Astraea salva solo una chiave usa-e-getta per questo dispositivo — mai la tua chiave privata.';

  @override
  String get remoteSignerConnect => 'Connetti';

  @override
  String get remoteSignerConnecting =>
      'In attesa che il signer approvi la connessione…';

  @override
  String get invalidBunkerUri =>
      'Questa non è una stringa di connessione bunker:// valida.';

  @override
  String get remoteSignerApprovalOpened =>
      'Approva la connessione nella pagina appena aperta, poi torna qui.';

  @override
  String get remoteSignerDisconnected =>
      'Il signer remoto non è connesso. Accedi di nuovo.';

  @override
  String get followDeviceTimezone => 'Segui il fuso orario del dispositivo';

  @override
  String get searchCityRegion => 'Cerca una città o una regione';

  @override
  String get noMatchingTimezone => 'Nessun fuso orario corrispondente.';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String couldNotLoadSettings(String error) {
    return 'Impossibile caricare le impostazioni:\n$error';
  }

  @override
  String get sectionAccount => 'Account';

  @override
  String get sectionSync => 'Sincronizzazione';

  @override
  String get sectionRelays => 'Relay';

  @override
  String get sectionAppearance => 'Aspetto';

  @override
  String get sectionData => 'Dati';

  @override
  String get sectionRemindersTimezone => 'Promemoria e fuso orario';

  @override
  String get sectionSupport => 'Supporto';

  @override
  String somethingWentWrong(String error) {
    return 'Qualcosa è andato storto: $error';
  }

  @override
  String get offlineNoAccount => 'Offline — nessun account';

  @override
  String get signInToSyncAcrossDevices =>
      'Accedi per sincronizzare il tuo calendario cifrato tra i dispositivi.';

  @override
  String get signIn => 'Accedi';

  @override
  String get signedInWithAmber => 'Accesso effettuato con Amber';

  @override
  String get signedIn => 'Accesso effettuato';

  @override
  String get signOut => 'Esci';

  @override
  String get backUpPrivateKey => 'Backup chiave privata';

  @override
  String get revealNsecSubtitle =>
      'Mostra la tua nsec per salvarla in un posto sicuro';

  @override
  String get signOutTitle => 'Uscire?';

  @override
  String get signOutBody =>
      'I tuoi eventi restano su questo dispositivo e sui relay. Assicurati di aver fatto il backup della chiave privata — senza di essa un account generato non può essere recuperato.';

  @override
  String get noPrivateKeyStored =>
      'Nessuna chiave privata salvata per questa sessione.';

  @override
  String get yourPrivateKeyTitle => 'La tua chiave privata (nsec)';

  @override
  String get nsecWarning =>
      'Chiunque abbia questa chiave controlla il tuo account. Non condividerla mai; conservala in un gestore di password.';

  @override
  String get copy => 'Copia';

  @override
  String get done => 'Fatto';

  @override
  String get syncNowTitle => 'Sincronizza ora';

  @override
  String get signInToSyncSubtitle =>
      'Accedi per sincronizzare il tuo calendario cifrato.';

  @override
  String get addRelayToSyncSubtitle =>
      'Aggiungi almeno un relay per sincronizzare.';

  @override
  String get syncingEllipsis => 'Sincronizzazione…';

  @override
  String get synced => 'Sincronizzato';

  @override
  String lastSyncedLabel(String when) {
    return 'Ultima sincronizzazione $when';
  }

  @override
  String lastSyncFailedLabel(String error) {
    return 'Ultima sincronizzazione non riuscita: $error';
  }

  @override
  String get pullMergePublish => 'Scarica, unisce e pubblica i tuoi eventi';

  @override
  String get publicRelays => 'Relay pubblici';

  @override
  String relaysConfiguredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count configurati',
      one: '1 configurato',
    );
    return '$_temp0';
  }

  @override
  String get addRelay => 'Aggiungi relay';

  @override
  String get suggestedRelaysTitle => 'Relay suggeriti';

  @override
  String get addOnlyRelaysYouWant => 'Aggiungi solo i relay che vuoi usare.';

  @override
  String get homeRelayBackup => 'Relay personale (backup)';

  @override
  String get homeRelayNotConfigured =>
      'Non configurato — un relay personale aggiuntivo per fare il backup dei tuoi eventi';

  @override
  String get homeRelayDialogTitle => 'Relay personale';

  @override
  String get lightTheme => 'Tema chiaro';

  @override
  String get darkThemeDefault =>
      'Astraea usa il tema scuro per impostazione predefinita';

  @override
  String get languageLabel => 'Lingua';

  @override
  String get systemLanguage => 'Lingua di sistema';

  @override
  String get accentColorLabel => 'Colore accento';

  @override
  String get accentNavy => 'Blu navy';

  @override
  String get accentBitcoin => 'Arancione Bitcoin';

  @override
  String get accentNostr => 'Viola Nostr';

  @override
  String get exportEvents => 'Esporta eventi';

  @override
  String get exportEventsSubtitle =>
      'Salva un file .ics — opzionalmente protetto da password';

  @override
  String get importEvents => 'Importa eventi';

  @override
  String get importEventsSubtitle =>
      'Da un file .ics o da un\'esportazione Astraea cifrata';

  @override
  String get encryptExportTitle => 'Cifrare questa esportazione?';

  @override
  String get encryptExportBody =>
      'Un file .ics semplice può essere aperto da qualsiasi app calendario — e da chiunque lo ottenga. Imposta una password per cifrarlo (solo Astraea potrà reimportarlo).';

  @override
  String get exportPasswordLabel =>
      'Password (lascia vuoto per un .ics semplice)';

  @override
  String get export => 'Esporta';

  @override
  String get encryptedExportSaved => 'Esportazione cifrata salvata.';

  @override
  String get exportSaved => 'Esportazione salvata.';

  @override
  String exportFailed(String error) {
    return 'Esportazione non riuscita: $error';
  }

  @override
  String get couldNotReadSelectedFile =>
      'Impossibile leggere il file selezionato.';

  @override
  String get selectedFileTooLarge => 'Il file selezionato supera i 10 MB.';

  @override
  String importedEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importati $count eventi.',
      one: 'Importato 1 evento.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(String error) {
    return 'Importazione non riuscita: $error';
  }

  @override
  String get thisExportIsEncrypted => 'Questa esportazione è cifrata';

  @override
  String get passwordLabel => 'Password';

  @override
  String get wrongPassword => 'Password errata.';

  @override
  String get invalidEncryptedExport =>
      'Questa esportazione cifrata non è valida.';

  @override
  String get reminders => 'Promemoria';

  @override
  String get scheduleLocalNotifications =>
      'Pianifica notifiche locali per i promemoria degli eventi';

  @override
  String get timezone => 'Fuso orario';

  @override
  String followDeviceTimezoneWithName(String zone) {
    return 'Segui il fuso orario del dispositivo ($zone)';
  }

  @override
  String get supportAstraea => 'Sostieni Astraea';

  @override
  String noLightningWalletFound(String address) {
    return 'Nessun wallet Lightning trovato — indirizzo copiato: $address';
  }

  @override
  String get desktopServiceUnreachableTitle =>
      'Servizio Astraea in background non disponibile';

  @override
  String get desktopServiceUnreachableBody =>
      'L\'app desktop comunica con astraea-service tramite D-Bus per l\'archiviazione, la sincronizzazione e le notifiche, e non è stato possibile raggiungerlo. Se lo stai eseguendo dai sorgenti, installalo con:\n\n./scripts/install-dev.sh';

  @override
  String get retry => 'Riprova';

  @override
  String get calendarsLabel => 'Calendari';

  @override
  String calendarsUnavailable(String error) {
    return 'Calendari non disponibili: $error';
  }

  @override
  String get serviceUnreachable => 'Servizio non raggiungibile';

  @override
  String syncStatusLabel(String status) {
    return 'Sincronizzazione: $status';
  }

  @override
  String syncPendingSuffix(int count) {
    return ' ($count in sospeso)';
  }

  @override
  String get localOnlyMode => 'Modalità locale (nessuna identità Nostr)';

  @override
  String get syncStarted => 'Sincronizzazione avviata';

  @override
  String syncUnavailable(String error) {
    return 'Sincronizzazione non disponibile: $error';
  }

  @override
  String get notSignedIn => 'Accesso non effettuato';

  @override
  String get signInWithBrowserSubtitle =>
      'Accedi con il tuo browser (NIP-07) per sincronizzare questo calendario su Nostr.';

  @override
  String get signedInBackgroundSigning =>
      'Accesso effettuato — firma in background tramite chiave delegata';

  @override
  String get signedInRemoteSigner =>
      'Accesso effettuato — signer remoto (NIP-46)';

  @override
  String get signedInNoBackgroundSigner =>
      'Accesso effettuato, ma nessun signer in background configurato — la sincronizzazione resta in sospeso. Esegui \"astraea-service auth provision-key\" in un terminale.';

  @override
  String couldNotStartLogin(String error) {
    return 'Impossibile avviare l\'accesso: $error';
  }

  @override
  String get signOutConfirmDesktopBody =>
      'Questo dimentica l\'account solo su questo dispositivo — i tuoi eventi restano sui relay. Un\'eventuale chiave di firma fornita viene rimossa dal portachiavi.';

  @override
  String get signInWithBrowserTitle => 'Accedi con il tuo browser';

  @override
  String get loginSessionExpired =>
      'Questa sessione di accesso è scaduta. Riprova.';

  @override
  String get loginWaitingBody =>
      'È stata aperta una scheda del browser per confermare la tua identità Nostr (NIP-07). Approvala lì — questa finestra si chiude automaticamente. La tua chiave privata non viene mai richiesta.';

  @override
  String get openAgain => 'Apri di nuovo';

  @override
  String get offlineWillRetry => 'Offline — riproverà automaticamente.';

  @override
  String get upToDate => 'Aggiornato';

  @override
  String operationsFailingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count operazioni non riuscite',
      one: '1 operazione non riuscita',
    );
    return '$_temp0';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count in sospeso',
      one: '1 in sospeso',
    );
    return '$_temp0';
  }

  @override
  String pendingFailingCount(String pending, String failing) {
    return '$pending, $failing';
  }

  @override
  String get relayStatus => 'Stato dei relay';

  @override
  String get relaysLabel => 'Relay';

  @override
  String relaysConfiguredLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count configurati',
      one: '1 configurato',
    );
    return '$_temp0';
  }

  @override
  String get unencryptedTransport => 'Trasporto non cifrato';

  @override
  String couldNotReachService(String error) {
    return 'Impossibile raggiungere astraea-service: $error';
  }

  @override
  String get inviteSectionTitle => 'Partecipanti';

  @override
  String get inviteButtonLabel => 'Invita';

  @override
  String get noAttendeesYet => 'Nessuno è stato ancora invitato';

  @override
  String get inviteDialogTitle => 'Invita qualcuno';

  @override
  String get inviteDialogHint => 'npub, nome@dominio o chiave pubblica';

  @override
  String resolvePersonFailed(String error) {
    return 'Impossibile trovare quella persona: $error';
  }

  @override
  String get confirmNip05Title => 'Conferma destinatario';

  @override
  String confirmNip05Body(String query, String pubkey) {
    return '$query è stato risolto in $pubkey tramite NIP-05. Questa corrispondenza è controllata dal dominio: assicurati che sia la persona attesa.';
  }

  @override
  String get attendeeStatusInvited => 'Invitato';

  @override
  String get attendeeStatusAccepted => 'Accettato';

  @override
  String get attendeeStatusDeclined => 'Rifiutato';

  @override
  String inviteFailed(String error) {
    return 'Impossibile inviare l\'invito: $error';
  }

  @override
  String get pendingInvitationsTooltip => 'Inviti';

  @override
  String get pendingInvitationsTitle => 'Inviti';

  @override
  String get pendingInvitationsEmpty => 'Nessun invito in sospeso';

  @override
  String invitationFromLabel(String pubkey) {
    return 'Da $pubkey';
  }

  @override
  String get acceptInvitation => 'Accetta';

  @override
  String get declineInvitation => 'Rifiuta';

  @override
  String respondToInvitationFailed(String error) {
    return 'Impossibile rispondere: $error';
  }

  @override
  String get invitationAccepted => 'Invito accettato';

  @override
  String get invitationDeclined => 'Invito rifiutato';
}
