import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/features/fitness/providers/fitness_provider.dart';
import 'package:tenkai/features/fitness/screens/create_program_screen.dart';
import 'package:tenkai/features/fitness/widgets/program_form.dart';

class ProgramsScreen extends ConsumerWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programState = ref.watch(fitnessProvider);
    final c = context.tenkai;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text('Programs')),
      body: Builder(
        builder: (context) {
          final topPad = MediaQuery.of(context).padding.top;
          if (programState.isLoading) {
            return Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: c.mutedForeground,
                ),
              ),
            );
          }
          if (programState.error != null) {
            return const Center(
              child: TenkaiEmptyState(title: 'Couldn\'t load programs'),
            );
          }
          final programs = programState.programs;
          if (programs == null || programs.isEmpty) {
            return Center(
              child: TenkaiEmptyState(
                title: 'No programs yet',
                description: 'Programs you create will show up here.',
                action: FilledButton(
                  onPressed: () => {
                    showTenkaiSheet(
                      context: context,
                      title: 'Create program',
                      child: ProgramForm(),
                    ),
                  },
                  child: Text("Create program"),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.fromLTRB(
              TenkaiSpacing.lg,
              topPad,
              TenkaiSpacing.lg,
              TenkaiSpacing.xl,
            ),
            itemCount: programs.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: TenkaiSpacing.sm),
            itemBuilder: (_, index) =>
                TenkaiListRow(title: programs[index].title),
          );
        },
      ),
    );
  }
}
