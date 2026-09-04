import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../l10n/app_localizations.dart';
import '../models/event_model.dart';
import '../providers/auth_provider.dart';
import '../providers/calendar_view_provider.dart';
import '../providers/events_provider.dart';
import '../providers/sync_provider.dart';
import '../utils/event_color.dart';
import '../utils/formatter.dart';
import '../utils/recurrence.dart';
import 'event_details_screen.dart';
import 'event_editor_screen.dart';
import 'settings_screen.dart';
import '../widgets/astraea_ui.dart';

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
    // Force a sync as soon as the calendar is on screen, so what the user sees
    // is already reconciled with the relays. [SyncNotifier.syncOnStartup]
    // latches itself, so coming back to this screen later does not re-trigger
    // it, and it decides on its own which session types can sync silently.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(ref.read(syncProvider.notifier).syncOnStartup());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final view = ref.watch(calendarViewProvider);
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          _SyncButton(),
          AstraeaIconButton(
            tooltip: l10n.settingsTooltip,
            icon: Icons.tune_rounded,
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          const SizedBox(width: AstraeaTokens.space3),
        ],
      ),
      floatingActionButton: _NewEventButton(
        label: l10n.newEventButton,
        onPressed: () => _openEditor(context, ref, view.selectedDay),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: _ViewNavigationBar(mode: view.mode),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceContainerLowest,
            ],
          ),
        ),
        child: eventsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              l10n.couldNotLoadEvents(e.toString()),
              textAlign: TextAlign.center,
            ),
          ),
          data: (events) => _body(context, ref, view, events),
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
        return _CalendarWithAgenda(view: view, events: events);
      case CalendarViewMode.week:
        return _WeekTimeline(view: view, events: events);
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

class _ViewNavigationBar extends ConsumerWidget {
  const _ViewNavigationBar({required this.mode});

  final CalendarViewMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final labels = [l10n.viewMonth, l10n.viewWeek, l10n.viewDay, l10n.viewList];
    final icons = [
      Icons.calendar_month_rounded,
      Icons.view_week_rounded,
      Icons.today_rounded,
      Icons.inbox_rounded,
    ];
    return AstraeaFloatingBar(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: CalendarViewMode.values.map((item) {
          final selected = item == mode;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(AstraeaTokens.radiusMd),
              onTap: () =>
                  ref.read(calendarViewProvider.notifier).setMode(item),
              child: AnimatedContainer(
                duration: AstraeaTokens.motion(
                  context,
                  AstraeaTokens.shortMotion,
                ),
                curve: AstraeaTokens.motionCurve,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.14)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AstraeaTokens.radiusMd),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icons[item.index],
                      size: 19,
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      labels[item.index],
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NewEventButton extends StatelessWidget {
  const _NewEventButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 78, right: 4),
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add_rounded),
        label: Text(label),
        style: FilledButton.styleFrom(
          elevation: 8,
          shadowColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.35),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AstraeaTokens.radiusLg),
          ),
        ),
      ),
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
    return Column(
      children: [
        _CalendarHeader(
          focusedDay: view.focusedDay,
          onToday: () => notifier.selectDay(DateTime.now()),
        ),
        TableCalendar<EventOccurrence>(
          firstDay: DateTime.utc(2000, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: view.focusedDay,
          calendarFormat: CalendarFormat.month,
          availableGestures: AvailableGestures.horizontalSwipe,
          headerVisible: false,
          selectedDayPredicate: (day) => isSameDay(day, view.selectedDay),
          // The visible recurrence window is expanded once per rebuild rather
          // than once for every one of the calendar's 42 day cells.
          eventLoader: (day) =>
              occurrences[(day.year, day.month, day.day)] ?? const [],
          onDaySelected: (selected, focused) =>
              notifier.selectDay(selected, focusedDay: focused),
          onPageChanged: notifier.setFocusedDay,
          calendarStyle: const CalendarStyle(
            cellMargin: EdgeInsets.symmetric(vertical: 5),
            outsideDaysVisible: true,
            markersMaxCount: 3,
            markerSize: 5,
            markerMargin: EdgeInsets.symmetric(horizontal: 1),
          ),
          calendarBuilders: CalendarBuilders<EventOccurrence>(
            markerBuilder: _buildDayMarkers,
            defaultBuilder: (context, day, focusedDay) =>
                _CalendarDayCell(day: day),
            outsideBuilder: (context, day, focusedDay) =>
                _CalendarDayCell(day: day, outside: true),
            todayBuilder: (context, day, focusedDay) =>
                _CalendarDayCell(day: day, today: true),
            selectedBuilder: (context, day, focusedDay) =>
                _CalendarDayCell(day: day, selected: true),
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

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({required this.focusedDay, required this.onToday});

  final DateTime focusedDay;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMMM').format(focusedDay),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  '${focusedDay.year}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onToday,
            icon: const Icon(Icons.my_location_rounded, size: 16),
            label: const Text('Today'),
          ),
        ],
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.day,
    this.selected = false,
    this.today = false,
    this.outside = false,
  });

  final DateTime day;
  final bool selected;
  final bool today;
  final bool outside;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final weekend = day.weekday >= DateTime.saturday;
    final foreground = selected
        ? scheme.onPrimary
        : outside
        ? scheme.onSurface.withValues(alpha: 0.28)
        : weekend
        ? scheme.primary.withValues(alpha: 0.82)
        : scheme.onSurface;
    return Center(
      child: AnimatedContainer(
        duration: AstraeaTokens.motion(context, AstraeaTokens.shortMotion),
        curve: AstraeaTokens.motionCurve,
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary
              : today
              ? scheme.primary.withValues(alpha: 0.13)
              : weekend
              ? scheme.primary.withValues(alpha: 0.035)
              : Colors.transparent,
          shape: BoxShape.circle,
          border: today && !selected
              ? Border.all(color: scheme.primary, width: 1.5)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          '${day.day}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: foreground,
            fontWeight: selected || today ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _WeekTimeline extends ConsumerWidget {
  const _WeekTimeline({required this.view, required this.events});

  final CalendarViewState view;
  final List<Event> events;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = DateTime(
      view.selectedDay.year,
      view.selectedDay.month,
      view.selectedDay.day,
    );
    final weekStart = selected.subtract(Duration(days: selected.weekday % 7));
    final occurrences = RecurrenceExpander.expandAll(
      events,
      rangeStartUtc: weekStart.toUtc(),
      rangeEndUtc: weekStart.add(const Duration(days: 7)).toUtc(),
    );
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.viewWeek,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Text(
                DateFormat('MMM yyyy').format(selected),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: AstraeaGlassSurface(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            radius: AstraeaTokens.radiusMd,
            shadow: false,
            child: Row(
              children: List.generate(7, (index) {
                final day = weekStart.add(Duration(days: index));
                final active = isSameDay(day, selected);
                final hasEvents = occurrences.any(
                  (o) => isSameDay(o.startUtc.toLocal(), day),
                );
                return Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AstraeaTokens.radiusSm),
                    onTap: () =>
                        ref.read(calendarViewProvider.notifier).selectDay(day),
                    child: AnimatedContainer(
                      duration: AstraeaTokens.motion(
                        context,
                        AstraeaTokens.shortMotion,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: active
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(
                          AstraeaTokens.radiusSm,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            DateFormat(
                              'EEE',
                            ).format(day).substring(0, 2).toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: active
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${day.day}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: active
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 3),
                          AnimatedContainer(
                            duration: AstraeaTokens.motion(
                              context,
                              AstraeaTokens.shortMotion,
                            ),
                            width: hasEvents ? 5 : 3,
                            height: hasEvents ? 5 : 3,
                            decoration: BoxDecoration(
                              color: active
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.primary.withValues(
                                      alpha: hasEvents ? 1 : 0.18,
                                    ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _Timeline(day: selected, occurrences: occurrences),
        ),
      ],
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.day, required this.occurrences});

  final DateTime day;
  final List<EventOccurrence> occurrences;

  @override
  Widget build(BuildContext context) {
    final dayOccurrences = occurrences.where((o) {
      final startDay = _localDay(o.startUtc);
      final endDay = _lastTouchedLocalDay(o);
      return !day.isBefore(startDay) && !day.isAfter(endDay);
    }).toList();
    final now = DateTime.now();
    final today = isSameDay(now, day);
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: 24,
      itemBuilder: (context, hour) {
        final matches = dayOccurrences.where((o) {
          final startsBeforeThisDay = _localDay(o.startUtc).isBefore(day);
          return o.event.isAllDay || startsBeforeThisDay
              ? hour == 0
              : o.startUtc.toLocal().hour == hour;
        }).toList();
        final current = today && now.hour == hour;
        return SizedBox(
          height: matches.isEmpty
              ? 62
              : (matches.length * 58).clamp(62, 150).toDouble(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 62,
                child: Padding(
                  padding: const EdgeInsets.only(top: 3, right: 10),
                  child: Text(
                    hour == 0
                        ? '12 AM'
                        : DateFormat(
                            'HH:00',
                          ).format(DateTime(2020, 1, 1, hour)),
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned(
                      top: 10,
                      left: 0,
                      right: 14,
                      child: Divider(
                        color: Theme.of(
                          context,
                        ).colorScheme.outlineVariant.withValues(alpha: 0.55),
                      ),
                    ),
                    if (current)
                      Positioned(
                        top: 8,
                        left: -3,
                        right: 14,
                        child: Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Theme.of(context).colorScheme.error,
                                thickness: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (matches.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 18, right: 14),
                        child: Column(
                          children: matches
                              .map(
                                (occurrence) =>
                                    _TimelineEvent(occurrence: occurrence),
                              )
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TimelineEvent extends StatelessWidget {
  const _TimelineEvent({required this.occurrence});

  final EventOccurrence occurrence;

  @override
  Widget build(BuildContext context) {
    final event = occurrence.event;
    final color = parseEventColor(event.color);
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(AstraeaTokens.radiusSm),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EventDetailsScreen(eventId: event.id),
          ),
        ),
        child: Container(
          constraints: const BoxConstraints(minHeight: 42),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(AstraeaTokens.radiusSm),
            border: Border(left: BorderSide(color: color, width: 4)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  event.title.isEmpty ? l10n.untitledEvent : event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (!event.isAllDay)
                Text(
                  Formatter.timeLabelLocal(occurrence.startUtc),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
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
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  Formatter.dayLabelLocal(start),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Text(
                DateFormat('d').format(start),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.35),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: occurrences.isEmpty
              ? _EmptyState(message: l10n.noEventsToday)
              : _Timeline(day: start, occurrences: occurrences),
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
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
      itemCount: sections.length,
      itemBuilder: (context, i) {
        final section = sections[i];
        final localDay = section.first.startUtc.toLocal();
        final isToday = isSameDay(localDay, DateTime.now());
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 22, bottom: 8),
              child: Row(
                children: [
                  Text(
                    DateFormat('EEE').format(localDay).toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('d MMM').format(localDay),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
              /* child: Text(
                // Local, matching the grouping above — labelling with the
                // event's own timezone could name a different day than the
                // section the event was grouped into.
                Formatter.dayLabelLocal(section.first.startUtc.toLocal()),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ), */
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
    final color = parseEventColor(event.color);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AstraeaGlassSurface(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        radius: AstraeaTokens.radiusSm,
        blur: 6,
        shadow: false,
        child: InkWell(
          borderRadius: BorderRadius.circular(AstraeaTokens.radiusSm),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EventDetailsScreen(eventId: event.id),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 42,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title.isEmpty ? l10n.untitledEvent : event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.isAllDay
                          ? l10n.allDay
                          : '${Formatter.timeLabelLocal(occurrence.startUtc)} – ${Formatter.timeLabelLocal(occurrence.endUtc)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (occurrence.isRecurringInstance)
                Icon(
                  Icons.repeat_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
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
