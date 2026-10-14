import 'package:drift/drift.dart';
import 'package:tenkai/core/table_mixin.dart';

class Goals extends Table with TableMixin {
  TextColumn get title => text().withLength(min: 1, max: 64)();
  TextColumn get description => text().nullable()();
  TextColumn get unit => text().nullable().withLength(max: 32)();
  RealColumn get initialValue => real().withDefault(const Constant(0))();
  RealColumn get currentValue => real().withDefault(const Constant(0))();
  RealColumn get targetValue => real().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get parentGoalId => integer().nullable().references(
    Goals,
    #id,
    onDelete: KeyAction.cascade,
  )();
  RealColumn get goalValueOnParentGoal => real().nullable().customConstraint(
    'NULL CHECK (goal_value_on_parent_goal IS NULL OR '
    'goal_value_on_parent_goal BETWEEN 0 AND 1)',
  )();
}
