import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/features/fitness/providers/health_provider.dart';

const int MAXSTEPS = 10000;

class StepsWidget extends ConsumerWidget {
  const StepsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthState = ref.watch(healthProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TenkaiSpacing.md),
        child: Builder(
          builder: (context) {
            if (healthState.isLoading) {
              return CircularProgressIndicator();
            } else if (healthState.error != null) {
              return Text(healthState.error!);
            } else if (healthState.steps != null) {
              return Stack(
                alignment: AlignmentGeometry.center,
                children: [
                  CircularProgressIndicator(
                    constraints: BoxConstraints(minHeight: 150, minWidth: 150),
                    strokeWidth: 10,
                    value: healthState.steps! / MAXSTEPS,
                  ),
                  Text(
                    healthState.steps.toString(),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
