// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Estonian (`et`).
class AppLocalizationsEt extends AppLocalizations {
  AppLocalizationsEt([String locale = 'et']) : super(locale);

  @override
  String get appTitle => 'Astraea';

  @override
  String get cancel => 'Tühista';

  @override
  String get save => 'Salvesta';

  @override
  String get delete => 'Kustuta';

  @override
  String get continueLabel => 'Jätka';

  @override
  String get next => 'Edasi';

  @override
  String get back => 'Tagasi';

  @override
  String get loading => 'Laadimine…';

  @override
  String get settingsTooltip => 'Seaded';

  @override
  String get newEventButton => 'Uus sündmus';

  @override
  String couldNotLoadEvents(String error) {
    return 'Sündmusi ei õnnestunud laadida:\n$error';
  }

  @override
  String get viewMonth => 'Kuu';

  @override
  String get viewWeek => 'Nädal';

  @override
  String get viewDay => 'Päev';

  @override
  String get viewList => 'Loend';

  @override
  String get noEventsToday => 'Sel päeval sündmusi pole.';

  @override
  String get noUpcomingEvents =>
      'Järgmise 60 päeva jooksul tulevaid sündmusi pole.';

  @override
  String get untitledEvent => '(nimetu)';

  @override
  String get allDay => 'Kogu päev';

  @override
  String get addAccountToSyncTooltip => 'Lisa Nostr konto sünkroonimiseks';

  @override
  String get syncNowTooltip => 'Sünkrooni kohe';

  @override
  String get addNostrAccountTitle => 'Lisa Nostr konto';

  @override
  String get eventNotFound => 'Sündmust ei leitud.';

  @override
  String get eventAppBarTitle => 'Sündmus';

  @override
  String get editTooltip => 'Muuda';

  @override
  String get deleteTooltip => 'Kustuta';

  @override
  String allDayLabel(String date) {
    return '$date · Kogu päev';
  }

  @override
  String recurrenceUntilLabel(String recurrence, String date) {
    return '$recurrence · kuni $date';
  }

  @override
  String get syncedToRelays => 'Sünkroonitud releedega';

  @override
  String get notYetSynced => 'Veel sünkroonimata';

  @override
  String get deleteEventTitle => 'Kas kustutada sündmus?';

  @override
  String get deleteEventBody =>
      'See eemaldab sündmuse sellest seadmest ja taotleb selle kustutamist releedest.';

  @override
  String get editEventTitle => 'Muuda sündmust';

  @override
  String get newEventTitle => 'Uus sündmus';

  @override
  String get fieldTitle => 'Pealkiri';

  @override
  String get allDaySwitch => 'Kogu päev';

  @override
  String get startsLabel => 'Algab';

  @override
  String get endsLabel => 'Lõpeb';

  @override
  String get timezoneLabel => 'Ajavöönd';

  @override
  String get repeatsLabel => 'Kordumine';

  @override
  String get untilLabel => 'Kuni';

  @override
  String get foreverLabel => 'Igavesti';

  @override
  String get remindersLabel => 'Meeldetuletused';

  @override
  String get addChip => 'Lisa';

  @override
  String get colorLabel => 'Värv';

  @override
  String get locationLabel => 'Asukoht';

  @override
  String get descriptionLabel => 'Kirjeldus';

  @override
  String couldNotSaveEvent(String error) {
    return 'Sündmust ei õnnestunud salvestada: $error';
  }

  @override
  String get recurrenceNone => 'Ei kordu';

  @override
  String get recurrenceDaily => 'Iga päev';

  @override
  String get recurrenceWeekly => 'Iga nädal';

  @override
  String get recurrenceMonthly => 'Iga kuu';

  @override
  String get recurrenceYearly => 'Iga aasta';

  @override
  String get reminderAtStart => 'Alguses';

  @override
  String reminderMinutesBefore(int count) {
    return '$count min enne';
  }

  @override
  String reminderHoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tundi enne',
      one: '1 tund enne',
    );
    return '$_temp0';
  }

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count päeva enne',
      one: '1 päev enne',
    );
    return '$_temp0';
  }

  @override
  String get getStarted => 'Alusta';

  @override
  String get useOffline => 'Kasuta võrguühenduseta';

  @override
  String get welcomeTitle => 'Tere tulemast Astraeasse';

  @override
  String get welcomeSubtitle =>
      'Privaatne, esmajärjekorras võrguühenduseta kalender, mis jätab kontrolli sinu kätte.';

  @override
  String get featureLocalTitle => 'Sinu kalender jääb sinu seadmesse';

  @override
  String get featureLocalBody =>
      'Loo sündmusi, kordusi ja meeldetuletusi ilma konto või internetiühenduseta.';

  @override
  String get featureSyncTitle => 'Valikuline sünkroonimine Nostri kaudu';

  @override
  String get featureSyncBody =>
      'Ühenda konto, et varundada oma kalender ja kasutada seda mitmes seadmes sinu valitud releede kaudu.';

  @override
  String get featureEncryptedTitle => 'Alati krüptitud enne üleslaadimist';

  @override
  String get featureEncryptedBody =>
      'Kalendri sisu krüptitakse otsast lõpuni enne selle seadme lahkumist. Releede operaatorid ei saa seda lugeda.';

  @override
  String get featureAmberTitle => 'Hoia oma võtit Amberis';

  @override
  String get featureAmberBody =>
      'Androidis saab väline allkirjastaja juurdepääsu heaks kiita, paljastamata su privaatvõtit Astraeale.';

  @override
  String get featureRemindersTitle => 'Privaatsed kohalikud meeldetuletused';

  @override
  String get featureRemindersBody =>
      'Teavitused planeerib su seade ja need ei sõltu pilvekalendriteenusest.';

  @override
  String get connectNostrAccountTitle => 'Ühenda Nostr konto';

  @override
  String get connectNostrAccountBody =>
      'Seda on vaja ainult krüptitud sünkroonimiseks. Astraeat saad kasutada ka täiesti võrguühenduseta.';

  @override
  String get chooseRelaysTitle => 'Vali releed sünkroonimiseks';

  @override
  String get chooseRelaysBody =>
      'Releed salvestavad su krüptitud kalendri ja teevad selle kättesaadavaks su teistes seadmetes. Lisa üks või mitu, või jäta loend tühjaks ja seadista see hiljem.';

  @override
  String couldNotLoadRelaySettings(String error) {
    return 'Releede seadeid ei õnnestunud laadida: $error';
  }

  @override
  String get suggestedRelays => 'Soovitatud';

  @override
  String get addRelayTooltip => 'Lisa relee';

  @override
  String get customRelayLabel => 'Kohandatud relee';

  @override
  String get customRelayHint => 'wss://relay.example.com';

  @override
  String get selectedRelays => 'Valitud';

  @override
  String get removeRelayTooltip => 'Eemalda relee';

  @override
  String get invalidRelayUrl =>
      'Sisesta kehtiv wss:// aadress (või ws:// privaatse relee jaoks).';

  @override
  String get insecureRelayWarning =>
      'ws:// ei ole ülekande ajal krüptitud — kasuta seda ainult usaldusväärse relee jaoks.';

  @override
  String get nostrAccountConnected => 'Nostr konto ühendatud';

  @override
  String get invalidPrivateKey =>
      'See privaatvõti ei ole kehtiv. Kontrolli seda ja proovi uuesti.';

  @override
  String couldNotSignIn(String error) {
    return 'Sisselogimine ebaõnnestus: $error';
  }

  @override
  String get signInWithAmber => 'Logi sisse Amberiga';

  @override
  String get createNewAccount => 'Loo uus konto';

  @override
  String get generatedAccountWarning =>
      'Loodud konto saab taastada ainult selle privaatvõtmega. Varunda see pärast seadistamist Seadetest.';

  @override
  String get importExistingKey => 'Impordi olemasolev võti';

  @override
  String get privateKeyFieldLabel =>
      'nsec või kuueteistkümnendsüsteemi privaatvõti';

  @override
  String get importButton => 'Impordi';

  @override
  String get followDeviceTimezone => 'Järgi seadme ajavööndit';

  @override
  String get searchCityRegion => 'Otsi linna või piirkonda';

  @override
  String get noMatchingTimezone => 'Sobivat ajavööndit ei leitud.';

  @override
  String get settingsTitle => 'Seaded';

  @override
  String couldNotLoadSettings(String error) {
    return 'Seadeid ei õnnestunud laadida:\n$error';
  }

  @override
  String get sectionAccount => 'Konto';

  @override
  String get sectionSync => 'Sünkroonimine';

  @override
  String get sectionRelays => 'Releed';

  @override
  String get sectionAppearance => 'Välimus';

  @override
  String get sectionData => 'Andmed';

  @override
  String get sectionRemindersTimezone => 'Meeldetuletused ja ajavöönd';

  @override
  String get sectionSupport => 'Tugi';

  @override
  String somethingWentWrong(String error) {
    return 'Midagi läks valesti: $error';
  }

  @override
  String get offlineNoAccount => 'Võrguühenduseta — kontot pole';

  @override
  String get signInToSyncAcrossDevices =>
      'Logi sisse, et sünkroonida oma krüptitud kalender seadmete vahel.';

  @override
  String get signIn => 'Logi sisse';

  @override
  String get signedInWithAmber => 'Sisse logitud Amberiga';

  @override
  String get signedIn => 'Sisse logitud';

  @override
  String get signOut => 'Logi välja';

  @override
  String get backUpPrivateKey => 'Varunda privaatvõti';

  @override
  String get revealNsecSubtitle =>
      'Näita oma nsec-i, et see turvaliselt salvestada';

  @override
  String get signOutTitle => 'Kas logida välja?';

  @override
  String get signOutBody =>
      'Sinu sündmused jäävad sellesse seadmesse ja releedesse. Veendu, et oled oma privaatvõtme varundanud — ilma selleta ei saa loodud kontot taastada.';

  @override
  String get noPrivateKeyStored =>
      'Selle seansi jaoks pole salvestatud privaatvõtit.';

  @override
  String get yourPrivateKeyTitle => 'Sinu privaatvõti (nsec)';

  @override
  String get nsecWarning =>
      'Igaüks, kellel on see võti, kontrollib su kontot. Ära seda kunagi jaga; hoia seda paroolihalduris.';

  @override
  String get copy => 'Kopeeri';

  @override
  String get done => 'Valmis';

  @override
  String get syncNowTitle => 'Sünkrooni kohe';

  @override
  String get signInToSyncSubtitle =>
      'Logi sisse, et sünkroonida oma krüptitud kalender.';

  @override
  String get addRelayToSyncSubtitle =>
      'Sünkroonimiseks lisa vähemalt üks relee.';

  @override
  String get syncingEllipsis => 'Sünkroonimine…';

  @override
  String get synced => 'Sünkroonitud';

  @override
  String lastSyncedLabel(String when) {
    return 'Viimati sünkroonitud $when';
  }

  @override
  String lastSyncFailedLabel(String error) {
    return 'Viimane sünkroonimine ebaõnnestus: $error';
  }

  @override
  String get pullMergePublish => 'Toob, ühendab ja avaldab sinu sündmused';

  @override
  String get publicRelays => 'Avalikud releed';

  @override
  String relaysConfiguredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seadistatud',
      one: '1 seadistatud',
    );
    return '$_temp0';
  }

  @override
  String get addRelay => 'Lisa relee';

  @override
  String get suggestedRelaysTitle => 'Soovitatud releed';

  @override
  String get addOnlyRelaysYouWant =>
      'Lisa ainult releed, mida soovid kasutada.';

  @override
  String get homeRelayBackup => 'Isiklik relee (varukoopia)';

  @override
  String get homeRelayNotConfigured =>
      'Seadistamata — täiendav isiklik relee sinu sündmuste varundamiseks';

  @override
  String get homeRelayDialogTitle => 'Isiklik relee';

  @override
  String get lightTheme => 'Hele teema';

  @override
  String get darkThemeDefault => 'Astraea kasutab vaikimisi tumedat teemat';

  @override
  String get languageLabel => 'Keel';

  @override
  String get systemLanguage => 'Süsteemi keel';

  @override
  String get exportEvents => 'Ekspordi sündmused';

  @override
  String get exportEventsSubtitle =>
      'Salvesta .ics fail — soovi korral parooliga kaitstud';

  @override
  String get importEvents => 'Impordi sündmused';

  @override
  String get importEventsSubtitle =>
      '.ics failist või krüptitud Astraea ekspordist';

  @override
  String get encryptExportTitle => 'Kas krüptida see eksport?';

  @override
  String get encryptExportBody =>
      'Tavalise .ics faili saab avada iga kalendrirakendus — ja igaüks, kes selle kätte saab. Määra parool selle krüptimiseks (ainult Astraea saab selle uuesti importida).';

  @override
  String get exportPasswordLabel =>
      'Parool (jäta tühjaks tavalise .ics faili jaoks)';

  @override
  String get export => 'Ekspordi';

  @override
  String get encryptedExportSaved => 'Krüptitud eksport salvestatud.';

  @override
  String get exportSaved => 'Eksport salvestatud.';

  @override
  String exportFailed(String error) {
    return 'Eksport ebaõnnestus: $error';
  }

  @override
  String get couldNotReadSelectedFile => 'Valitud faili ei õnnestunud lugeda.';

  @override
  String get selectedFileTooLarge => 'Valitud fail on suurem kui 10 MB.';

  @override
  String importedEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imporditi $count sündmust.',
      one: 'Imporditi 1 sündmus.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(String error) {
    return 'Import ebaõnnestus: $error';
  }

  @override
  String get thisExportIsEncrypted => 'See eksport on krüptitud';

  @override
  String get passwordLabel => 'Parool';

  @override
  String get wrongPassword => 'Vale parool.';

  @override
  String get invalidEncryptedExport => 'See krüptitud eksport ei ole kehtiv.';

  @override
  String get reminders => 'Meeldetuletused';

  @override
  String get scheduleLocalNotifications =>
      'Planeeri kohalikud teavitused sündmuste meeldetuletusteks';

  @override
  String get timezone => 'Ajavöönd';

  @override
  String followDeviceTimezoneWithName(String zone) {
    return 'Järgi seadme ajavööndit ($zone)';
  }

  @override
  String get supportAstraea => 'Toeta Astraeat';

  @override
  String noLightningWalletFound(String address) {
    return 'Lightning rahakotti ei leitud — aadress kopeeriti: $address';
  }

  @override
  String get desktopServiceUnreachableTitle =>
      'Astraea taustateenus pole saadaval';

  @override
  String get desktopServiceUnreachableBody =>
      'Töölauarakendus suhtleb astraea-service\'iga D-Bus\'i kaudu salvestamiseks, sünkroonimiseks ja teavitusteks, kuid seda ei õnnestunud saavutada. Kui käitad seda lähtekoodist, installi see käsuga:\n\n./scripts/install-dev.sh';

  @override
  String get retry => 'Proovi uuesti';

  @override
  String get calendarsLabel => 'Kalendrid';

  @override
  String calendarsUnavailable(String error) {
    return 'Kalendrid pole saadaval: $error';
  }

  @override
  String get serviceUnreachable => 'Teenus pole saavutatav';

  @override
  String syncStatusLabel(String status) {
    return 'Sünkroonimine: $status';
  }

  @override
  String syncPendingSuffix(int count) {
    return ' ($count ootel)';
  }

  @override
  String get localOnlyMode => 'Ainult kohalik režiim (Nostr identiteeti pole)';

  @override
  String get syncStarted => 'Sünkroonimine alustatud';

  @override
  String syncUnavailable(String error) {
    return 'Sünkroonimine pole saadaval: $error';
  }

  @override
  String get notSignedIn => 'Sisse logimata';

  @override
  String get signInWithBrowserSubtitle =>
      'Logi sisse oma brauseriga (NIP-07), et sünkroonida see kalender Nostri kaudu.';

  @override
  String get signedInBackgroundSigning =>
      'Sisse logitud — taustal allkirjastamine delegeeritud võtmega';

  @override
  String get signedInRemoteSigner =>
      'Sisse logitud — kaugallkirjastaja (NIP-46)';

  @override
  String get signedInNoBackgroundSigner =>
      'Sisse logitud, kuid taustal töötavat allkirjastajat pole seadistatud — sünkroonimine jääb pausile. Käivita terminalis \"astraea-service auth provision-key\".';

  @override
  String couldNotStartLogin(String error) {
    return 'Sisselogimist ei õnnestunud alustada: $error';
  }

  @override
  String get signOutConfirmDesktopBody =>
      'See unustab konto ainult selles seadmes — sinu sündmused jäävad releedesse. Võimalik pakutud allkirjastamisvõti eemaldatakse võtmehoidjast.';

  @override
  String get signInWithBrowserTitle => 'Logi sisse oma brauseriga';

  @override
  String get loginSessionExpired =>
      'See sisselogimisseanss on aegunud. Proovi uuesti.';

  @override
  String get loginWaitingBody =>
      'Avati brauserisakk sinu Nostr identiteedi kinnitamiseks (NIP-07). Kinnita see seal — see dialoog sulgub automaatselt. Sinu privaatvõtit ei küsita kunagi.';

  @override
  String get openAgain => 'Ava uuesti';

  @override
  String get offlineWillRetry =>
      'Võrguühenduseta — proovib automaatselt uuesti.';

  @override
  String get upToDate => 'Ajakohane';

  @override
  String operationsFailingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ebaõnnestunud toimingut',
      one: '1 ebaõnnestunud toiming',
    );
    return '$_temp0';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ootel',
      one: '1 ootel',
    );
    return '$_temp0';
  }

  @override
  String pendingFailingCount(String pending, String failing) {
    return '$pending, $failing';
  }

  @override
  String get relayStatus => 'Releede olek';

  @override
  String get relaysLabel => 'Releed';

  @override
  String relaysConfiguredLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seadistatud',
      one: '1 seadistatud',
    );
    return '$_temp0';
  }

  @override
  String get unencryptedTransport => 'Krüptimata edastus';

  @override
  String couldNotReachService(String error) {
    return 'astraea-service\'iga ei õnnestunud ühendust luua: $error';
  }
}
