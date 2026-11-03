import 'package:flutter/material.dart';
import 'package:tenkai/core/tokens/tenkai_spacing.dart';
import 'package:tenkai/features/task_tracker/models/task.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleDone,
    this.onTap,
  });

  final Task task;
  final ValueChanged<bool> onToggleDone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = _subtitle();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TenkaiSpacing.lg,
        vertical: TenkaiSpacing.xs,
      ),
      child: Card(
        child: ListTile(
          onTap: onTap,
          leading: Checkbox(
            value: task.isDone,
            onChanged: (value) => onToggleDone(value!),
          ),
          title: Text(task.title),
          subtitle: subtitle != null ? Text(subtitle) : null,
        ),
      ),
    );
  }

  String? _subtitle() {
    final parts = <String>[
      task.status.label,
      if (task.context != null && task.context!.isNotEmpty) task.context!,
      if (task.dueDate != null) 'Due ${_formatDate(task.dueDate!)}',
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  static String _formatDate(DateTime date) =>
      '${date.year}-${_pad(date.month)}-${_pad(date.day)}';

  static String _pad(int value) => value.toString().padLeft(2, '0');
}
