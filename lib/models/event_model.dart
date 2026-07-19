import 'reminder_model.dart';

/// Preset recurrence rules for the MVP. Full custom RRULE support is a
/// phase-2 concern and deliberately not modeled here — expansion of these
/// presets into concrete occurrences lives in `utils/recurrence.dart`.
enum RecurrenceType {
  none,
  daily,
  weekly,
  monthly,
  yearly;

  /// Serialized form matches the data-model spec: `null` for [none],
  /// otherwise the lowercase name ("daily", "weekly", ...).
  String? get jsonValue => this == RecurrenceType.none ? null : name;

  static RecurrenceType fromJson(String? value) {
    if (value == null) return RecurrenceType.none;
    return RecurrenceType.values.firstWhere(
      (r) => r.name == value,
      orElse: () => RecurrenceType.none,
    );
  }
}

/// A calendar event. Timezone-aware and offline-first.
///
/// Time handling rule (see the requirements): times are ALWAYS stored in
/// UTC ([startTimeUtc]/[endTimeUtc]); [timezone] is the IANA zone the event
/// was authored in, used to convert back to local wall-clock time for
/// display and to compute reminder fire instants. Storing UTC keeps events
/// unambiguous across DST changes and across devices in different zones.
///
/// Sync: each event is serialized to JSON, NIP-44 self-encrypted, and
/// published as a kind-30078 parameterized replaceable event with the
/// `d` tag `epochs:<id>`. [synced]/[nostrEventId] track the last relay
/// publish; [deleted] is the local tombstone for NIP-09 deletions the
/// relays may or may not honor.
class Event {
  final String id;
  final String title;
  final String description;

  /// Start/end as UTC instants. Always UTC (`isUtc == true`).
  final DateTime startTimeUtc;
  final DateTime endTimeUtc;

  /// IANA timezone name the event was authored in (e.g. "Europe/Rome").
  final String timezone;

  final bool isAllDay;

  /// Preset recurrence. [RecurrenceType.none] means a one-off event.
  final RecurrenceType recurrence;

  /// Inclusive upper bound for recurring occurrences (UTC), or null for an
  /// open-ended recurrence. Ignored when [recurrence] is
  /// [RecurrenceType.none].
  final DateTime? recurrenceEnd;

  final List<Reminder> reminders;

  /// ARGB color as a hex string, e.g. "0xFF2196F3".
  final String color;

  final String? location;

  /// Whether the latest local version has been published to the relays.
  final bool synced;

  /// The Nostr event id of the last successful publish, if any.
  final String? nostrEventId;

  /// Account that owns this event's sync history. Null means the event has
  /// never been associated with an account (for example, it was created in
  /// offline mode or imported from ICS). This prevents an unsynced event from
  /// one signed-in account being published under another account after a
  /// switch.
  final String? syncOwnerPubkey;

  /// Local deletion tombstone: kept so a NIP-09 deletion the relays ignore
  /// doesn't resurrect on the next sync (the local flag wins).
  final bool deleted;

  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.title,
    this.description = '',
    required this.startTimeUtc,
    required this.endTimeUtc,
    required this.timezone,
    this.isAllDay = false,
    this.recurrence = RecurrenceType.none,
    this.recurrenceEnd,
    this.reminders = const [],
    this.color = '0xFF2196F3',
    this.location,
    this.synced = false,
    this.nostrEventId,
    this.syncOwnerPubkey,
    this.deleted = false,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(startTimeUtc.isUtc, 'startTimeUtc must be UTC'),
       assert(endTimeUtc.isUtc, 'endTimeUtc must be UTC');

  Event copyWith({
    String? title,
    String? description,
    DateTime? startTimeUtc,
    DateTime? endTimeUtc,
    String? timezone,
    bool? isAllDay,
    RecurrenceType? recurrence,
    DateTime? recurrenceEnd,
    bool clearRecurrenceEnd = false,
    List<Reminder>? reminders,
    String? color,
    String? location,
    bool clearLocation = false,
    bool? synced,
    String? nostrEventId,
    String? syncOwnerPubkey,
    bool? deleted,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTimeUtc: startTimeUtc ?? this.startTimeUtc,
      endTimeUtc: endTimeUtc ?? this.endTimeUtc,
      timezone: timezone ?? this.timezone,
      isAllDay: isAllDay ?? this.isAllDay,
      recurrence: recurrence ?? this.recurrence,
      recurrenceEnd: clearRecurrenceEnd
          ? null
          : (recurrenceEnd ?? this.recurrenceEnd),
      reminders: reminders ?? this.reminders,
      color: color ?? this.color,
      location: clearLocation ? null : (location ?? this.location),
      synced: synced ?? this.synced,
      nostrEventId: nostrEventId ?? this.nostrEventId,
      syncOwnerPubkey: syncOwnerPubkey ?? this.syncOwnerPubkey,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Duration between start and end — reused when projecting recurring
  /// occurrences so every occurrence keeps the original length.
  Duration get duration => endTimeUtc.difference(startTimeUtc);

  /// The `d` tag used for this event's kind-30078 replaceable event.
  String get dTag => 'epochs:$id';

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'startTimeUtc': startTimeUtc.toIso8601String(),
    'endTimeUtc': endTimeUtc.toIso8601String(),
    'timezone': timezone,
    'isAllDay': isAllDay,
    'recurrence': recurrence.jsonValue,
    'recurrenceEnd': recurrenceEnd?.toIso8601String(),
    'reminders': reminders.map((r) => r.toJson()).toList(),
    'color': color,
    'location': location,
    'synced': synced,
    'nostrEventId': nostrEventId,
    'syncOwnerPubkey': syncOwnerPubkey,
    'deleted': deleted,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
  };

  factory Event.fromJson(Map<String, dynamic> json) {
    DateTime parseUtc(String iso) => DateTime.parse(iso).toUtc();
    return Event(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      startTimeUtc: parseUtc(json['startTimeUtc'] as String),
      endTimeUtc: parseUtc(json['endTimeUtc'] as String),
      timezone: json['timezone'] as String? ?? 'UTC',
      isAllDay: json['isAllDay'] as bool? ?? false,
      recurrence: RecurrenceType.fromJson(json['recurrence'] as String?),
      recurrenceEnd: json['recurrenceEnd'] == null
          ? null
          : parseUtc(json['recurrenceEnd'] as String),
      reminders: (json['reminders'] as List<dynamic>? ?? const [])
          .map(
            (e) => Reminder.fromJson(
              Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
            ),
          )
          .toList(),
      color: json['color'] as String? ?? '0xFF2196F3',
      location: json['location'] as String?,
      synced: json['synced'] as bool? ?? false,
      nostrEventId: json['nostrEventId'] as String?,
      syncOwnerPubkey: json['syncOwnerPubkey'] as String?,
      deleted: json['deleted'] as bool? ?? false,
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
    );
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
    }
    // Tolerate ISO strings too, in case an older/other client wrote them.
    return DateTime.parse(value as String).toUtc();
  }
}
