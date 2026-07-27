// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appTitle => 'Astraea';

  @override
  String get cancel => 'Anulează';

  @override
  String get save => 'Salvează';

  @override
  String get delete => 'Șterge';

  @override
  String get continueLabel => 'Continuă';

  @override
  String get next => 'Următorul';

  @override
  String get back => 'Înapoi';

  @override
  String get loading => 'Se încarcă…';

  @override
  String get settingsTooltip => 'Setări';

  @override
  String get newEventButton => 'Eveniment nou';

  @override
  String couldNotLoadEvents(String error) {
    return 'Evenimentele nu au putut fi încărcate:\n$error';
  }

  @override
  String get viewMonth => 'Lună';

  @override
  String get viewWeek => 'Săptămână';

  @override
  String get viewDay => 'Zi';

  @override
  String get viewList => 'Listă';

  @override
  String get noEventsToday => 'Nu există evenimente în această zi.';

  @override
  String get noUpcomingEvents =>
      'Nu există evenimente viitoare în următoarele 60 de zile.';

  @override
  String get untitledEvent => '(fără titlu)';

  @override
  String get allDay => 'Toată ziua';

  @override
  String get addAccountToSyncTooltip =>
      'Adaugă un cont Nostr pentru sincronizare';

  @override
  String get syncNowTooltip => 'Sincronizează acum';

  @override
  String get addNostrAccountTitle => 'Adaugă un cont Nostr';

  @override
  String get eventNotFound => 'Evenimentul nu a fost găsit.';

  @override
  String get eventAppBarTitle => 'Eveniment';

  @override
  String get editTooltip => 'Editează';

  @override
  String get deleteTooltip => 'Șterge';

  @override
  String allDayLabel(String date) {
    return '$date · Toată ziua';
  }

  @override
  String recurrenceUntilLabel(String recurrence, String date) {
    return '$recurrence · până la $date';
  }

  @override
  String get syncedToRelays => 'Sincronizat cu releele';

  @override
  String get notYetSynced => 'Încă nesincronizat';

  @override
  String get deleteEventTitle => 'Ștergi evenimentul?';

  @override
  String get deleteEventBody =>
      'Aceasta elimină evenimentul de pe acest dispozitiv și solicită ștergerea de pe relee.';

  @override
  String get editEventTitle => 'Editează evenimentul';

  @override
  String get newEventTitle => 'Eveniment nou';

  @override
  String get fieldTitle => 'Titlu';

  @override
  String get allDaySwitch => 'Toată ziua';

  @override
  String get startsLabel => 'Începe';

  @override
  String get endsLabel => 'Se termină';

  @override
  String get timezoneLabel => 'Fus orar';

  @override
  String get repeatsLabel => 'Repetare';

  @override
  String get untilLabel => 'Până la';

  @override
  String get foreverLabel => 'Pentru totdeauna';

  @override
  String get remindersLabel => 'Mementouri';

  @override
  String get addChip => 'Adaugă';

  @override
  String get colorLabel => 'Culoare';

  @override
  String get locationLabel => 'Locație';

  @override
  String get descriptionLabel => 'Descriere';

  @override
  String couldNotSaveEvent(String error) {
    return 'Evenimentul nu a putut fi salvat: $error';
  }

  @override
  String get recurrenceNone => 'Nu se repetă';

  @override
  String get recurrenceDaily => 'Zilnic';

  @override
  String get recurrenceWeekly => 'Săptămânal';

  @override
  String get recurrenceMonthly => 'Lunar';

  @override
  String get recurrenceYearly => 'Anual';

  @override
  String get reminderAtStart => 'La început';

  @override
  String reminderMinutesBefore(int count) {
    return '$count min înainte';
  }

  @override
  String reminderHoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'cu $count de ore înainte',
      few: 'cu $count ore înainte',
      one: 'cu 1 oră înainte',
    );
    return '$_temp0';
  }

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'cu $count de zile înainte',
      few: 'cu $count zile înainte',
      one: 'cu 1 zi înainte',
    );
    return '$_temp0';
  }

  @override
  String get getStarted => 'Începe';

  @override
  String get useOffline => 'Utilizează offline';

  @override
  String get welcomeTitle => 'Bine ai venit la Astraea';

  @override
  String get welcomeSubtitle =>
      'Un calendar privat, offline-first, care îți lasă ție controlul.';

  @override
  String get featureLocalTitle => 'Calendarul tău rămâne pe dispozitivul tău';

  @override
  String get featureLocalBody =>
      'Creează evenimente, recurențe și mementouri fără cont sau conexiune la internet.';

  @override
  String get featureSyncTitle => 'Sincronizare opțională prin Nostr';

  @override
  String get featureSyncBody =>
      'Conectează un cont pentru a face backup calendarului tău și a-l folosi pe mai multe dispozitive prin releele pe care le alegi.';

  @override
  String get featureEncryptedTitle =>
      'Întotdeauna criptat înainte de încărcare';

  @override
  String get featureEncryptedBody =>
      'Conținutul calendarului este criptat integral înainte de a părăsi acest dispozitiv. Operatorii releelor nu îl pot citi.';

  @override
  String get featureAmberTitle => 'Păstrează-ți cheia în Amber';

  @override
  String get featureAmberBody =>
      'Pe Android, un semnatar extern poate aproba accesul fără a expune cheia ta privată către Astraea.';

  @override
  String get featureRemindersTitle => 'Mementouri locale private';

  @override
  String get featureRemindersBody =>
      'Notificările sunt programate de dispozitivul tău și nu depind de un serviciu de calendar în cloud.';

  @override
  String get connectNostrAccountTitle => 'Conectează un cont Nostr';

  @override
  String get connectNostrAccountBody =>
      'Acest lucru este necesar doar pentru sincronizarea criptată. Poți folosi Astraea și complet offline.';

  @override
  String get chooseRelaysTitle => 'Alege relee pentru sincronizare';

  @override
  String get chooseRelaysBody =>
      'Releele stochează calendarul tău criptat și îl fac disponibil pe celelalte dispozitive ale tale. Adaugă unul sau mai multe, sau lasă lista goală și configureaz-o mai târziu.';

  @override
  String couldNotLoadRelaySettings(String error) {
    return 'Setările releelor nu au putut fi încărcate: $error';
  }

  @override
  String get suggestedRelays => 'Sugerate';

  @override
  String get addRelayTooltip => 'Adaugă releu';

  @override
  String get customRelayLabel => 'Releu personalizat';

  @override
  String get customRelayHint => 'wss://relay.example.com';

  @override
  String get selectedRelays => 'Selectate';

  @override
  String get removeRelayTooltip => 'Elimină releul';

  @override
  String get invalidRelayUrl =>
      'Introdu o adresă URL wss:// validă (sau ws:// pentru un releu privat).';

  @override
  String get insecureRelayWarning =>
      'ws:// nu este criptat în timpul transportului — folosește-l doar pentru un releu în care ai încredere.';

  @override
  String get nostrAccountConnected => 'Cont Nostr conectat';

  @override
  String get invalidPrivateKey =>
      'Această cheie privată nu este validă. Verific-o și încearcă din nou.';

  @override
  String couldNotSignIn(String error) {
    return 'Autentificarea a eșuat: $error';
  }

  @override
  String get signInWithAmber => 'Autentifică-te cu Amber';

  @override
  String get createNewAccount => 'Creează un cont nou';

  @override
  String get generatedAccountWarning =>
      'Un cont generat poate fi recuperat doar cu cheia sa privată. Fă backup din Setări după configurare.';

  @override
  String get importExistingKey => 'Importă o cheie existentă';

  @override
  String get privateKeyFieldLabel => 'nsec sau cheie privată hexazecimală';

  @override
  String get importButton => 'Importă';

  @override
  String get followDeviceTimezone => 'Urmează fusul orar al dispozitivului';

  @override
  String get searchCityRegion => 'Caută un oraș sau o regiune';

  @override
  String get noMatchingTimezone => 'Niciun fus orar corespunzător.';

  @override
  String get settingsTitle => 'Setări';

  @override
  String couldNotLoadSettings(String error) {
    return 'Setările nu au putut fi încărcate:\n$error';
  }

  @override
  String get sectionAccount => 'Cont';

  @override
  String get sectionSync => 'Sincronizare';

  @override
  String get sectionRelays => 'Relee';

  @override
  String get sectionAppearance => 'Aspect';

  @override
  String get sectionData => 'Date';

  @override
  String get sectionRemindersTimezone => 'Mementouri și fus orar';

  @override
  String get sectionSupport => 'Asistență';

  @override
  String somethingWentWrong(String error) {
    return 'Ceva a mers greșit: $error';
  }

  @override
  String get offlineNoAccount => 'Offline — niciun cont';

  @override
  String get signInToSyncAcrossDevices =>
      'Autentifică-te pentru a sincroniza calendarul criptat între dispozitive.';

  @override
  String get signIn => 'Autentificare';

  @override
  String get signedInWithAmber => 'Autentificat cu Amber';

  @override
  String get signedIn => 'Autentificat';

  @override
  String get signOut => 'Deconectare';

  @override
  String get backUpPrivateKey => 'Backup cheie privată';

  @override
  String get revealNsecSubtitle =>
      'Dezvăluie-ți nsec pentru a-l salva într-un loc sigur';

  @override
  String get signOutTitle => 'Te deconectezi?';

  @override
  String get signOutBody =>
      'Evenimentele tale rămân pe acest dispozitiv și pe relee. Asigură-te că ai făcut backup cheii private — fără ea, un cont generat nu poate fi recuperat.';

  @override
  String get noPrivateKeyStored =>
      'Nu există nicio cheie privată salvată pentru această sesiune.';

  @override
  String get yourPrivateKeyTitle => 'Cheia ta privată (nsec)';

  @override
  String get nsecWarning =>
      'Oricine deține această cheie controlează contul tău. Nu o distribui niciodată; păstreaz-o într-un manager de parole.';

  @override
  String get copy => 'Copiază';

  @override
  String get done => 'Gata';

  @override
  String get syncNowTitle => 'Sincronizează acum';

  @override
  String get signInToSyncSubtitle =>
      'Autentifică-te pentru a sincroniza calendarul criptat.';

  @override
  String get addRelayToSyncSubtitle =>
      'Adaugă cel puțin un releu pentru a sincroniza.';

  @override
  String get syncingEllipsis => 'Se sincronizează…';

  @override
  String get synced => 'Sincronizat';

  @override
  String lastSyncedLabel(String when) {
    return 'Ultima sincronizare $when';
  }

  @override
  String lastSyncFailedLabel(String error) {
    return 'Ultima sincronizare a eșuat: $error';
  }

  @override
  String get pullMergePublish => 'Preia, combină și publică evenimentele tale';

  @override
  String get publicRelays => 'Relee publice';

  @override
  String relaysConfiguredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de configurate',
      few: '$count configurate',
      one: '1 configurat',
    );
    return '$_temp0';
  }

  @override
  String get addRelay => 'Adaugă releu';

  @override
  String get suggestedRelaysTitle => 'Relee sugerate';

  @override
  String get addOnlyRelaysYouWant =>
      'Adaugă doar releele pe care vrei să le folosești.';

  @override
  String get homeRelayBackup => 'Releu personal (backup)';

  @override
  String get homeRelayNotConfigured =>
      'Neconfigurat — un releu personal suplimentar pentru a face backup evenimentelor tale';

  @override
  String get homeRelayDialogTitle => 'Releu personal';

  @override
  String get lightTheme => 'Temă deschisă';

  @override
  String get darkThemeDefault => 'Astraea folosește implicit tema întunecată';

  @override
  String get languageLabel => 'Limbă';

  @override
  String get systemLanguage => 'Limba sistemului';

  @override
  String get exportEvents => 'Exportă evenimente';

  @override
  String get exportEventsSubtitle =>
      'Salvează un fișier .ics — opțional protejat prin parolă';

  @override
  String get importEvents => 'Importă evenimente';

  @override
  String get importEventsSubtitle =>
      'Dintr-un fișier .ics sau un export criptat Astraea';

  @override
  String get encryptExportTitle => 'Criptezi acest export?';

  @override
  String get encryptExportBody =>
      'Un fișier .ics simplu poate fi deschis de orice aplicație de calendar — și de oricine îl obține. Setează o parolă pentru a-l cripta (doar Astraea va putea să-l reimporte).';

  @override
  String get exportPasswordLabel => 'Parolă (lasă gol pentru un .ics simplu)';

  @override
  String get export => 'Exportă';

  @override
  String get encryptedExportSaved => 'Export criptat salvat.';

  @override
  String get exportSaved => 'Export salvat.';

  @override
  String exportFailed(String error) {
    return 'Exportul a eșuat: $error';
  }

  @override
  String get couldNotReadSelectedFile =>
      'Fișierul selectat nu a putut fi citit.';

  @override
  String get selectedFileTooLarge => 'Fișierul selectat depășește 10 MB.';

  @override
  String importedEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de evenimente importate.',
      few: '$count evenimente importate.',
      one: '1 eveniment importat.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(String error) {
    return 'Importul a eșuat: $error';
  }

  @override
  String get thisExportIsEncrypted => 'Acest export este criptat';

  @override
  String get passwordLabel => 'Parolă';

  @override
  String get wrongPassword => 'Parolă incorectă.';

  @override
  String get invalidEncryptedExport => 'Acest export criptat nu este valid.';

  @override
  String get reminders => 'Mementouri';

  @override
  String get scheduleLocalNotifications =>
      'Programează notificări locale pentru mementourile evenimentelor';

  @override
  String get timezone => 'Fus orar';

  @override
  String followDeviceTimezoneWithName(String zone) {
    return 'Urmează fusul orar al dispozitivului ($zone)';
  }

  @override
  String get supportAstraea => 'Susține Astraea';

  @override
  String noLightningWalletFound(String address) {
    return 'Nu s-a găsit niciun portofel Lightning — adresa a fost copiată: $address';
  }

  @override
  String get desktopServiceUnreachableTitle =>
      'Serviciul de fundal Astraea este indisponibil';

  @override
  String get desktopServiceUnreachableBody =>
      'Aplicația desktop comunică cu astraea-service prin D-Bus pentru stocare, sincronizare și notificări și nu a putut fi contactat. Dacă îl rulezi din sursă, instalează-l cu:\n\n./scripts/install-dev.sh';

  @override
  String get retry => 'Încearcă din nou';

  @override
  String get calendarsLabel => 'Calendare';

  @override
  String calendarsUnavailable(String error) {
    return 'Calendare indisponibile: $error';
  }

  @override
  String get serviceUnreachable => 'Serviciu inaccesibil';

  @override
  String syncStatusLabel(String status) {
    return 'Sincronizare: $status';
  }

  @override
  String syncPendingSuffix(int count) {
    return ' ($count în așteptare)';
  }

  @override
  String get localOnlyMode => 'Mod doar local (fără identitate Nostr)';

  @override
  String get syncStarted => 'Sincronizare pornită';

  @override
  String syncUnavailable(String error) {
    return 'Sincronizare indisponibilă: $error';
  }

  @override
  String get notSignedIn => 'Neautentificat';

  @override
  String get signInWithBrowserSubtitle =>
      'Autentifică-te cu browserul tău (NIP-07) pentru a sincroniza acest calendar prin Nostr.';

  @override
  String get signedInBackgroundSigning =>
      'Autentificat — semnare în fundal printr-o cheie delegată';

  @override
  String get signedInRemoteSigner =>
      'Autentificat — semnatar la distanță (NIP-46)';

  @override
  String get signedInNoBackgroundSigner =>
      'Autentificat, dar niciun semnatar de fundal nu este configurat — sincronizarea rămâne în pauză. Rulează „astraea-service auth provision-key” într-un terminal.';

  @override
  String couldNotStartLogin(String error) {
    return 'Autentificarea nu a putut fi pornită: $error';
  }

  @override
  String get signOutConfirmDesktopBody =>
      'Aceasta uită contul doar pe acest dispozitiv — evenimentele tale rămân pe relee. O eventuală cheie de semnare furnizată este eliminată din breloc.';

  @override
  String get signInWithBrowserTitle => 'Autentifică-te cu browserul tău';

  @override
  String get loginSessionExpired =>
      'Această sesiune de autentificare a expirat. Încearcă din nou.';

  @override
  String get loginWaitingBody =>
      'A fost deschisă o filă de browser pentru a confirma identitatea ta Nostr (NIP-07). Aprob-o acolo — această fereastră se închide automat. Cheia ta privată nu este niciodată solicitată.';

  @override
  String get openAgain => 'Deschide din nou';

  @override
  String get offlineWillRetry => 'Offline — va reîncerca automat.';

  @override
  String get upToDate => 'Actualizat';

  @override
  String operationsFailingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de operațiuni eșuate',
      few: '$count operațiuni eșuate',
      one: '1 operațiune eșuată',
    );
    return '$_temp0';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count în așteptare',
      few: '$count în așteptare',
      one: '1 în așteptare',
    );
    return '$_temp0';
  }

  @override
  String pendingFailingCount(String pending, String failing) {
    return '$pending, $failing';
  }

  @override
  String get relayStatus => 'Starea releelor';

  @override
  String get relaysLabel => 'Relee';

  @override
  String relaysConfiguredLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de configurate',
      few: '$count configurate',
      one: '1 configurat',
    );
    return '$_temp0';
  }

  @override
  String get unencryptedTransport => 'Transport necriptat';

  @override
  String couldNotReachService(String error) {
    return 'Nu s-a putut contacta astraea-service: $error';
  }

  @override
  String get inviteSectionTitle => 'Participanți';

  @override
  String get inviteButtonLabel => 'Invită';

  @override
  String get noAttendeesYet => 'Nimeni nu a fost invitat încă';

  @override
  String get inviteDialogTitle => 'Invită pe cineva';

  @override
  String get inviteDialogHint => 'npub, nume@domeniu sau cheie publică';

  @override
  String resolvePersonFailed(String error) {
    return 'Persoana nu a putut fi găsită: $error';
  }

  @override
  String get confirmNip05Title => 'Confirmă destinatarul';

  @override
  String confirmNip05Body(String query, String pubkey) {
    return '$query a fost rezolvat la $pubkey prin NIP-05. Această corespondență este controlată de domeniu — asigură-te că este persoana așteptată.';
  }

  @override
  String get attendeeStatusInvited => 'Invitat';

  @override
  String get attendeeStatusAccepted => 'Acceptat';

  @override
  String get attendeeStatusDeclined => 'Refuzat';

  @override
  String inviteFailed(String error) {
    return 'Invitația nu a putut fi trimisă: $error';
  }

  @override
  String get pendingInvitationsTooltip => 'Invitații';

  @override
  String get pendingInvitationsTitle => 'Invitații';

  @override
  String get pendingInvitationsEmpty => 'Nicio invitație în așteptare';

  @override
  String invitationFromLabel(String pubkey) {
    return 'De la $pubkey';
  }

  @override
  String get acceptInvitation => 'Acceptă';

  @override
  String get declineInvitation => 'Refuză';

  @override
  String respondToInvitationFailed(String error) {
    return 'Răspunsul nu a putut fi trimis: $error';
  }

  @override
  String get invitationAccepted => 'Invitație acceptată';

  @override
  String get invitationDeclined => 'Invitație refuzată';
}
