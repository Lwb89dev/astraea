import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/event_place.dart';
import '../utils/constants.dart';

/// One geocoder hit. Address parts exist for ranking and are not all stored
/// on [EventPlace].
class PlaceSearchResult {
  const PlaceSearchResult({
    required this.place,
    this.road,
    this.houseNumber,
    this.city,
    this.postcode,
    this.country,
  });

  final EventPlace place;
  final String? road;
  final String? houseNumber;
  final String? city;
  final String? postcode;
  final String? country;
}

sealed class GeocodeStatus {
  const GeocodeStatus();
}

final class GeocodeResults extends GeocodeStatus {
  const GeocodeResults(this.results);

  final List<PlaceSearchResult> results;
}

/// Network, timeout, non-HTTPS endpoint, or a response we refuse to trust.
final class GeocodeUnavailable extends GeocodeStatus {
  const GeocodeUnavailable();
}

/// Looks up a single location string. Implementations must not receive the
/// event title, description, or any other calendar field.
abstract class GeocodingService {
  Future<GeocodeStatus> search(String query);
}

enum PlaceDecisionKind { attach, choose, skip }

class PlaceDecision {
  const PlaceDecision.attach(this.place)
    : kind = PlaceDecisionKind.attach,
      candidates = const [];

  const PlaceDecision.choose(this.candidates)
    : kind = PlaceDecisionKind.choose,
      place = null;

  const PlaceDecision.skip()
    : kind = PlaceDecisionKind.skip,
      place = null,
      candidates = const [];

  final PlaceDecisionKind kind;
  final EventPlace? place;
  final List<PlaceSearchResult> candidates;
}

/// The only string a geocoder may see. Empty and over-long text is not sent.
/// The event title is intentionally not an argument.
String? geocodingQuery(String? location) {
  final text = location?.trim();
  if (text == null || text.isEmpty) return null;
  if (text.length > 300) return null;
  return text;
}

bool geocoderEndpointAllowed(Uri uri) {
  if (uri.scheme != 'https') return false;
  if (uri.host.isEmpty || uri.userInfo.isNotEmpty) return false;
  return true;
}

String normalizePlaceQuery(String query) {
  return _fold(query).trim().replaceAll(RegExp(r'\s+'), ' ');
}

/// Ranks [candidates] without treating Nominatim `importance` as confidence.
///
/// A clear lead attaches the winner. Several plausible hits ask the user.
/// A weak or empty list leaves the location as text.
PlaceDecision decidePlaceMatch(
  String query,
  List<PlaceSearchResult> candidates,
) {
  if (candidates.isEmpty) return const PlaceDecision.skip();
  final scored = [
    for (final candidate in candidates)
      (candidate, placeMatchScore(query, candidate)),
  ]..sort(_byScoreThenName);
  final best = scored.first;
  if (best.$2 < 20) return const PlaceDecision.skip();
  final second = scored.length > 1 ? scored[1].$2 : null;
  final clearLead = second == null || best.$2 - second >= 15;
  if (best.$2 >= 45 && clearLead) {
    return PlaceDecision.attach(best.$1.place);
  }
  final plausible = [
    for (final row in scored)
      if (row.$2 >= 20) row.$1,
  ];
  if (plausible.isEmpty) return const PlaceDecision.skip();
  return PlaceDecision.choose(plausible.take(5).toList());
}

int placeMatchScore(String query, PlaceSearchResult candidate) {
  final folded = normalizePlaceQuery(query);
  if (folded.isEmpty) return 0;
  final queryTokens = _tokens(folded);
  final display = normalizePlaceQuery(candidate.place.displayName ?? '');
  final name = normalizePlaceQuery(candidate.place.name ?? '');
  var score = _textScore(folded, display, name);
  score += queryTokens.intersection(_tokens(display)).length * 4;
  score += _houseScore(folded, candidate.houseNumber);
  score += _fieldScore(candidate.road, queryTokens, hit: 20, miss: 0);
  score += _fieldScore(candidate.city, queryTokens, hit: 15, miss: -10);
  score += _fieldScore(candidate.postcode, queryTokens, hit: 15, miss: 0);
  score += _fieldScore(candidate.country, queryTokens, hit: 5, miss: -10);
  score += _nameScore(name, queryTokens);
  return score;
}

/// Nominatim search. The endpoint is constructor-injected so a self-hosted
/// HTTPS instance can replace the public one without a new call site.
class NominatimGeocodingService implements GeocodingService {
  NominatimGeocodingService({
    http.Client? client,
    Uri? endpoint,
    Duration minInterval = const Duration(seconds: 1),
    PlaceQueryCache? cache,
    this.timeout = const Duration(seconds: 10),
    this.maxBytes = 256 * 1024,
    String? userAgent,
  }) : _client = client ?? http.Client(),
       _endpoint = endpoint ?? Uri.parse(AppConstants.nominatimSearchUrl),
       _cache = cache ?? PlaceQueryCache(),
       _userAgent = userAgent ?? AppConstants.geocoderUserAgent,
       _pacer = _pacerFor(endpoint, minInterval) {
    if (!geocoderEndpointAllowed(_endpoint)) {
      throw ArgumentError.value(
        _endpoint,
        'endpoint',
        'geocoder endpoint must be HTTPS',
      );
    }
  }

  final http.Client _client;
  final Uri _endpoint;
  final PlaceQueryCache _cache;
  final String _userAgent;
  final RequestPacer _pacer;
  final Duration timeout;
  final int maxBytes;

  static final RequestPacer publicNominatimPacer = RequestPacer(
    minInterval: const Duration(seconds: 1),
  );

  static RequestPacer _pacerFor(Uri? endpoint, Duration minInterval) {
    final host = (endpoint ?? Uri.parse(AppConstants.nominatimSearchUrl)).host;
    if (host == 'nominatim.openstreetmap.org') return publicNominatimPacer;
    return RequestPacer(minInterval: minInterval);
  }

  @override
  Future<GeocodeStatus> search(String query) async {
    final text = geocodingQuery(query);
    if (text == null) return const GeocodeResults([]);
    final key = normalizePlaceQuery(text);
    final cached = _cache.lookup(key);
    if (cached != null) return GeocodeResults(cached);
    try {
      await _pacer.pace();
      final uri = _searchUri(text);
      if (!geocoderEndpointAllowed(uri)) return const GeocodeUnavailable();
      final response = await _client
          .get(
            uri,
            headers: {'User-Agent': _userAgent, 'Accept': 'application/json'},
          )
          .timeout(timeout);
      final parsed = _accept(response);
      if (parsed == null) return const GeocodeUnavailable();
      _cache.store(key, parsed);
      return GeocodeResults(parsed);
    } catch (_) {
      // The exception often embeds the request URL. It is not logged.
      return const GeocodeUnavailable();
    }
  }

  Uri _searchUri(String text) {
    return _endpoint.replace(
      queryParameters: {
        'format': 'jsonv2',
        'addressdetails': '1',
        'limit': '5',
        'q': text,
      },
    );
  }

  List<PlaceSearchResult>? _accept(http.Response response) {
    if (response.statusCode != 200) return null;
    final finalUri = response.request?.url;
    if (finalUri != null && !geocoderEndpointAllowed(finalUri)) return null;
    if (response.body.length > maxBytes) return null;
    return parseNominatimBody(response.body);
  }
}

class PlaceQueryCache {
  PlaceQueryCache({this.capacity = 32});

  final int capacity;
  final _keys = <String>[];
  final _values = <String, List<PlaceSearchResult>>{};

  List<PlaceSearchResult>? lookup(String normalized) => _values[normalized];

  void store(String normalized, List<PlaceSearchResult> results) {
    _keys.remove(normalized);
    _keys.add(normalized);
    _values[normalized] = results;
    while (_keys.length > capacity) {
      _values.remove(_keys.removeAt(0));
    }
  }
}

class RequestPacer {
  RequestPacer({
    required this.minInterval,
    Future<void> Function(Duration duration)? delay,
  }) : _delay = delay ?? Future<void>.delayed;

  final Duration minInterval;
  final Future<void> Function(Duration duration) _delay;
  Future<void> _tail = Future<void>.value();
  DateTime _earliest = DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> pace() {
    if (minInterval <= Duration.zero) return Future<void>.value();
    final gate = _tail.then((_) async {
      final wait = _earliest.difference(DateTime.now());
      if (wait > Duration.zero) await _delay(wait);
      _earliest = DateTime.now().add(minInterval);
    });
    _tail = gate;
    return gate;
  }
}

/// Null when [body] is not a JSON array. Individual bad rows are skipped.
List<PlaceSearchResult>? parseNominatimBody(String body) {
  final Object? decoded;
  try {
    decoded = jsonDecode(body);
  } on FormatException {
    return null;
  }
  if (decoded is! List) return null;
  final results = <PlaceSearchResult>[];
  for (final row in decoded.take(8)) {
    final parsed = _parseNominatimRow(row);
    if (parsed != null) results.add(parsed);
  }
  return results;
}

PlaceSearchResult? _parseNominatimRow(Object? row) {
  if (row is! Map) return null;
  final json = Map<Object?, Object?>.from(row);
  final lat = double.tryParse('${json['lat']}');
  final lon = double.tryParse('${json['lon']}');
  if (lat == null || lon == null || !coordinatesValid(lat, lon)) return null;
  final identity = _nominatimOsm(json['osm_type'], json['osm_id']);
  final address = json['address'];
  EventPlace place;
  try {
    place = EventPlace(
      latitude: lat,
      longitude: lon,
      source: EventPlace.osmSource,
      name: _stringOrNull(json['name']),
      displayName: _stringOrNull(json['display_name']),
      osmType: identity.$1,
      osmId: identity.$2,
      osmCategory:
          _stringOrNull(json['category']) ?? _stringOrNull(json['class']),
      osmSubtype: _stringOrNull(json['type']),
    );
  } on ArgumentError {
    return null;
  }
  return PlaceSearchResult(
    place: place,
    road: _address(address, 'road'),
    houseNumber: _address(address, 'house_number'),
    city: _city(address),
    postcode: _address(address, 'postcode'),
    country: _address(address, 'country'),
  );
}

(String?, int?) _nominatimOsm(Object? type, Object? id) {
  if (type is! String) return (null, null);
  final parsed = id is int
      ? id
      : (id is num && id == id.roundToDouble() ? id.toInt() : null);
  if (parsed == null || parsed <= 0) return (null, null);
  if (type != 'node' && type != 'way' && type != 'relation') {
    return (null, null);
  }
  return (type, parsed);
}

String? _city(Object? address) {
  return _address(address, 'city') ??
      _address(address, 'town') ??
      _address(address, 'village') ??
      _address(address, 'municipality');
}

String? _address(Object? address, String key) {
  if (address is! Map) return null;
  return _stringOrNull(address[key]);
}

String? _stringOrNull(Object? value) {
  if (value is! String) return null;
  final text = value.trim();
  return text.isEmpty ? null : text;
}

int _textScore(String query, String display, String name) {
  if (display == query || name == query) return 50;
  if (display.contains(query)) return 40;
  return 0;
}

int _houseScore(String query, String? houseNumber) {
  final house = houseNumber?.trim();
  final queryNumbers = RegExp(r'\d+').allMatches(query).map((m) => m.group(0));
  if (house == null || house.isEmpty) return 0;
  if (queryNumbers.contains(house)) return 25;
  if (queryNumbers.isEmpty) return 0;
  return -25;
}

int _fieldScore(
  String? field,
  Set<String> queryTokens, {
  required int hit,
  required int miss,
}) {
  final parts = _tokens(normalizePlaceQuery(field ?? ''));
  if (parts.isEmpty) return 0;
  if (parts.every(queryTokens.contains)) return hit;
  return miss;
}

int _nameScore(String name, Set<String> queryTokens) {
  final parts = _tokens(name).where((token) => token.length > 2).toSet();
  if (parts.isEmpty) return 0;
  if (parts.every(queryTokens.contains)) return 20;
  return 0;
}

int _byScoreThenName((PlaceSearchResult, int) a, (PlaceSearchResult, int) b) {
  final byScore = b.$2.compareTo(a.$2);
  if (byScore != 0) return byScore;
  final left = a.$1.place.displayName ?? a.$1.place.name ?? '';
  final right = b.$1.place.displayName ?? b.$1.place.name ?? '';
  return left.compareTo(right);
}

Set<String> _tokens(String text) {
  return text
      .split(RegExp(r'[^a-z0-9]+'))
      .where((token) => token.isNotEmpty)
      .toSet();
}

String _fold(String input) {
  const from = 'àáâäãåèéêëìíîïòóôöõùúûüñç';
  const to = 'aaaaaaeeeeiiiiooooouuuunc';
  final buffer = StringBuffer();
  for (final rune in input.toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    final index = from.indexOf(char);
    buffer.write(index < 0 ? char : to[index]);
  }
  return buffer.toString();
}
