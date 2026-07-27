// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Astraea';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get next => 'Seguinte';

  @override
  String get back => 'Voltar';

  @override
  String get loading => 'A carregar…';

  @override
  String get settingsTooltip => 'Definições';

  @override
  String get newEventButton => 'Novo evento';

  @override
  String couldNotLoadEvents(String error) {
    return 'Não foi possível carregar os eventos:\n$error';
  }

  @override
  String get viewMonth => 'Mês';

  @override
  String get viewWeek => 'Semana';

  @override
  String get viewDay => 'Dia';

  @override
  String get viewList => 'Lista';

  @override
  String get noEventsToday => 'Sem eventos neste dia.';

  @override
  String get noUpcomingEvents => 'Sem eventos futuros nos próximos 60 dias.';

  @override
  String get untitledEvent => '(sem título)';

  @override
  String get allDay => 'Dia inteiro';

  @override
  String get addAccountToSyncTooltip =>
      'Adicionar uma conta Nostr para sincronizar';

  @override
  String get syncNowTooltip => 'Sincronizar agora';

  @override
  String get addNostrAccountTitle => 'Adicionar uma conta Nostr';

  @override
  String get eventNotFound => 'Evento não encontrado.';

  @override
  String get eventAppBarTitle => 'Evento';

  @override
  String get editTooltip => 'Editar';

  @override
  String get deleteTooltip => 'Eliminar';

  @override
  String allDayLabel(String date) {
    return '$date · Dia inteiro';
  }

  @override
  String recurrenceUntilLabel(String recurrence, String date) {
    return '$recurrence · até $date';
  }

  @override
  String get syncedToRelays => 'Sincronizado com os relés';

  @override
  String get notYetSynced => 'Ainda não sincronizado';

  @override
  String get deleteEventTitle => 'Eliminar o evento?';

  @override
  String get deleteEventBody =>
      'Isto remove o evento deste dispositivo e solicita a eliminação nos relés.';

  @override
  String get editEventTitle => 'Editar evento';

  @override
  String get newEventTitle => 'Novo evento';

  @override
  String get fieldTitle => 'Título';

  @override
  String get allDaySwitch => 'Dia inteiro';

  @override
  String get startsLabel => 'Início';

  @override
  String get endsLabel => 'Fim';

  @override
  String get timezoneLabel => 'Fuso horário';

  @override
  String get repeatsLabel => 'Repetição';

  @override
  String get untilLabel => 'Até';

  @override
  String get foreverLabel => 'Para sempre';

  @override
  String get remindersLabel => 'Lembretes';

  @override
  String get addChip => 'Adicionar';

  @override
  String get colorLabel => 'Cor';

  @override
  String get locationLabel => 'Local';

  @override
  String get descriptionLabel => 'Descrição';

  @override
  String couldNotSaveEvent(String error) {
    return 'Não foi possível guardar o evento: $error';
  }

  @override
  String get recurrenceNone => 'Não se repete';

  @override
  String get recurrenceDaily => 'Diariamente';

  @override
  String get recurrenceWeekly => 'Semanalmente';

  @override
  String get recurrenceMonthly => 'Mensalmente';

  @override
  String get recurrenceYearly => 'Anualmente';

  @override
  String get reminderAtStart => 'No início';

  @override
  String reminderMinutesBefore(int count) {
    return '$count min antes';
  }

  @override
  String reminderHoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count horas antes',
      one: '1 hora antes',
    );
    return '$_temp0';
  }

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias antes',
      one: '1 dia antes',
    );
    return '$_temp0';
  }

  @override
  String get getStarted => 'Começar';

  @override
  String get useOffline => 'Usar offline';

  @override
  String get welcomeTitle => 'Bem-vindo ao Astraea';

  @override
  String get welcomeSubtitle =>
      'Um calendário privado, offline-first, que te dá o controlo.';

  @override
  String get featureLocalTitle =>
      'O teu calendário permanece no teu dispositivo';

  @override
  String get featureLocalBody =>
      'Cria eventos, recorrências e lembretes sem conta nem ligação à internet.';

  @override
  String get featureSyncTitle => 'Sincronização opcional através do Nostr';

  @override
  String get featureSyncBody =>
      'Liga uma conta para fazer cópia de segurança do teu calendário e usá-lo em vários dispositivos através dos relés que escolheres.';

  @override
  String get featureEncryptedTitle => 'Sempre cifrado antes do envio';

  @override
  String get featureEncryptedBody =>
      'O conteúdo do calendário é cifrado de ponta a ponta antes de sair deste dispositivo. Os operadores de relés não conseguem lê-lo.';

  @override
  String get featureAmberTitle => 'Guarda a tua chave no Amber';

  @override
  String get featureAmberBody =>
      'No Android, um assinante externo pode aprovar o acesso sem expor a tua chave privada ao Astraea.';

  @override
  String get featureRemindersTitle => 'Lembretes locais privados';

  @override
  String get featureRemindersBody =>
      'As notificações são agendadas pelo teu dispositivo e não dependem de um serviço de calendário na nuvem.';

  @override
  String get connectNostrAccountTitle => 'Ligar uma conta Nostr';

  @override
  String get connectNostrAccountBody =>
      'Isto só é necessário para a sincronização cifrada. Também podes usar o Astraea totalmente offline.';

  @override
  String get chooseRelaysTitle => 'Escolhe relés para a sincronização';

  @override
  String get chooseRelaysBody =>
      'Os relés guardam o teu calendário cifrado e disponibilizam-no nos teus outros dispositivos. Adiciona um ou mais, ou deixa a lista vazia e configura mais tarde.';

  @override
  String couldNotLoadRelaySettings(String error) {
    return 'Não foi possível carregar as definições de relés: $error';
  }

  @override
  String get suggestedRelays => 'Sugeridos';

  @override
  String get addRelayTooltip => 'Adicionar relé';

  @override
  String get customRelayLabel => 'Relé personalizado';

  @override
  String get customRelayHint => 'wss://relay.example.com';

  @override
  String get selectedRelays => 'Selecionados';

  @override
  String get removeRelayTooltip => 'Remover relé';

  @override
  String get invalidRelayUrl =>
      'Introduz um URL wss:// válido (ou ws:// para um relé privado).';

  @override
  String get insecureRelayWarning =>
      'ws:// não é cifrado em trânsito — usa-o apenas para um relé em que confies.';

  @override
  String get nostrAccountConnected => 'Conta Nostr ligada';

  @override
  String get invalidPrivateKey =>
      'Essa chave privada não é válida. Verifica-a e tenta novamente.';

  @override
  String couldNotSignIn(String error) {
    return 'Não foi possível iniciar sessão: $error';
  }

  @override
  String get signInWithAmber => 'Iniciar sessão com Amber';

  @override
  String get createNewAccount => 'Criar uma nova conta';

  @override
  String get generatedAccountWarning =>
      'Uma conta gerada só pode ser recuperada com a respetiva chave privada. Faz a cópia de segurança nas Definições após a configuração.';

  @override
  String get importExistingKey => 'Importar uma chave existente';

  @override
  String get privateKeyFieldLabel => 'nsec ou chave privada hexadecimal';

  @override
  String get importButton => 'Importar';

  @override
  String get followDeviceTimezone => 'Seguir o fuso horário do dispositivo';

  @override
  String get searchCityRegion => 'Pesquisar uma cidade ou região';

  @override
  String get noMatchingTimezone => 'Nenhum fuso horário correspondente.';

  @override
  String get settingsTitle => 'Definições';

  @override
  String couldNotLoadSettings(String error) {
    return 'Não foi possível carregar as definições:\n$error';
  }

  @override
  String get sectionAccount => 'Conta';

  @override
  String get sectionSync => 'Sincronização';

  @override
  String get sectionRelays => 'Relés';

  @override
  String get sectionAppearance => 'Aparência';

  @override
  String get sectionData => 'Dados';

  @override
  String get sectionRemindersTimezone => 'Lembretes e fuso horário';

  @override
  String get sectionSupport => 'Apoio';

  @override
  String somethingWentWrong(String error) {
    return 'Algo correu mal: $error';
  }

  @override
  String get offlineNoAccount => 'Offline — sem conta';

  @override
  String get signInToSyncAcrossDevices =>
      'Inicia sessão para sincronizar o teu calendário cifrado entre dispositivos.';

  @override
  String get signIn => 'Iniciar sessão';

  @override
  String get signedInWithAmber => 'Sessão iniciada com Amber';

  @override
  String get signedIn => 'Sessão iniciada';

  @override
  String get signOut => 'Terminar sessão';

  @override
  String get backUpPrivateKey => 'Cópia de segurança da chave privada';

  @override
  String get revealNsecSubtitle =>
      'Revela a tua nsec para a guardares num local seguro';

  @override
  String get signOutTitle => 'Terminar sessão?';

  @override
  String get signOutBody =>
      'Os teus eventos permanecem neste dispositivo e nos relés. Certifica-te de que fizeste a cópia de segurança da tua chave privada — sem ela, uma conta gerada não pode ser recuperada.';

  @override
  String get noPrivateKeyStored =>
      'Nenhuma chave privada guardada para esta sessão.';

  @override
  String get yourPrivateKeyTitle => 'A tua chave privada (nsec)';

  @override
  String get nsecWarning =>
      'Quem tiver esta chave controla a tua conta. Nunca a partilhes; guarda-a num gestor de palavras-passe.';

  @override
  String get copy => 'Copiar';

  @override
  String get done => 'Concluído';

  @override
  String get syncNowTitle => 'Sincronizar agora';

  @override
  String get signInToSyncSubtitle =>
      'Inicia sessão para sincronizar o teu calendário cifrado.';

  @override
  String get addRelayToSyncSubtitle =>
      'Adiciona pelo menos um relé para sincronizar.';

  @override
  String get syncingEllipsis => 'A sincronizar…';

  @override
  String get synced => 'Sincronizado';

  @override
  String lastSyncedLabel(String when) {
    return 'Última sincronização $when';
  }

  @override
  String lastSyncFailedLabel(String error) {
    return 'A última sincronização falhou: $error';
  }

  @override
  String get pullMergePublish => 'Obtém, combina e publica os teus eventos';

  @override
  String get publicRelays => 'Relés públicos';

  @override
  String relaysConfiguredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count configurados',
      one: '1 configurado',
    );
    return '$_temp0';
  }

  @override
  String get addRelay => 'Adicionar relé';

  @override
  String get suggestedRelaysTitle => 'Relés sugeridos';

  @override
  String get addOnlyRelaysYouWant =>
      'Adiciona apenas os relés que queres usar.';

  @override
  String get homeRelayBackup => 'Relé pessoal (cópia de segurança)';

  @override
  String get homeRelayNotConfigured =>
      'Não configurado — um relé pessoal adicional para fazer cópia de segurança dos teus eventos';

  @override
  String get homeRelayDialogTitle => 'Relé pessoal';

  @override
  String get lightTheme => 'Tema claro';

  @override
  String get darkThemeDefault => 'O Astraea usa o tema escuro por predefinição';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get systemLanguage => 'Idioma do sistema';

  @override
  String get exportEvents => 'Exportar eventos';

  @override
  String get exportEventsSubtitle =>
      'Guardar um ficheiro .ics — opcionalmente protegido por palavra-passe';

  @override
  String get importEvents => 'Importar eventos';

  @override
  String get importEventsSubtitle =>
      'A partir de um ficheiro .ics ou de uma exportação cifrada do Astraea';

  @override
  String get encryptExportTitle => 'Cifrar esta exportação?';

  @override
  String get encryptExportBody =>
      'Um ficheiro .ics simples pode ser aberto por qualquer aplicação de calendário — e por quem o obtiver. Define uma palavra-passe para o cifrar (só o Astraea o conseguirá voltar a importar).';

  @override
  String get exportPasswordLabel =>
      'Palavra-passe (deixa vazio para um .ics simples)';

  @override
  String get export => 'Exportar';

  @override
  String get encryptedExportSaved => 'Exportação cifrada guardada.';

  @override
  String get exportSaved => 'Exportação guardada.';

  @override
  String exportFailed(String error) {
    return 'Falha na exportação: $error';
  }

  @override
  String get couldNotReadSelectedFile =>
      'Não foi possível ler o ficheiro selecionado.';

  @override
  String get selectedFileTooLarge =>
      'O ficheiro selecionado tem mais de 10 MB.';

  @override
  String importedEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eventos importados.',
      one: '1 evento importado.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(String error) {
    return 'Falha na importação: $error';
  }

  @override
  String get thisExportIsEncrypted => 'Esta exportação está cifrada';

  @override
  String get passwordLabel => 'Palavra-passe';

  @override
  String get wrongPassword => 'Palavra-passe incorreta.';

  @override
  String get invalidEncryptedExport => 'Esta exportação cifrada não é válida.';

  @override
  String get reminders => 'Lembretes';

  @override
  String get scheduleLocalNotifications =>
      'Agendar notificações locais para lembretes de eventos';

  @override
  String get timezone => 'Fuso horário';

  @override
  String followDeviceTimezoneWithName(String zone) {
    return 'Seguir o fuso horário do dispositivo ($zone)';
  }

  @override
  String get supportAstraea => 'Apoiar o Astraea';

  @override
  String noLightningWalletFound(String address) {
    return 'Nenhuma carteira Lightning encontrada — endereço copiado: $address';
  }

  @override
  String get desktopServiceUnreachableTitle =>
      'Serviço em segundo plano do Astraea indisponível';

  @override
  String get desktopServiceUnreachableBody =>
      'A aplicação de ambiente de trabalho comunica com o astraea-service através de D-Bus para armazenamento, sincronização e notificações, e não foi possível contactá-lo. Se estiveres a executar a partir do código-fonte, instala-o com:\n\n./scripts/install-dev.sh';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get calendarsLabel => 'Calendários';

  @override
  String calendarsUnavailable(String error) {
    return 'Calendários indisponíveis: $error';
  }

  @override
  String get serviceUnreachable => 'Serviço inacessível';

  @override
  String syncStatusLabel(String status) {
    return 'Sincronização: $status';
  }

  @override
  String syncPendingSuffix(int count) {
    return ' ($count pendentes)';
  }

  @override
  String get localOnlyMode => 'Modo apenas local (sem identidade Nostr)';

  @override
  String get syncStarted => 'Sincronização iniciada';

  @override
  String syncUnavailable(String error) {
    return 'Sincronização indisponível: $error';
  }

  @override
  String get notSignedIn => 'Sessão não iniciada';

  @override
  String get signInWithBrowserSubtitle =>
      'Inicia sessão com o teu navegador (NIP-07) para sincronizar este calendário através do Nostr.';

  @override
  String get signedInBackgroundSigning =>
      'Sessão iniciada — assinatura em segundo plano através de uma chave delegada';

  @override
  String get signedInRemoteSigner =>
      'Sessão iniciada — assinante remoto (NIP-46)';

  @override
  String get signedInNoBackgroundSigner =>
      'Sessão iniciada, mas nenhum assinante em segundo plano está configurado — a sincronização permanece em pausa. Executa \"astraea-service auth provision-key\" num terminal.';

  @override
  String couldNotStartLogin(String error) {
    return 'Não foi possível iniciar o início de sessão: $error';
  }

  @override
  String get signOutConfirmDesktopBody =>
      'Isto esquece a conta apenas neste dispositivo — os teus eventos permanecem nos relés. Uma chave de assinatura fornecida, se existir, é removida do chaveiro.';

  @override
  String get signInWithBrowserTitle => 'Inicia sessão com o teu navegador';

  @override
  String get loginSessionExpired =>
      'Esta sessão de início de sessão expirou. Tenta novamente.';

  @override
  String get loginWaitingBody =>
      'Foi aberto um separador do navegador para confirmar a tua identidade Nostr (NIP-07). Aprova-a lá — esta janela fecha-se automaticamente. A tua chave privada nunca é pedida.';

  @override
  String get openAgain => 'Abrir novamente';

  @override
  String get offlineWillRetry => 'Offline — tentará novamente automaticamente.';

  @override
  String get upToDate => 'Atualizado';

  @override
  String operationsFailingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count operações a falhar',
      one: '1 operação a falhar',
    );
    return '$_temp0';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pendentes',
      one: '1 pendente',
    );
    return '$_temp0';
  }

  @override
  String pendingFailingCount(String pending, String failing) {
    return '$pending, $failing';
  }

  @override
  String get relayStatus => 'Estado dos relés';

  @override
  String get relaysLabel => 'Relés';

  @override
  String relaysConfiguredLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count configurados',
      one: '1 configurado',
    );
    return '$_temp0';
  }

  @override
  String get unencryptedTransport => 'Transporte não cifrado';

  @override
  String couldNotReachService(String error) {
    return 'Não foi possível contactar o astraea-service: $error';
  }

  @override
  String get inviteSectionTitle => 'Participantes';

  @override
  String get inviteButtonLabel => 'Convidar';

  @override
  String get noAttendeesYet => 'Ainda ninguém foi convidado';

  @override
  String get inviteDialogTitle => 'Convidar alguém';

  @override
  String get inviteDialogHint => 'npub, nome@domínio ou chave pública';

  @override
  String resolvePersonFailed(String error) {
    return 'Não foi possível encontrar essa pessoa: $error';
  }

  @override
  String get confirmNip05Title => 'Confirmar destinatário';

  @override
  String confirmNip05Body(String query, String pubkey) {
    return '$query foi resolvido para $pubkey através de NIP-05. Este mapeamento é controlado pelo domínio — certifique-se de que é a pessoa esperada.';
  }

  @override
  String get attendeeStatusInvited => 'Convidado';

  @override
  String get attendeeStatusAccepted => 'Aceite';

  @override
  String get attendeeStatusDeclined => 'Recusado';

  @override
  String inviteFailed(String error) {
    return 'Não foi possível enviar o convite: $error';
  }

  @override
  String get pendingInvitationsTooltip => 'Convites';

  @override
  String get pendingInvitationsTitle => 'Convites';

  @override
  String get pendingInvitationsEmpty => 'Sem convites pendentes';

  @override
  String invitationFromLabel(String pubkey) {
    return 'De $pubkey';
  }

  @override
  String get acceptInvitation => 'Aceitar';

  @override
  String get declineInvitation => 'Recusar';

  @override
  String respondToInvitationFailed(String error) {
    return 'Não foi possível responder: $error';
  }

  @override
  String get invitationAccepted => 'Convite aceite';

  @override
  String get invitationDeclined => 'Convite recusado';
}
