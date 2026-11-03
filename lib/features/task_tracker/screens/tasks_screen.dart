import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/tokens/tenkai_colors.dart';
import 'package:tenkai/core/tokens/tenkai_radius.dart';
import 'package:tenkai/core/tokens/tenkai_spacing.dart';
import 'package:tenkai/core/widgets/tenkai_empty_state.dart';
import 'package:tenkai/core/widgets/tenkai_error_state_widget.dart';
import 'package:tenkai/features/task_tracker/providers/task_provider.dart';
import 'package:tenkai/features/task_tracker/widgets/create_task_form.dart';
import 'package:tenkai/features/task_tracker/widgets/task_card.dart';
import 'package:tenkai/features/task_tracker/widgets/task_status_filter.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  void _openCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        minimum: EdgeInsets.all(TenkaiSpacing.md),
        child: const CreateTaskForm(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskProvider);
    final notifier = ref.read(taskProvider.notifier);
    final filterState = ref.watch(taskFilterProvider);
    final filterNotifier = ref.read(taskFilterProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Tasks'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _openCreateSheet(context),
          ),
        ],
      ),
      body: SafeArea(
        minimum: EdgeInsets.all(TenkaiSpacing.md),
        child: Column(
          children: [
            TaskStatusFilter(
              selected: filterState,
              onSelected: filterNotifier.set,
            ),
            const SizedBox(height: TenkaiSpacing.sm),
            Expanded(
              child: state.when(
                data: (data) {
                  final tasks = data;
                  if (tasks.isEmpty) {
                    return const TenkaiEmptyState(title: 'No tasks yet');
                  }

                  final notifier = ref.read(taskProvider.notifier);
                  return RefreshIndicator(
                    onRefresh: notifier.build,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(
                        bottom: TenkaiSpacing.xxxl,
                      ),
                      itemCount: tasks.length,
                      itemBuilder: (_, index) {
                        final task = tasks[index];
                        return Dismissible(
                          key: ValueKey(task.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => notifier.deleteTask(task.id),
                          background: _deleteBackground(),
                          child: TaskCard(
                            task: task,
                            onToggleDone: (_) => notifier.toggleDone(task),
                          ),
                        );
                      },
                    ),
                  );
                },
                error: (error, stackTrace) => TenkaiErrorStateWidget(
                  message: error.toString(),
                  onRetry: () => notifier.build,
                ),
                loading: () => Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders the correct body for the current [TaskState]: spinner, error,
/// empty placeholder, or the task list.

Widget _deleteBackground() => Container(
  alignment: Alignment.centerRight,
  margin: const EdgeInsets.symmetric(
    horizontal: TenkaiSpacing.lg,
    vertical: TenkaiSpacing.xs,
  ),
  padding: const EdgeInsets.only(right: TenkaiSpacing.lg),
  decoration: BoxDecoration(
    color: TenkaiColors.errorDim,
    borderRadius: BorderRadius.circular(TenkaiRadius.md),
  ),
  child: const Icon(Icons.delete_outline, color: TenkaiColors.error),
);
