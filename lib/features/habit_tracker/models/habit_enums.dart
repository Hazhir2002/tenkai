/// Lifecycle stage of a habit. Stored in the DB as the [dbValue] string.
///
/// - [established]: a habit that is already part of the user's life.
/// - [building]: a habit actively being formed right now.
/// - [planned]: a habit the user intends to build later.
enum HabitStatus {
  established('established'),
  building('building'),
  planned('planned');

  const HabitStatus(this.dbValue);

  final String dbValue;

  static HabitStatus fromDb(String value) => HabitStatus.values.firstWhere(
    (s) => s.dbValue == value,
    orElse: () => HabitStatus.building,
  );

  String get label => switch (this) {
    HabitStatus.established => 'Established',
    HabitStatus.building => 'Building',
    HabitStatus.planned => 'Planned',
  };
}

/// What triggers a habit (Atomic Habits "cue").
///
/// - [time]: fires on a schedule (see `HabitSchedules`).
/// - [afterHabit]: stacks onto another habit — do it after finishing that one.
enum HabitCueType {
  time('time'),
  afterHabit('afterHabit');

  const HabitCueType(this.dbValue);

  final String dbValue;

  static HabitCueType fromDb(String value) => HabitCueType.values.firstWhere(
    (c) => c.dbValue == value,
    orElse: () => HabitCueType.time,
  );

  String get label => switch (this) {
    HabitCueType.time => 'At a time',
    HabitCueType.afterHabit => 'After a habit',
  };
}

/// The habit's derived state *for today*, used to style graph nodes. Ordered
/// loosely from "most active" to "least active".
enum HabitDayState {
  /// Completed today.
  doneToday,

  /// The single next habit the user should act on today.
  next,

  /// Scheduled for today and still pending.
  pendingToday,

  /// An active habit, but not scheduled for today (or after-cue only).
  notScheduledToday,

  /// Status is `building` and has no bearing on today.
  building,

  /// Status is `planned` — a future intention, shown dim.
  planned,
}

/// Short weekday labels indexed by ISO weekday (1 = Mon .. 7 = Sun).
const List<String> kWeekdayLabels = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

/// Label for a weekday value as stored in `HabitSchedules.weekday`
/// (1..7, or null for daily).
String weekdayLabel(int? weekday) {
  if (weekday == null) return 'Daily';
  if (weekday < 1 || weekday > 7) return '?';
  return kWeekdayLabels[weekday - 1];
}

/// Formats an hour/minute pair as `HH:mm`.
String formatHm(int hour, int minute) {
  final h = hour.toString().padLeft(2, '0');
  final m = minute.toString().padLeft(2, '0');
  return '$h:$m';
}
