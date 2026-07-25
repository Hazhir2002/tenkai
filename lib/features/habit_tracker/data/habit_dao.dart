import 'package:drift/drift.dart';
import 'package:tenkai/core/database.dart';

import 'tables/habit.dart';
import 'tables/habit_completion.dart';
import 'tables/habit_schedule.dart';

part 'habit_dao.g.dart';

/// Data access for the habit tracker feature.
@DriftAccessor(tables: [Habits, HabitSchedules, HabitCompletions])
class HabitDao extends DatabaseAccessor<AppDatabase> with _$HabitDaoMixin {
  HabitDao(super.db);

  Stream<List<Habit>> watchAllHabits() => (select(habits)..orderBy([
    (t) => OrderingTerm.asc(t.sortOrder),
    (t) => OrderingTerm.asc(t.createdAt),
  ])).watch();

  Future<List<Habit>> getAllHabits() => (select(habits)..orderBy([
    (t) => OrderingTerm.asc(t.sortOrder),
    (t) => OrderingTerm.asc(t.createdAt),
  ])).get();

  Future<Habit?> getHabit(int id) =>
      (select(habits)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<List<HabitSchedule>> watchAllSchedules() =>
      select(habitSchedules).watch();

  Future<List<HabitSchedule>> getSchedulesFor(int habitId) =>
      (select(habitSchedules)..where((t) => t.habitId.equals(habitId))).get();

  Stream<List<HabitCompletion>> watchCompletionsForDate(String dateKey) =>
      (select(habitCompletions)..where((t) => t.dateKey.equals(dateKey)))
          .watch();

  Future<bool> isDoneToday(int habitId, String dateKey) async {
    final row = await (select(habitCompletions)..where(
      (t) => t.habitId.equals(habitId) & t.dateKey.equals(dateKey),
    )).getSingleOrNull();
    return row != null;
  }

  /// Creates a habit and (optionally) its schedule slots in one transaction,
  /// returning the new habit id.
  Future<int> createHabit({
    required String title,
    String? description,
    required String status,
    required String cueType,
    int? cueHabitId,
    bool reminderEnabled = true,
    int reminderOffsetMinutes = 0,
    List<HabitSchedulesCompanion> schedules = const [],
  }) {
    return transaction(() async {
      final id = await into(habits).insert(
        HabitsCompanion.insert(
          title: title,
          description: Value(description),
          status: Value(status),
          cueType: Value(cueType),
          cueHabitId: Value(cueHabitId),
          reminderEnabled: Value(reminderEnabled),
          reminderOffsetMinutes: Value(reminderOffsetMinutes),
        ),
      );
      for (final s in schedules) {
        await into(habitSchedules).insert(s.copyWith(habitId: Value(id)));
      }
      return id;
    });
  }

  Future<void> updateHabit(Habit habit) {
    return update(habits).replace(habit.copyWith(updatedAt: DateTime.now()));
  }

  /// Replaces all of a habit's schedule slots (delete-then-insert).
  Future<void> replaceSchedules(
    int habitId,
    List<HabitSchedulesCompanion> schedules,
  ) {
    return transaction(() async {
      await (delete(habitSchedules)
        ..where((t) => t.habitId.equals(habitId))).go();
      for (final s in schedules) {
        await into(habitSchedules).insert(s.copyWith(habitId: Value(habitId)));
      }
    });
  }

  Future<int> deleteHabit(int id) =>
      (delete(habits)..where((t) => t.id.equals(id))).go();

  Future<void> markHabitDone(int habitId, String dateKey) async {
    final already = await isDoneToday(habitId, dateKey);
    if (already) return;
    await into(habitCompletions).insert(
      HabitCompletionsCompanion.insert(habitId: habitId, dateKey: dateKey),
    );
  }

  Future<void> unmarkHabitDone(int habitId, String dateKey) {
    return (delete(habitCompletions)..where(
      (t) => t.habitId.equals(habitId) & t.dateKey.equals(dateKey),
    )).go();
  }
}
