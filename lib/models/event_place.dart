/// A resolved place attached to an event.
///
/// `lwb.place/1` is a small interchange record. Another app can read it from
/// the encrypted calendar payload. The event's `location` string stays the
/// text the user wrote; this object is only the geographic metadata.
///
/// Nominatim `place_id` is not stored. It changes between Nominatim instances.
/// OSM type + id is the identity when the provider returned one.
class EventPlace {
  static const schemaId = 'lwb.place/1';
  static const osmSource = 'osm-nominatim';
  static const icsSource = 'icalendar';
  static const maxTextLength = 500;
  static const maxTokenLength = 64;

  final String schema;
  final double latitude;
  final double longitude;
  final String source;
  final String? name;
  final String? displayName;
  final String? osmType;
  final int? osmId;
  final String? osmCategory;
  final String? osmSubtype;

  EventPlace({
    this.schema = schemaId,
    required this.latitude,
    required this.longitude,
    required String source,
    String? name,
    String? displayName,
    String? osmType,
    int? osmId,
    String? osmCategory,
    String? osmSubtype,
  }) : source = source.trim(),
       name = _optionalText(name, maxTextLength),
       displayName = _optionalText(displayName, maxTextLength),
       osmType = _osmIdentity(osmType, osmId).$1,
       osmId = _osmIdentity(osmType, osmId).$2,
       osmCategory = _token(osmCategory),
       osmSubtype = _token(osmSubtype) {
    if (schema != schemaId) {
      throw ArgumentError.value(schema, 'schema', 'unsupported place schema');
    }
    if (!coordinatesValid(latitude, longitude)) {
      throw ArgumentError('coordinates are outside the valid range');
    }
    if (this.source.isEmpty || this.source.length > maxTokenLength) {
      throw ArgumentError('place source is missing or too long');
    }
    if (this.source.runes.any(_isControl)) {
      throw ArgumentError('place source contains control characters');
    }
  }

  /// Pin label. The calendar title is never used.
  String get headline {
    final named = name?.trim();
    if (named != null && named.isNotEmpty) return named;
    return displayName?.trim() ?? '';
  }

  /// Address line under [headline], when [displayName] says more than the name.
  String? get detailLine {
    final display = displayName?.trim();
    if (display == null || display.isEmpty) return null;
    final head = headline;
    if (display == head) return null;
    if (head.isNotEmpty && display.startsWith(head)) {
      final rest = display
          .substring(head.length)
          .replaceFirst(RegExp(r'^[, ]+'), '');
      return rest.isEmpty ? null : rest;
    }
    return display;
  }

  Map<String, dynamic> toJson() => {
    'schema': schema,
    'latitude': latitude,
    'longitude': longitude,
    'source': source,
    if (name != null) 'name': name,
    if (displayName != null) 'displayName': displayName,
    if (osmType != null) 'osmType': osmType,
    if (osmId != null) 'osmId': osmId,
    if (osmCategory != null) 'osmCategory': osmCategory,
    if (osmSubtype != null) 'osmSubtype': osmSubtype,
  };

  /// Null when [raw] is absent or not a usable `lwb.place/1` object. A bad
  /// place never fails the surrounding event.
  static EventPlace? tryParse(Object? raw) {
    if (raw == null || raw is! Map) return null;
    final json = Map<Object?, Object?>.from(raw);
    if (json['schema'] != schemaId) return null;
    final lat = _asDouble(json['latitude']);
    final lon = _asDouble(json['longitude']);
    final source = json['source'];
    if (lat == null || lon == null || source is! String) return null;
    final identity = _parseOsm(json['osmType'], json['osmId']);
    try {
      return EventPlace(
        latitude: lat,
        longitude: lon,
        source: source,
        name: _stringOrNull(json['name']),
        displayName: _stringOrNull(json['displayName']),
        osmType: identity.$1,
        osmId: identity.$2,
        osmCategory: _stringOrNull(json['osmCategory']),
        osmSubtype: _stringOrNull(json['osmSubtype']),
      );
    } on ArgumentError {
      return null;
    }
  }

  /// Coordinates from an iCalendar `GEO` property. Source is [icsSource]:
  /// an import does not invent an OpenStreetMap id.
  static EventPlace? fromIcsGeo(String? raw, {String? label}) {
    if (raw == null) return null;
    final parts = raw.split(';');
    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0].trim());
    final lon = double.tryParse(parts[1].trim());
    if (lat == null || lon == null) return null;
    try {
      return EventPlace(
        latitude: lat,
        longitude: lon,
        source: icsSource,
        displayName: label,
      );
    } on ArgumentError {
      return null;
    }
  }

  @override
  bool operator ==(Object other) {
    return other is EventPlace &&
        other.schema == schema &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.source == source &&
        other.name == name &&
        other.displayName == displayName &&
        other.osmType == osmType &&
        other.osmId == osmId &&
        other.osmCategory == osmCategory &&
        other.osmSubtype == osmSubtype;
  }

  @override
  int get hashCode => Object.hash(
    schema,
    latitude,
    longitude,
    source,
    name,
    displayName,
    osmType,
    osmId,
    osmCategory,
    osmSubtype,
  );
}

/// A place stays attached only while the location text is still the text it
/// was resolved against. Editing the address drops the old coordinates.
EventPlace? placeForLocation({
  required String? location,
  required String? resolvedAgainst,
  required EventPlace? place,
}) {
  if (place == null) return null;
  final text = location?.trim();
  final anchor = resolvedAgainst?.trim();
  if (text == null || text.isEmpty || text != anchor) return null;
  return place;
}

bool coordinatesValid(double latitude, double longitude) {
  return latitude.isFinite &&
      longitude.isFinite &&
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;
}

/// Six decimal places, dot separator. Used by geo URIs and `GEO` values.
String formatCoordinate(double value) => value.toStringAsFixed(6);

String? _optionalText(String? value, int max) {
  if (value == null) return null;
  final text = value.trim();
  if (text.isEmpty || text.length > max || text.runes.any(_isControl)) {
    return null;
  }
  return text;
}

String? _stringOrNull(Object? value) => value is String ? value : null;

String? _token(String? value) {
  final text = _optionalText(value, EventPlace.maxTokenLength);
  if (text == null) return null;
  if (!RegExp(r'^[A-Za-z0-9_:-]+$').hasMatch(text)) return null;
  return text;
}

(String?, int?) _osmIdentity(String? type, int? id) {
  if (type != 'node' && type != 'way' && type != 'relation') {
    return (null, null);
  }
  if (id == null || id <= 0) return (null, null);
  return (type, id);
}

(String?, int?) _parseOsm(Object? type, Object? id) {
  if (type is! String) return (null, null);
  return _osmIdentity(type, _asInt(id));
}

double? _asDouble(Object? value) {
  if (value is! num) return null;
  final number = value.toDouble();
  return number.isFinite ? number : null;
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num && value == value.roundToDouble()) return value.toInt();
  return null;
}

bool _isControl(int rune) => rune < 32 || rune == 127;
