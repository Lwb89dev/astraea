// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get appTitle => 'Astraea';

  @override
  String get cancel => 'Peruuta';

  @override
  String get save => 'Tallenna';

  @override
  String get delete => 'Poista';

  @override
  String get continueLabel => 'Jatka';

  @override
  String get next => 'Seuraava';

  @override
  String get back => 'Takaisin';

  @override
  String get loading => 'Ladataan…';

  @override
  String get settingsTooltip => 'Asetukset';

  @override
  String get newEventButton => 'Uusi tapahtuma';

  @override
  String couldNotLoadEvents(String error) {
    return 'Tapahtumia ei voitu ladata:\n$error';
  }

  @override
  String get viewMonth => 'Kuukausi';

  @override
  String get viewWeek => 'Viikko';

  @override
  String get viewDay => 'Päivä';

  @override
  String get viewList => 'Luettelo';

  @override
  String get noEventsToday => 'Ei tapahtumia tänä päivänä.';

  @override
  String get noUpcomingEvents =>
      'Ei tulevia tapahtumia seuraavan 60 päivän aikana.';

  @override
  String get untitledEvent => '(nimetön)';

  @override
  String get allDay => 'Koko päivä';

  @override
  String get addAccountToSyncTooltip => 'Lisää Nostr-tili synkronointia varten';

  @override
  String get syncNowTooltip => 'Synkronoi nyt';

  @override
  String get addNostrAccountTitle => 'Lisää Nostr-tili';

  @override
  String get eventNotFound => 'Tapahtumaa ei löytynyt.';

  @override
  String get eventAppBarTitle => 'Tapahtuma';

  @override
  String get editTooltip => 'Muokkaa';

  @override
  String get deleteTooltip => 'Poista';

  @override
  String allDayLabel(String date) {
    return '$date · Koko päivä';
  }

  @override
  String recurrenceUntilLabel(String recurrence, String date) {
    return '$recurrence · $date asti';
  }

  @override
  String get syncedToRelays => 'Synkronoitu releille';

  @override
  String get notYetSynced => 'Ei vielä synkronoitu';

  @override
  String get deleteEventTitle => 'Poistetaanko tapahtuma?';

  @override
  String get deleteEventBody =>
      'Tämä poistaa tapahtuman tästä laitteesta ja pyytää poistoa releiltä.';

  @override
  String get editEventTitle => 'Muokkaa tapahtumaa';

  @override
  String get newEventTitle => 'Uusi tapahtuma';

  @override
  String get fieldTitle => 'Otsikko';

  @override
  String get allDaySwitch => 'Koko päivä';

  @override
  String get startsLabel => 'Alkaa';

  @override
  String get endsLabel => 'Päättyy';

  @override
  String get timezoneLabel => 'Aikavyöhyke';

  @override
  String get repeatsLabel => 'Toistuu';

  @override
  String get untilLabel => 'Asti';

  @override
  String get foreverLabel => 'Ikuisesti';

  @override
  String get remindersLabel => 'Muistutukset';

  @override
  String get addChip => 'Lisää';

  @override
  String get colorLabel => 'Väri';

  @override
  String get locationLabel => 'Sijainti';

  @override
  String get descriptionLabel => 'Kuvaus';

  @override
  String couldNotSaveEvent(String error) {
    return 'Tapahtumaa ei voitu tallentaa: $error';
  }

  @override
  String get recurrenceNone => 'Ei toistu';

  @override
  String get recurrenceDaily => 'Päivittäin';

  @override
  String get recurrenceWeekly => 'Viikoittain';

  @override
  String get recurrenceMonthly => 'Kuukausittain';

  @override
  String get recurrenceYearly => 'Vuosittain';

  @override
  String get reminderAtStart => 'Alussa';

  @override
  String reminderMinutesBefore(int count) {
    return '$count min ennen';
  }

  @override
  String reminderHoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tuntia ennen',
      one: '1 tunti ennen',
    );
    return '$_temp0';
  }

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count päivää ennen',
      one: '1 päivä ennen',
    );
    return '$_temp0';
  }

  @override
  String get getStarted => 'Aloita';

  @override
  String get useOffline => 'Käytä offline-tilassa';

  @override
  String get welcomeTitle => 'Tervetuloa Astraeaan';

  @override
  String get welcomeSubtitle =>
      'Yksityinen, offline-ensin-kalenteri, joka jättää hallinnan sinulle.';

  @override
  String get featureLocalTitle => 'Kalenterisi pysyy laitteellasi';

  @override
  String get featureLocalBody =>
      'Luo tapahtumia, toistoja ja muistutuksia ilman tiliä tai internet-yhteyttä.';

  @override
  String get featureSyncTitle => 'Valinnainen synkronointi Nostrin kautta';

  @override
  String get featureSyncBody =>
      'Yhdistä tili varmuuskopioidaksesi kalenterisi ja käyttääksesi sitä useilla laitteilla valitsemiesi releiden kautta.';

  @override
  String get featureEncryptedTitle => 'Aina salattu ennen lähetystä';

  @override
  String get featureEncryptedBody =>
      'Kalenterin sisältö salataan päästä päähän ennen kuin se poistuu tästä laitteesta. Releiden ylläpitäjät eivät voi lukea sitä.';

  @override
  String get featureAmberTitle => 'Säilytä avaimesi Amberissa';

  @override
  String get featureAmberBody =>
      'Androidissa ulkoinen allekirjoittaja voi hyväksyä pääsyn paljastamatta yksityistä avaintasi Astraealle.';

  @override
  String get featureRemindersTitle => 'Yksityiset paikalliset muistutukset';

  @override
  String get featureRemindersBody =>
      'Ilmoitukset ajastaa laitteesi, eivätkä ne riipu pilvikalenteripalvelusta.';

  @override
  String get connectNostrAccountTitle => 'Yhdistä Nostr-tili';

  @override
  String get connectNostrAccountBody =>
      'Tätä tarvitaan vain salattua synkronointia varten. Voit myös käyttää Astraeaa täysin offline-tilassa.';

  @override
  String get chooseRelaysTitle => 'Valitse releet synkronointia varten';

  @override
  String get chooseRelaysBody =>
      'Releet tallentavat salatun kalenterisi ja tekevät sen saataville muilla laitteillasi. Lisää yksi tai useampi, tai jätä lista tyhjäksi ja määritä se myöhemmin.';

  @override
  String couldNotLoadRelaySettings(String error) {
    return 'Releasetuksia ei voitu ladata: $error';
  }

  @override
  String get suggestedRelays => 'Ehdotetut';

  @override
  String get addRelayTooltip => 'Lisää rele';

  @override
  String get customRelayLabel => 'Mukautettu rele';

  @override
  String get customRelayHint => 'wss://relay.example.com';

  @override
  String get selectedRelays => 'Valitut';

  @override
  String get removeRelayTooltip => 'Poista rele';

  @override
  String get invalidRelayUrl =>
      'Anna kelvollinen wss://-osoite (tai ws:// yksityiselle releelle).';

  @override
  String get insecureRelayWarning =>
      'ws:// ei ole salattu siirron aikana — käytä sitä vain releelle, johon luotat.';

  @override
  String get nostrAccountConnected => 'Nostr-tili yhdistetty';

  @override
  String get invalidPrivateKey =>
      'Tuo yksityinen avain ei ole kelvollinen. Tarkista se ja yritä uudelleen.';

  @override
  String couldNotSignIn(String error) {
    return 'Kirjautuminen epäonnistui: $error';
  }

  @override
  String get signInWithAmber => 'Kirjaudu Amberilla';

  @override
  String get createNewAccount => 'Luo uusi tili';

  @override
  String get generatedAccountWarning =>
      'Luodun tilin voi palauttaa vain sen yksityisellä avaimella. Varmuuskopioi se Asetuksista määrityksen jälkeen.';

  @override
  String get importExistingKey => 'Tuo olemassa oleva avain';

  @override
  String get privateKeyFieldLabel =>
      'nsec tai heksadesimaalinen yksityinen avain';

  @override
  String get importButton => 'Tuo';

  @override
  String get followDeviceTimezone => 'Seuraa laitteen aikavyöhykettä';

  @override
  String get searchCityRegion => 'Hae kaupunkia tai aluetta';

  @override
  String get noMatchingTimezone => 'Ei vastaavaa aikavyöhykettä.';

  @override
  String get settingsTitle => 'Asetukset';

  @override
  String couldNotLoadSettings(String error) {
    return 'Asetuksia ei voitu ladata:\n$error';
  }

  @override
  String get sectionAccount => 'Tili';

  @override
  String get sectionSync => 'Synkronointi';

  @override
  String get sectionRelays => 'Releet';

  @override
  String get sectionAppearance => 'Ulkoasu';

  @override
  String get sectionData => 'Tiedot';

  @override
  String get sectionRemindersTimezone => 'Muistutukset ja aikavyöhyke';

  @override
  String get sectionSupport => 'Tuki';

  @override
  String somethingWentWrong(String error) {
    return 'Jotain meni pieleen: $error';
  }

  @override
  String get offlineNoAccount => 'Offline — ei tiliä';

  @override
  String get signInToSyncAcrossDevices =>
      'Kirjaudu sisään synkronoidaksesi salatun kalenterisi laitteiden välillä.';

  @override
  String get signIn => 'Kirjaudu sisään';

  @override
  String get signedInWithAmber => 'Kirjautunut Amberilla';

  @override
  String get signedIn => 'Kirjautunut sisään';

  @override
  String get signOut => 'Kirjaudu ulos';

  @override
  String get backUpPrivateKey => 'Varmuuskopioi yksityinen avain';

  @override
  String get revealNsecSubtitle =>
      'Näytä nsec-avaimesi tallentaaksesi sen turvalliseen paikkaan';

  @override
  String get signOutTitle => 'Kirjaudutaanko ulos?';

  @override
  String get signOutBody =>
      'Tapahtumasi pysyvät tässä laitteessa ja releillä. Varmista, että olet varmuuskopioinut yksityisen avaimesi — ilman sitä luotua tiliä ei voi palauttaa.';

  @override
  String get noPrivateKeyStored =>
      'Tälle istunnolle ei ole tallennettu yksityistä avainta.';

  @override
  String get yourPrivateKeyTitle => 'Yksityinen avaimesi (nsec)';

  @override
  String get nsecWarning =>
      'Kuka tahansa, jolla on tämä avain, hallitsee tiliäsi. Älä koskaan jaa sitä; säilytä se salasananhallinnassa.';

  @override
  String get copy => 'Kopioi';

  @override
  String get done => 'Valmis';

  @override
  String get syncNowTitle => 'Synkronoi nyt';

  @override
  String get signInToSyncSubtitle =>
      'Kirjaudu sisään synkronoidaksesi salatun kalenterisi.';

  @override
  String get addRelayToSyncSubtitle =>
      'Lisää vähintään yksi rele synkronoidaksesi.';

  @override
  String get syncingEllipsis => 'Synkronoidaan…';

  @override
  String get synced => 'Synkronoitu';

  @override
  String lastSyncedLabel(String when) {
    return 'Viimeksi synkronoitu $when';
  }

  @override
  String lastSyncFailedLabel(String error) {
    return 'Viimeisin synkronointi epäonnistui: $error';
  }

  @override
  String get pullMergePublish => 'Hakee, yhdistää ja julkaisee tapahtumasi';

  @override
  String get publicRelays => 'Julkiset releet';

  @override
  String relaysConfiguredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count määritetty',
      one: '1 määritetty',
    );
    return '$_temp0';
  }

  @override
  String get addRelay => 'Lisää rele';

  @override
  String get suggestedRelaysTitle => 'Ehdotetut releet';

  @override
  String get addOnlyRelaysYouWant =>
      'Lisää vain ne releet, joita haluat käyttää.';

  @override
  String get homeRelayBackup => 'Henkilökohtainen rele (varmuuskopio)';

  @override
  String get homeRelayNotConfigured =>
      'Ei määritetty — ylimääräinen henkilökohtainen rele tapahtumiesi varmuuskopiointiin';

  @override
  String get homeRelayDialogTitle => 'Henkilökohtainen rele';

  @override
  String get lightTheme => 'Vaalea teema';

  @override
  String get darkThemeDefault => 'Astraea käyttää oletuksena tummaa teemaa';

  @override
  String get languageLabel => 'Kieli';

  @override
  String get systemLanguage => 'Järjestelmän kieli';

  @override
  String get exportEvents => 'Vie tapahtumat';

  @override
  String get exportEventsSubtitle =>
      'Tallenna .ics-tiedosto — valinnaisesti salasanalla suojattuna';

  @override
  String get importEvents => 'Tuo tapahtumia';

  @override
  String get importEventsSubtitle =>
      '.ics-tiedostosta tai salatusta Astraea-viennistä';

  @override
  String get encryptExportTitle => 'Salataanko tämä vienti?';

  @override
  String get encryptExportBody =>
      'Tavallisen .ics-tiedoston voi avata mikä tahansa kalenterisovellus — ja kuka tahansa, joka saa tiedoston. Aseta salasana salataksesi sen (vain Astraea voi tuoda sen takaisin).';

  @override
  String get exportPasswordLabel =>
      'Salasana (jätä tyhjäksi tavallista .ics-tiedostoa varten)';

  @override
  String get export => 'Vie';

  @override
  String get encryptedExportSaved => 'Salattu vienti tallennettu.';

  @override
  String get exportSaved => 'Vienti tallennettu.';

  @override
  String exportFailed(String error) {
    return 'Vienti epäonnistui: $error';
  }

  @override
  String get couldNotReadSelectedFile => 'Valittua tiedostoa ei voitu lukea.';

  @override
  String get selectedFileTooLarge => 'Valittu tiedosto on yli 10 Mt.';

  @override
  String importedEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tapahtumaa tuotu.',
      one: '1 tapahtuma tuotu.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(String error) {
    return 'Tuonti epäonnistui: $error';
  }

  @override
  String get thisExportIsEncrypted => 'Tämä vienti on salattu';

  @override
  String get passwordLabel => 'Salasana';

  @override
  String get wrongPassword => 'Väärä salasana.';

  @override
  String get invalidEncryptedExport =>
      'Tämä salattu vienti ei ole kelvollinen.';

  @override
  String get reminders => 'Muistutukset';

  @override
  String get scheduleLocalNotifications =>
      'Ajasta paikallisia ilmoituksia tapahtumamuistutuksille';

  @override
  String get timezone => 'Aikavyöhyke';

  @override
  String followDeviceTimezoneWithName(String zone) {
    return 'Seuraa laitteen aikavyöhykettä ($zone)';
  }

  @override
  String get supportAstraea => 'Tue Astraeaa';

  @override
  String noLightningWalletFound(String address) {
    return 'Lightning-lompakkoa ei löytynyt — osoite kopioitu: $address';
  }

  @override
  String get desktopServiceUnreachableTitle =>
      'Astraean taustapalvelu ei ole käytettävissä';

  @override
  String get desktopServiceUnreachableBody =>
      'Työpöytäsovellus kommunikoi astraea-servicen kanssa D-Busin kautta tallennusta, synkronointia ja ilmoituksia varten, eikä siihen saatu yhteyttä. Jos ajat sitä lähdekoodista, asenna se komennolla:\n\n./scripts/install-dev.sh';

  @override
  String get retry => 'Yritä uudelleen';

  @override
  String get calendarsLabel => 'Kalenterit';

  @override
  String calendarsUnavailable(String error) {
    return 'Kalenterit eivät ole käytettävissä: $error';
  }

  @override
  String get serviceUnreachable => 'Palveluun ei saada yhteyttä';

  @override
  String syncStatusLabel(String status) {
    return 'Synkronointi: $status';
  }

  @override
  String syncPendingSuffix(int count) {
    return ' ($count odottaa)';
  }

  @override
  String get localOnlyMode => 'Vain paikallinen tila (ei Nostr-identiteettiä)';

  @override
  String get syncStarted => 'Synkronointi aloitettu';

  @override
  String syncUnavailable(String error) {
    return 'Synkronointi ei ole käytettävissä: $error';
  }

  @override
  String get notSignedIn => 'Ei kirjautunut sisään';

  @override
  String get signInWithBrowserSubtitle =>
      'Kirjaudu sisään selaimellasi (NIP-07) synkronoidaksesi tämän kalenterin Nostrin kautta.';

  @override
  String get signedInBackgroundSigning =>
      'Kirjautunut sisään — taustalla tapahtuva allekirjoitus delegoidulla avaimella';

  @override
  String get signedInRemoteSigner =>
      'Kirjautunut sisään — etäallekirjoittaja (NIP-46)';

  @override
  String get signedInNoBackgroundSigner =>
      'Kirjautunut sisään, mutta taustalla toimivaa allekirjoittajaa ei ole määritetty — synkronointi pysyy pysäytettynä. Suorita \"astraea-service auth provision-key\" päätteessä.';

  @override
  String couldNotStartLogin(String error) {
    return 'Kirjautumista ei voitu aloittaa: $error';
  }

  @override
  String get signOutConfirmDesktopBody =>
      'Tämä unohtaa tilin vain tällä laitteella — tapahtumasi pysyvät releillä. Mahdollinen käyttöönotettu allekirjoitusavain poistetaan avaimenperästä.';

  @override
  String get signInWithBrowserTitle => 'Kirjaudu sisään selaimellasi';

  @override
  String get loginSessionExpired =>
      'Tämä kirjautumisistunto on vanhentunut. Yritä uudelleen.';

  @override
  String get loginWaitingBody =>
      'Selainvälilehti avattiin vahvistamaan Nostr-identiteettisi (NIP-07). Hyväksy se siellä — tämä ikkuna sulkeutuu automaattisesti. Yksityistä avaintasi ei koskaan pyydetä.';

  @override
  String get openAgain => 'Avaa uudelleen';

  @override
  String get offlineWillRetry => 'Offline — yrittää uudelleen automaattisesti.';

  @override
  String get upToDate => 'Ajan tasalla';

  @override
  String operationsFailingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count epäonnistunutta toimenpidettä',
      one: '1 epäonnistunut toimenpide',
    );
    return '$_temp0';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count odottaa',
      one: '1 odottaa',
    );
    return '$_temp0';
  }

  @override
  String pendingFailingCount(String pending, String failing) {
    return '$pending, $failing';
  }

  @override
  String get relayStatus => 'Releiden tila';

  @override
  String get relaysLabel => 'Releet';

  @override
  String relaysConfiguredLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count määritetty',
      one: '1 määritetty',
    );
    return '$_temp0';
  }

  @override
  String get unencryptedTransport => 'Salaamaton siirto';

  @override
  String couldNotReachService(String error) {
    return 'astraea-serviceen ei saatu yhteyttä: $error';
  }
}
