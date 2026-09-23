import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

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
  ],
  daos: [UserDao, JournalDao, HabitDao, BookDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

  // @override
  // MigrationStrategy get migration => MigrationStrategy(
  //   onCreate: (m) => m.createAll(),
  //   onUpgrade: (m, from, to) async {
  //     // v2 adds the habit tracker tables.
  //     if (from < 2) {
  //       await m.createTable(habits);
  //       await m.createTable(habitSchedules);
  //       await m.createTable(habitCompletions);
  //     }
  //     // v3 adds the book tracker tables.
  //     if (from < 3) {
  //       await m.createTable(books);
  //       await m.createTable(readingSessions);
  //       await m.createTable(bookHighlights);
  //     }
  //   },
  // );

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
