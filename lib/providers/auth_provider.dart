import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/local_storage_service.dart';
import '../services/nostr_service.dart';
import 'service_providers.dart';

/// Global authentication state: `null` = no Nostr account (offline, local-only
/// use); otherwise the user is signed in with that identity (local key, Amber
/// or a NIP-46 remote signer). First-run routing is intentionally handled by a
/// separate onboarding completion flag.
///
/// `build()` runs at startup and is the "is there already a saved account?"
/// check: it reads the persisted pubkey/login method and rebuilds the session
/// from whatever that method needs. Unlike Echoes, Astraea supports *creating*
/// a new account ([generateAccount]) in addition to importing an existing key.
class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    developer.log('AuthNotifier.build called', name: 'AuthNotifier');
    final localStorage = ref.read(localStorageServiceProvider);
    final publicKeyHex = await localStorage.loadPublicKey();
    if (publicKeyHex == null) {
      return null; // No account (never signed in, or offline-only).
    }

    final method =
        await localStorage.loadLoginMethod() ?? LoginMethod.importedKey;
    final user = await _restore(method, publicKeyHex, localStorage);
    if (user == null) return null;
    // Only ever claim local data for the account the session metadata agrees
    // on. A mismatch means corrupt or tampered-with metadata, and silently
    // re-owning another account's events would be a data-leak, not a recovery.
    if (user.publicKeyHex != publicKeyHex) return null;
    await localStorage.claimLegacySyncedEvents(publicKeyHex);
    return user;
  }

  /// Rebuilds the session for [method]. Returns `null` for any inconsistent
  /// stored state (missing key, unusable remote-signer session), which the
  /// caller treats as "logged out" rather than as an error the user must
  /// resolve before the calendar opens.
  Future<User?> _restore(
    LoginMethod method,
    String publicKeyHex,
    LocalStorageService localStorage,
  ) async {
    final nostrService = ref.read(nostrServiceProvider);
    switch (method) {
      case LoginMethod.amber:
        return nostrService.amberSession(publicKeyHex);
      case LoginMethod.remoteSigner:
        final session = await localStorage.loadRemoteSignerSession();
        if (session == null) return null;
        return nostrService.restoreRemoteSignerSession(session);
      case LoginMethod.importedKey:
      case LoginMethod.generatedKey:
        final privateKeyHex = await localStorage.loadPrivateKey();
        if (privateKeyHex == null) return null;
        return nostrService.login(privateKeyHex, method: method);
    }
  }

  /// Creates and persists a brand-new keypair (first-time user).
  Future<void> generateAccount() async {
    developer.log('AuthNotifier.generateAccount called', name: 'AuthNotifier');
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final nostrService = ref.read(nostrServiceProvider);
      final user = await nostrService.generateAccount();
      await _persist(user);
      return user;
    });
  }

  /// Signs in via Amber (NIP-55 external signer): the private key never enters
  /// the app. Persists the public key + login method only.
  Future<void> loginWithAmber() async {
    developer.log('AuthNotifier.loginWithAmber called', name: 'AuthNotifier');
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final nostrService = ref.read(nostrServiceProvider);
      final user = await nostrService.loginWithAmber();
      await _persist(user);
      return user;
    });
  }

  /// Signs in against a NIP-46 remote signer from a pasted `bunker://…`
  /// string. The account private key never enters the app: only the ephemeral
  /// client key Astraea generated for this connection is stored, in secure
  /// storage.
  ///
  /// [onAuthUrl] is called when the signer wants the user to approve the
  /// connection in a browser first.
  Future<void> loginWithRemoteSigner(
    String bunkerUri, {
    void Function(String url)? onAuthUrl,
  }) async {
    developer.log(
      'AuthNotifier.loginWithRemoteSigner called',
      name: 'AuthNotifier',
    );
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final nostrService = ref.read(nostrServiceProvider);
      final result = await nostrService.loginWithRemoteSigner(
        bunkerUri,
        onAuthUrl: onAuthUrl,
      );
      await ref
          .read(localStorageServiceProvider)
          .saveRemoteSignerSession(result.session);
      await _persist(result.user);
      return result.user;
    });
  }

  /// Imports an existing account from an nsec (bech32) or hex private key.
  Future<void> importAccount(String privateKey) async {
    developer.log('AuthNotifier.importAccount called', name: 'AuthNotifier');
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final nostrService = ref.read(nostrServiceProvider);
      // Decode inside its own guard so a malformed key can never leak: any
      // decode failure collapses into a fixed, key-free marker exception
      // (the login form shows a generic "invalid key" message for it).
      final User user;
      try {
        user = await nostrService.importAccount(privateKey);
      } catch (_) {
        throw const InvalidPrivateKeyException();
      }
      await _persist(user);
      return user;
    });
  }

  Future<void> _persist(User user) async {
    final localStorage = ref.read(localStorageServiceProvider);
    if (user.privateKeyHex != null) {
      await localStorage.savePrivateKey(user.privateKeyHex!);
    }
    await localStorage.savePublicKey(user.publicKeyHex);
    await localStorage.saveLoginMethod(user.loginMethod);
    // Completing onboarding, rather than merely persisting an account, marks
    // the app as entered. This keeps the relay-selection step visible after a
    // successful first-run login. Settings' linking flow closes itself by
    // listening to [authProvider], so it does not need the entry flag either.
  }

  /// Clears the local account and returns to "logged out". Everything tied to
  /// the identity goes with it: the stored secrets, the live remote-signer
  /// connection, and the on-disk avatar cache.
  Future<void> logout() async {
    developer.log('AuthNotifier.logout called', name: 'AuthNotifier');
    await ref.read(nostrServiceProvider).disconnectRemoteSigner();
    await ref.read(localStorageServiceProvider).clearSession();
    await ref.read(fileCacheServiceProvider).clear();
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);
