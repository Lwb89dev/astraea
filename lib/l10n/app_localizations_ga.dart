// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Irish (`ga`).
class AppLocalizationsGa extends AppLocalizations {
  AppLocalizationsGa([String locale = 'ga']) : super(locale);

  @override
  String get appTitle => 'Astraea';

  @override
  String get cancel => 'Cealaigh';

  @override
  String get save => 'Sábháil';

  @override
  String get delete => 'Scrios';

  @override
  String get continueLabel => 'Lean ar aghaidh';

  @override
  String get next => 'Ar aghaidh';

  @override
  String get back => 'Siar';

  @override
  String get loading => 'Á lódáil…';

  @override
  String get settingsTooltip => 'Socruithe';

  @override
  String get newEventButton => 'Ócáid nua';

  @override
  String couldNotLoadEvents(String error) {
    return 'Níorbh fhéidir ócáidí a lódáil:\n$error';
  }

  @override
  String get viewMonth => 'Mí';

  @override
  String get viewWeek => 'Seachtain';

  @override
  String get viewDay => 'Lá';

  @override
  String get viewList => 'Liosta';

  @override
  String get noEventsToday => 'Níl aon ócáidí ar an lá seo.';

  @override
  String get noUpcomingEvents =>
      'Níl aon ócáidí atá ag teacht sna 60 lá atá romhainn.';

  @override
  String get untitledEvent => '(gan teideal)';

  @override
  String get allDay => 'An lá ar fad';

  @override
  String get addAccountToSyncTooltip => 'Cuir cuntas Nostr leis chun sioncrónú';

  @override
  String get syncNowTooltip => 'Sioncrónaigh anois';

  @override
  String get addNostrAccountTitle => 'Cuir cuntas Nostr leis';

  @override
  String get eventNotFound => 'Níor aimsíodh an ócáid.';

  @override
  String get eventAppBarTitle => 'Ócáid';

  @override
  String get editTooltip => 'Cuir in eagar';

  @override
  String get deleteTooltip => 'Scrios';

  @override
  String allDayLabel(String date) {
    return '$date · An lá ar fad';
  }

  @override
  String recurrenceUntilLabel(String recurrence, String date) {
    return '$recurrence · go dtí $date';
  }

  @override
  String get syncedToRelays => 'Sioncrónaithe leis na sealaithe';

  @override
  String get notYetSynced => 'Nach bhfuil sioncrónaithe fós';

  @override
  String get deleteEventTitle => 'An ócáid a scriosadh?';

  @override
  String get deleteEventBody =>
      'Baintear an ócáid seo den ghléas seo agus iarrtar go scriosfar í ó na sealaithe.';

  @override
  String get editEventTitle => 'Cuir an ócáid in eagar';

  @override
  String get newEventTitle => 'Ócáid nua';

  @override
  String get fieldTitle => 'Teideal';

  @override
  String get allDaySwitch => 'An lá ar fad';

  @override
  String get startsLabel => 'Tosaíonn';

  @override
  String get endsLabel => 'Críochnaíonn';

  @override
  String get timezoneLabel => 'Crios ama';

  @override
  String get repeatsLabel => 'Athrá';

  @override
  String get untilLabel => 'Go dtí';

  @override
  String get foreverLabel => 'Go deo';

  @override
  String get remindersLabel => 'Meabhrúcháin';

  @override
  String get addChip => 'Cuir leis';

  @override
  String get colorLabel => 'Dath';

  @override
  String get locationLabel => 'Suíomh';

  @override
  String get descriptionLabel => 'Cur síos';

  @override
  String couldNotSaveEvent(String error) {
    return 'Níorbh fhéidir an ócáid a shábháil: $error';
  }

  @override
  String get recurrenceNone => 'Ní athdhéantar í';

  @override
  String get recurrenceDaily => 'Laethúil';

  @override
  String get recurrenceWeekly => 'Seachtainiúil';

  @override
  String get recurrenceMonthly => 'Míosúil';

  @override
  String get recurrenceYearly => 'Bliantúil';

  @override
  String get reminderAtStart => 'Ag an tús';

  @override
  String reminderMinutesBefore(int count) {
    return '$count nóiméad roimh ré';
  }

  @override
  String reminderHoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uair roimh ré',
      few: '$count huaire roimh ré',
      two: '$count uair roimh ré',
      one: '1 uair roimh ré',
    );
    return '$_temp0';
  }

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lá roimh ré',
      few: '$count lá roimh ré',
      two: '$count lá roimh ré',
      one: '1 lá roimh ré',
    );
    return '$_temp0';
  }

  @override
  String get getStarted => 'Tosaigh';

  @override
  String get useOffline => 'Úsáid as líne';

  @override
  String get welcomeTitle => 'Fáilte go Astraea';

  @override
  String get welcomeSubtitle =>
      'Féilire príobháideach, as líne ar dtús, a fhágann an smacht agatsa.';

  @override
  String get featureLocalTitle => 'Fanann d\'fhéilire ar do ghléas';

  @override
  String get featureLocalBody =>
      'Cruthaigh ócáidí, athráite agus meabhrúcháin gan cuntas ná ceangal idirlín.';

  @override
  String get featureSyncTitle => 'Sioncrónú roghnach trí Nostr';

  @override
  String get featureSyncBody =>
      'Ceangail cuntas chun cúltaca a dhéanamh ar d\'fhéilire agus é a úsáid ar níos mó ná gléas amháin trí na sealaithe a roghnaíonn tú.';

  @override
  String get featureEncryptedTitle => 'Criptithe i gcónaí roimh uaslódáil';

  @override
  String get featureEncryptedBody =>
      'Criptítear ábhar an fhéilire ó cheann go ceann sula bhfágann sé an gléas seo. Ní féidir le hoibreoirí sealaithe é a léamh.';

  @override
  String get featureAmberTitle => 'Coinnigh d\'eochair in Amber';

  @override
  String get featureAmberBody =>
      'Ar Android, is féidir le sínitheoir seachtrach rochtain a cheadú gan d\'eochair phríobháideach a nochtadh d\'Astraea.';

  @override
  String get featureRemindersTitle => 'Meabhrúcháin áitiúla phríobháideacha';

  @override
  String get featureRemindersBody =>
      'Sceidealaítear fógraí ag do ghléas agus níl siad ag brath ar sheirbhís féilire scamaill.';

  @override
  String get connectNostrAccountTitle => 'Ceangail cuntas Nostr';

  @override
  String get connectNostrAccountBody =>
      'Níl gá leis seo ach amháin le haghaidh sioncrónú criptithe. Is féidir leat Astraea a úsáid go hiomlán as líne freisin.';

  @override
  String get chooseRelaysTitle =>
      'Roghnaigh sealaithe le haghaidh sioncrónaithe';

  @override
  String get chooseRelaysBody =>
      'Stórálann sealaithe d\'fhéilire criptithe agus déanann siad é ar fáil ar do ghléasanna eile. Cuir ceann amháin nó níos mó leis, nó fág an liosta folamh agus cumraigh é seo níos déanaí.';

  @override
  String couldNotLoadRelaySettings(String error) {
    return 'Níorbh fhéidir socruithe na sealaithe a lódáil: $error';
  }

  @override
  String get suggestedRelays => 'Molta';

  @override
  String get addRelayTooltip => 'Cuir sealaí leis';

  @override
  String get customRelayLabel => 'Sealaí saincheaptha';

  @override
  String get customRelayHint => 'wss://relay.example.com';

  @override
  String get selectedRelays => 'Roghnaithe';

  @override
  String get removeRelayTooltip => 'Bain sealaí';

  @override
  String get invalidRelayUrl =>
      'Cuir isteach URL wss:// bailí (nó ws:// le haghaidh sealaí príobháideach).';

  @override
  String get insecureRelayWarning =>
      'Níl ws:// criptithe le linn iompair — ná húsáid é ach amháin do shealaí a bhfuil muinín agat as.';

  @override
  String get nostrAccountConnected => 'Cuntas Nostr ceangailte';

  @override
  String get invalidPrivateKey =>
      'Níl an eochair phríobháideach sin bailí. Seiceáil í agus bain triail eile as.';

  @override
  String couldNotSignIn(String error) {
    return 'Níorbh fhéidir logáil isteach: $error';
  }

  @override
  String get signInWithAmber => 'Logáil isteach le Amber';

  @override
  String get createNewAccount => 'Cruthaigh cuntas nua';

  @override
  String get generatedAccountWarning =>
      'Ní féidir cuntas ginte a aisghabháil ach lena eochair phríobháideach amháin. Déan cúltaca uirthi ó na Socruithe tar éis an tsocraithe.';

  @override
  String get importExistingKey => 'Iompórtáil eochair atá ann cheana';

  @override
  String get privateKeyFieldLabel =>
      'nsec nó eochair phríobháideach heicsidheachúlach';

  @override
  String get importButton => 'Iompórtáil';

  @override
  String get followDeviceTimezone => 'Lean crios ama an ghléis';

  @override
  String get searchCityRegion => 'Cuardaigh cathair nó réigiún';

  @override
  String get noMatchingTimezone => 'Níl aon chrios ama a mheaitseálann.';

  @override
  String get settingsTitle => 'Socruithe';

  @override
  String couldNotLoadSettings(String error) {
    return 'Níorbh fhéidir socruithe a lódáil:\n$error';
  }

  @override
  String get sectionAccount => 'Cuntas';

  @override
  String get sectionSync => 'Sioncrónú';

  @override
  String get sectionRelays => 'Sealaithe';

  @override
  String get sectionAppearance => 'Cuma';

  @override
  String get sectionData => 'Sonraí';

  @override
  String get sectionRemindersTimezone => 'Meabhrúcháin agus crios ama';

  @override
  String get sectionSupport => 'Tacaíocht';

  @override
  String somethingWentWrong(String error) {
    return 'Chuaigh rud éigin cearr: $error';
  }

  @override
  String get offlineNoAccount => 'As líne — gan chuntas';

  @override
  String get signInToSyncAcrossDevices =>
      'Logáil isteach chun d\'fhéilire criptithe a shioncrónú idir ghléasanna.';

  @override
  String get signIn => 'Logáil isteach';

  @override
  String get signedInWithAmber => 'Logáilte isteach le Amber';

  @override
  String get signedIn => 'Logáilte isteach';

  @override
  String get signOut => 'Logáil amach';

  @override
  String get backUpPrivateKey => 'Déan cúltaca ar an eochair phríobháideach';

  @override
  String get revealNsecSubtitle =>
      'Nocht d\'nsec chun é a shábháil in áit shábháilte';

  @override
  String get signOutTitle => 'Logáil amach?';

  @override
  String get signOutBody =>
      'Fanann d\'ócáidí ar an ngléas seo agus ar na sealaithe. Bí cinnte go bhfuil cúltaca déanta agat ar d\'eochair phríobháideach — gan í, ní féidir cuntas ginte a aisghabháil.';

  @override
  String get noPrivateKeyStored =>
      'Níl aon eochair phríobháideach stóráilte don seisiún seo.';

  @override
  String get yourPrivateKeyTitle => 'D\'eochair phríobháideach (nsec)';

  @override
  String get nsecWarning =>
      'Rialaíonn duine ar bith a bhfuil an eochair seo aige do chuntas. Ná roinn í riamh; coinnigh í i mbainisteoir pasfhocal.';

  @override
  String get copy => 'Cóipeáil';

  @override
  String get done => 'Críochnaithe';

  @override
  String get syncNowTitle => 'Sioncrónaigh anois';

  @override
  String get signInToSyncSubtitle =>
      'Logáil isteach chun d\'fhéilire criptithe a shioncrónú.';

  @override
  String get addRelayToSyncSubtitle =>
      'Cuir sealaí amháin ar a laghad leis chun sioncrónú.';

  @override
  String get syncingEllipsis => 'Ag sioncrónú…';

  @override
  String get synced => 'Sioncrónaithe';

  @override
  String lastSyncedLabel(String when) {
    return 'Sioncrónaithe don uair dheireanach $when';
  }

  @override
  String lastSyncFailedLabel(String error) {
    return 'Theip ar an sioncrónú deireanach: $error';
  }

  @override
  String get pullMergePublish =>
      'Faigheann, cumascann agus foilsíonn sé d\'ócáidí';

  @override
  String get publicRelays => 'Sealaithe poiblí';

  @override
  String relaysConfiguredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cumraithe',
      few: '$count chumraithe',
      two: '$count chumraithe',
      one: '1 cumraithe',
    );
    return '$_temp0';
  }

  @override
  String get addRelay => 'Cuir sealaí leis';

  @override
  String get suggestedRelaysTitle => 'Sealaithe molta';

  @override
  String get addOnlyRelaysYouWant =>
      'Ná cuir leis ach na sealaithe ar mhaith leat a úsáid.';

  @override
  String get homeRelayBackup => 'Sealaí pearsanta (cúltaca)';

  @override
  String get homeRelayNotConfigured =>
      'Gan chumrú — sealaí pearsanta breise chun cúltaca a dhéanamh ar d\'ócáidí';

  @override
  String get homeRelayDialogTitle => 'Sealaí pearsanta';

  @override
  String get lightTheme => 'Téama éadrom';

  @override
  String get darkThemeDefault =>
      'Úsáideann Astraea an téama dorcha mar réamhshocrú';

  @override
  String get languageLabel => 'Teanga';

  @override
  String get systemLanguage => 'Teanga an chórais';

  @override
  String get accentColorLabel => 'Dath aiceanta';

  @override
  String get accentNavy => 'Gorm airm';

  @override
  String get accentBitcoin => 'Oráiste Bitcoin';

  @override
  String get accentNostr => 'Corcra Nostr';

  @override
  String get exportEvents => 'Easpórtáil ócáidí';

  @override
  String get exportEventsSubtitle =>
      'Sábháil comhad .ics — cosanta le pasfhocal go roghnach';

  @override
  String get importEvents => 'Iompórtáil ócáidí';

  @override
  String get importEventsSubtitle =>
      'Ó chomhad .ics nó ó easpórtáil chriptithe Astraea';

  @override
  String get encryptExportTitle => 'An easpórtáil seo a chriptiú?';

  @override
  String get encryptExportBody =>
      'Is féidir le haon aip féilire comhad .ics simplí a oscailt — agus le duine ar bith a fhaigheann é. Socraigh pasfhocal chun é a chriptiú (ní bheidh ach Astraea in ann é a iompórtáil ar ais).';

  @override
  String get exportPasswordLabel => 'Pasfhocal (fág folamh do .ics simplí)';

  @override
  String get export => 'Easpórtáil';

  @override
  String get encryptedExportSaved => 'Sábháladh an easpórtáil chriptithe.';

  @override
  String get exportSaved => 'Sábháladh an easpórtáil.';

  @override
  String exportFailed(String error) {
    return 'Theip ar an easpórtáil: $error';
  }

  @override
  String get couldNotReadSelectedFile =>
      'Níorbh fhéidir an comhad roghnaithe a léamh.';

  @override
  String get selectedFileTooLarge =>
      'Tá an comhad roghnaithe níos mó ná 10 MB.';

  @override
  String importedEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Iompórtáladh $count ócáid.',
      one: 'Iompórtáladh 1 ócáid.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(String error) {
    return 'Theip ar an iompórtáil: $error';
  }

  @override
  String get thisExportIsEncrypted => 'Tá an easpórtáil seo criptithe';

  @override
  String get passwordLabel => 'Pasfhocal';

  @override
  String get wrongPassword => 'Pasfhocal mícheart.';

  @override
  String get invalidEncryptedExport =>
      'Níl an easpórtáil chriptithe seo bailí.';

  @override
  String get reminders => 'Meabhrúcháin';

  @override
  String get scheduleLocalNotifications =>
      'Sceideal fógraí áitiúla do mheabhrúcháin ócáide';

  @override
  String get timezone => 'Crios ama';

  @override
  String followDeviceTimezoneWithName(String zone) {
    return 'Lean crios ama an ghléis ($zone)';
  }

  @override
  String get supportAstraea => 'Tacaigh le Astraea';

  @override
  String noLightningWalletFound(String address) {
    return 'Níor aimsíodh sparán Lightning — cóipeáladh an seoladh: $address';
  }

  @override
  String get desktopServiceUnreachableTitle =>
      'Níl seirbhís chúlra Astraea ar fáil';

  @override
  String get desktopServiceUnreachableBody =>
      'Labhraíonn an aip deisce le astraea-service trí D-Bus le haghaidh stórála, sioncrónaithe agus fógraí, agus níorbh fhéidir teacht uirthi. Má tá tú á rith ón bhfoinse, suiteáil í le:\n\n./scripts/install-dev.sh';

  @override
  String get retry => 'Bain triail eile as';

  @override
  String get calendarsLabel => 'Féilirí';

  @override
  String calendarsUnavailable(String error) {
    return 'Níl féilirí ar fáil: $error';
  }

  @override
  String get serviceUnreachable => 'Níl an tseirbhís inrochtana';

  @override
  String syncStatusLabel(String status) {
    return 'Sioncrónú: $status';
  }

  @override
  String syncPendingSuffix(int count) {
    return ' ($count ar feitheamh)';
  }

  @override
  String get localOnlyMode => 'Mód áitiúil amháin (gan aon aitheantas Nostr)';

  @override
  String get syncStarted => 'Tosaíodh an sioncrónú';

  @override
  String syncUnavailable(String error) {
    return 'Níl an sioncrónú ar fáil: $error';
  }

  @override
  String get notSignedIn => 'Nach bhfuil logáilte isteach';

  @override
  String get signInWithBrowserSubtitle =>
      'Logáil isteach le do bhrabhsálaí (NIP-07) chun an féilire seo a shioncrónú trí Nostr.';

  @override
  String get signedInBackgroundSigning =>
      'Logáilte isteach — síniú sa chúlra trí eochair tharmligthe';

  @override
  String get signedInRemoteSigner =>
      'Logáilte isteach — sínitheoir cianda (NIP-46)';

  @override
  String get signedInNoBackgroundSigner =>
      'Logáilte isteach, ach níl aon sínitheoir cúlra cumraithe — fanann an sioncrónú ar sos. Rith \"astraea-service auth provision-key\" i dteirminéal.';

  @override
  String couldNotStartLogin(String error) {
    return 'Níorbh fhéidir logáil isteach a thosú: $error';
  }

  @override
  String get signOutConfirmDesktopBody =>
      'Ní dhéanann sé seo dearmad ar an gcuntas ach ar an ngléas seo — fanann d\'ócáidí ar na sealaithe. Baintear aon eochair shínithe soláthraithe as an eochairchrann.';

  @override
  String get signInWithBrowserTitle => 'Logáil isteach le do bhrabhsálaí';

  @override
  String get loginSessionExpired =>
      'Tá an seisiún logála isteach seo imithe in éag. Bain triail eile as.';

  @override
  String get loginWaitingBody =>
      'Osclaíodh cluaisín brabhsálaí chun d\'aitheantas Nostr a dhearbhú (NIP-07). Ceadaigh ansin é — dúnann an dialóg seo go huathoibríoch. Ní iarrtar d\'eochair phríobháideach riamh.';

  @override
  String get openAgain => 'Oscail arís';

  @override
  String get offlineWillRetry =>
      'As líne — déanfaidh sé iarracht eile go huathoibríoch.';

  @override
  String get upToDate => 'Cothrom le dáta';

  @override
  String operationsFailingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count oibríocht theip',
      one: '1 oibríocht theip',
    );
    return '$_temp0';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ar feitheamh',
      one: '1 ar feitheamh',
    );
    return '$_temp0';
  }

  @override
  String pendingFailingCount(String pending, String failing) {
    return '$pending, $failing';
  }

  @override
  String get relayStatus => 'Stádas na sealaithe';

  @override
  String get relaysLabel => 'Sealaithe';

  @override
  String relaysConfiguredLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cumraithe',
      few: '$count chumraithe',
      two: '$count chumraithe',
      one: '1 cumraithe',
    );
    return '$_temp0';
  }

  @override
  String get unencryptedTransport => 'Iompar neamhchriptithe';

  @override
  String couldNotReachService(String error) {
    return 'Níorbh fhéidir teacht ar astraea-service: $error';
  }

  @override
  String get inviteSectionTitle => 'Rannpháirtithe';

  @override
  String get inviteButtonLabel => 'Tabhair cuireadh';

  @override
  String get noAttendeesYet => 'Níor tugadh cuireadh d\'aon duine fós';

  @override
  String get inviteDialogTitle => 'Tabhair cuireadh do dhuine';

  @override
  String get inviteDialogHint => 'npub, ainm@fearann, nó eochair phoiblí';

  @override
  String resolvePersonFailed(String error) {
    return 'Níorbh fhéidir an duine sin a réiteach: $error';
  }

  @override
  String get confirmNip05Title => 'Deimhnigh an faighteoir';

  @override
  String confirmNip05Body(String query, String pubkey) {
    return 'Réitíodh $query go $pubkey trí NIP-05. Is é an fearann a rialaíonn an mapáil seo — bí cinnte gurb é an duine a bhfuiltear ag súil leis.';
  }

  @override
  String get attendeeStatusInvited => 'Cuireadh tugtha';

  @override
  String get attendeeStatusAccepted => 'Glactha';

  @override
  String get attendeeStatusDeclined => 'Diúltaithe';

  @override
  String inviteFailed(String error) {
    return 'Níorbh fhéidir an cuireadh a sheoladh: $error';
  }

  @override
  String get pendingInvitationsTooltip => 'Cuirí';

  @override
  String get pendingInvitationsTitle => 'Cuirí';

  @override
  String get pendingInvitationsEmpty => 'Níl aon chuireadh ar feitheamh';

  @override
  String invitationFromLabel(String pubkey) {
    return 'Ó $pubkey';
  }

  @override
  String get acceptInvitation => 'Glac';

  @override
  String get declineInvitation => 'Diúltaigh';

  @override
  String respondToInvitationFailed(String error) {
    return 'Níorbh fhéidir freagra a sheoladh: $error';
  }

  @override
  String get invitationAccepted => 'Glacadh leis an gcuireadh';

  @override
  String get invitationDeclined => 'Diúltaíodh don chuireadh';
}
