import 'package:drift/drift.dart';
import 'package:tenkai/core/database.dart';

import 'tables/journal_entries.dart';

part 'journal_dao.g.dart';

/// Data access for the journal feature.
@DriftAccessor(tables: [JournalEntries])
class JournalDao extends DatabaseAccessor<AppDatabase> with _$JournalDaoMixin {
  JournalDao(super.db);

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
}
