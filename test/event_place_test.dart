import 'dart:convert';

import 'package:astraea/desktop/service_event_codec.dart';
import 'package:astraea/models/event_model.dart';
import 'package:astraea/models/event_place.dart';
import 'package:astraea/services/place_navigation.dart';
import 'package:astraea/utils/calendar_tags.dart';
import 'package:flutter_test/flutter_test.dart';

Event _event({String? location, EventPlace? place}) {
  final start = DateTime.utc(2026, 7, 15, 13);
  return Event(
    id: 'evt-1',
    title: 'Dentist',
    description: 'Checkup',
    startTimeUtc: start,
    endTimeUtc: start.add(const Duration(hours: 1)),
    timezone: 'Europe/Rome',
    location: location,
    place: place,
    createdAt: DateTime.utc(2026, 7, 1),
    updatedAt: DateTime.utc(2026, 7, 1),
  );
}

EventPlace _bianchini() {
  return EventPlace(
    latitude: 45.0703,
    longitude: 7.6869,
    source: EventPlace.osmSource,
    name: 'Bianchini SRL',
    displayName: 'Bianchini SRL, Via Roma 1, Torino, Italia',
    osmType: 'node',
    osmId: 123456789,
    osmCategory: 'amenity',
    osmSubtype: 'dentist',
  );
}

void main() {
  group('EventPlace', () {
    test('accepts the poles and rejects anything outside them', () {
      expect(coordinatesValid(90, 180), isTrue);
      expect(coordinatesValid(-90, -180), isTrue);
      expect(
        () => EventPlace(latitude: 90, longitude: 180, source: 'edge'),
        returnsNormally,
      );
      expect(coordinatesValid(90.000001, 0), isFalse);
      expect(coordinatesValid(0, 180.0001), isFalse);
      expect(coordinatesValid(double.nan, 0), isFalse);
      expect(coordinatesValid(double.infinity, 0), isFalse);
      expect(
        () => EventPlace(latitude: 90.000001, longitude: 0, source: 'x'),
        throwsArgumentError,
      );
      expect(
        () => EventPlace(latitude: double.nan, longitude: 0, source: 'x'),
        throwsArgumentError,
      );
    });

    test('round-trips a place and omits the key when there is none', () {
      final event = _event(
        location: 'Bianchini SRL, Via Roma 1, Torino',
        place: _bianchini(),
      );
      final restored = Event.fromJson(event.toJson());

      expect(restored.location, event.location);
      expect(restored.place, event.place);
      expect(restored.place!.toJson().containsKey('place_id'), isFalse);

      final bare = _event(location: 'Office').toJson();
      expect(bare.containsKey('place'), isFalse);
      expect(Event.fromJson(bare).place, isNull);
    });

    test('a malformed place does not fail the event', () {
      final stored = _event(location: 'Office').toJson();
      stored['place'] = {
        'schema': 'lwb.place/1',
        'latitude': '45.0',
        'longitude': 7,
        'source': 'osm-nominatim',
      };
      final fromString = Event.fromJson(stored);
      expect(fromString.title, 'Dentist');
      expect(fromString.location, 'Office');
      expect(fromString.place, isNull);

      stored['place'] = {
        'schema': 'lwb.place/1',
        'latitude': 120,
        'longitude': 0,
        'source': 'osm-nominatim',
      };
      expect(Event.fromJson(stored).place, isNull);

      stored['place'] = {
        'schema': 'lwb.place/2',
        'latitude': 45,
        'longitude': 7,
        'source': 'osm-nominatim',
      };
      expect(Event.fromJson(stored).place, isNull);

      stored['place'] = 'not-an-object';
      expect(Event.fromJson(stored).title, 'Dentist');
      expect(Event.fromJson(stored).place, isNull);
    });

    test('editing the location text drops the coordinates', () {
      const address = 'Bianchini SRL, Via Roma 1, Torino';
      final place = _bianchini();
      expect(
        placeForLocation(
          location: '  $address  ',
          resolvedAgainst: address,
          place: place,
        ),
        place,
      );
      expect(
        placeForLocation(
          location: 'Via Roma 2, Torino',
          resolvedAgainst: address,
          place: place,
        ),
        isNull,
      );
      expect(
        placeForLocation(
          location: '   ',
          resolvedAgainst: address,
          place: place,
        ),
        isNull,
      );
    });

    test('copyWith can replace or clear a place', () {
      final event = _event(place: _bianchini());
      expect(event.copyWith(clearPlace: true).place, isNull);
      final other = EventPlace(
        latitude: 1,
        longitude: 2,
        source: EventPlace.icsSource,
      );
      expect(event.copyWith(place: other).place, other);
    });
  });

  group('geo URI', () {
    test('encodes the label and keeps the sign of the coordinates', () {
      final labeled = EventPlace(
        latitude: 45.1,
        longitude: 7.2,
        source: 'resolved',
        name: 'A&B (x)',
      );
      expect(
        buildGeoUri(labeled),
        'geo:0,0?q=45.100000,7.200000(A%26B%20%28x%29)',
      );

      final street = EventPlace(
        latitude: 45.0703,
        longitude: 7.6869,
        source: EventPlace.osmSource,
        name: 'Bianchini SRL, Via Roma 1',
      );
      expect(
        buildGeoUri(street),
        'geo:0,0?q=45.070300,7.686900(Bianchini%20SRL%2C%20Via%20Roma%201)',
      );

      final south = EventPlace(
        latitude: -33.8,
        longitude: 18,
        source: 'resolved',
      );
      expect(buildGeoUri(south), 'geo:0,0?q=-33.800000,18.000000');
    });

    test('caps the pin label at 120 characters', () {
      final place = EventPlace(
        latitude: 1,
        longitude: 2,
        source: 'resolved',
        name: 'A' * 130,
      );
      expect(
        buildGeoUri(place),
        'geo:0,0?q=1.000000,2.000000(${Uri.encodeComponent('A' * 120)})',
      );
    });
  });

  group('public calendar tags', () {
    test('the payload carries the place and the tags do not', () {
      final event = _event(
        location: 'Bianchini SRL, Via Roma 1, Torino',
        place: _bianchini(),
      );
      final payload = jsonEncode(event.toJson());
      final tags = jsonEncode(publicCalendarTags(event));

      expect(payload, contains('latitude'));
      expect(payload, contains('45.0703'));
      expect(tags, '[["d","epochs:evt-1"]]');
      expect(tags, isNot(contains('latitude')));
      expect(tags, isNot(contains('45.0703')));
      expect(tags, isNot(contains('7.6869')));
    });
  });

  group('ServiceEventCodec place', () {
    Map<String, dynamic> envelope({Object? place, bool inMetadata = false}) {
      return {
        'id': 'evt-1',
        'title': 'Dentist',
        'location': 'Bianchini SRL, Via Roma 1, Torino',
        'start': '2026-07-15T13:00:00.000Z',
        'end': '2026-07-15T14:00:00.000Z',
        'createdAt': '2026-07-01T00:00:00.000Z',
        'updatedAt': '2026-07-01T00:00:00.000Z',
        if (place != null && inMetadata) 'metadata': {'place': place},
        if (place != null && !inMetadata) 'place': place,
      };
    }

    test('reads a place from the draft or from service metadata', () {
      final json = _bianchini().toJson();
      expect(
        ServiceEventCodec.fromServiceJson(envelope(place: json)).place,
        _bianchini(),
      );
      expect(
        ServiceEventCodec.fromServiceJson(
          envelope(place: json, inMetadata: true),
        ).place,
        _bianchini(),
      );
      expect(
        ServiceEventCodec.fromServiceJson(
          envelope(place: {'schema': 'nope'}),
        ).place,
        isNull,
      );
    });

    test('a draft omits an empty place and a patch sends null to clear it', () {
      final bare = _event();
      final saved = _event(place: _bianchini());
      expect(ServiceEventCodec.toDraftJson(bare).containsKey('place'), isFalse);
      expect(
        ServiceEventCodec.toDraftJson(saved)['place'],
        _bianchini().toJson(),
      );
      expect(ServiceEventCodec.toPatchJson(bare)['place'], isNull);
      expect(
        ServiceEventCodec.toPatchJson(saved)['place'],
        _bianchini().toJson(),
      );
    });
  });
}
