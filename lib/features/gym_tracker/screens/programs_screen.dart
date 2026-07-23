import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/features/gym_tracker/providers/program_provider.dart';

class ProgramsScreen extends ConsumerWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programState = ref.watch(programProvider);

    return Scaffold(
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (programState.isLoading) {
              return CircularProgressIndicator();
            } else if (programState.error != null) {
              return Text(programState.error!);
            } else if (programState.programs != null) {
              return ListView.builder(
                itemCount: programState.programs!.length,
                itemBuilder: (_, index) =>
                    Card(child: Text(programState.programs![index].name)),
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
