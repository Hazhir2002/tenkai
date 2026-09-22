import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/features/goal_tracker/enums/goal_status.dart';
import 'package:tenkai/features/goal_tracker/models/goal.dart';
import 'package:tenkai/features/goal_tracker/models/goal_log.dart';
import 'package:tenkai/features/goal_tracker/models/milestone.dart';
import 'package:tenkai/features/goal_tracker/params/create_goal_param.dart';
import 'package:tenkai/features/goal_tracker/params/log_value_param.dart';
import 'package:tenkai/features/goal_tracker/params/milestone_param.dart';
import 'package:tenkai/features/goal_tracker/params/update_goal_param.dart';
import 'package:tenkai/features/goal_tracker/repositories/goal_repository.dart';

/// Immutable UI state for the goals list.
///
/// [filter] is `null` for "all" (which still hides archived goals).
/// [visibleGoals] derives the filtered view so widgets don't re-implement it.
class GoalState {
  final List<Goal>? goals;
  final GoalStatus? filter;
  final bool isLoading;
  final String? error;

  const GoalState({
    this.goals,
    this.filter,
    this.isLoading = false,
    this.error,
  });

  List<Goal> get visibleGoals {
    final all = goals ?? const <Goal>[];
    final f = filter;
    if (f == null) {
      return all.where((g) => g.status != GoalStatus.archived).toList();
    }
    return all.where((g) => g.status == f).toList();
  }

  GoalState copyWith({
    List<Goal>? goals,
    GoalStatus? filter,
    bool clearFilter = false,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) => GoalState(
    goals: goals ?? this.goals,
    filter: clearFilter ? null : (filter ?? this.filter),
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
  );
}

class GoalNotifier extends Notifier<GoalState> {
  late final GoalRepository _repository;

  @override
  GoalState build() {
    _repository = ref.read(goalRepositoryProvider);
    Future.microtask(loadGoals);
    return const GoalState(isLoading: true);
  }

  Future<void> loadGoals() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.getGoals();
    state = result.fold(
      (failure) => state.copyWith(isLoading: false, error: failure.message),
      (goals) =>
          state.copyWith(isLoading: false, goals: goals, clearError: true),
    );
  }

  /// Sets the active status filter (pass `null` for the "All" view).
  void setFilter(GoalStatus? filter) {
    state = filter == null
        ? state.copyWith(clearFilter: true)
        : state.copyWith(filter: filter);
  }

  Future<bool> createGoal(CreateGoalParam params) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.createGoal(params);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (goal) {
        state = state.copyWith(
          isLoading: false,
          goals: <Goal>[goal, ...?state.goals],
          clearError: true,
        );
        return true;
      },
    );
  }

  Future<bool> updateGoal(String id, UpdateGoalParam params) async {
    final result = await _repository.updateGoal(id, params);
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (updated) {
        _replaceGoal(updated);
        ref.invalidate(goalDetailProvider(id));
        return true;
      },
    );
  }

  Future<bool> archiveGoal(String id) =>
      updateGoal(id, const UpdateGoalParam(status: GoalStatus.archived));

  Future<bool> completeGoal(String id) =>
      updateGoal(id, const UpdateGoalParam(status: GoalStatus.completed));

  Future<bool> reactivateGoal(String id) =>
      updateGoal(id, const UpdateGoalParam(status: GoalStatus.active));

  Future<void> deleteGoal(String id) async {
    final result = await _repository.deleteGoal(id);
    state = result.fold(
      (failure) => state.copyWith(error: failure.message),
      (_) => state.copyWith(
        goals: [
          for (final goal in state.goals ?? const <Goal>[])
            if (goal.id != id) goal,
        ],
        clearError: true,
      ),
    );
  }

  /// Records a value. Returns the updated goal on success (so the caller can
  /// react to auto-completion), or null on failure.
  Future<Goal?> logValue(String id, LogValueParam params) async {
    final result = await _repository.logValue(id, params);
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return null;
      },
      (updated) {
        _replaceGoal(updated);
        // A new value can change pacing, the history, and achieved milestones.
        ref.invalidate(goalDetailProvider(id));
        ref.invalidate(goalLogsProvider(id));
        ref.invalidate(goalMilestonesProvider(id));
        return updated;
      },
    );
  }

  Future<bool> createMilestone(String goalId, MilestoneParam params) async {
    final result = await _repository.createMilestone(goalId, params);
    return _afterMilestoneChange(goalId, result.isRight());
  }

  Future<bool> updateMilestone(
    String goalId,
    String milestoneId,
    MilestoneParam params,
  ) async {
    final result =
        await _repository.updateMilestone(goalId, milestoneId, params);
    return _afterMilestoneChange(goalId, result.isRight());
  }

  Future<bool> deleteMilestone(String goalId, String milestoneId) async {
    final result = await _repository.deleteMilestone(goalId, milestoneId);
    return _afterMilestoneChange(goalId, result.isRight());
  }

  bool _afterMilestoneChange(String goalId, bool success) {
    if (success) ref.invalidate(goalMilestonesProvider(goalId));
    return success;
  }

  void _replaceGoal(Goal updated) {
    state = state.copyWith(
      goals: [
        for (final goal in state.goals ?? const <Goal>[])
          if (goal.id == updated.id) updated else goal,
      ],
      clearError: true,
    );
  }
}

final goalProvider = NotifierProvider<GoalNotifier, GoalState>(
  GoalNotifier.new,
);

/// A single goal fetched fresh (with freshly computed pacing), for the detail
/// screen. Kept separate from the list so deep links work without the list.
final goalDetailProvider = FutureProvider.family<Goal, String>((ref, id) async {
  final result = await ref.watch(goalRepositoryProvider).getGoal(id);
  return result.fold((failure) => throw failure, (goal) => goal);
});

/// A goal's value history, oldest first (chart data).
final goalLogsProvider =
    FutureProvider.family<List<GoalLog>, String>((ref, id) async {
      final result = await ref.watch(goalRepositoryProvider).getLogs(id);
      return result.fold((failure) => throw failure, (logs) => logs);
    });

/// A goal's milestones, ordered by target value ascending.
final goalMilestonesProvider =
    FutureProvider.family<List<Milestone>, String>((ref, id) async {
      final result = await ref.watch(goalRepositoryProvider).getMilestones(id);
      return result.fold((failure) => throw failure, (items) => items);
    });
