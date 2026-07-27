// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get appTitle => 'Astraea';

  @override
  String get cancel => 'Άκυρο';

  @override
  String get save => 'Αποθήκευση';

  @override
  String get delete => 'Διαγραφή';

  @override
  String get continueLabel => 'Συνέχεια';

  @override
  String get next => 'Επόμενο';

  @override
  String get back => 'Πίσω';

  @override
  String get loading => 'Φόρτωση…';

  @override
  String get settingsTooltip => 'Ρυθμίσεις';

  @override
  String get newEventButton => 'Νέο συμβάν';

  @override
  String couldNotLoadEvents(String error) {
    return 'Δεν ήταν δυνατή η φόρτωση συμβάντων:\n$error';
  }

  @override
  String get viewMonth => 'Μήνας';

  @override
  String get viewWeek => 'Εβδομάδα';

  @override
  String get viewDay => 'Ημέρα';

  @override
  String get viewList => 'Λίστα';

  @override
  String get noEventsToday => 'Δεν υπάρχουν συμβάντα αυτή την ημέρα.';

  @override
  String get noUpcomingEvents =>
      'Δεν υπάρχουν προσεχή συμβάντα τις επόμενες 60 ημέρες.';

  @override
  String get untitledEvent => '(χωρίς τίτλο)';

  @override
  String get allDay => 'Όλη την ημέρα';

  @override
  String get addAccountToSyncTooltip =>
      'Προσθήκη λογαριασμού Nostr για συγχρονισμό';

  @override
  String get syncNowTooltip => 'Συγχρονισμός τώρα';

  @override
  String get addNostrAccountTitle => 'Προσθήκη λογαριασμού Nostr';

  @override
  String get eventNotFound => 'Το συμβάν δεν βρέθηκε.';

  @override
  String get eventAppBarTitle => 'Συμβάν';

  @override
  String get editTooltip => 'Επεξεργασία';

  @override
  String get deleteTooltip => 'Διαγραφή';

  @override
  String allDayLabel(String date) {
    return '$date · Όλη την ημέρα';
  }

  @override
  String recurrenceUntilLabel(String recurrence, String date) {
    return '$recurrence · έως $date';
  }

  @override
  String get syncedToRelays => 'Συγχρονισμένο με τους relay';

  @override
  String get notYetSynced => 'Δεν έχει συγχρονιστεί ακόμη';

  @override
  String get deleteEventTitle => 'Διαγραφή συμβάντος;';

  @override
  String get deleteEventBody =>
      'Αυτό αφαιρεί το συμβάν από αυτή τη συσκευή και ζητά τη διαγραφή του από τους relay.';

  @override
  String get editEventTitle => 'Επεξεργασία συμβάντος';

  @override
  String get newEventTitle => 'Νέο συμβάν';

  @override
  String get fieldTitle => 'Τίτλος';

  @override
  String get allDaySwitch => 'Όλη την ημέρα';

  @override
  String get startsLabel => 'Έναρξη';

  @override
  String get endsLabel => 'Λήξη';

  @override
  String get timezoneLabel => 'Ζώνη ώρας';

  @override
  String get repeatsLabel => 'Επανάληψη';

  @override
  String get untilLabel => 'Έως';

  @override
  String get foreverLabel => 'Για πάντα';

  @override
  String get remindersLabel => 'Υπενθυμίσεις';

  @override
  String get addChip => 'Προσθήκη';

  @override
  String get colorLabel => 'Χρώμα';

  @override
  String get locationLabel => 'Τοποθεσία';

  @override
  String get descriptionLabel => 'Περιγραφή';

  @override
  String couldNotSaveEvent(String error) {
    return 'Δεν ήταν δυνατή η αποθήκευση του συμβάντος: $error';
  }

  @override
  String get recurrenceNone => 'Δεν επαναλαμβάνεται';

  @override
  String get recurrenceDaily => 'Καθημερινά';

  @override
  String get recurrenceWeekly => 'Εβδομαδιαία';

  @override
  String get recurrenceMonthly => 'Μηνιαία';

  @override
  String get recurrenceYearly => 'Ετήσια';

  @override
  String get reminderAtStart => 'Στην έναρξη';

  @override
  String reminderMinutesBefore(int count) {
    return '$count λεπτά πριν';
  }

  @override
  String reminderHoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ώρες πριν',
      one: '1 ώρα πριν',
    );
    return '$_temp0';
  }

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ημέρες πριν',
      one: '1 ημέρα πριν',
    );
    return '$_temp0';
  }

  @override
  String get getStarted => 'Ξεκινήστε';

  @override
  String get useOffline => 'Χρήση εκτός σύνδεσης';

  @override
  String get welcomeTitle => 'Καλώς ήρθατε στο Astraea';

  @override
  String get welcomeSubtitle =>
      'Ένα ιδιωτικό ημερολόγιο, εκτός σύνδεσης πρωτίστως, που σας αφήνει τον έλεγχο.';

  @override
  String get featureLocalTitle => 'Το ημερολόγιό σας παραμένει στη συσκευή σας';

  @override
  String get featureLocalBody =>
      'Δημιουργήστε συμβάντα, επαναλήψεις και υπενθυμίσεις χωρίς λογαριασμό ή σύνδεση στο διαδίκτυο.';

  @override
  String get featureSyncTitle => 'Προαιρετικός συγχρονισμός μέσω Nostr';

  @override
  String get featureSyncBody =>
      'Συνδέστε έναν λογαριασμό για να δημιουργήσετε αντίγραφο ασφαλείας του ημερολογίου σας και να το χρησιμοποιήσετε σε πολλές συσκευές μέσω relay που επιλέγετε.';

  @override
  String get featureEncryptedTitle =>
      'Πάντα κρυπτογραφημένο πριν από τη μεταφόρτωση';

  @override
  String get featureEncryptedBody =>
      'Το περιεχόμενο του ημερολογίου κρυπτογραφείται από άκρο σε άκρο πριν φύγει από αυτή τη συσκευή. Οι διαχειριστές relay δεν μπορούν να το διαβάσουν.';

  @override
  String get featureAmberTitle => 'Κρατήστε το κλειδί σας στο Amber';

  @override
  String get featureAmberBody =>
      'Στο Android, ένας εξωτερικός υπογράφων μπορεί να εγκρίνει την πρόσβαση χωρίς να εκθέτει το ιδιωτικό σας κλειδί στο Astraea.';

  @override
  String get featureRemindersTitle => 'Ιδιωτικές τοπικές υπενθυμίσεις';

  @override
  String get featureRemindersBody =>
      'Οι ειδοποιήσεις προγραμματίζονται από τη συσκευή σας και δεν εξαρτώνται από υπηρεσία ημερολογίου στο cloud.';

  @override
  String get connectNostrAccountTitle => 'Σύνδεση λογαριασμού Nostr';

  @override
  String get connectNostrAccountBody =>
      'Αυτό απαιτείται μόνο για κρυπτογραφημένο συγχρονισμό. Μπορείτε επίσης να χρησιμοποιήσετε το Astraea εντελώς εκτός σύνδεσης.';

  @override
  String get chooseRelaysTitle => 'Επιλέξτε relay για συγχρονισμό';

  @override
  String get chooseRelaysBody =>
      'Οι relay αποθηκεύουν το κρυπτογραφημένο ημερολόγιό σας και το καθιστούν διαθέσιμο στις άλλες συσκευές σας. Προσθέστε έναν ή περισσότερους, ή αφήστε τη λίστα κενή και ρυθμίστε το αργότερα.';

  @override
  String couldNotLoadRelaySettings(String error) {
    return 'Δεν ήταν δυνατή η φόρτωση των ρυθμίσεων relay: $error';
  }

  @override
  String get suggestedRelays => 'Προτεινόμενα';

  @override
  String get addRelayTooltip => 'Προσθήκη relay';

  @override
  String get customRelayLabel => 'Προσαρμοσμένο relay';

  @override
  String get customRelayHint => 'wss://relay.example.com';

  @override
  String get selectedRelays => 'Επιλεγμένα';

  @override
  String get removeRelayTooltip => 'Αφαίρεση relay';

  @override
  String get invalidRelayUrl =>
      'Εισαγάγετε μια έγκυρη διεύθυνση wss:// (ή ws:// για ιδιωτικό relay).';

  @override
  String get insecureRelayWarning =>
      'Το ws:// δεν είναι κρυπτογραφημένο κατά τη μεταφορά — χρησιμοποιήστε το μόνο για relay που εμπιστεύεστε.';

  @override
  String get nostrAccountConnected => 'Ο λογαριασμός Nostr συνδέθηκε';

  @override
  String get invalidPrivateKey =>
      'Αυτό το ιδιωτικό κλειδί δεν είναι έγκυρο. Ελέγξτε το και δοκιμάστε ξανά.';

  @override
  String couldNotSignIn(String error) {
    return 'Δεν ήταν δυνατή η σύνδεση: $error';
  }

  @override
  String get signInWithAmber => 'Σύνδεση με Amber';

  @override
  String get createNewAccount => 'Δημιουργία νέου λογαριασμού';

  @override
  String get generatedAccountWarning =>
      'Ένας δημιουργημένος λογαριασμός μπορεί να ανακτηθεί μόνο με το ιδιωτικό του κλειδί. Δημιουργήστε αντίγραφο ασφαλείας από τις Ρυθμίσεις μετά την εγκατάσταση.';

  @override
  String get importExistingKey => 'Εισαγωγή υπάρχοντος κλειδιού';

  @override
  String get privateKeyFieldLabel => 'nsec ή δεκαεξαδικό ιδιωτικό κλειδί';

  @override
  String get importButton => 'Εισαγωγή';

  @override
  String get followDeviceTimezone => 'Ακολούθηση ζώνης ώρας συσκευής';

  @override
  String get searchCityRegion => 'Αναζήτηση πόλης ή περιοχής';

  @override
  String get noMatchingTimezone => 'Δεν υπάρχει αντίστοιχη ζώνη ώρας.';

  @override
  String get settingsTitle => 'Ρυθμίσεις';

  @override
  String couldNotLoadSettings(String error) {
    return 'Δεν ήταν δυνατή η φόρτωση των ρυθμίσεων:\n$error';
  }

  @override
  String get sectionAccount => 'Λογαριασμός';

  @override
  String get sectionSync => 'Συγχρονισμός';

  @override
  String get sectionRelays => 'Relay';

  @override
  String get sectionAppearance => 'Εμφάνιση';

  @override
  String get sectionData => 'Δεδομένα';

  @override
  String get sectionRemindersTimezone => 'Υπενθυμίσεις και ζώνη ώρας';

  @override
  String get sectionSupport => 'Υποστήριξη';

  @override
  String somethingWentWrong(String error) {
    return 'Κάτι πήγε στραβά: $error';
  }

  @override
  String get offlineNoAccount => 'Εκτός σύνδεσης — χωρίς λογαριασμό';

  @override
  String get signInToSyncAcrossDevices =>
      'Συνδεθείτε για να συγχρονίσετε το κρυπτογραφημένο ημερολόγιό σας μεταξύ συσκευών.';

  @override
  String get signIn => 'Σύνδεση';

  @override
  String get signedInWithAmber => 'Συνδεδεμένος με Amber';

  @override
  String get signedIn => 'Συνδεδεμένος';

  @override
  String get signOut => 'Αποσύνδεση';

  @override
  String get backUpPrivateKey => 'Αντίγραφο ασφαλείας ιδιωτικού κλειδιού';

  @override
  String get revealNsecSubtitle =>
      'Εμφανίστε το nsec σας για να το αποθηκεύσετε κάπου ασφαλές';

  @override
  String get signOutTitle => 'Αποσύνδεση;';

  @override
  String get signOutBody =>
      'Τα συμβάντα σας παραμένουν σε αυτή τη συσκευή και στους relay. Βεβαιωθείτε ότι έχετε δημιουργήσει αντίγραφο ασφαλείας του ιδιωτικού σας κλειδιού — χωρίς αυτό, ένας δημιουργημένος λογαριασμός δεν μπορεί να ανακτηθεί.';

  @override
  String get noPrivateKeyStored =>
      'Δεν υπάρχει αποθηκευμένο ιδιωτικό κλειδί για αυτή τη συνεδρία.';

  @override
  String get yourPrivateKeyTitle => 'Το ιδιωτικό σας κλειδί (nsec)';

  @override
  String get nsecWarning =>
      'Όποιος έχει αυτό το κλειδί ελέγχει τον λογαριασμό σας. Μην το μοιράζεστε ποτέ· αποθηκεύστε το σε διαχειριστή κωδικών πρόσβασης.';

  @override
  String get copy => 'Αντιγραφή';

  @override
  String get done => 'Τέλος';

  @override
  String get syncNowTitle => 'Συγχρονισμός τώρα';

  @override
  String get signInToSyncSubtitle =>
      'Συνδεθείτε για να συγχρονίσετε το κρυπτογραφημένο ημερολόγιό σας.';

  @override
  String get addRelayToSyncSubtitle =>
      'Προσθέστε τουλάχιστον έναν relay για συγχρονισμό.';

  @override
  String get syncingEllipsis => 'Συγχρονισμός…';

  @override
  String get synced => 'Συγχρονισμένο';

  @override
  String lastSyncedLabel(String when) {
    return 'Τελευταίος συγχρονισμός $when';
  }

  @override
  String lastSyncFailedLabel(String error) {
    return 'Ο τελευταίος συγχρονισμός απέτυχε: $error';
  }

  @override
  String get pullMergePublish =>
      'Λαμβάνει, συγχωνεύει και δημοσιεύει τα συμβάντα σας';

  @override
  String get publicRelays => 'Δημόσιοι relay';

  @override
  String relaysConfiguredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ρυθμισμένοι',
      one: '1 ρυθμισμένος',
    );
    return '$_temp0';
  }

  @override
  String get addRelay => 'Προσθήκη relay';

  @override
  String get suggestedRelaysTitle => 'Προτεινόμενοι relay';

  @override
  String get addOnlyRelaysYouWant =>
      'Προσθέστε μόνο τους relay που θέλετε να χρησιμοποιήσετε.';

  @override
  String get homeRelayBackup => 'Προσωπικός relay (αντίγραφο ασφαλείας)';

  @override
  String get homeRelayNotConfigured =>
      'Δεν έχει ρυθμιστεί — ένας επιπλέον προσωπικός relay για αντίγραφο ασφαλείας των συμβάντων σας';

  @override
  String get homeRelayDialogTitle => 'Προσωπικός relay';

  @override
  String get lightTheme => 'Ανοιχτόχρωμο θέμα';

  @override
  String get darkThemeDefault =>
      'Το Astraea χρησιμοποιεί το σκούρο θέμα ως προεπιλογή';

  @override
  String get languageLabel => 'Γλώσσα';

  @override
  String get systemLanguage => 'Γλώσσα συστήματος';

  @override
  String get exportEvents => 'Εξαγωγή συμβάντων';

  @override
  String get exportEventsSubtitle =>
      'Αποθήκευση αρχείου .ics — προαιρετικά προστατευμένο με κωδικό πρόσβασης';

  @override
  String get importEvents => 'Εισαγωγή συμβάντων';

  @override
  String get importEventsSubtitle =>
      'Από αρχείο .ics ή κρυπτογραφημένη εξαγωγή Astraea';

  @override
  String get encryptExportTitle => 'Κρυπτογράφηση αυτής της εξαγωγής;';

  @override
  String get encryptExportBody =>
      'Ένα απλό αρχείο .ics μπορεί να ανοιχθεί από οποιαδήποτε εφαρμογή ημερολογίου — και από όποιον το αποκτήσει. Ορίστε έναν κωδικό πρόσβασης για να το κρυπτογραφήσετε (μόνο το Astraea θα μπορεί να το επανεισαγάγει).';

  @override
  String get exportPasswordLabel =>
      'Κωδικός πρόσβασης (αφήστε κενό για απλό .ics)';

  @override
  String get export => 'Εξαγωγή';

  @override
  String get encryptedExportSaved => 'Η κρυπτογραφημένη εξαγωγή αποθηκεύτηκε.';

  @override
  String get exportSaved => 'Η εξαγωγή αποθηκεύτηκε.';

  @override
  String exportFailed(String error) {
    return 'Η εξαγωγή απέτυχε: $error';
  }

  @override
  String get couldNotReadSelectedFile =>
      'Δεν ήταν δυνατή η ανάγνωση του επιλεγμένου αρχείου.';

  @override
  String get selectedFileTooLarge =>
      'Το επιλεγμένο αρχείο υπερβαίνει τα 10 MB.';

  @override
  String importedEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Εισήχθησαν $count συμβάντα.',
      one: 'Εισήχθη 1 συμβάν.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(String error) {
    return 'Η εισαγωγή απέτυχε: $error';
  }

  @override
  String get thisExportIsEncrypted => 'Αυτή η εξαγωγή είναι κρυπτογραφημένη';

  @override
  String get passwordLabel => 'Κωδικός πρόσβασης';

  @override
  String get wrongPassword => 'Λανθασμένος κωδικός πρόσβασης.';

  @override
  String get invalidEncryptedExport =>
      'Αυτή η κρυπτογραφημένη εξαγωγή δεν είναι έγκυρη.';

  @override
  String get reminders => 'Υπενθυμίσεις';

  @override
  String get scheduleLocalNotifications =>
      'Προγραμματισμός τοπικών ειδοποιήσεων για υπενθυμίσεις συμβάντων';

  @override
  String get timezone => 'Ζώνη ώρας';

  @override
  String followDeviceTimezoneWithName(String zone) {
    return 'Ακολούθηση ζώνης ώρας συσκευής ($zone)';
  }

  @override
  String get supportAstraea => 'Υποστηρίξτε το Astraea';

  @override
  String noLightningWalletFound(String address) {
    return 'Δεν βρέθηκε πορτοφόλι Lightning — η διεύθυνση αντιγράφηκε: $address';
  }

  @override
  String get desktopServiceUnreachableTitle =>
      'Η υπηρεσία παρασκηνίου του Astraea δεν είναι διαθέσιμη';

  @override
  String get desktopServiceUnreachableBody =>
      'Η εφαρμογή επιτραπέζιου υπολογιστή επικοινωνεί με το astraea-service μέσω D-Bus για αποθήκευση, συγχρονισμό και ειδοποιήσεις, αλλά δεν ήταν δυνατή η επικοινωνία. Αν το εκτελείτε από τον πηγαίο κώδικα, εγκαταστήστε το με:\n\n./scripts/install-dev.sh';

  @override
  String get retry => 'Επανάληψη';

  @override
  String get calendarsLabel => 'Ημερολόγια';

  @override
  String calendarsUnavailable(String error) {
    return 'Τα ημερολόγια δεν είναι διαθέσιμα: $error';
  }

  @override
  String get serviceUnreachable => 'Η υπηρεσία δεν είναι προσβάσιμη';

  @override
  String syncStatusLabel(String status) {
    return 'Συγχρονισμός: $status';
  }

  @override
  String syncPendingSuffix(int count) {
    return ' ($count σε εκκρεμότητα)';
  }

  @override
  String get localOnlyMode => 'Λειτουργία μόνο τοπικά (χωρίς ταυτότητα Nostr)';

  @override
  String get syncStarted => 'Ο συγχρονισμός ξεκίνησε';

  @override
  String syncUnavailable(String error) {
    return 'Ο συγχρονισμός δεν είναι διαθέσιμος: $error';
  }

  @override
  String get notSignedIn => 'Δεν είστε συνδεδεμένοι';

  @override
  String get signInWithBrowserSubtitle =>
      'Συνδεθείτε με το πρόγραμμα περιήγησής σας (NIP-07) για να συγχρονίσετε αυτό το ημερολόγιο μέσω Nostr.';

  @override
  String get signedInBackgroundSigning =>
      'Συνδεδεμένος — υπογραφή στο παρασκήνιο μέσω εξουσιοδοτημένου κλειδιού';

  @override
  String get signedInRemoteSigner =>
      'Συνδεδεμένος — απομακρυσμένος υπογράφων (NIP-46)';

  @override
  String get signedInNoBackgroundSigner =>
      'Συνδεδεμένος, αλλά δεν έχει ρυθμιστεί υπογράφων παρασκηνίου — ο συγχρονισμός παραμένει σε παύση. Εκτελέστε το «astraea-service auth provision-key» σε ένα τερματικό.';

  @override
  String couldNotStartLogin(String error) {
    return 'Δεν ήταν δυνατή η έναρξη της σύνδεσης: $error';
  }

  @override
  String get signOutConfirmDesktopBody =>
      'Αυτό ξεχνά τον λογαριασμό μόνο σε αυτή τη συσκευή — τα συμβάντα σας παραμένουν στους relay. Τυχόν παρεχόμενο κλειδί υπογραφής αφαιρείται από την μπρελόκ.';

  @override
  String get signInWithBrowserTitle =>
      'Συνδεθείτε με το πρόγραμμα περιήγησής σας';

  @override
  String get loginSessionExpired =>
      'Αυτή η συνεδρία σύνδεσης έληξε. Δοκιμάστε ξανά.';

  @override
  String get loginWaitingBody =>
      'Ανοίχθηκε μια καρτέλα προγράμματος περιήγησης για την επιβεβαίωση της ταυτότητάς σας Nostr (NIP-07). Εγκρίνετέ την εκεί — αυτός ο διάλογος κλείνει αυτόματα. Το ιδιωτικό σας κλειδί δεν ζητείται ποτέ.';

  @override
  String get openAgain => 'Άνοιγμα ξανά';

  @override
  String get offlineWillRetry => 'Εκτός σύνδεσης — θα επαναληφθεί αυτόματα.';

  @override
  String get upToDate => 'Ενημερωμένο';

  @override
  String operationsFailingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count αποτυχημένες λειτουργίες',
      one: '1 αποτυχημένη λειτουργία',
    );
    return '$_temp0';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count σε εκκρεμότητα',
      one: '1 σε εκκρεμότητα',
    );
    return '$_temp0';
  }

  @override
  String pendingFailingCount(String pending, String failing) {
    return '$pending, $failing';
  }

  @override
  String get relayStatus => 'Κατάσταση relay';

  @override
  String get relaysLabel => 'Relay';

  @override
  String relaysConfiguredLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ρυθμισμένοι',
      one: '1 ρυθμισμένος',
    );
    return '$_temp0';
  }

  @override
  String get unencryptedTransport => 'Μη κρυπτογραφημένη μεταφορά';

  @override
  String couldNotReachService(String error) {
    return 'Δεν ήταν δυνατή η επικοινωνία με το astraea-service: $error';
  }

  @override
  String get inviteSectionTitle => 'Συμμετέχοντες';

  @override
  String get inviteButtonLabel => 'Πρόσκληση';

  @override
  String get noAttendeesYet => 'Δεν έχει προσκληθεί κανείς ακόμη';

  @override
  String get inviteDialogTitle => 'Προσκάλεσε κάποιον';

  @override
  String get inviteDialogHint => 'npub, όνομα@τομέας ή δημόσιο κλειδί';

  @override
  String resolvePersonFailed(String error) {
    return 'Δεν ήταν δυνατή η εύρεση αυτού του ατόμου: $error';
  }

  @override
  String get confirmNip05Title => 'Επιβεβαίωση παραλήπτη';

  @override
  String confirmNip05Body(String query, String pubkey) {
    return 'Το $query αντιστοιχίστηκε στο $pubkey μέσω NIP-05. Αυτή η αντιστοίχιση ελέγχεται από τον τομέα — βεβαιωθείτε ότι πρόκειται για το αναμενόμενο άτομο.';
  }

  @override
  String get attendeeStatusInvited => 'Προσκλήθηκε';

  @override
  String get attendeeStatusAccepted => 'Αποδέχθηκε';

  @override
  String get attendeeStatusDeclined => 'Απέρριψε';

  @override
  String inviteFailed(String error) {
    return 'Δεν ήταν δυνατή η αποστολή της πρόσκλησης: $error';
  }

  @override
  String get pendingInvitationsTooltip => 'Προσκλήσεις';

  @override
  String get pendingInvitationsTitle => 'Προσκλήσεις';

  @override
  String get pendingInvitationsEmpty => 'Δεν υπάρχουν εκκρεμείς προσκλήσεις';

  @override
  String invitationFromLabel(String pubkey) {
    return 'Από $pubkey';
  }

  @override
  String get acceptInvitation => 'Αποδοχή';

  @override
  String get declineInvitation => 'Απόρριψη';

  @override
  String respondToInvitationFailed(String error) {
    return 'Δεν ήταν δυνατή η αποστολή απάντησης: $error';
  }

  @override
  String get invitationAccepted => 'Η πρόσκληση έγινε αποδεκτή';

  @override
  String get invitationDeclined => 'Η πρόσκληση απορρίφθηκε';
}
