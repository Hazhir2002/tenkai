import 'package:flutter/material.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_button.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_node.dart';
import 'package:tenkai/core/design_system/tokens/tenkai_spacing.dart';

class HabitTrackerScreen extends StatelessWidget {
  const HabitTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Habit Tracker')),
      body: Padding(
        padding: EdgeInsetsGeometry.all(TenkaiSpacing.lg),
        child: Center(
          child: Column(
            children: [
              TenkaiButton(
                label: 'Add new habit',
                onPressed: () => {},
                variant: TenkaiButtonVariant.primary,
              ),
              Column(
                spacing: TenkaiSpacing.xxxl,
                children: [
                  TenkaiNode(),
                  TenkaiNode(),
                  TenkaiNode(),
                  TenkaiNode(),
                  TenkaiNode(),
                  TenkaiNode(),
                  TenkaiNode(),
                  TenkaiNode(),
                  TenkaiNode(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
