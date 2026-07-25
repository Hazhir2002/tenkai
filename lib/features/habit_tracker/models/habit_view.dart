import 'package:tenkai/core/database.dart';

import 'habit_enums.dart';

/// An immutable, UI-ready projection of a [Habit] row: the raw habit plus its
/// schedule slots, its derived state for today, and its stacked children
/// (habits cued "after" this one). Built by `habitGraphProvider`.
class HabitView {
  const HabitView({
    required this.habit,
    required this.schedules,
    required this.dayState,
    required this.nextOccurrence,
    required this.cueHabit,
    required this.children,
    required this.depth,
  });

  final Habit habit;
  final List<HabitSchedule> schedules;
  final HabitDayState dayState;

  /// The next scheduled occurrence (today or upcoming), if any — used for
  /// ordering and the "next" marker.
  final DateTime? nextOccurrence;

  /// The habit this one stacks onto, when [cueType] is `afterHabit`.
  final Habit? cueHabit;

  /// Habits stacked directly after this one.
  final List<HabitView> children;

  /// Indentation depth in the chain graph (roots = 0).
  final int depth;

  HabitStatus get status => HabitStatus.fromDb(habit.status);
  HabitCueType get cueType => HabitCueType.fromDb(habit.cueType);

  bool get isDoneToday => dayState == HabitDayState.doneToday;
  bool get isNext => dayState == HabitDayState.next;

  /// A short human description of this habit's cue for the node label.
  String cueDescription() {
    if (cueType == HabitCueType.afterHabit) {
      final name = cueHabit?.title;
      return name == null ? 'After a habit' : 'After $name';
    }
    if (schedules.isEmpty) return 'No schedule';
    final parts = schedules
        .map((s) => '${weekdayLabel(s.weekday)} ${formatHm(s.hour, s.minute)}')
        .toList();
    return parts.join(' · ');
  }
}
