import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/features/task_tracker/enums/task_status.dart';
import 'package:tenkai/features/task_tracker/models/task.dart';
import 'package:tenkai/features/task_tracker/params/create_task_param.dart';
import 'package:tenkai/features/task_tracker/params/update_task_param.dart';
import 'package:tenkai/features/task_tracker/repositories/task_repository.dart';

class TaskNotifier extends AsyncNotifier<List<Task>> {
  TaskRepository get _repo => ref.read(taskRepositoryProvider);

  @override
  Future<List<Task>> build() async {
    final result = await _repo.getTasks();
    return result.fold((f) => throw Exception(f.message), (tasks) => tasks);
  }

  Future<void> createTask(CreateTaskParam params) async {
    final result = await _repo.createTask(params);
    final task = result.fold((f) => throw Exception(f.message), (t) => t);
    state = AsyncData([...?state.value, task]);
  }

  Future<void> updateTask(String id, UpdateTaskParam params) async {
    final result = await _repo.updateTask(id, params);
    final updated = result.fold((f) => throw Exception(f.message), (t) => t);
    state = AsyncData([
      for (final t in state.value ?? const <Task>[])
        if (t.id == id) updated else t,
    ]);
  }

  Future<void> toggleDone(Task task) => updateTask(
    task.id,
    UpdateTaskParam(status: task.isDone ? TaskStatus.active : TaskStatus.done),
  );

  Future<void> deleteTask(String id) async {
    final result = await _repo.deleteTask(id);
    result.fold((f) => throw Exception(f.message), (_) => null);
    state = AsyncData([
      for (final t in state.value ?? const <Task>[])
        if (t.id != id) t,
    ]);
  }
}

final taskProvider = AsyncNotifierProvider<TaskNotifier, List<Task>>(
  TaskNotifier.new,
);

// Filter: plain UI state
class TaskFilterNotifier extends Notifier<TaskStatus?> {
  @override
  TaskStatus? build() => null;

  void set(TaskStatus? filter) => state = filter;
}

final taskFilterProvider = NotifierProvider<TaskFilterNotifier, TaskStatus?>(
  TaskFilterNotifier.new,
);

// Derived view (replaces visibleTasks)
final visibleTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final filter = ref.watch(taskFilterProvider);
  return ref
      .watch(taskProvider)
      .whenData(
        (tasks) => filter == null
            ? tasks
            : tasks.where((t) => t.status == filter).toList(),
      );
});
