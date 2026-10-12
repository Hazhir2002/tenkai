import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tenkai/features/fitness/data/fitness_dao.dart';
import 'package:tenkai/features/fitness/data/tables/program_session.dart';
import 'package:tenkai/features/fitness/data/tables/program.dart';
import 'package:tenkai/features/fitness/data/tables/session_exercise.dart';

import 'package:tenkai/features/habit_tracker/data/habit_dao.dart';
import 'package:tenkai/features/habit_tracker/data/tables/habit.dart';
import 'package:tenkai/features/habit_tracker/data/tables/habit_completion.dart';
import 'package:tenkai/features/habit_tracker/data/tables/habit_schedule.dart';
import 'package:tenkai/features/journal/data/journal_dao.dart';
import 'package:tenkai/features/journal/data/tables/journal_entries.dart';
import 'package:tenkai/features/knowledge/data/book_dao.dart';
import 'package:tenkai/features/knowledge/data/tables/book.dart';
import 'package:tenkai/features/knowledge/data/tables/book_highlight.dart';
import 'package:tenkai/features/knowledge/data/tables/reading_session.dart';
import 'package:tenkai/features/user/data/user_dao.dart';
import 'package:tenkai/features/user/data/tables/user_fear.dart';
import 'package:tenkai/features/user/data/tables/user_stat.dart';
import 'package:tenkai/features/user/models/user_fear_status.dart';
import 'package:flutter/material.dart' show TimeOfDay;

part 'database.g.dart';

/// The single app-wide Drift database. Tables live in their own files under
/// each feature's `data/tables/`, and each feature's queries live in its own
/// [DatabaseAccessor] DAO (see [ProfileDao], [JournalDao], [HabitDao]).
@DriftDatabase(
  tables: [
    UserStat,
    JournalEntries,
    Habits,
    HabitSchedules,
    HabitCompletions,
    Books,
    ReadingSessions,
    BookHighlights,
    UserFear,
    Programs,
    ProgramSessions,
    SessionExercises,
  ],
  daos: [UserDao, JournalDao, HabitDao, BookDao, FitnessDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 3) {
        await m.dropColumn(sessionExercises, 'day_of_week');
        await m.dropColumn(sessionExercises, 'time_of_day');
        await m.addColumn(programSessions, programSessions.dayOfWeek);
        await m.addColumn(programSessions, programSessions.timeOfDay);
      }
      if (from < 4) {
        await m.alterTable(TableMigration(sessionExercises));
      }
      if (from < 5) {
        await m.dropColumn(habits, 'reminder_offset_minutes');
      }
      if (from < 6) {
        await m.dropColumn(readingSessions, 'date_key');
        await m.addColumn(readingSessions, readingSessions.updatedAt);
        await m.addColumn(bookHighlights, bookHighlights.updatedAt);
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'tenkai_db',
      native: const DriftNativeOptions(
        // By default, `driftDatabase` from `package:drift_flutter` stores the
        // database files in `getApplicationDocumentsDirectory()`.
        databaseDirectory: getApplicationSupportDirectory,
      ),
      // If you need web support, see https://drift.simonbinder.eu/platforms/web/
    );
  }
}
