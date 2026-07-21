import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/constants.dart';
import '../utils/relay_url.dart';
import 'desktop_providers.dart';

/// Desktop-only replacements for the mobile Account/Sync/Relay sections in
/// SettingsScreen (docs/authentication.md, docs/nostr-sync.md). On Linux,
/// identity, signing and relays belong to astraea-service — the Flutter
/// process never holds a key or a relay connection (ADR-003/006), so these
/// sections talk to the service over D-Bus instead of the local Hive/secure
/// storage the mobile widgets use.
///
/// Selected via the same conditional-import seam as `desktop_bootstrap.dart`
/// (dart.library.io); the web build gets the stub instead, where every
/// factory returns `null` and settings_screen.dart falls back to the shared
/// mobile widgets.
bool get isLinuxDesktop => Platform.isLinux;

Widget? desktopAccountSection() =>
    isLinuxDesktop ? const _DesktopAccountSection() : null;

Widget? desktopSyncSection() =>
    isLinuxDesktop ? const _DesktopSyncSection() : null;

Widget? desktopRelaySection() =>
    isLinuxDesktop ? const _DesktopRelaySection() : null;

// ── Account ──────────────────────────────────────────────────────────────

class _DesktopAccountSection extends ConsumerWidget {
  const _DesktopAccountSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(desktopAuthStatusProvider);

    return status.when(
      loading: () => const ListTile(
        leading: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        title: Text('Loading…'),
      ),
      error: (e, _) => ListTile(
        leading: const Icon(Icons.error_outline),
        title: Text('Could not reach astraea-service: $e'),
      ),
      data: (data) {
        final authenticated = data['authenticated'] == true;
        if (!authenticated) {
          return ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Not signed in'),
            subtitle: const Text(
              'Sign in with your browser (NIP-07) to sync this calendar over Nostr.',
            ),
            trailing: FilledButton(
              onPressed: () => _beginLogin(context, ref),
              child: const Text('Sign in'),
            ),
          );
        }
        final npub = data['npub'] as String? ?? '';
        final signer = data['signer'] as String? ?? 'none';
        final signerState = data['signerState'] as String? ?? 'unknown';
        return ListTile(
          leading: const Icon(Icons.verified_user_outlined),
          title: Text(_truncate(npub)),
          subtitle: Text(_signerSubtitle(signer, signerState)),
          isThreeLine: signerState != 'ready',
          trailing: TextButton(
            onPressed: () => _confirmSignOut(context, ref),
            child: const Text('Sign out'),
          ),
        );
      },
    );
  }

  String _truncate(String npub) => npub.length > 20
      ? '${npub.substring(0, 10)}…${npub.substring(npub.length - 6)}'
      : npub;

  String _signerSubtitle(String signer, String state) {
    if (state == 'ready') {
      return switch (signer) {
        'local_delegated' =>
          'Signed in — background signing via a delegated key',
        'remote_nip46' => 'Signed in — remote signer (NIP-46)',
        _ => 'Signed in',
      };
    }
    return 'Signed in, but no background signer is configured — sync stays '
        'parked. Run "astraea-service auth provision-key" in a terminal.';
  }

  Future<void> _beginLogin(BuildContext context, WidgetRef ref) async {
    final client = ref.read(dbusCalendarClientProvider);
    final Map<String, dynamic> session;
    try {
      session = await client.beginBrowserLogin();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not start login: $e')));
      }
      return;
    }
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _LoginWaitingDialog(session: session),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'This forgets the account on this device only — your events stay '
          'on the relays. A provisioned signing key, if any, is removed from '
          'the keyring.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(dbusCalendarClientProvider).logout();
    }
  }
}

/// Shown while the browser callback is pending. Closes itself as soon as
/// [desktopAuthStatusProvider] reports `authenticated: true` — the service
/// emits `AuthenticationChanged` from the callback handler, which is outside
/// any D-Bus call, so this is a signal wait, never polling.
class _LoginWaitingDialog extends ConsumerStatefulWidget {
  const _LoginWaitingDialog({required this.session});

  final Map<String, dynamic> session;

  @override
  ConsumerState<_LoginWaitingDialog> createState() =>
      _LoginWaitingDialogState();
}

class _LoginWaitingDialogState extends ConsumerState<_LoginWaitingDialog> {
  Timer? _expiryTimer;
  bool _expired = false;

  @override
  void initState() {
    super.initState();
    final expiresAt = DateTime.tryParse(
      widget.session['expiresAt'] as String? ?? '',
    );
    if (expiresAt != null) {
      final remaining = expiresAt.difference(DateTime.now());
      _expiryTimer = Timer(remaining.isNegative ? Duration.zero : remaining, () {
        if (mounted) setState(() => _expired = true);
      });
    }
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(desktopAuthStatusProvider, (previous, next) {
      if (next.value?['authenticated'] == true) {
        Navigator.of(context).pop();
      }
    });

    return AlertDialog(
      title: const Text('Sign in with your browser'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _expired
              ? const [Text('This login session expired. Try again.')]
              : const [
                  Text(
                    'A browser tab was opened to confirm your Nostr identity '
                    '(NIP-07). Approve it there — this dialog closes '
                    'automatically. Your private key is never requested.',
                  ),
                  SizedBox(height: 16),
                  Center(child: CircularProgressIndicator()),
                ],
        ),
      ),
      actions: [
        if (!_expired)
          TextButton(
            onPressed: () async {
              final url = widget.session['url'] as String?;
              if (url != null) {
                await launchUrl(
                  Uri.parse(url),
                  mode: LaunchMode.externalApplication,
                );
              }
            },
            child: const Text('Open again'),
          ),
        TextButton(
          onPressed: () async {
            final sessionId = widget.session['sessionId'] as String?;
            if (sessionId != null) {
              try {
                await ref
                    .read(dbusCalendarClientProvider)
                    .cancelBrowserLogin(sessionId);
              } catch (_) {
                // Already completed or expired server-side; closing is fine.
              }
            }
            if (context.mounted) Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

// ── Sync ─────────────────────────────────────────────────────────────────

class _DesktopSyncSection extends ConsumerWidget {
  const _DesktopSyncSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(desktopSyncStatusProvider);
    final authenticated =
        ref.watch(desktopAuthStatusProvider).value?['authenticated'] == true;
    final hasRelays = ref.watch(desktopRelaysProvider).value?.isNotEmpty ?? false;

    return sync.when(
      loading: () => const ListTile(
        leading: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        title: Text('Loading…'),
      ),
      error: (e, _) => ListTile(
        leading: const Icon(Icons.error_outline),
        title: Text('Sync status unavailable: $e'),
      ),
      data: (data) {
        final state = data['state'] as String? ?? 'idle';
        final pending = (data['pending'] as num?)?.toInt() ?? 0;
        final failed = (data['failed'] as num?)?.toInt() ?? 0;
        final network = data['networkStatus'] as String? ?? 'unknown';
        final lastError = data['lastError'] as String?;
        final relays = (data['relays'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .toList(growable: false);

        return Column(
          children: [
            ListTile(
              leading: Icon(
                state == 'syncing'
                    ? Icons.sync
                    : (failed > 0 ? Icons.sync_problem : Icons.sync),
              ),
              title: const Text('Sync now'),
              subtitle: Text(
                !authenticated
                    ? 'Sign in to sync your encrypted calendar.'
                    : !hasRelays
                    ? 'Add at least one relay below to synchronize.'
                    : _subtitle(state, pending, failed, network, lastError),
              ),
              trailing: state == 'syncing'
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              enabled: authenticated && hasRelays && state != 'syncing',
              onTap: () => _syncNow(context, ref),
            ),
            if (relays != null && relays.isNotEmpty)
              ExpansionTile(
                title: const Text('Relay status'),
                children: [
                  for (final relay in relays)
                    ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.circle,
                        size: 10,
                        color: relay['state'] == 'connected'
                            ? Colors.green
                            : Colors.grey,
                      ),
                      title: Text(relay['url'] as String? ?? ''),
                      subtitle: Text((relay['state'] as String?) ?? 'unknown'),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }

  String _subtitle(
    String state,
    int pending,
    int failed,
    String network,
    String? lastError,
  ) {
    if (network == 'offline') return 'Offline — will retry automatically.';
    if (state == 'syncing') return 'Syncing…';
    if (lastError != null && lastError.isNotEmpty) return lastError;
    if (pending == 0) {
      return failed > 0 ? '$failed operation(s) failing' : 'Up to date';
    }
    return '$pending pending${failed > 0 ? ', $failed failing' : ''}';
  }

  Future<void> _syncNow(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(dbusCalendarClientProvider).syncNow();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Sync unavailable: $e')));
    }
  }
}

// ── Relays ───────────────────────────────────────────────────────────────

class _DesktopRelaySection extends ConsumerWidget {
  const _DesktopRelaySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relaysAsync = ref.watch(desktopRelaysProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return relaysAsync.when(
      loading: () => const ListTile(
        leading: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        title: Text('Loading…'),
      ),
      error: (e, _) => ListTile(
        leading: const Icon(Icons.error_outline),
        title: Text('Relays unavailable: $e'),
      ),
      data: (relays) => ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        backgroundColor: colorScheme.surfaceContainerHigh,
        collapsedBackgroundColor: Colors.transparent,
        leading: const Icon(Icons.dns_outlined),
        title: const Text('Relays'),
        subtitle: Text('${relays.length} configured'),
        initiallyExpanded: relays.isEmpty,
        children: [
          for (final url in relays)
            ListTile(
              leading: Icon(
                isInsecureRelayUrl(url) ? Icons.lock_open : Icons.circle,
                size: isInsecureRelayUrl(url) ? 18 : 10,
                color: isInsecureRelayUrl(url) ? colorScheme.error : null,
              ),
              title: Text(url),
              subtitle: isInsecureRelayUrl(url)
                  ? const Text('Unencrypted transport')
                  : null,
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => ref
                    .read(desktopRelaysProvider.notifier)
                    .save(relays.where((r) => r != url).toList()),
              ),
            ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Add relay'),
            onTap: () => _addRelay(context, ref, relays),
          ),
          if (AppConstants.defaultRelays.any((r) => !relays.contains(r))) ...[
            const Divider(),
            const ListTile(dense: true, title: Text('Suggested relays')),
            for (final url in AppConstants.defaultRelays)
              if (!relays.contains(url))
                ListTile(
                  leading: const Icon(Icons.dns_outlined),
                  title: Text(Uri.parse(url).host),
                  subtitle: Text(url),
                  trailing: IconButton(
                    tooltip: 'Add relay',
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => ref
                        .read(desktopRelaysProvider.notifier)
                        .save([...relays, url]),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  Future<void> _addRelay(
    BuildContext context,
    WidgetRef ref,
    List<String> relays,
  ) async {
    final input = await _promptForRelayUrl(context);
    if (input == null || input.isEmpty) return;
    final url = normalizeRelayUrl(input);
    if (url == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Enter a valid wss:// (or ws:// for a private relay) URL.',
            ),
          ),
        );
      }
      return;
    }
    if (isInsecureRelayUrl(url) && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ws:// is unencrypted in transit — only use it for a relay you trust.',
          ),
        ),
      );
    }
    if (relays.contains(url)) return;
    await ref.read(desktopRelaysProvider.notifier).save([...relays, url]);
  }
}

Future<String?> _promptForRelayUrl(BuildContext context) async {
  final controller = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Add relay'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'wss://relay.example.com',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
          child: const Text('Save'),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}
