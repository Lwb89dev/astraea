import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../l10n/app_localizations.dart';
import '../models/event_model.dart';
import '../providers/auth_provider.dart';
import '../providers/calendar_view_provider.dart';
import '../providers/events_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/sync_provider.dart';
import '../utils/app_accent.dart';
import '../utils/event_color.dart';
import '../utils/formatter.dart';
import '../utils/recurrence.dart';
import 'event_details_screen.dart';
import 'event_editor_screen.dart';
import 'settings_screen.dart';

/// The home screen: month / week / day / list views over the same events,
/// switchable from a segmented control. Tapping a day selects it; tapping an
/// occurrence opens its details; the FAB creates a new event on the selected
/// day.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  @override
  void initState() {
    super.initState();
    // Local-key sessions can synchronize unobtrusively on app open. Amber is
    // intentionally excluded: decrypting a calendar may require signer UI and
    // should only happen after an explicit tap.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = ref.read(authProvider).value;
      if (user?.loginMethod.isLocalKey == true) {
        ref.read(syncProvider.notifier).syncNow();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final view = ref.watch(calendarViewProvider);
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          _SyncButton(),
          IconButton(
            tooltip: l10n.settingsTooltip,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref, view.selectedDay),
        icon: const Icon(Icons.add),
        label: Text(l10n.newEventButton),
      ),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            l10n.couldNotLoadEvents(e.toString()),
            textAlign: TextAlign.center,
          ),
        ),
        data: (events) => Column(
          children: [
            _ViewModeSelector(mode: view.mode),
            const Divider(height: 1),
            Expanded(child: _body(context, ref, view, events)),
          ],
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    CalendarViewState view,
    List<Event> events,
  ) {
    switch (view.mode) {
      case CalendarViewMode.month:
      case CalendarViewMode.week:
        return _CalendarWithAgenda(view: view, events: events);
      case CalendarViewMode.day:
        return _DayAgenda(day: view.selectedDay, events: events);
      case CalendarViewMode.list:
        return _UpcomingList(events: events);
    }
  }

  static void _openEditor(BuildContext context, WidgetRef ref, DateTime day) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EventEditorScreen(initialDay: day)),
    );
  }
}

// ── View-mode segmented control ────────────────────────────────────────────

class _ViewModeSelector extends ConsumerWidget {
  const _ViewModeSelector({required this.mode});

  final CalendarViewMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 480;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SegmentedButton<CalendarViewMode>(
            expandedInsets: EdgeInsets.zero,
            segments: [
              ButtonSegment(
                value: CalendarViewMode.month,
                icon: const Icon(Icons.calendar_view_month),
                label: compact ? null : Text(l10n.viewMonth),
                tooltip: l10n.viewMonth,
              ),
              ButtonSegment(
                value: CalendarViewMode.week,
                icon: const Icon(Icons.calendar_view_week),
                label: compact ? null : Text(l10n.viewWeek),
                tooltip: l10n.viewWeek,
              ),
              ButtonSegment(
                value: CalendarViewMode.day,
                icon: const Icon(Icons.calendar_view_day),
                label: compact ? null : Text(l10n.viewDay),
                tooltip: l10n.viewDay,
              ),
              ButtonSegment(
                value: CalendarViewMode.list,
                icon: const Icon(Icons.view_agenda_outlined),
                label: compact ? null : Text(l10n.viewList),
                tooltip: l10n.viewList,
              ),
            ],
            selected: {mode},
            showSelectedIcon: false,
            onSelectionChanged: (s) =>
                ref.read(calendarViewProvider.notifier).setMode(s.first),
          ),
        );
      },
    );
  }
}

// ── Month/week calendar + selected-day agenda ──────────────────────────────

class _CalendarWithAgenda extends ConsumerWidget {
  const _CalendarWithAgenda({required this.view, required this.events});

  final CalendarViewState view;
  final List<Event> events;

  Map<(int, int, int), List<EventOccurrence>> _visibleOccurrences() {
    final focused = view.focusedDay;
    final DateTime rangeStart;
    final DateTime rangeEnd;
    if (view.mode == CalendarViewMode.week) {
      final day = DateTime(focused.year, focused.month, focused.day);
      rangeStart = day.subtract(Duration(days: day.weekday % 7));
      rangeEnd = DateTime(
        rangeStart.year,
        rangeStart.month,
        rangeStart.day + 7,
      );
    } else {
      final first = DateTime(focused.year, focused.month);
      rangeStart = first.subtract(Duration(days: first.weekday % 7));
      // Six complete calendar rows cover every month layout TableCalendar can
      // request, including leading and trailing days from adjacent months.
      rangeEnd = DateTime(
        rangeStart.year,
        rangeStart.month,
        rangeStart.day + 42,
      );
    }

    final byDay = <(int, int, int), List<EventOccurrence>>{};
    for (final occurrence in RecurrenceExpander.expandAll(
      events,
      rangeStartUtc: rangeStart.toUtc(),
      rangeEndUtc: rangeEnd.toUtc(),
    )) {
      // A multi-day occurrence belongs on every calendar day it touches, not
      // just the one it starts on — otherwise the month grid can only ever
      // mark its first day, however long the event runs.
      final startDay = _localDay(occurrence.startUtc);
      var lastDay = _lastTouchedLocalDay(occurrence);
      // A zero-duration occurrence (start == end — the Astraea/Kairos
      // integration mirrors a task's due instant this way) makes end-1ms's
      // calendar day fall *before* start's whenever that instant lands
      // exactly on a local midnight, which would otherwise make the
      // occurrence occupy zero days and vanish from the grid entirely. An
      // occurrence always touches at least the day it starts on.
      if (lastDay.isBefore(startDay)) lastDay = startDay;

      var day = startDay;
      if (day.isBefore(rangeStart)) day = rangeStart;
      final cappedLastDay = lastDay.isAfter(rangeEnd)
          ? rangeEnd.subtract(const Duration(days: 1))
          : lastDay;
      while (!day.isAfter(cappedLastDay)) {
        byDay
            .putIfAbsent((day.year, day.month, day.day), () => [])
            .add(occurrence);
        day = day.add(const Duration(days: 1));
      }
    }
    return byDay;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(calendarViewProvider.notifier);
    final occurrences = _visibleOccurrences();
    final accent = AppAccent.fromPrefsValue(
      ref.watch(settingsProvider).value?.accent,
    );
    return Column(
      children: [
        TableCalendar<EventOccurrence>(
          firstDay: DateTime.utc(2000, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: view.focusedDay,
          calendarFormat: view.mode == CalendarViewMode.week
              ? CalendarFormat.week
              : CalendarFormat.month,
          availableGestures: AvailableGestures.horizontalSwipe,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          selectedDayPredicate: (day) => isSameDay(day, view.selectedDay),
          // The visible recurrence window is expanded once per rebuild rather
          // than once for every one of the calendar's 42 day cells.
          eventLoader: (day) =>
              occurrences[(day.year, day.month, day.day)] ?? const [],
          onDaySelected: (selected, focused) =>
              notifier.selectDay(selected, focusedDay: focused),
          onPageChanged: notifier.setFocusedDay,
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: accent.dayBackground,
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(color: accent.onIndicator),
            selectedDecoration: BoxDecoration(
              color: accent.indicator,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: TextStyle(color: accent.onIndicator),
          ),
          calendarBuilders: const CalendarBuilders<EventOccurrence>(
            markerBuilder: _buildDayMarkers,
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _DayAgenda(day: view.selectedDay, events: events),
        ),
      ],
    );
  }
}

/// Midnight, local time, for [utc] converted to local — the calendar day it
/// falls on.
DateTime _localDay(DateTime utc) {
  final local = utc.toLocal();
  return DateTime(local.year, local.month, local.day);
}

/// Whether [occurrence] fits entirely within one calendar day — the line
/// between "gets a dot" and "gets a continuous bar" in the month grid.
bool _isMultiDayOccurrence(EventOccurrence occurrence) {
  final lastTouchedDay = _lastTouchedLocalDay(occurrence);
  return lastTouchedDay.isAfter(_localDay(occurrence.startUtc));
}

/// Returns the last local calendar day touched by an occurrence. A point
/// occurrence (the representation used by Kairos tasks) touches its start day
/// even though there is no positive-width interval to subtract from.
DateTime _lastTouchedLocalDay(EventOccurrence occurrence) => _localDay(
  occurrence.isPoint
      ? occurrence.startUtc
      : occurrence.endUtc.subtract(const Duration(milliseconds: 1)),
);

/// Custom month-grid marker (see `eventLoader`/`_visibleOccurrences` above,
/// which spans a multi-day occurrence across every day it covers): a
/// multi-day event draws as a continuous bar rather than a single dot,
/// flush with the cell edges so consecutive days' segments visually
/// connect, rounded only where the event actually starts or ends. Capped at
/// 2 bars plus a row of dots for same-day events, so a busy cell never
/// overflows.
Widget? _buildDayMarkers(
  BuildContext context,
  DateTime day,
  List<EventOccurrence> events,
) {
  if (events.isEmpty) return null;
  final multiDay = events.where(_isMultiDayOccurrence).take(2).toList();
  final singleDay = events.where((o) => !_isMultiDayOccurrence(o)).toList();

  final rows = <Widget>[
    for (final occurrence in multiDay)
      _MultiDayBar(day: day, occurrence: occurrence),
    if (singleDay.isNotEmpty && multiDay.length < 2)
      _SingleDayDots(occurrences: singleDay, maxCount: 3 - multiDay.length),
  ];
  if (rows.isEmpty) return null;

  return Positioned(
    left: 0,
    right: 0,
    bottom: 3,
    child: Column(mainAxisSize: MainAxisSize.min, children: rows),
  );
}

/// One segment of a multi-day event's bar for [day]. Deliberately unmargined
/// on any side that isn't the event's true start/end, so the segments in
/// consecutive day cells sit flush and read as one continuous line.
class _MultiDayBar extends StatelessWidget {
  const _MultiDayBar({required this.day, required this.occurrence});

  final DateTime day;
  final EventOccurrence occurrence;

  @override
  Widget build(BuildContext context) {
    final isFirstDay = isSameDay(_localDay(occurrence.startUtc), day);
    final isLastDay = isSameDay(
      _localDay(occurrence.endUtc.subtract(const Duration(milliseconds: 1))),
      day,
    );
    const cap = Radius.circular(3);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Container(
        height: 5,
        margin: EdgeInsets.only(
          left: isFirstDay ? 3 : 0,
          right: isLastDay ? 3 : 0,
        ),
        decoration: BoxDecoration(
          color: parseEventColor(occurrence.event.color),
          borderRadius: BorderRadius.horizontal(
            left: isFirstDay ? cap : Radius.zero,
            right: isLastDay ? cap : Radius.zero,
          ),
        ),
      ),
    );
  }
}

class _SingleDayDots extends StatelessWidget {
  const _SingleDayDots({required this.occurrences, required this.maxCount});

  final List<EventOccurrence> occurrences;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final occurrence in occurrences.take(maxCount))
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: parseEventColor(occurrence.event.color),
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}

// ── A single day's list of occurrences ─────────────────────────────────────

class _DayAgenda extends StatelessWidget {
  const _DayAgenda({required this.day, required this.events});

  final DateTime day;
  final List<Event> events;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final start = DateTime(day.year, day.month, day.day);
    final occurrences = RecurrenceExpander.expandAll(
      events,
      rangeStartUtc: start.toUtc(),
      // Construct the next wall-clock midnight instead of adding 24 hours;
      // a DST transition can make a local calendar day 23 or 25 hours long.
      rangeEndUtc: DateTime(start.year, start.month, start.day + 1).toUtc(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            Formatter.dayLabelLocal(start),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: occurrences.isEmpty
              ? _EmptyState(message: l10n.noEventsToday)
              : ListView.builder(
                  itemCount: occurrences.length,
                  itemBuilder: (_, i) =>
                      _OccurrenceTile(occurrence: occurrences[i]),
                ),
        ),
      ],
    );
  }
}

// ── Upcoming agenda (list view) ────────────────────────────────────────────

class _UpcomingList extends StatelessWidget {
  const _UpcomingList({required this.events});

  final List<Event> events;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, now.day);
    final to = DateTime(from.year, from.month, from.day + 60);
    final occurrences = RecurrenceExpander.expandAll(
      events,
      rangeStartUtc: from.toUtc(),
      rangeEndUtc: to.toUtc(),
    );

    if (occurrences.isEmpty) {
      return _EmptyState(message: l10n.noUpcomingEvents);
    }

    // Group by local day for section headers.
    final byDay = <String, List<EventOccurrence>>{};
    for (final occ in occurrences) {
      final local = occ.startUtc.toLocal();
      final key = '${local.year}-${local.month}-${local.day}';
      byDay.putIfAbsent(key, () => []).add(occ);
    }

    final sections = byDay.values.toList();
    return ListView.builder(
      itemCount: sections.length,
      itemBuilder: (context, i) {
        final section = sections[i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                // Local, matching the grouping above — labelling with the
                // event's own timezone could name a different day than the
                // section the event was grouped into.
                Formatter.dayLabelLocal(section.first.startUtc.toLocal()),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            ...section.map((occ) => _OccurrenceTile(occurrence: occ)),
          ],
        );
      },
    );
  }
}

// ── Shared occurrence tile ─────────────────────────────────────────────────

class _OccurrenceTile extends StatelessWidget {
  const _OccurrenceTile({required this.occurrence});

  final EventOccurrence occurrence;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final event = occurrence.event;
    return ListTile(
      leading: Container(
        width: 6,
        height: 40,
        decoration: BoxDecoration(
          color: parseEventColor(event.color),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      title: Text(event.title.isEmpty ? l10n.untitledEvent : event.title),
      subtitle: Text(
        // Device-local times, consistent with the local day grouping (store
        // UTC, display local). The event's own timezone is authoring detail,
        // shown in the details screen.
        event.isAllDay
            ? l10n.allDay
            : '${Formatter.timeLabelLocal(occurrence.startUtc)}'
                  ' – ${Formatter.timeLabelLocal(occurrence.endUtc)}',
      ),
      trailing: occurrence.isRecurringInstance
          ? const Icon(Icons.repeat, size: 18)
          : null,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EventDetailsScreen(eventId: event.id),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _SyncButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sync = ref.watch(syncProvider);
    final user = ref.watch(authProvider).value;
    if (sync.status == SyncStatus.syncing) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return IconButton(
      tooltip: user == null
          ? l10n.addAccountToSyncTooltip
          : l10n.syncNowTooltip,
      icon: const Icon(Icons.sync),
      onPressed: user == null
          ? null
          : () => ref.read(syncProvider.notifier).syncNow(),
    );
  }
}
