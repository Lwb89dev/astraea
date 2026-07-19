import 'dart:convert';

import 'package:astraea/services/export_encryption_service.dart';
import 'package:astraea/services/local_storage_service.dart';
import 'package:astraea/utils/constants.dart';
import 'package:astraea/utils/relay_url.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageService storage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService(
      exportEncryptionService: ExportEncryptionService(),
    );
  });

  test('fresh onboarding starts without silently selected relays', () async {
    expect((await storage.loadSettings()).relays, isEmpty);
  });

  test('an upgraded install retains the historical implicit relays', () async {
    SharedPreferences.setMockInitialValues({
      AppConstants.prefsEnteredKey: true,
    });

    expect((await storage.loadSettings()).relays, AppConstants.defaultRelays);
  });

  test(
    'an explicit empty relay choice remains empty after onboarding',
    () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.prefsEnteredKey: true,
        AppConstants.prefsRelaysKey: jsonEncode(<String>[]),
      });

      expect((await storage.loadSettings()).relays, isEmpty);
    },
  );

  test('relay URL normalization accepts only secure usable URLs', () {
    expect(normalizeSecureRelayUrl(' WSS://NOS.LOL '), 'wss://nos.lol');
    expect(normalizeSecureRelayUrl('ws://nos.lol'), isNull);
    expect(normalizeSecureRelayUrl('https://nos.lol'), isNull);
    expect(normalizeSecureRelayUrl('wss://user@nos.lol'), isNull);
    expect(normalizeSecureRelayUrl('wss://nos.lol/#fragment'), isNull);
  });
}
