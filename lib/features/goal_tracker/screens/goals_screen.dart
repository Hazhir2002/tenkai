import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/tokens/tenkai_colors.dart';
import 'package:tenkai/core/tokens/tenkai_radius.dart';
import 'package:tenkai/core/tokens/tenkai_spacing.dart';
import 'package:tenkai/core/widgets/tenkai_empty_state.dart';
import 'package:tenkai/features/goal_tracker/providers/goal_provider.dart';
import 'package:tenkai/features/goal_tracker/widgets/goal_card.dart';
import 'package:tenkai/features/goal_tracker/widgets/goal_status_filter.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(goalProvider);
    final notifier = ref.read(goalProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Goals'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => context.push('/goals/new'),
          ),
        ],
      ),
      body: SafeArea(
        minimum: EdgeInsets.all(TenkaiSpacing.md),
        child: Column(
          children: [
            GoalStatusFilter(
              selected: state.filter,
              onSelected: notifier.setFilter,
            ),
            const SizedBox(height: TenkaiSpacing.sm),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (state.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state.error != null) {
                    return Text(state.error!);
                  }
                  final goals = state.visibleGoals;
                  if (goals.isEmpty) {
                    return TenkaiEmptyState(
                      title: state.filter != null
                          ? 'No goals here'
                          : 'No goals yet — set your first one',
                      description:
                          'Goals will give meaning to your life and help with daily motivation',
                      action: FilledButton(
                        onPressed: () {
                          context.push('/goals/new');
                        },
                        child: Text('Create Goal'),
                      ),
                    );
                  }

                  final notifier = ref.read(goalProvider.notifier);
                  return RefreshIndicator(
                    onRefresh: notifier.loadGoals,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(
                        bottom: TenkaiSpacing.xxxl,
                      ),
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
                },
              ),
            ),
          ],
        ),
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
