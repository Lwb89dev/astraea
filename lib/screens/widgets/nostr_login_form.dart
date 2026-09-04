import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../services/nip46_client.dart';
import '../../services/nostr_service.dart';
import '../../utils/formatter.dart';

/// Reusable Nostr account form used by first-run onboarding and by Settings'
/// "add account" flow.
///
/// Offers, in decreasing order of key safety:
///  - Amber (Android only, NIP-55): the key stays in another app on the device;
///  - a remote signer (NIP-46 "bunker", every platform): the key stays on
///    hardware the user controls and never touches this device at all;
///  - a locally generated key, or an imported nsec.
class NostrLoginForm extends ConsumerStatefulWidget {
  const NostrLoginForm({super.key, this.onLoggedIn});

  final VoidCallback? onLoggedIn;

  @override
  ConsumerState<NostrLoginForm> createState() => _NostrLoginFormState();
}

class _NostrLoginFormState extends ConsumerState<NostrLoginForm> {
  final _importController = TextEditingController();
  final _bunkerController = TextEditingController();
  bool _showImportField = false;
  bool _showBunkerField = false;

  bool get _supportsAmber =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void dispose() {
    _importController.dispose();
    _bunkerController.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    await action();
    if (!mounted) return;
    if (ref.read(authProvider).value != null) widget.onLoggedIn?.call();
  }

  Future<void> _import() async {
    final key = _importController.text.trim();
    if (key.isEmpty) return;
    await _run(() => ref.read(authProvider.notifier).importAccount(key));
  }

  Future<void> _connectRemoteSigner() async {
    final uri = _bunkerController.text.trim();
    if (uri.isEmpty) return;
    await _run(
      () => ref
          .read(authProvider.notifier)
          .loginWithRemoteSigner(uri, onAuthUrl: _openApprovalPage),
    );
    // The connection string carries a single-use secret: drop it from the
    // widget as soon as it has been used, so it is not left sitting in a text
    // field (and therefore in a screenshot or an accessibility dump).
    if (mounted) _bunkerController.clear();
  }

  /// The signer asked for interactive approval. Opening the page is the whole
  /// point of the `auth_url` reply; [Nip46Client] has already restricted it to
  /// https, so nothing else can be launched through this path.
  Future<void> _openApprovalPage(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).remoteSignerApprovalOpened),
      ),
    );
  }

  /// Login errors are shown verbatim only when they are known to be safe. A
  /// bad key or a bad bunker string must never be echoed back: both can embed
  /// secret material, and a `FormatException` cheerfully quotes its input.
  String _errorText(AppLocalizations l10n, Object? error) {
    if (error is InvalidPrivateKeyException) return l10n.invalidPrivateKey;
    if (error is Nip46Exception) return error.message;
    return l10n.couldNotSignIn(error.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final user = authState.value;
    final isLoading = authState.isLoading;

    if (user != null) return _connectedCard(context, l10n, user.npub);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (authState.hasError)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              _errorText(l10n, authState.error),
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        if (_supportsAmber) ...[
          FilledButton.tonalIcon(
            onPressed: isLoading
                ? null
                : () => _run(
                    () => ref.read(authProvider.notifier).loginWithAmber(),
                  ),
            icon: const Icon(Icons.shield_outlined),
            label: Text(l10n.signInWithAmber),
          ),
          const SizedBox(height: 12),
        ],
        FilledButton.tonalIcon(
          onPressed: isLoading
              ? null
              : () => setState(() => _showBunkerField = !_showBunkerField),
          icon: const Icon(Icons.vpn_key_outlined),
          label: Text(l10n.signInWithRemoteSigner),
        ),
        if (_showBunkerField) ..._remoteSignerFields(theme, l10n, isLoading),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: isLoading
              ? null
              : () => _run(
                  () => ref.read(authProvider.notifier).generateAccount(),
                ),
          icon: const Icon(Icons.auto_awesome),
          label: Text(l10n.createNewAccount),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.generatedAccountWarning,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: isLoading
              ? null
              : () => setState(() => _showImportField = !_showImportField),
          icon: const Icon(Icons.key),
          label: Text(l10n.importExistingKey),
        ),
        if (_showImportField) ..._importFields(l10n, isLoading),
        if (isLoading) ...[
          const SizedBox(height: 24),
          Text(
            _showBunkerField ? l10n.remoteSignerConnecting : '',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }

  Widget _connectedCard(
    BuildContext context,
    AppLocalizations l10n,
    String npub,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.verified_user_outlined),
            title: Text(l10n.nostrAccountConnected),
            subtitle: Text(Formatter.truncateKey(npub)),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: widget.onLoggedIn,
          child: Text(l10n.continueLabel),
        ),
      ],
    );
  }

  List<Widget> _remoteSignerFields(
    ThemeData theme,
    AppLocalizations l10n,
    bool isLoading,
  ) {
    return [
      const SizedBox(height: 12),
      Text(
        l10n.remoteSignerHelp,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _bunkerController,
        // Treated as a secret: the string embeds a single-use connection
        // token, so no autocorrect, no keyboard learning, no suggestions.
        autocorrect: false,
        enableSuggestions: false,
        keyboardType: TextInputType.url,
        textInputAction: TextInputAction.done,
        onSubmitted: isLoading ? null : (_) => _connectRemoteSigner(),
        decoration: InputDecoration(
          labelText: l10n.remoteSignerFieldLabel,
          hintText: 'bunker://…',
          border: const OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      FilledButton(
        onPressed: isLoading ? null : _connectRemoteSigner,
        child: Text(l10n.remoteSignerConnect),
      ),
    ];
  }

  List<Widget> _importFields(AppLocalizations l10n, bool isLoading) {
    return [
      const SizedBox(height: 16),
      TextField(
        controller: _importController,
        obscureText: true,
        autocorrect: false,
        enableSuggestions: false,
        keyboardType: TextInputType.visiblePassword,
        textInputAction: TextInputAction.done,
        onSubmitted: isLoading ? null : (_) => _import(),
        decoration: InputDecoration(
          labelText: l10n.privateKeyFieldLabel,
          border: const OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      FilledButton(
        onPressed: isLoading ? null : _import,
        child: Text(l10n.importButton),
      ),
    ];
  }
}
