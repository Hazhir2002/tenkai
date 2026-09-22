import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/features/task_tracker/enums/task_status.dart';
import 'package:tenkai/features/task_tracker/models/task.dart';
import 'package:tenkai/features/task_tracker/params/create_task_param.dart';
import 'package:tenkai/features/task_tracker/params/update_task_param.dart';
import 'package:tenkai/features/task_tracker/repositories/task_repository.dart';

/// Immutable UI state for the task list.
///
/// [filter] is `null` for "all". [visibleTasks] derives the filtered view so
/// widgets don't re-implement filtering logic.
class TaskState {
  final List<Task>? tasks;
  final TaskStatus? filter;
  final bool isLoading;
  final String? error;

  const TaskState({
    this.tasks,
    this.filter,
    this.isLoading = false,
    this.error,
  });

  List<Task> get visibleTasks {
    final all = tasks ?? const [];
    if (filter == null) return all;
    return all.where((task) => task.status == filter).toList();
  }

  TaskState copyWith({
    List<Task>? tasks,
    TaskStatus? filter,
    bool clearFilter = false,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) => TaskState(
    tasks: tasks ?? this.tasks,
    filter: clearFilter ? null : (filter ?? this.filter),
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
  );
}

class TaskNotifier extends Notifier<TaskState> {
  late final TaskRepository _repository;

  @override
  TaskState build() {
    _repository = ref.read(taskRepositoryProvider);
    Future.microtask(loadTasks);
    return const TaskState(isLoading: true);
  }

  Future<void> loadTasks() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.getTasks();

    state = result.fold(
      (failure) => state.copyWith(isLoading: false, error: failure.message),
      (tasks) => state.copyWith(isLoading: false, tasks: tasks, clearError: true),
    );
  }

  /// Sets the active status filter (pass `null` to show all tasks).
  void setFilter(TaskStatus? filter) {
    state = filter == null
        ? state.copyWith(clearFilter: true)
        : state.copyWith(filter: filter);
  }

  Future<void> createTask(CreateTaskParam params) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.createTask(params);

    state = result.fold(
      (failure) => state.copyWith(isLoading: false, error: failure.message),
      (task) => state.copyWith(
        isLoading: false,
        tasks: <Task>[...?state.tasks, task],
        clearError: true,
      ),
    );
  }

  Future<void> updateTask(String id, UpdateTaskParam params) async {
    final result = await _repository.updateTask(id, params);

    state = result.fold(
      (failure) => state.copyWith(error: failure.message),
      (updated) => state.copyWith(
        tasks: [
          for (final task in state.tasks ?? const <Task>[])
            if (task.id == id) updated else task,
        ],
        clearError: true,
      ),
    );
  }

  /// Convenience for the most common mutation: toggling a task's done state.
  Future<void> toggleDone(Task task) => updateTask(
    task.id,
    UpdateTaskParam(
      status: task.isDone ? TaskStatus.active : TaskStatus.done,
    ),
  );

  Future<void> deleteTask(String id) async {
    final result = await _repository.deleteTask(id);

    state = result.fold(
      (failure) => state.copyWith(error: failure.message),
      (_) => state.copyWith(
        tasks: [
          for (final task in state.tasks ?? const <Task>[])
            if (task.id != id) task,
        ],
        clearError: true,
      ),
    );
  }
}

final taskProvider = NotifierProvider<TaskNotifier, TaskState>(
  TaskNotifier.new,
);
