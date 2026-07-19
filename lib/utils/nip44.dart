import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:meta/meta.dart' show visibleForTesting;
import 'package:pointycastle/export.dart';

/// [NIP-44](https://github.com/nostr-protocol/nips/blob/master/44.md)
/// "Versioned Encryption" — the current Nostr standard for encrypting an
/// event's `content`, superseding the older NIP-04 (plain AES-256-CBC,
/// no message authentication, vulnerable to bit-flipping since there's no
/// MAC — the Nostr protocol itself now marks it deprecated).
///
/// Algorithm (v2, the only version the spec currently defines):
///  1. ECDH over secp256k1 between the two parties' keys; only the shared
///     point's X coordinate (32 bytes) is used.
///  2. `conversationKey = HKDF-extract(salt: "nip44-v2", ikm: sharedX)`.
///  3. Per-message: `HKDF-expand(conversationKey, info: nonce, 76 bytes)`
///     split into a 32-byte ChaCha20 key, 12-byte ChaCha20 nonce, and
///     32-byte HMAC key.
///  4. The plaintext is padded (see [_pad]) to one of a small set of
///     bucket sizes, so ciphertext length only loosely correlates with
///     plaintext length — a relay operator watching payload sizes can't
///     easily fingerprint message content.
///  5. `ciphertext = ChaCha20(chachaKey, chachaNonce, paddedPlaintext)`
///     (encrypt-then-MAC, not an AEAD mode — the authentication tag is a
///     separate HMAC-SHA256 computed next).
///  6. `mac = HMAC-SHA256(hmacKey, nonce || ciphertext)`.
///  7. `payload = base64(0x02 || nonce || ciphertext || mac)`.
///
/// No published Dart package implementing NIP-44 can currently sit
/// alongside `dart_nostr` in this project without a dependency-version
/// conflict (see the `pointycastle` entry in pubspec.yaml for why), so
/// this is a direct implementation against `pointycastle`, which already
/// provides every primitive the spec needs (secp256k1 EC point
/// arithmetic, HMAC-SHA256, and the IETF ChaCha20 variant this spec
/// requires). It is verified against the
/// [official NIP-44 v2 test vectors](https://github.com/paulmillr/nip44)
/// in `test/nip44_test.dart` — conversation-key derivation, the padding
/// length table, and full encrypt/decrypt round trips are all checked
/// against the canonical fixture rather than only against themselves.
class Nip44 {
  Nip44._();

  /// Encrypts [plaintext] from [senderPrivateKeyHex] to
  /// [recipientPublicKeyHex] (both hex-encoded; the public key may be
  /// either the 32-byte x-only form Nostr uses for pubkeys, or a
  /// 33-byte compressed / 65-byte uncompressed EC point).
  ///
  /// [customNonce] exists only so tests can reproduce the exact
  /// ciphertext of a spec test vector; real callers must never pass it —
  /// a reused nonce for the same conversation key breaks NIP-44's
  /// security guarantees the same way it would for any stream cipher.
  static String encrypt({
    required String plaintext,
    required String senderPrivateKeyHex,
    required String recipientPublicKeyHex,
    Uint8List? customNonce,
  }) {
    final conversationKey = _deriveConversationKey(
      _computeSharedSecretX(senderPrivateKeyHex, recipientPublicKeyHex),
    );
    final nonce = customNonce ?? _randomBytes(32);
    final keys = _deriveMessageKeys(conversationKey, nonce);

    final padded = _pad(Uint8List.fromList(utf8.encode(plaintext)));
    final ciphertext = _chacha20(keys.chachaKey, keys.chachaNonce, padded);
    final mac = _calculateMac(keys.hmacKey, nonce, ciphertext);

    return _constructPayload(nonce, ciphertext, mac);
  }

  /// Decrypts a NIP-44 v2 [payload] sent by [senderPublicKeyHex] to the
  /// holder of [recipientPrivateKeyHex]. Throws [FormatException] if the
  /// payload is malformed, uses an unsupported version, or fails MAC
  /// verification (which also covers "wrong key" and "corrupted/tampered
  /// ciphertext", since NIP-44 doesn't distinguish those cases — telling
  /// them apart would leak information to an attacker probing the MAC).
  static String decrypt({
    required String payload,
    required String recipientPrivateKeyHex,
    required String senderPublicKeyHex,
  }) {
    final conversationKey = _deriveConversationKey(
      _computeSharedSecretX(recipientPrivateKeyHex, senderPublicKeyHex),
    );
    return _decryptWithConversationKey(payload, conversationKey);
  }

  static String _decryptWithConversationKey(
    String payload,
    Uint8List conversationKey,
  ) {
    final parsed = _parsePayload(payload);
    final keys = _deriveMessageKeys(conversationKey, parsed.nonce);

    final expectedMac = _calculateMac(
      keys.hmacKey,
      parsed.nonce,
      parsed.ciphertext,
    );
    if (!_constantTimeEquals(expectedMac, parsed.mac)) {
      throw const FormatException('NIP-44 payload failed MAC verification.');
    }

    final padded = _chacha20(
      keys.chachaKey,
      keys.chachaNonce,
      parsed.ciphertext,
    );
    return utf8.decode(_unpad(padded));
  }

  // ---------------------------------------------------------------------
  // Test-only hooks (see test/nip44_test.dart) — thin wrappers so the
  // official spec vectors can validate internal derivation steps
  // individually (some vectors give a precomputed conversation key rather
  // than a key pair), not just the end-to-end encrypt/decrypt result.
  // ---------------------------------------------------------------------

  @visibleForTesting
  static Uint8List conversationKeyForTesting(
    String privateKeyHex,
    String publicKeyHex,
  ) {
    return _deriveConversationKey(
      _computeSharedSecretX(privateKeyHex, publicKeyHex),
    );
  }

  @visibleForTesting
  static String decryptWithConversationKeyForTesting({
    required String payload,
    required Uint8List conversationKey,
  }) {
    return _decryptWithConversationKey(payload, conversationKey);
  }

  @visibleForTesting
  static int calcPaddedLenForTesting(int unpaddedLen) =>
      _calcPaddedLen(unpaddedLen);

  // ---------------------------------------------------------------------
  // ECDH (secp256k1) — steps 1-2 of the algorithm above.
  // ---------------------------------------------------------------------

  static final ECDomainParameters _secp256k1 = ECCurve_secp256k1();

  /// Computes the raw X coordinate (32 bytes) of `privateKeyHex * publicKeyHex`
  /// on secp256k1 — the ECDH shared secret NIP-44 feeds into HKDF. Only X is
  /// used (never Y): this matches the spec and how Nostr's own x-only
  /// (BIP-340) public keys already drop the Y coordinate's sign.
  static Uint8List _computeSharedSecretX(
    String privateKeyHex,
    String publicKeyHex,
  ) {
    final d = BigInt.parse(privateKeyHex, radix: 16);
    if (d == BigInt.zero || d >= _secp256k1.n) {
      throw ArgumentError(
        'Private key is out of the secp256k1 curve order range.',
      );
    }
    // Nostr pubkeys are stored x-only (32 bytes / 64 hex chars, BIP-340);
    // EC point decompression needs an explicit sign byte, and by
    // convention (same as event signature verification elsewhere in the
    // app) the even-Y point for that X is always the one meant. Longer
    // hex strings are already a compressed (33-byte) or uncompressed
    // (65-byte) point and are used as-is.
    final normalizedPubKeyHex = publicKeyHex.length == 64
        ? '02$publicKeyHex'
        : publicKeyHex;
    final publicPoint = _secp256k1.curve.decodePoint(
      _hexToBytes(normalizedPubKeyHex),
    )!;

    final sharedPoint = (publicPoint * d)!;
    return _bigIntToBytes(sharedPoint.x!.toBigInteger()!, 32);
  }

  // ---------------------------------------------------------------------
  // HKDF (RFC 5869) over HMAC-SHA256 — steps 2-3.
  // ---------------------------------------------------------------------

  static Uint8List _hmacSha256(Uint8List key, Uint8List data) {
    final hmac = HMac(SHA256Digest(), 64)..init(KeyParameter(key));
    return hmac.process(data);
  }

  static Uint8List _deriveConversationKey(Uint8List sharedSecretX) {
    // HKDF-extract: conversationKey = HMAC-SHA256(salt, ikm).
    return _hmacSha256(
      Uint8List.fromList(utf8.encode('nip44-v2')),
      sharedSecretX,
    );
  }

  static ({Uint8List chachaKey, Uint8List chachaNonce, Uint8List hmacKey})
  _deriveMessageKeys(Uint8List conversationKey, Uint8List nonce) {
    // HKDF-expand(conversationKey, info: nonce, length: 76), then split
    // into the three per-message keys the spec defines.
    const totalLength = 76;
    const hashLength = 32;
    final iterations = (totalLength + hashLength - 1) ~/ hashLength;
    final output = BytesBuilder();
    var previousBlock = Uint8List(0);
    for (var i = 1; i <= iterations; i++) {
      previousBlock = _hmacSha256(
        conversationKey,
        Uint8List.fromList([...previousBlock, ...nonce, i]),
      );
      output.add(previousBlock);
    }
    final expanded = output.toBytes().sublist(0, totalLength);
    return (
      chachaKey: expanded.sublist(0, 32),
      chachaNonce: expanded.sublist(32, 44),
      hmacKey: expanded.sublist(44, 76),
    );
  }

  // ---------------------------------------------------------------------
  // Padding (NIP-44 §Padding) — step 4. Bucketing the padded length hides
  // the exact plaintext length while keeping the overhead bounded.
  // ---------------------------------------------------------------------

  static int _calcPaddedLen(int unpaddedLen) {
    if (unpaddedLen <= 32) return 32;
    final nextPowerOfTwo = 1 << (unpaddedLen - 1).bitLength;
    final chunk = nextPowerOfTwo <= 256 ? 32 : nextPowerOfTwo ~/ 8;
    return chunk * ((unpaddedLen - 1) ~/ chunk + 1);
  }

  static Uint8List _pad(Uint8List plaintext) {
    final unpaddedLen = plaintext.length;
    if (unpaddedLen < 1 || unpaddedLen > 65535) {
      throw ArgumentError(
        'NIP-44 plaintext must be 1..65535 bytes (got $unpaddedLen).',
      );
    }
    final padded = Uint8List(2 + _calcPaddedLen(unpaddedLen));
    // 2-byte big-endian length header, then the plaintext, then zeros
    // (Uint8List is zero-initialized) up to the bucketed length.
    padded[0] = (unpaddedLen >> 8) & 0xFF;
    padded[1] = unpaddedLen & 0xFF;
    padded.setRange(2, 2 + unpaddedLen, plaintext);
    return padded;
  }

  /// Rejects anything but an exactly-sized buffer (header + bucketed
  /// length, no extra trailing bytes) — a looser check would accept
  /// padding oracle / malleability tricks that a stricter length match
  /// catches for free.
  static Uint8List _unpad(Uint8List padded) {
    if (padded.length < 2) {
      throw const FormatException('NIP-44 padded plaintext is too short.');
    }
    final unpaddedLen = (padded[0] << 8) + padded[1];
    if (unpaddedLen == 0 ||
        unpaddedLen > padded.length - 2 ||
        padded.length != 2 + _calcPaddedLen(unpaddedLen)) {
      throw const FormatException(
        'NIP-44 padded plaintext has invalid padding.',
      );
    }
    return padded.sublist(2, 2 + unpaddedLen);
  }

  // ---------------------------------------------------------------------
  // ChaCha20 (IETF variant, 96-bit nonce) — step 5. A raw stream cipher:
  // encryption and decryption are the same XOR-with-keystream operation.
  // ---------------------------------------------------------------------

  static Uint8List _chacha20(Uint8List key, Uint8List nonce, Uint8List data) {
    final cipher = ChaCha7539Engine()
      ..init(true, ParametersWithIV(KeyParameter(key), nonce));
    final output = Uint8List(data.length);
    cipher.processBytes(data, 0, data.length, output, 0);
    return output;
  }

  // ---------------------------------------------------------------------
  // MAC (step 6) and payload framing (step 7).
  // ---------------------------------------------------------------------

  static Uint8List _calculateMac(
    Uint8List hmacKey,
    Uint8List nonce,
    Uint8List ciphertext,
  ) {
    return _hmacSha256(hmacKey, Uint8List.fromList([...nonce, ...ciphertext]));
  }

  /// Compares two byte lists without short-circuiting on the first
  /// mismatch, so the time this takes doesn't leak how many leading bytes
  /// of a forged MAC happened to be correct.
  static bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }

  static String _constructPayload(
    Uint8List nonce,
    Uint8List ciphertext,
    Uint8List mac,
  ) {
    return base64.encode([0x02, ...nonce, ...ciphertext, ...mac]);
  }

  static ({Uint8List nonce, Uint8List ciphertext, Uint8List mac}) _parsePayload(
    String payload,
  ) {
    if (payload.isEmpty || payload.startsWith('#')) {
      throw const FormatException(
        'Unknown/unsupported NIP-44 payload version.',
      );
    }
    // Smallest possible payload: version(1) + nonce(32) + 1 ChaCha20
    // block's worth of ciphertext(32) + mac(32) = 97 bytes -> ceil to
    // base64's 4-byte groups and account for the '=' padding chars used
    // at these exact lengths; largest: 65535-byte plaintext, padded and
    // base64-encoded. These bounds match the reference implementation and
    // reject obviously-malformed payloads before the (more expensive)
    // base64 decode + MAC check.
    if (payload.length < 132 || payload.length > 87472) {
      throw const FormatException('NIP-44 payload has an invalid size.');
    }

    final Uint8List data;
    try {
      data = base64.decode(payload);
    } on FormatException {
      throw const FormatException('NIP-44 payload is not valid base64.');
    }

    if (data[0] != 0x02) {
      throw const FormatException('Unsupported NIP-44 payload version.');
    }

    return (
      nonce: data.sublist(1, 33),
      ciphertext: data.sublist(33, data.length - 32),
      mac: data.sublist(data.length - 32),
    );
  }

  // ---------------------------------------------------------------------
  // Small shared helpers.
  // ---------------------------------------------------------------------

  static Uint8List _hexToBytes(String hex) {
    final bytes = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return bytes;
  }

  static Uint8List _bigIntToBytes(BigInt value, int length) {
    final hex = value.toRadixString(16).padLeft(length * 2, '0');
    return _hexToBytes(hex);
  }

  static final Random _secureRandom = Random.secure();

  static Uint8List _randomBytes(int length) {
    return Uint8List.fromList(
      List<int>.generate(length, (_) => _secureRandom.nextInt(256)),
    );
  }
}
