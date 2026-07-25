import 'package:drift/drift.dart';

import 'habit.dart';

/// A record that a habit was completed. One row per completion; [dateKey]
/// ('yyyy-MM-dd') lets us cheaply look up "done today" and build streaks.
class HabitCompletions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId =>
      integer().references(Habits, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get completedAt =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get dateKey => text()();
}
