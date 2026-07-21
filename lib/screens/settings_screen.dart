import 'dart:convert';

import 'package:cryptography/cryptography.dart'
    show SecretBoxAuthenticationError;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show Clipboard, ClipboardData, MethodChannel;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

import '../desktop/desktop_settings_sections_stub.dart'
    if (dart.library.io) '../desktop/desktop_settings_sections.dart'
    as desktop_settings;
import '../models/app_settings.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/events_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/service_providers.dart';
import '../providers/settings_provider.dart';
import '../providers/sync_provider.dart';
import '../providers/theme_provider.dart';
import '../services/local_storage_service.dart';
import '../utils/constants.dart';
import '../utils/formatter.dart';
import '../utils/relay_url.dart';
import 'entry_screen.dart';
import 'widgets/timezone_picker.dart';

const _privacyChannel = MethodChannel('com.example.astraea/privacy');

/// App-wide settings: Nostr account, sync + relays (including the personal/
/// home backup relay), appearance, data export/import, notifications/timezone,
/// and the developer donation tile. Section layout mirrors Echoes' settings
/// screen.
///
/// The home-screen widgets deliberately have no section here: they're added the
/// standard Android way (long-press the home screen → Widgets) and keep
/// themselves up to date without the app.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Could not load settings:\n$e',
            textAlign: TextAlign.center,
          ),
        ),
        data: (settings) => ListView(
          children: [
            const _SectionHeader('Account'),
            desktop_settings.desktopAccountSection() ?? const _AccountSection(),
            const _SectionHeader('Sync'),
            desktop_settings.desktopSyncSection() ??
                _SyncSection(settings: settings),
            const _SectionHeader('Relays'),
            desktop_settings.desktopRelaySection() ??
                _RelaySection(settings: settings),
            const _SectionHeader('Appearance'),
            const _AppearanceSection(),
            const _SectionHeader('Data'),
            const _DataSection(),
            const _SectionHeader('Reminders & timezone'),
            _RemindersSection(settings: settings),
            const _SectionHeader('Support'),
            const _DonationTile(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

// ── Account ──────────────────────────────────────────────────────────────

class _AccountSection extends ConsumerWidget {
  const _AccountSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      loading: () => const ListTile(
        leading: CircularProgressIndicator(strokeWidth: 2),
        title: Text('Loading…'),
      ),
      error: (error, _) => ListTile(
        leading: const Icon(Icons.error_outline),
        title: Text('Something went wrong: $error'),
      ),
      data: (user) {
        if (user == null) {
          // Offline, local-only session: offer to add an account to sync.
          return ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Offline — no account'),
            subtitle: const Text(
              'Sign in to sync your encrypted calendar across devices.',
            ),
            trailing: FilledButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const EntryScreen())),
              child: const Text('Sign in'),
            ),
          );
        }

        // Best-effort niceties on top of the always-available npub: a display
        // name and avatar from the account's public kind-0 profile, when one
        // could be fetched. Both fall back cleanly (truncated npub / plain
        // icon) while loading or on failure — this row must never block.
        final profile = ref.watch(profileProvider).value;
        final avatarUrl = profile?.picture;
        final avatarFile = avatarUrl != null
            ? ref.watch(avatarFileProvider(avatarUrl)).value
            : null;
        final displayName = profile?.label ?? Formatter.truncateKey(user.npub);

        return Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: avatarFile != null
                    ? FileImage(avatarFile)
                    : null,
                child: avatarFile == null
                    ? Icon(
                        user.loginMethod == LoginMethod.amber
                            ? Icons.shield_outlined
                            : Icons.verified_user_outlined,
                      )
                    : null,
              ),
              title: Text(displayName),
              subtitle: Text(
                user.loginMethod == LoginMethod.amber
                    ? 'Signed in with Amber'
                    : 'Signed in',
              ),
              trailing: TextButton(
                onPressed: () => _confirmSignOut(context, ref),
                child: const Text('Sign out'),
              ),
            ),
            // Backing up the key only applies when Astraea holds it — with
            // Amber the key lives in the signer, not here.
            if (user.loginMethod.isLocalKey)
              ListTile(
                leading: const Icon(Icons.vpn_key_outlined),
                title: const Text('Back up private key'),
                subtitle: const Text(
                  'Reveal your nsec to save it somewhere safe',
                ),
                onTap: () => _backupPrivateKey(context, ref),
              ),
          ],
        );
      },
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'Your events stay on this device and on the relays. Make sure you have backed up '
          'your private key — without it a generated account cannot be recovered.',
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
      await ref.read(authProvider.notifier).logout();
    }
  }

  /// Reveals the account's private key as an `nsec` so the user can back it
  /// up — the only way to recover a generated account. Read on demand from
  /// secure storage; never held in provider state.
  Future<void> _backupPrivateKey(BuildContext context, WidgetRef ref) async {
    final privateKeyHex = await ref
        .read(localStorageServiceProvider)
        .loadPrivateKey();
    if (privateKeyHex == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No private key stored for this session.'),
          ),
        );
      }
      return;
    }
    final nsec = ref.read(nostrServiceProvider).privateKeyToNsec(privateKeyHex);
    if (!context.mounted) return;
    try {
      await _privacyChannel.invokeMethod<void>('setSecure', true);
    } catch (_) {
      // Non-Android platforms don't expose the native privacy channel.
    }
    if (!context.mounted) return;
    try {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Your private key (nsec)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Anyone with this key controls your account. Never share it; store it in a password manager.',
              ),
              const SizedBox(height: 16),
              SelectableText(
                nsec,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await _privacyChannel.invokeMethod<void>(
                    'copySensitive',
                    nsec,
                  );
                } catch (_) {
                  await Clipboard.setData(ClipboardData(text: nsec));
                }
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Copy'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } finally {
      try {
        await _privacyChannel.invokeMethod<void>('setSecure', false);
      } catch (_) {
        // Non-Android platform.
      }
    }
  }
}

// ── Sync ─────────────────────────────────────────────────────────────────

class _SyncSection extends ConsumerWidget {
  const _SyncSection({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(syncProvider);
    final signedIn = ref.watch(authProvider).value != null;
    final hasRelays = settings.allSyncRelays.isNotEmpty;

    return ListTile(
      leading: const Icon(Icons.sync),
      title: const Text('Sync now'),
      subtitle: Text(
        !signedIn
            ? 'Sign in to sync your encrypted calendar.'
            : !hasRelays
            ? 'Add at least one relay to synchronize.'
            : _syncSubtitle(sync),
      ),
      trailing: sync.status == SyncStatus.syncing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      enabled: signedIn && hasRelays && sync.status != SyncStatus.syncing,
      onTap: () => ref.read(syncProvider.notifier).syncNow(),
    );
  }

  String _syncSubtitle(SyncState sync) {
    switch (sync.status) {
      case SyncStatus.syncing:
        return 'Syncing…';
      case SyncStatus.success:
        final at = sync.lastSyncedAt;
        return at == null
            ? 'Synced'
            : 'Last synced ${Formatter.fullLabel(at.toUtc(), tz.local.name)}';
      case SyncStatus.error:
        return 'Last sync failed: ${sync.errorMessage}';
      case SyncStatus.idle:
        return 'Pull, merge and publish your events';
    }
  }
}

// ── Relays ───────────────────────────────────────────────────────────────

class _RelaySection extends ConsumerWidget {
  const _RelaySection({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          backgroundColor: colorScheme.surfaceContainerHigh,
          collapsedBackgroundColor: Colors.transparent,
          leading: const Icon(Icons.dns_outlined),
          title: const Text('Public relays'),
          subtitle: Text('${settings.relays.length} configured'),
          children: [
            ...settings.relays.map(
              (url) => ListTile(
                leading: const Icon(Icons.circle, size: 10),
                title: Text(url),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => _save(
                    ref,
                    settings.copyWith(
                      relays: settings.relays.where((r) => r != url).toList(),
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add relay'),
              onTap: () async {
                final input = await _promptForText(
                  context,
                  title: 'Add relay',
                  hint: 'wss://relay.example.com',
                );
                if (input == null || input.isEmpty) return;
                final url = _validRelayUrl(input);
                if (url == null) {
                  if (context.mounted) _showInvalidRelay(context);
                  return;
                }
                if (context.mounted) _warnIfInsecure(context, url);
                if (settings.relays.contains(url)) return;
                await _save(
                  ref,
                  settings.copyWith(relays: [...settings.relays, url]),
                );
              },
            ),
            if (AppConstants.defaultRelays.any(
              (relay) => !settings.relays.contains(relay),
            )) ...[
              const Divider(),
              const ListTile(
                dense: true,
                title: Text('Suggested relays'),
                subtitle: Text('Add only the relays you want to use.'),
              ),
              for (final url in AppConstants.defaultRelays)
                if (!settings.relays.contains(url))
                  ListTile(
                    leading: const Icon(Icons.dns_outlined),
                    title: Text(Uri.parse(url).host),
                    subtitle: Text(url),
                    trailing: IconButton(
                      tooltip: 'Add relay',
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => _save(
                        ref,
                        settings.copyWith(relays: [...settings.relays, url]),
                      ),
                    ),
                  ),
            ],
          ],
        ),
        ListTile(
          leading: const Icon(Icons.home_outlined),
          title: const Text('Home relay (backup)'),
          subtitle: Text(
            settings.homeRelayUrl?.isNotEmpty == true
                ? settings.homeRelayUrl!
                : 'Not configured — an additional personal relay to back up your events',
          ),
          trailing: const Icon(Icons.edit_outlined),
          onTap: () async {
            final input = await _promptForText(
              context,
              title: 'Home relay',
              hint: 'wss://relay.myhome.net',
              initial: settings.homeRelayUrl,
            );
            if (input == null) return;
            if (input.isEmpty) {
              await _save(ref, settings.copyWith(clearHomeRelay: true));
              return;
            }
            final url = _validRelayUrl(input);
            if (url == null) {
              if (context.mounted) _showInvalidRelay(context);
              return;
            }
            if (context.mounted) _warnIfInsecure(context, url);
            await _save(ref, settings.copyWith(homeRelayUrl: url));
          },
        ),
      ],
    );
  }

  Future<void> _save(WidgetRef ref, AppSettings updated) =>
      ref.read(settingsProvider.notifier).save(updated);

  /// Accepts `wss://` (recommended) or `ws://` URLs (returned normalized),
  /// null otherwise. `ws://` is allowed — self-hosted/personal relays often
  /// have no TLS certificate — but flagged via [_warnIfInsecure]; event
  /// content stays end-to-end encrypted regardless of transport.
  String? _validRelayUrl(String input) => normalizeRelayUrl(input);

  void _showInvalidRelay(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Enter a valid wss:// (or ws:// for a private relay) URL.'),
      ),
    );
  }

  void _warnIfInsecure(BuildContext context, String url) {
    if (!isInsecureRelayUrl(url)) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'ws:// is unencrypted in transit — only use it for a relay you trust.',
        ),
      ),
    );
  }
}

// ── Appearance ───────────────────────────────────────────────────────────

class _AppearanceSection extends ConsumerWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return SwitchListTile(
      secondary: Icon(
        themeMode == ThemeMode.light
            ? Icons.light_mode_outlined
            : Icons.dark_mode_outlined,
      ),
      title: const Text('Light theme'),
      subtitle: const Text('Astraea uses the dark theme by default'),
      value: themeMode == ThemeMode.light,
      onChanged: (value) => ref
          .read(themeModeProvider.notifier)
          .setThemeMode(value ? ThemeMode.light : ThemeMode.dark),
    );
  }
}

// ── Data (export / import) ───────────────────────────────────────────────

class _DataSection extends ConsumerWidget {
  const _DataSection();

  static const _maxImportBytes = 10 * 1024 * 1024;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.upload_outlined),
          title: const Text('Export events'),
          subtitle: const Text(
            'Save a .ics file — optionally password-encrypted',
          ),
          onTap: () => _export(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.download_outlined),
          title: const Text('Import events'),
          subtitle: const Text(
            'From a .ics file or an encrypted Astraea export',
          ),
          onTap: () => _import(context, ref),
        ),
      ],
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final password = await _askExportPassword(context);
    if (password == null) return; // Cancelled.

    try {
      final content = await ref
          .read(localStorageServiceProvider)
          .exportEventsAsIcs(password: password.isEmpty ? null : password);
      final encrypted = password.isNotEmpty;
      final stamp = DateTime.now().toIso8601String().split('T').first;
      final bytes = utf8.encode(content);

      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Save your calendar export',
        fileName: encrypted ? 'astraea-$stamp.ics.json' : 'astraea-$stamp.ics',
        bytes: bytes,
      );
      if (path == null) return; // Cancelled.
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              encrypted ? 'Encrypted export saved.' : 'Export saved.',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  /// Empty string = export unencrypted; null = the user cancelled.
  Future<String?> _askExportPassword(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Encrypt this export?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A plain .ics can be opened by any calendar app — and by anyone who gets the file. '
              'Set a password to encrypt it (only Astraea will be able to import it back).',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Password (leave empty for a plain .ics)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Export'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['ics', 'json'],
        withData: true,
      );
      final picked = result?.files.single;
      if (picked == null) return;
      final fileBytes = picked.bytes;
      if (fileBytes == null) {
        throw StateError('Could not read the selected file.');
      }
      if (fileBytes.length > _maxImportBytes) {
        throw StateError('The selected file is larger than 10 MB.');
      }
      final raw = utf8.decode(fileBytes);
      final defaultTimezone =
          ref.read(settingsProvider).value?.timezone ?? tz.local.name;

      final int? count;
      if (LocalStorageService.isExportEncrypted(raw)) {
        if (!context.mounted) return;
        count = await _importEncrypted(context, ref, raw, defaultTimezone);
        if (count == null) return; // Password dialog cancelled.
      } else {
        count = await ref
            .read(eventsProvider.notifier)
            .importFromIcs(raw, defaultTimezone: defaultTimezone);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Imported $count event(s).')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    }
  }

  /// Password prompt for an encrypted export — stays open and shows an inline
  /// "wrong password" on a failed attempt rather than closing and forcing the
  /// whole file-picker flow to be redone. Returns the imported count, or null
  /// if cancelled.
  Future<int?> _importEncrypted(
    BuildContext context,
    WidgetRef ref,
    String raw,
    String defaultTimezone,
  ) async {
    final controller = TextEditingController();
    var submitting = false;
    String? errorText;

    final count = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('This export is encrypted'),
          content: TextField(
            controller: controller,
            obscureText: true,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Password',
              errorText: errorText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: submitting ? null : () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: submitting
                  ? null
                  : () async {
                      setState(() {
                        submitting = true;
                        errorText = null;
                      });
                      try {
                        final imported = await ref
                            .read(eventsProvider.notifier)
                            .importFromIcs(
                              raw,
                              password: controller.text,
                              defaultTimezone: defaultTimezone,
                            );
                        if (ctx.mounted) Navigator.of(ctx).pop(imported);
                      } on SecretBoxAuthenticationError {
                        if (!ctx.mounted) return;
                        setState(() {
                          submitting = false;
                          errorText = 'Wrong password.';
                        });
                      } catch (_) {
                        if (!ctx.mounted) return;
                        setState(() {
                          submitting = false;
                          errorText = 'This encrypted export is not valid.';
                        });
                      }
                    },
              child: const Text('Import'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    return count;
  }
}

// ── Reminders & timezone ─────────────────────────────────────────────────

class _RemindersSection extends ConsumerWidget {
  const _RemindersSection({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.notifications_outlined),
          title: const Text('Reminders'),
          subtitle: const Text(
            'Schedule local notifications for event reminders',
          ),
          value: settings.notificationsEnabled,
          onChanged: (v) => ref
              .read(settingsProvider.notifier)
              .save(settings.copyWith(notificationsEnabled: v)),
        ),
        ListTile(
          leading: const Icon(Icons.public),
          title: const Text('Timezone'),
          subtitle: Text(
            settings.timezone ?? 'Follow device timezone (${tz.local.name})',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            final zone = await showTimezonePicker(
              context,
              current: settings.timezone,
            );
            if (zone == null) return; // Dismissed.
            await ref
                .read(settingsProvider.notifier)
                .save(
                  zone.isEmpty
                      ? settings.copyWith(clearTimezone: true)
                      : settings.copyWith(timezone: zone),
                );
          },
        ),
      ],
    );
  }
}

// ── Support ──────────────────────────────────────────────────────────────

/// Hands a `lightning:` URI to whatever wallet app is installed (it resolves
/// the Lightning address itself via LNURL-pay — no QR code or in-app invoice
/// fetching needed). Falls back to copying the address if no wallet is
/// installed to handle the URI. Same approach as Echoes' donation tile.
class _DonationTile extends StatelessWidget {
  const _DonationTile();

  Future<void> _donate(BuildContext context) async {
    final uri = Uri.parse('lightning:${AppConstants.lightningAddress}');
    var launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      launched = false;
    }
    if (launched) return;

    await Clipboard.setData(
      const ClipboardData(text: AppConstants.lightningAddress),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No Lightning wallet found — address copied: ${AppConstants.lightningAddress}',
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _donate(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(Icons.bolt_rounded, color: colorScheme.primary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Support Astraea',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppConstants.lightningAddress,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new_rounded,
              size: 14,
              color: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared ───────────────────────────────────────────────────────────────

Future<String?> _promptForText(
  BuildContext context, {
  required String title,
  required String hint,
  String? initial,
}) async {
  final controller = TextEditingController(text: initial ?? '');
  final result = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: hint,
          border: const OutlineInputBorder(),
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
