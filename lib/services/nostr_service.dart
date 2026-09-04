import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:amberflutter/amberflutter.dart';
import 'package:dart_nostr/dart_nostr.dart';
import 'package:flutter/services.dart' show MissingPluginException;

import '../models/event_model.dart';
import '../models/profile.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/crypto.dart';
import '../utils/nostr_event_check.dart';
import '../utils/relay_url.dart';
import 'nip46_client.dart';

/// Wraps all interaction with the Nostr protocol: key generation/import,
/// npub/nsec conversion (NIP-19 bech32), login, event signing + NIP-44
/// encryption, relay transport, and the REQ that pulls the user's encrypted
/// calendar events.
///
/// Three identity modes, all funnelling through [_encrypt], [_decryptEvent]
/// and [_signEvent] so the rest of the app never has to know which is active:
///  - Local key ([LoginMethod.importedKey]/[LoginMethod.generatedKey]): the
///    private key is held on-device; signing and NIP-44 crypto happen locally
///    (via `dart_nostr` + [CryptoUtils]).
///  - Amber ([LoginMethod.amber], NIP-55, Android only): the private key never
///    enters the app; signing and NIP-44 encrypt/decrypt are delegated to
///    Amber over intents. The exact same branching Echoes uses.
///  - Remote signer ([LoginMethod.remoteSigner], NIP-46 "bunker", every
///    platform): the private key never enters the app either; operations are
///    encrypted requests to the user's own signer over a relay
///    ([Nip46Client]).
class NostrService {
  final Nostr _nostr = Nostr.instance;
  final Amberflutter _amber = Amberflutter();

  /// The live NIP-46 connection, when the session is [LoginMethod.remoteSigner].
  /// Owned here (not by a provider) because it must outlive individual screens
  /// and be shared by publish, fetch and delete alike.
  Nip46Client? _remoteSigner;

  // -------------------------------------------------------------------
  // Bounds on what a relay can make this process hold in memory. Relays are
  // untrusted: they choose how many events to send and how large each one is.
  // -------------------------------------------------------------------

  /// Upper bound on events kept from one REQ. Comfortably above any realistic
  /// personal calendar.
  static const int _maxFetchedEvents = 5000;

  /// Upper bound on one event's encrypted `content`. A NIP-44 payload for a
  /// calendar entry is a few kilobytes; anything at this size is already
  /// pathological.
  static const int _maxEventContentChars = 90000;

  /// Upper bound on the *combined* content of one REQ — the bound that
  /// actually caps memory, since the two above would otherwise multiply out
  /// to hundreds of megabytes. 20 MiB-equivalent covers a very large calendar
  /// with room to spare, and matches the Linux service's own fetch budget.
  static const int _maxFetchTotalChars = 20 * 1024 * 1024;

  // -------------------------------------------------------------------
  // Identity / login
  // -------------------------------------------------------------------

  /// Converts a hex public key to its bech32 `npub` form (NIP-19).
  String publicKeyToNpub(String publicKeyHex) {
    return _nostr.services.bech32.encodePublicKeyToNpub(publicKeyHex);
  }

  /// Converts a hex private key to its bech32 `nsec` — shown once to a user
  /// who just generated an account so they can back it up. Never logged or
  /// persisted in this form.
  String privateKeyToNsec(String privateKeyHex) {
    return _nostr.services.bech32.encodePrivateKeyToNsec(privateKeyHex);
  }

  /// Generates a brand-new keypair for a first-time user
  /// ([LoginMethod.generatedKey]).
  Future<User> generateAccount() async {
    developer.log('NostrService.generateAccount called', name: 'NostrService');
    final keyPair = _nostr.services.keys.generateKeyPair();
    return User(
      publicKeyHex: keyPair.public,
      npub: publicKeyToNpub(keyPair.public),
      loginMethod: LoginMethod.generatedKey,
      privateKeyHex: keyPair.private,
    );
  }

  /// Imports an existing account from an nsec (bech32) or raw hex private key.
  /// Throws [InvalidPrivateKeyException] (detail-free) if it can't be decoded.
  Future<User> importAccount(String privateKey) async {
    developer.log('NostrService.importAccount called', name: 'NostrService');
    final trimmed = privateKey.trim();
    try {
      final privateKeyHex = trimmed.startsWith('nsec1')
          ? _nostr.services.bech32.decodeNsecKeyToPrivateKey(trimmed)
          : trimmed.toLowerCase();
      if (!_nostr.services.keys.isValidPrivateKey(privateKeyHex)) {
        throw const InvalidPrivateKeyException();
      }
      return _userFromPrivateKey(privateKeyHex, LoginMethod.importedKey);
    } on InvalidPrivateKeyException {
      rethrow;
    } catch (_) {
      throw const InvalidPrivateKeyException();
    }
  }

  /// Rebuilds a local-key session from a stored private key on app restart.
  /// [method] is the persisted [LoginMethod], so a generated account doesn't
  /// silently turn into an "imported" one across restarts.
  Future<User> login(
    String privateKeyHex, {
    LoginMethod method = LoginMethod.importedKey,
  }) async {
    developer.log('NostrService.login called', name: 'NostrService');
    return _userFromPrivateKey(privateKeyHex, method);
  }

  /// Rebuilds an Amber session from the saved public key on app restart (no
  /// private key involved).
  User amberSession(String publicKeyHex) {
    return User(
      publicKeyHex: publicKeyHex,
      npub: publicKeyToNpub(publicKeyHex),
      loginMethod: LoginMethod.amber,
    );
  }

  // -------------------------------------------------------------------
  // Remote signer (NIP-46 / bunker)
  // -------------------------------------------------------------------

  /// Signs in against a remote signer using a pasted `bunker://…` connection
  /// string, and returns both the resulting [User] and the [Nip46Session] the
  /// caller must persist in secure storage.
  ///
  /// The string is parsed, not trusted: an unparseable one raises a
  /// [Nip46Exception] whose message deliberately contains none of what the
  /// user pasted (a bunker URI embeds a single-use secret).
  ///
  /// [onAuthUrl] is invoked if the signer asks for interactive approval in a
  /// browser; the connection attempt keeps waiting while the user does that.
  Future<({User user, Nip46Session session})> loginWithRemoteSigner(
    String bunkerUri, {
    void Function(String url)? onAuthUrl,
  }) async {
    developer.log(
      'NostrService.loginWithRemoteSigner called',
      name: 'NostrService',
    );
    final target = Nip46Target.parseBunkerUri(bunkerUri);
    if (target == null) {
      throw const Nip46Exception(
        'That is not a valid bunker:// connection string.',
      );
    }

    // A fresh throwaway identity per connection: it authorizes only this
    // install against the signer, is revocable there, and is never the
    // account key.
    final clientKeys = _nostr.services.keys.generateKeyPair();
    final client = Nip46Client(
      nostr: _nostr,
      target: target,
      clientPrivateKeyHex: clientKeys.private,
      connectRelays: connectToRelays,
      onAuthUrl: onAuthUrl,
      requestTimeout: AppConstants.remoteSignerRequestTimeout,
    );

    try {
      final publicKeyHex = await client.connect();
      await _replaceRemoteSigner(client);
      return (
        user: User(
          publicKeyHex: publicKeyHex,
          npub: publicKeyToNpub(publicKeyHex),
          loginMethod: LoginMethod.remoteSigner,
        ),
        session: Nip46Session(
          target: target,
          clientPrivateKeyHex: clientKeys.private,
          userPubkeyHex: publicKeyHex,
        ),
      );
    } catch (_) {
      await client.close();
      rethrow;
    }
  }

  /// Rebuilds a remote-signer session from secure storage on app restart. No
  /// round-trip happens here: the connection is opened lazily on the first
  /// operation, so a signer that is currently offline does not block startup.
  User restoreRemoteSignerSession(Nip46Session session) {
    _replaceRemoteSigner(
      Nip46Client(
        nostr: _nostr,
        target: session.target,
        clientPrivateKeyHex: session.clientPrivateKeyHex,
        connectRelays: connectToRelays,
        requestTimeout: AppConstants.remoteSignerRequestTimeout,
      ),
    );
    return User(
      publicKeyHex: session.userPubkeyHex,
      npub: publicKeyToNpub(session.userPubkeyHex),
      loginMethod: LoginMethod.remoteSigner,
    );
  }

  /// Tears down the remote-signer connection (sign-out, or switching accounts).
  Future<void> disconnectRemoteSigner() => _replaceRemoteSigner(null);

  Future<void> _replaceRemoteSigner(Nip46Client? client) async {
    final previous = _remoteSigner;
    _remoteSigner = client;
    await previous?.close();
  }

  /// The active connection, or a clear error. Reaching this with no client is
  /// a programming error (a [LoginMethod.remoteSigner] user was built without
  /// restoring its session), not something a user can trigger.
  Nip46Client _requireRemoteSigner() {
    final client = _remoteSigner;
    if (client == null) {
      throw const Nip46Exception(
        'The remote signer is not connected. Sign in again.',
      );
    }
    return client;
  }

  User _userFromPrivateKey(String privateKeyHex, LoginMethod method) {
    final keyPair = _nostr.services.keys.generateKeyPairFromExistingPrivateKey(
      privateKeyHex,
    );
    return User(
      publicKeyHex: keyPair.public,
      npub: publicKeyToNpub(keyPair.public),
      loginMethod: method,
      privateKeyHex: privateKeyHex,
    );
  }

  /// true if the Amber app (NIP-55 signer) is installed. Android only: other
  /// platforms don't implement the plugin method, so treat that as "not
  /// available" rather than crashing.
  Future<bool> isAmberInstalled() async {
    developer.log('NostrService.isAmberInstalled called', name: 'NostrService');
    try {
      return await _amber.isAppInstalled();
    } on MissingPluginException {
      return false;
    }
  }

  /// Opens a [LoginMethod.amber] session by asking Amber for the active
  /// account's public key (NIP-55 intent). Requests every permission Astraea
  /// will need up front — `sign_event` plus `nip44_encrypt`/`nip44_decrypt`
  /// (the self-encryption used for every event, when publishing and when
  /// fetching) — so Amber grants them once instead of prompting on every
  /// publish/fetch. Handles a hex or already-bech32 npub reply.
  Future<User> loginWithAmber() async {
    developer.log('NostrService.loginWithAmber called', name: 'NostrService');
    if (!await isAmberInstalled()) {
      throw StateError(
        'Amber does not appear to be installed on this device. '
        'Install Amber (NIP-55 signer) and try again.',
      );
    }

    final result = await _awaitAmber(
      _amber.getPublicKey(
        permissions: const [
          Permission(type: 'sign_event'),
          Permission(type: 'nip44_encrypt'),
          Permission(type: 'nip44_decrypt'),
        ],
      ),
    );
    final raw = (result['signature'] as String?)?.trim() ?? '';
    if (raw.isEmpty) {
      throw StateError('Amber did not return a public key.');
    }

    final String publicKeyHex;
    final String npub;
    if (raw.startsWith('npub1')) {
      npub = raw;
      publicKeyHex = _nostr.services.bech32.decodeNpubKeyToPublicKey(raw);
    } else {
      publicKeyHex = raw.toLowerCase();
      npub = publicKeyToNpub(publicKeyHex);
    }
    return User(
      publicKeyHex: publicKeyHex,
      npub: npub,
      loginMethod: LoginMethod.amber,
    );
  }

  // -------------------------------------------------------------------
  // Relay transport + events
  // -------------------------------------------------------------------

  /// Opens (and keeps) websocket connections to [relayUrls]. Safe to call
  /// repeatedly. `lazyListeningToRelays: false` (the default) is required, or
  /// OK/EVENT frames are never dispatched (see the same note in Echoes).
  Future<void> connectToRelays(List<String> relayUrls) async {
    developer.log(
      'NostrService.connectToRelays called (${relayUrls.length} relays)',
      name: 'NostrService',
    );
    if (relayUrls.isEmpty) return;
    _validateRelayUrls(relayUrls);
    await _nostr.services.relays.init(
      relaysUrl: relayUrls,
      retryOnError: true,
      retryOnClose: true,
    );
  }

  /// Fetches [publicKeyHex]'s public profile card (kind 0), if any relay has
  /// one. Unlike calendar events this is plain public data by design — no
  /// NIP-44 involved — so a missing or malformed profile is not an error, just
  /// `null` / best-effort field parsing.
  ///
  /// Always queries a few well-known metadata relays alongside the user's own
  /// (see [AppConstants.profileMetadataFallbackRelayUrls]): the configured
  /// relays are for event storage and often don't carry the profile.
  Future<NostrProfile?> fetchProfileMetadata({
    required String publicKeyHex,
    required List<String> relayUrls,
  }) async {
    // The pubkey is the account's Nostr identity: logging it would tie every
    // device log (and every bug report built from one) to that identity.
    developer.log(
      'NostrService.fetchProfileMetadata called',
      name: 'NostrService',
    );
    final urls = {
      ...relayUrls,
      ...AppConstants.profileMetadataFallbackRelayUrls,
    }.toList();
    await connectToRelays(urls);

    final events = await _fetchFromRelays(
      request: NostrRequest(
        filters: [
          NostrFilter(authors: [publicKeyHex], kinds: const [0], limit: 1),
        ],
      ),
      relayUrls: urls,
    );
    final authentic = events
        .where(
          (event) => isAuthenticNostrEvent(
            event,
            expectedAuthor: publicKeyHex,
            expectedKind: 0,
          ),
        )
        .toList();
    if (authentic.isEmpty) return null;

    // Relays don't have to enforce "one kind-0 per author" or return results
    // in order — pick the most recent event actually received. `createdAt` is
    // nullable; treat a missing timestamp as oldest rather than crashing.
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    final latest = authentic.reduce(
      (a, b) => (a.createdAt ?? epoch).isAfter(b.createdAt ?? epoch) ? a : b,
    );
    final content = latest.content;
    if (content == null || content.isEmpty || content.length > 65536) {
      return null;
    }

    try {
      final json = jsonDecode(content) as Map<String, dynamic>;
      return NostrProfile.fromMetadataJson(publicKeyHex, json);
    } catch (e) {
      developer.log(
        'Could not parse profile metadata: $e',
        name: 'NostrService',
      );
      return null;
    }
  }

  /// Encrypts [event]'s JSON (NIP-44 self-encryption), signs it as a
  /// kind-30078 event under the `d` tag `epochs:<id>` (parameterized
  /// replaceable), publishes it to [relayUrls], and returns the
  /// relay-confirmed event id. Encryption + signing branch on
  /// [author.loginMethod] (local key vs Amber).
  Future<String> publishEvent({
    required User author,
    required Event event,
    required List<String> relayUrls,
  }) async {
    developer.log(
      'NostrService.publishEvent called: d=${event.dTag}',
      name: 'NostrService',
    );
    if (relayUrls.isEmpty) throw StateError('No relay configured.');
    await connectToRelays(relayUrls);

    final content = await _encrypt(author, jsonEncode(event.toJson()));
    final signed = await _signEvent(
      author: author,
      kind: AppConstants.calendarEventKind,
      tags: [
        ['d', event.dTag],
      ],
      content: content,
      createdAt: event.updatedAt,
    );

    // `relays:` is always passed explicitly: dart_nostr's registry keeps every
    // socket ever opened this session (including the metadata-only relays the
    // profile fetch touches), and a null `relays` broadcasts to ALL of them —
    // which would hand the user's encrypted events to relays they never chose.
    await _sendToEveryRelay(signed, relayUrls);
    return signed.id!;
  }

  /// Fetches every Astraea calendar event (kind 30078, legacy `d` tag prefixed
  /// `epochs:`) authored by [author] from [relayUrls], decrypts each and
  /// returns them as [Event]s (marked synced). Events that fail to decrypt or
  /// parse are skipped rather than failing the whole fetch.
  ///
  /// Relays can only match exact `#d` values, not a prefix, so we request all
  /// of the author's kind-30078 events and filter to `epochs:` client-side.
  Future<List<Event>> fetchEvents({
    required User author,
    required List<String> relayUrls,
    DateTime? since,
  }) async {
    developer.log('NostrService.fetchEvents called', name: 'NostrService');
    if (relayUrls.isEmpty) return const [];
    await connectToRelays(relayUrls);

    final events = await _fetchFromRelays(
      request: NostrRequest(
        filters: [
          NostrFilter(
            authors: [author.publicKeyHex],
            kinds: const [AppConstants.calendarEventKind],
            since: since,
          ),
        ],
      ),
      relayUrls: relayUrls,
    );

    final result = <Event>[];
    for (final raw in events) {
      if (!isAuthenticNostrEvent(
        raw,
        expectedAuthor: author.publicKeyHex,
        expectedKind: AppConstants.calendarEventKind,
      )) {
        continue;
      }
      final content = raw.content;
      final id = raw.id;
      if (content == null || content.isEmpty || id == null) continue;
      final dTag = _dTagOf(raw);
      if (dTag == null || !dTag.startsWith(AppConstants.dTagPrefix)) continue;
      final event = await _decryptEvent(author, content, id);
      if (event != null && event.dTag == dTag) result.add(event);
    }
    return result;
  }

  /// Publishes a NIP-09 deletion request (kind 5) retracting one previous
  /// concrete version. Astraea deliberately does not delete the parameterized-
  /// replaceable coordinate: the newest version is an encrypted tombstone that
  /// must remain fetchable so other devices can learn the deletion.
  Future<void> publishDeletion({
    required User author,
    required String nostrEventId,
    required List<String> relayUrls,
  }) async {
    developer.log(
      'NostrService.publishDeletion called: $nostrEventId',
      name: 'NostrService',
    );
    if (relayUrls.isEmpty) return;
    await connectToRelays(relayUrls);

    final signed = await _signEvent(
      author: author,
      kind: AppConstants.deletionEventKind,
      tags: <List<String>>[
        ['e', nostrEventId],
      ],
      content: '',
      createdAt: DateTime.now(),
    );
    await _sendToEveryRelay(signed, relayUrls);
  }

  // -------------------------------------------------------------------
  // Encryption / signing (local key vs Amber)
  // -------------------------------------------------------------------

  /// NIP-44 self-encryption of [plaintext] for [author], routed to whichever
  /// backend holds the account key. One switch over every login method, so a
  /// future mode cannot be forgotten here: the analyzer flags a non-exhaustive
  /// switch.
  Future<String> _encrypt(User author, String plaintext) {
    switch (author.loginMethod) {
      case LoginMethod.importedKey:
      case LoginMethod.generatedKey:
        return Future.value(
          CryptoUtils.encryptNip44(
            plaintext: plaintext,
            privateKeyHex: _requireLocalKey(author),
            recipientPublicKeyHex: author.publicKeyHex,
          ),
        );
      case LoginMethod.amber:
        return _amberEncrypt(author, plaintext);
      case LoginMethod.remoteSigner:
        return _requireRemoteSigner().nip44Encrypt(
          peerPubkeyHex: author.publicKeyHex,
          plaintext: plaintext,
        );
    }
  }

  Future<String> _amberEncrypt(User author, String plaintext) async {
    final result = await _awaitAmber(
      _amber.nip44Encrypt(
        plaintext: plaintext,
        currentUser: author.npub,
        pubKey: author.publicKeyHex,
      ),
    );
    final encrypted = (result['signature'] as String?) ?? '';
    if (encrypted.isEmpty) {
      throw StateError('Amber returned no encrypted content.');
    }
    return encrypted;
  }

  /// Counterpart of [_encrypt]. Returns the plaintext; the caller decides what
  /// to do with a failure.
  Future<String> _decrypt(User author, String ciphertext) {
    switch (author.loginMethod) {
      case LoginMethod.importedKey:
      case LoginMethod.generatedKey:
        return Future.value(
          CryptoUtils.decryptNip44(
            ciphertext: ciphertext,
            privateKeyHex: _requireLocalKey(author),
            senderPublicKeyHex: author.publicKeyHex,
          ),
        );
      case LoginMethod.amber:
        return _amberDecrypt(author, ciphertext);
      case LoginMethod.remoteSigner:
        return _requireRemoteSigner().nip44Decrypt(
          peerPubkeyHex: author.publicKeyHex,
          ciphertext: ciphertext,
        );
    }
  }

  Future<String> _amberDecrypt(User author, String ciphertext) async {
    final result = await _awaitAmber(
      _amber.nip44Decrypt(
        ciphertext: ciphertext,
        currentUser: author.npub,
        pubKey: author.publicKeyHex,
      ),
    );
    final decrypted = result['signature'] as String?;
    if (decrypted == null) {
      throw StateError('Amber returned no decrypted content.');
    }
    return decrypted;
  }

  Future<Event?> _decryptEvent(
    User author,
    String ciphertext,
    String eventId,
  ) async {
    try {
      final plaintext = await _decrypt(author, ciphertext);
      final json = jsonDecode(plaintext) as Map<String, dynamic>;
      return Event.fromJson(json).copyWith(
        synced: true,
        nostrEventId: eventId,
        syncOwnerPubkey: author.publicKeyHex,
      );
    } catch (_) {
      // Parsing failures can embed plaintext snippets in FormatException.
      // Never copy those into logs: decrypted calendar content is sensitive.
      developer.log(
        'Could not decrypt/parse event $eventId',
        name: 'NostrService',
      );
      return null;
    }
  }

  Future<NostrEvent> _signEvent({
    required User author,
    required int kind,
    required List<List<String>> tags,
    required String content,
    required DateTime createdAt,
  }) async {
    if (author.loginMethod.isLocalKey) {
      final keyPair = _nostr.services.keys
          .generateKeyPairFromExistingPrivateKey(_requireLocalKey(author));
      return NostrEvent.fromPartialData(
        kind: kind,
        content: content,
        keyPairs: keyPair,
        tags: tags,
        createdAt: createdAt,
      );
    }

    // External signers get an unsigned NIP-01 event object and hand back a
    // signed one. What comes back is never trusted: [_verifySignedEvent]
    // re-checks that it is exactly the event we asked to have signed.
    final unsigned = <String, dynamic>{
      'pubkey': author.publicKeyHex,
      'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
      'kind': kind,
      'tags': tags,
      'content': content,
    };
    final signed = author.loginMethod == LoginMethod.amber
        ? await _amberSign(author, unsigned)
        : _nostrEventFromMap(await _requireRemoteSigner().signEvent(unsigned));
    return _verifySignedEvent(
      signed,
      author: author,
      kind: kind,
      tags: tags,
      content: content,
      createdAt: createdAt,
    );
  }

  Future<NostrEvent> _amberSign(
    User author,
    Map<String, dynamic> unsigned,
  ) async {
    final result = await _awaitAmber(
      _amber.signEvent(
        currentUser: author.npub,
        eventJson: jsonEncode(unsigned),
      ),
    );
    final signedJson = result['event'] as String?;
    if (signedJson == null) throw StateError('Amber returned no signed event.');
    return _nostrEventFromMap(jsonDecode(signedJson) as Map<String, dynamic>);
  }

  /// An external signer is trusted to hold the key, not to be honest about
  /// what it signed. Verifies that [signed] carries a valid NIP-01 id and
  /// signature for the account, and that every field still matches the request
  /// — otherwise a compromised signer (or a relay in front of one) could
  /// publish arbitrary content under the user's identity.
  NostrEvent _verifySignedEvent(
    NostrEvent signed, {
    required User author,
    required int kind,
    required List<List<String>> tags,
    required String content,
    required DateTime createdAt,
  }) {
    final signedCreatedAt = signed.createdAt;
    final sameCreatedSecond =
        signedCreatedAt != null &&
        signedCreatedAt.millisecondsSinceEpoch ~/ 1000 ==
            createdAt.millisecondsSinceEpoch ~/ 1000;
    final matches =
        isAuthenticNostrEvent(
          signed,
          expectedAuthor: author.publicKeyHex,
          expectedKind: kind,
        ) &&
        signed.content == content &&
        jsonEncode(signed.tags) == jsonEncode(tags) &&
        sameCreatedSecond;
    if (!matches) {
      throw StateError(
        'The signer returned a signed event that does not match the request.',
      );
    }
    return signed;
  }

  // -------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------

  String _requireLocalKey(User author) {
    final privateKeyHex = author.privateKeyHex;
    if (privateKeyHex == null) {
      throw StateError('Missing private key for a local-key session.');
    }
    return privateKeyHex;
  }

  /// Bounds how long we wait for an Amber intent to return (see
  /// [AppConstants.amberInteractionTimeout]).
  Future<T> _awaitAmber<T>(Future<T> future) {
    return future.timeout(
      AppConstants.amberInteractionTimeout,
      onTimeout: () => throw StateError(
        'Amber did not respond in time. If you cancelled the request in Amber, please try again.',
      ),
    );
  }

  /// Collects one REQ only from [relayUrls], waiting until every target sent
  /// EOSE or the bounded timeout elapsed. `dart_nostr`'s async convenience
  /// method currently drops its relay filter when it creates the underlying
  /// subscription and completes on the first EOSE; using the stream API keeps
  /// metadata-only relays out of calendar queries and doesn't miss a slower
  /// relay's stored events.
  Future<List<NostrEvent>> _fetchFromRelays({
    required NostrRequest request,
    required List<String> relayUrls,
  }) async {
    if (relayUrls.isEmpty) return const [];
    _validateRelayUrls(relayUrls);

    final expectedEose = relayUrls.toSet().length;
    final eoseRelays = <String>{};
    final finished = Completer<void>();
    final events = <NostrEvent>[];
    final subscription = _nostr.services.relays.startEventsSubscription(
      request: request,
      relays: relayUrls,
      onEose: (relay, _) {
        eoseRelays.add(relay);
        if (eoseRelays.length >= expectedEose && !finished.isCompleted) {
          finished.complete();
        }
      },
    );
    var totalChars = 0;
    final listener = subscription.stream.listen((event) {
      // Three independent bounds, because a hostile or broken relay controls
      // both how many events it sends and how big each one is:
      //  - a count cap, so a flood of tiny events cannot grow the list;
      //  - a per-event cap, so one oversized event is dropped (not counted
      //    against the budget — it was never kept);
      //  - a *total* budget, which is the one that actually bounds memory.
      //    Without it the first two multiply out to hundreds of megabytes,
      //    and Dart strings are UTF-16, so that is bytes times two. This
      //    mirrors MAX_FETCH_TOTAL_BYTES in the Linux service's transport.
      final length = event.content?.length ?? 0;
      if (events.length >= _maxFetchedEvents ||
          length > _maxEventContentChars) {
        return;
      }
      if (totalChars + length > _maxFetchTotalChars) return;
      totalChars += length;
      events.add(event);
    });

    try {
      await finished.future.timeout(
        AppConstants.syncEoseTimeout,
        onTimeout: () {},
      );
    } finally {
      await listener.cancel();
      subscription.close();
    }
    return events;
  }

  /// Waits for an acceptance from every configured target. The dependency's
  /// multi-relay helper completes after the first OK, which could mark an event
  /// synced even when the personal backup relay rejected or never received it.
  /// One request per relay preserves the meaning of `synced`; partial success
  /// remains safe because Nostr event publication is idempotent and the next
  /// cycle retries the same deterministic event id.
  Future<void> _sendToEveryRelay(
    NostrEvent event,
    List<String> relayUrls,
  ) async {
    final acknowledgements = await Future.wait([
      for (final relayUrl in relayUrls.toSet())
        _nostr.services.relays.sendEventToRelaysAsync(
          event,
          timeout: AppConstants.syncEoseTimeout,
          relays: [relayUrl],
        ),
    ]);
    final rejected = acknowledgements.where((ok) => ok.isEventAccepted != true);
    if (rejected.isNotEmpty) {
      final reason = rejected.first.message ?? 'unknown reason';
      throw StateError('A configured relay rejected the event: $reason');
    }
  }

  /// Delegates to [normalizeRelayUrl] — the same check Settings/onboarding
  /// already use to decide what a user is even allowed to save — instead of
  /// keeping a second, independent copy of "what's a valid relay URL" here.
  /// The two had already drifted once (this used to hard-reject `ws://`,
  /// so a personal/self-hosted relay the user had saved through Settings
  /// would pass validation there and then fail *every* sync/publish here,
  /// unconditionally); a shared source of truth is what actually prevents
  /// that class of bug from coming back.
  void _validateRelayUrls(Iterable<String> relayUrls) {
    for (final raw in relayUrls) {
      if (normalizeRelayUrl(raw) == null || raw.length > 2048) {
        throw ArgumentError.value(raw, 'relayUrls', 'Invalid relay URL.');
      }
    }
  }

  String? _dTagOf(NostrEvent event) {
    final tags = event.tags;
    if (tags == null) return null;
    for (final tag in tags) {
      if (tag.length >= 2 && tag[0] == 'd') return tag[1];
    }
    return null;
  }

  NostrEvent _nostrEventFromMap(Map<String, dynamic> map) {
    return NostrEvent(
      id: map['id'] as String,
      kind: map['kind'] as int,
      content: map['content'] as String? ?? '',
      sig: map['sig'] as String,
      pubkey: map['pubkey'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['created_at'] as int) * 1000,
      ),
      tags: (map['tags'] as List<dynamic>)
          .map(
            (tag) => (tag as List<dynamic>).map((e) => e.toString()).toList(),
          )
          .toList(),
    );
  }
}

/// Thrown by [NostrService.importAccount] when the entered key can't be
/// decoded/validated. Carries no detail — never the key the user typed.
class InvalidPrivateKeyException implements Exception {
  const InvalidPrivateKeyException();

  @override
  String toString() => 'Invalid private key';
}
