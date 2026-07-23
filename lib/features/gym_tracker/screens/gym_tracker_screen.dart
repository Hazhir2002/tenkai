import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_button.dart';

class GymTrackerScreen extends StatelessWidget {
  const GymTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gym tracker')),
      body: Column(
        children: [
          TenkaiButton(
            onPressed: () => context.push('/gym-tracker/exercises'),
            label: 'exercises screen',
          ),

          TenkaiButton(
            onPressed: () => context.push('/gym-tracker/programs'),
            label: 'programs',
          ),
        ],
      ),
    );
  }
}
