import 'package:flutter/material.dart';
import 'package:tenkai/core/tokens/tenkai_spacing.dart';
import 'package:tenkai/features/goal_tracker/widgets/goal_form.dart';

class CreateGoalScreen extends StatelessWidget {
  const CreateGoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        minimum: EdgeInsets.all(TenkaiSpacing.md),
        child: GoalForm(),
      ),
    );
  }
}
