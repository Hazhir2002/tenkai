import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/core/widgets/tenkai_empty_state.dart';
import 'package:tenkai/features/fitness/providers/fitness_provider.dart';
import 'package:tenkai/features/fitness/widgets/program_form.dart';

class ProgramsScreen extends ConsumerWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programState = ref.watch(fitnessProvider);
    final c = context.tenkai;
    final theme = Theme.of(context);

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
            itemBuilder: (_, index) => ListTile(
              title: Text(programs[index].title),
              onTap: () =>
                  context.push('/fitness/programs/${programs[index].id}'),
              trailing: IconButton(
                onPressed: () => {
                  ref
                      .read(fitnessProvider.notifier)
                      .deleteProgram(programs[index].id),
                },
                icon: Icon(
                  IconsaxOutline.trash,
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
