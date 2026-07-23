import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/features/gym_tracker/providers/exercise_provider.dart';

class ExercisesScreen extends ConsumerWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseState = ref.watch(exerciseProvider);

    return Scaffold(
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (exerciseState.isLoading) {
              return CircularProgressIndicator();
            } else if (exerciseState.error != null) {
              return Text(exerciseState.error!);
            } else if (exerciseState.exercises != null) {
              return ListView.builder(
                itemBuilder: (_, index) =>
                    Card(child: Text(exerciseState.exercises![index].name)),
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}
