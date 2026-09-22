import 'package:tenkai/features/task_tracker/enums/task_status.dart';

/// Payload for creating a task. [status] is optional — the backend defaults
/// new tasks to [TaskStatus.active] when omitted.
class CreateTaskParam {
  final String title;
  final TaskStatus? status;
  final String? context;
  final DateTime? dueDate;

  const CreateTaskParam({
    required this.title,
    this.status,
    this.context,
    this.dueDate,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    if (status != null) 'status': status!.apiValue,
    if (context != null) 'context': context,
    if (dueDate != null) 'due_date': dueDate!.toIso8601String(),
  };
}
