import 'package:drift/drift.dart';

/// A habit the user is tracking. Built around the Atomic Habits idea that a new
/// habit is anchored to a *cue* — either "after I finish an existing habit"
/// (habit stacking, via [cueHabitId]) or "at a scheduled time" (see
/// `HabitSchedules`). [status] tracks the habit's lifecycle.
class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 64)();
  TextColumn get description => text().nullable()();

  /// established | building | planned
  TextColumn get status => text().withDefault(const Constant('building'))();

  /// time | afterHabit
  TextColumn get cueType => text().withDefault(const Constant('time'))();

  /// When [cueType] is `afterHabit`, the habit this one stacks onto.
  IntColumn get cueHabitId =>
      integer().nullable().references(Habits, #id, onDelete: KeyAction.setNull)();

  BoolColumn get reminderEnabled =>
      boolean().withDefault(const Constant(true))();

  /// Delay (minutes) before reminding once the cue habit is completed.
  IntColumn get reminderOffsetMinutes =>
      integer().withDefault(const Constant(0))();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
