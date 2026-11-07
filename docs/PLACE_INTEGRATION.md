# Place integration

Astraea can attach a resolved place to an event. The text the user typed
stays in `location`. Coordinates and OpenStreetMap identity, when the user
asks for them, live in `place`.

Resolving a location is a user action (Save, or Resolve again). Astraea does
not geocode the calendar in the background and does not send the title,
description, reminders, or any other event field to the geocoder.

## `lwb.place/1`

This is a small interchange object. It is not private to Astraea. Another
app that decrypts an Astraea calendar payload, or that shares this schema,
can read it.

```json
{
  "schema": "lwb.place/1",
  "name": "Bianchini SRL",
  "displayName": "Bianchini SRL, Via Roma 1, Torino, Italia",
  "latitude": 45.0703,
  "longitude": 7.6869,
  "osmType": "node",
  "osmId": 123456789,
  "osmCategory": "amenity",
  "osmSubtype": "dentist",
  "source": "osm-nominatim"
}
```

Required:

| Field | Meaning |
| --- | --- |
| `schema` | Exactly `lwb.place/1`. Any other value is ignored. |
| `latitude` | Finite number, −90 to 90. |
| `longitude` | Finite number, −180 to 180. |
| `source` | Who produced the coordinates. `osm-nominatim` for a Nominatim search. `icalendar` for an imported `GEO` property. |

Optional: `name`, `displayName`, `osmType` (`node`, `way`, or `relation`),
`osmId` (positive integer), `osmCategory`, `osmSubtype`.

Do not store Nominatim `place_id`. It is specific to one Nominatim instance
and is not stable.

Unknown keys are dropped. A place that fails validation is discarded. The
event around it still loads, with `place` absent. Events written before this
field existed have no `place` key and stay valid.

`location` remains the human-readable string. Changing that text drops the
previous `place`. Coordinates from an old address are not kept.

## Privacy

The geocoder sees one string: the location field, trimmed, at most 300
characters. It does not see the rest of the event.

The request happens when the user saves an event that has location text and
no place yet, or when they tap Resolve again. A failure, including being
offline, still saves the event. `location` keeps the typed text and `place`
stays empty.

There is no bulk geocode and no scan of existing events.

The editor says so next to the field: resolving sends that text to the
configured geocoding provider.

On sync, `place` is a field of `Event.toJson()`. It rides inside the existing
NIP-44 ciphertext of the kind `30078` event. The public tags stay exactly
`["d", "epochs:<id>"]`. Latitude, longitude, addresses and OSM ids are not
tags, and this does not add a Nostr kind.

The Linux service keeps `place` in the event metadata column and writes it
back into the encrypted payload when it republishes. A newer remote payload
that omits `place` clears the stored one, which is the same rule as any
other optional payload field an older writer drops.

Production logs do not include location text, resolved addresses, or
coordinates.

## Nominatim

The default provider is the public Nominatim search endpoint:

`https://nominatim.openstreetmap.org/search`

The service is `NominatimGeocodingService`. Pass another `https` URI to point
it at a self-hosted instance. Plain `http` is rejected. There is no Astraea
backend in between.

The public instance is used within its usage policy:

- search runs on Save or Resolve again, never on each keystroke
- at most one request per second to `nominatim.openstreetmap.org`
- `User-Agent` is `Astraea/1.1.0 (+https://github.com/Lwb89dev/astraea)`
- responses are capped (256 KiB) and time out after 10 seconds
- identical normalised queries are cached in memory
- the UI credits OpenStreetMap and links to
  <https://www.openstreetmap.org/copyright>

Nominatim does not return a confidence score this app treats as truth.
Candidates are ordered from the query text and the address parts Nominatim
did return (name, street, house number, city, postcode, country). One clear
lead is attached. Several plausible hits are shown in a sheet, which always
includes “Keep location without map position”. No plausible hit leaves the
text as-is.

Map data is © OpenStreetMap contributors.

## Android navigation

A resolved place opens with the standard map intent:

`geo:0,0?q=<latitude>,<longitude>(<percent-encoded label>)`

The label is the place name, not the calendar title. Latitude and longitude
are formatted by Astraea. The label is the only user-controlled component
and is percent-encoded.

On Android the bridge is the method channel `com.example.astraea/places`.
If `app.roadstr` is installed, the intent is targeted at that package so
another app cannot stand in for Roadstr. The manifest declares package
visibility for `app.roadstr` only.

Roadstr is not a dependency. The event saves without it. If Roadstr is
absent, or installed but does not handle the URI, Astraea sends the same
`geo:` URI with no package set. If nothing handles it, the screen says so.
It does not crash.

No re-geocoding is required to navigate. The coordinates were stored with
the event.

## iCalendar

`LOCATION` is still exported from the text field. A resolved place also
exports RFC 5545 `GEO:<latitude>;<longitude>`.

Import reads `LOCATION` as before. A valid `GEO` becomes a place with
`source` `icalendar` and no OSM id. An Astraea round trip through iCalendar
keeps the coordinates and the location text. OSM identity does not survive
`GEO`, because the standard property has no place for it.

## Versioning

`lwb.place/1` is additive and optional. A reader that does not know it
ignores the object. A writer that does not know it omits the object.

A future incompatible change uses a new schema string (`lwb.place/2`).
Readers of `lwb.place/1` ignore unknown schemas instead of guessing.
