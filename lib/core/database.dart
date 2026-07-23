import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class UserStat extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 32)();
  TextColumn get unit => text().withLength(min: 1, max: 32)();
  IntColumn get value => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class UserStatLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userStatId =>
      integer().references(UserStat, #id, onDelete: KeyAction.cascade)();
  IntColumn get value => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class JournalEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get content => text()();
  TextColumn get source => text().withDefault(const Constant('typed'))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [UserStat, JournalEntries])
class AppDatabase extends _$AppDatabase {
  // After generating code, this class needs to define a `schemaVersion` getter
  // and a constructor telling drift where the database should be stored.
  // These are described in the getting started guide: https://drift.simonbinder.eu/setup/
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<JournalEntry>> watchAllEntriesOnce() => (select(
    journalEntries,
  )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();

  Stream<List<JournalEntry>> watchAllEntries() => (select(
    journalEntries,
  )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();

  Future<int> addEntry({required String content, required String source}) {
    return into(journalEntries).insert(
      JournalEntriesCompanion.insert(content: content, source: Value(source)),
    );
  }

  Future<bool> updateEntry(JournalEntry entry, String newContent) {
    return update(
      journalEntries,
    ).replace(entry.copyWith(content: newContent, updatedAt: DateTime.now()));
  }

  Future<int> deleteEntry(int id) {
    return (delete(journalEntries)..where((t) => t.id.equals(id))).go();
  }

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
