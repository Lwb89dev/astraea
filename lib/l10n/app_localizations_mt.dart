// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Maltese (`mt`).
class AppLocalizationsMt extends AppLocalizations {
  AppLocalizationsMt([String locale = 'mt']) : super(locale);

  @override
  String get appTitle => 'Astraea';

  @override
  String get cancel => 'Ikkanċella';

  @override
  String get save => 'Issejvja';

  @override
  String get delete => 'Ħassar';

  @override
  String get continueLabel => 'Kompli';

  @override
  String get next => 'Li jmiss';

  @override
  String get back => 'Lura';

  @override
  String get loading => 'Qed jgħabbi…';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get newEventButton => 'Avveniment ġdid';

  @override
  String couldNotLoadEvents(String error) {
    return 'L-avvenimenti ma setgħux jitgħabbew:\n$error';
  }

  @override
  String get viewMonth => 'Xahar';

  @override
  String get viewWeek => 'Ġimgħa';

  @override
  String get viewDay => 'Jum';

  @override
  String get viewList => 'Lista';

  @override
  String get noEventsToday => 'M\'hemm l-ebda avveniment dan il-jum.';

  @override
  String get noUpcomingEvents =>
      'M\'hemm l-ebda avveniment li ġej fl-60 jum li ġejjin.';

  @override
  String get untitledEvent => '(mingħajr titlu)';

  @override
  String get allDay => 'Il-jum kollu';

  @override
  String get addAccountToSyncTooltip => 'Żid kont Nostr biex tissinkronizza';

  @override
  String get syncNowTooltip => 'Sinkronizza issa';

  @override
  String get addNostrAccountTitle => 'Żid kont Nostr';

  @override
  String get eventNotFound => 'L-avveniment ma nstabx.';

  @override
  String get eventAppBarTitle => 'Avveniment';

  @override
  String get editTooltip => 'Editja';

  @override
  String get deleteTooltip => 'Ħassar';

  @override
  String allDayLabel(String date) {
    return '$date · Il-jum kollu';
  }

  @override
  String recurrenceUntilLabel(String recurrence, String date) {
    return '$recurrence · sa $date';
  }

  @override
  String get syncedToRelays => 'Issinkronizzat mar-relays';

  @override
  String get notYetSynced => 'Għadu ma ġiex issinkronizzat';

  @override
  String get deleteEventTitle => 'Tħassar l-avveniment?';

  @override
  String get deleteEventBody =>
      'Dan ineħħi l-avveniment minn dan l-apparat u jitlob it-tħassir mir-relays.';

  @override
  String get editEventTitle => 'Editja l-avveniment';

  @override
  String get newEventTitle => 'Avveniment ġdid';

  @override
  String get fieldTitle => 'Titlu';

  @override
  String get allDaySwitch => 'Il-jum kollu';

  @override
  String get startsLabel => 'Jibda';

  @override
  String get endsLabel => 'Jispiċċa';

  @override
  String get timezoneLabel => 'Żona tal-ħin';

  @override
  String get repeatsLabel => 'Ripetizzjoni';

  @override
  String get untilLabel => 'Sa';

  @override
  String get foreverLabel => 'Għal dejjem';

  @override
  String get remindersLabel => 'Tfakkiriet';

  @override
  String get addChip => 'Żid';

  @override
  String get colorLabel => 'Kulur';

  @override
  String get locationLabel => 'Post';

  @override
  String get descriptionLabel => 'Deskrizzjoni';

  @override
  String couldNotSaveEvent(String error) {
    return 'L-avveniment ma setax jiġi ssejvjat: $error';
  }

  @override
  String get recurrenceNone => 'Ma jitrattabx';

  @override
  String get recurrenceDaily => 'Kuljum';

  @override
  String get recurrenceWeekly => 'Kull ġimgħa';

  @override
  String get recurrenceMonthly => 'Kull xahar';

  @override
  String get recurrenceYearly => 'Kull sena';

  @override
  String get reminderAtStart => 'Fil-bidu';

  @override
  String reminderMinutesBefore(int count) {
    return '$count min qabel';
  }

  @override
  String reminderHoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sigħat qabel',
      one: 'siegħa 1 qabel',
    );
    return '$_temp0';
  }

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ijiem qabel',
      one: 'jum 1 qabel',
    );
    return '$_temp0';
  }

  @override
  String get getStarted => 'Ibda';

  @override
  String get useOffline => 'Uża offline';

  @override
  String get welcomeTitle => 'Merħba f\'Astraea';

  @override
  String get welcomeSubtitle =>
      'Kalendarju privat, offline-first, li jħallik il-kontroll.';

  @override
  String get featureLocalTitle =>
      'Il-kalendarju tiegħek jibqa\' fuq l-apparat tiegħek';

  @override
  String get featureLocalBody =>
      'Oħloq avvenimenti, rikorrenzi u tfakkiriet mingħajr kont jew konnessjoni tal-internet.';

  @override
  String get featureSyncTitle =>
      'Sinkronizzazzjoni fakultattiva permezz ta\' Nostr';

  @override
  String get featureSyncBody =>
      'Ikkonnettja kont biex tibbekkjajja l-kalendarju tiegħek u tużah fuq diversi apparati permezz tar-relays li tagħżel.';

  @override
  String get featureEncryptedTitle => 'Dejjem ikkriptat qabel it-tluq';

  @override
  String get featureEncryptedBody =>
      'Il-kontenut tal-kalendarju jiġi kkriptat minn tarf sa tarf qabel ma jitlaq minn dan l-apparat. L-operaturi tar-relays ma jistgħux jaqrawh.';

  @override
  String get featureAmberTitle => 'Żomm iċ-ċavetta tiegħek f\'Amber';

  @override
  String get featureAmberBody =>
      'Fuq Android, firmatarju estern jista\' japprova l-aċċess mingħajr ma jesponi ċ-ċavetta privata tiegħek lil Astraea.';

  @override
  String get featureRemindersTitle => 'Tfakkiriet lokali privati';

  @override
  String get featureRemindersBody =>
      'In-notifiki jiġu skedati mill-apparat tiegħek u ma jiddependux minn servizz ta\' kalendarju fuq il-cloud.';

  @override
  String get connectNostrAccountTitle => 'Ikkonnettja kont Nostr';

  @override
  String get connectNostrAccountBody =>
      'Dan huwa meħtieġ biss għal sinkronizzazzjoni kkriptata. Tista\' wkoll tuża Astraea kompletament offline.';

  @override
  String get chooseRelaysTitle => 'Agħżel relays għas-sinkronizzazzjoni';

  @override
  String get chooseRelaysBody =>
      'Ir-relays jaħżnu l-kalendarju kkriptat tiegħek u jagħmluh disponibbli fuq l-apparati l-oħra tiegħek. Żid wieħed jew aktar, jew ħalli l-lista vojta u kkonfigurah aktar tard.';

  @override
  String couldNotLoadRelaySettings(String error) {
    return 'L-issettjar tar-relays ma setax jitgħabba: $error';
  }

  @override
  String get suggestedRelays => 'Issuġġeriti';

  @override
  String get addRelayTooltip => 'Żid relay';

  @override
  String get customRelayLabel => 'Relay personalizzat';

  @override
  String get customRelayHint => 'wss://relay.example.com';

  @override
  String get selectedRelays => 'Magħżula';

  @override
  String get removeRelayTooltip => 'Neħħi relay';

  @override
  String get invalidRelayUrl =>
      'Daħħal URL wss:// validu (jew ws:// għal relay privat).';

  @override
  String get insecureRelayWarning =>
      'ws:// mhux ikkriptat waqt it-trasport — użah biss għal relay li tafda.';

  @override
  String get nostrAccountConnected => 'Il-kont Nostr huwa konness';

  @override
  String get invalidPrivateKey =>
      'Dik iċ-ċavetta privata mhix valida. Iċċekkjaha u erġa\' pprova.';

  @override
  String couldNotSignIn(String error) {
    return 'Ma setax jidħol: $error';
  }

  @override
  String get signInWithAmber => 'Idħol b\'Amber';

  @override
  String get createNewAccount => 'Oħloq kont ġdid';

  @override
  String get generatedAccountWarning =>
      'Kont iġġenerat jista\' jiġi rkuprat biss biċ-ċavetta privata tiegħu. Ibbekkjajh mis-Settings wara l-installazzjoni.';

  @override
  String get importExistingKey => 'Importa ċavetta eżistenti';

  @override
  String get privateKeyFieldLabel => 'nsec jew ċavetta privata eżadeċimali';

  @override
  String get importButton => 'Importa';

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
  String get followDeviceTimezone => 'Segwi ż-żona tal-ħin tal-apparat';

  @override
  String get searchCityRegion => 'Fittex belt jew reġjun';

  @override
  String get noMatchingTimezone => 'L-ebda żona tal-ħin li taqbel.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String couldNotLoadSettings(String error) {
    return 'Is-settings ma setgħux jitgħabbew:\n$error';
  }

  @override
  String get sectionAccount => 'Kont';

  @override
  String get sectionSync => 'Sinkronizzazzjoni';

  @override
  String get sectionRelays => 'Relays';

  @override
  String get sectionAppearance => 'Dehra';

  @override
  String get sectionData => 'Data';

  @override
  String get sectionRemindersTimezone => 'Tfakkiriet u żona tal-ħin';

  @override
  String get sectionSupport => 'Appoġġ';

  @override
  String somethingWentWrong(String error) {
    return 'Xi ħaġa marret ħażin: $error';
  }

  @override
  String get offlineNoAccount => 'Offline — l-ebda kont';

  @override
  String get signInToSyncAcrossDevices =>
      'Idħol biex tissinkronizza l-kalendarju kkriptat tiegħek bejn l-apparati.';

  @override
  String get signIn => 'Idħol';

  @override
  String get signedInWithAmber => 'Daħal b\'Amber';

  @override
  String get signedIn => 'Daħal';

  @override
  String get signOut => 'Oħroġ';

  @override
  String get backUpPrivateKey => 'Ibbekkjajja ċ-ċavetta privata';

  @override
  String get revealNsecSubtitle =>
      'Uri l-nsec tiegħek biex tissejvjah f\'post sikur';

  @override
  String get signOutTitle => 'Toħroġ?';

  @override
  String get signOutBody =>
      'L-avvenimenti tiegħek jibqgħu fuq dan l-apparat u fuq ir-relays. Kun żgur li bbekkjajt iċ-ċavetta privata tiegħek — mingħajrha kont iġġenerat ma jistax jiġi rkuprat.';

  @override
  String get noPrivateKeyStored =>
      'L-ebda ċavetta privata mhix maħżuna għal din is-sessjoni.';

  @override
  String get yourPrivateKeyTitle => 'Iċ-ċavetta privata tiegħek (nsec)';

  @override
  String get nsecWarning =>
      'Kull min għandu din iċ-ċavetta jikkontrolla l-kont tiegħek. Qatt taqsamhiex; żommha f\'maniġer tal-passwords.';

  @override
  String get copy => 'Ikkopja';

  @override
  String get done => 'Lest';

  @override
  String get syncNowTitle => 'Sinkronizza issa';

  @override
  String get signInToSyncSubtitle =>
      'Idħol biex tissinkronizza l-kalendarju kkriptat tiegħek.';

  @override
  String get addRelayToSyncSubtitle =>
      'Żid mill-inqas relay wieħed biex tissinkronizza.';

  @override
  String get syncingEllipsis => 'Qed jissinkronizza…';

  @override
  String get synced => 'Issinkronizzat';

  @override
  String lastSyncedLabel(String when) {
    return 'L-aħħar sinkronizzazzjoni $when';
  }

  @override
  String lastSyncFailedLabel(String error) {
    return 'L-aħħar sinkronizzazzjoni falliet: $error';
  }

  @override
  String get pullMergePublish =>
      'Iġib, jgħaqqad u jippubblika l-avvenimenti tiegħek';

  @override
  String get publicRelays => 'Relays pubbliċi';

  @override
  String relaysConfiguredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ikkonfigurati',
      one: '1 ikkonfigurat',
    );
    return '$_temp0';
  }

  @override
  String get addRelay => 'Żid relay';

  @override
  String get suggestedRelaysTitle => 'Relays issuġġeriti';

  @override
  String get addOnlyRelaysYouWant => 'Żid biss ir-relays li trid tuża.';

  @override
  String get homeRelayBackup => 'Relay personali (backup)';

  @override
  String get homeRelayNotConfigured =>
      'Mhux ikkonfigurat — relay personali addizzjonali biex tibbekkjajja l-avvenimenti tiegħek';

  @override
  String get homeRelayDialogTitle => 'Relay personali';

  @override
  String get lightTheme => 'Tema ċara';

  @override
  String get darkThemeDefault => 'Astraea tuża t-tema skura b\'mod predefinit';

  @override
  String get languageLabel => 'Lingwa';

  @override
  String get systemLanguage => 'Lingwa tas-sistema';

  @override
  String get accentColorLabel => 'Kulur ta\' l-aċċent';

  @override
  String get accentNavy => 'Blu navy';

  @override
  String get accentBitcoin => 'Oranġjo Bitcoin';

  @override
  String get accentNostr => 'Vjola Nostr';

  @override
  String get exportEvents => 'Esporta avvenimenti';

  @override
  String get exportEventsSubtitle =>
      'Issejvja fajl .ics — bi protezzjoni tal-password fakultattiva';

  @override
  String get importEvents => 'Importa avvenimenti';

  @override
  String get importEventsSubtitle =>
      'Minn fajl .ics jew esportazzjoni Astraea kkriptata';

  @override
  String get encryptExportTitle => 'Tikkripta din l-esportazzjoni?';

  @override
  String get encryptExportBody =>
      'Fajl .ics sempliċi jista\' jinfetaħ minn kwalunkwe app tal-kalendarju — u minn kull min jiksbu. Issettja password biex tikkriptah (Astraea biss se tkun tista\' terġa\' timportah).';

  @override
  String get exportPasswordLabel =>
      'Password (ħalliha vojta għal .ics sempliċi)';

  @override
  String get export => 'Esporta';

  @override
  String get encryptedExportSaved =>
      'L-esportazzjoni kkriptata ġiet issejvjata.';

  @override
  String get exportSaved => 'L-esportazzjoni ġiet issejvjata.';

  @override
  String exportFailed(String error) {
    return 'L-esportazzjoni falliet: $error';
  }

  @override
  String get couldNotReadSelectedFile => 'Il-fajl magħżul ma setax jinqara.';

  @override
  String get selectedFileTooLarge => 'Il-fajl magħżul huwa akbar minn 10 MB.';

  @override
  String importedEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ġew importati $count avvenimenti.',
      one: 'Ġie importat avveniment 1.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(String error) {
    return 'L-importazzjoni falliet: $error';
  }

  @override
  String get thisExportIsEncrypted => 'Din l-esportazzjoni hija kkriptata';

  @override
  String get passwordLabel => 'Password';

  @override
  String get wrongPassword => 'Password żbaljata.';

  @override
  String get invalidEncryptedExport =>
      'Din l-esportazzjoni kkriptata mhix valida.';

  @override
  String get reminders => 'Tfakkiriet';

  @override
  String get scheduleLocalNotifications =>
      'Skeda notifiki lokali għat-tfakkiriet tal-avvenimenti';

  @override
  String get timezone => 'Żona tal-ħin';

  @override
  String followDeviceTimezoneWithName(String zone) {
    return 'Segwi ż-żona tal-ħin tal-apparat ($zone)';
  }

  @override
  String get supportAstraea => 'Appoġġa Astraea';

  @override
  String noLightningWalletFound(String address) {
    return 'L-ebda kartiera Lightning ma nstabet — indirizz ikkopjat: $address';
  }

  @override
  String get desktopServiceUnreachableTitle =>
      'Is-servizz ta\' sfond ta\' Astraea mhux disponibbli';

  @override
  String get desktopServiceUnreachableBody =>
      'L-app tad-desktop tikkomunika ma\' astraea-service permezz ta\' D-Bus għall-ħżin, sinkronizzazzjoni u notifiki, u ma setgħetx tintlaħaq. Jekk qed taħdimha mis-sors, installaha b\':\n\n./scripts/install-dev.sh';

  @override
  String get retry => 'Erġa\' pprova';

  @override
  String get calendarsLabel => 'Kalendarji';

  @override
  String calendarsUnavailable(String error) {
    return 'Il-kalendarji mhumiex disponibbli: $error';
  }

  @override
  String get serviceUnreachable => 'Is-servizz mhux aċċessibbli';

  @override
  String syncStatusLabel(String status) {
    return 'Sinkronizzazzjoni: $status';
  }

  @override
  String syncPendingSuffix(int count) {
    return ' ($count pendenti)';
  }

  @override
  String get localOnlyMode => 'Modalità lokali biss (l-ebda identità Nostr)';

  @override
  String get syncStarted => 'Is-sinkronizzazzjoni bdiet';

  @override
  String syncUnavailable(String error) {
    return 'Is-sinkronizzazzjoni mhix disponibbli: $error';
  }

  @override
  String get notSignedIn => 'Mhux midħul';

  @override
  String get signInWithBrowserSubtitle =>
      'Idħol bil-browser tiegħek (NIP-07) biex tissinkronizza dan il-kalendarju permezz ta\' Nostr.';

  @override
  String get signedInBackgroundSigning =>
      'Daħal — iffirmar fl-isfond permezz ta\' ċavetta ddelegata';

  @override
  String get signedInRemoteSigner => 'Daħal — firmatarju remot (NIP-46)';

  @override
  String get signedInNoBackgroundSigner =>
      'Daħal, iżda l-ebda firmatarju tal-isfond mhux ikkonfigurat — is-sinkronizzazzjoni tibqa\' fi pawża. Aħdem \"astraea-service auth provision-key\" f\'terminal.';

  @override
  String couldNotStartLogin(String error) {
    return 'Id-dħul ma setax jinbeda: $error';
  }

  @override
  String get signOutConfirmDesktopBody =>
      'Dan jinsa l-kont biss fuq dan l-apparat — l-avvenimenti tiegħek jibqgħu fuq ir-relays. Kwalunkwe ċavetta ta\' firma pprovduta tiġi mneħħija mill-keyring.';

  @override
  String get signInWithBrowserTitle => 'Idħol bil-browser tiegħek';

  @override
  String get loginSessionExpired =>
      'Din is-sessjoni tad-dħul skadiet. Erġa\' pprova.';

  @override
  String get loginWaitingBody =>
      'Infetħet tab tal-browser biex tikkonferma l-identità Nostr tiegħek (NIP-07). Approvaha hemm — dan id-dialogu jagħlaq awtomatikament. Iċ-ċavetta privata tiegħek qatt ma tintalab.';

  @override
  String get openAgain => 'Iftaħ mill-ġdid';

  @override
  String get offlineWillRetry =>
      'Offline — se jerġa\' jipprova awtomatikament.';

  @override
  String get upToDate => 'Aġġornat';

  @override
  String operationsFailingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count operazzjonijiet falliti',
      one: 'operazzjoni 1 fallita',
    );
    return '$_temp0';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pendenti',
      one: '1 pendenti',
    );
    return '$_temp0';
  }

  @override
  String pendingFailingCount(String pending, String failing) {
    return '$pending, $failing';
  }

  @override
  String get relayStatus => 'Status tar-relays';

  @override
  String get relaysLabel => 'Relays';

  @override
  String relaysConfiguredLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ikkonfigurati',
      one: '1 ikkonfigurat',
    );
    return '$_temp0';
  }

  @override
  String get unencryptedTransport => 'Trasport mhux ikkriptat';

  @override
  String couldNotReachService(String error) {
    return 'Ma setax jintlaħaq astraea-service: $error';
  }

  @override
  String get inviteSectionTitle => 'Parteċipanti';

  @override
  String get inviteButtonLabel => 'Istieden';

  @override
  String get noAttendeesYet => 'Għadu ħadd ma ġie mistieden';

  @override
  String get inviteDialogTitle => 'Istieden lil xi ħadd';

  @override
  String get inviteDialogHint => 'npub, isem@dominju, jew ċavetta pubblika';

  @override
  String resolvePersonFailed(String error) {
    return 'Ma setax jinstab dak il-persuna: $error';
  }

  @override
  String get confirmNip05Title => 'Ikkonferma d-destinatarju';

  @override
  String confirmNip05Body(String query, String pubkey) {
    return '$query ġie riżolt għal $pubkey permezz ta\' NIP-05. Din il-mappa hija kkontrollata mid-dominju — kun żgur li din hija l-persuna mistennija.';
  }

  @override
  String get attendeeStatusInvited => 'Mistieden';

  @override
  String get attendeeStatusAccepted => 'Aċċettat';

  @override
  String get attendeeStatusDeclined => 'Miċħud';

  @override
  String inviteFailed(String error) {
    return 'Ma setax jintbagħat l-istedina: $error';
  }

  @override
  String get pendingInvitationsTooltip => 'Stediniet';

  @override
  String get pendingInvitationsTitle => 'Stediniet';

  @override
  String get pendingInvitationsEmpty => 'L-ebda stedina pendenti';

  @override
  String invitationFromLabel(String pubkey) {
    return 'Minn $pubkey';
  }

  @override
  String get acceptInvitation => 'Aċċetta';

  @override
  String get declineInvitation => 'Iċħad';

  @override
  String respondToInvitationFailed(String error) {
    return 'Ma setgħetx tintbagħat tweġiba: $error';
  }

  @override
  String get invitationAccepted => 'Stedina aċċettata';

  @override
  String get invitationDeclined => 'Stedina miċħuda';
}
