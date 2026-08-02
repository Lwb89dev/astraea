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
import '../l10n/app_localizations.dart';
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
import '../utils/app_accent.dart';
import '../utils/constants.dart';
import '../utils/formatter.dart';
import '../utils/relay_url.dart';
import 'entry_screen.dart';
import 'widgets/timezone_picker.dart';

const _privacyChannel = MethodChannel('com.example.astraea/privacy');

/// Native display name for each supported UI language, keyed by IETF tag —
/// shown in its own language (so a user finds their language regardless of
/// what the app is currently displaying), sourced from
/// AppLocalizations.supportedLocales (generated from lib/l10n/*.arb).
const Map<String, String> _languageNativeNames = {
  'bg': 'Български',
  'cs': 'Čeština',
  'da': 'Dansk',
  'de': 'Deutsch',
  'el': 'Ελληνικά',
  'en': 'English',
  'es': 'Español',
  'et': 'Eesti',
  'fi': 'Suomi',
  'fr': 'Français',
  'ga': 'Gaeilge',
  'hr': 'Hrvatski',
  'hu': 'Magyar',
  'it': 'Italiano',
  'ja': '日本語',
  'lt': 'Lietuvių',
  'lv': 'Latviešu',
  'mt': 'Malti',
  'nl': 'Nederlands',
  'pl': 'Polski',
  'pt': 'Português',
  'ro': 'Română',
  'ru': 'Русский',
  'sk': 'Slovenčina',
  'sl': 'Slovenščina',
  'sv': 'Svenska',
  'zh': '中文',
};

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
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            l10n.couldNotLoadSettings(e.toString()),
            textAlign: TextAlign.center,
          ),
        ),
        data: (settings) => ListView(
          children: [
            _SectionHeader(l10n.sectionAccount),
            desktop_settings.desktopAccountSection() ?? const _AccountSection(),
            _SectionHeader(l10n.sectionSync),
            desktop_settings.desktopSyncSection() ??
                _SyncSection(settings: settings),
            _SectionHeader(l10n.sectionRelays),
            desktop_settings.desktopRelaySection() ??
                _RelaySection(settings: settings),
            _SectionHeader(l10n.sectionAppearance),
            _AppearanceSection(settings: settings),
            _SectionHeader(l10n.sectionData),
            const _DataSection(),
            _SectionHeader(l10n.sectionRemindersTimezone),
            _RemindersSection(settings: settings),
            _SectionHeader(l10n.sectionSupport),
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
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);

    return authState.when(
      loading: () => ListTile(
        leading: const CircularProgressIndicator(strokeWidth: 2),
        title: Text(l10n.loading),
      ),
      error: (error, _) => ListTile(
        leading: const Icon(Icons.error_outline),
        title: Text(l10n.somethingWentWrong(error.toString())),
      ),
      data: (user) {
        if (user == null) {
          // Offline, local-only session: offer to add an account to sync.
          return ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(l10n.offlineNoAccount),
            subtitle: Text(l10n.signInToSyncAcrossDevices),
            trailing: FilledButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const EntryScreen())),
              child: Text(l10n.signIn),
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
                    ? Icon(_accountIcon(user.loginMethod))
                    : null,
              ),
              title: Text(displayName),
              subtitle: Text(_accountSubtitle(l10n, user.loginMethod)),
              trailing: TextButton(
                onPressed: () => _confirmSignOut(context, ref),
                child: Text(l10n.signOut),
              ),
            ),
            // Backing up the key only applies when Astraea holds it — with an
            // external signer (Amber or NIP-46) the key lives there, not here.
            if (user.loginMethod.isLocalKey)
              ListTile(
                leading: const Icon(Icons.vpn_key_outlined),
                title: Text(l10n.backUpPrivateKey),
                subtitle: Text(l10n.revealNsecSubtitle),
                onTap: () => _backupPrivateKey(context, ref),
              ),
          ],
        );
      },
    );
  }

  /// Icon that tells the user, at a glance, where their key actually lives.
  IconData _accountIcon(LoginMethod method) {
    return switch (method) {
      LoginMethod.amber => Icons.shield_outlined,
      LoginMethod.remoteSigner => Icons.cloud_outlined,
      LoginMethod.importedKey ||
      LoginMethod.generatedKey => Icons.verified_user_outlined,
    };
  }

  String _accountSubtitle(AppLocalizations l10n, LoginMethod method) {
    return switch (method) {
      LoginMethod.amber => l10n.signedInWithAmber,
      LoginMethod.remoteSigner => l10n.signedInRemoteSigner,
      LoginMethod.importedKey || LoginMethod.generatedKey => l10n.signedIn,
    };
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.signOutTitle),
        content: Text(l10n.signOutBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.signOut),
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
    final l10n = AppLocalizations.of(context);
    final privateKeyHex = await ref
        .read(localStorageServiceProvider)
        .loadPrivateKey();
    if (privateKeyHex == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.noPrivateKeyStored)));
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
          title: Text(l10n.yourPrivateKeyTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.nsecWarning),
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
              child: Text(l10n.copy),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.done),
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
    final l10n = AppLocalizations.of(context);
    final sync = ref.watch(syncProvider);
    final signedIn = ref.watch(authProvider).value != null;
    final hasRelays = settings.allSyncRelays.isNotEmpty;

    return ListTile(
      leading: const Icon(Icons.sync),
      title: Text(l10n.syncNowTitle),
      subtitle: Text(
        !signedIn
            ? l10n.signInToSyncSubtitle
            : !hasRelays
            ? l10n.addRelayToSyncSubtitle
            : _syncSubtitle(l10n, sync),
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

  String _syncSubtitle(AppLocalizations l10n, SyncState sync) {
    switch (sync.status) {
      case SyncStatus.syncing:
        return l10n.syncingEllipsis;
      case SyncStatus.success:
        final at = sync.lastSyncedAt;
        return at == null
            ? l10n.synced
            : l10n.lastSyncedLabel(
                Formatter.fullLabel(at.toUtc(), tz.local.name),
              );
      case SyncStatus.error:
        return l10n.lastSyncFailedLabel(sync.errorMessage ?? '');
      case SyncStatus.idle:
        return l10n.pullMergePublish;
    }
  }
}

// ── Relays ───────────────────────────────────────────────────────────────

class _RelaySection extends ConsumerWidget {
  const _RelaySection({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          backgroundColor: colorScheme.surfaceContainerHigh,
          collapsedBackgroundColor: Colors.transparent,
          leading: const Icon(Icons.dns_outlined),
          title: Text(l10n.publicRelays),
          subtitle: Text(l10n.relaysConfiguredCount(settings.relays.length)),
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
              title: Text(l10n.addRelay),
              onTap: () async {
                final input = await _promptForText(
                  context,
                  title: l10n.addRelay,
                  hint: l10n.customRelayHint,
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
            if (AppConstants.suggestedRelays.any(
              (relay) => !settings.relays.contains(relay),
            )) ...[
              const Divider(),
              ListTile(
                dense: true,
                title: Text(l10n.suggestedRelaysTitle),
                subtitle: Text(l10n.addOnlyRelaysYouWant),
              ),
              for (final url in AppConstants.suggestedRelays)
                if (!settings.relays.contains(url))
                  ListTile(
                    leading: const Icon(Icons.dns_outlined),
                    title: Text(Uri.parse(url).host),
                    subtitle: Text(url),
                    trailing: IconButton(
                      tooltip: l10n.addRelayTooltip,
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
          title: Text(l10n.homeRelayBackup),
          subtitle: Text(
            settings.homeRelayUrl?.isNotEmpty == true
                ? settings.homeRelayUrl!
                : l10n.homeRelayNotConfigured,
          ),
          trailing: const Icon(Icons.edit_outlined),
          onTap: () async {
            final input = await _promptForText(
              context,
              title: l10n.homeRelayDialogTitle,
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
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.invalidRelayUrl)));
  }

  void _warnIfInsecure(BuildContext context, String url) {
    if (!isInsecureRelayUrl(url)) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.insecureRelayWarning)));
  }
}

// ── Appearance ───────────────────────────────────────────────────────────

class _AppearanceSection extends ConsumerWidget {
  const _AppearanceSection({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);

    return Column(
      children: [
        SwitchListTile(
          secondary: Icon(
            themeMode == ThemeMode.light
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
          ),
          title: Text(l10n.lightTheme),
          subtitle: Text(l10n.darkThemeDefault),
          value: themeMode == ThemeMode.light,
          onChanged: (value) => ref
              .read(themeModeProvider.notifier)
              .setThemeMode(value ? ThemeMode.light : ThemeMode.dark),
        ),
        ListTile(
          leading: const Icon(Icons.language_outlined),
          title: Text(l10n.languageLabel),
          subtitle: Text(
            settings.locale == null
                ? l10n.systemLanguage
                : (_languageNativeNames[settings.locale] ?? settings.locale!),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _pickLanguage(context, ref, settings),
        ),
        ListTile(
          leading: CircleAvatar(
            radius: 12,
            backgroundColor: AppAccent.fromPrefsValue(settings.accent).seed,
          ),
          title: Text(l10n.accentColorLabel),
          subtitle: Text(AppAccent.fromPrefsValue(settings.accent).label(l10n)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _pickAccent(context, ref, settings),
        ),
      ],
    );
  }

  Future<void> _pickAccent(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) async {
    final l10n = AppLocalizations.of(context);
    final current = AppAccent.fromPrefsValue(settings.accent);
    final chosen = await showModalBottomSheet<AppAccent>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final accent in AppAccent.values)
              ListTile(
                leading: CircleAvatar(radius: 12, backgroundColor: accent.seed),
                title: Text(accent.label(l10n)),
                selected: accent == current,
                trailing: accent == current ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(ctx).pop(accent),
              ),
          ],
        ),
      ),
    );
    if (chosen == null || chosen == current) return;
    await ref
        .read(settingsProvider.notifier)
        .save(settings.copyWith(accent: chosen.prefsValue));
  }

  Future<void> _pickLanguage(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) async {
    final l10n = AppLocalizations.of(context);
    final codes =
        AppLocalizations.supportedLocales.map((l) => l.languageCode).toList()
          ..sort(
            (a, b) => (_languageNativeNames[a] ?? a).compareTo(
              _languageNativeNames[b] ?? b,
            ),
          );

    final chosen = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.75,
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.phone_android),
              title: Text(l10n.systemLanguage),
              selected: settings.locale == null,
              onTap: () => Navigator.of(ctx).pop(''),
            ),
            const Divider(height: 1),
            for (final code in codes)
              ListTile(
                title: Text(_languageNativeNames[code] ?? code),
                selected: settings.locale == code,
                trailing: settings.locale == code
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.of(ctx).pop(code),
              ),
          ],
        ),
      ),
    );
    if (chosen == null) return;
    await ref
        .read(settingsProvider.notifier)
        .save(
          chosen.isEmpty
              ? settings.copyWith(clearLocale: true)
              : settings.copyWith(locale: chosen),
        );
  }
}

// ── Data (export / import) ───────────────────────────────────────────────

class _DataSection extends ConsumerWidget {
  const _DataSection();

  static const _maxImportBytes = 10 * 1024 * 1024;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.upload_outlined),
          title: Text(l10n.exportEvents),
          subtitle: Text(l10n.exportEventsSubtitle),
          onTap: () => _export(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.download_outlined),
          title: Text(l10n.importEvents),
          subtitle: Text(l10n.importEventsSubtitle),
          onTap: () => _import(context, ref),
        ),
      ],
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
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
        dialogTitle: l10n.exportEvents,
        fileName: encrypted ? 'astraea-$stamp.ics.json' : 'astraea-$stamp.ics',
        bytes: bytes,
      );
      if (path == null) return; // Cancelled.
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              encrypted ? l10n.encryptedExportSaved : l10n.exportSaved,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportFailed(e.toString()))),
        );
      }
    }
  }

  /// Empty string = export unencrypted; null = the user cancelled.
  Future<String?> _askExportPassword(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.encryptExportTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.encryptExportBody),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.exportPasswordLabel,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: Text(l10n.export),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
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
        throw StateError(l10n.couldNotReadSelectedFile);
      }
      if (fileBytes.length > _maxImportBytes) {
        throw StateError(l10n.selectedFileTooLarge);
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
        ).showSnackBar(SnackBar(content: Text(l10n.importedEventCount(count))));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.importFailed(e.toString()))),
        );
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
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    var submitting = false;
    String? errorText;

    // One attempt, lifted out of the widget tree. Inline it and the actual
    // logic — try, decrypt, classify the failure — sits eight levels deep
    // inside builders, where it is nearly unreadable and easy to get wrong.
    // Here it is a flat sequence: mark busy, import, close or explain.
    Future<void> attempt(
      BuildContext ctx,
      void Function(void Function()) setState,
    ) async {
      setState(() {
        submitting = true;
        errorText = null;
      });
      String? failure;
      try {
        final imported = await ref
            .read(eventsProvider.notifier)
            .importFromIcs(
              raw,
              password: controller.text,
              defaultTimezone: defaultTimezone,
            );
        if (ctx.mounted) Navigator.of(ctx).pop(imported);
        return;
      } on SecretBoxAuthenticationError {
        // The one failure the user can act on: the password was wrong.
        failure = l10n.wrongPassword;
      } catch (_) {
        // Anything else means the file is not a readable Astraea export. The
        // exception is deliberately not shown: a decode failure can quote the
        // bytes it choked on, which are the user's calendar.
        failure = l10n.invalidEncryptedExport;
      }
      if (!ctx.mounted) return;
      setState(() {
        submitting = false;
        errorText = failure;
      });
    }

    final count = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l10n.thisExportIsEncrypted),
          content: TextField(
            controller: controller,
            obscureText: true,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.passwordLabel,
              errorText: errorText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: submitting ? null : () => Navigator.of(ctx).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: submitting ? null : () => attempt(ctx, setState),
              child: Text(l10n.importButton),
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
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.notifications_outlined),
          title: Text(l10n.reminders),
          subtitle: Text(l10n.scheduleLocalNotifications),
          value: settings.notificationsEnabled,
          onChanged: (v) => ref
              .read(settingsProvider.notifier)
              .save(settings.copyWith(notificationsEnabled: v)),
        ),
        ListTile(
          leading: const Icon(Icons.public),
          title: Text(l10n.timezone),
          subtitle: Text(
            settings.timezone ??
                l10n.followDeviceTimezoneWithName(tz.local.name),
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
    final l10n = AppLocalizations.of(context);
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
        SnackBar(
          content: Text(
            l10n.noLightningWalletFound(AppConstants.lightningAddress),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                    l10n.supportAstraea,
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
  final l10n = AppLocalizations.of(context);
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
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
          child: Text(l10n.save),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}
