import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/features/goal_tracker/providers/goal_provider.dart';
import 'package:tenkai/features/goal_tracker/widgets/create_goal_form.dart';
import 'package:tenkai/features/goal_tracker/widgets/goal_card.dart';
import 'package:tenkai/features/goal_tracker/widgets/goal_status_filter.dart';

/// The "Goals" tab: a filterable list of goals backed by [goalProvider].
/// Creating routes through a bottom sheet; each goal opens its detail screen.
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  void _openCreateSheet(BuildContext context) {
    showTenkaiSheet(
      context: context,
      title: 'New goal',
      child: const CreateGoalForm(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(goalProvider);
    final notifier = ref.read(goalProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Goals'),
        // showBackButton: false,
        actions: [
          // TenkaiAppBarAction(
          //   symbol: 'plus',
          //   onPressed: () => _openCreateSheet(context),
          // ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          children: [
            GoalStatusFilter(
              selected: state.filter,
              onSelected: notifier.setFilter,
            ),
            const SizedBox(height: TenkaiSpacing.sm),
            Expanded(child: _GoalListBody(state: state)),
          ],
        ),
      ),
    );
  }
}

class _GoalListBody extends ConsumerWidget {
  const _GoalListBody({required this.state});

  final GoalState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading && state.goals == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.goals == null) {
      return _ErrorState(
        message: state.error!,
        onRetry: () => ref.read(goalProvider.notifier).loadGoals(),
      );
    }

    final goals = state.visibleGoals;
    if (goals.isEmpty) {
      return _EmptyState(hasFilter: state.filter != null);
    }

    final notifier = ref.read(goalProvider.notifier);
    return RefreshIndicator(
      onRefresh: notifier.loadGoals,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: TenkaiSpacing.xxxl),
        itemCount: goals.length,
        itemBuilder: (_, index) {
          final goal = goals[index];
          return Dismissible(
            key: ValueKey(goal.id),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => notifier.deleteGoal(goal.id),
            background: _deleteBackground(),
            child: GoalCard(
              goal: goal,
              onTap: () => context.push('/goals/${goal.id}'),
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
  const _EmptyState({required this.hasFilter});

  final bool hasFilter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        hasFilter ? 'No goals here' : 'No goals yet — set your first one',
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
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
