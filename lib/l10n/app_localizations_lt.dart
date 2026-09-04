// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Lithuanian (`lt`).
class AppLocalizationsLt extends AppLocalizations {
  AppLocalizationsLt([String locale = 'lt']) : super(locale);

  @override
  String get appTitle => 'Astraea';

  @override
  String get cancel => 'Atšaukti';

  @override
  String get save => 'Išsaugoti';

  @override
  String get delete => 'Ištrinti';

  @override
  String get continueLabel => 'Tęsti';

  @override
  String get next => 'Kitas';

  @override
  String get back => 'Atgal';

  @override
  String get loading => 'Įkeliama…';

  @override
  String get settingsTooltip => 'Nustatymai';

  @override
  String get newEventButton => 'Naujas įvykis';

  @override
  String couldNotLoadEvents(String error) {
    return 'Nepavyko įkelti įvykių:\n$error';
  }

  @override
  String get viewMonth => 'Mėnuo';

  @override
  String get viewWeek => 'Savaitė';

  @override
  String get viewDay => 'Diena';

  @override
  String get viewList => 'Sąrašas';

  @override
  String get noEventsToday => 'Šią dieną įvykių nėra.';

  @override
  String get noUpcomingEvents => 'Artimiausias 60 dienų būsimų įvykių nėra.';

  @override
  String get untitledEvent => '(be pavadinimo)';

  @override
  String get allDay => 'Visą dieną';

  @override
  String get addAccountToSyncTooltip =>
      'Pridėti Nostr paskyrą sinchronizavimui';

  @override
  String get syncNowTooltip => 'Sinchronizuoti dabar';

  @override
  String get addNostrAccountTitle => 'Pridėti Nostr paskyrą';

  @override
  String get eventNotFound => 'Įvykis nerastas.';

  @override
  String get eventAppBarTitle => 'Įvykis';

  @override
  String get editTooltip => 'Redaguoti';

  @override
  String get deleteTooltip => 'Ištrinti';

  @override
  String allDayLabel(String date) {
    return '$date · Visą dieną';
  }

  @override
  String recurrenceUntilLabel(String recurrence, String date) {
    return '$recurrence · iki $date';
  }

  @override
  String get syncedToRelays => 'Sinchronizuota su relėmis';

  @override
  String get notYetSynced => 'Dar nesinchronizuota';

  @override
  String get deleteEventTitle => 'Ištrinti įvykį?';

  @override
  String get deleteEventBody =>
      'Tai pašalins įvykį iš šio įrenginio ir paprašys jį ištrinti iš relių.';

  @override
  String get editEventTitle => 'Redaguoti įvykį';

  @override
  String get newEventTitle => 'Naujas įvykis';

  @override
  String get fieldTitle => 'Pavadinimas';

  @override
  String get allDaySwitch => 'Visą dieną';

  @override
  String get startsLabel => 'Prasideda';

  @override
  String get endsLabel => 'Baigiasi';

  @override
  String get timezoneLabel => 'Laiko juosta';

  @override
  String get repeatsLabel => 'Pasikartojimas';

  @override
  String get untilLabel => 'Iki';

  @override
  String get foreverLabel => 'Visam laikui';

  @override
  String get remindersLabel => 'Priminimai';

  @override
  String get addChip => 'Pridėti';

  @override
  String get colorLabel => 'Spalva';

  @override
  String get locationLabel => 'Vieta';

  @override
  String get descriptionLabel => 'Aprašymas';

  @override
  String couldNotSaveEvent(String error) {
    return 'Nepavyko išsaugoti įvykio: $error';
  }

  @override
  String get recurrenceNone => 'Nesikartoja';

  @override
  String get recurrenceDaily => 'Kasdien';

  @override
  String get recurrenceWeekly => 'Kas savaitę';

  @override
  String get recurrenceMonthly => 'Kas mėnesį';

  @override
  String get recurrenceYearly => 'Kasmet';

  @override
  String get reminderAtStart => 'Pradžioje';

  @override
  String reminderMinutesBefore(int count) {
    return '$count min. prieš';
  }

  @override
  String reminderHoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valandų prieš',
      few: '$count valandas prieš',
      one: '1 valandą prieš',
    );
    return '$_temp0';
  }

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dienų prieš',
      few: '$count dienas prieš',
      one: '1 dieną prieš',
    );
    return '$_temp0';
  }

  @override
  String get getStarted => 'Pradėti';

  @override
  String get useOffline => 'Naudoti neprisijungus';

  @override
  String get welcomeTitle => 'Sveiki atvykę į Astraea';

  @override
  String get welcomeSubtitle =>
      'Privatus, pirmiausia neprisijungus veikiantis kalendorius, paliekantis kontrolę jums.';

  @override
  String get featureLocalTitle => 'Jūsų kalendorius lieka jūsų įrenginyje';

  @override
  String get featureLocalBody =>
      'Kurkite įvykius, pasikartojimus ir priminimus be paskyros ar interneto ryšio.';

  @override
  String get featureSyncTitle => 'Neprivalomas sinchronizavimas per Nostr';

  @override
  String get featureSyncBody =>
      'Prijunkite paskyrą, kad sukurtumėte kalendoriaus atsarginę kopiją ir naudotumėte jį keliuose įrenginiuose per jūsų pasirinktus relius.';

  @override
  String get featureEncryptedTitle => 'Visada užšifruota prieš įkeliant';

  @override
  String get featureEncryptedBody =>
      'Kalendoriaus turinys šifruojamas ištisai prieš paliekant šį įrenginį. Relių operatoriai negali jo skaityti.';

  @override
  String get featureAmberTitle => 'Saugokite savo raktą Amber programoje';

  @override
  String get featureAmberBody =>
      'Android sistemoje išorinis pasirašantysis gali patvirtinti prieigą neatskleisdamas jūsų privataus rakto Astraea.';

  @override
  String get featureRemindersTitle => 'Privatūs vietiniai priminimai';

  @override
  String get featureRemindersBody =>
      'Pranešimus suplanuoja jūsų įrenginys, ir jie nepriklauso nuo debesijos kalendoriaus paslaugos.';

  @override
  String get connectNostrAccountTitle => 'Prijungti Nostr paskyrą';

  @override
  String get connectNostrAccountBody =>
      'To reikia tik šifruotam sinchronizavimui. Astraea taip pat galite naudoti visiškai neprisijungę.';

  @override
  String get chooseRelaysTitle => 'Pasirinkite relius sinchronizavimui';

  @override
  String get chooseRelaysBody =>
      'Reliai saugo jūsų šifruotą kalendorių ir padaro jį prieinamą kituose jūsų įrenginiuose. Pridėkite vieną ar daugiau, arba palikite sąrašą tuščią ir sukonfigūruokite vėliau.';

  @override
  String couldNotLoadRelaySettings(String error) {
    return 'Nepavyko įkelti relių nustatymų: $error';
  }

  @override
  String get suggestedRelays => 'Siūlomi';

  @override
  String get addRelayTooltip => 'Pridėti relę';

  @override
  String get customRelayLabel => 'Pasirinktinė relė';

  @override
  String get customRelayHint => 'wss://relay.example.com';

  @override
  String get selectedRelays => 'Pasirinkti';

  @override
  String get removeRelayTooltip => 'Pašalinti relę';

  @override
  String get invalidRelayUrl =>
      'Įveskite galiojantį wss:// adresą (arba ws:// privačiai relei).';

  @override
  String get insecureRelayWarning =>
      'ws:// perdavimo metu nešifruojamas — naudokite tik relei, kuria pasitikite.';

  @override
  String get nostrAccountConnected => 'Nostr paskyra prijungta';

  @override
  String get invalidPrivateKey =>
      'Šis privatus raktas negalioja. Patikrinkite jį ir bandykite dar kartą.';

  @override
  String couldNotSignIn(String error) {
    return 'Nepavyko prisijungti: $error';
  }

  @override
  String get signInWithAmber => 'Prisijungti su Amber';

  @override
  String get createNewAccount => 'Sukurti naują paskyrą';

  @override
  String get generatedAccountWarning =>
      'Sukurtą paskyrą galima atkurti tik naudojant jos privatų raktą. Padarykite atsarginę kopiją Nustatymuose po sąrankos.';

  @override
  String get importExistingKey => 'Importuoti esamą raktą';

  @override
  String get privateKeyFieldLabel => 'nsec arba šešioliktainis privatus raktas';

  @override
  String get importButton => 'Importuoti';

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
  String get followDeviceTimezone => 'Naudoti įrenginio laiko juostą';

  @override
  String get searchCityRegion => 'Ieškoti miesto ar regiono';

  @override
  String get noMatchingTimezone => 'Atitinkančios laiko juostos nėra.';

  @override
  String get settingsTitle => 'Nustatymai';

  @override
  String couldNotLoadSettings(String error) {
    return 'Nepavyko įkelti nustatymų:\n$error';
  }

  @override
  String get sectionAccount => 'Paskyra';

  @override
  String get sectionSync => 'Sinchronizavimas';

  @override
  String get sectionRelays => 'Reliai';

  @override
  String get sectionAppearance => 'Išvaizda';

  @override
  String get sectionData => 'Duomenys';

  @override
  String get sectionRemindersTimezone => 'Priminimai ir laiko juosta';

  @override
  String get sectionSupport => 'Pagalba';

  @override
  String somethingWentWrong(String error) {
    return 'Kažkas nutiko ne taip: $error';
  }

  @override
  String get offlineNoAccount => 'Neprisijungęs — nėra paskyros';

  @override
  String get signInToSyncAcrossDevices =>
      'Prisijunkite, kad sinchronizuotumėte šifruotą kalendorių tarp įrenginių.';

  @override
  String get signIn => 'Prisijungti';

  @override
  String get signedInWithAmber => 'Prisijungta su Amber';

  @override
  String get signedIn => 'Prisijungta';

  @override
  String get signOut => 'Atsijungti';

  @override
  String get backUpPrivateKey => 'Sukurti privataus rakto atsarginę kopiją';

  @override
  String get revealNsecSubtitle =>
      'Parodykite savo nsec, kad išsaugotumėte jį saugioje vietoje';

  @override
  String get signOutTitle => 'Atsijungti?';

  @override
  String get signOutBody =>
      'Jūsų įvykiai lieka šiame įrenginyje ir reliuose. Įsitikinkite, kad padarėte privataus rakto atsarginę kopiją — be jo sukurtos paskyros negalima atkurti.';

  @override
  String get noPrivateKeyStored => 'Šiai sesijai privataus rakto neišsaugota.';

  @override
  String get yourPrivateKeyTitle => 'Jūsų privatus raktas (nsec)';

  @override
  String get nsecWarning =>
      'Kiekvienas, turintis šį raktą, kontroliuoja jūsų paskyrą. Niekada juo nesidalykite; saugokite slaptažodžių tvarkyklėje.';

  @override
  String get copy => 'Kopijuoti';

  @override
  String get done => 'Atlikta';

  @override
  String get syncNowTitle => 'Sinchronizuoti dabar';

  @override
  String get signInToSyncSubtitle =>
      'Prisijunkite, kad sinchronizuotumėte šifruotą kalendorių.';

  @override
  String get addRelayToSyncSubtitle =>
      'Norėdami sinchronizuoti, pridėkite bent vieną relę.';

  @override
  String get syncingEllipsis => 'Sinchronizuojama…';

  @override
  String get synced => 'Sinchronizuota';

  @override
  String lastSyncedLabel(String when) {
    return 'Paskutinį kartą sinchronizuota $when';
  }

  @override
  String lastSyncFailedLabel(String error) {
    return 'Paskutinis sinchronizavimas nepavyko: $error';
  }

  @override
  String get pullMergePublish => 'Gauna, sujungia ir publikuoja jūsų įvykius';

  @override
  String get publicRelays => 'Vieši reliai';

  @override
  String relaysConfiguredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sukonfigūruotų',
      few: '$count sukonfigūruoti',
      one: '1 sukonfigūruotas',
    );
    return '$_temp0';
  }

  @override
  String get addRelay => 'Pridėti relę';

  @override
  String get suggestedRelaysTitle => 'Siūlomi reliai';

  @override
  String get addOnlyRelaysYouWant =>
      'Pridėkite tik tuos relius, kuriuos norite naudoti.';

  @override
  String get homeRelayBackup => 'Asmeninė relė (atsarginė kopija)';

  @override
  String get homeRelayNotConfigured =>
      'Nesukonfigūruota — papildoma asmeninė relė jūsų įvykių atsarginei kopijai';

  @override
  String get homeRelayDialogTitle => 'Asmeninė relė';

  @override
  String get lightTheme => 'Šviesi tema';

  @override
  String get darkThemeDefault =>
      'Astraea pagal numatytuosius nustatymus naudoja tamsią temą';

  @override
  String get languageLabel => 'Kalba';

  @override
  String get systemLanguage => 'Sistemos kalba';

  @override
  String get accentColorLabel => 'Akcentinė spalva';

  @override
  String get accentNavy => 'Tamsiai mėlyna';

  @override
  String get accentBitcoin => 'Bitkoino oranžinė';

  @override
  String get accentNostr => 'Nostr violetinė';

  @override
  String get exportEvents => 'Eksportuoti įvykius';

  @override
  String get exportEventsSubtitle =>
      'Išsaugoti .ics failą — pasirinktinai apsaugotą slaptažodžiu';

  @override
  String get importEvents => 'Importuoti įvykius';

  @override
  String get importEventsSubtitle =>
      'Iš .ics failo arba šifruoto Astraea eksporto';

  @override
  String get encryptExportTitle => 'Šifruoti šį eksportą?';

  @override
  String get encryptExportBody =>
      'Paprastą .ics failą gali atidaryti bet kuri kalendoriaus programa — ir bet kas, kas jį gauna. Nustatykite slaptažodį, kad jį užšifruotumėte (jį iš naujo importuoti galės tik Astraea).';

  @override
  String get exportPasswordLabel =>
      'Slaptažodis (palikite tuščią paprastam .ics failui)';

  @override
  String get export => 'Eksportuoti';

  @override
  String get encryptedExportSaved => 'Šifruotas eksportas išsaugotas.';

  @override
  String get exportSaved => 'Eksportas išsaugotas.';

  @override
  String exportFailed(String error) {
    return 'Eksportavimas nepavyko: $error';
  }

  @override
  String get couldNotReadSelectedFile =>
      'Nepavyko perskaityti pasirinkto failo.';

  @override
  String get selectedFileTooLarge => 'Pasirinktas failas didesnis nei 10 MB.';

  @override
  String importedEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importuota $count įvykių.',
      few: 'Importuoti $count įvykiai.',
      one: 'Importuotas 1 įvykis.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(String error) {
    return 'Importavimas nepavyko: $error';
  }

  @override
  String get thisExportIsEncrypted => 'Šis eksportas yra šifruotas';

  @override
  String get passwordLabel => 'Slaptažodis';

  @override
  String get wrongPassword => 'Neteisingas slaptažodis.';

  @override
  String get invalidEncryptedExport => 'Šis šifruotas eksportas negalioja.';

  @override
  String get reminders => 'Priminimai';

  @override
  String get scheduleLocalNotifications =>
      'Suplanuoti vietinius pranešimus įvykių priminimams';

  @override
  String get timezone => 'Laiko juosta';

  @override
  String followDeviceTimezoneWithName(String zone) {
    return 'Naudoti įrenginio laiko juostą ($zone)';
  }

  @override
  String get supportAstraea => 'Paremti Astraea';

  @override
  String noLightningWalletFound(String address) {
    return 'Lightning piniginė nerasta — adresas nukopijuotas: $address';
  }

  @override
  String get desktopServiceUnreachableTitle =>
      'Astraea foninė paslauga nepasiekiama';

  @override
  String get desktopServiceUnreachableBody =>
      'Darbalaukio programa bendrauja su astraea-service per D-Bus saugojimui, sinchronizavimui ir pranešimams, tačiau nepavyko su ja susisiekti. Jei paleidžiate iš šaltinio kodo, įdiekite ją naudodami:\n\n./scripts/install-dev.sh';

  @override
  String get retry => 'Bandyti dar kartą';

  @override
  String get calendarsLabel => 'Kalendoriai';

  @override
  String calendarsUnavailable(String error) {
    return 'Kalendoriai nepasiekiami: $error';
  }

  @override
  String get serviceUnreachable => 'Paslauga nepasiekiama';

  @override
  String syncStatusLabel(String status) {
    return 'Sinchronizavimas: $status';
  }

  @override
  String syncPendingSuffix(int count) {
    return ' ($count laukiama)';
  }

  @override
  String get localOnlyMode => 'Tik vietinis režimas (nėra Nostr tapatybės)';

  @override
  String get syncStarted => 'Sinchronizavimas pradėtas';

  @override
  String syncUnavailable(String error) {
    return 'Sinchronizavimas nepasiekiamas: $error';
  }

  @override
  String get notSignedIn => 'Neprisijungta';

  @override
  String get signInWithBrowserSubtitle =>
      'Prisijunkite naudodami naršyklę (NIP-07), kad sinchronizuotumėte šį kalendorių per Nostr.';

  @override
  String get signedInBackgroundSigning =>
      'Prisijungta — pasirašymas fone naudojant deleguotą raktą';

  @override
  String get signedInRemoteSigner =>
      'Prisijungta — nuotolinis pasirašytojas (NIP-46)';

  @override
  String get signedInNoBackgroundSigner =>
      'Prisijungta, tačiau foninis pasirašytojas nesukonfigūruotas — sinchronizavimas lieka pristabdytas. Terminale paleiskite „astraea-service auth provision-key“.';

  @override
  String couldNotStartLogin(String error) {
    return 'Nepavyko pradėti prisijungimo: $error';
  }

  @override
  String get signOutConfirmDesktopBody =>
      'Tai pamiršta paskyrą tik šiame įrenginyje — jūsų įvykiai lieka reliuose. Bet koks suteiktas pasirašymo raktas pašalinamas iš raktų pakabuko.';

  @override
  String get signInWithBrowserTitle => 'Prisijunkite naudodami naršyklę';

  @override
  String get loginSessionExpired =>
      'Ši prisijungimo sesija baigėsi. Bandykite dar kartą.';

  @override
  String get loginWaitingBody =>
      'Buvo atidarytas naršyklės skirtukas jūsų Nostr tapatybei patvirtinti (NIP-07). Patvirtinkite ten — šis dialogo langas užsidarys automatiškai. Jūsų privataus rakto niekada neprašoma.';

  @override
  String get openAgain => 'Atidaryti dar kartą';

  @override
  String get offlineWillRetry =>
      'Neprisijungęs — bandys dar kartą automatiškai.';

  @override
  String get upToDate => 'Atnaujinta';

  @override
  String operationsFailingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nepavykusių operacijų',
      few: '$count nepavykusios operacijos',
      one: '1 nepavykusi operacija',
    );
    return '$_temp0';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count laukiama',
      few: '$count laukiama',
      one: '1 laukiama',
    );
    return '$_temp0';
  }

  @override
  String pendingFailingCount(String pending, String failing) {
    return '$pending, $failing';
  }

  @override
  String get relayStatus => 'Relių būsena';

  @override
  String get relaysLabel => 'Reliai';

  @override
  String relaysConfiguredLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sukonfigūruotų',
      few: '$count sukonfigūruoti',
      one: '1 sukonfigūruotas',
    );
    return '$_temp0';
  }

  @override
  String get unencryptedTransport => 'Nešifruotas perdavimas';

  @override
  String couldNotReachService(String error) {
    return 'Nepavyko susisiekti su astraea-service: $error';
  }

  @override
  String get inviteSectionTitle => 'Dalyviai';

  @override
  String get inviteButtonLabel => 'Pakviesti';

  @override
  String get noAttendeesYet => 'Kol kas niekas nepakviestas';

  @override
  String get inviteDialogTitle => 'Pakviesti asmenį';

  @override
  String get inviteDialogHint => 'npub, vardas@domenas arba viešasis raktas';

  @override
  String resolvePersonFailed(String error) {
    return 'Nepavyko rasti šio asmens: $error';
  }

  @override
  String get confirmNip05Title => 'Patvirtinkite gavėją';

  @override
  String confirmNip05Body(String query, String pubkey) {
    return '$query per NIP-05 buvo susietas su $pubkey. Šį susiejimą valdo domenas — įsitikinkite, kad tai laukiamas asmuo.';
  }

  @override
  String get attendeeStatusInvited => 'Pakviestas';

  @override
  String get attendeeStatusAccepted => 'Priimta';

  @override
  String get attendeeStatusDeclined => 'Atmesta';

  @override
  String inviteFailed(String error) {
    return 'Nepavyko išsiųsti kvietimo: $error';
  }

  @override
  String get pendingInvitationsTooltip => 'Kvietimai';

  @override
  String get pendingInvitationsTitle => 'Kvietimai';

  @override
  String get pendingInvitationsEmpty => 'Nėra laukiančių kvietimų';

  @override
  String invitationFromLabel(String pubkey) {
    return 'Nuo $pubkey';
  }

  @override
  String get acceptInvitation => 'Priimti';

  @override
  String get declineInvitation => 'Atmesti';

  @override
  String respondToInvitationFailed(String error) {
    return 'Nepavyko atsakyti: $error';
  }

  @override
  String get invitationAccepted => 'Kvietimas priimtas';

  @override
  String get invitationDeclined => 'Kvietimas atmestas';
}
