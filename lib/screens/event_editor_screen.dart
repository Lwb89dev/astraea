import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';

import '../desktop/desktop_invite_section_stub.dart'
    if (dart.library.io) '../desktop/desktop_invite_section.dart'
    as desktop_invite;
import '../l10n/app_localizations.dart';
import '../models/event_model.dart';
import '../models/event_place.dart';
import '../models/reminder_model.dart';
import '../providers/events_provider.dart';
import '../providers/service_providers.dart';
import '../providers/settings_provider.dart';
import '../services/geocoding_service.dart';
import '../utils/event_color.dart';
import '../utils/formatter.dart';
import 'widgets/place_location.dart';
import 'widgets/timezone_picker.dart';
import '../widgets/astraea_ui.dart';

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
  EventPlace? _place;
  String? _placeAnchor;
  bool _keepTextOnly = false;
  int _lookupGeneration = 0;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _titleController.text = e.title;
      _descriptionController.text = e.description;
      _locationController.text = e.location ?? '';
      _place = placeForLocation(
        location: e.location,
        resolvedAgainst: e.location,
        place: e.place,
      );
      _placeAnchor = _place == null ? null : e.location?.trim();
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
    _locationController.addListener(_onLocationChanged);
  }

  void _onLocationChanged() {
    final text = _locationController.text.trim();
    if (text.isNotEmpty && text == _placeAnchor) return;
    if (_place == null && !_keepTextOnly && _placeAnchor == null) return;
    setState(() {
      _place = null;
      _keepTextOnly = false;
      _placeAnchor = null;
    });
  }

  void _bindPlace(EventPlace? place, {required bool keepText}) {
    final text = _locationController.text.trim();
    setState(() {
      _place = place;
      _keepTextOnly = keepText && place == null;
      _placeAnchor = text.isEmpty ? null : text;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.removeListener(_onLocationChanged);
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
    final l10n = AppLocalizations.of(context);
    final selected = await showModalBottomSheet<int>(
      context: context,
      builder: (_) => ListView(
        shrinkWrap: true,
        children: Reminder.presetsMinutes
            .map(
              (m) => ListTile(
                title: Text(Formatter.reminderLabel(l10n, m)),
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

  String? get _locationText {
    final text = _locationController.text.trim();
    return text.isEmpty ? null : text;
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final prepared = await _preparePlace(_locationText);
    if (!mounted || prepared == null) {
      if (mounted) setState(() => _saving = false);
      return;
    }
    try {
      await ref.read(eventsProvider.notifier).upsert(_eventFromForm(prepared));
      if (!mounted) return;
      if (prepared.unresolved || prepared.offline) _tellUnresolved();
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.couldNotSaveEvent(error.toString()))),
      );
    }
  }

  Event _eventFromForm(_PreparedPlace prepared) {
    final now = DateTime.now().toUtc();
    final existing = widget.existing;
    final startUtc = _toUtc(_start);
    final endUtc = _toUtc(_end);
    return Event(
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
      location: _locationText,
      place: prepared.place,
      synced: false,
      nostrEventId: existing?.nostrEventId,
      syncOwnerPubkey: existing?.syncOwnerPubkey,
      createdAt: existing?.createdAt ?? now,
      // The notifier advances this at Nostr's whole-second resolution. Keep
      // the stored value when editing so an edit made before a prior synthetic
      // +1 second has elapsed can never move the replaceable event backwards.
      updatedAt: existing?.updatedAt ?? now,
    );
  }

  /// Null means the user dismissed the candidate sheet and the save stops.
  Future<_PreparedPlace?> _preparePlace(String? location) async {
    if (location == null) return const _PreparedPlace(null, unresolved: false);
    final anchored = placeForLocation(
      location: location,
      resolvedAgainst: _placeAnchor,
      place: _place,
    );
    if (anchored != null) return _PreparedPlace(anchored, unresolved: false);
    if (_keepTextOnly && location == _placeAnchor) {
      return const _PreparedPlace(null, unresolved: false);
    }
    final query = geocodingQuery(location);
    if (query == null) return const _PreparedPlace(null, unresolved: false);
    return _lookup(query);
  }

  Future<_PreparedPlace?> _lookup(String query) async {
    final generation = ++_lookupGeneration;
    final status = await ref.read(geocodingServiceProvider).search(query);
    if (!mounted || generation != _lookupGeneration) return null;
    return switch (status) {
      GeocodeUnavailable() => const _PreparedPlace(null, offline: true),
      GeocodeResults(:final results) => _fromDecision(
        query,
        results,
        generation,
      ),
    };
  }

  Future<_PreparedPlace?> _fromDecision(
    String query,
    List<PlaceSearchResult> results,
    int generation,
  ) async {
    final decision = decidePlaceMatch(query, results);
    if (decision.kind == PlaceDecisionKind.attach) {
      return _PreparedPlace(decision.place, unresolved: false);
    }
    if (decision.kind == PlaceDecisionKind.skip) {
      return const _PreparedPlace(null, unresolved: true);
    }
    final picked = await showPlacePicker(
      context: context,
      candidates: decision.candidates,
    );
    if (!mounted || generation != _lookupGeneration || picked == null) {
      return null;
    }
    if (picked.keepText) return const _PreparedPlace(null, unresolved: false);
    return _PreparedPlace(picked.place, unresolved: false);
  }

  Future<void> _resolveAgain() async {
    if (_saving) return;
    final query = geocodingQuery(_locationText);
    if (query == null) return;
    setState(() => _saving = true);
    final prepared = await _lookup(query);
    if (!mounted) return;
    setState(() => _saving = false);
    if (prepared == null || prepared.offline) return;
    if (prepared.unresolved) {
      _bindPlace(null, keepText: false);
      return;
    }
    _bindPlace(prepared.place, keepText: prepared.place == null);
  }

  void _tellUnresolved() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.placeSavedWithoutPosition)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEditing = widget.existing != null;
    final swatches = [
      if (!kEventColorPalette.contains(_colorValue)) _colorValue,
      ...kEventColorPalette,
    ];
    return AstraeaSheet(
      tint: Color(_colorValue),
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? l10n.editEventTitle : l10n.newEventTitle),
          actions: [
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AstraeaTokens.radiusLg),
                ),
              ),
              child: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.save),
            ),
          ],
        ),
        body: Builder(
          builder: (context) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
            children: [
              TextField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  hintText: l10n.fieldTitle,
                  filled: false,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              AstraeaSection(
                title: l10n.startsLabel,
                child: AstraeaGlassSurface(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  shadow: false,
                  child: Column(
                    children: [
                      _DateTimeRow(
                        label: l10n.startsLabel,
                        value: _isAllDay
                            ? Formatter.dayLabel(_toUtc(_start), _timezone)
                            : _stampLocal(_start),
                        onTap: () => _pickDateTime(isStart: true),
                      ),
                      const Divider(indent: 56, endIndent: 12),
                      _DateTimeRow(
                        label: l10n.endsLabel,
                        value: _isAllDay
                            ? Formatter.dayLabel(_toUtc(_end), _timezone)
                            : _stampLocal(_end),
                        onTap: () => _pickDateTime(isStart: false),
                      ),
                      const Divider(indent: 56, endIndent: 12),
                      SwitchListTile.adaptive(
                        contentPadding: const EdgeInsets.only(
                          left: 12,
                          right: 8,
                        ),
                        title: Text(l10n.allDaySwitch),
                        value: _isAllDay,
                        onChanged: (v) => setState(() => _isAllDay = v),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              AstraeaGlassSurface(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                shadow: false,
                child: ListTile(
                  leading: const Icon(Icons.public_rounded),
                  title: Text(l10n.timezoneLabel),
                  subtitle: Text(_timezone),
                  trailing: const Icon(Icons.chevron_right_rounded),
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
              ),
              const SizedBox(height: 18),
              AstraeaSection(
                title: l10n.repeatsLabel,
                child: AstraeaGlassSurface(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  shadow: false,
                  child: DropdownButtonFormField<RecurrenceType>(
                    initialValue: _recurrence,
                    decoration: InputDecoration(
                      labelText: l10n.repeatsLabel,
                      border: InputBorder.none,
                      filled: false,
                    ),
                    items: RecurrenceType.values
                        .map(
                          (r) => DropdownMenuItem(
                            value: r,
                            child: Text(Formatter.recurrenceLabel(l10n, r)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _recurrence = v ?? RecurrenceType.none),
                  ),
                ),
              ),
              if (_recurrence != RecurrenceType.none) ...[
                const SizedBox(height: 8),
                AstraeaGlassSurface(
                  shadow: false,
                  child: _DateTimeRow(
                    label: l10n.untilLabel,
                    value: _recurrenceEnd == null
                        ? l10n.foreverLabel
                        : Formatter.dayLabel(
                            _toUtc(_recurrenceEnd!),
                            _timezone,
                          ),
                    onTap: _pickRecurrenceEnd,
                    onClear: _recurrenceEnd == null
                        ? null
                        : () => setState(() => _recurrenceEnd = null),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              AstraeaSection(
                title: l10n.remindersLabel,
                child: AstraeaGlassSurface(
                  padding: const EdgeInsets.all(14),
                  shadow: false,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._reminders.map(
                        (r) => InputChip(
                          label: Text(
                            Formatter.reminderLabel(l10n, r.minutesBefore),
                          ),
                          onDeleted: () => setState(
                            () => _reminders = _reminders
                                .where((x) => x != r)
                                .toList(),
                          ),
                        ),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.add_rounded, size: 18),
                        label: Text(l10n.addChip),
                        onPressed: _addReminder,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              AstraeaSection(
                title: l10n.colorLabel,
                child: AstraeaGlassSurface(
                  padding: const EdgeInsets.all(16),
                  shadow: false,
                  child: Wrap(
                    spacing: 14,
                    children: swatches.map((value) {
                      final selected = value == _colorValue;
                      return Semantics(
                        label: l10n.colorLabel,
                        selected: selected,
                        button: true,
                        child: GestureDetector(
                          onTap: () => setState(() => _colorValue = value),
                          child: AnimatedContainer(
                            duration: AstraeaTokens.motion(
                              context,
                              AstraeaTokens.shortMotion,
                            ),
                            width: selected ? 38 : 32,
                            height: selected ? 38 : 32,
                            decoration: BoxDecoration(
                              color: Color(value),
                              shape: BoxShape.circle,
                              border: selected
                                  ? Border.all(
                                      color: readableTextColorOn(Color(value)),
                                      width: 3,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              AstraeaSection(
                title: l10n.locationLabel,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: l10n.locationLabel,
                        prefixIcon: const Icon(Icons.place_outlined),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.placePrivacyNotice,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (_anchoredPlace case final place?)
                      ResolvedPlaceSummary(
                        place: place,
                        onResolveAgain: _saving ? () {} : _resolveAgain,
                        onClear: _saving
                            ? () {}
                            : () => _bindPlace(null, keepText: true),
                      ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.descriptionLabel,
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        alignLabelWithHint: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 62),
                          child: Icon(Icons.notes_rounded),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.existing != null)
                desktop_invite.desktopInviteSection(widget.existing!.id) ??
                    const SizedBox.shrink(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _stampLocal(DateTime wall) =>
      Formatter.fullLabel(_toUtc(wall), _timezone);

  EventPlace? get _anchoredPlace {
    return placeForLocation(
      location: _locationText,
      resolvedAgainst: _placeAnchor,
      place: _place,
    );
  }
}

class _PreparedPlace {
  const _PreparedPlace(
    this.place, {
    this.unresolved = false,
    this.offline = false,
  });

  final EventPlace? place;
  final bool unresolved;
  final bool offline;
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
