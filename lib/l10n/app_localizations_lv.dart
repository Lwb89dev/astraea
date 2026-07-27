// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Latvian (`lv`).
class AppLocalizationsLv extends AppLocalizations {
  AppLocalizationsLv([String locale = 'lv']) : super(locale);

  @override
  String get appTitle => 'Astraea';

  @override
  String get cancel => 'Atcelt';

  @override
  String get save => 'Saglabāt';

  @override
  String get delete => 'Dzēst';

  @override
  String get continueLabel => 'Turpināt';

  @override
  String get next => 'Tālāk';

  @override
  String get back => 'Atpakaļ';

  @override
  String get loading => 'Notiek ielāde…';

  @override
  String get settingsTooltip => 'Iestatījumi';

  @override
  String get newEventButton => 'Jauns notikums';

  @override
  String couldNotLoadEvents(String error) {
    return 'Neizdevās ielādēt notikumus:\n$error';
  }

  @override
  String get viewMonth => 'Mēnesis';

  @override
  String get viewWeek => 'Nedēļa';

  @override
  String get viewDay => 'Diena';

  @override
  String get viewList => 'Saraksts';

  @override
  String get noEventsToday => 'Šajā dienā notikumu nav.';

  @override
  String get noUpcomingEvents => 'Nākamo 60 dienu laikā gaidāmu notikumu nav.';

  @override
  String get untitledEvent => '(bez nosaukuma)';

  @override
  String get allDay => 'Visu dienu';

  @override
  String get addAccountToSyncTooltip => 'Pievienot Nostr kontu sinhronizācijai';

  @override
  String get syncNowTooltip => 'Sinhronizēt tagad';

  @override
  String get addNostrAccountTitle => 'Pievienot Nostr kontu';

  @override
  String get eventNotFound => 'Notikums nav atrasts.';

  @override
  String get eventAppBarTitle => 'Notikums';

  @override
  String get editTooltip => 'Rediģēt';

  @override
  String get deleteTooltip => 'Dzēst';

  @override
  String allDayLabel(String date) {
    return '$date · Visu dienu';
  }

  @override
  String recurrenceUntilLabel(String recurrence, String date) {
    return '$recurrence · līdz $date';
  }

  @override
  String get syncedToRelays => 'Sinhronizēts ar relejiem';

  @override
  String get notYetSynced => 'Vēl nav sinhronizēts';

  @override
  String get deleteEventTitle => 'Dzēst notikumu?';

  @override
  String get deleteEventBody =>
      'Tas noņem notikumu no šīs ierīces un pieprasa tā dzēšanu no relejiem.';

  @override
  String get editEventTitle => 'Rediģēt notikumu';

  @override
  String get newEventTitle => 'Jauns notikums';

  @override
  String get fieldTitle => 'Nosaukums';

  @override
  String get allDaySwitch => 'Visu dienu';

  @override
  String get startsLabel => 'Sākas';

  @override
  String get endsLabel => 'Beidzas';

  @override
  String get timezoneLabel => 'Laika josla';

  @override
  String get repeatsLabel => 'Atkārtošanās';

  @override
  String get untilLabel => 'Līdz';

  @override
  String get foreverLabel => 'Uz visiem laikiem';

  @override
  String get remindersLabel => 'Atgādinājumi';

  @override
  String get addChip => 'Pievienot';

  @override
  String get colorLabel => 'Krāsa';

  @override
  String get locationLabel => 'Vieta';

  @override
  String get descriptionLabel => 'Apraksts';

  @override
  String couldNotSaveEvent(String error) {
    return 'Neizdevās saglabāt notikumu: $error';
  }

  @override
  String get recurrenceNone => 'Neatkārtojas';

  @override
  String get recurrenceDaily => 'Katru dienu';

  @override
  String get recurrenceWeekly => 'Katru nedēļu';

  @override
  String get recurrenceMonthly => 'Katru mēnesi';

  @override
  String get recurrenceYearly => 'Katru gadu';

  @override
  String get reminderAtStart => 'Sākumā';

  @override
  String reminderMinutesBefore(int count) {
    return '$count min iepriekš';
  }

  @override
  String reminderHoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stundas iepriekš',
      one: '1 stundu iepriekš',
      zero: '$count stundas iepriekš',
    );
    return '$_temp0';
  }

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dienas iepriekš',
      one: '1 dienu iepriekš',
      zero: '$count dienas iepriekš',
    );
    return '$_temp0';
  }

  @override
  String get getStarted => 'Sākt';

  @override
  String get useOffline => 'Lietot bezsaistē';

  @override
  String get welcomeTitle => 'Laipni lūdzam Astraea';

  @override
  String get welcomeSubtitle =>
      'Privāts, vispirms bezsaistes kalendārs, kas atstāj kontroli tavās rokās.';

  @override
  String get featureLocalTitle => 'Tavs kalendārs paliek tavā ierīcē';

  @override
  String get featureLocalBody =>
      'Izveido notikumus, atkārtojumus un atgādinājumus bez konta vai interneta pieslēguma.';

  @override
  String get featureSyncTitle => 'Neobligāta sinhronizācija, izmantojot Nostr';

  @override
  String get featureSyncBody =>
      'Pievieno kontu, lai izveidotu kalendāra dublējumu un izmantotu to vairākās ierīcēs, izmantojot tevis izvēlētus relejus.';

  @override
  String get featureEncryptedTitle => 'Vienmēr šifrēts pirms augšupielādes';

  @override
  String get featureEncryptedBody =>
      'Kalendāra saturs tiek šifrēts no gala līdz galam, pirms tas atstāj šo ierīci. Releju operatori to nevar lasīt.';

  @override
  String get featureAmberTitle => 'Glabā savu atslēgu Amber';

  @override
  String get featureAmberBody =>
      'Android sistēmā ārējs parakstītājs var apstiprināt piekļuvi, neatklājot tavu privāto atslēgu Astraea.';

  @override
  String get featureRemindersTitle => 'Privāti lokāli atgādinājumi';

  @override
  String get featureRemindersBody =>
      'Paziņojumus plāno tava ierīce, un tie nav atkarīgi no mākoņa kalendāra pakalpojuma.';

  @override
  String get connectNostrAccountTitle => 'Pievienot Nostr kontu';

  @override
  String get connectNostrAccountBody =>
      'Tas nepieciešams tikai šifrētai sinhronizācijai. Astraea var izmantot arī pilnīgi bezsaistē.';

  @override
  String get chooseRelaysTitle => 'Izvēlies relejus sinhronizācijai';

  @override
  String get chooseRelaysBody =>
      'Releji glabā tavu šifrēto kalendāru un padara to pieejamu citās tavās ierīcēs. Pievieno vienu vai vairākus, vai atstāj sarakstu tukšu un konfigurē to vēlāk.';

  @override
  String couldNotLoadRelaySettings(String error) {
    return 'Neizdevās ielādēt releju iestatījumus: $error';
  }

  @override
  String get suggestedRelays => 'Ieteiktie';

  @override
  String get addRelayTooltip => 'Pievienot releju';

  @override
  String get customRelayLabel => 'Pielāgots relejs';

  @override
  String get customRelayHint => 'wss://relay.example.com';

  @override
  String get selectedRelays => 'Izvēlētie';

  @override
  String get removeRelayTooltip => 'Noņemt releju';

  @override
  String get invalidRelayUrl =>
      'Ievadi derīgu wss:// adresi (vai ws:// privātam relejam).';

  @override
  String get insecureRelayWarning =>
      'ws:// pārraides laikā nav šifrēts — izmanto to tikai relejam, kuram uzticies.';

  @override
  String get nostrAccountConnected => 'Nostr konts pievienots';

  @override
  String get invalidPrivateKey =>
      'Šī privātā atslēga nav derīga. Pārbaudi to un mēģini vēlreiz.';

  @override
  String couldNotSignIn(String error) {
    return 'Neizdevās pieteikties: $error';
  }

  @override
  String get signInWithAmber => 'Pieteikties ar Amber';

  @override
  String get createNewAccount => 'Izveidot jaunu kontu';

  @override
  String get generatedAccountWarning =>
      'Izveidotu kontu var atgūt tikai ar tā privāto atslēgu. Izveido tās dublējumu Iestatījumos pēc iestatīšanas.';

  @override
  String get importExistingKey => 'Importēt esošu atslēgu';

  @override
  String get privateKeyFieldLabel => 'nsec vai heksadecimāla privātā atslēga';

  @override
  String get importButton => 'Importēt';

  @override
  String get followDeviceTimezone => 'Izmantot ierīces laika joslu';

  @override
  String get searchCityRegion => 'Meklēt pilsētu vai reģionu';

  @override
  String get noMatchingTimezone => 'Nav atbilstošas laika joslas.';

  @override
  String get settingsTitle => 'Iestatījumi';

  @override
  String couldNotLoadSettings(String error) {
    return 'Neizdevās ielādēt iestatījumus:\n$error';
  }

  @override
  String get sectionAccount => 'Konts';

  @override
  String get sectionSync => 'Sinhronizācija';

  @override
  String get sectionRelays => 'Releji';

  @override
  String get sectionAppearance => 'Izskats';

  @override
  String get sectionData => 'Dati';

  @override
  String get sectionRemindersTimezone => 'Atgādinājumi un laika josla';

  @override
  String get sectionSupport => 'Atbalsts';

  @override
  String somethingWentWrong(String error) {
    return 'Kaut kas nogāja greizi: $error';
  }

  @override
  String get offlineNoAccount => 'Bezsaistē — nav konta';

  @override
  String get signInToSyncAcrossDevices =>
      'Piesakies, lai sinhronizētu savu šifrēto kalendāru starp ierīcēm.';

  @override
  String get signIn => 'Pieteikties';

  @override
  String get signedInWithAmber => 'Pieteicies ar Amber';

  @override
  String get signedIn => 'Pieteicies';

  @override
  String get signOut => 'Izrakstīties';

  @override
  String get backUpPrivateKey => 'Dublēt privāto atslēgu';

  @override
  String get revealNsecSubtitle =>
      'Parādi savu nsec, lai to saglabātu drošā vietā';

  @override
  String get signOutTitle => 'Izrakstīties?';

  @override
  String get signOutBody =>
      'Tavi notikumi paliek šajā ierīcē un relejos. Pārliecinies, ka esi izveidojis privātās atslēgas dublējumu — bez tā izveidotu kontu nevar atgūt.';

  @override
  String get noPrivateKeyStored => 'Šai sesijai nav saglabāta privātā atslēga.';

  @override
  String get yourPrivateKeyTitle => 'Tava privātā atslēga (nsec)';

  @override
  String get nsecWarning =>
      'Ikviens, kam ir šī atslēga, kontrolē tavu kontu. Nekad to nekopīgo; glabā to paroļu pārvaldniekā.';

  @override
  String get copy => 'Kopēt';

  @override
  String get done => 'Gatavs';

  @override
  String get syncNowTitle => 'Sinhronizēt tagad';

  @override
  String get signInToSyncSubtitle =>
      'Piesakies, lai sinhronizētu savu šifrēto kalendāru.';

  @override
  String get addRelayToSyncSubtitle =>
      'Pievieno vismaz vienu releju, lai sinhronizētu.';

  @override
  String get syncingEllipsis => 'Notiek sinhronizācija…';

  @override
  String get synced => 'Sinhronizēts';

  @override
  String lastSyncedLabel(String when) {
    return 'Pēdējoreiz sinhronizēts $when';
  }

  @override
  String lastSyncFailedLabel(String error) {
    return 'Pēdējā sinhronizācija neizdevās: $error';
  }

  @override
  String get pullMergePublish => 'Iegūst, apvieno un publicē tavus notikumus';

  @override
  String get publicRelays => 'Publiskie releji';

  @override
  String relaysConfiguredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count konfigurēti',
      one: '1 konfigurēts',
      zero: '$count konfigurēti',
    );
    return '$_temp0';
  }

  @override
  String get addRelay => 'Pievienot releju';

  @override
  String get suggestedRelaysTitle => 'Ieteiktie releji';

  @override
  String get addOnlyRelaysYouWant =>
      'Pievieno tikai tos relejus, kurus vēlies izmantot.';

  @override
  String get homeRelayBackup => 'Personīgais relejs (dublējums)';

  @override
  String get homeRelayNotConfigured =>
      'Nav konfigurēts — papildu personīgs relejs tavu notikumu dublēšanai';

  @override
  String get homeRelayDialogTitle => 'Personīgais relejs';

  @override
  String get lightTheme => 'Gaišā tēma';

  @override
  String get darkThemeDefault => 'Astraea pēc noklusējuma izmanto tumšo tēmu';

  @override
  String get languageLabel => 'Valoda';

  @override
  String get systemLanguage => 'Sistēmas valoda';

  @override
  String get exportEvents => 'Eksportēt notikumus';

  @override
  String get exportEventsSubtitle =>
      'Saglabāt .ics failu — pēc izvēles ar paroles aizsardzību';

  @override
  String get importEvents => 'Importēt notikumus';

  @override
  String get importEventsSubtitle =>
      'No .ics faila vai šifrēta Astraea eksporta';

  @override
  String get encryptExportTitle => 'Vai šifrēt šo eksportu?';

  @override
  String get encryptExportBody =>
      'Vienkāršu .ics failu var atvērt jebkura kalendāra lietotne — un ikviens, kas to iegūst. Iestati paroli, lai to šifrētu (to varēs atkārtoti importēt tikai Astraea).';

  @override
  String get exportPasswordLabel =>
      'Parole (atstāj tukšu vienkāršam .ics failam)';

  @override
  String get export => 'Eksportēt';

  @override
  String get encryptedExportSaved => 'Šifrēts eksports saglabāts.';

  @override
  String get exportSaved => 'Eksports saglabāts.';

  @override
  String exportFailed(String error) {
    return 'Eksports neizdevās: $error';
  }

  @override
  String get couldNotReadSelectedFile => 'Neizdevās nolasīt izvēlēto failu.';

  @override
  String get selectedFileTooLarge => 'Izvēlētais fails pārsniedz 10 MB.';

  @override
  String importedEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importēti $count notikumi.',
      one: 'Importēts 1 notikums.',
      zero: 'Importēti $count notikumi.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(String error) {
    return 'Imports neizdevās: $error';
  }

  @override
  String get thisExportIsEncrypted => 'Šis eksports ir šifrēts';

  @override
  String get passwordLabel => 'Parole';

  @override
  String get wrongPassword => 'Nepareiza parole.';

  @override
  String get invalidEncryptedExport => 'Šis šifrētais eksports nav derīgs.';

  @override
  String get reminders => 'Atgādinājumi';

  @override
  String get scheduleLocalNotifications =>
      'Ieplānot lokālus paziņojumus notikumu atgādinājumiem';

  @override
  String get timezone => 'Laika josla';

  @override
  String followDeviceTimezoneWithName(String zone) {
    return 'Izmantot ierīces laika joslu ($zone)';
  }

  @override
  String get supportAstraea => 'Atbalstīt Astraea';

  @override
  String noLightningWalletFound(String address) {
    return 'Lightning maks netika atrasts — adrese nokopēta: $address';
  }

  @override
  String get desktopServiceUnreachableTitle =>
      'Astraea fona pakalpojums nav pieejams';

  @override
  String get desktopServiceUnreachableBody =>
      'Darbvirsmas lietotne sazinās ar astraea-service, izmantojot D-Bus, glabāšanai, sinhronizācijai un paziņojumiem, taču to nebija iespējams sasniegt. Ja to palaid no pirmkoda, instalē to ar:\n\n./scripts/install-dev.sh';

  @override
  String get retry => 'Mēģināt vēlreiz';

  @override
  String get calendarsLabel => 'Kalendāri';

  @override
  String calendarsUnavailable(String error) {
    return 'Kalendāri nav pieejami: $error';
  }

  @override
  String get serviceUnreachable => 'Pakalpojums nav sasniedzams';

  @override
  String syncStatusLabel(String status) {
    return 'Sinhronizācija: $status';
  }

  @override
  String syncPendingSuffix(int count) {
    return ' ($count gaida)';
  }

  @override
  String get localOnlyMode => 'Tikai lokālais režīms (nav Nostr identitātes)';

  @override
  String get syncStarted => 'Sinhronizācija sākta';

  @override
  String syncUnavailable(String error) {
    return 'Sinhronizācija nav pieejama: $error';
  }

  @override
  String get notSignedIn => 'Nav pieteicies';

  @override
  String get signInWithBrowserSubtitle =>
      'Piesakies ar savu pārlūkprogrammu (NIP-07), lai sinhronizētu šo kalendāru, izmantojot Nostr.';

  @override
  String get signedInBackgroundSigning =>
      'Pieteicies — fona parakstīšana ar deleģētu atslēgu';

  @override
  String get signedInRemoteSigner =>
      'Pieteicies — attālais parakstītājs (NIP-46)';

  @override
  String get signedInNoBackgroundSigner =>
      'Pieteicies, bet fona parakstītājs nav konfigurēts — sinhronizācija paliek pauzēta. Palaid termināli ar \"astraea-service auth provision-key\".';

  @override
  String couldNotStartLogin(String error) {
    return 'Neizdevās sākt pieteikšanos: $error';
  }

  @override
  String get signOutConfirmDesktopBody =>
      'Tas aizmirst kontu tikai šajā ierīcē — tavi notikumi paliek relejos. Jebkura nodrošinātā parakstīšanas atslēga tiek noņemta no atslēgu saiskas.';

  @override
  String get signInWithBrowserTitle => 'Piesakies ar savu pārlūkprogrammu';

  @override
  String get loginSessionExpired =>
      'Šī pieteikšanās sesija ir beigusies. Mēģini vēlreiz.';

  @override
  String get loginWaitingBody =>
      'Tika atvērta pārlūkprogrammas cilne, lai apstiprinātu tavu Nostr identitāti (NIP-07). Apstiprini to tur — šis dialoglodziņš aizvērsies automātiski. Tava privātā atslēga netiek pieprasīta nekad.';

  @override
  String get openAgain => 'Atvērt vēlreiz';

  @override
  String get offlineWillRetry => 'Bezsaistē — automātiski mēģinās vēlreiz.';

  @override
  String get upToDate => 'Aktuāls';

  @override
  String operationsFailingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count neveiksmīgas darbības',
      one: '1 neveiksmīga darbība',
      zero: '$count neveiksmīgas darbības',
    );
    return '$_temp0';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gaida',
      one: '1 gaida',
      zero: '$count gaida',
    );
    return '$_temp0';
  }

  @override
  String pendingFailingCount(String pending, String failing) {
    return '$pending, $failing';
  }

  @override
  String get relayStatus => 'Releju statuss';

  @override
  String get relaysLabel => 'Releji';

  @override
  String relaysConfiguredLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count konfigurēti',
      one: '1 konfigurēts',
      zero: '$count konfigurēti',
    );
    return '$_temp0';
  }

  @override
  String get unencryptedTransport => 'Nešifrēta pārraide';

  @override
  String couldNotReachService(String error) {
    return 'Neizdevās sasniegt astraea-service: $error';
  }

  @override
  String get inviteSectionTitle => 'Dalībnieki';

  @override
  String get inviteButtonLabel => 'Uzaicināt';

  @override
  String get noAttendeesYet => 'Pagaidām neviens nav uzaicināts';

  @override
  String get inviteDialogTitle => 'Uzaicināt kādu';

  @override
  String get inviteDialogHint => 'npub, vārds@domēns vai publiskā atslēga';

  @override
  String resolvePersonFailed(String error) {
    return 'Neizdevās atrast šo personu: $error';
  }

  @override
  String get confirmNip05Title => 'Apstiprināt saņēmēju';

  @override
  String confirmNip05Body(String query, String pubkey) {
    return '$query tika atrisināts uz $pubkey, izmantojot NIP-05. Šo sasaisti kontrolē domēns — pārliecinieties, ka tā ir sagaidītā persona.';
  }

  @override
  String get attendeeStatusInvited => 'Uzaicināts';

  @override
  String get attendeeStatusAccepted => 'Pieņemts';

  @override
  String get attendeeStatusDeclined => 'Noraidīts';

  @override
  String inviteFailed(String error) {
    return 'Neizdevās nosūtīt uzaicinājumu: $error';
  }

  @override
  String get pendingInvitationsTooltip => 'Uzaicinājumi';

  @override
  String get pendingInvitationsTitle => 'Uzaicinājumi';

  @override
  String get pendingInvitationsEmpty => 'Nav gaidošu uzaicinājumu';

  @override
  String invitationFromLabel(String pubkey) {
    return 'No $pubkey';
  }

  @override
  String get acceptInvitation => 'Pieņemt';

  @override
  String get declineInvitation => 'Noraidīt';

  @override
  String respondToInvitationFailed(String error) {
    return 'Neizdevās atbildēt: $error';
  }

  @override
  String get invitationAccepted => 'Uzaicinājums pieņemts';

  @override
  String get invitationDeclined => 'Uzaicinājums noraidīts';
}
