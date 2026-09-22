import 'package:tenkai/features/task_tracker/enums/task_status.dart';

/// Payload for partially updating a task. Every field is optional; only the
/// non-null ones are serialized, so a call can update just the [status]
/// (e.g. marking done) without clobbering other fields.
class UpdateTaskParam {
  final String? title;
  final TaskStatus? status;
  final String? context;
  final DateTime? dueDate;

  const UpdateTaskParam({this.title, this.status, this.context, this.dueDate});

  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (status != null) 'status': status!.apiValue,
    if (context != null) 'context': context,
    if (dueDate != null) 'due_date': dueDate!.toIso8601String(),
  };
}
