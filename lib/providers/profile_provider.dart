import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile.dart';
import '../utils/constants.dart';
import 'auth_provider.dart';
import 'service_providers.dart';
import 'settings_provider.dart';

/// The signed-in account's public Nostr profile (display name + avatar),
/// re-fetched whenever [authProvider] resolves to a (possibly new) user.
///
/// Emits the last-cached profile (SharedPreferences) immediately, if any, then
/// replaces it with a freshly-fetched one once the relay round-trip completes,
/// so Settings never shows a blank state on launch. A failed/empty fetch keeps
/// whatever was cached rather than clearing it: a stale name/avatar is better
/// than none for this decorative, non-critical feature.
class ProfileNotifier extends AsyncNotifier<NostrProfile?> {
  @override
  Future<NostrProfile?> build() async {
    developer.log('ProfileNotifier.build called', name: 'ProfileNotifier');
    final author = ref.watch(authProvider).value;
    if (author == null) return null; // Offline/local-only: no profile to show.

    final cached = await _loadCached(author.publicKeyHex);
    if (cached != null) state = AsyncData(cached);

    NostrProfile? fetched;
    try {
      final relays = ref.read(settingsProvider).value?.relays ?? const [];
      fetched = await ref
          .read(nostrServiceProvider)
          .fetchProfileMetadata(
            publicKeyHex: author.publicKeyHex,
            relayUrls: relays,
          );
    } catch (e) {
      developer.log(
        'Could not refresh profile metadata: $e',
        name: 'ProfileNotifier',
      );
    }
    if (fetched == null) return cached;

    await _saveCached(fetched);
    return fetched;
  }

  Future<NostrProfile?> _loadCached(String publicKeyHex) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.prefsProfileCacheKey);
    if (raw == null) return null;
    try {
      final profile = NostrProfile.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      // Guards against showing a previous account's cached name/avatar right
      // after switching accounts.
      return profile.publicKeyHex == publicKeyHex ? profile : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveCached(NostrProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.prefsProfileCacheKey,
      jsonEncode(profile.toJson()),
    );
  }
}

final profileProvider = AsyncNotifierProvider<ProfileNotifier, NostrProfile?>(
  ProfileNotifier.new,
);

/// Downloads and disk-caches the avatar at [url] (a profile's public `picture`
/// field — not encrypted, the same image any other Nostr client shows), keyed
/// by the URL's sha256 so re-fetching the same profile never re-downloads it.
/// Returns null on any failure (missing image, network error, non-200): the
/// account row falls back to a plain icon, same as "no avatar set".
final avatarFileProvider = FutureProvider.family<File?, String>((
  ref,
  url,
) async {
  const maxAvatarBytes = 5 * 1024 * 1024;
  final cacheService = ref.watch(fileCacheServiceProvider);
  final key = sha256.convert(utf8.encode(url)).toString();

  final cached = await cacheService.get(key);
  if (cached != null) return cached;

  // The URL comes from a relay-supplied profile event, i.e. it's untrusted
  // input: https only (no cleartext fetch announcing the user's IP to an
  // arbitrary host), and a hard timeout so a slow host can't pin the request.
  final uri = Uri.tryParse(url);
  if (uri == null || uri.scheme != 'https') return null;

  try {
    final client = http.Client();
    try {
      final request = http.Request('GET', uri);
      final response = await client
          .send(request)
          .timeout(const Duration(seconds: 15));
      // Redirects are followed by package:http. Re-check the final target so an
      // HTTPS profile URL cannot silently downgrade to cleartext.
      if (response.statusCode != 200 ||
          response.request?.url.scheme != 'https') {
        return null;
      }
      final contentType = response.headers['content-type']?.toLowerCase() ?? '';
      if (!contentType.startsWith('image/')) return null;
      final declaredLength = response.contentLength;
      if (declaredLength != null && declaredLength > maxAvatarBytes) {
        return null;
      }

      final bytes = <int>[];
      await for (final chunk in response.stream.timeout(
        const Duration(seconds: 15),
      )) {
        if (bytes.length + chunk.length > maxAvatarBytes) return null;
        bytes.addAll(chunk);
      }
      return await cacheService.put(key, Uint8List.fromList(bytes));
    } finally {
      client.close();
    }
  } catch (e) {
    developer.log(
      'Could not download avatar from $url: $e',
      name: 'avatarFileProvider',
    );
    return null;
  }
});
