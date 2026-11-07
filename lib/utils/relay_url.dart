/// Returns a normalized Nostr relay URL, or `null` when [input] is malformed.
///
/// `wss://` (encrypted) is the recommended scheme and what every suggested
/// public relay uses. Plain `ws://` is also accepted — personal/self-hosted
/// relays (e.g. on localhost or a home LAN) often have no TLS certificate —
/// but it is not silently upgraded: event *content* stays NIP-44 encrypted
/// end-to-end either way, so a `ws://` relay only trades away transport-level
/// confidentiality of protocol metadata (pubkey, timing, sizes) that a
/// passive network observer could see; callers should surface that trade-off
/// to the user (see the relay settings UI) rather than silently accepting it.
///
/// Relay configuration is shared by onboarding and Settings; keeping this
/// check in one place prevents the two entry points from accepting different
/// values. Fragments and embedded credentials have no meaning for a relay and
/// are rejected rather than silently discarded.
String? normalizeRelayUrl(String input) {
  final uri = Uri.tryParse(input.trim());
  final scheme = uri?.scheme.toLowerCase();
  if (uri == null ||
      (scheme != 'wss' && scheme != 'ws') ||
      uri.host.isEmpty ||
      uri.hasFragment ||
      uri.userInfo.isNotEmpty) {
    return null;
  }

  return uri.replace(scheme: scheme, host: uri.host.toLowerCase()).toString();
}

/// Whether [url] is an unencrypted relay connection (already validated by
/// [normalizeRelayUrl]) — used to show an inline warning in the UI.
bool isInsecureRelayUrl(String url) => url.startsWith('ws://');
