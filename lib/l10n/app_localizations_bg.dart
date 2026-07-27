// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bulgarian (`bg`).
class AppLocalizationsBg extends AppLocalizations {
  AppLocalizationsBg([String locale = 'bg']) : super(locale);

  @override
  String get appTitle => 'Astraea';

  @override
  String get cancel => 'Отказ';

  @override
  String get save => 'Запиши';

  @override
  String get delete => 'Изтрий';

  @override
  String get continueLabel => 'Продължи';

  @override
  String get next => 'Напред';

  @override
  String get back => 'Назад';

  @override
  String get loading => 'Зареждане…';

  @override
  String get settingsTooltip => 'Настройки';

  @override
  String get newEventButton => 'Ново събитие';

  @override
  String couldNotLoadEvents(String error) {
    return 'Събитията не можаха да се заредят:\n$error';
  }

  @override
  String get viewMonth => 'Месец';

  @override
  String get viewWeek => 'Седмица';

  @override
  String get viewDay => 'Ден';

  @override
  String get viewList => 'Списък';

  @override
  String get noEventsToday => 'Няма събития този ден.';

  @override
  String get noUpcomingEvents =>
      'Няма предстоящи събития през следващите 60 дни.';

  @override
  String get untitledEvent => '(без заглавие)';

  @override
  String get allDay => 'Цял ден';

  @override
  String get addAccountToSyncTooltip =>
      'Добавяне на Nostr акаунт за синхронизиране';

  @override
  String get syncNowTooltip => 'Синхронизирай сега';

  @override
  String get addNostrAccountTitle => 'Добавяне на Nostr акаунт';

  @override
  String get eventNotFound => 'Събитието не е намерено.';

  @override
  String get eventAppBarTitle => 'Събитие';

  @override
  String get editTooltip => 'Редактирай';

  @override
  String get deleteTooltip => 'Изтрий';

  @override
  String allDayLabel(String date) {
    return '$date · Цял ден';
  }

  @override
  String recurrenceUntilLabel(String recurrence, String date) {
    return '$recurrence · до $date';
  }

  @override
  String get syncedToRelays => 'Синхронизирано с релетата';

  @override
  String get notYetSynced => 'Все още не е синхронизирано';

  @override
  String get deleteEventTitle => 'Да се изтрие ли събитието?';

  @override
  String get deleteEventBody =>
      'Това премахва събитието от това устройство и заявява изтриване от релетата.';

  @override
  String get editEventTitle => 'Редактиране на събитие';

  @override
  String get newEventTitle => 'Ново събитие';

  @override
  String get fieldTitle => 'Заглавие';

  @override
  String get allDaySwitch => 'Цял ден';

  @override
  String get startsLabel => 'Начало';

  @override
  String get endsLabel => 'Край';

  @override
  String get timezoneLabel => 'Часова зона';

  @override
  String get repeatsLabel => 'Повторение';

  @override
  String get untilLabel => 'До';

  @override
  String get foreverLabel => 'Завинаги';

  @override
  String get remindersLabel => 'Напомняния';

  @override
  String get addChip => 'Добави';

  @override
  String get colorLabel => 'Цвят';

  @override
  String get locationLabel => 'Местоположение';

  @override
  String get descriptionLabel => 'Описание';

  @override
  String couldNotSaveEvent(String error) {
    return 'Събитието не можа да се запази: $error';
  }

  @override
  String get recurrenceNone => 'Не се повтаря';

  @override
  String get recurrenceDaily => 'Всеки ден';

  @override
  String get recurrenceWeekly => 'Всяка седмица';

  @override
  String get recurrenceMonthly => 'Всеки месец';

  @override
  String get recurrenceYearly => 'Всяка година';

  @override
  String get reminderAtStart => 'В началото';

  @override
  String reminderMinutesBefore(int count) {
    return '$count мин. преди';
  }

  @override
  String reminderHoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count часа преди',
      one: '1 час преди',
    );
    return '$_temp0';
  }

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дни преди',
      one: '1 ден преди',
    );
    return '$_temp0';
  }

  @override
  String get getStarted => 'Начало';

  @override
  String get useOffline => 'Използвай офлайн';

  @override
  String get welcomeTitle => 'Добре дошли в Astraea';

  @override
  String get welcomeSubtitle =>
      'Личен, офлайн-първо календар, който оставя контрола на вас.';

  @override
  String get featureLocalTitle => 'Календарът ви остава на устройството ви';

  @override
  String get featureLocalBody =>
      'Създавайте събития, повторения и напомняния без акаунт или интернет връзка.';

  @override
  String get featureSyncTitle => 'Незадължителна синхронизация чрез Nostr';

  @override
  String get featureSyncBody =>
      'Свържете акаунт, за да архивирате календара си и да го използвате на няколко устройства чрез избрани от вас релета.';

  @override
  String get featureEncryptedTitle => 'Винаги криптирано преди качване';

  @override
  String get featureEncryptedBody =>
      'Съдържанието на календара се криптира от край до край, преди да напусне това устройство. Операторите на релета не могат да го четат.';

  @override
  String get featureAmberTitle => 'Пазете ключа си в Amber';

  @override
  String get featureAmberBody =>
      'На Android външен подписващ може да одобри достъп, без да разкрива личния ви ключ пред Astraea.';

  @override
  String get featureRemindersTitle => 'Лични локални напомняния';

  @override
  String get featureRemindersBody =>
      'Известията се планират от устройството ви и не зависят от облачна услуга за календар.';

  @override
  String get connectNostrAccountTitle => 'Свързване на Nostr акаунт';

  @override
  String get connectNostrAccountBody =>
      'Това е необходимо само за криптирана синхронизация. Можете да използвате Astraea и напълно офлайн.';

  @override
  String get chooseRelaysTitle => 'Изберете релета за синхронизация';

  @override
  String get chooseRelaysBody =>
      'Релетата съхраняват криптирания ви календар и го правят достъпен на другите ви устройства. Добавете едно или повече или оставете списъка празен и го конфигурирайте по-късно.';

  @override
  String couldNotLoadRelaySettings(String error) {
    return 'Настройките на релетата не можаха да се заредят: $error';
  }

  @override
  String get suggestedRelays => 'Предложени';

  @override
  String get addRelayTooltip => 'Добави реле';

  @override
  String get customRelayLabel => 'Персонализирано реле';

  @override
  String get customRelayHint => 'wss://relay.example.com';

  @override
  String get selectedRelays => 'Избрани';

  @override
  String get removeRelayTooltip => 'Премахни реле';

  @override
  String get invalidRelayUrl =>
      'Въведете валиден адрес wss:// (или ws:// за частно реле).';

  @override
  String get insecureRelayWarning =>
      'ws:// не е криптирано при пренос — използвайте го само за реле, на което имате доверие.';

  @override
  String get nostrAccountConnected => 'Nostr акаунтът е свързан';

  @override
  String get invalidPrivateKey =>
      'Този личен ключ не е валиден. Проверете го и опитайте отново.';

  @override
  String couldNotSignIn(String error) {
    return 'Влизането е неуспешно: $error';
  }

  @override
  String get signInWithAmber => 'Вход с Amber';

  @override
  String get createNewAccount => 'Създай нов акаунт';

  @override
  String get generatedAccountWarning =>
      'Генериран акаунт може да бъде възстановен само с личния му ключ. Архивирайте го от Настройки след настройката.';

  @override
  String get importExistingKey => 'Импортирай съществуващ ключ';

  @override
  String get privateKeyFieldLabel => 'nsec или шестнадесетичен личен ключ';

  @override
  String get importButton => 'Импортирай';

  @override
  String get followDeviceTimezone => 'Следвай часовата зона на устройството';

  @override
  String get searchCityRegion => 'Търсене на град или регион';

  @override
  String get noMatchingTimezone => 'Няма съответстваща часова зона.';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String couldNotLoadSettings(String error) {
    return 'Настройките не можаха да се заредят:\n$error';
  }

  @override
  String get sectionAccount => 'Акаунт';

  @override
  String get sectionSync => 'Синхронизация';

  @override
  String get sectionRelays => 'Релета';

  @override
  String get sectionAppearance => 'Външен вид';

  @override
  String get sectionData => 'Данни';

  @override
  String get sectionRemindersTimezone => 'Напомняния и часова зона';

  @override
  String get sectionSupport => 'Поддръжка';

  @override
  String somethingWentWrong(String error) {
    return 'Нещо се обърка: $error';
  }

  @override
  String get offlineNoAccount => 'Офлайн — без акаунт';

  @override
  String get signInToSyncAcrossDevices =>
      'Влезте, за да синхронизирате криптирания си календар между устройства.';

  @override
  String get signIn => 'Вход';

  @override
  String get signedInWithAmber => 'Влезли сте с Amber';

  @override
  String get signedIn => 'Влезли сте';

  @override
  String get signOut => 'Изход';

  @override
  String get backUpPrivateKey => 'Архивиране на личен ключ';

  @override
  String get revealNsecSubtitle =>
      'Покажете своя nsec, за да го запазите на сигурно място';

  @override
  String get signOutTitle => 'Да излезете ли?';

  @override
  String get signOutBody =>
      'Събитията ви остават на това устройство и на релетата. Уверете се, че сте архивирали личния си ключ — без него генериран акаунт не може да бъде възстановен.';

  @override
  String get noPrivateKeyStored => 'Няма запазен личен ключ за тази сесия.';

  @override
  String get yourPrivateKeyTitle => 'Личният ви ключ (nsec)';

  @override
  String get nsecWarning =>
      'Всеки, който притежава този ключ, контролира акаунта ви. Никога не го споделяйте; съхранявайте го в мениджър на пароли.';

  @override
  String get copy => 'Копирай';

  @override
  String get done => 'Готово';

  @override
  String get syncNowTitle => 'Синхронизирай сега';

  @override
  String get signInToSyncSubtitle =>
      'Влезте, за да синхронизирате криптирания си календар.';

  @override
  String get addRelayToSyncSubtitle =>
      'Добавете поне едно реле, за да синхронизирате.';

  @override
  String get syncingEllipsis => 'Синхронизиране…';

  @override
  String get synced => 'Синхронизирано';

  @override
  String lastSyncedLabel(String when) {
    return 'Последно синхронизиране $when';
  }

  @override
  String lastSyncFailedLabel(String error) {
    return 'Последната синхронизация е неуспешна: $error';
  }

  @override
  String get pullMergePublish =>
      'Извлича, обединява и публикува вашите събития';

  @override
  String get publicRelays => 'Публични релета';

  @override
  String relaysConfiguredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count конфигурирани',
      one: '1 конфигурирано',
    );
    return '$_temp0';
  }

  @override
  String get addRelay => 'Добави реле';

  @override
  String get suggestedRelaysTitle => 'Предложени релета';

  @override
  String get addOnlyRelaysYouWant =>
      'Добавяйте само релетата, които искате да използвате.';

  @override
  String get homeRelayBackup => 'Лично реле (архив)';

  @override
  String get homeRelayNotConfigured =>
      'Не е конфигурирано — допълнително лично реле за архивиране на събитията ви';

  @override
  String get homeRelayDialogTitle => 'Лично реле';

  @override
  String get lightTheme => 'Светла тема';

  @override
  String get darkThemeDefault => 'Astraea използва тъмна тема по подразбиране';

  @override
  String get languageLabel => 'Език';

  @override
  String get systemLanguage => 'Системен език';

  @override
  String get exportEvents => 'Експортиране на събития';

  @override
  String get exportEventsSubtitle =>
      'Запазете файл .ics — по избор защитен с парола';

  @override
  String get importEvents => 'Импортиране на събития';

  @override
  String get importEventsSubtitle =>
      'От файл .ics или криптиран експорт на Astraea';

  @override
  String get encryptExportTitle => 'Да се криптира ли този експорт?';

  @override
  String get encryptExportBody =>
      'Обикновен файл .ics може да бъде отворен от всяко приложение за календар — и от всеки, който го получи. Задайте парола, за да го криптирате (само Astraea ще може да го импортира отново).';

  @override
  String get exportPasswordLabel =>
      'Парола (оставете празно за обикновен .ics файл)';

  @override
  String get export => 'Експортирай';

  @override
  String get encryptedExportSaved => 'Криптираният експорт е запазен.';

  @override
  String get exportSaved => 'Експортът е запазен.';

  @override
  String exportFailed(String error) {
    return 'Експортирането е неуспешно: $error';
  }

  @override
  String get couldNotReadSelectedFile =>
      'Избраният файл не можа да бъде прочетен.';

  @override
  String get selectedFileTooLarge => 'Избраният файл надвишава 10 MB.';

  @override
  String importedEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Импортирани са $count събития.',
      one: 'Импортирано е 1 събитие.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(String error) {
    return 'Импортирането е неуспешно: $error';
  }

  @override
  String get thisExportIsEncrypted => 'Този експорт е криптиран';

  @override
  String get passwordLabel => 'Парола';

  @override
  String get wrongPassword => 'Грешна парола.';

  @override
  String get invalidEncryptedExport => 'Този криптиран експорт не е валиден.';

  @override
  String get reminders => 'Напомняния';

  @override
  String get scheduleLocalNotifications =>
      'Планирайте локални известия за напомняния за събития';

  @override
  String get timezone => 'Часова зона';

  @override
  String followDeviceTimezoneWithName(String zone) {
    return 'Следвай часовата зона на устройството ($zone)';
  }

  @override
  String get supportAstraea => 'Подкрепете Astraea';

  @override
  String noLightningWalletFound(String address) {
    return 'Не е намерен Lightning портфейл — адресът е копиран: $address';
  }

  @override
  String get desktopServiceUnreachableTitle =>
      'Фоновата услуга на Astraea не е налична';

  @override
  String get desktopServiceUnreachableBody =>
      'Настолното приложение комуникира с astraea-service чрез D-Bus за съхранение, синхронизация и известия, но не можа да бъде достигнато. Ако го стартирате от изходния код, инсталирайте го с:\n\n./scripts/install-dev.sh';

  @override
  String get retry => 'Опитай отново';

  @override
  String get calendarsLabel => 'Календари';

  @override
  String calendarsUnavailable(String error) {
    return 'Календарите не са налични: $error';
  }

  @override
  String get serviceUnreachable => 'Услугата не е достъпна';

  @override
  String syncStatusLabel(String status) {
    return 'Синхронизация: $status';
  }

  @override
  String syncPendingSuffix(int count) {
    return ' ($count чакащи)';
  }

  @override
  String get localOnlyMode => 'Само локален режим (без Nostr идентичност)';

  @override
  String get syncStarted => 'Синхронизацията е стартирана';

  @override
  String syncUnavailable(String error) {
    return 'Синхронизацията не е налична: $error';
  }

  @override
  String get notSignedIn => 'Не сте влезли';

  @override
  String get signInWithBrowserSubtitle =>
      'Влезте с браузъра си (NIP-07), за да синхронизирате този календар чрез Nostr.';

  @override
  String get signedInBackgroundSigning =>
      'Влезли сте — фоново подписване чрез делегиран ключ';

  @override
  String get signedInRemoteSigner =>
      'Влезли сте — отдалечен подписващ (NIP-46)';

  @override
  String get signedInNoBackgroundSigner =>
      'Влезли сте, но не е конфигуриран фонов подписващ — синхронизацията остава на пауза. Изпълнете „astraea-service auth provision-key“ в терминал.';

  @override
  String couldNotStartLogin(String error) {
    return 'Влизането не можа да се стартира: $error';
  }

  @override
  String get signOutConfirmDesktopBody =>
      'Това забравя акаунта само на това устройство — вашите събития остават на релетата. Всеки предоставен ключ за подпис се премахва от ключодържателя.';

  @override
  String get signInWithBrowserTitle => 'Влезте с браузъра си';

  @override
  String get loginSessionExpired =>
      'Тази сесия за вход е изтекла. Опитайте отново.';

  @override
  String get loginWaitingBody =>
      'Отворен е раздел в браузъра за потвърждаване на вашата Nostr идентичност (NIP-07). Одобрете го там — този диалог се затваря автоматично. Личният ви ключ никога не се изисква.';

  @override
  String get openAgain => 'Отвори отново';

  @override
  String get offlineWillRetry => 'Офлайн — ще опита отново автоматично.';

  @override
  String get upToDate => 'Актуално';

  @override
  String operationsFailingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count неуспешни операции',
      one: '1 неуспешна операция',
    );
    return '$_temp0';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count чакащи',
      one: '1 чакащо',
    );
    return '$_temp0';
  }

  @override
  String pendingFailingCount(String pending, String failing) {
    return '$pending, $failing';
  }

  @override
  String get relayStatus => 'Състояние на релетата';

  @override
  String get relaysLabel => 'Релета';

  @override
  String relaysConfiguredLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count конфигурирани',
      one: '1 конфигурирано',
    );
    return '$_temp0';
  }

  @override
  String get unencryptedTransport => 'Некриптиран пренос';

  @override
  String couldNotReachService(String error) {
    return 'astraea-service не можа да бъде достигнат: $error';
  }

  @override
  String get inviteSectionTitle => 'Участници';

  @override
  String get inviteButtonLabel => 'Покани';

  @override
  String get noAttendeesYet => 'Все още никой не е поканен';

  @override
  String get inviteDialogTitle => 'Покани някого';

  @override
  String get inviteDialogHint => 'npub, име@домейн или публичен ключ';

  @override
  String resolvePersonFailed(String error) {
    return 'Лицето не можа да бъде намерено: $error';
  }

  @override
  String get confirmNip05Title => 'Потвърдете получателя';

  @override
  String confirmNip05Body(String query, String pubkey) {
    return '$query беше преобразувано в $pubkey чрез NIP-05. Това съответствие се контролира от домейна — уверете се, че е лицето, което очаквате.';
  }

  @override
  String get attendeeStatusInvited => 'Поканен';

  @override
  String get attendeeStatusAccepted => 'Приел';

  @override
  String get attendeeStatusDeclined => 'Отказал';

  @override
  String inviteFailed(String error) {
    return 'Поканата не можа да бъде изпратена: $error';
  }

  @override
  String get pendingInvitationsTooltip => 'Покани';

  @override
  String get pendingInvitationsTitle => 'Покани';

  @override
  String get pendingInvitationsEmpty => 'Няма чакащи покани';

  @override
  String invitationFromLabel(String pubkey) {
    return 'От $pubkey';
  }

  @override
  String get acceptInvitation => 'Приемане';

  @override
  String get declineInvitation => 'Отказ';

  @override
  String respondToInvitationFailed(String error) {
    return 'Отговорът не можа да бъде изпратен: $error';
  }

  @override
  String get invitationAccepted => 'Поканата е приета';

  @override
  String get invitationDeclined => 'Поканата е отказана';
}
