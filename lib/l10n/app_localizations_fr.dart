// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Astraea';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get continueLabel => 'Continuer';

  @override
  String get next => 'Suivant';

  @override
  String get back => 'Retour';

  @override
  String get loading => 'Chargement…';

  @override
  String get settingsTooltip => 'Paramètres';

  @override
  String get newEventButton => 'Nouvel événement';

  @override
  String couldNotLoadEvents(String error) {
    return 'Impossible de charger les événements :\n$error';
  }

  @override
  String get viewMonth => 'Mois';

  @override
  String get viewWeek => 'Semaine';

  @override
  String get viewDay => 'Jour';

  @override
  String get viewList => 'Liste';

  @override
  String get noEventsToday => 'Aucun événement ce jour-là.';

  @override
  String get noUpcomingEvents =>
      'Aucun événement à venir dans les 60 prochains jours.';

  @override
  String get untitledEvent => '(sans titre)';

  @override
  String get allDay => 'Toute la journée';

  @override
  String get addAccountToSyncTooltip =>
      'Ajouter un compte Nostr pour synchroniser';

  @override
  String get syncNowTooltip => 'Synchroniser maintenant';

  @override
  String get addNostrAccountTitle => 'Ajouter un compte Nostr';

  @override
  String get eventNotFound => 'Événement introuvable.';

  @override
  String get eventAppBarTitle => 'Événement';

  @override
  String get editTooltip => 'Modifier';

  @override
  String get deleteTooltip => 'Supprimer';

  @override
  String allDayLabel(String date) {
    return '$date · Toute la journée';
  }

  @override
  String recurrenceUntilLabel(String recurrence, String date) {
    return '$recurrence · jusqu\'au $date';
  }

  @override
  String get syncedToRelays => 'Synchronisé sur les relais';

  @override
  String get notYetSynced => 'Pas encore synchronisé';

  @override
  String get deleteEventTitle => 'Supprimer l\'événement ?';

  @override
  String get deleteEventBody =>
      'Cela supprime l\'événement de cet appareil et demande sa suppression sur les relais.';

  @override
  String get editEventTitle => 'Modifier l\'événement';

  @override
  String get newEventTitle => 'Nouvel événement';

  @override
  String get fieldTitle => 'Titre';

  @override
  String get allDaySwitch => 'Toute la journée';

  @override
  String get startsLabel => 'Début';

  @override
  String get endsLabel => 'Fin';

  @override
  String get timezoneLabel => 'Fuseau horaire';

  @override
  String get repeatsLabel => 'Répétition';

  @override
  String get untilLabel => 'Jusqu\'au';

  @override
  String get foreverLabel => 'Toujours';

  @override
  String get remindersLabel => 'Rappels';

  @override
  String get addChip => 'Ajouter';

  @override
  String get colorLabel => 'Couleur';

  @override
  String get locationLabel => 'Lieu';

  @override
  String get descriptionLabel => 'Description';

  @override
  String couldNotSaveEvent(String error) {
    return 'Impossible d\'enregistrer l\'événement : $error';
  }

  @override
  String get recurrenceNone => 'Ne se répète pas';

  @override
  String get recurrenceDaily => 'Tous les jours';

  @override
  String get recurrenceWeekly => 'Toutes les semaines';

  @override
  String get recurrenceMonthly => 'Tous les mois';

  @override
  String get recurrenceYearly => 'Tous les ans';

  @override
  String get reminderAtStart => 'Au début';

  @override
  String reminderMinutesBefore(int count) {
    return '$count min avant';
  }

  @override
  String reminderHoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count heures avant',
      one: '1 heure avant',
    );
    return '$_temp0';
  }

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours avant',
      one: '1 jour avant',
    );
    return '$_temp0';
  }

  @override
  String get getStarted => 'Commencer';

  @override
  String get useOffline => 'Utiliser hors ligne';

  @override
  String get welcomeTitle => 'Bienvenue sur Astraea';

  @override
  String get welcomeSubtitle =>
      'Un calendrier privé, hors ligne par défaut, qui vous laisse le contrôle.';

  @override
  String get featureLocalTitle => 'Votre calendrier reste sur votre appareil';

  @override
  String get featureLocalBody =>
      'Créez des événements, des récurrences et des rappels sans compte ni connexion internet.';

  @override
  String get featureSyncTitle => 'Synchronisation facultative via Nostr';

  @override
  String get featureSyncBody =>
      'Connectez un compte pour sauvegarder votre calendrier et l\'utiliser sur plusieurs appareils via les relais de votre choix.';

  @override
  String get featureEncryptedTitle => 'Toujours chiffré avant l\'envoi';

  @override
  String get featureEncryptedBody =>
      'Le contenu du calendrier est chiffré de bout en bout avant de quitter cet appareil. Les opérateurs de relais ne peuvent pas le lire.';

  @override
  String get featureAmberTitle => 'Gardez votre clé dans Amber';

  @override
  String get featureAmberBody =>
      'Sur Android, un signataire externe peut approuver l\'accès sans exposer votre clé privée à Astraea.';

  @override
  String get featureRemindersTitle => 'Rappels locaux privés';

  @override
  String get featureRemindersBody =>
      'Les notifications sont programmées par votre appareil et ne dépendent pas d\'un service de calendrier en ligne.';

  @override
  String get connectNostrAccountTitle => 'Connecter un compte Nostr';

  @override
  String get connectNostrAccountBody =>
      'Cela n\'est nécessaire que pour la synchronisation chiffrée. Vous pouvez aussi utiliser Astraea entièrement hors ligne.';

  @override
  String get chooseRelaysTitle =>
      'Choisissez des relais pour la synchronisation';

  @override
  String get chooseRelaysBody =>
      'Les relais stockent votre calendrier chiffré et le rendent disponible sur vos autres appareils. Ajoutez-en un ou plusieurs, ou laissez la liste vide et configurez-la plus tard.';

  @override
  String couldNotLoadRelaySettings(String error) {
    return 'Impossible de charger les paramètres des relais : $error';
  }

  @override
  String get suggestedRelays => 'Suggérés';

  @override
  String get addRelayTooltip => 'Ajouter un relais';

  @override
  String get customRelayLabel => 'Relais personnalisé';

  @override
  String get customRelayHint => 'wss://relay.example.com';

  @override
  String get selectedRelays => 'Sélectionnés';

  @override
  String get removeRelayTooltip => 'Retirer le relais';

  @override
  String get invalidRelayUrl =>
      'Saisissez une URL wss:// valide (ou ws:// pour un relais privé).';

  @override
  String get insecureRelayWarning =>
      'ws:// n\'est pas chiffré en transit — utilisez-le uniquement pour un relais de confiance.';

  @override
  String get nostrAccountConnected => 'Compte Nostr connecté';

  @override
  String get invalidPrivateKey =>
      'Cette clé privée n\'est pas valide. Vérifiez-la et réessayez.';

  @override
  String couldNotSignIn(String error) {
    return 'Impossible de se connecter : $error';
  }

  @override
  String get signInWithAmber => 'Se connecter avec Amber';

  @override
  String get createNewAccount => 'Créer un nouveau compte';

  @override
  String get generatedAccountWarning =>
      'Un compte généré ne peut être récupéré qu\'avec sa clé privée. Sauvegardez-la depuis les Paramètres après la configuration.';

  @override
  String get importExistingKey => 'Importer une clé existante';

  @override
  String get privateKeyFieldLabel => 'nsec ou clé privée hexadécimale';

  @override
  String get importButton => 'Importer';

  @override
  String get followDeviceTimezone => 'Suivre le fuseau horaire de l\'appareil';

  @override
  String get searchCityRegion => 'Rechercher une ville ou une région';

  @override
  String get noMatchingTimezone => 'Aucun fuseau horaire correspondant.';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String couldNotLoadSettings(String error) {
    return 'Impossible de charger les paramètres :\n$error';
  }

  @override
  String get sectionAccount => 'Compte';

  @override
  String get sectionSync => 'Synchronisation';

  @override
  String get sectionRelays => 'Relais';

  @override
  String get sectionAppearance => 'Apparence';

  @override
  String get sectionData => 'Données';

  @override
  String get sectionRemindersTimezone => 'Rappels et fuseau horaire';

  @override
  String get sectionSupport => 'Assistance';

  @override
  String somethingWentWrong(String error) {
    return 'Une erreur est survenue : $error';
  }

  @override
  String get offlineNoAccount => 'Hors ligne — aucun compte';

  @override
  String get signInToSyncAcrossDevices =>
      'Connectez-vous pour synchroniser votre calendrier chiffré entre vos appareils.';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signedInWithAmber => 'Connecté avec Amber';

  @override
  String get signedIn => 'Connecté';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get backUpPrivateKey => 'Sauvegarder la clé privée';

  @override
  String get revealNsecSubtitle =>
      'Afficher votre nsec pour la conserver en lieu sûr';

  @override
  String get signOutTitle => 'Se déconnecter ?';

  @override
  String get signOutBody =>
      'Vos événements restent sur cet appareil et sur les relais. Assurez-vous d\'avoir sauvegardé votre clé privée — sans elle, un compte généré ne peut pas être récupéré.';

  @override
  String get noPrivateKeyStored =>
      'Aucune clé privée enregistrée pour cette session.';

  @override
  String get yourPrivateKeyTitle => 'Votre clé privée (nsec)';

  @override
  String get nsecWarning =>
      'Quiconque possède cette clé contrôle votre compte. Ne la partagez jamais ; conservez-la dans un gestionnaire de mots de passe.';

  @override
  String get copy => 'Copier';

  @override
  String get done => 'Terminé';

  @override
  String get syncNowTitle => 'Synchroniser maintenant';

  @override
  String get signInToSyncSubtitle =>
      'Connectez-vous pour synchroniser votre calendrier chiffré.';

  @override
  String get addRelayToSyncSubtitle =>
      'Ajoutez au moins un relais pour synchroniser.';

  @override
  String get syncingEllipsis => 'Synchronisation…';

  @override
  String get synced => 'Synchronisé';

  @override
  String lastSyncedLabel(String when) {
    return 'Dernière synchronisation $when';
  }

  @override
  String lastSyncFailedLabel(String error) {
    return 'Échec de la dernière synchronisation : $error';
  }

  @override
  String get pullMergePublish => 'Récupère, fusionne et publie vos événements';

  @override
  String get publicRelays => 'Relais publics';

  @override
  String relaysConfiguredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count configurés',
      one: '1 configuré',
    );
    return '$_temp0';
  }

  @override
  String get addRelay => 'Ajouter un relais';

  @override
  String get suggestedRelaysTitle => 'Relais suggérés';

  @override
  String get addOnlyRelaysYouWant =>
      'N\'ajoutez que les relais que vous voulez utiliser.';

  @override
  String get homeRelayBackup => 'Relais personnel (sauvegarde)';

  @override
  String get homeRelayNotConfigured =>
      'Non configuré — un relais personnel supplémentaire pour sauvegarder vos événements';

  @override
  String get homeRelayDialogTitle => 'Relais personnel';

  @override
  String get lightTheme => 'Thème clair';

  @override
  String get darkThemeDefault => 'Astraea utilise le thème sombre par défaut';

  @override
  String get languageLabel => 'Langue';

  @override
  String get systemLanguage => 'Langue du système';

  @override
  String get accentColorLabel => 'Couleur d\'accent';

  @override
  String get accentNavy => 'Bleu marine';

  @override
  String get accentBitcoin => 'Orange Bitcoin';

  @override
  String get accentNostr => 'Violet Nostr';

  @override
  String get exportEvents => 'Exporter les événements';

  @override
  String get exportEventsSubtitle =>
      'Enregistrer un fichier .ics — chiffré par mot de passe en option';

  @override
  String get importEvents => 'Importer des événements';

  @override
  String get importEventsSubtitle =>
      'Depuis un fichier .ics ou une exportation Astraea chiffrée';

  @override
  String get encryptExportTitle => 'Chiffrer cette exportation ?';

  @override
  String get encryptExportBody =>
      'Un fichier .ics simple peut être ouvert par n\'importe quelle application de calendrier — et par quiconque l\'obtient. Définissez un mot de passe pour le chiffrer (seul Astraea pourra le réimporter).';

  @override
  String get exportPasswordLabel =>
      'Mot de passe (laisser vide pour un .ics simple)';

  @override
  String get export => 'Exporter';

  @override
  String get encryptedExportSaved => 'Exportation chiffrée enregistrée.';

  @override
  String get exportSaved => 'Exportation enregistrée.';

  @override
  String exportFailed(String error) {
    return 'Échec de l\'exportation : $error';
  }

  @override
  String get couldNotReadSelectedFile =>
      'Impossible de lire le fichier sélectionné.';

  @override
  String get selectedFileTooLarge => 'Le fichier sélectionné dépasse 10 Mo.';

  @override
  String importedEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count événements importés.',
      one: '1 événement importé.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(String error) {
    return 'Échec de l\'importation : $error';
  }

  @override
  String get thisExportIsEncrypted => 'Cette exportation est chiffrée';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get wrongPassword => 'Mot de passe incorrect.';

  @override
  String get invalidEncryptedExport =>
      'Cette exportation chiffrée n\'est pas valide.';

  @override
  String get reminders => 'Rappels';

  @override
  String get scheduleLocalNotifications =>
      'Programmer des notifications locales pour les rappels d\'événements';

  @override
  String get timezone => 'Fuseau horaire';

  @override
  String followDeviceTimezoneWithName(String zone) {
    return 'Suivre le fuseau horaire de l\'appareil ($zone)';
  }

  @override
  String get supportAstraea => 'Soutenir Astraea';

  @override
  String noLightningWalletFound(String address) {
    return 'Aucun portefeuille Lightning trouvé — adresse copiée : $address';
  }

  @override
  String get desktopServiceUnreachableTitle =>
      'Service Astraea en arrière-plan indisponible';

  @override
  String get desktopServiceUnreachableBody =>
      'L\'application de bureau communique avec astraea-service via D-Bus pour le stockage, la synchronisation et les notifications, et il n\'a pas pu être atteint. Si vous l\'exécutez depuis les sources, installez-le avec :\n\n./scripts/install-dev.sh';

  @override
  String get retry => 'Réessayer';

  @override
  String get calendarsLabel => 'Calendriers';

  @override
  String calendarsUnavailable(String error) {
    return 'Calendriers indisponibles : $error';
  }

  @override
  String get serviceUnreachable => 'Service inaccessible';

  @override
  String syncStatusLabel(String status) {
    return 'Synchronisation : $status';
  }

  @override
  String syncPendingSuffix(int count) {
    return ' ($count en attente)';
  }

  @override
  String get localOnlyMode => 'Mode local uniquement (aucune identité Nostr)';

  @override
  String get syncStarted => 'Synchronisation démarrée';

  @override
  String syncUnavailable(String error) {
    return 'Synchronisation indisponible : $error';
  }

  @override
  String get notSignedIn => 'Non connecté';

  @override
  String get signInWithBrowserSubtitle =>
      'Connectez-vous avec votre navigateur (NIP-07) pour synchroniser ce calendrier via Nostr.';

  @override
  String get signedInBackgroundSigning =>
      'Connecté — signature en arrière-plan via une clé déléguée';

  @override
  String get signedInRemoteSigner => 'Connecté — signataire distant (NIP-46)';

  @override
  String get signedInNoBackgroundSigner =>
      'Connecté, mais aucun signataire en arrière-plan n\'est configuré — la synchronisation reste en attente. Exécutez « astraea-service auth provision-key » dans un terminal.';

  @override
  String couldNotStartLogin(String error) {
    return 'Impossible de démarrer la connexion : $error';
  }

  @override
  String get signOutConfirmDesktopBody =>
      'Cela oublie le compte uniquement sur cet appareil — vos événements restent sur les relais. Une clé de signature fournie, le cas échéant, est retirée du trousseau.';

  @override
  String get signInWithBrowserTitle => 'Connectez-vous avec votre navigateur';

  @override
  String get loginSessionExpired =>
      'Cette session de connexion a expiré. Réessayez.';

  @override
  String get loginWaitingBody =>
      'Un onglet du navigateur s\'est ouvert pour confirmer votre identité Nostr (NIP-07). Approuvez-le là-bas — cette fenêtre se ferme automatiquement. Votre clé privée n\'est jamais demandée.';

  @override
  String get openAgain => 'Rouvrir';

  @override
  String get offlineWillRetry => 'Hors ligne — nouvelle tentative automatique.';

  @override
  String get upToDate => 'À jour';

  @override
  String operationsFailingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count opérations en échec',
      one: '1 opération en échec',
    );
    return '$_temp0';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count en attente',
      one: '1 en attente',
    );
    return '$_temp0';
  }

  @override
  String pendingFailingCount(String pending, String failing) {
    return '$pending, $failing';
  }

  @override
  String get relayStatus => 'État des relais';

  @override
  String get relaysLabel => 'Relais';

  @override
  String relaysConfiguredLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count configurés',
      one: '1 configuré',
    );
    return '$_temp0';
  }

  @override
  String get unencryptedTransport => 'Transport non chiffré';

  @override
  String couldNotReachService(String error) {
    return 'Impossible de joindre astraea-service : $error';
  }

  @override
  String get inviteSectionTitle => 'Participants';

  @override
  String get inviteButtonLabel => 'Inviter';

  @override
  String get noAttendeesYet => 'Personne n\'a encore été invité';

  @override
  String get inviteDialogTitle => 'Inviter quelqu\'un';

  @override
  String get inviteDialogHint => 'npub, nom@domaine ou clé publique';

  @override
  String resolvePersonFailed(String error) {
    return 'Impossible de résoudre cette personne : $error';
  }

  @override
  String get confirmNip05Title => 'Confirmer le destinataire';

  @override
  String confirmNip05Body(String query, String pubkey) {
    return '$query a été résolu en $pubkey via NIP-05. Cette correspondance est contrôlée par le domaine — assurez-vous qu\'il s\'agit bien de la personne attendue.';
  }

  @override
  String get attendeeStatusInvited => 'Invité';

  @override
  String get attendeeStatusAccepted => 'Accepté';

  @override
  String get attendeeStatusDeclined => 'Refusé';

  @override
  String inviteFailed(String error) {
    return 'Impossible d\'envoyer l\'invitation : $error';
  }

  @override
  String get pendingInvitationsTooltip => 'Invitations';

  @override
  String get pendingInvitationsTitle => 'Invitations';

  @override
  String get pendingInvitationsEmpty => 'Aucune invitation en attente';

  @override
  String invitationFromLabel(String pubkey) {
    return 'De $pubkey';
  }

  @override
  String get acceptInvitation => 'Accepter';

  @override
  String get declineInvitation => 'Refuser';

  @override
  String respondToInvitationFailed(String error) {
    return 'Impossible de répondre : $error';
  }

  @override
  String get invitationAccepted => 'Invitation acceptée';

  @override
  String get invitationDeclined => 'Invitation refusée';
}
