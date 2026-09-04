// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Astraea';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';

  @override
  String get delete => '削除';

  @override
  String get continueLabel => '続ける';

  @override
  String get next => '次へ';

  @override
  String get back => '戻る';

  @override
  String get loading => '読み込み中…';

  @override
  String get settingsTooltip => '設定';

  @override
  String get newEventButton => '新しい予定';

  @override
  String couldNotLoadEvents(String error) {
    return '予定を読み込めませんでした:\n$error';
  }

  @override
  String get viewMonth => '月';

  @override
  String get viewWeek => '週';

  @override
  String get viewDay => '日';

  @override
  String get viewList => 'リスト';

  @override
  String get noEventsToday => 'この日に予定はありません。';

  @override
  String get noUpcomingEvents => '今後60日間に予定はありません。';

  @override
  String get untitledEvent => '（無題）';

  @override
  String get allDay => '終日';

  @override
  String get addAccountToSyncTooltip => '同期するには Nostr アカウントを追加してください';

  @override
  String get syncNowTooltip => '今すぐ同期';

  @override
  String get addNostrAccountTitle => 'Nostr アカウントを追加';

  @override
  String get eventNotFound => '予定が見つかりません。';

  @override
  String get eventAppBarTitle => '予定';

  @override
  String get editTooltip => '編集';

  @override
  String get deleteTooltip => '削除';

  @override
  String allDayLabel(String date) {
    return '$date · 終日';
  }

  @override
  String recurrenceUntilLabel(String recurrence, String date) {
    return '$recurrence · $date まで';
  }

  @override
  String get syncedToRelays => 'リレーと同期済み';

  @override
  String get notYetSynced => 'まだ同期されていません';

  @override
  String get deleteEventTitle => '予定を削除しますか？';

  @override
  String get deleteEventBody => 'この操作により、この予定はこのデバイスから削除され、リレーからの削除も要求されます。';

  @override
  String get editEventTitle => '予定を編集';

  @override
  String get newEventTitle => '新しい予定';

  @override
  String get fieldTitle => 'タイトル';

  @override
  String get allDaySwitch => '終日';

  @override
  String get startsLabel => '開始';

  @override
  String get endsLabel => '終了';

  @override
  String get timezoneLabel => 'タイムゾーン';

  @override
  String get repeatsLabel => '繰り返し';

  @override
  String get untilLabel => 'まで';

  @override
  String get foreverLabel => '無期限';

  @override
  String get remindersLabel => 'リマインダー';

  @override
  String get addChip => '追加';

  @override
  String get colorLabel => '色';

  @override
  String get locationLabel => '場所';

  @override
  String get descriptionLabel => '説明';

  @override
  String couldNotSaveEvent(String error) {
    return '予定を保存できませんでした: $error';
  }

  @override
  String get recurrenceNone => '繰り返さない';

  @override
  String get recurrenceDaily => '毎日';

  @override
  String get recurrenceWeekly => '毎週';

  @override
  String get recurrenceMonthly => '毎月';

  @override
  String get recurrenceYearly => '毎年';

  @override
  String get reminderAtStart => '開始時';

  @override
  String reminderMinutesBefore(int count) {
    return '$count 分前';
  }

  @override
  String reminderHoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 時間前',
    );
    return '$_temp0';
  }

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 日前',
    );
    return '$_temp0';
  }

  @override
  String get getStarted => 'はじめる';

  @override
  String get useOffline => 'オフラインで使用';

  @override
  String get welcomeTitle => 'Astraea へようこそ';

  @override
  String get welcomeSubtitle => 'オフラインファーストのプライベートなカレンダーで、主導権はあなたにあります。';

  @override
  String get featureLocalTitle => 'カレンダーはあなたのデバイスに保存されます';

  @override
  String get featureLocalBody => 'アカウントやインターネット接続なしで、予定、繰り返し、リマインダーを作成できます。';

  @override
  String get featureSyncTitle => 'Nostr によるオプションの同期';

  @override
  String get featureSyncBody =>
      'アカウントを接続して、選択したリレーを通じてカレンダーをバックアップし、複数のデバイスで使用できます。';

  @override
  String get featureEncryptedTitle => 'アップロード前に常に暗号化';

  @override
  String get featureEncryptedBody =>
      'カレンダーの内容は、このデバイスを離れる前にエンドツーエンドで暗号化されます。リレー運営者はそれを読み取れません。';

  @override
  String get featureAmberTitle => '鍵は Amber に保管';

  @override
  String get featureAmberBody =>
      'Android では、外部の署名者があなたの秘密鍵を Astraea に公開することなくアクセスを承認できます。';

  @override
  String get featureRemindersTitle => 'プライベートなローカルリマインダー';

  @override
  String get featureRemindersBody =>
      '通知はあなたのデバイスによってスケジュールされ、クラウドカレンダーサービスに依存しません。';

  @override
  String get connectNostrAccountTitle => 'Nostr アカウントを接続';

  @override
  String get connectNostrAccountBody =>
      'これは暗号化された同期にのみ必要です。Astraea は完全にオフラインでも使用できます。';

  @override
  String get chooseRelaysTitle => '同期用のリレーを選択';

  @override
  String get chooseRelaysBody =>
      'リレーは暗号化されたカレンダーを保存し、他のデバイスで利用できるようにします。1つ以上追加するか、リストを空のままにして後で設定してください。';

  @override
  String couldNotLoadRelaySettings(String error) {
    return 'リレー設定を読み込めませんでした: $error';
  }

  @override
  String get suggestedRelays => 'おすすめ';

  @override
  String get addRelayTooltip => 'リレーを追加';

  @override
  String get customRelayLabel => 'カスタムリレー';

  @override
  String get customRelayHint => 'wss://relay.example.com';

  @override
  String get selectedRelays => '選択済み';

  @override
  String get removeRelayTooltip => 'リレーを削除';

  @override
  String get invalidRelayUrl =>
      '有効な wss:// のURLを入力してください（プライベートリレーの場合は ws://）。';

  @override
  String get insecureRelayWarning =>
      'ws:// は転送中に暗号化されません — 信頼できるリレーにのみ使用してください。';

  @override
  String get nostrAccountConnected => 'Nostr アカウントが接続されました';

  @override
  String get invalidPrivateKey => 'その秘密鍵は無効です。確認してもう一度お試しください。';

  @override
  String couldNotSignIn(String error) {
    return 'サインインできませんでした: $error';
  }

  @override
  String get signInWithAmber => 'Amber でサインイン';

  @override
  String get createNewAccount => '新しいアカウントを作成';

  @override
  String get generatedAccountWarning =>
      '生成されたアカウントは、その秘密鍵によってのみ復元できます。設定完了後に「設定」からバックアップしてください。';

  @override
  String get importExistingKey => '既存の鍵をインポート';

  @override
  String get privateKeyFieldLabel => 'nsec または16進数の秘密鍵';

  @override
  String get importButton => 'インポート';

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
  String get followDeviceTimezone => 'デバイスのタイムゾーンに従う';

  @override
  String get searchCityRegion => '都市または地域を検索';

  @override
  String get noMatchingTimezone => '一致するタイムゾーンがありません。';

  @override
  String get settingsTitle => '設定';

  @override
  String couldNotLoadSettings(String error) {
    return '設定を読み込めませんでした:\n$error';
  }

  @override
  String get sectionAccount => 'アカウント';

  @override
  String get sectionSync => '同期';

  @override
  String get sectionRelays => 'リレー';

  @override
  String get sectionAppearance => '外観';

  @override
  String get sectionData => 'データ';

  @override
  String get sectionRemindersTimezone => 'リマインダーとタイムゾーン';

  @override
  String get sectionSupport => 'サポート';

  @override
  String somethingWentWrong(String error) {
    return '問題が発生しました: $error';
  }

  @override
  String get offlineNoAccount => 'オフライン — アカウントなし';

  @override
  String get signInToSyncAcrossDevices => 'サインインしてデバイス間で暗号化されたカレンダーを同期してください。';

  @override
  String get signIn => 'サインイン';

  @override
  String get signedInWithAmber => 'Amber でサインイン済み';

  @override
  String get signedIn => 'サインイン済み';

  @override
  String get signOut => 'サインアウト';

  @override
  String get backUpPrivateKey => '秘密鍵をバックアップ';

  @override
  String get revealNsecSubtitle => 'nsec を表示して安全な場所に保存してください';

  @override
  String get signOutTitle => 'サインアウトしますか？';

  @override
  String get signOutBody =>
      'あなたの予定はこのデバイスとリレー上に残ります。秘密鍵をバックアップしたことを確認してください — それがないと、生成されたアカウントは復元できません。';

  @override
  String get noPrivateKeyStored => 'このセッションに保存されている秘密鍵はありません。';

  @override
  String get yourPrivateKeyTitle => 'あなたの秘密鍵（nsec）';

  @override
  String get nsecWarning =>
      'この鍵を持つ人は誰でもあなたのアカウントを制御できます。決して共有せず、パスワードマネージャーに保管してください。';

  @override
  String get copy => 'コピー';

  @override
  String get done => '完了';

  @override
  String get syncNowTitle => '今すぐ同期';

  @override
  String get signInToSyncSubtitle => 'サインインして暗号化されたカレンダーを同期してください。';

  @override
  String get addRelayToSyncSubtitle => '同期するには少なくとも1つのリレーを追加してください。';

  @override
  String get syncingEllipsis => '同期中…';

  @override
  String get synced => '同期済み';

  @override
  String lastSyncedLabel(String when) {
    return '最終同期: $when';
  }

  @override
  String lastSyncFailedLabel(String error) {
    return '前回の同期が失敗しました: $error';
  }

  @override
  String get pullMergePublish => 'あなたの予定を取得、マージ、公開します';

  @override
  String get publicRelays => '公開リレー';

  @override
  String relaysConfiguredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件設定済み',
    );
    return '$_temp0';
  }

  @override
  String get addRelay => 'リレーを追加';

  @override
  String get suggestedRelaysTitle => 'おすすめのリレー';

  @override
  String get addOnlyRelaysYouWant => '使用したいリレーのみを追加してください。';

  @override
  String get homeRelayBackup => '個人用リレー（バックアップ）';

  @override
  String get homeRelayNotConfigured => '未設定 — 予定をバックアップするための追加の個人用リレー';

  @override
  String get homeRelayDialogTitle => '個人用リレー';

  @override
  String get lightTheme => 'ライトテーマ';

  @override
  String get darkThemeDefault => 'Astraea は既定でダークテーマを使用します';

  @override
  String get languageLabel => '言語';

  @override
  String get systemLanguage => 'システム言語';

  @override
  String get accentColorLabel => 'アクセントカラー';

  @override
  String get accentNavy => 'ネイビーブルー';

  @override
  String get accentBitcoin => 'ビットコインオレンジ';

  @override
  String get accentNostr => 'Nostrパープル';

  @override
  String get exportEvents => '予定をエクスポート';

  @override
  String get exportEventsSubtitle => '.ics ファイルを保存します — パスワード保護は任意です';

  @override
  String get importEvents => '予定をインポート';

  @override
  String get importEventsSubtitle => '.ics ファイルまたは暗号化された Astraea エクスポートから';

  @override
  String get encryptExportTitle => 'このエクスポートを暗号化しますか？';

  @override
  String get encryptExportBody =>
      '通常の .ics ファイルはどのカレンダーアプリでも開くことができ、ファイルを入手した誰でも読めます。パスワードを設定して暗号化してください（再インポートできるのは Astraea のみになります）。';

  @override
  String get exportPasswordLabel => 'パスワード（通常の .ics ファイルにする場合は空欄のまま）';

  @override
  String get export => 'エクスポート';

  @override
  String get encryptedExportSaved => '暗号化されたエクスポートを保存しました。';

  @override
  String get exportSaved => 'エクスポートを保存しました。';

  @override
  String exportFailed(String error) {
    return 'エクスポートに失敗しました: $error';
  }

  @override
  String get couldNotReadSelectedFile => '選択したファイルを読み込めませんでした。';

  @override
  String get selectedFileTooLarge => '選択したファイルは10MBを超えています。';

  @override
  String importedEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件の予定をインポートしました。',
    );
    return '$_temp0';
  }

  @override
  String importFailed(String error) {
    return 'インポートに失敗しました: $error';
  }

  @override
  String get thisExportIsEncrypted => 'このエクスポートは暗号化されています';

  @override
  String get passwordLabel => 'パスワード';

  @override
  String get wrongPassword => 'パスワードが間違っています。';

  @override
  String get invalidEncryptedExport => 'この暗号化されたエクスポートは無効です。';

  @override
  String get reminders => 'リマインダー';

  @override
  String get scheduleLocalNotifications => '予定のリマインダーのためにローカル通知をスケジュールする';

  @override
  String get timezone => 'タイムゾーン';

  @override
  String followDeviceTimezoneWithName(String zone) {
    return 'デバイスのタイムゾーンに従う（$zone）';
  }

  @override
  String get supportAstraea => 'Astraea をサポート';

  @override
  String noLightningWalletFound(String address) {
    return 'Lightning ウォレットが見つかりませんでした — アドレスをコピーしました: $address';
  }

  @override
  String get desktopServiceUnreachableTitle => 'Astraea のバックグラウンドサービスが利用できません';

  @override
  String get desktopServiceUnreachableBody =>
      'デスクトップアプリは、保存、同期、通知のために D-Bus 経由で astraea-service と通信しますが、接続できませんでした。ソースから実行している場合は、次のコマンドでインストールしてください:\n\n./scripts/install-dev.sh';

  @override
  String get retry => '再試行';

  @override
  String get calendarsLabel => 'カレンダー';

  @override
  String calendarsUnavailable(String error) {
    return 'カレンダーを利用できません: $error';
  }

  @override
  String get serviceUnreachable => 'サービスに到達できません';

  @override
  String syncStatusLabel(String status) {
    return '同期: $status';
  }

  @override
  String syncPendingSuffix(int count) {
    return '（保留中 $count 件）';
  }

  @override
  String get localOnlyMode => 'ローカルのみモード（Nostr の識別情報なし）';

  @override
  String get syncStarted => '同期を開始しました';

  @override
  String syncUnavailable(String error) {
    return '同期を利用できません: $error';
  }

  @override
  String get notSignedIn => 'サインインしていません';

  @override
  String get signInWithBrowserSubtitle =>
      'ブラウザ（NIP-07）でサインインして、このカレンダーを Nostr 経由で同期してください。';

  @override
  String get signedInBackgroundSigning => 'サインイン済み — 委任された鍵によるバックグラウンド署名';

  @override
  String get signedInRemoteSigner => 'サインイン済み — リモート署名者（NIP-46）';

  @override
  String get signedInNoBackgroundSigner =>
      'サインイン済みですが、バックグラウンド署名者が設定されていません — 同期は保留のままです。ターミナルで「astraea-service auth provision-key」を実行してください。';

  @override
  String couldNotStartLogin(String error) {
    return 'ログインを開始できませんでした: $error';
  }

  @override
  String get signOutConfirmDesktopBody =>
      'これはこのデバイス上でのみアカウントを忘れます — 予定はリレー上に残ります。提供された署名鍵があれば、キーリングから削除されます。';

  @override
  String get signInWithBrowserTitle => 'ブラウザでサインイン';

  @override
  String get loginSessionExpired => 'このログインセッションは期限切れです。もう一度お試しください。';

  @override
  String get loginWaitingBody =>
      'あなたの Nostr 識別情報（NIP-07）を確認するためにブラウザタブが開かれました。そこで承認してください — このダイアログは自動的に閉じます。あなたの秘密鍵が求められることは決してありません。';

  @override
  String get openAgain => '再度開く';

  @override
  String get offlineWillRetry => 'オフライン — 自動的に再試行します。';

  @override
  String get upToDate => '最新の状態です';

  @override
  String operationsFailingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件の操作が失敗',
    );
    return '$_temp0';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件保留中',
    );
    return '$_temp0';
  }

  @override
  String pendingFailingCount(String pending, String failing) {
    return '$pending、$failing';
  }

  @override
  String get relayStatus => 'リレーの状態';

  @override
  String get relaysLabel => 'リレー';

  @override
  String relaysConfiguredLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件設定済み',
    );
    return '$_temp0';
  }

  @override
  String get unencryptedTransport => '暗号化されていない通信';

  @override
  String couldNotReachService(String error) {
    return 'astraea-service に接続できませんでした: $error';
  }

  @override
  String get inviteSectionTitle => '参加者';

  @override
  String get inviteButtonLabel => '招待';

  @override
  String get noAttendeesYet => 'まだ誰も招待していません';

  @override
  String get inviteDialogTitle => '招待する';

  @override
  String get inviteDialogHint => 'npub、name@domain、または公開鍵';

  @override
  String resolvePersonFailed(String error) {
    return 'その相手を解決できませんでした: $error';
  }

  @override
  String get confirmNip05Title => '受信者の確認';

  @override
  String confirmNip05Body(String query, String pubkey) {
    return '$query は NIP-05 により $pubkey に解決されました。この対応関係はドメイン側が管理しています。想定した相手であることを確認してください。';
  }

  @override
  String get attendeeStatusInvited => '招待済み';

  @override
  String get attendeeStatusAccepted => '承諾済み';

  @override
  String get attendeeStatusDeclined => '辞退済み';

  @override
  String inviteFailed(String error) {
    return '招待を送信できませんでした: $error';
  }

  @override
  String get pendingInvitationsTooltip => '招待';

  @override
  String get pendingInvitationsTitle => '招待';

  @override
  String get pendingInvitationsEmpty => '保留中の招待はありません';

  @override
  String invitationFromLabel(String pubkey) {
    return '送信元: $pubkey';
  }

  @override
  String get acceptInvitation => '承諾';

  @override
  String get declineInvitation => '辞退';

  @override
  String respondToInvitationFailed(String error) {
    return '応答を送信できませんでした: $error';
  }

  @override
  String get invitationAccepted => '招待を承諾しました';

  @override
  String get invitationDeclined => '招待を辞退しました';
}
