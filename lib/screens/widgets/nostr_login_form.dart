import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../services/nostr_service.dart';
import '../../utils/formatter.dart';

/// Reusable Nostr account form used by first-run onboarding and by Settings'
/// "add account" flow.
class NostrLoginForm extends ConsumerStatefulWidget {
  const NostrLoginForm({super.key, this.onLoggedIn});

  final VoidCallback? onLoggedIn;

  @override
  ConsumerState<NostrLoginForm> createState() => _NostrLoginFormState();
}

class _NostrLoginFormState extends ConsumerState<NostrLoginForm> {
  final _importController = TextEditingController();
  bool _showImportField = false;

  bool get _supportsAmber =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void dispose() {
    _importController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final user = authState.value;
    final isLoading = authState.isLoading;

    if (user != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.verified_user_outlined),
              title: const Text('Nostr account connected'),
              subtitle: Text(Formatter.truncateKey(user.npub)),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: widget.onLoggedIn,
            child: const Text('Continue'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (authState.hasError)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              // A parsing exception may contain the key the user entered.
              // Never interpolate it into the UI or logs.
              authState.error is InvalidPrivateKeyException
                  ? 'That private key is not valid. Check it and try again.'
                  : 'Could not sign in: ${authState.error}',
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
            label: const Text('Sign in with Amber'),
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: isLoading
              ? null
              : () => _run(
                  () => ref.read(authProvider.notifier).generateAccount(),
                ),
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Create a new account'),
        ),
        const SizedBox(height: 8),
        Text(
          'A generated account can only be recovered with its private key. '
          'Back it up from Settings after setup.',
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
          label: const Text('Import an existing key'),
        ),
        if (_showImportField) ...[
          const SizedBox(height: 16),
          TextField(
            controller: _importController,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: isLoading ? null : (_) => _import(),
            decoration: const InputDecoration(
              labelText: 'nsec or hex private key',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: isLoading ? null : _import,
            child: const Text('Import'),
          ),
        ],
        if (isLoading) ...[
          const SizedBox(height: 24),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }
}
