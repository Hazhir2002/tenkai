import 'package:drift/drift.dart';
import 'package:tenkai/core/table_mixin.dart';

class Books extends Table with TableMixin {
  TextColumn get title => text().withLength(min: 1, max: 128)();
  TextColumn get author => text().nullable()();

  TextColumn get coverImagePath => text().nullable()();

  IntColumn get totalPages => integer()();
  IntColumn get currentPage => integer().withDefault(const Constant(0))();

  TextColumn get status => text().withDefault(const Constant('reading'))();

  DateTimeColumn get deadline => dateTime().nullable()();

  IntColumn get dailyPageGoal => integer().nullable()();

  BoolColumn get reminderEnabled =>
      boolean().withDefault(const Constant(false))();
  IntColumn get reminderHour => integer().nullable()();
  IntColumn get reminderMinute => integer().nullable()();

  IntColumn get rating => integer().nullable()();
  TextColumn get review => text().nullable()();

  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
}
