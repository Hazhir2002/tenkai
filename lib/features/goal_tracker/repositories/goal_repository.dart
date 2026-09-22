import 'package:dartz/dartz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/errors/failures.dart';
import 'package:tenkai/core/helpers/repository_helper.dart';
import 'package:tenkai/features/goal_tracker/models/goal.dart';
import 'package:tenkai/features/goal_tracker/models/goal_log.dart';
import 'package:tenkai/features/goal_tracker/models/milestone.dart';
import 'package:tenkai/features/goal_tracker/params/create_goal_param.dart';
import 'package:tenkai/features/goal_tracker/params/log_value_param.dart';
import 'package:tenkai/features/goal_tracker/params/milestone_param.dart';
import 'package:tenkai/features/goal_tracker/params/update_goal_param.dart';
import 'package:tenkai/features/goal_tracker/sources/goal_remote_source.dart';

/// Wraps [GoalRemoteSource], turning thrown errors into typed [Failure]s via
/// [RepositoryHelper] so callers get a predictable `Either<Failure, T>`.
class GoalRepository {
  final GoalRemoteSource _source;

  const GoalRepository(this._source);

  Future<Either<Failure, List<Goal>>> getGoals() =>
      RepositoryHelper.executeFromSource(() => _source.getGoals());

  Future<Either<Failure, Goal>> getGoal(String id) =>
      RepositoryHelper.executeFromSource(() => _source.getGoal(id));

  Future<Either<Failure, Goal>> createGoal(CreateGoalParam params) =>
      RepositoryHelper.executeFromSource(() => _source.createGoal(params));

  Future<Either<Failure, Goal>> updateGoal(String id, UpdateGoalParam params) =>
      RepositoryHelper.executeFromSource(() => _source.updateGoal(id, params));

  Future<Either<Failure, Unit>> deleteGoal(String id) =>
      RepositoryHelper.executeFromSource(() async {
        await _source.deleteGoal(id);
        return unit;
      });

  Future<Either<Failure, Goal>> logValue(String id, LogValueParam params) =>
      RepositoryHelper.executeFromSource(() => _source.logValue(id, params));

  Future<Either<Failure, List<GoalLog>>> getLogs(String id) =>
      RepositoryHelper.executeFromSource(() => _source.getLogs(id));

  Future<Either<Failure, List<Milestone>>> getMilestones(String id) =>
      RepositoryHelper.executeFromSource(() => _source.getMilestones(id));

  Future<Either<Failure, Milestone>> createMilestone(
    String id,
    MilestoneParam params,
  ) => RepositoryHelper.executeFromSource(
    () => _source.createMilestone(id, params),
  );

  Future<Either<Failure, Milestone>> updateMilestone(
    String id,
    String milestoneId,
    MilestoneParam params,
  ) => RepositoryHelper.executeFromSource(
    () => _source.updateMilestone(id, milestoneId, params),
  );

  Future<Either<Failure, Unit>> deleteMilestone(String id, String milestoneId) =>
      RepositoryHelper.executeFromSource(() async {
        await _source.deleteMilestone(id, milestoneId);
        return unit;
      });
}

final goalRepositoryProvider = Provider<GoalRepository>(
  (ref) => GoalRepository(ref.read(goalRemoteSourceProvider)),
);
