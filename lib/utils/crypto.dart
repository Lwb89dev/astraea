import 'nip44.dart';

/// NIP-44 encryption for the `content` field of calendar-event events.
///
/// Events are "self-encrypted": the sender and recipient are the same person
/// (the event's owner), so only whoever holds the private key can ever
/// decrypt them — that is what keeps them invisible to everyone else on the
/// relay, including the relay operator.
///
/// `dart_nostr` (the main Nostr SDK used elsewhere in Astraea) does not
/// implement NIP-44, so this wraps [Nip44] — see that file for the full
/// algorithm and why it's a direct implementation rather than a third-party
/// package. NIP-44 supersedes the older NIP-04 (ECDH + plain AES-256-CBC, no
/// padding, no message authentication), which the Nostr protocol now marks
/// deprecated; Astraea does not use NIP-04 anywhere.
///
/// Astraea only ever holds the private key locally (imported or generated),
/// so there is no external-signer (Amber) path here — unlike Echoes.
class CryptoUtils {
  CryptoUtils._();

  /// Encrypts [plaintext] with NIP-44 using [privateKeyHex] and
  /// [recipientPublicKeyHex]. For self-encrypted events,
  /// [recipientPublicKeyHex] is the same account's own public key.
  static String encryptNip44({
    required String plaintext,
    required String privateKeyHex,
    required String recipientPublicKeyHex,
  }) {
    return Nip44.encrypt(
      plaintext: plaintext,
      senderPrivateKeyHex: privateKeyHex,
      recipientPublicKeyHex: recipientPublicKeyHex,
    );
  }

  /// Decrypts a NIP-44 payload using [privateKeyHex] and
  /// [senderPublicKeyHex]. For self-encrypted events, [senderPublicKeyHex]
  /// is the same account's own public key.
  static String decryptNip44({
    required String ciphertext,
    required String privateKeyHex,
    required String senderPublicKeyHex,
  }) {
    return Nip44.decrypt(
      payload: ciphertext,
      recipientPrivateKeyHex: privateKeyHex,
      senderPublicKeyHex: senderPublicKeyHex,
    );
  }
}
