// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Astraea';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get continueLabel => '继续';

  @override
  String get next => '下一步';

  @override
  String get back => '返回';

  @override
  String get loading => '加载中…';

  @override
  String get settingsTooltip => '设置';

  @override
  String get newEventButton => '新建事件';

  @override
  String couldNotLoadEvents(String error) {
    return '无法加载事件：\n$error';
  }

  @override
  String get viewMonth => '月';

  @override
  String get viewWeek => '周';

  @override
  String get viewDay => '日';

  @override
  String get viewList => '列表';

  @override
  String get noEventsToday => '这一天没有事件。';

  @override
  String get noUpcomingEvents => '未来 60 天内没有即将到来的事件。';

  @override
  String get untitledEvent => '（无标题）';

  @override
  String get allDay => '全天';

  @override
  String get addAccountToSyncTooltip => '添加 Nostr 账户以进行同步';

  @override
  String get syncNowTooltip => '立即同步';

  @override
  String get addNostrAccountTitle => '添加 Nostr 账户';

  @override
  String get eventNotFound => '未找到事件。';

  @override
  String get eventAppBarTitle => '事件';

  @override
  String get editTooltip => '编辑';

  @override
  String get deleteTooltip => '删除';

  @override
  String allDayLabel(String date) {
    return '$date · 全天';
  }

  @override
  String recurrenceUntilLabel(String recurrence, String date) {
    return '$recurrence · 直到 $date';
  }

  @override
  String get syncedToRelays => '已与中继同步';

  @override
  String get notYetSynced => '尚未同步';

  @override
  String get deleteEventTitle => '删除此事件？';

  @override
  String get deleteEventBody => '这将从此设备中删除该事件，并请求从中继中删除。';

  @override
  String get editEventTitle => '编辑事件';

  @override
  String get newEventTitle => '新建事件';

  @override
  String get fieldTitle => '标题';

  @override
  String get allDaySwitch => '全天';

  @override
  String get startsLabel => '开始';

  @override
  String get endsLabel => '结束';

  @override
  String get timezoneLabel => '时区';

  @override
  String get repeatsLabel => '重复';

  @override
  String get untilLabel => '直到';

  @override
  String get foreverLabel => '永远';

  @override
  String get remindersLabel => '提醒';

  @override
  String get addChip => '添加';

  @override
  String get colorLabel => '颜色';

  @override
  String get locationLabel => '地点';

  @override
  String get descriptionLabel => '描述';

  @override
  String couldNotSaveEvent(String error) {
    return '无法保存事件：$error';
  }

  @override
  String get recurrenceNone => '不重复';

  @override
  String get recurrenceDaily => '每天';

  @override
  String get recurrenceWeekly => '每周';

  @override
  String get recurrenceMonthly => '每月';

  @override
  String get recurrenceYearly => '每年';

  @override
  String get reminderAtStart => '开始时';

  @override
  String reminderMinutesBefore(int count) {
    return '提前 $count 分钟';
  }

  @override
  String reminderHoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '提前 $count 小时',
    );
    return '$_temp0';
  }

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '提前 $count 天',
    );
    return '$_temp0';
  }

  @override
  String get getStarted => '开始使用';

  @override
  String get useOffline => '离线使用';

  @override
  String get welcomeTitle => '欢迎使用 Astraea';

  @override
  String get welcomeSubtitle => '一款以离线优先为原则的私密日历，掌控权始终在你手中。';

  @override
  String get featureLocalTitle => '你的日历保存在你的设备上';

  @override
  String get featureLocalBody => '无需账户或网络连接即可创建事件、重复规则和提醒。';

  @override
  String get featureSyncTitle => '通过 Nostr 进行可选同步';

  @override
  String get featureSyncBody => '连接账户以备份你的日历，并通过你选择的中继在多个设备上使用它。';

  @override
  String get featureEncryptedTitle => '上传前始终加密';

  @override
  String get featureEncryptedBody => '日历内容在离开此设备之前会进行端到端加密。中继运营者无法读取它。';

  @override
  String get featureAmberTitle => '在 Amber 中保存你的密钥';

  @override
  String get featureAmberBody =>
      '在 Android 上，外部签名者可以批准访问权限，而不会向 Astraea 暴露你的私钥。';

  @override
  String get featureRemindersTitle => '私密的本地提醒';

  @override
  String get featureRemindersBody => '通知由你的设备安排，不依赖任何云端日历服务。';

  @override
  String get connectNostrAccountTitle => '连接 Nostr 账户';

  @override
  String get connectNostrAccountBody => '这仅在需要加密同步时才需要。你也可以完全离线使用 Astraea。';

  @override
  String get chooseRelaysTitle => '选择用于同步的中继';

  @override
  String get chooseRelaysBody =>
      '中继存储你的加密日历，并使其在你的其他设备上可用。添加一个或多个，或将列表留空并稍后配置。';

  @override
  String couldNotLoadRelaySettings(String error) {
    return '无法加载中继设置：$error';
  }

  @override
  String get suggestedRelays => '推荐';

  @override
  String get addRelayTooltip => '添加中继';

  @override
  String get customRelayLabel => '自定义中继';

  @override
  String get customRelayHint => 'wss://relay.example.com';

  @override
  String get selectedRelays => '已选择';

  @override
  String get removeRelayTooltip => '移除中继';

  @override
  String get invalidRelayUrl => '请输入有效的 wss:// 地址（或用于私有中继的 ws://）。';

  @override
  String get insecureRelayWarning => 'ws:// 在传输过程中未加密 — 仅将其用于你信任的中继。';

  @override
  String get nostrAccountConnected => 'Nostr 账户已连接';

  @override
  String get invalidPrivateKey => '该私钥无效。请检查后重试。';

  @override
  String couldNotSignIn(String error) {
    return '无法登录：$error';
  }

  @override
  String get signInWithAmber => '使用 Amber 登录';

  @override
  String get createNewAccount => '创建新账户';

  @override
  String get generatedAccountWarning => '生成的账户只能通过其私钥恢复。请在设置完成后从“设置”中备份。';

  @override
  String get importExistingKey => '导入现有密钥';

  @override
  String get privateKeyFieldLabel => 'nsec 或十六进制私钥';

  @override
  String get importButton => '导入';

  @override
  String get followDeviceTimezone => '跟随设备时区';

  @override
  String get searchCityRegion => '搜索城市或地区';

  @override
  String get noMatchingTimezone => '没有匹配的时区。';

  @override
  String get settingsTitle => '设置';

  @override
  String couldNotLoadSettings(String error) {
    return '无法加载设置：\n$error';
  }

  @override
  String get sectionAccount => '账户';

  @override
  String get sectionSync => '同步';

  @override
  String get sectionRelays => '中继';

  @override
  String get sectionAppearance => '外观';

  @override
  String get sectionData => '数据';

  @override
  String get sectionRemindersTimezone => '提醒和时区';

  @override
  String get sectionSupport => '支持';

  @override
  String somethingWentWrong(String error) {
    return '出现了问题：$error';
  }

  @override
  String get offlineNoAccount => '离线 — 无账户';

  @override
  String get signInToSyncAcrossDevices => '登录以在设备间同步你的加密日历。';

  @override
  String get signIn => '登录';

  @override
  String get signedInWithAmber => '已通过 Amber 登录';

  @override
  String get signedIn => '已登录';

  @override
  String get signOut => '退出登录';

  @override
  String get backUpPrivateKey => '备份私钥';

  @override
  String get revealNsecSubtitle => '显示你的 nsec 以将其保存在安全的地方';

  @override
  String get signOutTitle => '退出登录？';

  @override
  String get signOutBody => '你的事件将保留在此设备和中继上。请确保已备份你的私钥 — 没有它，生成的账户将无法恢复。';

  @override
  String get noPrivateKeyStored => '此会话未保存私钥。';

  @override
  String get yourPrivateKeyTitle => '你的私钥（nsec）';

  @override
  String get nsecWarning => '任何拥有此密钥的人都可以控制你的账户。切勿分享；请将其保存在密码管理器中。';

  @override
  String get copy => '复制';

  @override
  String get done => '完成';

  @override
  String get syncNowTitle => '立即同步';

  @override
  String get signInToSyncSubtitle => '登录以同步你的加密日历。';

  @override
  String get addRelayToSyncSubtitle => '至少添加一个中继才能同步。';

  @override
  String get syncingEllipsis => '正在同步…';

  @override
  String get synced => '已同步';

  @override
  String lastSyncedLabel(String when) {
    return '上次同步于 $when';
  }

  @override
  String lastSyncFailedLabel(String error) {
    return '上次同步失败：$error';
  }

  @override
  String get pullMergePublish => '拉取、合并并发布你的事件';

  @override
  String get publicRelays => '公共中继';

  @override
  String relaysConfiguredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已配置 $count 个',
    );
    return '$_temp0';
  }

  @override
  String get addRelay => '添加中继';

  @override
  String get suggestedRelaysTitle => '推荐中继';

  @override
  String get addOnlyRelaysYouWant => '只添加你想使用的中继。';

  @override
  String get homeRelayBackup => '个人中继（备份）';

  @override
  String get homeRelayNotConfigured => '未配置 — 用于备份你的事件的额外个人中继';

  @override
  String get homeRelayDialogTitle => '个人中继';

  @override
  String get lightTheme => '浅色主题';

  @override
  String get darkThemeDefault => 'Astraea 默认使用深色主题';

  @override
  String get languageLabel => '语言';

  @override
  String get systemLanguage => '系统语言';

  @override
  String get exportEvents => '导出事件';

  @override
  String get exportEventsSubtitle => '保存 .ics 文件 — 可选择使用密码保护';

  @override
  String get importEvents => '导入事件';

  @override
  String get importEventsSubtitle => '从 .ics 文件或加密的 Astraea 导出文件导入';

  @override
  String get encryptExportTitle => '加密此导出？';

  @override
  String get encryptExportBody =>
      '任何日历应用都可以打开普通的 .ics 文件 — 任何获取该文件的人也可以。设置密码以加密它（只有 Astraea 才能重新导入它）。';

  @override
  String get exportPasswordLabel => '密码（留空以生成普通 .ics 文件）';

  @override
  String get export => '导出';

  @override
  String get encryptedExportSaved => '加密导出已保存。';

  @override
  String get exportSaved => '导出已保存。';

  @override
  String exportFailed(String error) {
    return '导出失败：$error';
  }

  @override
  String get couldNotReadSelectedFile => '无法读取所选文件。';

  @override
  String get selectedFileTooLarge => '所选文件超过 10 MB。';

  @override
  String importedEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已导入 $count 个事件。',
    );
    return '$_temp0';
  }

  @override
  String importFailed(String error) {
    return '导入失败：$error';
  }

  @override
  String get thisExportIsEncrypted => '此导出已加密';

  @override
  String get passwordLabel => '密码';

  @override
  String get wrongPassword => '密码错误。';

  @override
  String get invalidEncryptedExport => '此加密导出无效。';

  @override
  String get reminders => '提醒';

  @override
  String get scheduleLocalNotifications => '为事件提醒安排本地通知';

  @override
  String get timezone => '时区';

  @override
  String followDeviceTimezoneWithName(String zone) {
    return '跟随设备时区（$zone）';
  }

  @override
  String get supportAstraea => '支持 Astraea';

  @override
  String noLightningWalletFound(String address) {
    return '未找到 Lightning 钱包 — 地址已复制：$address';
  }

  @override
  String get desktopServiceUnreachableTitle => 'Astraea 后台服务不可用';

  @override
  String get desktopServiceUnreachableBody =>
      '桌面应用通过 D-Bus 与 astraea-service 通信以处理存储、同步和通知，但无法连接到它。如果你是从源码运行的，请使用以下命令安装：\n\n./scripts/install-dev.sh';

  @override
  String get retry => '重试';

  @override
  String get calendarsLabel => '日历';

  @override
  String calendarsUnavailable(String error) {
    return '日历不可用：$error';
  }

  @override
  String get serviceUnreachable => '服务不可达';

  @override
  String syncStatusLabel(String status) {
    return '同步：$status';
  }

  @override
  String syncPendingSuffix(int count) {
    return '（$count 个待处理）';
  }

  @override
  String get localOnlyMode => '仅本地模式（无 Nostr 身份）';

  @override
  String get syncStarted => '同步已开始';

  @override
  String syncUnavailable(String error) {
    return '同步不可用：$error';
  }

  @override
  String get notSignedIn => '未登录';

  @override
  String get signInWithBrowserSubtitle => '使用你的浏览器（NIP-07）登录，以通过 Nostr 同步此日历。';

  @override
  String get signedInBackgroundSigning => '已登录 — 通过委托密钥进行后台签名';

  @override
  String get signedInRemoteSigner => '已登录 — 远程签名者（NIP-46）';

  @override
  String get signedInNoBackgroundSigner =>
      '已登录，但未配置后台签名者 — 同步将保持暂停状态。请在终端中运行 “astraea-service auth provision-key”。';

  @override
  String couldNotStartLogin(String error) {
    return '无法开始登录：$error';
  }

  @override
  String get signOutConfirmDesktopBody =>
      '这仅会在此设备上忘记该账户 — 你的事件仍保留在中继上。任何已配置的签名密钥都会从密钥环中移除。';

  @override
  String get signInWithBrowserTitle => '使用你的浏览器登录';

  @override
  String get loginSessionExpired => '此登录会话已过期。请重试。';

  @override
  String get loginWaitingBody =>
      '已打开浏览器标签页以确认你的 Nostr 身份（NIP-07）。请在那里批准 — 此对话框会自动关闭。系统绝不会请求你的私钥。';

  @override
  String get openAgain => '再次打开';

  @override
  String get offlineWillRetry => '离线 — 将自动重试。';

  @override
  String get upToDate => '已是最新';

  @override
  String operationsFailingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个操作失败',
    );
    return '$_temp0';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个待处理',
    );
    return '$_temp0';
  }

  @override
  String pendingFailingCount(String pending, String failing) {
    return '$pending，$failing';
  }

  @override
  String get relayStatus => '中继状态';

  @override
  String get relaysLabel => '中继';

  @override
  String relaysConfiguredLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已配置 $count 个',
    );
    return '$_temp0';
  }

  @override
  String get unencryptedTransport => '未加密传输';

  @override
  String couldNotReachService(String error) {
    return '无法连接到 astraea-service：$error';
  }

  @override
  String get inviteSectionTitle => '参与者';

  @override
  String get inviteButtonLabel => '邀请';

  @override
  String get noAttendeesYet => '尚未邀请任何人';

  @override
  String get inviteDialogTitle => '邀请某人';

  @override
  String get inviteDialogHint => 'npub、name@domain 或公钥';

  @override
  String resolvePersonFailed(String error) {
    return '无法解析该联系人：$error';
  }

  @override
  String get confirmNip05Title => '确认收件人';

  @override
  String confirmNip05Body(String query, String pubkey) {
    return '通过 NIP-05，$query 已解析为 $pubkey。此映射由该域名控制——请确认这是您预期的联系人。';
  }

  @override
  String get attendeeStatusInvited => '已邀请';

  @override
  String get attendeeStatusAccepted => '已接受';

  @override
  String get attendeeStatusDeclined => '已拒绝';

  @override
  String inviteFailed(String error) {
    return '无法发送邀请：$error';
  }

  @override
  String get pendingInvitationsTooltip => '邀请';

  @override
  String get pendingInvitationsTitle => '邀请';

  @override
  String get pendingInvitationsEmpty => '没有待处理的邀请';

  @override
  String invitationFromLabel(String pubkey) {
    return '来自 $pubkey';
  }

  @override
  String get acceptInvitation => '接受';

  @override
  String get declineInvitation => '拒绝';

  @override
  String respondToInvitationFailed(String error) {
    return '无法发送回复：$error';
  }

  @override
  String get invitationAccepted => '邀请已接受';

  @override
  String get invitationDeclined => '邀请已拒绝';
}
