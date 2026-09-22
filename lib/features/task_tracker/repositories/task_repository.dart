import 'package:dartz/dartz.dart' hide Task;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/errors/failures.dart';
import 'package:tenkai/core/helpers/repository_helper.dart';
import 'package:tenkai/features/task_tracker/models/task.dart';
import 'package:tenkai/features/task_tracker/params/create_task_param.dart';
import 'package:tenkai/features/task_tracker/params/update_task_param.dart';
import 'package:tenkai/features/task_tracker/sources/task_remote_source.dart';

/// Wraps [TaskRemoteSource], turning thrown errors into typed [Failure]s via
/// [RepositoryHelper] so callers get a predictable `Either<Failure, T>`.
class TaskRepository {
  final TaskRemoteSource _taskRemoteSource;

  const TaskRepository(this._taskRemoteSource);

  Future<Either<Failure, List<Task>>> getTasks() =>
      RepositoryHelper.executeFromSource(() => _taskRemoteSource.getTasks());

  Future<Either<Failure, Task>> getTask(String id) =>
      RepositoryHelper.executeFromSource(() => _taskRemoteSource.getTask(id));

  Future<Either<Failure, Task>> createTask(CreateTaskParam params) =>
      RepositoryHelper.executeFromSource(
        () => _taskRemoteSource.createTask(params),
      );

  Future<Either<Failure, Task>> updateTask(
    String id,
    UpdateTaskParam params,
  ) => RepositoryHelper.executeFromSource(
    () => _taskRemoteSource.updateTask(id, params),
  );

  Future<Either<Failure, Unit>> deleteTask(String id) =>
      RepositoryHelper.executeFromSource(() async {
        await _taskRemoteSource.deleteTask(id);
        return unit;
      });
}

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => TaskRepository(ref.read(taskRemoteSourceProvider)),
);
