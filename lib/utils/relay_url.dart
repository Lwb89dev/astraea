/// Returns a normalized secure Nostr relay URL, or `null` when [input] is
/// malformed or would use an unencrypted websocket connection.
///
/// Relay configuration is shared by onboarding and Settings; keeping this
/// check in one place prevents the two entry points from accepting different
/// values. Fragments and embedded credentials have no meaning for a relay and
/// are rejected rather than silently discarded.
String? normalizeSecureRelayUrl(String input) {
  final uri = Uri.tryParse(input.trim());
  if (uri == null ||
      uri.scheme.toLowerCase() != 'wss' ||
      uri.host.isEmpty ||
      uri.hasFragment ||
      uri.userInfo.isNotEmpty) {
    return null;
  }

  return uri.replace(scheme: 'wss', host: uri.host.toLowerCase()).toString();
}
