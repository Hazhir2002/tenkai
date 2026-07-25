import 'package:drift/drift.dart';

import 'habit.dart';

/// One slot of a time-cued habit's dynamic routine, e.g. "Friday 08:00".
/// A habit can have many slots. [weekday] null means "every day" (daily).
class HabitSchedules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId =>
      integer().references(Habits, #id, onDelete: KeyAction.cascade)();

  /// 1..7 (Mon..Sun); NULL = every day.
  IntColumn get weekday => integer().nullable()();
  IntColumn get hour => integer()();
  IntColumn get minute => integer()();
}
