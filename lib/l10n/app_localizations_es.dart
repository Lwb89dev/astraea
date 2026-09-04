// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

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
  String get next => 'Siguiente';

  @override
  String get back => 'Atrás';

  @override
  String get loading => 'Cargando…';

  @override
  String get settingsTooltip => 'Ajustes';

  @override
  String get newEventButton => 'Nuevo evento';

  @override
  String couldNotLoadEvents(String error) {
    return 'No se pudieron cargar los eventos:\n$error';
  }

  @override
  String get viewMonth => 'Mes';

  @override
  String get viewWeek => 'Semana';

  @override
  String get viewDay => 'Día';

  @override
  String get viewList => 'Lista';

  @override
  String get noEventsToday => 'No hay eventos este día.';

  @override
  String get noUpcomingEvents =>
      'No hay eventos próximos en los próximos 60 días.';

  @override
  String get untitledEvent => '(sin título)';

  @override
  String get allDay => 'Todo el día';

  @override
  String get addAccountToSyncTooltip =>
      'Añadir una cuenta Nostr para sincronizar';

  @override
  String get syncNowTooltip => 'Sincronizar ahora';

  @override
  String get addNostrAccountTitle => 'Añadir una cuenta Nostr';

  @override
  String get eventNotFound => 'Evento no encontrado.';

  @override
  String get eventAppBarTitle => 'Evento';

  @override
  String get editTooltip => 'Editar';

  @override
  String get deleteTooltip => 'Eliminar';

  @override
  String allDayLabel(String date) {
    return '$date · Todo el día';
  }

  @override
  String recurrenceUntilLabel(String recurrence, String date) {
    return '$recurrence · hasta el $date';
  }

  @override
  String get syncedToRelays => 'Sincronizado con los relés';

  @override
  String get notYetSynced => 'Aún no sincronizado';

  @override
  String get deleteEventTitle => '¿Eliminar el evento?';

  @override
  String get deleteEventBody =>
      'Esto elimina el evento de este dispositivo y solicita su eliminación en los relés.';

  @override
  String get editEventTitle => 'Editar evento';

  @override
  String get newEventTitle => 'Nuevo evento';

  @override
  String get fieldTitle => 'Título';

  @override
  String get allDaySwitch => 'Todo el día';

  @override
  String get startsLabel => 'Empieza';

  @override
  String get endsLabel => 'Termina';

  @override
  String get timezoneLabel => 'Zona horaria';

  @override
  String get repeatsLabel => 'Repetición';

  @override
  String get untilLabel => 'Hasta';

  @override
  String get foreverLabel => 'Para siempre';

  @override
  String get remindersLabel => 'Recordatorios';

  @override
  String get addChip => 'Añadir';

  @override
  String get colorLabel => 'Color';

  @override
  String get locationLabel => 'Ubicación';

  @override
  String get descriptionLabel => 'Descripción';

  @override
  String couldNotSaveEvent(String error) {
    return 'No se pudo guardar el evento: $error';
  }

  @override
  String get recurrenceNone => 'No se repite';

  @override
  String get recurrenceDaily => 'A diario';

  @override
  String get recurrenceWeekly => 'Cada semana';

  @override
  String get recurrenceMonthly => 'Cada mes';

  @override
  String get recurrenceYearly => 'Cada año';

  @override
  String get reminderAtStart => 'Al empezar';

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
      other: '$count días antes',
      one: '1 día antes',
    );
    return '$_temp0';
  }

  @override
  String get getStarted => 'Empezar';

  @override
  String get useOffline => 'Usar sin conexión';

  @override
  String get welcomeTitle => 'Bienvenido a Astraea';

  @override
  String get welcomeSubtitle =>
      'Un calendario privado y sin conexión por defecto que te deja el control.';

  @override
  String get featureLocalTitle => 'Tu calendario permanece en tu dispositivo';

  @override
  String get featureLocalBody =>
      'Crea eventos, repeticiones y recordatorios sin cuenta ni conexión a internet.';

  @override
  String get featureSyncTitle => 'Sincronización opcional a través de Nostr';

  @override
  String get featureSyncBody =>
      'Conecta una cuenta para hacer copia de seguridad de tu calendario y usarlo en varios dispositivos a través de los relés que elijas.';

  @override
  String get featureEncryptedTitle => 'Siempre cifrado antes de subirlo';

  @override
  String get featureEncryptedBody =>
      'El contenido del calendario se cifra de extremo a extremo antes de salir de este dispositivo. Los operadores de los relés no pueden leerlo.';

  @override
  String get featureAmberTitle => 'Guarda tu clave en Amber';

  @override
  String get featureAmberBody =>
      'En Android, un firmante externo puede aprobar el acceso sin exponer tu clave privada a Astraea.';

  @override
  String get featureRemindersTitle => 'Recordatorios locales privados';

  @override
  String get featureRemindersBody =>
      'Las notificaciones son programadas por tu dispositivo y no dependen de un servicio de calendario en la nube.';

  @override
  String get connectNostrAccountTitle => 'Conectar una cuenta Nostr';

  @override
  String get connectNostrAccountBody =>
      'Esto solo es necesario para la sincronización cifrada. También puedes usar Astraea completamente sin conexión.';

  @override
  String get chooseRelaysTitle => 'Elige relés para la sincronización';

  @override
  String get chooseRelaysBody =>
      'Los relés almacenan tu calendario cifrado y lo ponen a disposición en tus otros dispositivos. Añade uno o más, o deja la lista vacía y configúrala más tarde.';

  @override
  String couldNotLoadRelaySettings(String error) {
    return 'No se pudieron cargar los ajustes de los relés: $error';
  }

  @override
  String get suggestedRelays => 'Sugeridos';

  @override
  String get addRelayTooltip => 'Añadir relé';

  @override
  String get customRelayLabel => 'Relé personalizado';

  @override
  String get customRelayHint => 'wss://relay.example.com';

  @override
  String get selectedRelays => 'Seleccionados';

  @override
  String get removeRelayTooltip => 'Quitar relé';

  @override
  String get invalidRelayUrl =>
      'Introduce una URL wss:// válida (o ws:// para un relé privado).';

  @override
  String get insecureRelayWarning =>
      'ws:// no está cifrado en tránsito — úsalo solo para un relé de confianza.';

  @override
  String get nostrAccountConnected => 'Cuenta Nostr conectada';

  @override
  String get invalidPrivateKey =>
      'Esa clave privada no es válida. Compruébala e inténtalo de nuevo.';

  @override
  String couldNotSignIn(String error) {
    return 'No se pudo iniciar sesión: $error';
  }

  @override
  String get signInWithAmber => 'Iniciar sesión con Amber';

  @override
  String get createNewAccount => 'Crear una cuenta nueva';

  @override
  String get generatedAccountWarning =>
      'Una cuenta generada solo se puede recuperar con su clave privada. Haz una copia de seguridad desde Ajustes tras la configuración.';

  @override
  String get importExistingKey => 'Importar una clave existente';

  @override
  String get privateKeyFieldLabel => 'nsec o clave privada hexadecimal';

  @override
  String get importButton => 'Importar';

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
  String get followDeviceTimezone => 'Seguir la zona horaria del dispositivo';

  @override
  String get searchCityRegion => 'Buscar una ciudad o región';

  @override
  String get noMatchingTimezone => 'No hay ninguna zona horaria coincidente.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String couldNotLoadSettings(String error) {
    return 'No se pudieron cargar los ajustes:\n$error';
  }

  @override
  String get sectionAccount => 'Cuenta';

  @override
  String get sectionSync => 'Sincronización';

  @override
  String get sectionRelays => 'Relés';

  @override
  String get sectionAppearance => 'Apariencia';

  @override
  String get sectionData => 'Datos';

  @override
  String get sectionRemindersTimezone => 'Recordatorios y zona horaria';

  @override
  String get sectionSupport => 'Apoyo';

  @override
  String somethingWentWrong(String error) {
    return 'Algo salió mal: $error';
  }

  @override
  String get offlineNoAccount => 'Sin conexión — sin cuenta';

  @override
  String get signInToSyncAcrossDevices =>
      'Inicia sesión para sincronizar tu calendario cifrado entre dispositivos.';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signedInWithAmber => 'Sesión iniciada con Amber';

  @override
  String get signedIn => 'Sesión iniciada';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get backUpPrivateKey => 'Copia de seguridad de la clave privada';

  @override
  String get revealNsecSubtitle =>
      'Revela tu nsec para guardarla en un lugar seguro';

  @override
  String get signOutTitle => '¿Cerrar sesión?';

  @override
  String get signOutBody =>
      'Tus eventos permanecen en este dispositivo y en los relés. Asegúrate de haber hecho una copia de seguridad de tu clave privada — sin ella, una cuenta generada no se puede recuperar.';

  @override
  String get noPrivateKeyStored =>
      'No hay ninguna clave privada guardada para esta sesión.';

  @override
  String get yourPrivateKeyTitle => 'Tu clave privada (nsec)';

  @override
  String get nsecWarning =>
      'Cualquiera que tenga esta clave controla tu cuenta. Nunca la compartas; guárdala en un gestor de contraseñas.';

  @override
  String get copy => 'Copiar';

  @override
  String get done => 'Hecho';

  @override
  String get syncNowTitle => 'Sincronizar ahora';

  @override
  String get signInToSyncSubtitle =>
      'Inicia sesión para sincronizar tu calendario cifrado.';

  @override
  String get addRelayToSyncSubtitle =>
      'Añade al menos un relé para sincronizar.';

  @override
  String get syncingEllipsis => 'Sincronizando…';

  @override
  String get synced => 'Sincronizado';

  @override
  String lastSyncedLabel(String when) {
    return 'Última sincronización $when';
  }

  @override
  String lastSyncFailedLabel(String error) {
    return 'Falló la última sincronización: $error';
  }

  @override
  String get pullMergePublish => 'Descarga, combina y publica tus eventos';

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
  String get addRelay => 'Añadir relé';

  @override
  String get suggestedRelaysTitle => 'Relés sugeridos';

  @override
  String get addOnlyRelaysYouWant => 'Añade solo los relés que quieras usar.';

  @override
  String get homeRelayBackup => 'Relé personal (copia de seguridad)';

  @override
  String get homeRelayNotConfigured =>
      'No configurado — un relé personal adicional para hacer copia de seguridad de tus eventos';

  @override
  String get homeRelayDialogTitle => 'Relé personal';

  @override
  String get lightTheme => 'Tema claro';

  @override
  String get darkThemeDefault =>
      'Astraea usa el tema oscuro de forma predeterminada';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get systemLanguage => 'Idioma del sistema';

  @override
  String get accentColorLabel => 'Color de acento';

  @override
  String get accentNavy => 'Azul marino';

  @override
  String get accentBitcoin => 'Naranja Bitcoin';

  @override
  String get accentNostr => 'Morado Nostr';

  @override
  String get exportEvents => 'Exportar eventos';

  @override
  String get exportEventsSubtitle =>
      'Guardar un archivo .ics — opcionalmente protegido con contraseña';

  @override
  String get importEvents => 'Importar eventos';

  @override
  String get importEventsSubtitle =>
      'Desde un archivo .ics o una exportación cifrada de Astraea';

  @override
  String get encryptExportTitle => '¿Cifrar esta exportación?';

  @override
  String get encryptExportBody =>
      'Un archivo .ics simple puede abrirse con cualquier aplicación de calendario — y por cualquiera que lo obtenga. Establece una contraseña para cifrarlo (solo Astraea podrá volver a importarlo).';

  @override
  String get exportPasswordLabel =>
      'Contraseña (déjalo vacío para un .ics simple)';

  @override
  String get export => 'Exportar';

  @override
  String get encryptedExportSaved => 'Exportación cifrada guardada.';

  @override
  String get exportSaved => 'Exportación guardada.';

  @override
  String exportFailed(String error) {
    return 'Error al exportar: $error';
  }

  @override
  String get couldNotReadSelectedFile =>
      'No se pudo leer el archivo seleccionado.';

  @override
  String get selectedFileTooLarge =>
      'El archivo seleccionado supera los 10 MB.';

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
    return 'Error al importar: $error';
  }

  @override
  String get thisExportIsEncrypted => 'Esta exportación está cifrada';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get wrongPassword => 'Contraseña incorrecta.';

  @override
  String get invalidEncryptedExport => 'Esta exportación cifrada no es válida.';

  @override
  String get reminders => 'Recordatorios';

  @override
  String get scheduleLocalNotifications =>
      'Programar notificaciones locales para recordatorios de eventos';

  @override
  String get timezone => 'Zona horaria';

  @override
  String followDeviceTimezoneWithName(String zone) {
    return 'Seguir la zona horaria del dispositivo ($zone)';
  }

  @override
  String get supportAstraea => 'Apoyar a Astraea';

  @override
  String noLightningWalletFound(String address) {
    return 'No se encontró ninguna cartera Lightning — dirección copiada: $address';
  }

  @override
  String get desktopServiceUnreachableTitle =>
      'Servicio en segundo plano de Astraea no disponible';

  @override
  String get desktopServiceUnreachableBody =>
      'La aplicación de escritorio se comunica con astraea-service a través de D-Bus para el almacenamiento, la sincronización y las notificaciones, y no se pudo contactar. Si lo estás ejecutando desde el código fuente, instálalo con:\n\n./scripts/install-dev.sh';

  @override
  String get retry => 'Reintentar';

  @override
  String get calendarsLabel => 'Calendarios';

  @override
  String calendarsUnavailable(String error) {
    return 'Calendarios no disponibles: $error';
  }

  @override
  String get serviceUnreachable => 'Servicio inaccesible';

  @override
  String syncStatusLabel(String status) {
    return 'Sincronización: $status';
  }

  @override
  String syncPendingSuffix(int count) {
    return ' ($count pendientes)';
  }

  @override
  String get localOnlyMode => 'Modo solo local (sin identidad Nostr)';

  @override
  String get syncStarted => 'Sincronización iniciada';

  @override
  String syncUnavailable(String error) {
    return 'Sincronización no disponible: $error';
  }

  @override
  String get notSignedIn => 'Sesión no iniciada';

  @override
  String get signInWithBrowserSubtitle =>
      'Inicia sesión con tu navegador (NIP-07) para sincronizar este calendario a través de Nostr.';

  @override
  String get signedInBackgroundSigning =>
      'Sesión iniciada — firma en segundo plano mediante una clave delegada';

  @override
  String get signedInRemoteSigner =>
      'Sesión iniciada — firmante remoto (NIP-46)';

  @override
  String get signedInNoBackgroundSigner =>
      'Sesión iniciada, pero no hay ningún firmante en segundo plano configurado — la sincronización queda en pausa. Ejecuta «astraea-service auth provision-key» en una terminal.';

  @override
  String couldNotStartLogin(String error) {
    return 'No se pudo iniciar el acceso: $error';
  }

  @override
  String get signOutConfirmDesktopBody =>
      'Esto olvida la cuenta solo en este dispositivo — tus eventos permanecen en los relés. Se elimina del llavero cualquier clave de firma aprovisionada.';

  @override
  String get signInWithBrowserTitle => 'Inicia sesión con tu navegador';

  @override
  String get loginSessionExpired =>
      'Esta sesión de acceso ha caducado. Inténtalo de nuevo.';

  @override
  String get loginWaitingBody =>
      'Se abrió una pestaña del navegador para confirmar tu identidad Nostr (NIP-07). Apruébala allí — este diálogo se cierra automáticamente. Nunca se solicita tu clave privada.';

  @override
  String get openAgain => 'Abrir de nuevo';

  @override
  String get offlineWillRetry =>
      'Sin conexión — se reintentará automáticamente.';

  @override
  String get upToDate => 'Actualizado';

  @override
  String operationsFailingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count operaciones fallidas',
      one: '1 operación fallida',
    );
    return '$_temp0';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pendientes',
      one: '1 pendiente',
    );
    return '$_temp0';
  }

  @override
  String pendingFailingCount(String pending, String failing) {
    return '$pending, $failing';
  }

  @override
  String get relayStatus => 'Estado de los relés';

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
  String get unencryptedTransport => 'Transporte sin cifrar';

  @override
  String couldNotReachService(String error) {
    return 'No se pudo contactar con astraea-service: $error';
  }

  @override
  String get inviteSectionTitle => 'Asistentes';

  @override
  String get inviteButtonLabel => 'Invitar';

  @override
  String get noAttendeesYet => 'Aún no se ha invitado a nadie';

  @override
  String get inviteDialogTitle => 'Invitar a alguien';

  @override
  String get inviteDialogHint => 'npub, nombre@dominio o clave pública';

  @override
  String resolvePersonFailed(String error) {
    return 'No se pudo resolver esa persona: $error';
  }

  @override
  String get confirmNip05Title => 'Confirmar destinatario';

  @override
  String confirmNip05Body(String query, String pubkey) {
    return '$query se resolvió como $pubkey mediante NIP-05. Esta asociación la controla el dominio; asegúrate de que sea la persona esperada.';
  }

  @override
  String get attendeeStatusInvited => 'Invitado';

  @override
  String get attendeeStatusAccepted => 'Aceptado';

  @override
  String get attendeeStatusDeclined => 'Rechazado';

  @override
  String inviteFailed(String error) {
    return 'No se pudo enviar la invitación: $error';
  }

  @override
  String get pendingInvitationsTooltip => 'Invitaciones';

  @override
  String get pendingInvitationsTitle => 'Invitaciones';

  @override
  String get pendingInvitationsEmpty => 'No hay invitaciones pendientes';

  @override
  String invitationFromLabel(String pubkey) {
    return 'De $pubkey';
  }

  @override
  String get acceptInvitation => 'Aceptar';

  @override
  String get declineInvitation => 'Rechazar';

  @override
  String respondToInvitationFailed(String error) {
    return 'No se pudo responder: $error';
  }

  @override
  String get invitationAccepted => 'Invitación aceptada';

  @override
  String get invitationDeclined => 'Invitación rechazada';
}
