import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dbus_calendar_client.dart';
import 'desktop_providers.dart';

/// Desktop chrome around the shared calendar UI: a sidebar with the service
/// calendars and live service/sync status, plus a clear full-screen recovery
/// state when the background service is unreachable.
///
/// The sidebar only appears on wide windows; narrow windows keep the shared
/// (mobile) layout untouched.
class DesktopShell extends ConsumerWidget {
  const DesktopShell({super.key, required this.child});

  final Widget child;

  static const double _sidebarBreakpoint = 900;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(serviceStatusProvider);

    if (status.hasError && status.error is ServiceUnavailableException) {
      return _ServiceUnavailableScreen(
        detail: status.error.toString(),
        onRetry: () => ref.read(serviceStatusProvider.notifier).retry(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _sidebarBreakpoint) return child;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: 264, child: _Sidebar(status: status)),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar({required this.status});

  final AsyncValue<Map<String, dynamic>> status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendars = ref.watch(desktopCalendarsProvider);
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.nightlight_round,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Text('Astraea', style: theme.textTheme.titleLarge),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text(
                'Calendars',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: calendars.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Calendars unavailable: $e',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                data: (list) => ListView(
                  children: [
                    for (final calendar in list)
                      ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.circle,
                          size: 14,
                          color: _parseColor(calendar['color'] as String?),
                        ),
                        title: Text(calendar['name'] as String? ?? ''),
                      ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            _StatusTile(status: status),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String? raw) {
    if (raw == null) return const Color(0xFF3F51B5);
    final value = int.tryParse(raw.replaceFirst('0x', ''), radix: 16);
    return value == null ? const Color(0xFF3F51B5) : Color(value);
  }
}

class _StatusTile extends ConsumerWidget {
  const _StatusTile({required this.status});

  final AsyncValue<Map<String, dynamic>> status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final data = status.value;
    final authenticated = data?['authenticated'] == true;
    final pending = data?['pendingOperations'] ?? 0;
    final syncStatus = data?['syncStatus'] as String? ?? 'unknown';

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                status.hasError
                    ? Icons.cloud_off
                    : (pending == 0 ? Icons.cloud_done : Icons.cloud_upload),
                size: 18,
                color: status.hasError
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  status.hasError
                      ? 'Service unreachable'
                      : 'Sync: $syncStatus'
                            '${pending == 0 ? '' : ' ($pending pending)'}',
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                authenticated ? Icons.key : Icons.key_off,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  authenticated
                      ? (data?['activeAccount'] as String? ?? 'Signed in')
                      : 'Local-only mode (no Nostr identity)',
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await ref.read(dbusCalendarClientProvider).syncNow();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Sync started')),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Sync unavailable: $e')),
                  );
                }
              },
              icon: const Icon(Icons.sync, size: 18),
              label: const Text('Sync now'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceUnavailableScreen extends StatelessWidget {
  const _ServiceUnavailableScreen({
    required this.detail,
    required this.onRetry,
  });

  final String detail;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.dns_outlined,
                  size: 56,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Astraea background service unavailable',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'The desktop app talks to astraea-service over D-Bus for '
                  'storage, sync and notifications, and it could not be '
                  'reached. If you are running from source, install it '
                  'with:\n\n./scripts/install-dev.sh',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  detail,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
