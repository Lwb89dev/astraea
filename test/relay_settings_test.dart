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

  test('relay URL normalization accepts wss:// and ws:// only', () {
    expect(normalizeRelayUrl(' WSS://NOS.LOL '), 'wss://nos.lol');
    // ws:// is accepted for personal/self-hosted relays without TLS, but
    // never silently upgraded to wss:// (that would hide a real cert gap).
    expect(
      normalizeRelayUrl(' WS://192.168.1.10:7777 '),
      'ws://192.168.1.10:7777',
    );
    expect(isInsecureRelayUrl('ws://192.168.1.10:7777'), isTrue);
    expect(isInsecureRelayUrl('wss://nos.lol'), isFalse);
    expect(normalizeRelayUrl('https://nos.lol'), isNull);
    expect(normalizeRelayUrl('wss://user@nos.lol'), isNull);
    expect(normalizeRelayUrl('wss://nos.lol/#fragment'), isNull);
    expect(normalizeRelayUrl('ws://user@nos.lol'), isNull);
  });
}
