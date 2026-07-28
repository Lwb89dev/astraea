import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Selectable accent palettes (Settings > Appearance). The Material light/
/// dark base never changes — only the seed color fed to
/// `ColorScheme.fromSeed` (the rest of the app's buttons, app bar, etc.) and
/// two explicit, hand-picked tones used everywhere the app draws its own
/// "today"/event-indicator two-tone pairing (calendar month grid, Android
/// home-screen widgets): a lighter tint for a highlighted day's background,
/// and the accent's own saturated tone for event indicators, so the brand
/// color (bitcoin orange, nostr purple) stays recognizable rather than being
/// re-toned by Material 3's automatic tonal palette.
enum AppAccent {
  navy,
  bitcoin,
  nostr;

  static const _prefsValues = {
    AppAccent.navy: 'navy',
    AppAccent.bitcoin: 'bitcoin',
    AppAccent.nostr: 'nostr',
  };

  String get prefsValue => _prefsValues[this]!;

  static AppAccent fromPrefsValue(String? value) => AppAccent.values
      .firstWhere((a) => a.prefsValue == value, orElse: () => AppAccent.navy);

  /// Seed for `ColorScheme.fromSeed` — drives the rest of Material's tonal
  /// palette (buttons, app bar, etc.).
  Color get seed => switch (this) {
    AppAccent.navy => const Color(0xFF3F51B5),
    AppAccent.bitcoin => const Color(0xFFF7931A),
    AppAccent.nostr => const Color(0xFF8E30EB),
  };

  /// Lighter tint: background of a highlighted/"today" day.
  Color get dayBackground => switch (this) {
    AppAccent.navy => const Color(0xFF9FA8DA),
    AppAccent.bitcoin => const Color(0xFFFBC287),
    AppAccent.nostr => const Color(0xFFD5AEF2),
  };

  /// The saturated brand tone: event indicators (month-grid marker dots on
  /// the widget, the "+" accent pill, header bullet).
  Color get indicator => seed;

  /// Text/icon color guaranteed to read on [indicator] and [dayBackground].
  /// White works for navy and nostr purple, both dark enough; bitcoin
  /// orange is too light for white text, so it gets dark text instead.
  Color get onIndicator => switch (this) {
    AppAccent.bitcoin => const Color(0xFF161A2E),
    AppAccent.navy || AppAccent.nostr => Colors.white,
  };

  String label(AppLocalizations l10n) => switch (this) {
    AppAccent.navy => l10n.accentNavy,
    AppAccent.bitcoin => l10n.accentBitcoin,
    AppAccent.nostr => l10n.accentNostr,
  };
}
