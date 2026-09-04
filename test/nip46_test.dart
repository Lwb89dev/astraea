// Covers the parts of `lib/services/nip46_client.dart` that decide whether
// attacker-influenced input is accepted: the `bunker://` connection string
// parser and the stored-session validator.
//
// Both are boundaries. The connection string is pasted by the user from
// somewhere else entirely, and the stored session is read back from device
// storage that a backup/restore tool (or a rooted attacker) may have edited.
// Everything past those two gates assumes a well-formed signer target, so
// these are the checks that keep that assumption true.
import 'package:astraea/services/nip46_client.dart';
import 'package:flutter_test/flutter_test.dart';

const _signer =
    '3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d';
const _user =
    'e88a691e98d9987c964521dff60025f60700378a4879180dcbbb4a5027850411';
const _clientKey =
    '5c0c523f52a5b6fad39ed2403092df8cebc36318b39383bca6c00808626fab3a';

void main() {
  group('Nip46Target.parseBunkerUri', () {
    test('accepts a well-formed connection string', () {
      final target = Nip46Target.parseBunkerUri(
        'bunker://$_signer?relay=wss://relay.example.com&secret=abc123',
      );
      expect(target, isNotNull);
      expect(target!.remoteSignerPubkeyHex, _signer);
      expect(target.relays, ['wss://relay.example.com']);
      expect(target.secret, 'abc123');
    });

    test('accepts the scheme-only form some signers emit', () {
      final target = Nip46Target.parseBunkerUri(
        'bunker:$_signer?relay=wss://relay.example.com',
      );
      expect(target?.remoteSignerPubkeyHex, _signer);
      expect(target?.secret, isNull);
    });

    test('rejects anything that is not a usable signer target', () {
      // Wrong scheme; no relay to reach the signer on; a pubkey that is not a
      // pubkey. Each must fail closed rather than half-configure a connection.
      expect(
        Nip46Target.parseBunkerUri('https://$_signer?relay=wss://r.example'),
        isNull,
      );
      expect(Nip46Target.parseBunkerUri('bunker://$_signer'), isNull);
      expect(
        Nip46Target.parseBunkerUri('bunker://nope?relay=wss://r.example'),
        isNull,
      );
      expect(Nip46Target.parseBunkerUri(''), isNull);
    });

    test('drops relay URLs that are not relay URLs', () {
      // `https://` is not a relay, and embedded credentials are rejected by
      // the shared relay rules. Dropping every candidate leaves no way to
      // reach the signer, so the whole string is refused.
      expect(
        Nip46Target.parseBunkerUri('bunker://$_signer?relay=https://r.example'),
        isNull,
      );
      expect(
        Nip46Target.parseBunkerUri(
          'bunker://$_signer?relay=wss://user:pw@r.example',
        ),
        isNull,
      );
    });

    test('caps how many relays a pasted string can open', () {
      final relays = List.generate(
        12,
        (i) => 'relay=wss://relay$i.example.com',
      ).join('&');
      final target = Nip46Target.parseBunkerUri('bunker://$_signer?$relays');
      expect(target!.relays, hasLength(Nip46Target.maxRelays));
    });
  });

  group('Nip46Session', () {
    Nip46Session session() => const Nip46Session(
      target: Nip46Target(
        remoteSignerPubkeyHex: _signer,
        relays: ['wss://relay.example.com'],
        secret: 'abc123',
      ),
      clientPrivateKeyHex: _clientKey,
      userPubkeyHex: _user,
    );

    test('round-trips through its stored JSON form', () {
      final restored = Nip46Session.fromJson(session().toJson());
      expect(restored, isNotNull);
      expect(restored!.userPubkeyHex, _user);
      expect(restored.clientPrivateKeyHex, _clientKey);
      expect(restored.target.remoteSignerPubkeyHex, _signer);
      expect(restored.target.secret, 'abc123');
    });

    test('rejects a stored blob from an unknown version', () {
      final json = session().toJson()..['version'] = 99;
      expect(Nip46Session.fromJson(json), isNull);
    });

    test('rejects tampered or truncated fields instead of half-trusting', () {
      for (final mutate in <void Function(Map<String, dynamic>)>[
        (json) => json['signer'] = 'not-a-key',
        (json) => json['user'] = '',
        (json) => json['clientKey'] = 'deadbeef',
        (json) => json['relays'] = <String>[],
        (json) => json['relays'] = ['ftp://relay.example.com'],
        (json) => json.remove('user'),
      ]) {
        final json = session().toJson();
        mutate(json);
        expect(Nip46Session.fromJson(json), isNull);
      }
    });

    test(
      'stores the ephemeral client key and the account *public* key only',
      () {
        // The whole point of NIP-46 is that the account private key never
        // reaches this device, so the stored session must consist of exactly:
        // the throwaway client key, public identifiers, and the bunker secret.
        // Any additional key-shaped field would be a regression worth catching.
        final json = session().toJson();
        expect(json['clientKey'], _clientKey);
        expect(json['user'], _user, reason: 'the account *public* key');
        expect(json['signer'], _signer, reason: "the signer's public key");
        expect(json.keys.toSet(), {
          'version',
          'signer',
          'relays',
          'secret',
          'clientKey',
          'user',
        });
      },
    );
  });
}
