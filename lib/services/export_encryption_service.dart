import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

/// Password-based encryption for event exports.
///
/// An unencrypted `.ics` is exactly as sensitive as the calendar it contains —
/// every title, location and time in the clear — so exports can optionally be
/// wrapped in a password-protected envelope before leaving the device. This is
/// a separate concern from NIP-44 relay sync (which protects the *synced*
/// copy): it protects a file the user is about to put in cloud storage or send
/// to themselves.
///
/// Algorithms match Echoes' encrypted note exports: PBKDF2-HMAC-SHA256 with
/// 210,000 iterations (OWASP 2023 guidance) to derive a 256-bit key from the
/// password, then AES-256-GCM (authenticated) for the payload. The envelope is
/// self-contained — it carries its own random salt — so [decryptWithPassword]
/// needs nothing but the same password.
class ExportEncryptionService {
  static const _pbkdf2Iterations = 210000;
  static const _keyBits = 256;
  static const _saltLength = 16;

  final Pbkdf2 _pbkdf2 = Pbkdf2.hmacSha256(
    iterations: _pbkdf2Iterations,
    bits: _keyBits,
  );
  final AesGcm _aesGcm = AesGcm.with256bits();

  /// Encrypts [plaintext] (the .ics document) with a key derived fresh from
  /// [password], returning a self-contained envelope map.
  Future<Map<String, dynamic>> encryptWithPassword(
    String plaintext,
    String password,
  ) async {
    final salt = _randomBytes(_saltLength);
    final key = await _deriveKey(password, salt);
    final box = await _aesGcm.encrypt(utf8.encode(plaintext), secretKey: key);
    return {
      'salt': base64Encode(salt),
      'ciphertext': base64Encode(box.cipherText),
      'nonce': base64Encode(box.nonce),
      'mac': base64Encode(box.mac.bytes),
    };
  }

  /// Decrypts an envelope produced by [encryptWithPassword]. Throws
  /// [SecretBoxAuthenticationError] on a wrong password — callers should catch
  /// that specifically to show an inline "wrong password" message.
  Future<String> decryptWithPassword(
    Map<String, dynamic> stored,
    String password,
  ) async {
    final salt = base64Decode(stored['salt'] as String);
    final key = await _deriveKey(password, salt);
    final plaintext = await _aesGcm.decrypt(
      SecretBox(
        base64Decode(stored['ciphertext'] as String),
        nonce: base64Decode(stored['nonce'] as String),
        mac: Mac(base64Decode(stored['mac'] as String)),
      ),
      secretKey: key,
    );
    return utf8.decode(plaintext);
  }

  Future<SecretKey> _deriveKey(String password, List<int> salt) {
    return _pbkdf2.deriveKeyFromPassword(password: password, nonce: salt);
  }

  List<int> _randomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }
}
