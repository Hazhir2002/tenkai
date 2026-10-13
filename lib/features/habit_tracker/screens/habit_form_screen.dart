import 'package:flutter/material.dart';
import 'package:tenkai/core/tokens/tenkai_spacing.dart';
import 'package:tenkai/features/habit_tracker/widgets/habit_form.dart';

class HabitFormScreen extends StatelessWidget {
  const HabitFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Habit')),
      body: SafeArea(
        minimum: EdgeInsets.all(TenkaiSpacing.md),
        child: HabitForm(),
      ),
    );
  }
}
