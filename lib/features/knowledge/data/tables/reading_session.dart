import 'package:drift/drift.dart';

import 'book.dart';

/// One progress update: the reader advanced from [startPage] to [endPage], with
/// an optional "what I learned" [summary]. Every update creates one of these —
/// they're both the pace-graph data points and the reading log.
class ReadingSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  IntColumn get startPage => integer()();
  IntColumn get endPage => integer()();
  TextColumn get summary => text().nullable()();
  TextColumn get source => text().withDefault(const Constant('typed'))();

  /// 'yyyy-MM-dd' of the session, for streaks / per-day aggregation.
  TextColumn get dateKey => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
