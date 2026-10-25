import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/features/fitness/providers/program_provider.dart';

class SessionExerciseDetailScreen extends ConsumerWidget {
  final int sessionExerciseId;

  const SessionExerciseDetailScreen({
    super.key,
    required this.sessionExerciseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint(sessionExerciseId.toString());

    final sessionExerciseAsync = ref.watch(
      sessionExerciseProvider(sessionExerciseId),
    );
    final sessionExerciseLogsAsync = ref.watch(
      sessionExerciseLogsProvider(sessionExerciseId),
    );

    return Scaffold(
      appBar: AppBar(
        title: sessionExerciseAsync.when(
          data: (data) => Text(data.title),
          error: (error, stackTrace) => null,
          loading: () => null,
        ),
      ),
      body: Column(
        children: [
          sessionExerciseLogsAsync.when(
            data: (data) => Column(children: [Text(data.length.toString())]),
            error: (error, stackTrace) => Center(child: Text(error.toString())),
            loading: () => Center(child: CircularProgressIndicator()),
          ),
          // FilledButton(onPressed: () => {}, child: Text('Add new entry')),
        ],
      ),
    );
  }
}
