import 'package:flutter/material.dart';
import 'package:tenkai/core/theme/tenkai_semantic_colors.dart';
import 'package:tenkai/core/tokens/tenkai_spacing.dart';
import 'package:tenkai/core/tokens/tenkai_typography.dart';
import 'package:tenkai/features/task_tracker/models/task.dart';

/// A single task row: a done-toggle checkbox, the title (struck through when
/// done), and a metadata line (status · context · due date).
///
/// Purely presentational — it reports intent through [onToggleDone] and
/// [onTap] callbacks and owns no state, keeping it reusable and testable.
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
    final c = context.tenkai;
    final subtitle = _subtitle();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TenkaiSpacing.lg,
        vertical: TenkaiSpacing.xs,
      ),
      child: Card(
        // interactive: onTap != null,
        // onTap: onTap,
        // padding: const EdgeInsets.all(TenkaiSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Checkbox(
                value: task.isDone,
                onChanged: (value) => onToggleDone(value!),
              ),
            ),
            const SizedBox(width: TenkaiSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TenkaiTypography.bodyMd.copyWith(
                      color: task.isDone ? c.secondaryForeground : c.foreground,
                      decoration: task.isDone
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: c.secondaryForeground,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TenkaiTypography.labelSm.copyWith(
                        color: c.secondaryForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
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
