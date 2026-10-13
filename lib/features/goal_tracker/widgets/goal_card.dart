import 'package:flutter/material.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/features/goal_tracker/enums/goal_status.dart';
import 'package:tenkai/features/goal_tracker/models/goal.dart';
import 'package:tenkai/features/goal_tracker/widgets/goal_ui.dart';

/// A single goal row: title, a status/pace badge, the current→target readout,
/// and a progress bar. Purely presentational — reports taps via [onTap].
class GoalCard extends StatelessWidget {
  const GoalCard({super.key, required this.goal, this.onTap});

  final Goal goal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TenkaiSpacing.lg,
        vertical: TenkaiSpacing.xs,
      ),
      child: Card(
        // interactive: onTap != null,
        // onTap: onTap,
        // padding: const EdgeInsets.all(TenkaiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    goal.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TenkaiTypography.bodyMd.copyWith(
                      color: c.foreground,
                    ),
                  ),
                ),
                const SizedBox(width: TenkaiSpacing.sm),
                _badge(),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${formatGoalValue(goal.currentValue)} of '
              '${formatGoalValue(goal.targetValue, goal.unit)}',
              style: TenkaiTypography.labelSm.copyWith(
                color: c.secondaryForeground,
              ),
            ),
            const SizedBox(height: TenkaiSpacing.md),
            LinearProgressIndicator(value: goal.progress),
          ],
        ),
      ),
    );
  }

  Widget _badge() {
    switch (goal.status) {
      case GoalStatus.completed:
        return const Chip(
          label: Text('Completed'),
          backgroundColor: Colors.greenAccent,
        );
      case GoalStatus.archived:
        return const Chip(label: Text('Archived'));
      case GoalStatus.active:
        if (goal.hasPacing) {
          return Chip(label: Text(goal.pace.label));
        }
        return const Chip(label: Text('Active'));
    }
  }
}
