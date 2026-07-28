import 'dart:convert';

import '../models/event_model.dart';
import '../models/reminder_model.dart';

/// Versioned local contract used by Kairos to hand a calendar mirror to
/// Astraea. Nostr remains the durable cross-device transport; this contract
/// makes the same-device update immediate.
class KairosLocalService {
  KairosLocalService._();

  static const protocol = 'dev.echoes.astraea.local';
  static const protocolVersion = 1;
  static const maxPayloadBytes = 64 * 1024;

  /// Decodes the complete Kairos envelope.
  static KairosLocalMessage decode(String raw) {
    if (utf8.encode(raw).length > maxPayloadBytes) {
      throw const FormatException('Kairos payload is too large.');
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Kairos payload must be a JSON object.');
    }
    final json = Map<String, dynamic>.from(decoded);

    final wireProtocol = json['protocol'];
    if (wireProtocol is String && wireProtocol != protocol) {
      throw FormatException('Unsupported Kairos protocol: $wireProtocol');
    }
    final version = (json['version'] as num?)?.toInt() ??
        (wireProtocol is num ? wireProtocol.toInt() : protocolVersion);
    if (version != protocolVersion) {
      throw FormatException('Unsupported Kairos protocol version: $version');
    }
    final source = json['source'];
    if (source != null && source != 'kairos') {
      throw const FormatException('Kairos payload has an invalid source.');
    }

    final operation = json['operation'] as String? ?? 'upsert';
    if (operation != 'upsert' && operation != 'delete') {
      throw FormatException('Unsupported Kairos operation: $operation');
    }

    final eventJson = json['event'] ?? json['task'];
    final event = eventJson is Map
        ? _decodeEvent(Map<String, dynamic>.from(eventJson))
        : _decodeEvent(json);
    final taskId = _string(json['taskId']);
    if (taskId != null && taskId != event.id) {
      throw const FormatException('Kairos task id does not match event id.');
    }

    final notification = json['notification'];
    final showNotification = notification is Map
        ? notification['show'] as bool? ?? operation == 'upsert'
        : operation == 'upsert';
    final dedupeKey = notification is Map
        ? _string(notification['dedupeKey'])
        : null;

    return KairosLocalMessage(
      operation: operation,
      event: operation == 'delete' ? event.copyWith(deleted: true) : event,
      showNotification: showNotification && operation == 'upsert',
      dedupeKey: dedupeKey,
    );
  }

  /// Backwards-compatible convenience for the compact direct event shape.
  static Event decodeTask(String raw) => decode(raw).event;

  static Event _decodeEvent(Map<String, dynamic> json) {
    final id = _requiredString(json, const ['id', 'taskId'], 'id');
    final title = _string(_first(json, const ['title', 'name'])) ?? '';
    final start = _parseDateTime(
      _first(json, const ['dueAt', 'startTimeUtc', 'start', 'dueDate']),
      'dueAt',
    );
    final end = _parseDateTime(
      _first(json, const ['endTimeUtc', 'end']) ?? start.toIso8601String(),
      'endTimeUtc',
    );
    if (end.isBefore(start)) {
      throw const FormatException('Kairos task end precedes its due time.');
    }

    final now = DateTime.now().toUtc();
    final updatedAt = _parseTimestamp(json['updatedAt']) ?? now;
    final createdAt = _parseTimestamp(json['createdAt']) ?? updatedAt;
    final reminders = _reminders(json);

    return Event(
      id: id,
      title: title,
      description:
          _string(_first(json, const ['description', 'note'])) ?? 'Kairos task',
      startTimeUtc: start,
      endTimeUtc: end,
      timezone: _string(json['timezone']) ?? 'UTC',
      isAllDay: _bool(_first(json, const ['isAllDay', 'allDay'])) ?? false,
      recurrence: RecurrenceType.fromJson(
        _string(json['recurrence']),
      ),
      recurrenceEnd: _parseTimestamp(json['recurrenceEnd']),
      // The explicit envelope says whether to notify. When Kairos has no
      // task reminder, still make “show in Astraea” visibly actionable.
      reminders: reminders.isEmpty
          ? const [Reminder(minutesBefore: 0)]
          : reminders,
      color: _string(json['color']) ?? '0xFF2196F3',
      location: _string(json['location']),
      // Kairos owns the Nostr mirror; Astraea must not republish this handoff.
      synced: true,
      deleted: json['deleted'] as bool? ?? false,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static dynamic _first(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key) && json[key] != null) return json[key];
    }
    return null;
  }

  static String _requiredString(
    Map<String, dynamic> json,
    List<String> keys,
    String field,
  ) {
    final value = _string(_first(json, keys))?.trim();
    if (value == null || value.isEmpty || value.length > 256) {
      throw FormatException('Kairos payload has an invalid $field.');
    }
    return value;
  }

  static String? _string(dynamic value) => value is String ? value : null;

  static bool? _bool(dynamic value) => value is bool ? value : null;

  static List<Reminder> _reminders(Map<String, dynamic> json) {
    final raw = json['reminders'];
    final values = raw is List
        ? raw
        : json['reminderMinutesBefore'] is num
        ? [<String, dynamic>{'minutesBefore': json['reminderMinutesBefore']}]
        : const [];
    final seen = <int>{};
    final result = <Reminder>[];
    for (final value in values) {
      if (value is! Map) continue;
      final minutes = value['minutesBefore'];
      if (minutes is! num || minutes.isNaN || minutes.isInfinite) continue;
      final offset = minutes.toInt();
      if (offset < 0 || offset > 525600 || !seen.add(offset)) continue;
      result.add(Reminder(minutesBefore: offset));
      if (result.length == 8) break;
    }
    return result;
  }

  static DateTime _parseDateTime(dynamic value, String field) {
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Kairos payload is missing $field.');
    }
    final parsed = DateTime.tryParse(value);
    if (parsed == null) throw FormatException('Invalid Kairos $field.');
    return parsed.toUtc();
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true);
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value)?.toUtc();
    }
    return null;
  }
}

class KairosLocalMessage {
  const KairosLocalMessage({
    required this.operation,
    required this.event,
    required this.showNotification,
    this.dedupeKey,
  });

  final String operation;
  final Event event;
  final bool showNotification;
  final String? dedupeKey;
}
