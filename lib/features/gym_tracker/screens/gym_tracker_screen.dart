import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tenkai/core/design_system/tenkai.dart';

class GymTrackerScreen extends StatelessWidget {
  const GymTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: const TenkaiAppBar(title: 'Gym'),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          TenkaiSpacing.lg,
          MediaQuery.of(context).padding.top + TenkaiAppBar.compactHeight,
          TenkaiSpacing.lg,
          TenkaiSpacing.xl,
        ),
        children: [
          TenkaiListRow(
            title: 'Exercises',
            trailing: const Icon(Icons.chevron_right, size: 18),
            onTap: () => context.push('/gym-tracker/exercises'),
          ),
          const SizedBox(height: TenkaiSpacing.sm),
          TenkaiListRow(
            title: 'Programs',
            trailing: const Icon(Icons.chevron_right, size: 18),
            onTap: () => context.push('/gym-tracker/programs'),
          ),
        ],
      ),
    );
  }
}
