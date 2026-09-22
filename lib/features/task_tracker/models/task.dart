import 'package:tenkai/features/task_tracker/enums/task_status.dart';

/// An immutable task as returned by the API.
class Task {
  final String id;
  final String title;
  final TaskStatus status;

  /// Optional GTD "context" the task belongs to (e.g. `@home`, `@work`).
  final String? context;
  final DateTime? dueDate;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    required this.status,
    this.context,
    this.dueDate,
    required this.createdAt,
  });

  bool get isDone => status == TaskStatus.done;

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'].toString(),
    title: json['title'] as String,
    status: TaskStatus.fromApi(json['status'] as String?),
    context: json['context'] as String?,
    dueDate: _parseDate(json['due_date']),
    createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
  );

  Task copyWith({
    String? id,
    String? title,
    TaskStatus? status,
    String? context,
    DateTime? dueDate,
    DateTime? createdAt,
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    status: status ?? this.status,
    context: context ?? this.context,
    dueDate: dueDate ?? this.dueDate,
    createdAt: createdAt ?? this.createdAt,
  );

  static DateTime? _parseDate(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());
}
