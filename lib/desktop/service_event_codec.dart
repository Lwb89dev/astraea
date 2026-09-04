import '../models/event_model.dart';
import '../models/reminder_model.dart';

/// Maps between the app's [Event] model and the JSON the Astraea Linux
/// service speaks on D-Bus (docs/dbus-api.md, schemaVersion 1).
///
/// The service model is a superset (calendarId, syncState machine, url…);
/// this codec projects it onto the shared [Event] so every existing screen
/// works unchanged on desktop.
class ServiceEventCodec {
  ServiceEventCodec._();

  static Event fromServiceJson(Map<String, dynamic> json) {
    final syncState = json['syncState'] as String? ?? 'local_only';
    return Event(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      startTimeUtc: DateTime.parse(json['start'] as String).toUtc(),
      endTimeUtc: DateTime.parse(json['end'] as String).toUtc(),
      timezone: json['timezone'] as String? ?? 'UTC',
      isAllDay: json['allDay'] as bool? ?? false,
      recurrence: RecurrenceType.fromJson(_recurrenceOf(json)),
      recurrenceEnd: json['recurrenceEnd'] == null
          ? null
          : DateTime.parse(json['recurrenceEnd'] as String).toUtc(),
      reminders: (json['reminders'] as List<dynamic>? ?? const [])
          .map((r) => Reminder.fromJson(Map<String, dynamic>.from(r as Map)))
          .toList(),
      color: json['color'] as String? ?? '0xFF2196F3',
      location: json['location'] as String?,
      synced: syncState == 'synced' || syncState == 'deleted_synced',
      nostrEventId: json['nostrEventId'] as String?,
      syncOwnerPubkey: json['ownerPubkey'] as String?,
      deleted:
          syncState == 'deleted_pending' ||
          syncState == 'deleted_synced' ||
          json['deletedAt'] != null,
      createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toUtc(),
    );
  }

  /// The service serializes recurrence as a lowercase string enum; `none`
  /// maps to the wire `null` this side expects.
  static String? _recurrenceOf(Map<String, dynamic> json) {
    final value = json['recurrence'] as String?;
    return (value == null || value == 'none') ? null : value;
  }

  /// Draft for `CreateEvent`. The locally generated [Event.id] is passed
  /// through so an unpublished event keeps one stable identity end-to-end.
  static Map<String, dynamic> toDraftJson(Event event) => {
    'schemaVersion': 1,
    'id': event.id,
    'title': event.title,
    'description': event.description,
    if (event.location != null) 'location': event.location,
    'start': event.startTimeUtc.toIso8601String(),
    'end': event.endTimeUtc.toIso8601String(),
    'timezone': event.timezone,
    'allDay': event.isAllDay,
    'color': event.color,
    if (event.recurrence != RecurrenceType.none)
      'recurrence': {
        'type': event.recurrence.name,
        if (event.recurrenceEnd != null)
          'until': event.recurrenceEnd!.toIso8601String(),
      },
    'reminders': event.reminders.map((r) => r.toJson()).toList(),
  };

  /// Full-field merge patch for `UpdateEvent`: the editor produces a complete
  /// [Event], so every mutable field is sent (null clears location/recurrence).
  static Map<String, dynamic> toPatchJson(Event event) => {
    'schemaVersion': 1,
    'title': event.title,
    'description': event.description,
    'location': event.location,
    'start': event.startTimeUtc.toIso8601String(),
    'end': event.endTimeUtc.toIso8601String(),
    'timezone': event.timezone,
    'allDay': event.isAllDay,
    'color': event.color,
    'recurrence': event.recurrence == RecurrenceType.none
        ? null
        : {
            'type': event.recurrence.name,
            if (event.recurrenceEnd != null)
              'until': event.recurrenceEnd!.toIso8601String(),
          },
    'reminders': event.reminders.map((r) => r.toJson()).toList(),
  };
}
