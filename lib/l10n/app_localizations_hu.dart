// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get appTitle => 'Astraea';

  @override
  String get cancel => 'Mégse';

  @override
  String get save => 'Mentés';

  @override
  String get delete => 'Törlés';

  @override
  String get continueLabel => 'Tovább';

  @override
  String get next => 'Következő';

  @override
  String get back => 'Vissza';

  @override
  String get loading => 'Betöltés…';

  @override
  String get settingsTooltip => 'Beállítások';

  @override
  String get newEventButton => 'Új esemény';

  @override
  String couldNotLoadEvents(String error) {
    return 'Az események betöltése sikertelen:\n$error';
  }

  @override
  String get viewMonth => 'Hónap';

  @override
  String get viewWeek => 'Hét';

  @override
  String get viewDay => 'Nap';

  @override
  String get viewList => 'Lista';

  @override
  String get noEventsToday => 'Ezen a napon nincs esemény.';

  @override
  String get noUpcomingEvents => 'A következő 60 napban nincs esemény.';

  @override
  String get untitledEvent => '(névtelen)';

  @override
  String get allDay => 'Egész nap';

  @override
  String get addAccountToSyncTooltip =>
      'Nostr-fiók hozzáadása a szinkronizáláshoz';

  @override
  String get syncNowTooltip => 'Szinkronizálás most';

  @override
  String get addNostrAccountTitle => 'Nostr-fiók hozzáadása';

  @override
  String get eventNotFound => 'Az esemény nem található.';

  @override
  String get eventAppBarTitle => 'Esemény';

  @override
  String get editTooltip => 'Szerkesztés';

  @override
  String get deleteTooltip => 'Törlés';

  @override
  String allDayLabel(String date) {
    return '$date · Egész nap';
  }

  @override
  String recurrenceUntilLabel(String recurrence, String date) {
    return '$recurrence · eddig: $date';
  }

  @override
  String get syncedToRelays => 'Szinkronizálva a relékkel';

  @override
  String get notYetSynced => 'Még nincs szinkronizálva';

  @override
  String get deleteEventTitle => 'Törlöd az eseményt?';

  @override
  String get deleteEventBody =>
      'Ez eltávolítja az eseményt erről az eszközről, és törlést kér a relékről.';

  @override
  String get editEventTitle => 'Esemény szerkesztése';

  @override
  String get newEventTitle => 'Új esemény';

  @override
  String get fieldTitle => 'Cím';

  @override
  String get allDaySwitch => 'Egész nap';

  @override
  String get startsLabel => 'Kezdés';

  @override
  String get endsLabel => 'Befejezés';

  @override
  String get timezoneLabel => 'Időzóna';

  @override
  String get repeatsLabel => 'Ismétlődés';

  @override
  String get untilLabel => 'Eddig';

  @override
  String get foreverLabel => 'Örökre';

  @override
  String get remindersLabel => 'Emlékeztetők';

  @override
  String get addChip => 'Hozzáadás';

  @override
  String get colorLabel => 'Szín';

  @override
  String get locationLabel => 'Helyszín';

  @override
  String get descriptionLabel => 'Leírás';

  @override
  String couldNotSaveEvent(String error) {
    return 'Az esemény mentése sikertelen: $error';
  }

  @override
  String get recurrenceNone => 'Nem ismétlődik';

  @override
  String get recurrenceDaily => 'Naponta';

  @override
  String get recurrenceWeekly => 'Hetente';

  @override
  String get recurrenceMonthly => 'Havonta';

  @override
  String get recurrenceYearly => 'Évente';

  @override
  String get reminderAtStart => 'A kezdéskor';

  @override
  String reminderMinutesBefore(int count) {
    return '$count perccel korábban';
  }

  @override
  String reminderHoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count órával korábban',
      one: '1 órával korábban',
    );
    return '$_temp0';
  }

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nappal korábban',
      one: '1 nappal korábban',
    );
    return '$_temp0';
  }

  @override
  String get getStarted => 'Kezdjük';

  @override
  String get useOffline => 'Offline használat';

  @override
  String get welcomeTitle => 'Üdvözlünk az Astraea-ban';

  @override
  String get welcomeSubtitle =>
      'Egy privát, offline-first naptár, amely nálad hagyja az irányítást.';

  @override
  String get featureLocalTitle => 'A naptárad az eszközödön marad';

  @override
  String get featureLocalBody =>
      'Hozz létre eseményeket, ismétlődéseket és emlékeztetőket fiók vagy internetkapcsolat nélkül.';

  @override
  String get featureSyncTitle => 'Opcionális szinkronizálás Nostron keresztül';

  @override
  String get featureSyncBody =>
      'Kapcsolj össze egy fiókot, hogy biztonsági másolatot készíts a naptáradról, és több eszközön is használhasd az általad választott réléken keresztül.';

  @override
  String get featureEncryptedTitle => 'Mindig titkosítva a feltöltés előtt';

  @override
  String get featureEncryptedBody =>
      'A naptár tartalma végpontok közötti titkosítást kap, mielőtt elhagyja ezt az eszközt. A rélé üzemeltetői nem tudják elolvasni.';

  @override
  String get featureAmberTitle => 'Tartsd a kulcsodat az Amberben';

  @override
  String get featureAmberBody =>
      'Androidon egy külső aláíró jóváhagyhatja a hozzáférést anélkül, hogy felfedné a privát kulcsodat az Astraea felé.';

  @override
  String get featureRemindersTitle => 'Privát, helyi emlékeztetők';

  @override
  String get featureRemindersBody =>
      'Az értesítéseket az eszközöd ütemezi, és nem függenek felhőalapú naptárszolgáltatástól.';

  @override
  String get connectNostrAccountTitle => 'Nostr-fiók összekapcsolása';

  @override
  String get connectNostrAccountBody =>
      'Ez csak a titkosított szinkronizáláshoz szükséges. Az Astraea-t teljesen offline is használhatod.';

  @override
  String get chooseRelaysTitle => 'Válassz réléket a szinkronizáláshoz';

  @override
  String get chooseRelaysBody =>
      'A rélék tárolják a titkosított naptáradat, és elérhetővé teszik a többi eszközödön. Adj hozzá egyet vagy többet, vagy hagyd üresen a listát, és állítsd be később.';

  @override
  String couldNotLoadRelaySettings(String error) {
    return 'A rélébeállítások betöltése sikertelen: $error';
  }

  @override
  String get suggestedRelays => 'Javasolt';

  @override
  String get addRelayTooltip => 'Rélé hozzáadása';

  @override
  String get customRelayLabel => 'Egyéni rélé';

  @override
  String get customRelayHint => 'wss://relay.example.com';

  @override
  String get selectedRelays => 'Kiválasztott';

  @override
  String get removeRelayTooltip => 'Rélé eltávolítása';

  @override
  String get invalidRelayUrl =>
      'Adj meg egy érvényes wss:// URL-t (vagy ws://-t privát réléhez).';

  @override
  String get insecureRelayWarning =>
      'A ws:// nincs titkosítva átvitel közben — csak megbízható réléhez használd.';

  @override
  String get nostrAccountConnected => 'Nostr-fiók összekapcsolva';

  @override
  String get invalidPrivateKey =>
      'Ez a privát kulcs nem érvényes. Ellenőrizd, és próbáld újra.';

  @override
  String couldNotSignIn(String error) {
    return 'A bejelentkezés sikertelen: $error';
  }

  @override
  String get signInWithAmber => 'Bejelentkezés Amberrel';

  @override
  String get createNewAccount => 'Új fiók létrehozása';

  @override
  String get generatedAccountWarning =>
      'Egy generált fiók csak a privát kulcsával állítható helyre. Készíts róla biztonsági másolatot a Beállításokban a beállítás után.';

  @override
  String get importExistingKey => 'Meglévő kulcs importálása';

  @override
  String get privateKeyFieldLabel => 'nsec vagy hexadecimális privát kulcs';

  @override
  String get importButton => 'Importálás';

  @override
  String get followDeviceTimezone => 'Eszköz időzónájának követése';

  @override
  String get searchCityRegion => 'Város vagy régió keresése';

  @override
  String get noMatchingTimezone => 'Nincs egyező időzóna.';

  @override
  String get settingsTitle => 'Beállítások';

  @override
  String couldNotLoadSettings(String error) {
    return 'A beállítások betöltése sikertelen:\n$error';
  }

  @override
  String get sectionAccount => 'Fiók';

  @override
  String get sectionSync => 'Szinkronizálás';

  @override
  String get sectionRelays => 'Rélék';

  @override
  String get sectionAppearance => 'Megjelenés';

  @override
  String get sectionData => 'Adatok';

  @override
  String get sectionRemindersTimezone => 'Emlékeztetők és időzóna';

  @override
  String get sectionSupport => 'Támogatás';

  @override
  String somethingWentWrong(String error) {
    return 'Valami hiba történt: $error';
  }

  @override
  String get offlineNoAccount => 'Offline — nincs fiók';

  @override
  String get signInToSyncAcrossDevices =>
      'Jelentkezz be a titkosított naptárad eszközök közötti szinkronizálásához.';

  @override
  String get signIn => 'Bejelentkezés';

  @override
  String get signedInWithAmber => 'Bejelentkezve Amberrel';

  @override
  String get signedIn => 'Bejelentkezve';

  @override
  String get signOut => 'Kijelentkezés';

  @override
  String get backUpPrivateKey => 'Privát kulcs biztonsági mentése';

  @override
  String get revealNsecSubtitle =>
      'Mutasd meg az nsec-et, hogy biztonságos helyen tárold';

  @override
  String get signOutTitle => 'Kijelentkezel?';

  @override
  String get signOutBody =>
      'Az eseményeid megmaradnak ezen az eszközön és a réléken. Győződj meg róla, hogy biztonsági mentést készítettél a privát kulcsodról — enélkül egy generált fiók nem állítható helyre.';

  @override
  String get noPrivateKeyStored =>
      'Ehhez a munkamenethez nincs tárolt privát kulcs.';

  @override
  String get yourPrivateKeyTitle => 'A privát kulcsod (nsec)';

  @override
  String get nsecWarning =>
      'Aki rendelkezik ezzel a kulccsal, az irányítja a fiókodat. Soha ne oszd meg; tárold jelszókezelőben.';

  @override
  String get copy => 'Másolás';

  @override
  String get done => 'Kész';

  @override
  String get syncNowTitle => 'Szinkronizálás most';

  @override
  String get signInToSyncSubtitle =>
      'Jelentkezz be a titkosított naptárad szinkronizálásához.';

  @override
  String get addRelayToSyncSubtitle =>
      'Adj hozzá legalább egy rélét a szinkronizáláshoz.';

  @override
  String get syncingEllipsis => 'Szinkronizálás…';

  @override
  String get synced => 'Szinkronizálva';

  @override
  String lastSyncedLabel(String when) {
    return 'Utolsó szinkronizálás: $when';
  }

  @override
  String lastSyncFailedLabel(String error) {
    return 'Az utolsó szinkronizálás sikertelen: $error';
  }

  @override
  String get pullMergePublish =>
      'Lekéri, egyesíti és közzéteszi az eseményeidet';

  @override
  String get publicRelays => 'Nyilvános rélék';

  @override
  String relaysConfiguredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count beállítva',
      one: '1 beállítva',
    );
    return '$_temp0';
  }

  @override
  String get addRelay => 'Rélé hozzáadása';

  @override
  String get suggestedRelaysTitle => 'Javasolt rélék';

  @override
  String get addOnlyRelaysYouWant =>
      'Csak azokat a réléket add hozzá, amelyeket használni szeretnél.';

  @override
  String get homeRelayBackup => 'Személyes rélé (biztonsági mentés)';

  @override
  String get homeRelayNotConfigured =>
      'Nincs beállítva — egy további személyes rélé az eseményeid biztonsági mentéséhez';

  @override
  String get homeRelayDialogTitle => 'Személyes rélé';

  @override
  String get lightTheme => 'Világos téma';

  @override
  String get darkThemeDefault =>
      'Az Astraea alapértelmezetten a sötét témát használja';

  @override
  String get languageLabel => 'Nyelv';

  @override
  String get systemLanguage => 'Rendszernyelv';

  @override
  String get exportEvents => 'Események exportálása';

  @override
  String get exportEventsSubtitle =>
      '.ics fájl mentése — opcionálisan jelszóval védve';

  @override
  String get importEvents => 'Események importálása';

  @override
  String get importEventsSubtitle =>
      '.ics fájlból vagy titkosított Astraea exportból';

  @override
  String get encryptExportTitle => 'Titkosítsuk ezt az exportot?';

  @override
  String get encryptExportBody =>
      'Egy egyszerű .ics fájlt bármely naptáralkalmazás megnyithat — és bárki, aki hozzájut. Állíts be egy jelszót a titkosításhoz (csak az Astraea tudja majd újra importálni).';

  @override
  String get exportPasswordLabel =>
      'Jelszó (hagyd üresen egyszerű .ics fájlhoz)';

  @override
  String get export => 'Exportálás';

  @override
  String get encryptedExportSaved => 'Titkosított export mentve.';

  @override
  String get exportSaved => 'Export mentve.';

  @override
  String exportFailed(String error) {
    return 'Az exportálás sikertelen: $error';
  }

  @override
  String get couldNotReadSelectedFile =>
      'A kiválasztott fájl olvasása sikertelen.';

  @override
  String get selectedFileTooLarge =>
      'A kiválasztott fájl mérete meghaladja a 10 MB-ot.';

  @override
  String importedEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count esemény importálva.',
      one: '1 esemény importálva.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(String error) {
    return 'Az importálás sikertelen: $error';
  }

  @override
  String get thisExportIsEncrypted => 'Ez az export titkosított';

  @override
  String get passwordLabel => 'Jelszó';

  @override
  String get wrongPassword => 'Hibás jelszó.';

  @override
  String get invalidEncryptedExport => 'Ez a titkosított export érvénytelen.';

  @override
  String get reminders => 'Emlékeztetők';

  @override
  String get scheduleLocalNotifications =>
      'Helyi értesítések ütemezése az eseményemlékeztetőkhöz';

  @override
  String get timezone => 'Időzóna';

  @override
  String followDeviceTimezoneWithName(String zone) {
    return 'Eszköz időzónájának követése ($zone)';
  }

  @override
  String get supportAstraea => 'Támogasd az Astraea-t';

  @override
  String noLightningWalletFound(String address) {
    return 'Nem található Lightning tárca — a cím vágólapra másolva: $address';
  }

  @override
  String get desktopServiceUnreachableTitle =>
      'Az Astraea háttérszolgáltatása nem érhető el';

  @override
  String get desktopServiceUnreachableBody =>
      'Az asztali alkalmazás D-Bus-on keresztül kommunikál az astraea-service szolgáltatással a tárolás, a szinkronizálás és az értesítések érdekében, de nem sikerült elérni. Ha forráskódból futtatod, telepítsd ezzel:\n\n./scripts/install-dev.sh';

  @override
  String get retry => 'Újra';

  @override
  String get calendarsLabel => 'Naptárak';

  @override
  String calendarsUnavailable(String error) {
    return 'A naptárak nem érhetők el: $error';
  }

  @override
  String get serviceUnreachable => 'A szolgáltatás nem érhető el';

  @override
  String syncStatusLabel(String status) {
    return 'Szinkronizálás: $status';
  }

  @override
  String syncPendingSuffix(int count) {
    return ' ($count függőben)';
  }

  @override
  String get localOnlyMode => 'Csak helyi mód (nincs Nostr-azonosság)';

  @override
  String get syncStarted => 'Szinkronizálás elindítva';

  @override
  String syncUnavailable(String error) {
    return 'A szinkronizálás nem érhető el: $error';
  }

  @override
  String get notSignedIn => 'Nincs bejelentkezve';

  @override
  String get signInWithBrowserSubtitle =>
      'Jelentkezz be a böngésződdel (NIP-07) e naptár Nostron keresztüli szinkronizálásához.';

  @override
  String get signedInBackgroundSigning =>
      'Bejelentkezve — háttérbeli aláírás egy delegált kulccsal';

  @override
  String get signedInRemoteSigner => 'Bejelentkezve — távoli aláíró (NIP-46)';

  @override
  String get signedInNoBackgroundSigner =>
      'Bejelentkezve, de nincs beállítva háttérbeli aláíró — a szinkronizálás szüneteltetve marad. Futtasd az „astraea-service auth provision-key” parancsot egy terminálban.';

  @override
  String couldNotStartLogin(String error) {
    return 'A bejelentkezés indítása sikertelen: $error';
  }

  @override
  String get signOutConfirmDesktopBody =>
      'Ez csak ezen az eszközön felejti el a fiókot — az eseményeid megmaradnak a réléken. Az esetleges kiadott aláíró kulcsot eltávolítjuk a kulcstartóból.';

  @override
  String get signInWithBrowserTitle => 'Jelentkezz be a böngésződdel';

  @override
  String get loginSessionExpired =>
      'Ez a bejelentkezési munkamenet lejárt. Próbáld újra.';

  @override
  String get loginWaitingBody =>
      'Egy böngészőfül nyílt meg a Nostr-azonosságod megerősítéséhez (NIP-07). Hagyd jóvá ott — ez az ablak automatikusan bezáródik. A privát kulcsodat soha nem kérjük.';

  @override
  String get openAgain => 'Megnyitás újra';

  @override
  String get offlineWillRetry => 'Offline — automatikusan újrapróbálja.';

  @override
  String get upToDate => 'Naprakész';

  @override
  String operationsFailingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sikertelen művelet',
      one: '1 sikertelen művelet',
    );
    return '$_temp0';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count függőben',
      one: '1 függőben',
    );
    return '$_temp0';
  }

  @override
  String pendingFailingCount(String pending, String failing) {
    return '$pending, $failing';
  }

  @override
  String get relayStatus => 'Rélé állapota';

  @override
  String get relaysLabel => 'Rélék';

  @override
  String relaysConfiguredLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count beállítva',
      one: '1 beállítva',
    );
    return '$_temp0';
  }

  @override
  String get unencryptedTransport => 'Titkosítatlan átvitel';

  @override
  String couldNotReachService(String error) {
    return 'Az astraea-service nem érhető el: $error';
  }
}
