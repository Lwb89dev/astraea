import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/event_place.dart';

const placeChannelName = 'com.example.astraea/places';

enum PlaceNavOutcome { roadstr, geo, unavailable, failed }

/// `geo:0,0?q=<lat>,<lon>(<encoded label>)`.
///
/// Latitude and longitude are formatted by us. The label is the only
/// user-controlled component and is percent-encoded inside the parentheses.
String? buildGeoUri(EventPlace place) {
  if (!coordinatesValid(place.latitude, place.longitude)) return null;
  final lat = formatCoordinate(place.latitude);
  final lon = formatCoordinate(place.longitude);
  final buffer = StringBuffer('geo:0,0?q=$lat,$lon');
  final label = _pinLabel(place);
  if (label.isNotEmpty) {
    buffer.write('(${_encodePinLabel(label)})');
  }
  return buffer.toString();
}

/// Opens [place] in Roadstr when the Android bridge reports it, otherwise in
/// whatever app handles the same `geo:` URI. Astraea does not depend on Roadstr.
Future<PlaceNavOutcome> openPlace(EventPlace place) async {
  final uri = buildGeoUri(place);
  if (uri == null) return PlaceNavOutcome.failed;
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return _openAndroid(uri);
  }
  return _openExternal(uri);
}

Future<PlaceNavOutcome> _openAndroid(String uri) async {
  try {
    final result = await const MethodChannel(
      placeChannelName,
    ).invokeMethod<String>('open', {'uri': uri});
    return switch (result) {
      'roadstr' => PlaceNavOutcome.roadstr,
      'geo' => PlaceNavOutcome.geo,
      'unavailable' => PlaceNavOutcome.unavailable,
      _ => PlaceNavOutcome.failed,
    };
  } on MissingPluginException {
    return PlaceNavOutcome.unavailable;
  } on PlatformException {
    return PlaceNavOutcome.failed;
  }
}

Future<PlaceNavOutcome> _openExternal(String uri) async {
  try {
    final opened = await launchUrl(
      Uri.parse(uri),
      mode: LaunchMode.externalApplication,
    );
    return opened ? PlaceNavOutcome.geo : PlaceNavOutcome.unavailable;
  } catch (_) {
    return PlaceNavOutcome.failed;
  }
}

String _pinLabel(EventPlace place) {
  final headline = place.headline.trim();
  if (headline.isEmpty) return '';
  if (headline.length <= 120) return headline;
  return headline.substring(0, 120);
}

/// RFC 3986 percent-encoding. [Uri.encodeComponent] leaves `()*!'` raw, and a
/// raw `)` would end the geo label early.
String _encodePinLabel(String label) {
  final buffer = StringBuffer();
  for (final byte in utf8.encode(label)) {
    if (_unreserved(byte)) {
      buffer.writeCharCode(byte);
      continue;
    }
    buffer.write('%${byte.toRadixString(16).padLeft(2, '0').toUpperCase()}');
  }
  return buffer.toString();
}

bool _unreserved(int byte) {
  final letter = byte >= 0x41 && byte <= 0x5A || byte >= 0x61 && byte <= 0x7A;
  final digit = byte >= 0x30 && byte <= 0x39;
  return letter ||
      digit ||
      byte == 0x2D ||
      byte == 0x2E ||
      byte == 0x5F ||
      byte == 0x7E;
}
