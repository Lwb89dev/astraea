import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The three ways [CalendarScreen] can render the same events.
enum CalendarViewMode { month, week, day, list }

/// Ephemeral UI state for the calendar screen: which view is active, the
/// focused month (what the month grid pages to), and the selected day (drives
/// the day/list panels). Not persisted — it's view state, not user data.
class CalendarViewState {
  final CalendarViewMode mode;
  final DateTime focusedDay;
  final DateTime selectedDay;

  const CalendarViewState({
    required this.mode,
    required this.focusedDay,
    required this.selectedDay,
  });

  CalendarViewState copyWith({
    CalendarViewMode? mode,
    DateTime? focusedDay,
    DateTime? selectedDay,
  }) {
    return CalendarViewState(
      mode: mode ?? this.mode,
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
    );
  }
}

class CalendarViewNotifier extends Notifier<CalendarViewState> {
  @override
  CalendarViewState build() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return CalendarViewState(
      mode: CalendarViewMode.month,
      focusedDay: today,
      selectedDay: today,
    );
  }

  void setMode(CalendarViewMode mode) => state = state.copyWith(mode: mode);

  void selectDay(DateTime day, {DateTime? focusedDay}) {
    final normalized = DateTime(day.year, day.month, day.day);
    state = state.copyWith(
      selectedDay: normalized,
      focusedDay: focusedDay ?? day,
    );
  }

  void setFocusedDay(DateTime day) => state = state.copyWith(focusedDay: day);
}

final calendarViewProvider =
    NotifierProvider<CalendarViewNotifier, CalendarViewState>(
      CalendarViewNotifier.new,
    );
