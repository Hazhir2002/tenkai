import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/network/api_endpoints.dart';
import 'package:tenkai/core/network/dio_client.dart';
import 'package:tenkai/features/task_tracker/models/task.dart';
import 'package:tenkai/features/task_tracker/params/create_task_param.dart';
import 'package:tenkai/features/task_tracker/params/update_task_param.dart';

/// Talks to the `/tasks` API. This layer only knows about Dio and JSON — it
/// throws on failure and leaves error-to-[Failure] mapping to the repository.
class TaskRemoteSource {
  final DioClient _dioClient;

  const TaskRemoteSource(this._dioClient);

  Future<List<Task>> getTasks() async {
    final response = await _dioClient.dio.get(
      ApiEndpoints.taskEndpoints.getTasks,
    );

    return (response.data as List)
        .map((json) => Task.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Task> getTask(String id) async {
    final response = await _dioClient.dio.get(
      ApiEndpoints.taskEndpoints.getTask(id),
    );

    return Task.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Task> createTask(CreateTaskParam params) async {
    final response = await _dioClient.dio.post(
      ApiEndpoints.taskEndpoints.createTask,
      data: params.toJson(),
    );

    return Task.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Task> updateTask(String id, UpdateTaskParam params) async {
    final response = await _dioClient.dio.patch(
      ApiEndpoints.taskEndpoints.updateTask(id),
      data: params.toJson(),
    );

    return Task.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteTask(String id) async {
    await _dioClient.dio.delete(ApiEndpoints.taskEndpoints.deleteTask(id));
  }
}

final taskRemoteSourceProvider = Provider<TaskRemoteSource>(
  (ref) => TaskRemoteSource(ref.read(dioClientProvider)),
);
