import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/providers.dart';
import 'package:tenkai/features/goal_tracker/enums/goal_status.dart';
import 'package:tenkai/features/goal_tracker/models/goal_model.dart';

/// Immutable UI state for the goals list.
///
/// [filter] is `null` for "all" (which still hides archived goals).
/// [visibleGoals] derives the filtered view so widgets don't re-implement it.
class GoalState {
  final List<GoalModel> goals;
  final GoalStatus? filter;
  final bool isLoading;
  final String? error;

  const GoalState({
    this.goals = const [],
    this.filter,
    this.isLoading = false,
    this.error,
  });

  List<GoalModel> get visibleGoals {
    final all = goals;
    final f = filter;
    if (f == null) {
      return all.where((g) => g.status != GoalStatus.archived).toList();
    }
    return all.where((g) => g.status == f).toList();
  }

  GoalState copyWith({
    List<GoalModel>? goals,
    GoalStatus? filter,
    bool? isLoading,
    String? error,
  }) => GoalState(
    goals: goals ?? this.goals,
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
  );
}

class GoalNotifier extends Notifier<GoalState> {
  late AppDatabase _db;

  @override
  GoalState build() {
    _db = ref.read(appDataBaseProvider);
    Future.microtask(loadGoals);
    return const GoalState(isLoading: true);
  }

  Future<void> loadGoals() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _db.goalDao.getAllGoals();
    state = state.copyWith(
      isLoading: false,
      goals: result.map((g) => GoalModel.fromGoal(g)).toList(),
      error: null,
    );
  }

  /// Sets the active status filter (pass `null` for the "All" view).
  void setFilter(GoalStatus? filter) {
    state = filter == null ? state : state.copyWith(filter: filter);
  }

  Future<void> createGoal(GoalsCompanion entry) async {
    final result = await _db.goalDao.createGoal(entry);
    state = state.copyWith(goals: [...state.goals, GoalModel.fromGoal(result)]);
  }

  Future<void> updateGoal(GoalsCompanion entry) async {
    final result = await _db.goalDao.updateGoal(entry);
    state = state.copyWith(
      goals: state.goals.map((g) {
        return g.id == entry.id.value ? GoalModel.fromGoal(result) : g;
      }).toList(),
    );
  }

  Future<void> deleteGoal(int id) async {
    final result = await _db.goalDao.deleteGoal(id);
    if (result == 0) {
      state = state.copyWith(error: 'Failed to delete goal');
      return;
    }

    state = state.copyWith(
      goals: state.goals.where((g) => g.id != id).toList(),
    );
  }

  // Future<bool> archiveGoal(String id) =>
  //     updateGoal(id, const UpdateGoalParam(status: GoalStatus.archived));

  // Future<bool> completeGoal(String id) =>
  //     updateGoal(id, const UpdateGoalParam(status: GoalStatus.completed));

  // Future<bool> reactivateGoal(String id) =>
  //     updateGoal(id, const UpdateGoalParam(status: GoalStatus.active));

  // /// Records a value. Returns the updated goal on success (so the caller can
  // /// react to auto-completion), or null on failure.
  // Future<Goal?> logValue(String id, LogValueParam params) async {
  //   final result = await _repository.logValue(id, params);
  //   return result.fold(
  //     (failure) {
  //       state = state.copyWith(error: failure.message);
  //       return null;
  //     },
  //     (updated) {
  //       _replaceGoal(updated);
  //       // A new value can change pacing, the history, and achieved milestones.
  //       ref.invalidate(goalDetailProvider(id));
  //       ref.invalidate(goalLogsProvider(id));
  //       ref.invalidate(goalMilestonesProvider(id));
  //       return updated;
  //     },
  //   );
  // }

  // Future<bool> createMilestone(String goalId, MilestoneParam params) async {
  //   final result = await _repository.createMilestone(goalId, params);
  //   return _afterMilestoneChange(goalId, result.isRight());
  // }

  // Future<bool> updateMilestone(
  //   String goalId,
  //   String milestoneId,
  //   MilestoneParam params,
  // ) async {
  //   final result = await _repository.updateMilestone(
  //     goalId,
  //     milestoneId,
  //     params,
  //   );
  //   return _afterMilestoneChange(goalId, result.isRight());
  // }

  // Future<bool> deleteMilestone(String goalId, String milestoneId) async {
  //   final result = await _repository.deleteMilestone(goalId, milestoneId);
  //   return _afterMilestoneChange(goalId, result.isRight());
  // }

  // bool _afterMilestoneChange(String goalId, bool success) {
  //   if (success) ref.invalidate(goalMilestonesProvider(goalId));
  //   return success;
  // }

  // void _replaceGoal(Goal updated) {
  //   state = state.copyWith(
  //     goals: [
  //       for (final goal in state.goals ?? const <Goal>[])
  //         if (goal.id == updated.id) updated else goal,
  //     ],
  //     clearError: true,
  //   );
  // }
}

final goalProvider = NotifierProvider<GoalNotifier, GoalState>(
  GoalNotifier.new,
);

/// A single goal fetched fresh (with freshly computed pacing), for the detail
/// screen. Kept separate from the list so deep links work without the list.
// final goalDetailProvider = FutureProvider.family<Goal, String>((ref, id) async {
//   final result = await ref.watch(goalRepositoryProvider).getGoal(id);
//   return result.fold((failure) => throw failure, (goal) => goal);
// });

// /// A goal's value history, oldest first (chart data).
// final goalLogsProvider = FutureProvider.family<List<GoalLog>, String>((
//   ref,
//   id,
// ) async {
//   final result = await ref.watch(goalRepositoryProvider).getLogs(id);
//   return result.fold((failure) => throw failure, (logs) => logs);
// });

// /// A goal's milestones, ordered by target value ascending.
// final goalMilestonesProvider = FutureProvider.family<List<Milestone>, String>((
//   ref,
//   id,
// ) async {
//   final result = await ref.watch(goalRepositoryProvider).getMilestones(id);
//   return result.fold((failure) => throw failure, (items) => items);
// });
