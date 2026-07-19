import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';

import '../models/event_model.dart';
import '../models/reminder_model.dart';
import '../providers/events_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/event_color.dart';
import '../utils/formatter.dart';
import 'widgets/timezone_picker.dart';

/// Create/edit an event. Pass [existing] to edit, or [initialDay] to create
/// a new event pre-seeded to that day. Times are entered as local wall-clock
/// in the event's timezone and converted to UTC on save (the app's storage
/// rule is "always UTC on disk").
class EventEditorScreen extends ConsumerStatefulWidget {
  const EventEditorScreen({super.key, this.existing, this.initialDay});

  final Event? existing;
  final DateTime? initialDay;

  @override
  ConsumerState<EventEditorScreen> createState() => _EventEditorScreenState();
}

class _EventEditorScreenState extends ConsumerState<EventEditorScreen> {
  final _uuid = const Uuid();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  late DateTime _start;
  late DateTime _end;
  late String _timezone;
  bool _isAllDay = false;
  RecurrenceType _recurrence = RecurrenceType.none;
  DateTime? _recurrenceEnd;
  List<Reminder> _reminders = const [Reminder(minutesBefore: 15)];
  int _colorValue = kEventColorPalette.first;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _titleController.text = e.title;
      _descriptionController.text = e.description;
      _locationController.text = e.location ?? '';
      _timezone = e.timezone;
      _start = Formatter.toZoned(e.startTimeUtc, e.timezone);
      _end = Formatter.toZoned(e.endTimeUtc, e.timezone);
      _isAllDay = e.isAllDay;
      _recurrence = e.recurrence;
      _recurrenceEnd = e.recurrenceEnd == null
          ? null
          : Formatter.toZoned(e.recurrenceEnd!, e.timezone);
      _reminders = List.of(e.reminders);
      _colorValue = parseEventColor(e.color).toARGB32();
    } else {
      final day = widget.initialDay ?? DateTime.now();
      final now = DateTime.now();
      _start = DateTime(day.year, day.month, day.day, now.hour + 1);
      _end = _start.add(const Duration(hours: 1));
      _timezone = ref.read(settingsProvider).value?.timezone ?? tz.local.name;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  /// Interprets a picked local wall-clock [DateTime] as being in the event's
  /// [_timezone] and returns the corresponding UTC instant.
  DateTime _toUtc(DateTime wall) {
    try {
      final loc = tz.getLocation(_timezone);
      return tz.TZDateTime(
        loc,
        wall.year,
        wall.month,
        wall.day,
        wall.hour,
        wall.minute,
      ).toUtc();
    } catch (_) {
      return wall.toUtc();
    }
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final base = isStart ? _start : _end;
    final date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;

    TimeOfDay? time = TimeOfDay.fromDateTime(base);
    if (!_isAllDay) {
      time = await showTimePicker(context: context, initialTime: time);
      if (time == null || !mounted) return;
    }
    setState(() {
      final picked = DateTime(
        date.year,
        date.month,
        date.day,
        time!.hour,
        time.minute,
      );
      if (isStart) {
        final delta = _end.difference(_start);
        _start = picked;
        if (_end.isBefore(_start)) {
          _end = _start.add(
            delta.isNegative ? const Duration(hours: 1) : delta,
          );
        }
      } else {
        _end = picked.isBefore(_start)
            ? _start.add(const Duration(hours: 1))
            : picked;
      }
    });
  }

  Future<void> _pickRecurrenceEnd() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _recurrenceEnd ?? _start.add(const Duration(days: 30)),
      firstDate: _start,
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    setState(
      () => _recurrenceEnd = DateTime(
        date.year,
        date.month,
        date.day,
        23,
        59,
        59,
      ),
    );
  }

  void _addReminder() async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      builder: (_) => ListView(
        shrinkWrap: true,
        children: Reminder.presetsMinutes
            .map(
              (m) => ListTile(
                title: Text(Formatter.reminderLabel(m)),
                onTap: () => Navigator.of(context).pop(m),
              ),
            )
            .toList(),
      ),
    );
    if (selected == null) return;
    if (_reminders.any((r) => r.minutesBefore == selected)) return;
    setState(
      () => _reminders = [..._reminders, Reminder(minutesBefore: selected)],
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final now = DateTime.now().toUtc();
    final existing = widget.existing;
    final startUtc = _toUtc(_start);
    final endUtc = _toUtc(_end);

    final event = Event(
      id: existing?.id ?? _uuid.v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      startTimeUtc: startUtc,
      endTimeUtc: endUtc.isAfter(startUtc)
          ? endUtc
          : startUtc.add(const Duration(hours: 1)),
      timezone: _timezone,
      isAllDay: _isAllDay,
      recurrence: _recurrence,
      recurrenceEnd:
          _recurrence == RecurrenceType.none || _recurrenceEnd == null
          ? null
          : _toUtc(_recurrenceEnd!),
      reminders: _reminders,
      color: '0x${_colorValue.toRadixString(16).padLeft(8, '0').toUpperCase()}',
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      synced: false,
      nostrEventId: existing?.nostrEventId,
      syncOwnerPubkey: existing?.syncOwnerPubkey,
      createdAt: existing?.createdAt ?? now,
      // The notifier advances this at Nostr's whole-second resolution. Keep
      // the stored value when editing so an edit made before a prior synthetic
      // +1 second has elapsed can never move the replaceable event backwards.
      updatedAt: existing?.updatedAt ?? now,
    );

    try {
      await ref.read(eventsProvider.notifier).upsert(event);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save the event: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit event' : 'New event'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('All day'),
            value: _isAllDay,
            onChanged: (v) => setState(() => _isAllDay = v),
          ),
          _DateTimeRow(
            label: 'Starts',
            value: _isAllDay
                ? Formatter.dayLabel(_toUtc(_start), _timezone)
                : _stampLocal(_start),
            onTap: () => _pickDateTime(isStart: true),
          ),
          _DateTimeRow(
            label: 'Ends',
            value: _isAllDay
                ? Formatter.dayLabel(_toUtc(_end), _timezone)
                : _stampLocal(_end),
            onTap: () => _pickDateTime(isStart: false),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.public),
            title: const Text('Timezone'),
            subtitle: Text(_timezone),
            trailing: const Icon(Icons.chevron_right),
            // Picked from the IANA list, never typed: the times above are
            // interpreted in this zone, and an unrecognised name would silently
            // fall back to the device's (see [_toUtc]).
            onTap: () async {
              final zone = await showTimezonePicker(
                context,
                current: _timezone,
                allowFollowDevice: false,
              );
              if (zone == null || zone.isEmpty) return;
              setState(() => _timezone = zone);
            },
          ),
          const Divider(height: 32),
          DropdownButtonFormField<RecurrenceType>(
            initialValue: _recurrence,
            decoration: const InputDecoration(
              labelText: 'Repeats',
              border: OutlineInputBorder(),
            ),
            items: RecurrenceType.values
                .map(
                  (r) => DropdownMenuItem(
                    value: r,
                    child: Text(Formatter.recurrenceLabel(r)),
                  ),
                )
                .toList(),
            onChanged: (v) =>
                setState(() => _recurrence = v ?? RecurrenceType.none),
          ),
          if (_recurrence != RecurrenceType.none) ...[
            const SizedBox(height: 8),
            _DateTimeRow(
              label: 'Until',
              value: _recurrenceEnd == null
                  ? 'Forever'
                  : Formatter.dayLabel(_toUtc(_recurrenceEnd!), _timezone),
              onTap: _pickRecurrenceEnd,
              onClear: _recurrenceEnd == null
                  ? null
                  : () => setState(() => _recurrenceEnd = null),
            ),
          ],
          const Divider(height: 32),
          Text('Reminders', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._reminders.map(
                (r) => InputChip(
                  label: Text(Formatter.reminderLabel(r.minutesBefore)),
                  onDeleted: () => setState(
                    () => _reminders = _reminders.where((x) => x != r).toList(),
                  ),
                ),
              ),
              ActionChip(
                avatar: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                onPressed: _addReminder,
              ),
            ],
          ),
          const Divider(height: 32),
          Text('Color', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: kEventColorPalette.map((value) {
              final selected = value == _colorValue;
              return GestureDetector(
                onTap: () => setState(() => _colorValue = value),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Color(value),
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(
                            color: Theme.of(context).colorScheme.onSurface,
                            width: 3,
                          )
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Location',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _stampLocal(DateTime wall) =>
      Formatter.fullLabel(_toUtc(wall), _timezone);
}

class _DateTimeRow extends StatelessWidget {
  const _DateTimeRow({
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.schedule),
      title: Text(label),
      subtitle: Text(value),
      trailing: onClear == null
          ? const Icon(Icons.chevron_right)
          : IconButton(icon: const Icon(Icons.clear), onPressed: onClear),
      onTap: onTap,
    );
  }
}
