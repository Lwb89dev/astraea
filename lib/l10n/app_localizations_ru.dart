// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Astraea';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get delete => 'Удалить';

  @override
  String get continueLabel => 'Продолжить';

  @override
  String get next => 'Далее';

  @override
  String get back => 'Назад';

  @override
  String get loading => 'Загрузка…';

  @override
  String get settingsTooltip => 'Настройки';

  @override
  String get newEventButton => 'Новое событие';

  @override
  String couldNotLoadEvents(String error) {
    return 'Не удалось загрузить события:\n$error';
  }

  @override
  String get viewMonth => 'Месяц';

  @override
  String get viewWeek => 'Неделя';

  @override
  String get viewDay => 'День';

  @override
  String get viewList => 'Список';

  @override
  String get noEventsToday => 'В этот день событий нет.';

  @override
  String get noUpcomingEvents => 'В ближайшие 60 дней предстоящих событий нет.';

  @override
  String get untitledEvent => '(без названия)';

  @override
  String get allDay => 'Весь день';

  @override
  String get addAccountToSyncTooltip =>
      'Добавить учётную запись Nostr для синхронизации';

  @override
  String get syncNowTooltip => 'Синхронизировать сейчас';

  @override
  String get addNostrAccountTitle => 'Добавить учётную запись Nostr';

  @override
  String get eventNotFound => 'Событие не найдено.';

  @override
  String get eventAppBarTitle => 'Событие';

  @override
  String get editTooltip => 'Изменить';

  @override
  String get deleteTooltip => 'Удалить';

  @override
  String allDayLabel(String date) {
    return '$date · Весь день';
  }

  @override
  String recurrenceUntilLabel(String recurrence, String date) {
    return '$recurrence · до $date';
  }

  @override
  String get syncedToRelays => 'Синхронизировано с реле';

  @override
  String get notYetSynced => 'Ещё не синхронизировано';

  @override
  String get deleteEventTitle => 'Удалить событие?';

  @override
  String get deleteEventBody =>
      'Это удалит событие с этого устройства и запросит удаление с реле.';

  @override
  String get editEventTitle => 'Изменить событие';

  @override
  String get newEventTitle => 'Новое событие';

  @override
  String get fieldTitle => 'Название';

  @override
  String get allDaySwitch => 'Весь день';

  @override
  String get startsLabel => 'Начало';

  @override
  String get endsLabel => 'Конец';

  @override
  String get timezoneLabel => 'Часовой пояс';

  @override
  String get repeatsLabel => 'Повтор';

  @override
  String get untilLabel => 'До';

  @override
  String get foreverLabel => 'Навсегда';

  @override
  String get remindersLabel => 'Напоминания';

  @override
  String get addChip => 'Добавить';

  @override
  String get colorLabel => 'Цвет';

  @override
  String get locationLabel => 'Место';

  @override
  String get descriptionLabel => 'Описание';

  @override
  String couldNotSaveEvent(String error) {
    return 'Не удалось сохранить событие: $error';
  }

  @override
  String get recurrenceNone => 'Не повторяется';

  @override
  String get recurrenceDaily => 'Ежедневно';

  @override
  String get recurrenceWeekly => 'Еженедельно';

  @override
  String get recurrenceMonthly => 'Ежемесячно';

  @override
  String get recurrenceYearly => 'Ежегодно';

  @override
  String get reminderAtStart => 'В начале';

  @override
  String reminderMinutesBefore(int count) {
    return 'за $count мин.';
  }

  @override
  String reminderHoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'за $count часа',
      many: 'за $count часов',
      few: 'за $count часа',
      one: 'за 1 час',
    );
    return '$_temp0';
  }

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'за $count дня',
      many: 'за $count дней',
      few: 'за $count дня',
      one: 'за 1 день',
    );
    return '$_temp0';
  }

  @override
  String get getStarted => 'Начать';

  @override
  String get useOffline => 'Работать офлайн';

  @override
  String get welcomeTitle => 'Добро пожаловать в Astraea';

  @override
  String get welcomeSubtitle =>
      'Приватный, ориентированный на офлайн-работу календарь, оставляющий контроль вам.';

  @override
  String get featureLocalTitle => 'Ваш календарь остаётся на вашем устройстве';

  @override
  String get featureLocalBody =>
      'Создавайте события, повторения и напоминания без учётной записи и интернет-соединения.';

  @override
  String get featureSyncTitle => 'Необязательная синхронизация через Nostr';

  @override
  String get featureSyncBody =>
      'Подключите учётную запись, чтобы создать резервную копию календаря и использовать его на нескольких устройствах через выбранные вами реле.';

  @override
  String get featureEncryptedTitle => 'Всегда зашифровано перед отправкой';

  @override
  String get featureEncryptedBody =>
      'Содержимое календаря шифруется сквозным шифрованием, прежде чем покинуть это устройство. Операторы реле не могут его прочитать.';

  @override
  String get featureAmberTitle => 'Храните ключ в Amber';

  @override
  String get featureAmberBody =>
      'На Android внешний подписант может одобрять доступ, не раскрывая ваш приватный ключ Astraea.';

  @override
  String get featureRemindersTitle => 'Приватные локальные напоминания';

  @override
  String get featureRemindersBody =>
      'Уведомления планируются вашим устройством и не зависят от облачного сервиса календаря.';

  @override
  String get connectNostrAccountTitle => 'Подключить учётную запись Nostr';

  @override
  String get connectNostrAccountBody =>
      'Это необходимо только для зашифрованной синхронизации. Astraea также можно использовать полностью офлайн.';

  @override
  String get chooseRelaysTitle => 'Выберите реле для синхронизации';

  @override
  String get chooseRelaysBody =>
      'Реле хранят ваш зашифрованный календарь и делают его доступным на других ваших устройствах. Добавьте одно или несколько или оставьте список пустым и настройте позже.';

  @override
  String couldNotLoadRelaySettings(String error) {
    return 'Не удалось загрузить настройки реле: $error';
  }

  @override
  String get suggestedRelays => 'Предлагаемые';

  @override
  String get addRelayTooltip => 'Добавить реле';

  @override
  String get customRelayLabel => 'Своё реле';

  @override
  String get customRelayHint => 'wss://relay.example.com';

  @override
  String get selectedRelays => 'Выбранные';

  @override
  String get removeRelayTooltip => 'Удалить реле';

  @override
  String get invalidRelayUrl =>
      'Введите корректный адрес wss:// (или ws:// для приватного реле).';

  @override
  String get insecureRelayWarning =>
      'ws:// не шифруется при передаче — используйте его только для реле, которому вы доверяете.';

  @override
  String get nostrAccountConnected => 'Учётная запись Nostr подключена';

  @override
  String get invalidPrivateKey =>
      'Этот приватный ключ недействителен. Проверьте его и попробуйте снова.';

  @override
  String couldNotSignIn(String error) {
    return 'Не удалось войти: $error';
  }

  @override
  String get signInWithAmber => 'Войти через Amber';

  @override
  String get createNewAccount => 'Создать новую учётную запись';

  @override
  String get generatedAccountWarning =>
      'Сгенерированную учётную запись можно восстановить только с помощью её приватного ключа. Сделайте резервную копию в Настройках после настройки.';

  @override
  String get importExistingKey => 'Импортировать существующий ключ';

  @override
  String get privateKeyFieldLabel =>
      'nsec или шестнадцатеричный приватный ключ';

  @override
  String get importButton => 'Импортировать';

  @override
  String get followDeviceTimezone => 'Использовать часовой пояс устройства';

  @override
  String get searchCityRegion => 'Поиск города или региона';

  @override
  String get noMatchingTimezone => 'Нет подходящего часового пояса.';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String couldNotLoadSettings(String error) {
    return 'Не удалось загрузить настройки:\n$error';
  }

  @override
  String get sectionAccount => 'Учётная запись';

  @override
  String get sectionSync => 'Синхронизация';

  @override
  String get sectionRelays => 'Реле';

  @override
  String get sectionAppearance => 'Внешний вид';

  @override
  String get sectionData => 'Данные';

  @override
  String get sectionRemindersTimezone => 'Напоминания и часовой пояс';

  @override
  String get sectionSupport => 'Поддержка';

  @override
  String somethingWentWrong(String error) {
    return 'Что-то пошло не так: $error';
  }

  @override
  String get offlineNoAccount => 'Офлайн — нет учётной записи';

  @override
  String get signInToSyncAcrossDevices =>
      'Войдите, чтобы синхронизировать зашифрованный календарь между устройствами.';

  @override
  String get signIn => 'Войти';

  @override
  String get signedInWithAmber => 'Вход выполнен через Amber';

  @override
  String get signedIn => 'Вход выполнен';

  @override
  String get signOut => 'Выйти';

  @override
  String get backUpPrivateKey => 'Резервная копия приватного ключа';

  @override
  String get revealNsecSubtitle =>
      'Показать nsec, чтобы сохранить его в надёжном месте';

  @override
  String get signOutTitle => 'Выйти из учётной записи?';

  @override
  String get signOutBody =>
      'Ваши события остаются на этом устройстве и на реле. Убедитесь, что вы сделали резервную копию приватного ключа — без него сгенерированную учётную запись восстановить нельзя.';

  @override
  String get noPrivateKeyStored =>
      'Для этого сеанса не сохранён приватный ключ.';

  @override
  String get yourPrivateKeyTitle => 'Ваш приватный ключ (nsec)';

  @override
  String get nsecWarning =>
      'Любой, у кого есть этот ключ, контролирует вашу учётную запись. Никогда не передавайте его; храните его в менеджере паролей.';

  @override
  String get copy => 'Копировать';

  @override
  String get done => 'Готово';

  @override
  String get syncNowTitle => 'Синхронизировать сейчас';

  @override
  String get signInToSyncSubtitle =>
      'Войдите, чтобы синхронизировать зашифрованный календарь.';

  @override
  String get addRelayToSyncSubtitle =>
      'Добавьте хотя бы одно реле для синхронизации.';

  @override
  String get syncingEllipsis => 'Синхронизация…';

  @override
  String get synced => 'Синхронизировано';

  @override
  String lastSyncedLabel(String when) {
    return 'Последняя синхронизация $when';
  }

  @override
  String lastSyncFailedLabel(String error) {
    return 'Последняя синхронизация не удалась: $error';
  }

  @override
  String get pullMergePublish =>
      'Получает, объединяет и публикует ваши события';

  @override
  String get publicRelays => 'Публичные реле';

  @override
  String relaysConfiguredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'настроено $count',
      many: 'настроено $count',
      few: 'настроено $count',
      one: 'настроено 1',
    );
    return '$_temp0';
  }

  @override
  String get addRelay => 'Добавить реле';

  @override
  String get suggestedRelaysTitle => 'Рекомендуемые реле';

  @override
  String get addOnlyRelaysYouWant =>
      'Добавляйте только те реле, которые хотите использовать.';

  @override
  String get homeRelayBackup => 'Личное реле (резервная копия)';

  @override
  String get homeRelayNotConfigured =>
      'Не настроено — дополнительное личное реле для резервного копирования ваших событий';

  @override
  String get homeRelayDialogTitle => 'Личное реле';

  @override
  String get lightTheme => 'Светлая тема';

  @override
  String get darkThemeDefault => 'Astraea по умолчанию использует тёмную тему';

  @override
  String get languageLabel => 'Язык';

  @override
  String get systemLanguage => 'Язык системы';

  @override
  String get exportEvents => 'Экспорт событий';

  @override
  String get exportEventsSubtitle =>
      'Сохранить файл .ics — по желанию защищённый паролем';

  @override
  String get importEvents => 'Импорт событий';

  @override
  String get importEventsSubtitle =>
      'Из файла .ics или зашифрованного экспорта Astraea';

  @override
  String get encryptExportTitle => 'Зашифровать этот экспорт?';

  @override
  String get encryptExportBody =>
      'Обычный файл .ics может открыть любое приложение календаря — и любой, кто его получит. Задайте пароль, чтобы зашифровать его (только Astraea сможет импортировать его обратно).';

  @override
  String get exportPasswordLabel =>
      'Пароль (оставьте пустым для обычного .ics)';

  @override
  String get export => 'Экспортировать';

  @override
  String get encryptedExportSaved => 'Зашифрованный экспорт сохранён.';

  @override
  String get exportSaved => 'Экспорт сохранён.';

  @override
  String exportFailed(String error) {
    return 'Экспорт не удался: $error';
  }

  @override
  String get couldNotReadSelectedFile => 'Не удалось прочитать выбранный файл.';

  @override
  String get selectedFileTooLarge => 'Выбранный файл превышает 10 МБ.';

  @override
  String importedEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Импортировано $count события.',
      many: 'Импортировано $count событий.',
      few: 'Импортировано $count события.',
      one: 'Импортировано $count событие.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(String error) {
    return 'Импорт не удался: $error';
  }

  @override
  String get thisExportIsEncrypted => 'Этот экспорт зашифрован';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get wrongPassword => 'Неверный пароль.';

  @override
  String get invalidEncryptedExport =>
      'Этот зашифрованный экспорт недействителен.';

  @override
  String get reminders => 'Напоминания';

  @override
  String get scheduleLocalNotifications =>
      'Планировать локальные уведомления для напоминаний о событиях';

  @override
  String get timezone => 'Часовой пояс';

  @override
  String followDeviceTimezoneWithName(String zone) {
    return 'Использовать часовой пояс устройства ($zone)';
  }

  @override
  String get supportAstraea => 'Поддержать Astraea';

  @override
  String noLightningWalletFound(String address) {
    return 'Кошелёк Lightning не найден — адрес скопирован: $address';
  }

  @override
  String get desktopServiceUnreachableTitle =>
      'Фоновая служба Astraea недоступна';

  @override
  String get desktopServiceUnreachableBody =>
      'Настольное приложение взаимодействует со службой astraea-service через D-Bus для хранения, синхронизации и уведомлений, но связаться с ней не удалось. Если вы запускаете её из исходного кода, установите её с помощью:\n\n./scripts/install-dev.sh';

  @override
  String get retry => 'Повторить';

  @override
  String get calendarsLabel => 'Календари';

  @override
  String calendarsUnavailable(String error) {
    return 'Календари недоступны: $error';
  }

  @override
  String get serviceUnreachable => 'Служба недоступна';

  @override
  String syncStatusLabel(String status) {
    return 'Синхронизация: $status';
  }

  @override
  String syncPendingSuffix(int count) {
    return ' (в ожидании: $count)';
  }

  @override
  String get localOnlyMode => 'Только локальный режим (без идентичности Nostr)';

  @override
  String get syncStarted => 'Синхронизация запущена';

  @override
  String syncUnavailable(String error) {
    return 'Синхронизация недоступна: $error';
  }

  @override
  String get notSignedIn => 'Вход не выполнен';

  @override
  String get signInWithBrowserSubtitle =>
      'Войдите через браузер (NIP-07), чтобы синхронизировать этот календарь через Nostr.';

  @override
  String get signedInBackgroundSigning =>
      'Вход выполнен — фоновая подпись с помощью делегированного ключа';

  @override
  String get signedInRemoteSigner =>
      'Вход выполнен — удалённый подписант (NIP-46)';

  @override
  String get signedInNoBackgroundSigner =>
      'Вход выполнен, но фоновый подписант не настроен — синхронизация остаётся приостановленной. Выполните «astraea-service auth provision-key» в терминале.';

  @override
  String couldNotStartLogin(String error) {
    return 'Не удалось начать вход: $error';
  }

  @override
  String get signOutConfirmDesktopBody =>
      'Это удалит учётную запись только на этом устройстве — ваши события останутся на реле. Любой предоставленный ключ подписи удаляется из связки ключей.';

  @override
  String get signInWithBrowserTitle => 'Войдите через браузер';

  @override
  String get loginSessionExpired => 'Этот сеанс входа истёк. Попробуйте снова.';

  @override
  String get loginWaitingBody =>
      'Открыта вкладка браузера для подтверждения вашей идентичности Nostr (NIP-07). Подтвердите её там — это диалоговое окно закроется автоматически. Ваш приватный ключ никогда не запрашивается.';

  @override
  String get openAgain => 'Открыть снова';

  @override
  String get offlineWillRetry =>
      'Офлайн — попытка будет повторена автоматически.';

  @override
  String get upToDate => 'Актуально';

  @override
  String operationsFailingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count неудачной операции',
      many: '$count неудачных операций',
      few: '$count неудачные операции',
      one: '$count неудачная операция',
    );
    return '$_temp0';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count в ожидании',
      many: '$count в ожидании',
      few: '$count в ожидании',
      one: '$count в ожидании',
    );
    return '$_temp0';
  }

  @override
  String pendingFailingCount(String pending, String failing) {
    return '$pending, $failing';
  }

  @override
  String get relayStatus => 'Статус реле';

  @override
  String get relaysLabel => 'Реле';

  @override
  String relaysConfiguredLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'настроено $count',
      many: 'настроено $count',
      few: 'настроено $count',
      one: 'настроено $count',
    );
    return '$_temp0';
  }

  @override
  String get unencryptedTransport => 'Незашифрованная передача';

  @override
  String couldNotReachService(String error) {
    return 'Не удалось связаться со службой astraea-service: $error';
  }

  @override
  String get inviteSectionTitle => 'Участники';

  @override
  String get inviteButtonLabel => 'Пригласить';

  @override
  String get noAttendeesYet => 'Пока никто не приглашён';

  @override
  String get inviteDialogTitle => 'Пригласить кого-то';

  @override
  String get inviteDialogHint => 'npub, имя@домен или публичный ключ';

  @override
  String resolvePersonFailed(String error) {
    return 'Не удалось найти этого человека: $error';
  }

  @override
  String get confirmNip05Title => 'Подтвердите получателя';

  @override
  String confirmNip05Body(String query, String pubkey) {
    return '$query был сопоставлен с $pubkey через NIP-05. Это сопоставление контролируется доменом — убедитесь, что это ожидаемый человек.';
  }

  @override
  String get attendeeStatusInvited => 'Приглашён';

  @override
  String get attendeeStatusAccepted => 'Принято';

  @override
  String get attendeeStatusDeclined => 'Отклонено';

  @override
  String inviteFailed(String error) {
    return 'Не удалось отправить приглашение: $error';
  }

  @override
  String get pendingInvitationsTooltip => 'Приглашения';

  @override
  String get pendingInvitationsTitle => 'Приглашения';

  @override
  String get pendingInvitationsEmpty => 'Нет ожидающих приглашений';

  @override
  String invitationFromLabel(String pubkey) {
    return 'От $pubkey';
  }

  @override
  String get acceptInvitation => 'Принять';

  @override
  String get declineInvitation => 'Отклонить';

  @override
  String respondToInvitationFailed(String error) {
    return 'Не удалось отправить ответ: $error';
  }

  @override
  String get invitationAccepted => 'Приглашение принято';

  @override
  String get invitationDeclined => 'Приглашение отклонено';
}
