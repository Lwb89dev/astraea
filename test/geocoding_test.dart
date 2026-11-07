import 'dart:convert';

import 'package:astraea/models/event_place.dart';
import 'package:astraea/services/geocoding_service.dart';
import 'package:astraea/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _query = 'Bianchini SRL, Via Roma 1, Torino';

Map<String, Object?> _nominatimRow() {
  return {
    'place_id': 999,
    'importance': 0.91,
    'lat': '45.0703',
    'lon': '7.6869',
    'display_name': 'Bianchini SRL, Via Roma 1, Torino, Italia',
    'name': 'Bianchini SRL',
    'osm_type': 'node',
    'osm_id': 123456789,
    'category': 'amenity',
    'type': 'dentist',
    'address': {
      'road': 'Via Roma',
      'house_number': '1',
      'city': 'Torino',
      'postcode': '10121',
      'country': 'Italia',
    },
  };
}

Map<String, Object?> _weakerRow() {
  return {
    'lat': '45.46',
    'lon': '9.19',
    'display_name': 'Altro, Via Roma 1, Milano',
    'name': 'Altro',
    'osm_type': 'node',
    'osm_id': 42,
    'address': {'road': 'Via Roma', 'house_number': '1', 'city': 'Milano'},
  };
}

PlaceSearchResult _hit({
  required String display,
  String? name,
  String? road,
  String? houseNumber,
  String? city,
  String? country,
  double latitude = 45,
  double longitude = 7,
}) {
  return PlaceSearchResult(
    place: EventPlace(
      latitude: latitude,
      longitude: longitude,
      source: EventPlace.osmSource,
      name: name,
      displayName: display,
    ),
    road: road,
    houseNumber: houseNumber,
    city: city,
    country: country,
  );
}

NominatimGeocodingService _service(
  Future<http.Response> Function(http.Request request) handler, {
  int maxBytes = 256 * 1024,
}) {
  return NominatimGeocodingService(
    client: MockClient(handler),
    endpoint: Uri.parse('https://geocoder.test/search'),
    minInterval: Duration.zero,
    maxBytes: maxBytes,
  );
}

void main() {
  group('Nominatim parsing', () {
    test('reads jsonv2 and drops place_id', () {
      final parsed = parseNominatimBody(jsonEncode([_nominatimRow()]));
      expect(parsed, isNotNull);
      final hit = parsed!.single;
      expect(hit.place.latitude, closeTo(45.0703, 1e-6));
      expect(hit.place.longitude, closeTo(7.6869, 1e-6));
      expect(hit.place.source, EventPlace.osmSource);
      expect(hit.place.name, 'Bianchini SRL');
      expect(
        hit.place.displayName,
        'Bianchini SRL, Via Roma 1, Torino, Italia',
      );
      expect(hit.place.osmType, 'node');
      expect(hit.place.osmId, 123456789);
      expect(hit.place.osmCategory, 'amenity');
      expect(hit.place.osmSubtype, 'dentist');
      expect(hit.road, 'Via Roma');
      expect(hit.houseNumber, '1');
      expect(hit.city, 'Torino');
      expect(hit.postcode, '10121');
      expect(hit.country, 'Italia');
      expect(hit.place.toJson().containsKey('place_id'), isFalse);
      expect(hit.place.toJson().containsKey('importance'), isFalse);
    });

    test('skips a bad row, caps the list, and refuses a non-array', () {
      final rows = [
        for (var i = 0; i < 9; i++) {'lat': '10', 'lon': '$i', 'name': 'P$i'},
      ];
      final parsed = parseNominatimBody(jsonEncode(rows));
      expect(parsed, hasLength(8));
      expect(parsed!.last.place.longitude, closeTo(7, 1e-9));

      final mixed = parseNominatimBody(
        jsonEncode([
          {'lat': '10', 'lon': '1', 'name': 'ok'},
          {'lat': 'nope', 'lon': '1'},
          {'lat': '10', 'lon': '2', 'name': 'also'},
        ]),
      );
      expect(mixed, hasLength(2));
      expect(parseNominatimBody('{"lat":"1"}'), isNull);
      expect(parseNominatimBody('not json'), isNull);
    });
  });

  group('ranking', () {
    test('attaches a clear street match and skips an unrelated hit', () {
      final parsed = parseNominatimBody(
        jsonEncode([_nominatimRow(), _weakerRow()]),
      );
      final decision = decidePlaceMatch(_query, parsed!);
      expect(decision.kind, PlaceDecisionKind.attach);
      expect(decision.place!.name, 'Bianchini SRL');

      final pizza = decidePlaceMatch(_query, [
        _hit(
          display: 'Pizza place, Berlin',
          name: 'Pizza place',
          city: 'Berlin',
          country: 'Germany',
        ),
      ]);
      expect(pizza.kind, PlaceDecisionKind.skip);
      expect(decidePlaceMatch(_query, const []), const PlaceDecision.skip());
    });

    test('asks when two hits share the top score', () {
      final twins = parseNominatimBody(
        jsonEncode([_nominatimRow(), _nominatimRow()]),
      );
      final decision = decidePlaceMatch(_query, twins!);
      expect(decision.kind, PlaceDecisionKind.choose);
      expect(decision.candidates, hasLength(2));
    });

    test('keeps at most five plausible hits', () {
      final many = List.generate(
        6,
        (i) => _hit(
          display: 'alpha beta other $i',
          city: 'gamma',
          longitude: i.toDouble(),
        ),
      );
      final decision = decidePlaceMatch('alpha beta gamma', many);
      expect(decision.kind, PlaceDecisionKind.choose);
      expect(decision.candidates, hasLength(5));
    });

    test('folds a small set of Latin accents before comparing', () {
      final decision = decidePlaceMatch('Città di Torino', [
        _hit(display: 'Citta di Torino', city: 'Torino'),
      ]);
      expect(decision.kind, PlaceDecisionKind.attach);
    });
  });

  group('NominatimGeocodingService', () {
    test('rejects a non-HTTPS endpoint', () {
      expect(
        () => NominatimGeocodingService(
          client: MockClient((_) async => http.Response('[]', 200)),
          endpoint: Uri.parse('http://geocoder.test/search'),
          minInterval: Duration.zero,
        ),
        throwsArgumentError,
      );
      expect(
        geocoderEndpointAllowed(
          Uri.parse('https://user:pass@geocoder.test/search'),
        ),
        isFalse,
      );
    });

    test('sends only the location text, with the identifying agent', () async {
      http.Request? seen;
      final service = _service((request) async {
        seen = request;
        return http.Response(jsonEncode([_nominatimRow()]), 200);
      });

      final status = await service.search(_query);
      expect(status, isA<GeocodeResults>());
      expect(seen!.url.queryParameters['q'], _query);
      expect(seen!.url.queryParameters['q'], isNot(contains('Dentist')));
      expect(seen!.url.queryParameters['format'], 'jsonv2');
      expect(seen!.url.queryParameters['addressdetails'], '1');
      expect(seen!.url.queryParameters['limit'], '5');
      expect(seen!.headers['User-Agent'], AppConstants.geocoderUserAgent);
      expect(seen!.headers['Accept'], 'application/json');
      expect(seen!.url.scheme, 'https');
    });

    test(
      'caches an identical normalized query, including an empty result',
      () async {
        var calls = 0;
        final service = _service((request) async {
          calls++;
          return http.Response('[]', 200);
        });
        await service.search('Via  Roma');
        final again = await service.search('via roma');
        expect(calls, 1);
        expect(again, isA<GeocodeResults>());
        expect((again as GeocodeResults).results, isEmpty);
      },
    );

    test(
      'does not cache a transport failure, and does not search a long query',
      () async {
        var calls = 0;
        final service = _service((request) async {
          calls++;
          if (calls == 1) throw Exception('offline');
          return http.Response(jsonEncode([_nominatimRow()]), 200);
        });

        expect(await service.search('Via Roma'), isA<GeocodeUnavailable>());
        expect(await service.search('Via Roma'), isA<GeocodeResults>());
        expect(calls, 2);

        expect(await service.search('   '), isA<GeocodeResults>());
        expect(await service.search('x' * 301), isA<GeocodeResults>());
        expect(calls, 2);
      },
    );

    test(
      'treats a non-JSON body, an error status, and an oversized body as unavailable',
      () async {
        final junk = _service((_) async => http.Response('nope', 200));
        expect(await junk.search('Via Roma'), isA<GeocodeUnavailable>());

        final missing = _service((_) async => http.Response('[]', 404));
        expect(await missing.search('Via Roma'), isA<GeocodeUnavailable>());

        final huge = _service(
          (_) async => http.Response(jsonEncode([_nominatimRow()]), 200),
          maxBytes: 32,
        );
        expect(await huge.search('Via Roma'), isA<GeocodeUnavailable>());

        final redirected = _service((request) async {
          return http.Response(
            '[]',
            200,
            request: http.Request(
              'GET',
              Uri.parse('http://geocoder.test/search'),
            ),
          );
        });
        expect(await redirected.search('Via Roma'), isA<GeocodeUnavailable>());
      },
    );
  });
}
