import 'package:drift/drift.dart';

/// A book the user is tracking. Progress advances via reading sessions; pace is
/// measured against an optional [deadline] or an optional [dailyPageGoal].
class Books extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 128)();
  TextColumn get author => text().nullable()();

  /// Absolute path to a stored cover photo, if any.
  TextColumn get coverImagePath => text().nullable()();

  IntColumn get totalPages => integer()();
  IntColumn get currentPage => integer().withDefault(const Constant(0))();

  /// wantToRead | reading | finished | paused
  TextColumn get status => text().withDefault(const Constant('reading'))();

  /// Optional target date to finish by.
  DateTimeColumn get deadline => dateTime().nullable()();

  /// Optional pages-per-day goal (used when there's no [deadline]).
  IntColumn get dailyPageGoal => integer().nullable()();

  BoolColumn get reminderEnabled =>
      boolean().withDefault(const Constant(false))();
  IntColumn get reminderHour => integer().nullable()();
  IntColumn get reminderMinute => integer().nullable()();

  /// 1..5, set when the book is finished.
  IntColumn get rating => integer().nullable()();
  TextColumn get review => text().nullable()();

  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
