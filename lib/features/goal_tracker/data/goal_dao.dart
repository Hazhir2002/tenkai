import 'package:drift/drift.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/features/goal_tracker/data/tables/goal.dart';
import 'package:tenkai/features/goal_tracker/data/tables/goal_log.dart';

part 'goal_dao.g.dart';

@DriftAccessor(tables: [Goals, GoalLogs])
class GoalDao extends DatabaseAccessor<AppDatabase> with _$GoalDaoMixin {
  GoalDao(super.db);

  Future<List<Goal>> getAllGoals() =>
      (select(goals)..orderBy([(t) => OrderingTerm.asc(t.completedAt)])).get();

  Future<Goal> createGoal(GoalsCompanion entry) => transaction(() async {
    return await into(goals).insertReturning(entry);
  });

  Future<Goal> updateGoal(GoalsCompanion entry) => transaction(() async {
    final updatedGoals = await (update(
      goals,
    )..where((b) => b.id.equals(entry.id.value))).writeReturning(entry);
    return updatedGoals.first;
  });

  Future<int> deleteGoal(int id) => transaction(() async {
    return (delete(goals)..where((tbl) => tbl.id.equals(id))).go();
  });
}
