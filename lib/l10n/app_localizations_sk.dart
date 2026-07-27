// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String get appTitle => 'Astraea';

  @override
  String get cancel => 'Zrušiť';

  @override
  String get save => 'Uložiť';

  @override
  String get delete => 'Odstrániť';

  @override
  String get continueLabel => 'Pokračovať';

  @override
  String get next => 'Ďalej';

  @override
  String get back => 'Späť';

  @override
  String get loading => 'Načítava sa…';

  @override
  String get settingsTooltip => 'Nastavenia';

  @override
  String get newEventButton => 'Nová udalosť';

  @override
  String couldNotLoadEvents(String error) {
    return 'Udalosti sa nepodarilo načítať:\n$error';
  }

  @override
  String get viewMonth => 'Mesiac';

  @override
  String get viewWeek => 'Týždeň';

  @override
  String get viewDay => 'Deň';

  @override
  String get viewList => 'Zoznam';

  @override
  String get noEventsToday => 'V tento deň nie sú žiadne udalosti.';

  @override
  String get noUpcomingEvents =>
      'V nasledujúcich 60 dňoch nie sú žiadne nadchádzajúce udalosti.';

  @override
  String get untitledEvent => '(bez názvu)';

  @override
  String get allDay => 'Celý deň';

  @override
  String get addAccountToSyncTooltip => 'Pridať účet Nostr na synchronizáciu';

  @override
  String get syncNowTooltip => 'Synchronizovať teraz';

  @override
  String get addNostrAccountTitle => 'Pridať účet Nostr';

  @override
  String get eventNotFound => 'Udalosť sa nenašla.';

  @override
  String get eventAppBarTitle => 'Udalosť';

  @override
  String get editTooltip => 'Upraviť';

  @override
  String get deleteTooltip => 'Odstrániť';

  @override
  String allDayLabel(String date) {
    return '$date · Celý deň';
  }

  @override
  String recurrenceUntilLabel(String recurrence, String date) {
    return '$recurrence · do $date';
  }

  @override
  String get syncedToRelays => 'Synchronizované s relé';

  @override
  String get notYetSynced => 'Zatiaľ nesynchronizované';

  @override
  String get deleteEventTitle => 'Odstrániť udalosť?';

  @override
  String get deleteEventBody =>
      'Tým sa udalosť odstráni z tohto zariadenia a požiada sa o jej odstránenie z relé.';

  @override
  String get editEventTitle => 'Upraviť udalosť';

  @override
  String get newEventTitle => 'Nová udalosť';

  @override
  String get fieldTitle => 'Názov';

  @override
  String get allDaySwitch => 'Celý deň';

  @override
  String get startsLabel => 'Začína';

  @override
  String get endsLabel => 'Končí';

  @override
  String get timezoneLabel => 'Časové pásmo';

  @override
  String get repeatsLabel => 'Opakovanie';

  @override
  String get untilLabel => 'Do';

  @override
  String get foreverLabel => 'Navždy';

  @override
  String get remindersLabel => 'Pripomienky';

  @override
  String get addChip => 'Pridať';

  @override
  String get colorLabel => 'Farba';

  @override
  String get locationLabel => 'Miesto';

  @override
  String get descriptionLabel => 'Popis';

  @override
  String couldNotSaveEvent(String error) {
    return 'Udalosť sa nepodarilo uložiť: $error';
  }

  @override
  String get recurrenceNone => 'Neopakuje sa';

  @override
  String get recurrenceDaily => 'Denne';

  @override
  String get recurrenceWeekly => 'Týždenne';

  @override
  String get recurrenceMonthly => 'Mesačne';

  @override
  String get recurrenceYearly => 'Ročne';

  @override
  String get reminderAtStart => 'Na začiatku';

  @override
  String reminderMinutesBefore(int count) {
    return '$count min vopred';
  }

  @override
  String reminderHoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hodín vopred',
      many: '$count hodiny vopred',
      few: '$count hodiny vopred',
      one: '1 hodinu vopred',
    );
    return '$_temp0';
  }

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dní vopred',
      many: '$count dňa vopred',
      few: '$count dni vopred',
      one: '1 deň vopred',
    );
    return '$_temp0';
  }

  @override
  String get getStarted => 'Začať';

  @override
  String get useOffline => 'Použiť offline';

  @override
  String get welcomeTitle => 'Vitajte v Astraea';

  @override
  String get welcomeSubtitle =>
      'Súkromný, offline kalendár, ktorý vám ponecháva kontrolu.';

  @override
  String get featureLocalTitle => 'Váš kalendár zostáva vo vašom zariadení';

  @override
  String get featureLocalBody =>
      'Vytvárajte udalosti, opakovania a pripomienky bez účtu alebo internetového pripojenia.';

  @override
  String get featureSyncTitle => 'Voliteľná synchronizácia cez Nostr';

  @override
  String get featureSyncBody =>
      'Pripojte účet na zálohovanie kalendára a jeho používanie na viacerých zariadeniach prostredníctvom relé, ktoré si vyberiete.';

  @override
  String get featureEncryptedTitle => 'Vždy zašifrované pred nahraním';

  @override
  String get featureEncryptedBody =>
      'Obsah kalendára je end-to-end šifrovaný predtým, ako opustí toto zariadenie. Prevádzkovatelia relé ho nemôžu čítať.';

  @override
  String get featureAmberTitle => 'Uchovávajte kľúč v Amber';

  @override
  String get featureAmberBody =>
      'V Androide môže externý podpisovateľ schváliť prístup bez toho, aby vystavil váš súkromný kľúč Astraea.';

  @override
  String get featureRemindersTitle => 'Súkromné lokálne pripomienky';

  @override
  String get featureRemindersBody =>
      'Upozornenia naplánuje vaše zariadenie a nezávisia od cloudovej kalendárovej služby.';

  @override
  String get connectNostrAccountTitle => 'Pripojiť účet Nostr';

  @override
  String get connectNostrAccountBody =>
      'Toto je potrebné iba pre šifrovanú synchronizáciu. Astraea môžete používať aj úplne offline.';

  @override
  String get chooseRelaysTitle => 'Vyberte relé na synchronizáciu';

  @override
  String get chooseRelaysBody =>
      'Relé ukladajú váš šifrovaný kalendár a sprístupňujú ho na vašich ďalších zariadeniach. Pridajte jedno alebo viac, alebo nechajte zoznam prázdny a nastavte to neskôr.';

  @override
  String couldNotLoadRelaySettings(String error) {
    return 'Nastavenia relé sa nepodarilo načítať: $error';
  }

  @override
  String get suggestedRelays => 'Navrhované';

  @override
  String get addRelayTooltip => 'Pridať relé';

  @override
  String get customRelayLabel => 'Vlastné relé';

  @override
  String get customRelayHint => 'wss://relay.example.com';

  @override
  String get selectedRelays => 'Vybrané';

  @override
  String get removeRelayTooltip => 'Odstrániť relé';

  @override
  String get invalidRelayUrl =>
      'Zadajte platnú adresu wss:// (alebo ws:// pre súkromné relé).';

  @override
  String get insecureRelayWarning =>
      'ws:// je počas prenosu nešifrované — používajte ho iba pre relé, ktorému dôverujete.';

  @override
  String get nostrAccountConnected => 'Účet Nostr pripojený';

  @override
  String get invalidPrivateKey =>
      'Tento súkromný kľúč nie je platný. Skontrolujte ho a skúste to znova.';

  @override
  String couldNotSignIn(String error) {
    return 'Prihlásenie zlyhalo: $error';
  }

  @override
  String get signInWithAmber => 'Prihlásiť sa cez Amber';

  @override
  String get createNewAccount => 'Vytvoriť nový účet';

  @override
  String get generatedAccountWarning =>
      'Vygenerovaný účet je možné obnoviť iba pomocou jeho súkromného kľúča. Po nastavení si ho zálohujte v Nastaveniach.';

  @override
  String get importExistingKey => 'Importovať existujúci kľúč';

  @override
  String get privateKeyFieldLabel => 'nsec alebo hexadecimálny súkromný kľúč';

  @override
  String get importButton => 'Importovať';

  @override
  String get followDeviceTimezone => 'Použiť časové pásmo zariadenia';

  @override
  String get searchCityRegion => 'Hľadať mesto alebo región';

  @override
  String get noMatchingTimezone => 'Žiadne zodpovedajúce časové pásmo.';

  @override
  String get settingsTitle => 'Nastavenia';

  @override
  String couldNotLoadSettings(String error) {
    return 'Nastavenia sa nepodarilo načítať:\n$error';
  }

  @override
  String get sectionAccount => 'Účet';

  @override
  String get sectionSync => 'Synchronizácia';

  @override
  String get sectionRelays => 'Relé';

  @override
  String get sectionAppearance => 'Vzhľad';

  @override
  String get sectionData => 'Dáta';

  @override
  String get sectionRemindersTimezone => 'Pripomienky a časové pásmo';

  @override
  String get sectionSupport => 'Podpora';

  @override
  String somethingWentWrong(String error) {
    return 'Niečo sa pokazilo: $error';
  }

  @override
  String get offlineNoAccount => 'Offline — žiadny účet';

  @override
  String get signInToSyncAcrossDevices =>
      'Prihláste sa na synchronizáciu šifrovaného kalendára medzi zariadeniami.';

  @override
  String get signIn => 'Prihlásiť sa';

  @override
  String get signedInWithAmber => 'Prihlásené cez Amber';

  @override
  String get signedIn => 'Prihlásené';

  @override
  String get signOut => 'Odhlásiť sa';

  @override
  String get backUpPrivateKey => 'Zálohovať súkromný kľúč';

  @override
  String get revealNsecSubtitle =>
      'Zobraziť nsec na uloženie na bezpečné miesto';

  @override
  String get signOutTitle => 'Odhlásiť sa?';

  @override
  String get signOutBody =>
      'Vaše udalosti zostanú v tomto zariadení a na relé. Uistite sa, že ste si zálohovali súkromný kľúč — bez neho nie je možné vygenerovaný účet obnoviť.';

  @override
  String get noPrivateKeyStored =>
      'Pre túto reláciu nie je uložený žiadny súkromný kľúč.';

  @override
  String get yourPrivateKeyTitle => 'Váš súkromný kľúč (nsec)';

  @override
  String get nsecWarning =>
      'Ktokoľvek s týmto kľúčom ovláda váš účet. Nikdy ho nezdieľajte; uchovávajte ho v správcovi hesiel.';

  @override
  String get copy => 'Kopírovať';

  @override
  String get done => 'Hotovo';

  @override
  String get syncNowTitle => 'Synchronizovať teraz';

  @override
  String get signInToSyncSubtitle =>
      'Prihláste sa na synchronizáciu šifrovaného kalendára.';

  @override
  String get addRelayToSyncSubtitle =>
      'Na synchronizáciu pridajte aspoň jedno relé.';

  @override
  String get syncingEllipsis => 'Synchronizuje sa…';

  @override
  String get synced => 'Synchronizované';

  @override
  String lastSyncedLabel(String when) {
    return 'Naposledy synchronizované $when';
  }

  @override
  String lastSyncFailedLabel(String error) {
    return 'Posledná synchronizácia zlyhala: $error';
  }

  @override
  String get pullMergePublish => 'Stiahne, zlúči a publikuje vaše udalosti';

  @override
  String get publicRelays => 'Verejné relé';

  @override
  String relaysConfiguredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nakonfigurovaných',
      many: '$count nakonfigurovaného',
      few: '$count nakonfigurované',
      one: '1 nakonfigurované',
    );
    return '$_temp0';
  }

  @override
  String get addRelay => 'Pridať relé';

  @override
  String get suggestedRelaysTitle => 'Navrhované relé';

  @override
  String get addOnlyRelaysYouWant =>
      'Pridávajte iba relé, ktoré chcete používať.';

  @override
  String get homeRelayBackup => 'Osobné relé (záloha)';

  @override
  String get homeRelayNotConfigured =>
      'Nenakonfigurované — ďalšie osobné relé na zálohovanie vašich udalostí';

  @override
  String get homeRelayDialogTitle => 'Osobné relé';

  @override
  String get lightTheme => 'Svetlá téma';

  @override
  String get darkThemeDefault => 'Astraea predvolene používa tmavú tému';

  @override
  String get languageLabel => 'Jazyk';

  @override
  String get systemLanguage => 'Jazyk systému';

  @override
  String get exportEvents => 'Exportovať udalosti';

  @override
  String get exportEventsSubtitle =>
      'Uložiť súbor .ics — voliteľne chránený heslom';

  @override
  String get importEvents => 'Importovať udalosti';

  @override
  String get importEventsSubtitle =>
      'Zo súboru .ics alebo šifrovaného exportu Astraea';

  @override
  String get encryptExportTitle => 'Zašifrovať tento export?';

  @override
  String get encryptExportBody =>
      'Obyčajný súbor .ics môže otvoriť ktorákoľvek kalendárová aplikácia — a ktokoľvek, kto ho získa. Nastavte heslo na jeho zašifrovanie (znova ho bude môcť importovať iba Astraea).';

  @override
  String get exportPasswordLabel =>
      'Heslo (nechajte prázdne pre obyčajný súbor .ics)';

  @override
  String get export => 'Exportovať';

  @override
  String get encryptedExportSaved => 'Šifrovaný export uložený.';

  @override
  String get exportSaved => 'Export uložený.';

  @override
  String exportFailed(String error) {
    return 'Export zlyhal: $error';
  }

  @override
  String get couldNotReadSelectedFile =>
      'Vybraný súbor sa nepodarilo prečítať.';

  @override
  String get selectedFileTooLarge => 'Vybraný súbor je väčší ako 10 MB.';

  @override
  String importedEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importovaných $count udalostí.',
      many: 'Importovaných $count udalosti.',
      few: 'Importované $count udalosti.',
      one: 'Importovaná 1 udalosť.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(String error) {
    return 'Import zlyhal: $error';
  }

  @override
  String get thisExportIsEncrypted => 'Tento export je šifrovaný';

  @override
  String get passwordLabel => 'Heslo';

  @override
  String get wrongPassword => 'Nesprávne heslo.';

  @override
  String get invalidEncryptedExport => 'Tento šifrovaný export nie je platný.';

  @override
  String get reminders => 'Pripomienky';

  @override
  String get scheduleLocalNotifications =>
      'Naplánovať lokálne upozornenia na pripomienky udalostí';

  @override
  String get timezone => 'Časové pásmo';

  @override
  String followDeviceTimezoneWithName(String zone) {
    return 'Použiť časové pásmo zariadenia ($zone)';
  }

  @override
  String get supportAstraea => 'Podporiť Astraea';

  @override
  String noLightningWalletFound(String address) {
    return 'Nenašla sa žiadna Lightning peňaženka — adresa skopírovaná: $address';
  }

  @override
  String get desktopServiceUnreachableTitle =>
      'Služba Astraea na pozadí nie je dostupná';

  @override
  String get desktopServiceUnreachableBody =>
      'Desktopová aplikácia komunikuje so službou astraea-service cez D-Bus kvôli ukladaniu, synchronizácii a upozorneniam, ale nepodarilo sa ju zastihnúť. Ak ju spúšťate zo zdrojového kódu, nainštalujte ju pomocou:\n\n./scripts/install-dev.sh';

  @override
  String get retry => 'Skúsiť znova';

  @override
  String get calendarsLabel => 'Kalendáre';

  @override
  String calendarsUnavailable(String error) {
    return 'Kalendáre nie sú dostupné: $error';
  }

  @override
  String get serviceUnreachable => 'Služba nedostupná';

  @override
  String syncStatusLabel(String status) {
    return 'Synchronizácia: $status';
  }

  @override
  String syncPendingSuffix(int count) {
    return ' ($count čaká)';
  }

  @override
  String get localOnlyMode => 'Iba lokálny režim (žiadna identita Nostr)';

  @override
  String get syncStarted => 'Synchronizácia spustená';

  @override
  String syncUnavailable(String error) {
    return 'Synchronizácia nie je dostupná: $error';
  }

  @override
  String get notSignedIn => 'Neprihlásené';

  @override
  String get signInWithBrowserSubtitle =>
      'Prihláste sa cez prehliadač (NIP-07) na synchronizáciu tohto kalendára cez Nostr.';

  @override
  String get signedInBackgroundSigning =>
      'Prihlásené — podpisovanie na pozadí pomocou delegovaného kľúča';

  @override
  String get signedInRemoteSigner =>
      'Prihlásené — vzdialený podpisovateľ (NIP-46)';

  @override
  String get signedInNoBackgroundSigner =>
      'Prihlásené, ale nie je nakonfigurovaný žiadny podpisovateľ na pozadí — synchronizácia zostáva pozastavená. Spustite „astraea-service auth provision-key“ v termináli.';

  @override
  String couldNotStartLogin(String error) {
    return 'Prihlásenie sa nepodarilo spustiť: $error';
  }

  @override
  String get signOutConfirmDesktopBody =>
      'Tým sa účet zabudne iba na tomto zariadení — vaše udalosti zostanú na relé. Prípadný poskytnutý podpisový kľúč sa odstráni z kľúčenky.';

  @override
  String get signInWithBrowserTitle => 'Prihláste sa cez prehliadač';

  @override
  String get loginSessionExpired =>
      'Táto prihlasovacia relácia vypršala. Skúste to znova.';

  @override
  String get loginWaitingBody =>
      'Otvorila sa karta prehliadača na potvrdenie vašej identity Nostr (NIP-07). Schváľte ju tam — toto okno sa zavrie automaticky. Váš súkromný kľúč sa nikdy nevyžaduje.';

  @override
  String get openAgain => 'Otvoriť znova';

  @override
  String get offlineWillRetry => 'Offline — automaticky to skúsi znova.';

  @override
  String get upToDate => 'Aktuálne';

  @override
  String operationsFailingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count neúspešných operácií',
      many: '$count neúspešnej operácie',
      few: '$count neúspešné operácie',
      one: '1 neúspešná operácia',
    );
    return '$_temp0';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count čakajúcich',
      many: '$count čakajúceho',
      few: '$count čakajúce',
      one: '1 čakajúce',
    );
    return '$_temp0';
  }

  @override
  String pendingFailingCount(String pending, String failing) {
    return '$pending, $failing';
  }

  @override
  String get relayStatus => 'Stav relé';

  @override
  String get relaysLabel => 'Relé';

  @override
  String relaysConfiguredLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nakonfigurovaných',
      many: '$count nakonfigurovaného',
      few: '$count nakonfigurované',
      one: '1 nakonfigurované',
    );
    return '$_temp0';
  }

  @override
  String get unencryptedTransport => 'Nešifrovaný prenos';

  @override
  String couldNotReachService(String error) {
    return 'Nepodarilo sa spojiť so službou astraea-service: $error';
  }

  @override
  String get inviteSectionTitle => 'Účastníci';

  @override
  String get inviteButtonLabel => 'Pozvať';

  @override
  String get noAttendeesYet => 'Zatiaľ nikto nebol pozvaný';

  @override
  String get inviteDialogTitle => 'Pozvať niekoho';

  @override
  String get inviteDialogHint => 'npub, meno@doména alebo verejný kľúč';

  @override
  String resolvePersonFailed(String error) {
    return 'Túto osobu sa nepodarilo nájsť: $error';
  }

  @override
  String get confirmNip05Title => 'Potvrďte príjemcu';

  @override
  String confirmNip05Body(String query, String pubkey) {
    return '$query bolo cez NIP-05 preložené na $pubkey. Toto priradenie spravuje doména — uistite sa, že ide o očakávanú osobu.';
  }

  @override
  String get attendeeStatusInvited => 'Pozvaný';

  @override
  String get attendeeStatusAccepted => 'Prijaté';

  @override
  String get attendeeStatusDeclined => 'Odmietnuté';

  @override
  String inviteFailed(String error) {
    return 'Pozvánku sa nepodarilo odoslať: $error';
  }

  @override
  String get pendingInvitationsTooltip => 'Pozvánky';

  @override
  String get pendingInvitationsTitle => 'Pozvánky';

  @override
  String get pendingInvitationsEmpty => 'Žiadne čakajúce pozvánky';

  @override
  String invitationFromLabel(String pubkey) {
    return 'Od $pubkey';
  }

  @override
  String get acceptInvitation => 'Prijať';

  @override
  String get declineInvitation => 'Odmietnuť';

  @override
  String respondToInvitationFailed(String error) {
    return 'Odpoveď sa nepodarilo odoslať: $error';
  }

  @override
  String get invitationAccepted => 'Pozvánka prijatá';

  @override
  String get invitationDeclined => 'Pozvánka odmietnutá';
}
