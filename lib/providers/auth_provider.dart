import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/nostr_service.dart';
import 'service_providers.dart';

/// Global authentication state: `null` = no Nostr account (offline, local-only
/// use); otherwise the user is signed in with that identity (local key or
/// Amber). First-run routing is intentionally handled by a separate onboarding
/// completion flag.
///
/// `build()` runs at startup and is the "is there already a saved account?"
/// check: it reads the persisted pubkey/login method and rebuilds the
/// session from the stored private key. Unlike Echoes, Astraea supports
/// *creating* a new account ([generateAccount]) in addition to importing an
/// existing key.
class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    developer.log('AuthNotifier.build called', name: 'AuthNotifier');
    final localStorage = ref.read(localStorageServiceProvider);
    final publicKeyHex = await localStorage.loadPublicKey();
    if (publicKeyHex == null) {
      return null; // No account (never signed in, or offline-only).
    }

    final nostrService = ref.read(nostrServiceProvider);
    final method =
        await localStorage.loadLoginMethod() ?? LoginMethod.importedKey;

    if (method == LoginMethod.amber) {
      await localStorage.claimLegacySyncedEvents(publicKeyHex);
      return nostrService.amberSession(publicKeyHex);
    }

    final privateKeyHex = await localStorage.loadPrivateKey();
    if (privateKeyHex == null) {
      return null; // Inconsistent: treat as logged out.
    }
    final user = await nostrService.login(privateKeyHex, method: method);
    if (user.publicKeyHex != publicKeyHex) {
      return null; // Corrupt/inconsistent session metadata: do not claim data.
    }
    await localStorage.claimLegacySyncedEvents(publicKeyHex);
    return user;
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

  /// Clears the local account and returns to "logged out".
  Future<void> logout() async {
    developer.log('AuthNotifier.logout called', name: 'AuthNotifier');
    await ref.read(localStorageServiceProvider).clearSession();
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);
