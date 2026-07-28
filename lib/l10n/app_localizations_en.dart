// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Astraea';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get continueLabel => 'Continue';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get loading => 'Loading…';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get newEventButton => 'New event';

  @override
  String couldNotLoadEvents(String error) {
    return 'Could not load events:\n$error';
  }

  @override
  String get viewMonth => 'Month';

  @override
  String get viewWeek => 'Week';

  @override
  String get viewDay => 'Day';

  @override
  String get viewList => 'List';

  @override
  String get noEventsToday => 'No events on this day.';

  @override
  String get noUpcomingEvents => 'No upcoming events in the next 60 days.';

  @override
  String get untitledEvent => '(untitled)';

  @override
  String get allDay => 'All day';

  @override
  String get addAccountToSyncTooltip => 'Add a Nostr account to sync';

  @override
  String get syncNowTooltip => 'Sync now';

  @override
  String get addNostrAccountTitle => 'Add a Nostr account';

  @override
  String get eventNotFound => 'Event not found.';

  @override
  String get eventAppBarTitle => 'Event';

  @override
  String get editTooltip => 'Edit';

  @override
  String get deleteTooltip => 'Delete';

  @override
  String allDayLabel(String date) {
    return '$date · All day';
  }

  @override
  String recurrenceUntilLabel(String recurrence, String date) {
    return '$recurrence · until $date';
  }

  @override
  String get syncedToRelays => 'Synced to relays';

  @override
  String get notYetSynced => 'Not yet synced';

  @override
  String get deleteEventTitle => 'Delete event?';

  @override
  String get deleteEventBody =>
      'This removes the event from this device and requests deletion from the relays.';

  @override
  String get editEventTitle => 'Edit event';

  @override
  String get newEventTitle => 'New event';

  @override
  String get fieldTitle => 'Title';

  @override
  String get allDaySwitch => 'All day';

  @override
  String get startsLabel => 'Starts';

  @override
  String get endsLabel => 'Ends';

  @override
  String get timezoneLabel => 'Timezone';

  @override
  String get repeatsLabel => 'Repeats';

  @override
  String get untilLabel => 'Until';

  @override
  String get foreverLabel => 'Forever';

  @override
  String get remindersLabel => 'Reminders';

  @override
  String get addChip => 'Add';

  @override
  String get colorLabel => 'Color';

  @override
  String get locationLabel => 'Location';

  @override
  String get descriptionLabel => 'Description';

  @override
  String couldNotSaveEvent(String error) {
    return 'Could not save the event: $error';
  }

  @override
  String get recurrenceNone => 'Does not repeat';

  @override
  String get recurrenceDaily => 'Daily';

  @override
  String get recurrenceWeekly => 'Weekly';

  @override
  String get recurrenceMonthly => 'Monthly';

  @override
  String get recurrenceYearly => 'Yearly';

  @override
  String get reminderAtStart => 'At start';

  @override
  String reminderMinutesBefore(int count) {
    return '$count min before';
  }

  @override
  String reminderHoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours before',
      one: '1 hour before',
    );
    return '$_temp0';
  }

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days before',
      one: '1 day before',
    );
    return '$_temp0';
  }

  @override
  String get getStarted => 'Get started';

  @override
  String get useOffline => 'Use offline';

  @override
  String get welcomeTitle => 'Welcome to Astraea';

  @override
  String get welcomeSubtitle =>
      'A private, offline-first calendar that puts you in control.';

  @override
  String get featureLocalTitle => 'Your calendar stays on your device';

  @override
  String get featureLocalBody =>
      'Create events, recurrences and reminders without an account or an internet connection.';

  @override
  String get featureSyncTitle => 'Optional sync through Nostr';

  @override
  String get featureSyncBody =>
      'Connect an account to back up your calendar and use it on multiple devices through relays you choose.';

  @override
  String get featureEncryptedTitle => 'Always encrypted before upload';

  @override
  String get featureEncryptedBody =>
      'Calendar contents are end-to-end encrypted before they leave this device. Relay operators cannot read them.';

  @override
  String get featureAmberTitle => 'Keep your key in Amber';

  @override
  String get featureAmberBody =>
      'On Android, an external signer can approve access without exposing your private key to Astraea.';

  @override
  String get featureRemindersTitle => 'Private local reminders';

  @override
  String get featureRemindersBody =>
      'Notifications are scheduled by your device and do not depend on a cloud calendar service.';

  @override
  String get connectNostrAccountTitle => 'Connect a Nostr account';

  @override
  String get connectNostrAccountBody =>
      'This is only needed for encrypted synchronization. You can also use Astraea entirely offline.';

  @override
  String get chooseRelaysTitle => 'Choose relays for synchronization';

  @override
  String get chooseRelaysBody =>
      'Relays store your encrypted calendar and make it available to your other devices. Add one or more, or leave the list empty and configure it later.';

  @override
  String couldNotLoadRelaySettings(String error) {
    return 'Could not load relay settings: $error';
  }

  @override
  String get suggestedRelays => 'Suggested';

  @override
  String get addRelayTooltip => 'Add relay';

  @override
  String get customRelayLabel => 'Custom relay';

  @override
  String get customRelayHint => 'wss://relay.example.com';

  @override
  String get selectedRelays => 'Selected';

  @override
  String get removeRelayTooltip => 'Remove relay';

  @override
  String get invalidRelayUrl =>
      'Enter a valid wss:// (or ws:// for a private relay) URL.';

  @override
  String get insecureRelayWarning =>
      'ws:// is unencrypted in transit — only use it for a relay you trust.';

  @override
  String get nostrAccountConnected => 'Nostr account connected';

  @override
  String get invalidPrivateKey =>
      'That private key is not valid. Check it and try again.';

  @override
  String couldNotSignIn(String error) {
    return 'Could not sign in: $error';
  }

  @override
  String get signInWithAmber => 'Sign in with Amber';

  @override
  String get createNewAccount => 'Create a new account';

  @override
  String get generatedAccountWarning =>
      'A generated account can only be recovered with its private key. Back it up from Settings after setup.';

  @override
  String get importExistingKey => 'Import an existing key';

  @override
  String get privateKeyFieldLabel => 'nsec or hex private key';

  @override
  String get importButton => 'Import';

  @override
  String get followDeviceTimezone => 'Follow device timezone';

  @override
  String get searchCityRegion => 'Search a city or region';

  @override
  String get noMatchingTimezone => 'No matching timezone.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String couldNotLoadSettings(String error) {
    return 'Could not load settings:\n$error';
  }

  @override
  String get sectionAccount => 'Account';

  @override
  String get sectionSync => 'Sync';

  @override
  String get sectionRelays => 'Relays';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get sectionData => 'Data';

  @override
  String get sectionRemindersTimezone => 'Reminders & timezone';

  @override
  String get sectionSupport => 'Support';

  @override
  String somethingWentWrong(String error) {
    return 'Something went wrong: $error';
  }

  @override
  String get offlineNoAccount => 'Offline — no account';

  @override
  String get signInToSyncAcrossDevices =>
      'Sign in to sync your encrypted calendar across devices.';

  @override
  String get signIn => 'Sign in';

  @override
  String get signedInWithAmber => 'Signed in with Amber';

  @override
  String get signedIn => 'Signed in';

  @override
  String get signOut => 'Sign out';

  @override
  String get backUpPrivateKey => 'Back up private key';

  @override
  String get revealNsecSubtitle => 'Reveal your nsec to save it somewhere safe';

  @override
  String get signOutTitle => 'Sign out?';

  @override
  String get signOutBody =>
      'Your events stay on this device and on the relays. Make sure you have backed up your private key — without it a generated account cannot be recovered.';

  @override
  String get noPrivateKeyStored => 'No private key stored for this session.';

  @override
  String get yourPrivateKeyTitle => 'Your private key (nsec)';

  @override
  String get nsecWarning =>
      'Anyone with this key controls your account. Never share it; store it in a password manager.';

  @override
  String get copy => 'Copy';

  @override
  String get done => 'Done';

  @override
  String get syncNowTitle => 'Sync now';

  @override
  String get signInToSyncSubtitle => 'Sign in to sync your encrypted calendar.';

  @override
  String get addRelayToSyncSubtitle => 'Add at least one relay to synchronize.';

  @override
  String get syncingEllipsis => 'Syncing…';

  @override
  String get synced => 'Synced';

  @override
  String lastSyncedLabel(String when) {
    return 'Last synced $when';
  }

  @override
  String lastSyncFailedLabel(String error) {
    return 'Last sync failed: $error';
  }

  @override
  String get pullMergePublish => 'Pull, merge and publish your events';

  @override
  String get publicRelays => 'Public relays';

  @override
  String relaysConfiguredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count configured',
      one: '1 configured',
    );
    return '$_temp0';
  }

  @override
  String get addRelay => 'Add relay';

  @override
  String get suggestedRelaysTitle => 'Suggested relays';

  @override
  String get addOnlyRelaysYouWant => 'Add only the relays you want to use.';

  @override
  String get homeRelayBackup => 'Home relay (backup)';

  @override
  String get homeRelayNotConfigured =>
      'Not configured — an additional personal relay to back up your events';

  @override
  String get homeRelayDialogTitle => 'Home relay';

  @override
  String get lightTheme => 'Light theme';

  @override
  String get darkThemeDefault => 'Astraea uses the dark theme by default';

  @override
  String get languageLabel => 'Language';

  @override
  String get systemLanguage => 'System language';

  @override
  String get accentColorLabel => 'Accent color';

  @override
  String get accentNavy => 'Navy blue';

  @override
  String get accentBitcoin => 'Bitcoin orange';

  @override
  String get accentNostr => 'Nostr purple';

  @override
  String get exportEvents => 'Export events';

  @override
  String get exportEventsSubtitle =>
      'Save a .ics file — optionally password-encrypted';

  @override
  String get importEvents => 'Import events';

  @override
  String get importEventsSubtitle =>
      'From a .ics file or an encrypted Astraea export';

  @override
  String get encryptExportTitle => 'Encrypt this export?';

  @override
  String get encryptExportBody =>
      'A plain .ics can be opened by any calendar app — and by anyone who gets the file. Set a password to encrypt it (only Astraea will be able to import it back).';

  @override
  String get exportPasswordLabel => 'Password (leave empty for a plain .ics)';

  @override
  String get export => 'Export';

  @override
  String get encryptedExportSaved => 'Encrypted export saved.';

  @override
  String get exportSaved => 'Export saved.';

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get couldNotReadSelectedFile => 'Could not read the selected file.';

  @override
  String get selectedFileTooLarge => 'The selected file is larger than 10 MB.';

  @override
  String importedEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count events.',
      one: 'Imported 1 event.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get thisExportIsEncrypted => 'This export is encrypted';

  @override
  String get passwordLabel => 'Password';

  @override
  String get wrongPassword => 'Wrong password.';

  @override
  String get invalidEncryptedExport => 'This encrypted export is not valid.';

  @override
  String get reminders => 'Reminders';

  @override
  String get scheduleLocalNotifications =>
      'Schedule local notifications for event reminders';

  @override
  String get timezone => 'Timezone';

  @override
  String followDeviceTimezoneWithName(String zone) {
    return 'Follow device timezone ($zone)';
  }

  @override
  String get supportAstraea => 'Support Astraea';

  @override
  String noLightningWalletFound(String address) {
    return 'No Lightning wallet found — address copied: $address';
  }

  @override
  String get desktopServiceUnreachableTitle =>
      'Astraea background service unavailable';

  @override
  String get desktopServiceUnreachableBody =>
      'The desktop app talks to astraea-service over D-Bus for storage, sync and notifications, and it could not be reached. If you are running from source, install it with:\n\n./scripts/install-dev.sh';

  @override
  String get retry => 'Retry';

  @override
  String get calendarsLabel => 'Calendars';

  @override
  String calendarsUnavailable(String error) {
    return 'Calendars unavailable: $error';
  }

  @override
  String get serviceUnreachable => 'Service unreachable';

  @override
  String syncStatusLabel(String status) {
    return 'Sync: $status';
  }

  @override
  String syncPendingSuffix(int count) {
    return ' ($count pending)';
  }

  @override
  String get localOnlyMode => 'Local-only mode (no Nostr identity)';

  @override
  String get syncStarted => 'Sync started';

  @override
  String syncUnavailable(String error) {
    return 'Sync unavailable: $error';
  }

  @override
  String get notSignedIn => 'Not signed in';

  @override
  String get signInWithBrowserSubtitle =>
      'Sign in with your browser (NIP-07) to sync this calendar over Nostr.';

  @override
  String get signedInBackgroundSigning =>
      'Signed in — background signing via a delegated key';

  @override
  String get signedInRemoteSigner => 'Signed in — remote signer (NIP-46)';

  @override
  String get signedInNoBackgroundSigner =>
      'Signed in, but no background signer is configured — sync stays parked. Run \"astraea-service auth provision-key\" in a terminal.';

  @override
  String couldNotStartLogin(String error) {
    return 'Could not start login: $error';
  }

  @override
  String get signOutConfirmDesktopBody =>
      'This forgets the account on this device only — your events stay on the relays. A provisioned signing key, if any, is removed from the keyring.';

  @override
  String get signInWithBrowserTitle => 'Sign in with your browser';

  @override
  String get loginSessionExpired => 'This login session expired. Try again.';

  @override
  String get loginWaitingBody =>
      'A browser tab was opened to confirm your Nostr identity (NIP-07). Approve it there — this dialog closes automatically. Your private key is never requested.';

  @override
  String get openAgain => 'Open again';

  @override
  String get offlineWillRetry => 'Offline — will retry automatically.';

  @override
  String get upToDate => 'Up to date';

  @override
  String operationsFailingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count operations failing',
      one: '1 operation failing',
    );
    return '$_temp0';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pending',
      one: '1 pending',
    );
    return '$_temp0';
  }

  @override
  String pendingFailingCount(String pending, String failing) {
    return '$pending, $failing';
  }

  @override
  String get relayStatus => 'Relay status';

  @override
  String get relaysLabel => 'Relays';

  @override
  String relaysConfiguredLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count configured',
      one: '1 configured',
    );
    return '$_temp0';
  }

  @override
  String get unencryptedTransport => 'Unencrypted transport';

  @override
  String couldNotReachService(String error) {
    return 'Could not reach astraea-service: $error';
  }

  @override
  String get inviteSectionTitle => 'Attendees';

  @override
  String get inviteButtonLabel => 'Invite';

  @override
  String get noAttendeesYet => 'No one invited yet';

  @override
  String get inviteDialogTitle => 'Invite someone';

  @override
  String get inviteDialogHint => 'npub, name@domain, or public key';

  @override
  String resolvePersonFailed(String error) {
    return 'Could not resolve that person: $error';
  }

  @override
  String get confirmNip05Title => 'Confirm recipient';

  @override
  String confirmNip05Body(String query, String pubkey) {
    return '$query resolved to $pubkey via NIP-05. This mapping is controlled by the domain — make sure it\'s who you expect.';
  }

  @override
  String get attendeeStatusInvited => 'Invited';

  @override
  String get attendeeStatusAccepted => 'Accepted';

  @override
  String get attendeeStatusDeclined => 'Declined';

  @override
  String inviteFailed(String error) {
    return 'Could not send the invite: $error';
  }

  @override
  String get pendingInvitationsTooltip => 'Invitations';

  @override
  String get pendingInvitationsTitle => 'Invitations';

  @override
  String get pendingInvitationsEmpty => 'No pending invitations';

  @override
  String invitationFromLabel(String pubkey) {
    return 'From $pubkey';
  }

  @override
  String get acceptInvitation => 'Accept';

  @override
  String get declineInvitation => 'Decline';

  @override
  String respondToInvitationFailed(String error) {
    return 'Could not respond: $error';
  }

  @override
  String get invitationAccepted => 'Invitation accepted';

  @override
  String get invitationDeclined => 'Invitation declined';
}
