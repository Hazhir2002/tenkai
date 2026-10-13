import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/molecules/tenkai_molecules.dart';
import 'package:tenkai/core/widgets/tenkai_empty_state.dart';
import 'package:tenkai/features/fitness/providers/fitness_provider.dart';
import 'package:tenkai/features/fitness/widgets/session_excercise_form.dart';

class ProgramSessionDetailScreen extends ConsumerStatefulWidget {
  final int programId;
  final int programSessionId;

  const ProgramSessionDetailScreen({
    super.key,
    required this.programId,
    required this.programSessionId,
  });

  @override
  ConsumerState<ProgramSessionDetailScreen> createState() =>
      _ProgramSessionDetailScreenState();
}

class _ProgramSessionDetailScreenState
    extends ConsumerState<ProgramSessionDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(fitnessProvider.notifier)
          .listSessionExercises(widget.programId, widget.programSessionId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fitnessState = ref.watch(fitnessProvider);
    final programSession = fitnessState.programs!
        .where((element) => element.id == widget.programId)
        .first
        .programSessions!
        .where((element) => element.id == widget.programSessionId)
        .first;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              showTenkaiSheet(
                context: context,
                title: 'Add Session Exercise',
                child: SessionExerciseForm(
                  programId: widget.programId,
                  programSessionId: widget.programSessionId,
                ),
              );
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
          } else if (programSession.sessionExercises != null) {
            if (programSession.sessionExercises!.isEmpty) {
              return Center(
                child: TenkaiEmptyState(
                  title: 'No session exercises',
                  description: 'This session has no exercises',
                  action: FilledButton(
                    onPressed: () => {
                      showTenkaiSheet(
                        context: context,
                        title: 'Add Program Session',
                        child: SessionExerciseForm(
                          programId: widget.programId,
                          programSessionId: widget.programSessionId,
                        ),
                      ),
                    },
                    child: Text('Add Session'),
                  ),
                ),
              );
            }
            return Column(
              children: [
                ...programSession.sessionExercises!.map(
                  (ps) => Card(
                    child: ListTile(
                      title: Text(ps.title),
                      subtitle: Text(
                        "${ps.sets} sets with ${ps.repsStart} to ${ps.repsEnd} reps",
                      ),
                      // onTap: () => context.push(
                      //   '/fitness/programs/${ps.programId}/${ps.id}',
                      // ),
                      trailing: IconButton(
                        onPressed: () => {
                          ref
                              .read(fitnessProvider.notifier)
                              .deleteSessionExercise(
                                widget.programId,
                                widget.programSessionId,
                                ps.id,
                              ),
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
