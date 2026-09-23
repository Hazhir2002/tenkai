import 'package:drift/drift.dart';

/// A user-defined stat the profile screen tracks (title, unit, current value).
class UserStat extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 32)();
  TextColumn get unit => text().withLength(min: 1, max: 32)();
  IntColumn get value => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
