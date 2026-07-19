/// A Nostr account's public profile card (NIP-01 kind 0 "set_metadata").
///
/// Unlike the calendar events, this is **not** encrypted: kind 0 is a plain,
/// public Nostr event by design — the same profile card any other Nostr client
/// reads. Astraea only ever fetches its own signed-in user's profile (to show a
/// friendly name/avatar in Settings instead of a raw npub), never anyone
/// else's.
class NostrProfile {
  final String publicKeyHex;
  final String? name;
  final String? displayName;
  final String? picture;
  final String? about;

  const NostrProfile({
    required this.publicKeyHex,
    this.name,
    this.displayName,
    this.picture,
    this.about,
  });

  /// The best available human-readable label, preferring `display_name` (the
  /// user's chosen "pretty" name) over `name` (the NIP-05-adjacent handle).
  /// Null if neither is set, so callers can fall back to a truncated npub.
  String? get label {
    final trimmedDisplayName = displayName?.trim();
    if (trimmedDisplayName != null && trimmedDisplayName.isNotEmpty) {
      return trimmedDisplayName;
    }
    final trimmedName = name?.trim();
    if (trimmedName != null && trimmedName.isNotEmpty) return trimmedName;
    return null;
  }

  /// Parses a kind-0 event's `content` (already JSON-decoded). Every field is
  /// optional per spec, so nothing here throws for a sparse or unfamiliar
  /// profile — a missing/malformed field is treated as absent.
  factory NostrProfile.fromMetadataJson(
    String publicKeyHex,
    Map<String, dynamic> json,
  ) {
    return NostrProfile(
      publicKeyHex: publicKeyHex,
      name: json['name'] as String?,
      displayName: json['display_name'] as String?,
      picture: json['picture'] as String?,
      about: json['about'] as String?,
    );
  }

  /// Serialized for the small local cache in SharedPreferences (see
  /// [ProfileNotifier]) — unrelated to the Nostr wire format.
  Map<String, dynamic> toJson() => {
    'publicKeyHex': publicKeyHex,
    'name': name,
    'displayName': displayName,
    'picture': picture,
    'about': about,
  };

  factory NostrProfile.fromJson(Map<String, dynamic> json) {
    return NostrProfile(
      publicKeyHex: json['publicKeyHex'] as String,
      name: json['name'] as String?,
      displayName: json['displayName'] as String?,
      picture: json['picture'] as String?,
      about: json['about'] as String?,
    );
  }
}
