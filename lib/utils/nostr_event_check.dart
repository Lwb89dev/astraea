import 'package:dart_nostr/dart_nostr.dart';

/// Relays are untrusted transport: anything that arrives over a websocket is
/// attacker-controlled until proven otherwise.
///
/// Verifies both halves of NIP-01 validity for [event]:
///  1. the `id` really is the SHA-256 of the canonically serialized fields, and
///  2. the Schnorr signature authenticates that `id` under `pubkey`.
///
/// `dart_nostr`'s own `isVerified()` only checks (2). Without (1) a relay could
/// keep a valid signature and swap the `content`/`tags` it is presented with,
/// because nothing would re-derive the id the signature actually covers.
///
/// [expectedAuthor] and [expectedKind] are checked too, so a caller can never
/// be handed a correctly signed event that simply belongs to someone else or to
/// a different protocol flow (a signed kind-1 note replayed into the calendar
/// fetch, a NIP-46 reply forged by a relay under its own key, …).
///
/// Returns `false` — never throws — for any malformed input, so callers can use
/// it as a plain filter.
bool isAuthenticNostrEvent(
  NostrEvent event, {
  required String expectedAuthor,
  required int expectedKind,
}) {
  try {
    final id = event.id;
    final content = event.content;
    final createdAt = event.createdAt;
    final tags = event.tags;
    if (id == null || content == null || createdAt == null || tags == null) {
      return false;
    }
    if (event.pubkey != expectedAuthor || event.kind != expectedKind) {
      return false;
    }
    final computedId = NostrEvent.getEventId(
      kind: expectedKind,
      content: content,
      createdAt: createdAt,
      tags: tags,
      pubkey: event.pubkey,
    );
    return computedId == id && event.isVerified();
  } catch (_) {
    return false;
  }
}
