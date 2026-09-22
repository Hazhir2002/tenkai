import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/network/api_endpoints.dart';
import 'package:tenkai/core/network/dio_client.dart';
import 'package:tenkai/features/goal_tracker/models/goal.dart';
import 'package:tenkai/features/goal_tracker/models/goal_log.dart';
import 'package:tenkai/features/goal_tracker/models/milestone.dart';
import 'package:tenkai/features/goal_tracker/params/create_goal_param.dart';
import 'package:tenkai/features/goal_tracker/params/log_value_param.dart';
import 'package:tenkai/features/goal_tracker/params/milestone_param.dart';
import 'package:tenkai/features/goal_tracker/params/update_goal_param.dart';

/// Talks to the `/goals` API. This layer only knows about Dio and JSON — it
/// throws on failure and leaves error-to-[Failure] mapping to the repository.
class GoalRemoteSource {
  final DioClient _dioClient;

  const GoalRemoteSource(this._dioClient);

  GoalEndpoints get _e => ApiEndpoints.goalEndpoints;

  Future<List<Goal>> getGoals() async {
    final response = await _dioClient.dio.get(_e.getGoals);
    return (response.data as List)
        .map((json) => Goal.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Goal> getGoal(String id) async {
    final response = await _dioClient.dio.get(_e.goal(id));
    return Goal.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Goal> createGoal(CreateGoalParam params) async {
    final response = await _dioClient.dio.post(
      _e.createGoal,
      data: params.toJson(),
    );
    return Goal.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Goal> updateGoal(String id, UpdateGoalParam params) async {
    final response = await _dioClient.dio.patch(
      _e.goal(id),
      data: params.toJson(),
    );
    return Goal.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteGoal(String id) async {
    await _dioClient.dio.delete(_e.goal(id));
  }

  /// Records a value and returns the updated goal (new value/pace/status).
  Future<Goal> logValue(String id, LogValueParam params) async {
    final response = await _dioClient.dio.post(
      _e.logs(id),
      data: params.toJson(),
    );
    return Goal.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<GoalLog>> getLogs(String id) async {
    final response = await _dioClient.dio.get(_e.logs(id));
    return (response.data as List)
        .map((json) => GoalLog.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Milestone>> getMilestones(String id) async {
    final response = await _dioClient.dio.get(_e.milestones(id));
    return (response.data as List)
        .map((json) => Milestone.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Milestone> createMilestone(String id, MilestoneParam params) async {
    final response = await _dioClient.dio.post(
      _e.milestones(id),
      data: params.toJson(),
    );
    return Milestone.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Milestone> updateMilestone(
    String id,
    String milestoneId,
    MilestoneParam params,
  ) async {
    final response = await _dioClient.dio.patch(
      _e.milestone(id, milestoneId),
      data: params.toJson(),
    );
    return Milestone.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteMilestone(String id, String milestoneId) async {
    await _dioClient.dio.delete(_e.milestone(id, milestoneId));
  }
}

final goalRemoteSourceProvider = Provider<GoalRemoteSource>(
  (ref) => GoalRemoteSource(ref.read(dioClientProvider)),
);
