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
  amber;

  /// Whether Astraea holds the private key itself (local signing/crypto) vs.
  /// delegating to Amber.
  bool get isLocalKey => this != amber;
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
