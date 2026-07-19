// Validates `lib/utils/nip44.dart` against the official NIP-44 v2 test
// vectors (test/fixtures/nip44.vectors.json, from
// https://github.com/paulmillr/nip44 — the canonical fixture used across
// Nostr client implementations), instead of only testing the code against
// itself. Given this is hand-rolled cryptography (see nip44.dart's doc
// comment for why), passing these vectors is what makes it trustworthy
// enough to encrypt real user data.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:astraea/utils/nip44.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/export.dart';

final _secp256k1 = ECCurve_secp256k1();

Uint8List _hexToBytes(String hex) {
  final bytes = Uint8List(hex.length ~/ 2);
  for (var i = 0; i < bytes.length; i++) {
    bytes[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return bytes;
}

String _bytesToHex(List<int> bytes) {
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

/// Derives the x-only (32-byte) public key hex for [privateKeyHex] — the
/// vectors give private keys and expect the test to derive matching public
/// keys itself, the same way a real caller would via `dart_nostr`'s own
/// key generation (not exercised here, to keep this test focused on the
/// NIP-44 layer alone).
String _publicKeyHexFrom(String privateKeyHex) {
  final d = BigInt.parse(privateKeyHex, radix: 16);
  final point = (_secp256k1.G * d)!;
  final xHex = point.x!.toBigInteger()!.toRadixString(16).padLeft(64, '0');
  return xHex;
}

void main() {
  final vectors =
      json.decode(File('test/fixtures/nip44.vectors.json').readAsStringSync())
          as Map<String, dynamic>;
  final v2 = vectors['v2'] as Map<String, dynamic>;
  final valid = v2['valid'] as Map<String, dynamic>;
  final invalid = v2['invalid'] as Map<String, dynamic>;

  group('calc_padded_len (valid vectors)', () {
    for (final entry in valid['calc_padded_len'] as List) {
      final pair = entry as List;
      final input = pair[0] as int;
      final expected = pair[1] as int;
      test('calcPaddedLen($input) == $expected', () {
        expect(Nip44.calcPaddedLenForTesting(input), expected);
      });
    }
  });

  group('get_conversation_key (valid vectors)', () {
    for (final entry in valid['get_conversation_key'] as List) {
      final v = entry as Map<String, dynamic>;
      test(v['note'] as String, () {
        final actual = Nip44.conversationKeyForTesting(
          v['sec1'] as String,
          v['pub2'] as String,
        );
        expect(_bytesToHex(actual), v['conversation_key']);
      });
    }
  });

  group('get_conversation_key (invalid vectors)', () {
    for (final entry in invalid['get_conversation_key'] as List) {
      final v = entry as Map<String, dynamic>;
      test(v['note'] as String, () {
        expect(
          () => Nip44.conversationKeyForTesting(
            v['sec1'] as String,
            v['pub2'] as String,
          ),
          throwsA(anything),
        );
      });
    }
  });

  group('encrypt_decrypt (valid vectors)', () {
    for (final entry in valid['encrypt_decrypt'] as List) {
      final v = entry as Map<String, dynamic>;
      final plaintext = v['plaintext'] as String;
      test('round trip: "$plaintext"', () {
        final sec1 = v['sec1'] as String;
        final sec2 = v['sec2'] as String;
        final pub1 = _publicKeyHexFrom(sec1);
        final pub2 = _publicKeyHexFrom(sec2);
        final nonce = _hexToBytes(v['nonce'] as String);

        final encrypted = Nip44.encrypt(
          plaintext: plaintext,
          senderPrivateKeyHex: sec1,
          recipientPublicKeyHex: pub2,
          customNonce: nonce,
        );
        expect(
          encrypted,
          v['ciphertext'],
          reason: 'ciphertext must match the fixed-nonce vector exactly',
        );

        final decrypted = Nip44.decrypt(
          payload: v['ciphertext'] as String,
          recipientPrivateKeyHex: sec2,
          senderPublicKeyHex: pub1,
        );
        expect(decrypted, plaintext);
      });
    }
  });

  group('decrypt (invalid vectors)', () {
    for (final entry in invalid['decrypt'] as List) {
      final v = entry as Map<String, dynamic>;
      test(v['note'] as String, () {
        expect(
          () => Nip44.decryptWithConversationKeyForTesting(
            payload: v['ciphertext'] as String,
            conversationKey: _hexToBytes(v['conversation_key'] as String),
          ),
          throwsA(anything),
        );
      });
    }
  });
}
