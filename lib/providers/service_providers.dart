import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/calendar_sync_service.dart';
import '../services/export_encryption_service.dart';
import '../services/file_cache_service.dart';
import '../services/home_widget_service.dart';
import '../services/local_storage_service.dart';
import '../services/notification_service.dart';
import '../services/nostr_service.dart';

/// Providers for the "infrastructure" services — each a singleton for the
/// app's lifetime. Kept separate from the state providers so those can
/// depend on services via `ref.read`/`ref.watch`, and tests can override
/// them with `overrideWith`.

final exportEncryptionServiceProvider = Provider<ExportEncryptionService>((
  ref,
) {
  return ExportEncryptionService();
});

final fileCacheServiceProvider = Provider<FileCacheService>((ref) {
  return FileCacheService();
});

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService(
    exportEncryptionService: ref.watch(exportEncryptionServiceProvider),
  );
});

final nostrServiceProvider = Provider<NostrService>((ref) {
  return NostrService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(
    localStorageService: ref.watch(localStorageServiceProvider),
  );
});

final homeWidgetServiceProvider = Provider<HomeWidgetService>((ref) {
  return HomeWidgetService();
});

final calendarSyncServiceProvider = Provider<CalendarSyncService>((ref) {
  return CalendarSyncService(
    localStorageService: ref.watch(localStorageServiceProvider),
    nostrService: ref.watch(nostrServiceProvider),
  );
});
