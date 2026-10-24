import 'package:flutter/material.dart';
import 'package:tenkai/core/tokens/tenkai_spacing.dart';
import 'package:tenkai/core/tokens/tenkai_typography.dart';
import 'package:tenkai/features/goal_tracker/enums/goal_status.dart';
import 'package:tenkai/features/goal_tracker/models/goal_model.dart';
import 'package:tenkai/features/goal_tracker/widgets/goal_ui.dart';

import '../../../core/theme/tenkai_semantic_colors.dart'
    show TenkaiSemanticColorsX;

class GoalCard extends StatelessWidget {
  const GoalCard({super.key, required this.goal, this.onTap});

  final GoalModel goal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(goal.title),
        subtitle: Text(
          '${goal.currentValue} of '
          '${goal.targetValue ?? 0} ${goal.unit}',
        ),
        trailing: GoalModel.badge(goal),
        leading: CircularProgressIndicator(value: goal.progress),
      ),
    );
  }
}
