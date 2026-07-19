import 'package:uuid/uuid.dart';

import '../models/event_model.dart';
import '../models/reminder_model.dart';

/// Encodes/decodes Astraea events as iCalendar (RFC 5545) — the interchange
/// format every other calendar app speaks, so an export can be opened in
/// Thunderbird/Google Calendar/etc. and an .ics from them can be imported here.
///
/// Scope matches the app's own model rather than the whole spec: VEVENT with
/// UID/DTSTAMP/DTSTART/DTEND/SUMMARY/DESCRIPTION/LOCATION, RRULE limited to the
/// MVP presets (FREQ=DAILY|WEEKLY|MONTHLY|YEARLY [;UNTIL=]), and VALARM
/// reminders as negative TRIGGER durations. Anything richer that comes in from
/// another app (BYDAY, INTERVAL>1, EXDATE, VTIMEZONE definitions...) is
/// deliberately ignored rather than half-honoured — see [_parseRecurrence].
///
/// Times are written as UTC (`...Z`), which is exactly how events are stored,
/// so no timezone conversion happens on either side. The event's IANA zone is
/// carried in a private `X-ASTRAEA-TZ` property so an Astraea round trip keeps
/// it; other apps ignore unknown X- properties, per spec. Historical
/// `X-EPOCHS-*` properties are still accepted during import.
class IcsCodec {
  IcsCodec._();

  static const _uuid = Uuid();
  static const _prodId = '-//Astraea//Calendar on Nostr//EN';
  static const _tzProperty = 'X-ASTRAEA-TZ';
  static const _colorProperty = 'X-ASTRAEA-COLOR';
  static const _legacyTzProperty = 'X-EPOCHS-TZ';
  static const _legacyColorProperty = 'X-EPOCHS-COLOR';

  // ---------------------------------------------------------------------
  // Encode
  // ---------------------------------------------------------------------

  /// Serializes [events] into one VCALENDAR document.
  static String encode(Iterable<Event> events) {
    final buffer = StringBuffer()
      ..writeln('BEGIN:VCALENDAR')
      ..writeln('VERSION:2.0')
      ..writeln('PRODID:$_prodId')
      ..writeln('CALSCALE:GREGORIAN');
    for (final event in events) {
      _writeEvent(buffer, event);
    }
    buffer.writeln('END:VCALENDAR');
    // RFC 5545 §3.1 mandates CRLF line breaks; strict parsers reject bare LF.
    // No value can contain a raw newline (see [_escape]), so this is safe.
    return buffer.toString().replaceAll('\n', '\r\n');
  }

  static void _writeEvent(StringBuffer buffer, Event event) {
    buffer
      ..writeln('BEGIN:VEVENT')
      ..writeln('UID:${event.id}@astraea')
      ..writeln('DTSTAMP:${_formatUtc(event.updatedAt)}');

    if (event.isAllDay) {
      // All-day events use a DATE value and a non-inclusive end date.
      buffer
        ..writeln('DTSTART;VALUE=DATE:${_formatDate(event.startTimeUtc)}')
        ..writeln(
          'DTEND;VALUE=DATE:${_formatDate(event.endTimeUtc.add(const Duration(days: 1)))}',
        );
    } else {
      buffer
        ..writeln('DTSTART:${_formatUtc(event.startTimeUtc)}')
        ..writeln('DTEND:${_formatUtc(event.endTimeUtc)}');
    }

    buffer.writeln('SUMMARY:${_escape(event.title)}');
    if (event.description.isNotEmpty) {
      buffer.writeln('DESCRIPTION:${_escape(event.description)}');
    }
    final location = event.location;
    if (location != null && location.isNotEmpty) {
      buffer.writeln('LOCATION:${_escape(location)}');
    }
    final rrule = _formatRecurrence(event);
    if (rrule != null) buffer.writeln('RRULE:$rrule');

    buffer
      ..writeln('$_tzProperty:${event.timezone}')
      ..writeln('$_colorProperty:${event.color}');

    for (final reminder in event.reminders) {
      buffer
        ..writeln('BEGIN:VALARM')
        ..writeln('ACTION:DISPLAY')
        ..writeln('DESCRIPTION:${_escape(event.title)}')
        ..writeln('TRIGGER:${_formatTrigger(reminder.minutesBefore)}')
        ..writeln('END:VALARM');
    }
    buffer.writeln('END:VEVENT');
  }

  static String? _formatRecurrence(Event event) {
    if (event.recurrence == RecurrenceType.none) return null;
    final freq = switch (event.recurrence) {
      RecurrenceType.daily => 'DAILY',
      RecurrenceType.weekly => 'WEEKLY',
      RecurrenceType.monthly => 'MONTHLY',
      RecurrenceType.yearly => 'YEARLY',
      RecurrenceType.none => null,
    };
    if (freq == null) return null;
    final until = event.recurrenceEnd;
    return until == null
        ? 'FREQ=$freq'
        : 'FREQ=$freq;UNTIL=${_formatUtc(until)}';
  }

  /// A reminder as a negative ISO-8601 duration ("-PT15M", "-P1D"). 0 minutes
  /// means "at start" → "PT0S".
  static String _formatTrigger(int minutesBefore) {
    if (minutesBefore <= 0) return 'PT0S';
    if (minutesBefore % 1440 == 0) return '-P${minutesBefore ~/ 1440}D';
    if (minutesBefore % 60 == 0) return '-PT${minutesBefore ~/ 60}H';
    return '-PT${minutesBefore}M';
  }

  static String _formatUtc(DateTime instant) {
    final u = instant.toUtc();
    return '${_pad4(u.year)}${_pad2(u.month)}${_pad2(u.day)}'
        'T${_pad2(u.hour)}${_pad2(u.minute)}${_pad2(u.second)}Z';
  }

  static String _formatDate(DateTime instant) {
    final u = instant.toUtc();
    return '${_pad4(u.year)}${_pad2(u.month)}${_pad2(u.day)}';
  }

  static String _pad2(int v) => v.toString().padLeft(2, '0');
  static String _pad4(int v) => v.toString().padLeft(4, '0');

  /// RFC 5545 §3.3.11 text escaping: backslash, newline, comma, semicolon.
  /// Stray carriage returns are dropped — a raw CR inside a value would break
  /// the document's CRLF framing.
  static String _escape(String value) {
    return value
        .replaceAll('\r', '')
        .replaceAll('\\', '\\\\')
        .replaceAll('\n', '\\n')
        .replaceAll(',', '\\,')
        .replaceAll(';', '\\;');
  }

  static String _unescape(String value) {
    final out = StringBuffer();
    for (var i = 0; i < value.length; i++) {
      if (value[i] == '\\' && i + 1 < value.length) {
        final next = value[i + 1];
        out.write(switch (next) {
          'n' || 'N' => '\n',
          '\\' => '\\',
          ',' => ',',
          ';' => ';',
          _ => next,
        });
        i++;
      } else {
        out.write(value[i]);
      }
    }
    return out.toString();
  }

  // ---------------------------------------------------------------------
  // Decode
  // ---------------------------------------------------------------------

  /// Parses a VCALENDAR document into events. Throws [FormatException] if the
  /// text isn't an iCalendar document at all; individual VEVENTs that can't be
  /// understood (no DTSTART) are skipped rather than failing the whole import.
  ///
  /// [defaultTimezone] is used for events that carry no app timezone property
  /// anything exported by another app).
  static List<Event> decode(String text, {required String defaultTimezone}) {
    if (!text.contains('BEGIN:VCALENDAR')) {
      throw const FormatException('Not an iCalendar (.ics) file.');
    }
    final lines = _unfold(text);
    final events = <Event>[];

    List<String>? current;
    for (final line in lines) {
      if (line == 'BEGIN:VEVENT') {
        current = [];
      } else if (line == 'END:VEVENT') {
        if (current != null) {
          final event = _parseEvent(current, defaultTimezone);
          if (event != null) events.add(event);
        }
        current = null;
      } else {
        current?.add(line);
      }
    }
    return events;
  }

  /// RFC 5545 line unfolding: a CRLF followed by a space/tab continues the
  /// previous line. Must run before any property parsing.
  static List<String> _unfold(String text) {
    final raw = text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n');
    final out = <String>[];
    for (final line in raw) {
      if (line.isEmpty) continue;
      if ((line.startsWith(' ') || line.startsWith('\t')) && out.isNotEmpty) {
        out[out.length - 1] = out.last + line.substring(1);
      } else {
        out.add(line);
      }
    }
    return out;
  }

  static Event? _parseEvent(List<String> lines, String defaultTimezone) {
    String? uid;
    String? summary;
    String? description;
    String? location;
    String? timezone;
    String? color;
    DateTime? start;
    DateTime? end;
    var isAllDay = false;
    var recurrence = RecurrenceType.none;
    DateTime? recurrenceEnd;
    final reminders = <Reminder>[];

    for (final line in lines) {
      final split = _splitProperty(line);
      if (split == null) continue;
      final (name, params, value) = split;

      switch (name) {
        case 'UID':
          uid = value;
        case 'SUMMARY':
          summary = _unescape(value);
        case 'DESCRIPTION':
          // A VALARM's own DESCRIPTION would land here too; only take the
          // first (the VEVENT's), never let an alarm overwrite it.
          description ??= _unescape(value);
        case 'LOCATION':
          location = _unescape(value);
        case _tzProperty || _legacyTzProperty:
          timezone = value.trim();
        case _colorProperty || _legacyColorProperty:
          color = value.trim();
        case 'DTSTART':
          isAllDay = params.contains('VALUE=DATE');
          start = _parseDateTime(value);
        case 'DTEND':
          end = _parseDateTime(value);
        case 'RRULE':
          final parsed = _parseRecurrence(value);
          recurrence = parsed.$1;
          recurrenceEnd = parsed.$2;
        case 'TRIGGER':
          final minutes = _parseTrigger(value);
          if (minutes != null) reminders.add(Reminder(minutesBefore: minutes));
      }
    }

    if (start == null) return null; // Not a usable event.
    if (isAllDay && end != null) {
      // DTEND is exclusive for DATE values; bring it back to the last day.
      end = end.subtract(const Duration(days: 1));
    }
    final effectiveEnd = end ?? start.add(const Duration(hours: 1));
    final now = DateTime.now().toUtc();

    return Event(
      // Reuse the exported id when this came from Astraea (or its former
      // Epochs identity), so re-importing an
      // export updates events in place instead of duplicating them. Anything
      // else gets a fresh id.
      id: _appUidId(uid) ?? _uuid.v4(),
      title: summary ?? '',
      description: description ?? '',
      startTimeUtc: start,
      endTimeUtc: effectiveEnd.isAfter(start)
          ? effectiveEnd
          : start.add(const Duration(hours: 1)),
      timezone: timezone ?? defaultTimezone,
      isAllDay: isAllDay,
      recurrence: recurrence,
      recurrenceEnd: recurrenceEnd,
      reminders: reminders,
      color: color ?? '0xFF2196F3',
      location: (location != null && location.isNotEmpty) ? location : null,
      synced: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Extracts an event id from current and pre-rename Astraea export UIDs.
  static String? _appUidId(String? uid) {
    if (uid == null) return null;
    for (final suffix in const ['@astraea', '@epochs']) {
      if (uid.endsWith(suffix)) {
        return uid.substring(0, uid.length - suffix.length);
      }
    }
    return null;
  }

  /// Splits "NAME;PARAM=X:value" into its name, parameters and value. Returns
  /// null for a line with no colon (malformed).
  static (String, String, String)? _splitProperty(String line) {
    final colon = line.indexOf(':');
    if (colon < 0) return null;
    final head = line.substring(0, colon);
    final value = line.substring(colon + 1);
    final semi = head.indexOf(';');
    if (semi < 0) return (head.toUpperCase(), '', value);
    return (
      head.substring(0, semi).toUpperCase(),
      head.substring(semi + 1).toUpperCase(),
      value,
    );
  }

  /// Parses "20260715T130000Z", "20260715T130000" (floating — treated as UTC,
  /// since we have no VTIMEZONE support) or "20260715" (DATE).
  static DateTime? _parseDateTime(String value) {
    final v = value.trim();
    final match = RegExp(
      r'^(\d{4})(\d{2})(\d{2})(?:T(\d{2})(\d{2})(\d{2})(Z?))?$',
    ).firstMatch(v);
    if (match == null) return null;
    return DateTime.utc(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
      int.parse(match.group(4) ?? '0'),
      int.parse(match.group(5) ?? '0'),
      int.parse(match.group(6) ?? '0'),
    );
  }

  /// Maps an RRULE to the MVP presets. Only a bare FREQ (with an optional
  /// UNTIL) is honoured: an INTERVAL other than 1, or any BY* part, describes a
  /// pattern Astraea can't yet expand ([RecurrenceExpander] is preset-only), and
  /// silently importing it as a plain daily/weekly rule would put events on the
  /// wrong days. Those are dropped to a one-off event instead — visibly missing
  /// a recurrence beats silently wrong dates. Full RRULE is phase 2.
  static (RecurrenceType, DateTime?) _parseRecurrence(String value) {
    final parts = <String, String>{};
    for (final chunk in value.toUpperCase().split(';')) {
      final eq = chunk.indexOf('=');
      if (eq > 0) parts[chunk.substring(0, eq)] = chunk.substring(eq + 1);
    }
    final interval = parts['INTERVAL'];
    if (interval != null && interval != '1') return (RecurrenceType.none, null);
    if (parts.keys.any((k) => k.startsWith('BY'))) {
      return (RecurrenceType.none, null);
    }

    final type = switch (parts['FREQ']) {
      'DAILY' => RecurrenceType.daily,
      'WEEKLY' => RecurrenceType.weekly,
      'MONTHLY' => RecurrenceType.monthly,
      'YEARLY' => RecurrenceType.yearly,
      _ => RecurrenceType.none,
    };
    if (type == RecurrenceType.none) return (RecurrenceType.none, null);
    final until = parts['UNTIL'];
    return (type, until == null ? null : _parseDateTime(until));
  }

  /// Parses a VALARM TRIGGER duration into "minutes before the start". Only
  /// negative (or zero) durations relative to the start make sense as a
  /// reminder; a positive one (after the start) is ignored.
  static int? _parseTrigger(String value) {
    final v = value.trim().toUpperCase();
    final match = RegExp(
      r'^(-)?P(?:(\d+)W)?(?:(\d+)D)?(?:T(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?)?$',
    ).firstMatch(v);
    if (match == null) return null;
    final negative = match.group(1) == '-';
    final weeks = int.tryParse(match.group(2) ?? '0') ?? 0;
    final days = int.tryParse(match.group(3) ?? '0') ?? 0;
    final hours = int.tryParse(match.group(4) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(5) ?? '0') ?? 0;
    final total = weeks * 7 * 1440 + days * 1440 + hours * 60 + minutes;
    if (total == 0) return 0; // "At start".
    return negative ? total : null;
  }
}
