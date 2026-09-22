import 'package:flutter/material.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/features/task_tracker/enums/task_status.dart';

/// Horizontal row of filter chips: "All" plus one chip per [TaskStatus].
/// A `null` [selected] means the "All" chip is active.
class TaskStatusFilter extends StatelessWidget {
  const TaskStatusFilter({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final TaskStatus? selected;
  final ValueChanged<TaskStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: TenkaiSpacing.lg),
        children: [
          TenkaiChip(
            label: 'All',
            selected: selected == null,
            onTap: () => onSelected(null),
          ),
          for (final status in TaskStatus.values) ...[
            const SizedBox(width: TenkaiSpacing.sm),
            TenkaiChip(
              label: status.label,
              selected: selected == status,
              onTap: () => onSelected(status),
            ),
          ],
        ],
      ),
    );
  }
}
