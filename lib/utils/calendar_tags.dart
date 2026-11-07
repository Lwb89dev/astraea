import '../models/event_model.dart';

/// Tags published in the clear for a calendar event.
///
/// The encrypted payload carries [Event.toJson], including [Event.place].
/// Coordinates, addresses and OSM ids are never tags.
List<List<String>> publicCalendarTags(Event event) => [
  ['d', event.dTag],
];
