import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/molecules/tenkai_molecules.dart';
import 'package:tenkai/core/widgets/tenkai_empty_state.dart';
import 'package:tenkai/features/fitness/providers/fitness_provider.dart';
import 'package:tenkai/features/fitness/widgets/program_session_form.dart';

class ProgramDetailScreen extends ConsumerStatefulWidget {
  final int programId;

  const ProgramDetailScreen({super.key, required this.programId});

  @override
  ConsumerState<ProgramDetailScreen> createState() =>
      _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends ConsumerState<ProgramDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(fitnessProvider.notifier)
          .listProgramSessions(widget.programId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fitnessState = ref.watch(fitnessProvider);

    final program = fitnessState.programs!
        .where((p) => p.id == widget.programId)
        .first;

    return Scaffold(
      appBar: AppBar(
        title: Text(program.title),
        actions: [
          IconButton(
            onPressed: () => {
              showTenkaiSheet(
                context: context,
                title: 'Add Program Session',
                child: ProgramSessionForm(programId: widget.programId),
              ),
            },
            icon: Icon(IconsaxOutline.add),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (fitnessState.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (fitnessState.error != null) {
            return Center(child: Text(fitnessState.error!));
          } else if (program.programSessions != null) {
            if (program.programSessions!.isEmpty) {
              return Center(
                child: TenkaiEmptyState(
                  title: 'No program sessions',
                  description: 'This program has no sessions',
                  action: FilledButton(
                    onPressed: () => {
                      showTenkaiSheet(
                        context: context,
                        title: 'Add Program Session',
                        child: ProgramSessionForm(programId: widget.programId),
                      ),
                    },
                    child: Text('Add Session'),
                  ),
                ),
              );
            }
            return Column(
              children: [
                ...program.programSessions!.map(
                  (ps) => Card(
                    child: ListTile(
                      title: Text(ps.title),
                      onTap: () => context.push(
                        '/fitness/programs/${ps.programId}/${ps.id}',
                      ),
                      trailing: IconButton(
                        onPressed: () => {
                          ref
                              .read(fitnessProvider.notifier)
                              .deleteProgramSession(widget.programId, ps.id),
                        },
                        icon: Icon(
                          IconsaxOutline.trash,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
