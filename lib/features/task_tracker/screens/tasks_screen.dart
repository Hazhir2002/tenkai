import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/features/task_tracker/providers/task_provider.dart';
import 'package:tenkai/features/task_tracker/widgets/create_task_form.dart';
import 'package:tenkai/features/task_tracker/widgets/task_card.dart';
import 'package:tenkai/features/task_tracker/widgets/task_status_filter.dart';

/// The main "Tasks" tab: a filterable, mutable list of tasks backed by
/// [taskProvider]. Toggling done / deleting / creating all route through the
/// notifier so the screen stays a thin, declarative view of state.
class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  void _openCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.tenkai.card,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: TenkaiSpacing.lg,
          right: TenkaiSpacing.lg,
          top: TenkaiSpacing.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + TenkaiSpacing.lg,
        ),
        child: const CreateTaskForm(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskProvider);
    final notifier = ref.read(taskProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: TenkaiAppBar(
        title: 'Tasks',
        showBackButton: false,
        actions: [
          TenkaiAppBarAction(
            symbol: 'plus',
            onPressed: () => _openCreateSheet(context),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + TenkaiAppBar.compactHeight,
        ),
        child: Column(
          children: [
            TaskStatusFilter(
              selected: state.filter,
              onSelected: notifier.setFilter,
            ),
            const SizedBox(height: TenkaiSpacing.sm),
            Expanded(child: _TaskListBody(state: state)),
          ],
        ),
      ),
    );
  }
}

/// Renders the correct body for the current [TaskState]: spinner, error,
/// empty placeholder, or the task list.
class _TaskListBody extends ConsumerWidget {
  const _TaskListBody({required this.state});

  final TaskState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // First load (no data yet).
    if (state.isLoading && state.tasks == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.tasks == null) {
      return _ErrorState(
        message: state.error!,
        onRetry: () => ref.read(taskProvider.notifier).loadTasks(),
      );
    }

    final tasks = state.visibleTasks;
    if (tasks.isEmpty) {
      return const _EmptyState();
    }

    final notifier = ref.read(taskProvider.notifier);
    return RefreshIndicator(
      onRefresh: notifier.loadTasks,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: TenkaiSpacing.xxxl),
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
  }

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
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No tasks yet',
        style: TenkaiTypography.bodyMd.copyWith(
          color: context.tenkai.secondaryForeground,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TenkaiTypography.bodyMd.copyWith(
              color: context.tenkai.mutedForeground,
            ),
          ),
          const SizedBox(height: TenkaiSpacing.lg),
          TenkaiButton(
            label: 'Retry',
            variant: TenkaiButtonVariant.ghost,
            size: TenkaiButtonSize.sm,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
