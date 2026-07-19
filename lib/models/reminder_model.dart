/// A single local reminder attached to an [Event]: "notify me N minutes
/// before the event starts".
///
/// Reminders are OS-scheduled at event create/edit time via
/// [NotificationService.scheduleForEvent] using
/// `flutter_local_notifications`' `zonedSchedule()` — there is no polling.
/// The concrete fire instant is derived from the event's start time in its
/// timezone minus [minutesBefore] (see [NotificationService]).
class Reminder {
  /// How many minutes before the event's start the notification fires.
  /// Presets in the UI: 15 (min), 60 (1 hour); any custom value is allowed.
  final int minutesBefore;

  const Reminder({required this.minutesBefore});

  /// Common presets surfaced in the event editor.
  static const List<int> presetsMinutes = [0, 5, 15, 30, 60, 120, 1440];

  Reminder copyWith({int? minutesBefore}) =>
      Reminder(minutesBefore: minutesBefore ?? this.minutesBefore);

  Map<String, dynamic> toJson() => {'minutesBefore': minutesBefore};

  factory Reminder.fromJson(Map<String, dynamic> json) =>
      Reminder(minutesBefore: (json['minutesBefore'] as num).toInt());

  @override
  bool operator ==(Object other) =>
      other is Reminder && other.minutesBefore == minutesBefore;

  @override
  int get hashCode => minutesBefore.hashCode;
}
