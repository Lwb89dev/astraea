import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'widgets/nostr_login_form.dart';

/// Adds a Nostr identity to an existing local-only session.
///
/// First launch has its own onboarding flow; this focused screen remains
/// available from Settings after the user has already entered the calendar.
class EntryScreen extends StatelessWidget {
  const EntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addNostrAccountTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: NostrLoginForm(
                onLoggedIn: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
