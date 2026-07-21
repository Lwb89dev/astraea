import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';
import '../providers/app_entry_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';
import '../utils/relay_url.dart';
import 'widgets/nostr_login_form.dart';

/// First-launch flow, modelled after Echoes:
/// presentation → optional Nostr account → explicit relay selection.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _pageCount = 3;

  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    if (page < 0 || page >= _pageCount || !_controller.hasClients) return;
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    // Persist even an explicitly empty choice. Without this write, an upgraded
    // install's backwards-compatibility fallback could later mistake "none"
    // for the historical implicit defaults.
    final settings = await ref.read(settingsProvider.future);
    await ref.read(settingsProvider.notifier).save(settings);
    if (!mounted || !ref.read(settingsProvider).hasValue) return;
    await ref.read(appEntryProvider.notifier).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (page) => setState(() => _page = page),
                children: [
                  const _IntroPage(),
                  _LoginPage(onLoggedIn: () => _goToPage(2)),
                  const _RelaySetupPage(),
                ],
              ),
            ),
            _BottomBar(
              page: _page,
              accountConnected: auth.value != null,
              canFinish: settings.hasValue,
              onBack: () => _goToPage(_page - 1),
              onNext: () => _goToPage(_page + 1),
              onSkip: _finish,
              onFinish: _finish,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.page,
    required this.accountConnected,
    required this.canFinish,
    required this.onBack,
    required this.onNext,
    required this.onSkip,
    required this.onFinish,
  });

  final int page;
  final bool accountConnected;
  final bool canFinish;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final isFirst = page == 0;
    final isLast = page == 2;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 16),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: isFirst
                ? null
                : TextButton(onPressed: onBack, child: const Text('Back')),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => _PageDot(active: index == page),
              ),
            ),
          ),
          if (isLast)
            FilledButton(
              onPressed: canFinish ? onFinish : null,
              child: const Text('Get started'),
            )
          else if (page == 1 && !accountConnected)
            TextButton(onPressed: onSkip, child: const Text('Use offline'))
          else if (page == 0)
            FilledButton(onPressed: onNext, child: const Text('Next'))
          else
            const SizedBox(width: 72),
        ],
      ),
    );
  }
}

class _PageDot extends StatelessWidget {
  const _PageDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: active ? 20 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _IntroPage extends StatelessWidget {
  const _IntroPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final supportsAmber =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.wb_sunny_outlined,
                size: 56,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text('Welcome to Astraea', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'A private, offline-first calendar that puts you in control.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              const _FeatureRow(
                icon: Icons.smartphone_outlined,
                title: 'Your calendar stays on your device',
                body:
                    'Create events, recurrences and reminders without an account or an internet connection.',
              ),
              const _FeatureRow(
                icon: Icons.sync,
                title: 'Optional sync through Nostr',
                body:
                    'Connect an account to back up your calendar and use it on multiple devices through relays you choose.',
              ),
              const _FeatureRow(
                icon: Icons.lock_outline,
                title: 'Always encrypted before upload',
                body:
                    'Calendar contents are end-to-end encrypted before they leave this device. Relay operators cannot read them.',
              ),
              if (supportsAmber)
                const _FeatureRow(
                  icon: Icons.shield_outlined,
                  title: 'Keep your key in Amber',
                  body:
                      'On Android, an external signer can approve access without exposing your private key to Astraea.',
                ),
              const _FeatureRow(
                icon: Icons.notifications_none,
                title: 'Private local reminders',
                body:
                    'Notifications are scheduled by your device and do not depend on a cloud calendar service.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginPage extends StatelessWidget {
  const _LoginPage({required this.onLoggedIn});

  final VoidCallback onLoggedIn;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.key_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Connect a Nostr account',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This is only needed for encrypted synchronization. You can also use Astraea entirely offline.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              NostrLoginForm(onLoggedIn: onLoggedIn),
            ],
          ),
        ),
      ),
    );
  }
}

class _RelaySetupPage extends ConsumerStatefulWidget {
  const _RelaySetupPage();

  @override
  ConsumerState<_RelaySetupPage> createState() => _RelaySetupPageState();
}

class _RelaySetupPageState extends ConsumerState<_RelaySetupPage> {
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _addRelay(AppSettings settings, String rawUrl) async {
    final url = normalizeRelayUrl(rawUrl);
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid wss:// (or ws:// for a private relay) URL.'),
        ),
      );
      return;
    }
    if (isInsecureRelayUrl(url) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ws:// is unencrypted in transit — only use it for a relay you trust.',
          ),
        ),
      );
    }
    if (settings.relays.contains(url)) {
      _urlController.clear();
      return;
    }
    await ref
        .read(settingsProvider.notifier)
        .save(settings.copyWith(relays: [...settings.relays, url]));
    if (mounted) _urlController.clear();
  }

  Future<void> _removeRelay(AppSettings settings, String url) {
    return ref
        .read(settingsProvider.notifier)
        .save(
          settings.copyWith(
            relays: settings.relays.where((relay) => relay != url).toList(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.dns_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Choose relays for synchronization',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Relays store your encrypted calendar and make it available to your other devices. Add one or more, or leave the list empty and configure it later.',
              ),
              const SizedBox(height: 20),
              settingsState.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, _) => Text(
                  'Could not load relay settings: $error',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                data: (settings) => _RelayChooser(
                  settings: settings,
                  controller: _urlController,
                  onAdd: (url) => _addRelay(settings, url),
                  onRemove: (url) => _removeRelay(settings, url),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RelayChooser extends StatelessWidget {
  const _RelayChooser({
    required this.settings,
    required this.controller,
    required this.onAdd,
    required this.onRemove,
  });

  final AppSettings settings;
  final TextEditingController controller;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final selected = settings.relays.toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Suggested', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        for (final url in AppConstants.defaultRelays)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.dns_outlined),
            title: Text(Uri.parse(url).host),
            subtitle: Text(url),
            trailing: selected.contains(url)
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : IconButton(
                    tooltip: 'Add relay',
                    onPressed: () => onAdd(url),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                autocorrect: false,
                enableSuggestions: false,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                onSubmitted: onAdd,
                decoration: const InputDecoration(
                  labelText: 'Custom relay',
                  hintText: 'wss://relay.example.com',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: 'Add relay',
              onPressed: () => onAdd(controller.text),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        if (settings.relays.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Selected', style: Theme.of(context).textTheme.titleMedium),
          for (final url in settings.relays)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.dns_outlined),
              title: Text(url),
              trailing: IconButton(
                tooltip: 'Remove relay',
                onPressed: () => onRemove(url),
                icon: const Icon(Icons.remove_circle_outline),
              ),
            ),
        ],
      ],
    );
  }
}
