/// How this Nostr account is held on the device.
enum LoginMethod {
  /// An existing private key (nsec/hex) the user imported. Held locally in
  /// flutter_secure_storage; Astraea signs/encrypts on-device.
  importedKey,

  /// A brand-new keypair Astraea generated for the user on this device. Also
  /// held locally.
  generatedKey,

  /// External signer (Amber, NIP-55, Android only). The app never sees the
  /// private key: every signing / NIP-44 encrypt / NIP-44 decrypt goes
  /// through an intent to Amber. [User.privateKeyHex] is always null.
  amber,

  /// Remote signer over NIP-46 ("bunker"), available on every platform. The
  /// app never sees the account private key: it holds only a throwaway client
  /// key and sends every signing / NIP-44 operation to the user's own signer
  /// over a relay. [User.privateKeyHex] is always null.
  remoteSigner;

  /// Whether Astraea holds the account private key itself (local signing and
  /// local NIP-44 crypto) rather than delegating every operation to an
  /// external signer. Enumerated positively — adding a new external-signer
  /// mode must not silently make it look like a local-key session.
  bool get isLocalKey => this == importedKey || this == generatedKey;

  /// Whether signing requires a round-trip to software outside Astraea. Such
  /// sessions can involve user interaction (an Amber prompt, a bunker
  /// approval), so they are never triggered silently in the background.
  bool get usesExternalSigner => !isLocalKey;
}

/// Identity of the logged-in Nostr account: public key in hex + its bech32
/// (npub) form for display.
class User {
  final String publicKeyHex;
  final String npub;
  final LoginMethod loginMethod;

  /// The account private key (hex). Kept out of logs and never persisted in
  /// plaintext — it lives in [LocalStorageService]'s secure storage and is
  /// read only when signing or NIP-44 encrypting/decrypting an event.
  final String? privateKeyHex;

  const User({
    required this.publicKeyHex,
    required this.npub,
    required this.loginMethod,
    this.privateKeyHex,
  });
}
