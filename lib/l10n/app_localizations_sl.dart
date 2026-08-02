// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovenian (`sl`).
class AppLocalizationsSl extends AppLocalizations {
  AppLocalizationsSl([String locale = 'sl']) : super(locale);

  @override
  String get appTitle => 'Astraea';

  @override
  String get cancel => 'Prekliči';

  @override
  String get save => 'Shrani';

  @override
  String get delete => 'Izbriši';

  @override
  String get continueLabel => 'Nadaljuj';

  @override
  String get next => 'Naprej';

  @override
  String get back => 'Nazaj';

  @override
  String get loading => 'Nalaganje…';

  @override
  String get settingsTooltip => 'Nastavitve';

  @override
  String get newEventButton => 'Nov dogodek';

  @override
  String couldNotLoadEvents(String error) {
    return 'Dogodkov ni bilo mogoče naložiti:\n$error';
  }

  @override
  String get viewMonth => 'Mesec';

  @override
  String get viewWeek => 'Teden';

  @override
  String get viewDay => 'Dan';

  @override
  String get viewList => 'Seznam';

  @override
  String get noEventsToday => 'Na ta dan ni dogodkov.';

  @override
  String get noUpcomingEvents =>
      'V naslednjih 60 dneh ni prihajajočih dogodkov.';

  @override
  String get untitledEvent => '(brez naslova)';

  @override
  String get allDay => 'Ves dan';

  @override
  String get addAccountToSyncTooltip => 'Dodaj račun Nostr za sinhronizacijo';

  @override
  String get syncNowTooltip => 'Sinhroniziraj zdaj';

  @override
  String get addNostrAccountTitle => 'Dodaj račun Nostr';

  @override
  String get eventNotFound => 'Dogodek ni bil najden.';

  @override
  String get eventAppBarTitle => 'Dogodek';

  @override
  String get editTooltip => 'Uredi';

  @override
  String get deleteTooltip => 'Izbriši';

  @override
  String allDayLabel(String date) {
    return '$date · Ves dan';
  }

  @override
  String recurrenceUntilLabel(String recurrence, String date) {
    return '$recurrence · do $date';
  }

  @override
  String get syncedToRelays => 'Sinhronizirano s releji';

  @override
  String get notYetSynced => 'Še ni sinhronizirano';

  @override
  String get deleteEventTitle => 'Izbrišem dogodek?';

  @override
  String get deleteEventBody =>
      'To odstrani dogodek iz te naprave in zahteva izbris iz relejev.';

  @override
  String get editEventTitle => 'Uredi dogodek';

  @override
  String get newEventTitle => 'Nov dogodek';

  @override
  String get fieldTitle => 'Naslov';

  @override
  String get allDaySwitch => 'Ves dan';

  @override
  String get startsLabel => 'Začetek';

  @override
  String get endsLabel => 'Konec';

  @override
  String get timezoneLabel => 'Časovni pas';

  @override
  String get repeatsLabel => 'Ponavljanje';

  @override
  String get untilLabel => 'Do';

  @override
  String get foreverLabel => 'Za vedno';

  @override
  String get remindersLabel => 'Opomniki';

  @override
  String get addChip => 'Dodaj';

  @override
  String get colorLabel => 'Barva';

  @override
  String get locationLabel => 'Lokacija';

  @override
  String get descriptionLabel => 'Opis';

  @override
  String couldNotSaveEvent(String error) {
    return 'Dogodka ni bilo mogoče shraniti: $error';
  }

  @override
  String get recurrenceNone => 'Se ne ponavlja';

  @override
  String get recurrenceDaily => 'Dnevno';

  @override
  String get recurrenceWeekly => 'Tedensko';

  @override
  String get recurrenceMonthly => 'Mesečno';

  @override
  String get recurrenceYearly => 'Letno';

  @override
  String get reminderAtStart => 'Ob začetku';

  @override
  String reminderMinutesBefore(int count) {
    return '$count min prej';
  }

  @override
  String reminderHoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ur prej',
      few: '$count ure prej',
      two: '$count uri prej',
      one: '1 uro prej',
    );
    return '$_temp0';
  }

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dni prej',
      few: '$count dni prej',
      two: '$count dneva prej',
      one: '1 dan prej',
    );
    return '$_temp0';
  }

  @override
  String get getStarted => 'Začni';

  @override
  String get useOffline => 'Uporabi brez povezave';

  @override
  String get welcomeTitle => 'Dobrodošli v Astraea';

  @override
  String get welcomeSubtitle =>
      'Zaseben koledar, ki daje prednost delu brez povezave in vam prepušča nadzor.';

  @override
  String get featureLocalTitle => 'Vaš koledar ostane na vaši napravi';

  @override
  String get featureLocalBody =>
      'Ustvarjajte dogodke, ponavljanja in opomnike brez računa ali internetne povezave.';

  @override
  String get featureSyncTitle => 'Neobvezna sinhronizacija prek Nostra';

  @override
  String get featureSyncBody =>
      'Povežite račun za varnostno kopiranje koledarja in njegovo uporabo na več napravah prek relejev, ki jih izberete.';

  @override
  String get featureEncryptedTitle => 'Vedno šifrirano pred nalaganjem';

  @override
  String get featureEncryptedBody =>
      'Vsebina koledarja je šifrirana od konca do konca, preden zapusti to napravo. Upravljavci relejev je ne morejo brati.';

  @override
  String get featureAmberTitle => 'Hranite ključ v Amberju';

  @override
  String get featureAmberBody =>
      'Na Androidu lahko zunanji podpisnik odobri dostop, ne da bi izpostavil vaš zasebni ključ Astraei.';

  @override
  String get featureRemindersTitle => 'Zasebni lokalni opomniki';

  @override
  String get featureRemindersBody =>
      'Obvestila razporeja vaša naprava in niso odvisna od storitve koledarja v oblaku.';

  @override
  String get connectNostrAccountTitle => 'Poveži račun Nostr';

  @override
  String get connectNostrAccountBody =>
      'To je potrebno samo za šifrirano sinhronizacijo. Astraeo lahko uporabljate tudi popolnoma brez povezave.';

  @override
  String get chooseRelaysTitle => 'Izberite releje za sinhronizacijo';

  @override
  String get chooseRelaysBody =>
      'Releji shranjujejo vaš šifrirani koledar in ga naredijo dostopnega na vaših drugih napravah. Dodajte enega ali več, ali pustite seznam prazen in ga konfigurirajte pozneje.';

  @override
  String couldNotLoadRelaySettings(String error) {
    return 'Nastavitev relejev ni bilo mogoče naložiti: $error';
  }

  @override
  String get suggestedRelays => 'Predlagani';

  @override
  String get addRelayTooltip => 'Dodaj relej';

  @override
  String get customRelayLabel => 'Relej po meri';

  @override
  String get customRelayHint => 'wss://relay.example.com';

  @override
  String get selectedRelays => 'Izbrani';

  @override
  String get removeRelayTooltip => 'Odstrani relej';

  @override
  String get invalidRelayUrl =>
      'Vnesite veljaven naslov URL wss:// (ali ws:// za zasebni relej).';

  @override
  String get insecureRelayWarning =>
      'ws:// med prenosom ni šifriran — uporabite ga le za relej, ki mu zaupate.';

  @override
  String get nostrAccountConnected => 'Račun Nostr povezan';

  @override
  String get invalidPrivateKey =>
      'Ta zasebni ključ ni veljaven. Preverite ga in poskusite znova.';

  @override
  String couldNotSignIn(String error) {
    return 'Prijava ni uspela: $error';
  }

  @override
  String get signInWithAmber => 'Prijava z Amberjem';

  @override
  String get createNewAccount => 'Ustvari nov račun';

  @override
  String get generatedAccountWarning =>
      'Ustvarjen račun je mogoče obnoviti samo z njegovim zasebnim ključem. Po nastavitvi ga varnostno kopirajte v Nastavitvah.';

  @override
  String get importExistingKey => 'Uvozi obstoječi ključ';

  @override
  String get privateKeyFieldLabel => 'nsec ali šestnajstiški zasebni ključ';

  @override
  String get importButton => 'Uvozi';

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
  String get followDeviceTimezone => 'Sledi časovnemu pasu naprave';

  @override
  String get searchCityRegion => 'Iskanje mesta ali regije';

  @override
  String get noMatchingTimezone => 'Ni ujemajočega časovnega pasu.';

  @override
  String get settingsTitle => 'Nastavitve';

  @override
  String couldNotLoadSettings(String error) {
    return 'Nastavitev ni bilo mogoče naložiti:\n$error';
  }

  @override
  String get sectionAccount => 'Račun';

  @override
  String get sectionSync => 'Sinhronizacija';

  @override
  String get sectionRelays => 'Releji';

  @override
  String get sectionAppearance => 'Videz';

  @override
  String get sectionData => 'Podatki';

  @override
  String get sectionRemindersTimezone => 'Opomniki in časovni pas';

  @override
  String get sectionSupport => 'Podpora';

  @override
  String somethingWentWrong(String error) {
    return 'Nekaj je šlo narobe: $error';
  }

  @override
  String get offlineNoAccount => 'Brez povezave — brez računa';

  @override
  String get signInToSyncAcrossDevices =>
      'Prijavite se za sinhronizacijo šifriranega koledarja med napravami.';

  @override
  String get signIn => 'Prijava';

  @override
  String get signedInWithAmber => 'Prijavljeni z Amberjem';

  @override
  String get signedIn => 'Prijavljeni';

  @override
  String get signOut => 'Odjava';

  @override
  String get backUpPrivateKey => 'Varnostno kopiraj zasebni ključ';

  @override
  String get revealNsecSubtitle =>
      'Prikažite svoj nsec, da ga shranite na varno mesto';

  @override
  String get signOutTitle => 'Se želite odjaviti?';

  @override
  String get signOutBody =>
      'Vaši dogodki ostanejo na tej napravi in na relejih. Prepričajte se, da ste varnostno kopirali zasebni ključ — brez njega ustvarjenega računa ni mogoče obnoviti.';

  @override
  String get noPrivateKeyStored =>
      'Za to sejo ni shranjenega zasebnega ključa.';

  @override
  String get yourPrivateKeyTitle => 'Vaš zasebni ključ (nsec)';

  @override
  String get nsecWarning =>
      'Kdorkoli ima ta ključ, nadzoruje vaš račun. Nikoli ga ne delite; hranite ga v upravitelju gesel.';

  @override
  String get copy => 'Kopiraj';

  @override
  String get done => 'Končano';

  @override
  String get syncNowTitle => 'Sinhroniziraj zdaj';

  @override
  String get signInToSyncSubtitle =>
      'Prijavite se za sinhronizacijo šifriranega koledarja.';

  @override
  String get addRelayToSyncSubtitle =>
      'Za sinhronizacijo dodajte vsaj en relej.';

  @override
  String get syncingEllipsis => 'Sinhroniziranje…';

  @override
  String get synced => 'Sinhronizirano';

  @override
  String lastSyncedLabel(String when) {
    return 'Nazadnje sinhronizirano $when';
  }

  @override
  String lastSyncFailedLabel(String error) {
    return 'Zadnja sinhronizacija ni uspela: $error';
  }

  @override
  String get pullMergePublish => 'Pridobi, združi in objavi vaše dogodke';

  @override
  String get publicRelays => 'Javni releji';

  @override
  String relaysConfiguredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count konfiguriranih',
      few: '$count konfigurirani',
      two: '$count konfigurirana',
      one: '1 konfiguriran',
    );
    return '$_temp0';
  }

  @override
  String get addRelay => 'Dodaj relej';

  @override
  String get suggestedRelaysTitle => 'Predlagani releji';

  @override
  String get addOnlyRelaysYouWant =>
      'Dodajte samo releje, ki jih želite uporabljati.';

  @override
  String get homeRelayBackup => 'Osebni relej (varnostna kopija)';

  @override
  String get homeRelayNotConfigured =>
      'Ni konfiguriran — dodaten osebni relej za varnostno kopiranje vaših dogodkov';

  @override
  String get homeRelayDialogTitle => 'Osebni relej';

  @override
  String get lightTheme => 'Svetla tema';

  @override
  String get darkThemeDefault => 'Astraea privzeto uporablja temno temo';

  @override
  String get languageLabel => 'Jezik';

  @override
  String get systemLanguage => 'Sistemski jezik';

  @override
  String get accentColorLabel => 'Barva poudarka';

  @override
  String get accentNavy => 'Mornarsko modra';

  @override
  String get accentBitcoin => 'Bitcoin oranžna';

  @override
  String get accentNostr => 'Nostr vijolična';

  @override
  String get exportEvents => 'Izvozi dogodke';

  @override
  String get exportEventsSubtitle =>
      'Shrani datoteko .ics — po izbiri zaščiteno z geslom';

  @override
  String get importEvents => 'Uvozi dogodke';

  @override
  String get importEventsSubtitle =>
      'Iz datoteke .ics ali šifriranega izvoza Astraea';

  @override
  String get encryptExportTitle => 'Šifriram ta izvoz?';

  @override
  String get encryptExportBody =>
      'Navadno datoteko .ics lahko odpre katera koli koledarska aplikacija — in kdor koli, ki jo pridobi. Nastavite geslo za njeno šifriranje (le Astraea jo bo lahko ponovno uvozila).';

  @override
  String get exportPasswordLabel =>
      'Geslo (pustite prazno za navadno datoteko .ics)';

  @override
  String get export => 'Izvozi';

  @override
  String get encryptedExportSaved => 'Šifriran izvoz shranjen.';

  @override
  String get exportSaved => 'Izvoz shranjen.';

  @override
  String exportFailed(String error) {
    return 'Izvoz ni uspel: $error';
  }

  @override
  String get couldNotReadSelectedFile =>
      'Izbrane datoteke ni bilo mogoče prebrati.';

  @override
  String get selectedFileTooLarge => 'Izbrana datoteka je večja od 10 MB.';

  @override
  String importedEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Uvoženih je bilo $count dogodkov.',
      few: 'Uvoženi so bili $count dogodki.',
      two: 'Uvožena sta bila $count dogodka.',
      one: 'Uvožen je bil 1 dogodek.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(String error) {
    return 'Uvoz ni uspel: $error';
  }

  @override
  String get thisExportIsEncrypted => 'Ta izvoz je šifriran';

  @override
  String get passwordLabel => 'Geslo';

  @override
  String get wrongPassword => 'Napačno geslo.';

  @override
  String get invalidEncryptedExport => 'Ta šifriran izvoz ni veljaven.';

  @override
  String get reminders => 'Opomniki';

  @override
  String get scheduleLocalNotifications =>
      'Razporedi lokalna obvestila za opomnike dogodkov';

  @override
  String get timezone => 'Časovni pas';

  @override
  String followDeviceTimezoneWithName(String zone) {
    return 'Sledi časovnemu pasu naprave ($zone)';
  }

  @override
  String get supportAstraea => 'Podprite Astraeo';

  @override
  String noLightningWalletFound(String address) {
    return 'Denarnice Lightning ni bilo mogoče najti — naslov kopiran: $address';
  }

  @override
  String get desktopServiceUnreachableTitle =>
      'Ozadnja storitev Astraea ni na voljo';

  @override
  String get desktopServiceUnreachableBody =>
      'Namizna aplikacija se za shranjevanje, sinhronizacijo in obvestila povezuje z astraea-service prek D-Bus, vendar je ni bilo mogoče doseči. Če jo poganjate iz izvorne kode, jo namestite z:\n\n./scripts/install-dev.sh';

  @override
  String get retry => 'Poskusi znova';

  @override
  String get calendarsLabel => 'Koledarji';

  @override
  String calendarsUnavailable(String error) {
    return 'Koledarji niso na voljo: $error';
  }

  @override
  String get serviceUnreachable => 'Storitev ni dosegljiva';

  @override
  String syncStatusLabel(String status) {
    return 'Sinhronizacija: $status';
  }

  @override
  String syncPendingSuffix(int count) {
    return ' ($count v čakanju)';
  }

  @override
  String get localOnlyMode => 'Samo lokalni način (brez identitete Nostr)';

  @override
  String get syncStarted => 'Sinhronizacija se je začela';

  @override
  String syncUnavailable(String error) {
    return 'Sinhronizacija ni na voljo: $error';
  }

  @override
  String get notSignedIn => 'Niste prijavljeni';

  @override
  String get signInWithBrowserSubtitle =>
      'Prijavite se prek brskalnika (NIP-07), da sinhronizirate ta koledar prek Nostra.';

  @override
  String get signedInBackgroundSigning =>
      'Prijavljeni — podpisovanje v ozadju z delegiranim ključem';

  @override
  String get signedInRemoteSigner =>
      'Prijavljeni — oddaljeni podpisnik (NIP-46)';

  @override
  String get signedInNoBackgroundSigner =>
      'Prijavljeni, vendar ni konfiguriran noben podpisnik v ozadju — sinhronizacija ostaja začasno ustavljena. Zaženite »astraea-service auth provision-key« v terminalu.';

  @override
  String couldNotStartLogin(String error) {
    return 'Prijave ni bilo mogoče začeti: $error';
  }

  @override
  String get signOutConfirmDesktopBody =>
      'S tem pozabite račun le na tej napravi — vaši dogodki ostanejo na relejih. Morebitni zagotovljeni podpisni ključ se odstrani iz zbirke ključev.';

  @override
  String get signInWithBrowserTitle => 'Prijavite se prek brskalnika';

  @override
  String get loginSessionExpired =>
      'Ta prijavna seja je potekla. Poskusite znova.';

  @override
  String get loginWaitingBody =>
      'Odprl se je zavihek brskalnika za potrditev vaše identitete Nostr (NIP-07). Odobrite jo tam — to pogovorno okno se samodejno zapre. Vaš zasebni ključ nikoli ni zahtevan.';

  @override
  String get openAgain => 'Odpri znova';

  @override
  String get offlineWillRetry =>
      'Brez povezave — samodejno bo poskusilo znova.';

  @override
  String get upToDate => 'Posodobljeno';

  @override
  String operationsFailingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spodletelih operacij',
      few: '$count spodletele operacije',
      two: '$count spodleteli operaciji',
      one: '1 spodletela operacija',
    );
    return '$_temp0';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count v čakanju',
      few: '$count v čakanju',
      two: '$count v čakanju',
      one: '1 v čakanju',
    );
    return '$_temp0';
  }

  @override
  String pendingFailingCount(String pending, String failing) {
    return '$pending, $failing';
  }

  @override
  String get relayStatus => 'Stanje relejev';

  @override
  String get relaysLabel => 'Releji';

  @override
  String relaysConfiguredLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count konfiguriranih',
      few: '$count konfigurirani',
      two: '$count konfigurirana',
      one: '1 konfiguriran',
    );
    return '$_temp0';
  }

  @override
  String get unencryptedTransport => 'Nešifriran prenos';

  @override
  String couldNotReachService(String error) {
    return 'S astraea-service ni bilo mogoče vzpostaviti povezave: $error';
  }

  @override
  String get inviteSectionTitle => 'Udeleženci';

  @override
  String get inviteButtonLabel => 'Povabi';

  @override
  String get noAttendeesYet => 'Nihče še ni povabljen';

  @override
  String get inviteDialogTitle => 'Povabi nekoga';

  @override
  String get inviteDialogHint => 'npub, ime@domena ali javni ključ';

  @override
  String resolvePersonFailed(String error) {
    return 'Te osebe ni bilo mogoče najti: $error';
  }

  @override
  String get confirmNip05Title => 'Potrdi prejemnika';

  @override
  String confirmNip05Body(String query, String pubkey) {
    return '$query je bil prek NIP-05 razrešen v $pubkey. To preslikavo nadzoruje domena — prepričajte se, da gre za pričakovano osebo.';
  }

  @override
  String get attendeeStatusInvited => 'Povabljen';

  @override
  String get attendeeStatusAccepted => 'Sprejeto';

  @override
  String get attendeeStatusDeclined => 'Zavrnjeno';

  @override
  String inviteFailed(String error) {
    return 'Povabila ni bilo mogoče poslati: $error';
  }

  @override
  String get pendingInvitationsTooltip => 'Povabila';

  @override
  String get pendingInvitationsTitle => 'Povabila';

  @override
  String get pendingInvitationsEmpty => 'Ni čakajočih povabil';

  @override
  String invitationFromLabel(String pubkey) {
    return 'Od $pubkey';
  }

  @override
  String get acceptInvitation => 'Sprejmi';

  @override
  String get declineInvitation => 'Zavrni';

  @override
  String respondToInvitationFailed(String error) {
    return 'Odgovora ni bilo mogoče poslati: $error';
  }

  @override
  String get invitationAccepted => 'Povabilo sprejeto';

  @override
  String get invitationDeclined => 'Povabilo zavrnjeno';
}
