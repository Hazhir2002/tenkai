import 'package:drift/drift.dart';
import 'package:tenkai/core/table_mixin.dart';
import 'package:tenkai/features/goal_tracker/data/tables/goal.dart';

class GoalLogs extends Table with TableMixin {
  IntColumn get goalId =>
      integer().references(Goals, #id, onDelete: KeyAction.cascade)();
  RealColumn get value => real()();
  TextColumn get note => text().nullable()();
}
