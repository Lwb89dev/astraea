import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the app-level theme choice, persisted in SharedPreferences — same
/// pattern (and privacy-first dark default) as Echoes' [ThemeModeNotifier].
///
/// The persisted value is loaded eagerly in `main()` (see
/// [loadInitialThemeMode]) and seeded into the constructor via
/// `themeModeProvider.overrideWith(...)` on the root [ProviderContainer], so
/// the very first frame already renders in the right theme instead of flashing
/// one and rebuilding into the other.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  ThemeModeNotifier([this._initial]);

  static const _prefsKey = 'astraea.theme_mode';
  static const _legacyPrefsKey = 'epochs.theme_mode';

  final ThemeMode? _initial;

  @override
  ThemeMode build() => _initial ?? ThemeMode.dark;

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
  }

  /// Reads the persisted theme mode, if any. Called once in `main()`, before
  /// `runApp`.
  static Future<ThemeMode?> loadInitialThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_prefsKey) ?? prefs.getString(_legacyPrefsKey);
    if (name != null && !prefs.containsKey(_prefsKey)) {
      await prefs.setString(_prefsKey, name);
    }
    for (final mode in ThemeMode.values) {
      if (mode.name == name) return mode;
    }
    return null;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
