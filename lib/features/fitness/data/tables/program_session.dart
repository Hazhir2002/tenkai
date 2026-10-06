import 'package:drift/drift.dart';
import 'package:tenkai/core/table_mixin.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'program.dart';

class TimeOfDayConverter extends TypeConverter<TimeOfDay, int> {
  const TimeOfDayConverter();

  @override
  TimeOfDay fromSql(int fromDb) =>
      TimeOfDay(hour: fromDb ~/ 60, minute: fromDb % 60);

  @override
  int toSql(TimeOfDay value) => value.hour * 60 + value.minute;
}

class ProgramSessions extends Table with TableMixin {
  TextColumn get title => text().withLength(min: 1, max: 64)();
  IntColumn get programId =>
      integer().references(Programs, #id, onDelete: KeyAction.cascade)();
  IntColumn get hierarchy => integer().unique()();
  IntColumn get dayOfWeek => integer()
      .withDefault(const Constant(1))
      .check(dayOfWeek.isBetweenValues(1, 7))
      .nullable()();
  IntColumn get timeOfDay => integer()
      .map(const TimeOfDayConverter())
      .check(timeOfDay.isBetweenValues(0, 1439))
      .nullable()();
}
