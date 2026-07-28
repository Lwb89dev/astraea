import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bg.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_et.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ga.dart';
import 'app_localizations_hr.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_lt.dart';
import 'app_localizations_lv.dart';
import 'app_localizations_mt.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sk.dart';
import 'app_localizations_sl.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bg'),
    Locale('cs'),
    Locale('da'),
    Locale('de'),
    Locale('el'),
    Locale('en'),
    Locale('es'),
    Locale('et'),
    Locale('fi'),
    Locale('fr'),
    Locale('ga'),
    Locale('hr'),
    Locale('hu'),
    Locale('it'),
    Locale('ja'),
    Locale('lt'),
    Locale('lv'),
    Locale('mt'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
    Locale('ro'),
    Locale('ru'),
    Locale('sk'),
    Locale('sl'),
    Locale('sv'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Astraea'**
  String get appTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @newEventButton.
  ///
  /// In en, this message translates to:
  /// **'New event'**
  String get newEventButton;

  /// No description provided for @couldNotLoadEvents.
  ///
  /// In en, this message translates to:
  /// **'Could not load events:\n{error}'**
  String couldNotLoadEvents(String error);

  /// No description provided for @viewMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get viewMonth;

  /// No description provided for @viewWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get viewWeek;

  /// No description provided for @viewDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get viewDay;

  /// No description provided for @viewList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get viewList;

  /// No description provided for @noEventsToday.
  ///
  /// In en, this message translates to:
  /// **'No events on this day.'**
  String get noEventsToday;

  /// No description provided for @noUpcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'No upcoming events in the next 60 days.'**
  String get noUpcomingEvents;

  /// No description provided for @untitledEvent.
  ///
  /// In en, this message translates to:
  /// **'(untitled)'**
  String get untitledEvent;

  /// No description provided for @allDay.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get allDay;

  /// No description provided for @addAccountToSyncTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add a Nostr account to sync'**
  String get addAccountToSyncTooltip;

  /// No description provided for @syncNowTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNowTooltip;

  /// No description provided for @addNostrAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a Nostr account'**
  String get addNostrAccountTitle;

  /// No description provided for @eventNotFound.
  ///
  /// In en, this message translates to:
  /// **'Event not found.'**
  String get eventNotFound;

  /// No description provided for @eventAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get eventAppBarTitle;

  /// No description provided for @editTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editTooltip;

  /// No description provided for @deleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteTooltip;

  /// No description provided for @allDayLabel.
  ///
  /// In en, this message translates to:
  /// **'{date} · All day'**
  String allDayLabel(String date);

  /// No description provided for @recurrenceUntilLabel.
  ///
  /// In en, this message translates to:
  /// **'{recurrence} · until {date}'**
  String recurrenceUntilLabel(String recurrence, String date);

  /// No description provided for @syncedToRelays.
  ///
  /// In en, this message translates to:
  /// **'Synced to relays'**
  String get syncedToRelays;

  /// No description provided for @notYetSynced.
  ///
  /// In en, this message translates to:
  /// **'Not yet synced'**
  String get notYetSynced;

  /// No description provided for @deleteEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete event?'**
  String get deleteEventTitle;

  /// No description provided for @deleteEventBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the event from this device and requests deletion from the relays.'**
  String get deleteEventBody;

  /// No description provided for @editEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get editEventTitle;

  /// No description provided for @newEventTitle.
  ///
  /// In en, this message translates to:
  /// **'New event'**
  String get newEventTitle;

  /// No description provided for @fieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get fieldTitle;

  /// No description provided for @allDaySwitch.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get allDaySwitch;

  /// No description provided for @startsLabel.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get startsLabel;

  /// No description provided for @endsLabel.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get endsLabel;

  /// No description provided for @timezoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get timezoneLabel;

  /// No description provided for @repeatsLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get repeatsLabel;

  /// No description provided for @untilLabel.
  ///
  /// In en, this message translates to:
  /// **'Until'**
  String get untilLabel;

  /// No description provided for @foreverLabel.
  ///
  /// In en, this message translates to:
  /// **'Forever'**
  String get foreverLabel;

  /// No description provided for @remindersLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersLabel;

  /// No description provided for @addChip.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addChip;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @couldNotSaveEvent.
  ///
  /// In en, this message translates to:
  /// **'Could not save the event: {error}'**
  String couldNotSaveEvent(String error);

  /// No description provided for @recurrenceNone.
  ///
  /// In en, this message translates to:
  /// **'Does not repeat'**
  String get recurrenceNone;

  /// No description provided for @recurrenceDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get recurrenceDaily;

  /// No description provided for @recurrenceWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get recurrenceWeekly;

  /// No description provided for @recurrenceMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get recurrenceMonthly;

  /// No description provided for @recurrenceYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get recurrenceYearly;

  /// No description provided for @reminderAtStart.
  ///
  /// In en, this message translates to:
  /// **'At start'**
  String get reminderAtStart;

  /// No description provided for @reminderMinutesBefore.
  ///
  /// In en, this message translates to:
  /// **'{count} min before'**
  String reminderMinutesBefore(int count);

  /// No description provided for @reminderHoursBefore.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 hour before} other{{count} hours before}}'**
  String reminderHoursBefore(int count);

  /// No description provided for @reminderDaysBefore.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 day before} other{{count} days before}}'**
  String reminderDaysBefore(int count);

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @useOffline.
  ///
  /// In en, this message translates to:
  /// **'Use offline'**
  String get useOffline;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Astraea'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A private, offline-first calendar that puts you in control.'**
  String get welcomeSubtitle;

  /// No description provided for @featureLocalTitle.
  ///
  /// In en, this message translates to:
  /// **'Your calendar stays on your device'**
  String get featureLocalTitle;

  /// No description provided for @featureLocalBody.
  ///
  /// In en, this message translates to:
  /// **'Create events, recurrences and reminders without an account or an internet connection.'**
  String get featureLocalBody;

  /// No description provided for @featureSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Optional sync through Nostr'**
  String get featureSyncTitle;

  /// No description provided for @featureSyncBody.
  ///
  /// In en, this message translates to:
  /// **'Connect an account to back up your calendar and use it on multiple devices through relays you choose.'**
  String get featureSyncBody;

  /// No description provided for @featureEncryptedTitle.
  ///
  /// In en, this message translates to:
  /// **'Always encrypted before upload'**
  String get featureEncryptedTitle;

  /// No description provided for @featureEncryptedBody.
  ///
  /// In en, this message translates to:
  /// **'Calendar contents are end-to-end encrypted before they leave this device. Relay operators cannot read them.'**
  String get featureEncryptedBody;

  /// No description provided for @featureAmberTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your key in Amber'**
  String get featureAmberTitle;

  /// No description provided for @featureAmberBody.
  ///
  /// In en, this message translates to:
  /// **'On Android, an external signer can approve access without exposing your private key to Astraea.'**
  String get featureAmberBody;

  /// No description provided for @featureRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Private local reminders'**
  String get featureRemindersTitle;

  /// No description provided for @featureRemindersBody.
  ///
  /// In en, this message translates to:
  /// **'Notifications are scheduled by your device and do not depend on a cloud calendar service.'**
  String get featureRemindersBody;

  /// No description provided for @connectNostrAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect a Nostr account'**
  String get connectNostrAccountTitle;

  /// No description provided for @connectNostrAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This is only needed for encrypted synchronization. You can also use Astraea entirely offline.'**
  String get connectNostrAccountBody;

  /// No description provided for @chooseRelaysTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose relays for synchronization'**
  String get chooseRelaysTitle;

  /// No description provided for @chooseRelaysBody.
  ///
  /// In en, this message translates to:
  /// **'Relays store your encrypted calendar and make it available to your other devices. Add one or more, or leave the list empty and configure it later.'**
  String get chooseRelaysBody;

  /// No description provided for @couldNotLoadRelaySettings.
  ///
  /// In en, this message translates to:
  /// **'Could not load relay settings: {error}'**
  String couldNotLoadRelaySettings(String error);

  /// No description provided for @suggestedRelays.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get suggestedRelays;

  /// No description provided for @addRelayTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add relay'**
  String get addRelayTooltip;

  /// No description provided for @customRelayLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom relay'**
  String get customRelayLabel;

  /// No description provided for @customRelayHint.
  ///
  /// In en, this message translates to:
  /// **'wss://relay.example.com'**
  String get customRelayHint;

  /// No description provided for @selectedRelays.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selectedRelays;

  /// No description provided for @removeRelayTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove relay'**
  String get removeRelayTooltip;

  /// No description provided for @invalidRelayUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid wss:// (or ws:// for a private relay) URL.'**
  String get invalidRelayUrl;

  /// No description provided for @insecureRelayWarning.
  ///
  /// In en, this message translates to:
  /// **'ws:// is unencrypted in transit — only use it for a relay you trust.'**
  String get insecureRelayWarning;

  /// No description provided for @nostrAccountConnected.
  ///
  /// In en, this message translates to:
  /// **'Nostr account connected'**
  String get nostrAccountConnected;

  /// No description provided for @invalidPrivateKey.
  ///
  /// In en, this message translates to:
  /// **'That private key is not valid. Check it and try again.'**
  String get invalidPrivateKey;

  /// No description provided for @couldNotSignIn.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in: {error}'**
  String couldNotSignIn(String error);

  /// No description provided for @signInWithAmber.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Amber'**
  String get signInWithAmber;

  /// No description provided for @createNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Create a new account'**
  String get createNewAccount;

  /// No description provided for @generatedAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'A generated account can only be recovered with its private key. Back it up from Settings after setup.'**
  String get generatedAccountWarning;

  /// No description provided for @importExistingKey.
  ///
  /// In en, this message translates to:
  /// **'Import an existing key'**
  String get importExistingKey;

  /// No description provided for @privateKeyFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'nsec or hex private key'**
  String get privateKeyFieldLabel;

  /// No description provided for @importButton.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importButton;

  /// No description provided for @followDeviceTimezone.
  ///
  /// In en, this message translates to:
  /// **'Follow device timezone'**
  String get followDeviceTimezone;

  /// No description provided for @searchCityRegion.
  ///
  /// In en, this message translates to:
  /// **'Search a city or region'**
  String get searchCityRegion;

  /// No description provided for @noMatchingTimezone.
  ///
  /// In en, this message translates to:
  /// **'No matching timezone.'**
  String get noMatchingTimezone;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @couldNotLoadSettings.
  ///
  /// In en, this message translates to:
  /// **'Could not load settings:\n{error}'**
  String couldNotLoadSettings(String error);

  /// No description provided for @sectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get sectionAccount;

  /// No description provided for @sectionSync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sectionSync;

  /// No description provided for @sectionRelays.
  ///
  /// In en, this message translates to:
  /// **'Relays'**
  String get sectionRelays;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// No description provided for @sectionData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get sectionData;

  /// No description provided for @sectionRemindersTimezone.
  ///
  /// In en, this message translates to:
  /// **'Reminders & timezone'**
  String get sectionRemindersTimezone;

  /// No description provided for @sectionSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get sectionSupport;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong: {error}'**
  String somethingWentWrong(String error);

  /// No description provided for @offlineNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Offline — no account'**
  String get offlineNoAccount;

  /// No description provided for @signInToSyncAcrossDevices.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync your encrypted calendar across devices.'**
  String get signInToSyncAcrossDevices;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signedInWithAmber.
  ///
  /// In en, this message translates to:
  /// **'Signed in with Amber'**
  String get signedInWithAmber;

  /// No description provided for @signedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get signedIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @backUpPrivateKey.
  ///
  /// In en, this message translates to:
  /// **'Back up private key'**
  String get backUpPrivateKey;

  /// No description provided for @revealNsecSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reveal your nsec to save it somewhere safe'**
  String get revealNsecSubtitle;

  /// No description provided for @signOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutTitle;

  /// No description provided for @signOutBody.
  ///
  /// In en, this message translates to:
  /// **'Your events stay on this device and on the relays. Make sure you have backed up your private key — without it a generated account cannot be recovered.'**
  String get signOutBody;

  /// No description provided for @noPrivateKeyStored.
  ///
  /// In en, this message translates to:
  /// **'No private key stored for this session.'**
  String get noPrivateKeyStored;

  /// No description provided for @yourPrivateKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your private key (nsec)'**
  String get yourPrivateKeyTitle;

  /// No description provided for @nsecWarning.
  ///
  /// In en, this message translates to:
  /// **'Anyone with this key controls your account. Never share it; store it in a password manager.'**
  String get nsecWarning;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @syncNowTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNowTitle;

  /// No description provided for @signInToSyncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync your encrypted calendar.'**
  String get signInToSyncSubtitle;

  /// No description provided for @addRelayToSyncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add at least one relay to synchronize.'**
  String get addRelayToSyncSubtitle;

  /// No description provided for @syncingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncingEllipsis;

  /// No description provided for @synced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get synced;

  /// No description provided for @lastSyncedLabel.
  ///
  /// In en, this message translates to:
  /// **'Last synced {when}'**
  String lastSyncedLabel(String when);

  /// No description provided for @lastSyncFailedLabel.
  ///
  /// In en, this message translates to:
  /// **'Last sync failed: {error}'**
  String lastSyncFailedLabel(String error);

  /// No description provided for @pullMergePublish.
  ///
  /// In en, this message translates to:
  /// **'Pull, merge and publish your events'**
  String get pullMergePublish;

  /// No description provided for @publicRelays.
  ///
  /// In en, this message translates to:
  /// **'Public relays'**
  String get publicRelays;

  /// No description provided for @relaysConfiguredCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 configured} other{{count} configured}}'**
  String relaysConfiguredCount(int count);

  /// No description provided for @addRelay.
  ///
  /// In en, this message translates to:
  /// **'Add relay'**
  String get addRelay;

  /// No description provided for @suggestedRelaysTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggested relays'**
  String get suggestedRelaysTitle;

  /// No description provided for @addOnlyRelaysYouWant.
  ///
  /// In en, this message translates to:
  /// **'Add only the relays you want to use.'**
  String get addOnlyRelaysYouWant;

  /// No description provided for @homeRelayBackup.
  ///
  /// In en, this message translates to:
  /// **'Home relay (backup)'**
  String get homeRelayBackup;

  /// No description provided for @homeRelayNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not configured — an additional personal relay to back up your events'**
  String get homeRelayNotConfigured;

  /// No description provided for @homeRelayDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Home relay'**
  String get homeRelayDialogTitle;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light theme'**
  String get lightTheme;

  /// No description provided for @darkThemeDefault.
  ///
  /// In en, this message translates to:
  /// **'Astraea uses the dark theme by default'**
  String get darkThemeDefault;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @systemLanguage.
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get systemLanguage;

  /// No description provided for @accentColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get accentColorLabel;

  /// No description provided for @accentNavy.
  ///
  /// In en, this message translates to:
  /// **'Navy blue'**
  String get accentNavy;

  /// No description provided for @accentBitcoin.
  ///
  /// In en, this message translates to:
  /// **'Bitcoin orange'**
  String get accentBitcoin;

  /// No description provided for @accentNostr.
  ///
  /// In en, this message translates to:
  /// **'Nostr purple'**
  String get accentNostr;

  /// No description provided for @exportEvents.
  ///
  /// In en, this message translates to:
  /// **'Export events'**
  String get exportEvents;

  /// No description provided for @exportEventsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save a .ics file — optionally password-encrypted'**
  String get exportEventsSubtitle;

  /// No description provided for @importEvents.
  ///
  /// In en, this message translates to:
  /// **'Import events'**
  String get importEvents;

  /// No description provided for @importEventsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'From a .ics file or an encrypted Astraea export'**
  String get importEventsSubtitle;

  /// No description provided for @encryptExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Encrypt this export?'**
  String get encryptExportTitle;

  /// No description provided for @encryptExportBody.
  ///
  /// In en, this message translates to:
  /// **'A plain .ics can be opened by any calendar app — and by anyone who gets the file. Set a password to encrypt it (only Astraea will be able to import it back).'**
  String get encryptExportBody;

  /// No description provided for @exportPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password (leave empty for a plain .ics)'**
  String get exportPasswordLabel;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @encryptedExportSaved.
  ///
  /// In en, this message translates to:
  /// **'Encrypted export saved.'**
  String get encryptedExportSaved;

  /// No description provided for @exportSaved.
  ///
  /// In en, this message translates to:
  /// **'Export saved.'**
  String get exportSaved;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// No description provided for @couldNotReadSelectedFile.
  ///
  /// In en, this message translates to:
  /// **'Could not read the selected file.'**
  String get couldNotReadSelectedFile;

  /// No description provided for @selectedFileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The selected file is larger than 10 MB.'**
  String get selectedFileTooLarge;

  /// No description provided for @importedEventCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Imported 1 event.} other{Imported {count} events.}}'**
  String importedEventCount(int count);

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String importFailed(String error);

  /// No description provided for @thisExportIsEncrypted.
  ///
  /// In en, this message translates to:
  /// **'This export is encrypted'**
  String get thisExportIsEncrypted;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password.'**
  String get wrongPassword;

  /// No description provided for @invalidEncryptedExport.
  ///
  /// In en, this message translates to:
  /// **'This encrypted export is not valid.'**
  String get invalidEncryptedExport;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @scheduleLocalNotifications.
  ///
  /// In en, this message translates to:
  /// **'Schedule local notifications for event reminders'**
  String get scheduleLocalNotifications;

  /// No description provided for @timezone.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get timezone;

  /// No description provided for @followDeviceTimezoneWithName.
  ///
  /// In en, this message translates to:
  /// **'Follow device timezone ({zone})'**
  String followDeviceTimezoneWithName(String zone);

  /// No description provided for @supportAstraea.
  ///
  /// In en, this message translates to:
  /// **'Support Astraea'**
  String get supportAstraea;

  /// No description provided for @noLightningWalletFound.
  ///
  /// In en, this message translates to:
  /// **'No Lightning wallet found — address copied: {address}'**
  String noLightningWalletFound(String address);

  /// No description provided for @desktopServiceUnreachableTitle.
  ///
  /// In en, this message translates to:
  /// **'Astraea background service unavailable'**
  String get desktopServiceUnreachableTitle;

  /// No description provided for @desktopServiceUnreachableBody.
  ///
  /// In en, this message translates to:
  /// **'The desktop app talks to astraea-service over D-Bus for storage, sync and notifications, and it could not be reached. If you are running from source, install it with:\n\n./scripts/install-dev.sh'**
  String get desktopServiceUnreachableBody;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @calendarsLabel.
  ///
  /// In en, this message translates to:
  /// **'Calendars'**
  String get calendarsLabel;

  /// No description provided for @calendarsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Calendars unavailable: {error}'**
  String calendarsUnavailable(String error);

  /// No description provided for @serviceUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Service unreachable'**
  String get serviceUnreachable;

  /// No description provided for @syncStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Sync: {status}'**
  String syncStatusLabel(String status);

  /// No description provided for @syncPendingSuffix.
  ///
  /// In en, this message translates to:
  /// **' ({count} pending)'**
  String syncPendingSuffix(int count);

  /// No description provided for @localOnlyMode.
  ///
  /// In en, this message translates to:
  /// **'Local-only mode (no Nostr identity)'**
  String get localOnlyMode;

  /// No description provided for @syncStarted.
  ///
  /// In en, this message translates to:
  /// **'Sync started'**
  String get syncStarted;

  /// No description provided for @syncUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sync unavailable: {error}'**
  String syncUnavailable(String error);

  /// No description provided for @notSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get notSignedIn;

  /// No description provided for @signInWithBrowserSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your browser (NIP-07) to sync this calendar over Nostr.'**
  String get signInWithBrowserSubtitle;

  /// No description provided for @signedInBackgroundSigning.
  ///
  /// In en, this message translates to:
  /// **'Signed in — background signing via a delegated key'**
  String get signedInBackgroundSigning;

  /// No description provided for @signedInRemoteSigner.
  ///
  /// In en, this message translates to:
  /// **'Signed in — remote signer (NIP-46)'**
  String get signedInRemoteSigner;

  /// No description provided for @signedInNoBackgroundSigner.
  ///
  /// In en, this message translates to:
  /// **'Signed in, but no background signer is configured — sync stays parked. Run \"astraea-service auth provision-key\" in a terminal.'**
  String get signedInNoBackgroundSigner;

  /// No description provided for @couldNotStartLogin.
  ///
  /// In en, this message translates to:
  /// **'Could not start login: {error}'**
  String couldNotStartLogin(String error);

  /// No description provided for @signOutConfirmDesktopBody.
  ///
  /// In en, this message translates to:
  /// **'This forgets the account on this device only — your events stay on the relays. A provisioned signing key, if any, is removed from the keyring.'**
  String get signOutConfirmDesktopBody;

  /// No description provided for @signInWithBrowserTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your browser'**
  String get signInWithBrowserTitle;

  /// No description provided for @loginSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'This login session expired. Try again.'**
  String get loginSessionExpired;

  /// No description provided for @loginWaitingBody.
  ///
  /// In en, this message translates to:
  /// **'A browser tab was opened to confirm your Nostr identity (NIP-07). Approve it there — this dialog closes automatically. Your private key is never requested.'**
  String get loginWaitingBody;

  /// No description provided for @openAgain.
  ///
  /// In en, this message translates to:
  /// **'Open again'**
  String get openAgain;

  /// No description provided for @offlineWillRetry.
  ///
  /// In en, this message translates to:
  /// **'Offline — will retry automatically.'**
  String get offlineWillRetry;

  /// No description provided for @upToDate.
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get upToDate;

  /// No description provided for @operationsFailingCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 operation failing} other{{count} operations failing}}'**
  String operationsFailingCount(int count);

  /// No description provided for @pendingCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 pending} other{{count} pending}}'**
  String pendingCount(int count);

  /// No description provided for @pendingFailingCount.
  ///
  /// In en, this message translates to:
  /// **'{pending}, {failing}'**
  String pendingFailingCount(String pending, String failing);

  /// No description provided for @relayStatus.
  ///
  /// In en, this message translates to:
  /// **'Relay status'**
  String get relayStatus;

  /// No description provided for @relaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Relays'**
  String get relaysLabel;

  /// No description provided for @relaysConfiguredLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 configured} other{{count} configured}}'**
  String relaysConfiguredLabel(int count);

  /// No description provided for @unencryptedTransport.
  ///
  /// In en, this message translates to:
  /// **'Unencrypted transport'**
  String get unencryptedTransport;

  /// No description provided for @couldNotReachService.
  ///
  /// In en, this message translates to:
  /// **'Could not reach astraea-service: {error}'**
  String couldNotReachService(String error);

  /// No description provided for @inviteSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendees'**
  String get inviteSectionTitle;

  /// No description provided for @inviteButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get inviteButtonLabel;

  /// No description provided for @noAttendeesYet.
  ///
  /// In en, this message translates to:
  /// **'No one invited yet'**
  String get noAttendeesYet;

  /// No description provided for @inviteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite someone'**
  String get inviteDialogTitle;

  /// No description provided for @inviteDialogHint.
  ///
  /// In en, this message translates to:
  /// **'npub, name@domain, or public key'**
  String get inviteDialogHint;

  /// No description provided for @resolvePersonFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not resolve that person: {error}'**
  String resolvePersonFailed(String error);

  /// No description provided for @confirmNip05Title.
  ///
  /// In en, this message translates to:
  /// **'Confirm recipient'**
  String get confirmNip05Title;

  /// No description provided for @confirmNip05Body.
  ///
  /// In en, this message translates to:
  /// **'{query} resolved to {pubkey} via NIP-05. This mapping is controlled by the domain — make sure it\'s who you expect.'**
  String confirmNip05Body(String query, String pubkey);

  /// No description provided for @attendeeStatusInvited.
  ///
  /// In en, this message translates to:
  /// **'Invited'**
  String get attendeeStatusInvited;

  /// No description provided for @attendeeStatusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get attendeeStatusAccepted;

  /// No description provided for @attendeeStatusDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get attendeeStatusDeclined;

  /// No description provided for @inviteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send the invite: {error}'**
  String inviteFailed(String error);

  /// No description provided for @pendingInvitationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Invitations'**
  String get pendingInvitationsTooltip;

  /// No description provided for @pendingInvitationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Invitations'**
  String get pendingInvitationsTitle;

  /// No description provided for @pendingInvitationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No pending invitations'**
  String get pendingInvitationsEmpty;

  /// No description provided for @invitationFromLabel.
  ///
  /// In en, this message translates to:
  /// **'From {pubkey}'**
  String invitationFromLabel(String pubkey);

  /// No description provided for @acceptInvitation.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptInvitation;

  /// No description provided for @declineInvitation.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get declineInvitation;

  /// No description provided for @respondToInvitationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not respond: {error}'**
  String respondToInvitationFailed(String error);

  /// No description provided for @invitationAccepted.
  ///
  /// In en, this message translates to:
  /// **'Invitation accepted'**
  String get invitationAccepted;

  /// No description provided for @invitationDeclined.
  ///
  /// In en, this message translates to:
  /// **'Invitation declined'**
  String get invitationDeclined;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'bg',
    'cs',
    'da',
    'de',
    'el',
    'en',
    'es',
    'et',
    'fi',
    'fr',
    'ga',
    'hr',
    'hu',
    'it',
    'ja',
    'lt',
    'lv',
    'mt',
    'nl',
    'pl',
    'pt',
    'ro',
    'ru',
    'sk',
    'sl',
    'sv',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bg':
      return AppLocalizationsBg();
    case 'cs':
      return AppLocalizationsCs();
    case 'da':
      return AppLocalizationsDa();
    case 'de':
      return AppLocalizationsDe();
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'et':
      return AppLocalizationsEt();
    case 'fi':
      return AppLocalizationsFi();
    case 'fr':
      return AppLocalizationsFr();
    case 'ga':
      return AppLocalizationsGa();
    case 'hr':
      return AppLocalizationsHr();
    case 'hu':
      return AppLocalizationsHu();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'lt':
      return AppLocalizationsLt();
    case 'lv':
      return AppLocalizationsLv();
    case 'mt':
      return AppLocalizationsMt();
    case 'nl':
      return AppLocalizationsNl();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ro':
      return AppLocalizationsRo();
    case 'ru':
      return AppLocalizationsRu();
    case 'sk':
      return AppLocalizationsSk();
    case 'sl':
      return AppLocalizationsSl();
    case 'sv':
      return AppLocalizationsSv();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
