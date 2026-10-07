import 'package:flutter/material.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/features/goal_tracker/enums/goal_status.dart';

/// Horizontal row of filter chips: "All" plus one chip per [GoalStatus].
/// A `null` [selected] means the "All" chip is active.
class GoalStatusFilter extends StatelessWidget {
  const GoalStatusFilter({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final GoalStatus? selected;
  final ValueChanged<GoalStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: TenkaiSpacing.lg),
        children: [
          ChoiceChip(
            label: Text('All'),
            selected: selected == null,
            onSelected: (value) => onSelected(null),
          ),
          for (final status in GoalStatus.values) ...[
            const SizedBox(width: TenkaiSpacing.sm),
            ChoiceChip(
              label: Text(status.label),
              selected: selected == status,
              onSelected: (value) => onSelected(status),
            ),
          ],
        ],
      ),
    );
  }
}
