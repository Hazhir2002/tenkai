import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/providers.dart';

/// Reactively streams every saved journal entry, newest first. Drift's
/// `.watch()` re-emits automatically whenever a row is added, edited, or
/// removed, so any screen that watches this provider stays in sync with
/// the database with no manual refresh calls.
final journalEntriesProvider = StreamProvider<List<JournalEntry>>((ref) {
  final db = ref.watch(appDataBaseProvider);
  return db.watchAllEntries();
});
