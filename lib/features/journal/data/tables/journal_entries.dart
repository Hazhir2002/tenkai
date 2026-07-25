import 'package:drift/drift.dart';

/// A single journal entry (typed or transcribed).
class JournalEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get content => text()();
  TextColumn get source => text().withDefault(const Constant('typed'))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
