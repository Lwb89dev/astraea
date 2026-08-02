import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:dart_nostr/dart_nostr.dart';

import '../utils/nip44.dart';
import '../utils/nostr_event_check.dart';
import '../utils/relay_url.dart';

/// NIP-46 ("Nostr Connect" / bunker) remote-signer client.
///
/// The point of NIP-46 is that Astraea never holds the account's private key:
/// it holds a *separate, throwaway* client key, and every operation that would
/// need the account key (signing an event, NIP-44 encrypting or decrypting a
/// calendar entry) is sent as an encrypted request to a remote signer that the
/// user controls — a phone app, a self-hosted bunker, or a hosted service.
///
/// Wire format (all of it is deliberately spelled out here so this file can be
/// audited without reading the spec):
///
/// ```
///  Astraea (ephemeral client key)              remote signer (account key)
///        │  kind 24133, p-tagged to the signer, content = NIP-44 encrypt
///        │  under conversation key (client_sk, signer_pk) of
///        │  {"id":"<random>","method":"sign_event","params":["<json>"]}
///        │────────────────── relay(s) from the bunker URI ───────────────►
///        │
///        │  kind 24133, p-tagged back to the client, same encryption,
///        │  {"id":"<same>","result":"<value>"} or {"id":..,"error":".."}
///        ◄───────────────────────────────────────────────────────────────
/// ```
///
/// Threat model notes, because this class talks to an untrusted relay:
///  - Every inbound frame is checked with [isAuthenticNostrEvent] against the
///    signer's pubkey *and* kind 24133 before it is decrypted. A relay cannot
///    inject replies, and cannot replay a reply from another conversation.
///  - Request ids are 16 random bytes from [Random.secure]; a reply is only
///    ever matched to a request Astraea actually issued and is still waiting
///    for, so a relay cannot answer a question that was never asked.
///  - Inbound content is size-capped ([_maxResponseChars]) before decryption,
///    and the number of concurrently outstanding requests is capped
///    ([_maxPendingRequests]), so neither a hostile relay nor a hostile signer
///    can turn the connection into unbounded memory growth.
///  - Every request is bounded by [requestTimeout]; a signer that simply never
///    answers surfaces as an error instead of hanging the UI forever.
///  - Nothing here logs request parameters, results, plaintexts, ciphertexts,
///    the client key or the bunker secret — a calendar entry's title is as
///    sensitive as the entry itself.
class Nip46Client {
  Nip46Client({
    required this.nostr,
    required this.target,
    required this.clientPrivateKeyHex,
    required this.connectRelays,
    this.onAuthUrl,
    this.requestTimeout = const Duration(seconds: 60),
  });

  /// Nostr event kind carrying NIP-46 requests and responses in both
  /// directions. Fixed by the spec.
  static const int connectEventKind = 24133;

  /// A signer reply is a small JSON document (the largest realistic one is a
  /// signed event, itself bounded by what Astraea asked it to sign). Anything
  /// bigger is a relay flooding us, not a signer answering us.
  static const int _maxResponseChars = 256 * 1024;

  /// Astraea issues NIP-46 requests strictly one calendar operation at a time,
  /// so a handful of in-flight requests is already generous. The cap exists so
  /// a stuck signer cannot make the pending map grow without limit.
  static const int _maxPendingRequests = 32;

  /// Tolerance for clock skew between this device and the signer when asking
  /// relays for "replies from now on". Without it, a device whose clock runs
  /// slightly fast would filter out the signer's own replies.
  static const Duration _subscriptionSkew = Duration(minutes: 2);

  /// Injected rather than reached for as a global, so a test can drive the
  /// client against a fake relay pool.
  final Nostr nostr;

  final Nip46Target target;

  /// The ephemeral key Astraea generated for this connection. It is NOT the
  /// account key and can sign nothing but NIP-46 request envelopes; the signer
  /// authorizes it by pubkey. Persisted only in secure storage.
  final String clientPrivateKeyHex;

  /// Injected rather than calling the relay pool directly, so relay URL
  /// validation and connection options stay defined in exactly one place
  /// ([NostrService.connectToRelays]).
  final Future<void> Function(List<String> relayUrls) connectRelays;

  /// Called when the signer answers `auth_url`: the user must visit that URL
  /// (typically to approve the connection in a browser) before the original
  /// request can succeed. The request stays pending meanwhile.
  final void Function(String url)? onAuthUrl;

  final Duration requestTimeout;

  final Map<String, Completer<String>> _pending = {};
  final Random _random = Random.secure();

  NostrKeyPairs? _clientKeys;
  NostrEventsStream? _subscription;
  StreamSubscription<NostrEvent>? _listener;
  bool _closed = false;

  /// Public key of the ephemeral client identity, as the signer sees it.
  String get clientPublicKeyHex => _keys.public;

  NostrKeyPairs get _keys {
    return _clientKeys ??= nostr.services.keys
        .generateKeyPairFromExistingPrivateKey(clientPrivateKeyHex);
  }

  /// Performs the NIP-46 `connect` handshake and returns the account public key
  /// the signer is willing to act for.
  ///
  /// The optional secret from the bunker URI is passed straight through: it is
  /// the signer's own proof that whoever pasted the URI is the person it was
  /// issued to, and it is single-use on the signer side.
  Future<String> connect() async {
    // `connect`'s first parameter is the signer's own pubkey. Sending the
    // secret (when the URI carried one) is what makes the signer accept this
    // brand-new client key at all.
    final params = <String>[target.remoteSignerPubkeyHex, target.secret ?? ''];
    final ack = await _request('connect', params);
    if (ack != 'ack' && ack.isEmpty) {
      throw const Nip46Exception('The remote signer refused the connection.');
    }
    return getPublicKey();
  }

  /// The account public key (hex) the signer signs for. Validated here so a
  /// malicious signer cannot hand back something that is not a pubkey at all.
  Future<String> getPublicKey() async {
    final raw = (await _request('get_public_key', const [])).trim();
    final hex = raw.startsWith('npub1')
        ? nostr.services.bech32.decodeNpubKeyToPublicKey(raw)
        : raw.toLowerCase();
    if (!_isPubkeyHex(hex)) {
      throw const Nip46Exception('The remote signer returned no usable key.');
    }
    return hex;
  }

  /// Asks the signer to sign [unsigned] (a NIP-01 event object without `id`,
  /// `pubkey` and `sig`) and returns the signed event as a JSON map.
  ///
  /// The caller is responsible for checking that what came back is the event it
  /// asked to have signed — see [NostrService], which compares every field.
  Future<Map<String, dynamic>> signEvent(Map<String, dynamic> unsigned) async {
    final raw = await _request('sign_event', [jsonEncode(unsigned)]);
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const Nip46Exception('The remote signer returned no signed event.');
    }
    return decoded;
  }

  /// NIP-44 encryption performed by the signer, using the *account* key.
  /// [peerPubkeyHex] equals the account pubkey for Astraea's self-encrypted
  /// calendar entries.
  Future<String> nip44Encrypt({
    required String peerPubkeyHex,
    required String plaintext,
  }) {
    return _request('nip44_encrypt', [peerPubkeyHex, plaintext]);
  }

  Future<String> nip44Decrypt({
    required String peerPubkeyHex,
    required String ciphertext,
  }) {
    return _request('nip44_decrypt', [peerPubkeyHex, ciphertext]);
  }

  /// Releases the relay subscription and fails every outstanding request.
  /// Safe to call more than once.
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _listener?.cancel();
    _subscription?.close();
    _listener = null;
    _subscription = null;
    final pending = List.of(_pending.values);
    _pending.clear();
    for (final completer in pending) {
      if (!completer.isCompleted) {
        completer.completeError(
          const Nip46Exception('The remote signer connection was closed.'),
        );
      }
    }
  }

  // ---------------------------------------------------------------------
  // Request / response plumbing
  // ---------------------------------------------------------------------

  Future<String> _request(String method, List<String> params) async {
    if (_closed) {
      throw const Nip46Exception('The remote signer connection was closed.');
    }
    if (_pending.length >= _maxPendingRequests) {
      throw const Nip46Exception('Too many pending remote-signer requests.');
    }
    await _ensureSubscribed();

    final id = _randomHex(16);
    final completer = Completer<String>();
    _pending[id] = completer;
    try {
      await _send(id, method, params);
      return await completer.future.timeout(
        requestTimeout,
        onTimeout: () => throw const Nip46Exception(
          'The remote signer did not respond in time. '
          'Open your signer app to approve the request, then try again.',
        ),
      );
    } finally {
      _pending.remove(id);
    }
  }

  Future<void> _send(String id, String method, List<String> params) async {
    final envelope = jsonEncode({'id': id, 'method': method, 'params': params});
    final content = Nip44.encrypt(
      plaintext: envelope,
      senderPrivateKeyHex: clientPrivateKeyHex,
      recipientPublicKeyHex: target.remoteSignerPubkeyHex,
    );
    final event = NostrEvent.fromPartialData(
      kind: connectEventKind,
      content: content,
      keyPairs: _keys,
      tags: [
        ['p', target.remoteSignerPubkeyHex],
      ],
      createdAt: DateTime.now(),
    );
    // Fire-and-forget rather than waiting for OK: the answer we care about is
    // the signer's reply event, and a relay that never sends OK must not stall
    // a request that is otherwise progressing over a second relay.
    await nostr.services.relays.sendEventToRelays(event, relays: target.relays);
    developer.log('NIP-46 request sent: $method', name: 'Nip46Client');
  }

  /// Opens the single long-lived REQ for replies addressed to the client key.
  /// Idempotent: every request calls it, only the first one does any work.
  Future<void> _ensureSubscribed() async {
    if (_subscription != null) return;
    await connectRelays(target.relays);

    final subscription = nostr.services.relays.startEventsSubscription(
      request: NostrRequest(
        filters: [
          NostrFilter(
            kinds: const [connectEventKind],
            authors: [target.remoteSignerPubkeyHex],
            p: [clientPublicKeyHex],
            since: DateTime.now().subtract(_subscriptionSkew),
          ),
        ],
      ),
      relays: target.relays,
    );
    _subscription = subscription;
    _listener = subscription.stream.listen(
      _onEvent,
      onError: (Object _) {
        // Relay-level stream errors are transport noise: individual requests
        // already fail on their own timeout, and dart_nostr reconnects.
      },
    );
  }

  void _onEvent(NostrEvent event) {
    final content = event.content;
    if (content == null || content.length > _maxResponseChars) return;
    if (!isAuthenticNostrEvent(
      event,
      expectedAuthor: target.remoteSignerPubkeyHex,
      expectedKind: connectEventKind,
    )) {
      return;
    }
    final response = _decodeResponse(content);
    if (response == null) return;

    final id = response['id'];
    if (id is! String) return;
    final completer = _pending[id];
    if (completer == null || completer.isCompleted) return;

    // `auth_url` is not an answer: the signer is asking the user to approve
    // this client in a browser first, and will send the real reply afterwards.
    // Keep waiting (the request timeout still applies).
    final result = response['result'];
    if (result == 'auth_url') {
      _handleAuthUrl(response['error']);
      return;
    }

    final error = response['error'];
    if (error is String && error.isNotEmpty) {
      completer.completeError(Nip46Exception('Remote signer: $error'));
      return;
    }
    if (result is! String) {
      completer.completeError(
        const Nip46Exception('The remote signer sent a malformed reply.'),
      );
      return;
    }
    completer.complete(result);
  }

  /// Decrypts and parses a reply. Failures are silent by design: a relay can
  /// deliver anything at all to this subscription, and none of it should be
  /// able to raise out of a stream callback or end up in a log line.
  Map<String, dynamic>? _decodeResponse(String content) {
    try {
      final plaintext = Nip44.decrypt(
        payload: content,
        recipientPrivateKeyHex: clientPrivateKeyHex,
        senderPublicKeyHex: target.remoteSignerPubkeyHex,
      );
      final decoded = jsonDecode(plaintext);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  void _handleAuthUrl(Object? raw) {
    final callback = onAuthUrl;
    if (callback == null || raw is! String) return;
    // Only ever hand an https URL to the platform launcher: the signer is
    // semi-trusted, and `file:`/`intent:`/`javascript:` URLs from a remote
    // party are an obvious escalation vector.
    final uri = Uri.tryParse(raw);
    if (uri == null || uri.scheme.toLowerCase() != 'https') return;
    callback(uri.toString());
  }

  String _randomHex(int bytes) {
    final buffer = StringBuffer();
    for (var i = 0; i < bytes; i++) {
      buffer.write(_random.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}

/// Where a NIP-46 signer lives: its identity key, the relays it listens on, and
/// the optional single-use secret from the connection string.
class Nip46Target {
  const Nip46Target({
    required this.remoteSignerPubkeyHex,
    required this.relays,
    this.secret,
  });

  final String remoteSignerPubkeyHex;
  final List<String> relays;
  final String? secret;

  /// Upper bound on relays taken from a pasted connection string. A bunker
  /// normally publishes one or two; the cap stops a hostile string from making
  /// the app open dozens of websockets (and leaking the user's IP to each).
  static const int maxRelays = 4;

  /// Parses a `bunker://<signer-pubkey-hex>?relay=…&relay=…&secret=…` string.
  ///
  /// Returns `null` for anything that is not a well-formed bunker URI with at
  /// least one usable relay. Deliberately detail-free: the caller shows a
  /// generic message rather than echoing back a string that may contain the
  /// connection secret.
  static Nip46Target? parseBunkerUri(String raw) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null || uri.scheme.toLowerCase() != 'bunker') return null;

    // `bunker://<pubkey>` puts the pubkey in the authority, but some signers
    // emit `bunker:<pubkey>` where it lands in the path instead.
    final pubkey =
        (uri.host.isNotEmpty ? uri.host : uri.path.replaceAll('/', ''))
            .toLowerCase();
    if (!_isPubkeyHex(pubkey)) return null;

    final relays = <String>{};
    for (final candidate
        in uri.queryParametersAll['relay'] ?? const <String>[]) {
      final normalized = normalizeRelayUrl(candidate);
      if (normalized != null) relays.add(normalized);
      if (relays.length >= maxRelays) break;
    }
    if (relays.isEmpty) return null;

    final secret = uri.queryParameters['secret'];
    return Nip46Target(
      remoteSignerPubkeyHex: pubkey,
      relays: relays.toList(growable: false),
      secret: (secret == null || secret.isEmpty) ? null : secret,
    );
  }
}

/// Everything needed to re-open a remote-signer connection after an app
/// restart. Contains the ephemeral client private key and (possibly) the
/// bunker secret, so it belongs in secure storage and nowhere else.
class Nip46Session {
  const Nip46Session({
    required this.target,
    required this.clientPrivateKeyHex,
    required this.userPubkeyHex,
  });

  final Nip46Target target;
  final String clientPrivateKeyHex;

  /// The account pubkey the signer confirmed at connect time.
  final String userPubkeyHex;

  Map<String, dynamic> toJson() => {
    'version': 1,
    'signer': target.remoteSignerPubkeyHex,
    'relays': target.relays,
    if (target.secret != null) 'secret': target.secret,
    'clientKey': clientPrivateKeyHex,
    'user': userPubkeyHex,
  };

  /// Rebuilds a session from secure storage, re-validating every field.
  /// Returns `null` if the stored blob is from an unknown version or has been
  /// tampered with — the caller then treats the account as logged out rather
  /// than trusting half a session.
  static Nip46Session? fromJson(Map<String, dynamic> json) {
    if (json['version'] != 1) return null;
    final signer = json['signer'];
    final clientKey = json['clientKey'];
    final user = json['user'];
    if (signer is! String || clientKey is! String || user is! String) {
      return null;
    }
    if (!_isPubkeyHex(signer) || !_isPubkeyHex(user)) return null;
    if (!_isPubkeyHex(clientKey)) return null;

    final relays = <String>[];
    for (final value in (json['relays'] as List?) ?? const []) {
      final normalized = value is String ? normalizeRelayUrl(value) : null;
      if (normalized != null) relays.add(normalized);
      if (relays.length >= Nip46Target.maxRelays) break;
    }
    if (relays.isEmpty) return null;

    final secret = json['secret'];
    return Nip46Session(
      target: Nip46Target(
        remoteSignerPubkeyHex: signer,
        relays: relays,
        secret: secret is String && secret.isNotEmpty ? secret : null,
      ),
      clientPrivateKeyHex: clientKey,
      userPubkeyHex: user,
    );
  }
}

/// Failure of a remote-signer operation. The message is safe to show: it never
/// carries key material, request parameters or decrypted content.
class Nip46Exception implements Exception {
  const Nip46Exception(this.message);

  final String message;

  @override
  String toString() => message;
}

/// A 32-byte lowercase hex string — the shape of both a Nostr public key and a
/// Nostr private key.
bool _isPubkeyHex(String value) {
  if (value.length != 64) return false;
  for (final unit in value.codeUnits) {
    final isDigit = unit >= 0x30 && unit <= 0x39;
    final isLowerHex = unit >= 0x61 && unit <= 0x66;
    if (!isDigit && !isLowerHex) return false;
  }
  return true;
}
