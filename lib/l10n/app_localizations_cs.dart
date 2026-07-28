// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get appTitle => 'Astraea';

  @override
  String get cancel => 'Zrušit';

  @override
  String get save => 'Uložit';

  @override
  String get delete => 'Odstranit';

  @override
  String get continueLabel => 'Pokračovat';

  @override
  String get next => 'Další';

  @override
  String get back => 'Zpět';

  @override
  String get loading => 'Načítání…';

  @override
  String get settingsTooltip => 'Nastavení';

  @override
  String get newEventButton => 'Nová událost';

  @override
  String couldNotLoadEvents(String error) {
    return 'Události se nepodařilo načíst:\n$error';
  }

  @override
  String get viewMonth => 'Měsíc';

  @override
  String get viewWeek => 'Týden';

  @override
  String get viewDay => 'Den';

  @override
  String get viewList => 'Seznam';

  @override
  String get noEventsToday => 'Tento den nejsou žádné události.';

  @override
  String get noUpcomingEvents =>
      'V následujících 60 dnech nejsou žádné nadcházející události.';

  @override
  String get untitledEvent => '(bez názvu)';

  @override
  String get allDay => 'Celý den';

  @override
  String get addAccountToSyncTooltip => 'Přidat účet Nostr pro synchronizaci';

  @override
  String get syncNowTooltip => 'Synchronizovat nyní';

  @override
  String get addNostrAccountTitle => 'Přidat účet Nostr';

  @override
  String get eventNotFound => 'Událost nebyla nalezena.';

  @override
  String get eventAppBarTitle => 'Událost';

  @override
  String get editTooltip => 'Upravit';

  @override
  String get deleteTooltip => 'Odstranit';

  @override
  String allDayLabel(String date) {
    return '$date · Celý den';
  }

  @override
  String recurrenceUntilLabel(String recurrence, String date) {
    return '$recurrence · do $date';
  }

  @override
  String get syncedToRelays => 'Synchronizováno s relaji';

  @override
  String get notYetSynced => 'Zatím nesynchronizováno';

  @override
  String get deleteEventTitle => 'Odstranit událost?';

  @override
  String get deleteEventBody =>
      'Tím se událost odstraní z tohoto zařízení a požádá se o její odstranění z relají.';

  @override
  String get editEventTitle => 'Upravit událost';

  @override
  String get newEventTitle => 'Nová událost';

  @override
  String get fieldTitle => 'Název';

  @override
  String get allDaySwitch => 'Celý den';

  @override
  String get startsLabel => 'Začíná';

  @override
  String get endsLabel => 'Končí';

  @override
  String get timezoneLabel => 'Časové pásmo';

  @override
  String get repeatsLabel => 'Opakování';

  @override
  String get untilLabel => 'Do';

  @override
  String get foreverLabel => 'Navždy';

  @override
  String get remindersLabel => 'Připomenutí';

  @override
  String get addChip => 'Přidat';

  @override
  String get colorLabel => 'Barva';

  @override
  String get locationLabel => 'Místo';

  @override
  String get descriptionLabel => 'Popis';

  @override
  String couldNotSaveEvent(String error) {
    return 'Událost se nepodařilo uložit: $error';
  }

  @override
  String get recurrenceNone => 'Neopakuje se';

  @override
  String get recurrenceDaily => 'Denně';

  @override
  String get recurrenceWeekly => 'Týdně';

  @override
  String get recurrenceMonthly => 'Měsíčně';

  @override
  String get recurrenceYearly => 'Ročně';

  @override
  String get reminderAtStart => 'Na začátku';

  @override
  String reminderMinutesBefore(int count) {
    return '$count min předem';
  }

  @override
  String reminderHoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hodin předem',
      many: '$count hodiny předem',
      few: '$count hodiny předem',
      one: '1 hodinu předem',
    );
    return '$_temp0';
  }

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dní předem',
      many: '$count dne předem',
      few: '$count dny předem',
      one: '1 den předem',
    );
    return '$_temp0';
  }

  @override
  String get getStarted => 'Začít';

  @override
  String get useOffline => 'Použít offline';

  @override
  String get welcomeTitle => 'Vítejte v Astraea';

  @override
  String get welcomeSubtitle =>
      'Soukromý kalendář, offline na prvním místě, který vám ponechává kontrolu.';

  @override
  String get featureLocalTitle => 'Váš kalendář zůstává na vašem zařízení';

  @override
  String get featureLocalBody =>
      'Vytvářejte události, opakování a připomenutí bez účtu nebo internetového připojení.';

  @override
  String get featureSyncTitle => 'Volitelná synchronizace přes Nostr';

  @override
  String get featureSyncBody =>
      'Připojte účet, abyste zálohovali kalendář a používali jej na více zařízeních přes relaje, které si vyberete.';

  @override
  String get featureEncryptedTitle => 'Vždy zašifrováno před nahráním';

  @override
  String get featureEncryptedBody =>
      'Obsah kalendáře je šifrován end-to-end, než opustí toto zařízení. Provozovatelé relají jej nemohou číst.';

  @override
  String get featureAmberTitle => 'Uchovávejte klíč v Amber';

  @override
  String get featureAmberBody =>
      'V Androidu může externí podepisovatel schválit přístup, aniž by vystavil váš soukromý klíč Astraea.';

  @override
  String get featureRemindersTitle => 'Soukromá místní připomenutí';

  @override
  String get featureRemindersBody =>
      'Oznámení naplánuje vaše zařízení a nejsou závislá na cloudové kalendářové službě.';

  @override
  String get connectNostrAccountTitle => 'Připojit účet Nostr';

  @override
  String get connectNostrAccountBody =>
      'Toto je potřeba pouze pro šifrovanou synchronizaci. Astraea můžete používat i zcela offline.';

  @override
  String get chooseRelaysTitle => 'Vyberte relaje pro synchronizaci';

  @override
  String get chooseRelaysBody =>
      'Relaje ukládají váš šifrovaný kalendář a zpřístupňují jej na vašich dalších zařízeních. Přidejte jeden nebo více, nebo ponechte seznam prázdný a nastavte to později.';

  @override
  String couldNotLoadRelaySettings(String error) {
    return 'Nastavení relají se nepodařilo načíst: $error';
  }

  @override
  String get suggestedRelays => 'Navrhované';

  @override
  String get addRelayTooltip => 'Přidat relaj';

  @override
  String get customRelayLabel => 'Vlastní relaj';

  @override
  String get customRelayHint => 'wss://relay.example.com';

  @override
  String get selectedRelays => 'Vybrané';

  @override
  String get removeRelayTooltip => 'Odebrat relaj';

  @override
  String get invalidRelayUrl =>
      'Zadejte platnou adresu wss:// (nebo ws:// pro soukromý relaj).';

  @override
  String get insecureRelayWarning =>
      'ws:// je při přenosu nešifrované — používejte jej pouze pro relaj, kterému důvěřujete.';

  @override
  String get nostrAccountConnected => 'Účet Nostr připojen';

  @override
  String get invalidPrivateKey =>
      'Tento soukromý klíč není platný. Zkontrolujte jej a zkuste to znovu.';

  @override
  String couldNotSignIn(String error) {
    return 'Přihlášení se nezdařilo: $error';
  }

  @override
  String get signInWithAmber => 'Přihlásit se přes Amber';

  @override
  String get createNewAccount => 'Vytvořit nový účet';

  @override
  String get generatedAccountWarning =>
      'Vygenerovaný účet lze obnovit pouze pomocí jeho soukromého klíče. Zálohujte jej z Nastavení po dokončení konfigurace.';

  @override
  String get importExistingKey => 'Importovat existující klíč';

  @override
  String get privateKeyFieldLabel => 'nsec nebo hexadecimální soukromý klíč';

  @override
  String get importButton => 'Importovat';

  @override
  String get followDeviceTimezone => 'Použít časové pásmo zařízení';

  @override
  String get searchCityRegion => 'Hledat město nebo region';

  @override
  String get noMatchingTimezone => 'Žádné odpovídající časové pásmo.';

  @override
  String get settingsTitle => 'Nastavení';

  @override
  String couldNotLoadSettings(String error) {
    return 'Nastavení se nepodařilo načíst:\n$error';
  }

  @override
  String get sectionAccount => 'Účet';

  @override
  String get sectionSync => 'Synchronizace';

  @override
  String get sectionRelays => 'Relaje';

  @override
  String get sectionAppearance => 'Vzhled';

  @override
  String get sectionData => 'Data';

  @override
  String get sectionRemindersTimezone => 'Připomenutí a časové pásmo';

  @override
  String get sectionSupport => 'Podpora';

  @override
  String somethingWentWrong(String error) {
    return 'Něco se pokazilo: $error';
  }

  @override
  String get offlineNoAccount => 'Offline — žádný účet';

  @override
  String get signInToSyncAcrossDevices =>
      'Přihlaste se pro synchronizaci šifrovaného kalendáře mezi zařízeními.';

  @override
  String get signIn => 'Přihlásit se';

  @override
  String get signedInWithAmber => 'Přihlášeno přes Amber';

  @override
  String get signedIn => 'Přihlášeno';

  @override
  String get signOut => 'Odhlásit se';

  @override
  String get backUpPrivateKey => 'Zálohovat soukromý klíč';

  @override
  String get revealNsecSubtitle =>
      'Zobrazit nsec pro uložení na bezpečné místo';

  @override
  String get signOutTitle => 'Odhlásit se?';

  @override
  String get signOutBody =>
      'Vaše události zůstanou v tomto zařízení a na relajích. Ujistěte se, že jste zálohovali svůj soukromý klíč — bez něj nelze vygenerovaný účet obnovit.';

  @override
  String get noPrivateKeyStored =>
      'Pro tuto relaci není uložen žádný soukromý klíč.';

  @override
  String get yourPrivateKeyTitle => 'Váš soukromý klíč (nsec)';

  @override
  String get nsecWarning =>
      'Kdokoli s tímto klíčem ovládá váš účet. Nikdy jej nesdílejte; uchovávejte jej ve správci hesel.';

  @override
  String get copy => 'Kopírovat';

  @override
  String get done => 'Hotovo';

  @override
  String get syncNowTitle => 'Synchronizovat nyní';

  @override
  String get signInToSyncSubtitle =>
      'Přihlaste se pro synchronizaci šifrovaného kalendáře.';

  @override
  String get addRelayToSyncSubtitle =>
      'Pro synchronizaci přidejte alespoň jeden relaj.';

  @override
  String get syncingEllipsis => 'Synchronizace…';

  @override
  String get synced => 'Synchronizováno';

  @override
  String lastSyncedLabel(String when) {
    return 'Naposledy synchronizováno $when';
  }

  @override
  String lastSyncFailedLabel(String error) {
    return 'Poslední synchronizace se nezdařila: $error';
  }

  @override
  String get pullMergePublish => 'Stáhne, sloučí a publikuje vaše události';

  @override
  String get publicRelays => 'Veřejné relaje';

  @override
  String relaysConfiguredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nakonfigurovaných',
      many: '$count nakonfigurovaného',
      few: '$count nakonfigurované',
      one: '1 nakonfigurovaný',
    );
    return '$_temp0';
  }

  @override
  String get addRelay => 'Přidat relaj';

  @override
  String get suggestedRelaysTitle => 'Navrhované relaje';

  @override
  String get addOnlyRelaysYouWant =>
      'Přidávejte pouze relaje, které chcete používat.';

  @override
  String get homeRelayBackup => 'Osobní relaj (záloha)';

  @override
  String get homeRelayNotConfigured =>
      'Nenakonfigurováno — další osobní relaj pro zálohování vašich událostí';

  @override
  String get homeRelayDialogTitle => 'Osobní relaj';

  @override
  String get lightTheme => 'Světlý motiv';

  @override
  String get darkThemeDefault =>
      'Astraea ve výchozím nastavení používá tmavý motiv';

  @override
  String get languageLabel => 'Jazyk';

  @override
  String get systemLanguage => 'Jazyk systému';

  @override
  String get accentColorLabel => 'Barva zvýraznění';

  @override
  String get accentNavy => 'Tmavě modrá';

  @override
  String get accentBitcoin => 'Bitcoinová oranžová';

  @override
  String get accentNostr => 'Nostr fialová';

  @override
  String get exportEvents => 'Exportovat události';

  @override
  String get exportEventsSubtitle =>
      'Uložit soubor .ics — volitelně chráněný heslem';

  @override
  String get importEvents => 'Importovat události';

  @override
  String get importEventsSubtitle =>
      'Ze souboru .ics nebo šifrovaného exportu Astraea';

  @override
  String get encryptExportTitle => 'Zašifrovat tento export?';

  @override
  String get encryptExportBody =>
      'Obyčejný soubor .ics může otevřít jakákoli kalendářová aplikace — a kdokoli, kdo jej získá. Nastavte heslo pro jeho zašifrování (znovu jej bude moci importovat pouze Astraea).';

  @override
  String get exportPasswordLabel =>
      'Heslo (ponechte prázdné pro obyčejný soubor .ics)';

  @override
  String get export => 'Exportovat';

  @override
  String get encryptedExportSaved => 'Šifrovaný export uložen.';

  @override
  String get exportSaved => 'Export uložen.';

  @override
  String exportFailed(String error) {
    return 'Export se nezdařil: $error';
  }

  @override
  String get couldNotReadSelectedFile =>
      'Vybraný soubor se nepodařilo přečíst.';

  @override
  String get selectedFileTooLarge => 'Vybraný soubor je větší než 10 MB.';

  @override
  String importedEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importováno $count událostí.',
      many: 'Importováno $count události.',
      few: 'Importovány $count události.',
      one: 'Importována 1 událost.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(String error) {
    return 'Import se nezdařil: $error';
  }

  @override
  String get thisExportIsEncrypted => 'Tento export je šifrovaný';

  @override
  String get passwordLabel => 'Heslo';

  @override
  String get wrongPassword => 'Nesprávné heslo.';

  @override
  String get invalidEncryptedExport => 'Tento šifrovaný export není platný.';

  @override
  String get reminders => 'Připomenutí';

  @override
  String get scheduleLocalNotifications =>
      'Naplánovat místní oznámení pro připomenutí událostí';

  @override
  String get timezone => 'Časové pásmo';

  @override
  String followDeviceTimezoneWithName(String zone) {
    return 'Použít časové pásmo zařízení ($zone)';
  }

  @override
  String get supportAstraea => 'Podpořit Astraea';

  @override
  String noLightningWalletFound(String address) {
    return 'Nebyla nalezena žádná Lightning peněženka — adresa zkopírována: $address';
  }

  @override
  String get desktopServiceUnreachableTitle =>
      'Služba Astraea na pozadí není dostupná';

  @override
  String get desktopServiceUnreachableBody =>
      'Desktopová aplikace komunikuje se službou astraea-service přes D-Bus kvůli ukládání, synchronizaci a oznámením, ale nepodařilo se ji zastihnout. Pokud ji spouštíte ze zdrojového kódu, nainstalujte ji pomocí:\n\n./scripts/install-dev.sh';

  @override
  String get retry => 'Zkusit znovu';

  @override
  String get calendarsLabel => 'Kalendáře';

  @override
  String calendarsUnavailable(String error) {
    return 'Kalendáře nejsou dostupné: $error';
  }

  @override
  String get serviceUnreachable => 'Služba nedostupná';

  @override
  String syncStatusLabel(String status) {
    return 'Synchronizace: $status';
  }

  @override
  String syncPendingSuffix(int count) {
    return ' ($count čeká)';
  }

  @override
  String get localOnlyMode => 'Pouze místní režim (žádná identita Nostr)';

  @override
  String get syncStarted => 'Synchronizace zahájena';

  @override
  String syncUnavailable(String error) {
    return 'Synchronizace není dostupná: $error';
  }

  @override
  String get notSignedIn => 'Nepřihlášeno';

  @override
  String get signInWithBrowserSubtitle =>
      'Přihlaste se přes prohlížeč (NIP-07) pro synchronizaci tohoto kalendáře přes Nostr.';

  @override
  String get signedInBackgroundSigning =>
      'Přihlášeno — podepisování na pozadí pomocí delegovaného klíče';

  @override
  String get signedInRemoteSigner =>
      'Přihlášeno — vzdálený podepisovatel (NIP-46)';

  @override
  String get signedInNoBackgroundSigner =>
      'Přihlášeno, ale není nakonfigurován žádný podepisovatel na pozadí — synchronizace zůstává pozastavena. Spusťte „astraea-service auth provision-key“ v terminálu.';

  @override
  String couldNotStartLogin(String error) {
    return 'Přihlášení se nepodařilo zahájit: $error';
  }

  @override
  String get signOutConfirmDesktopBody =>
      'Tím se účet zapomene pouze na tomto zařízení — vaše události zůstanou na relajích. Případný poskytnutý podpisový klíč bude odstraněn z klíčenky.';

  @override
  String get signInWithBrowserTitle => 'Přihlaste se přes prohlížeč';

  @override
  String get loginSessionExpired =>
      'Tato přihlašovací relace vypršela. Zkuste to znovu.';

  @override
  String get loginWaitingBody =>
      'Byla otevřena karta prohlížeče pro potvrzení vaší identity Nostr (NIP-07). Schvalte ji tam — toto okno se zavře automaticky. Váš soukromý klíč není nikdy vyžadován.';

  @override
  String get openAgain => 'Otevřít znovu';

  @override
  String get offlineWillRetry => 'Offline — automaticky to zkusí znovu.';

  @override
  String get upToDate => 'Aktuální';

  @override
  String operationsFailingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count neúspěšných operací',
      many: '$count neúspěšné operace',
      few: '$count neúspěšné operace',
      one: '1 neúspěšná operace',
    );
    return '$_temp0';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count čekajících',
      many: '$count čekající',
      few: '$count čekající',
      one: '1 čekající',
    );
    return '$_temp0';
  }

  @override
  String pendingFailingCount(String pending, String failing) {
    return '$pending, $failing';
  }

  @override
  String get relayStatus => 'Stav relají';

  @override
  String get relaysLabel => 'Relaje';

  @override
  String relaysConfiguredLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nakonfigurovaných',
      many: '$count nakonfigurovaného',
      few: '$count nakonfigurované',
      one: '1 nakonfigurovaný',
    );
    return '$_temp0';
  }

  @override
  String get unencryptedTransport => 'Nešifrovaný přenos';

  @override
  String couldNotReachService(String error) {
    return 'Nepodařilo se spojit se službou astraea-service: $error';
  }

  @override
  String get inviteSectionTitle => 'Účastníci';

  @override
  String get inviteButtonLabel => 'Pozvat';

  @override
  String get noAttendeesYet => 'Zatím nikdo nebyl pozván';

  @override
  String get inviteDialogTitle => 'Pozvat někoho';

  @override
  String get inviteDialogHint => 'npub, jméno@doména nebo veřejný klíč';

  @override
  String resolvePersonFailed(String error) {
    return 'Osobu se nepodařilo najít: $error';
  }

  @override
  String get confirmNip05Title => 'Potvrdit příjemce';

  @override
  String confirmNip05Body(String query, String pubkey) {
    return '$query bylo přeloženo na $pubkey přes NIP-05. Toto mapování spravuje doména – ujistěte se, že jde o osobu, kterou očekáváte.';
  }

  @override
  String get attendeeStatusInvited => 'Pozván';

  @override
  String get attendeeStatusAccepted => 'Přijato';

  @override
  String get attendeeStatusDeclined => 'Odmítnuto';

  @override
  String inviteFailed(String error) {
    return 'Pozvánku se nepodařilo odeslat: $error';
  }

  @override
  String get pendingInvitationsTooltip => 'Pozvánky';

  @override
  String get pendingInvitationsTitle => 'Pozvánky';

  @override
  String get pendingInvitationsEmpty => 'Žádné čekající pozvánky';

  @override
  String invitationFromLabel(String pubkey) {
    return 'Od $pubkey';
  }

  @override
  String get acceptInvitation => 'Přijmout';

  @override
  String get declineInvitation => 'Odmítnout';

  @override
  String respondToInvitationFailed(String error) {
    return 'Odpověď se nepodařilo odeslat: $error';
  }

  @override
  String get invitationAccepted => 'Pozvánka přijata';

  @override
  String get invitationDeclined => 'Pozvánka odmítnuta';
}
