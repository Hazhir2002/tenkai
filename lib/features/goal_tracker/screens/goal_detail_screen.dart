import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/theme/tenkai_semantic_colors.dart';
import 'package:tenkai/core/tokens/tenkai_duration.dart';
import 'package:tenkai/core/tokens/tenkai_spacing.dart';
import 'package:tenkai/core/tokens/tenkai_typography.dart';
import 'package:tenkai/core/widgets/tenkai_metric_card.dart';
import 'package:tenkai/features/goal_tracker/enums/goal_status.dart';
import 'package:tenkai/features/goal_tracker/helper.dart';
import 'package:tenkai/features/goal_tracker/models/goal.dart';
import 'package:tenkai/features/goal_tracker/models/goal_model.dart';
import 'package:tenkai/features/goal_tracker/providers/goal_provider.dart';
import 'package:tenkai/features/goal_tracker/widgets/goal_card.dart';
import 'package:tenkai/features/goal_tracker/widgets/goal_form.dart';
import 'package:tenkai/features/goal_tracker/widgets/goal_pace_chart.dart';
import 'package:tenkai/features/goal_tracker/widgets/goal_ui.dart';
import 'package:tenkai/features/goal_tracker/widgets/log_value_form.dart';
import 'package:tenkai/features/goal_tracker/widgets/milestone_list.dart';

class GoalDetailScreen extends ConsumerStatefulWidget {
  const GoalDetailScreen({super.key, required this.goalId});

  final int goalId;

  @override
  ConsumerState<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends ConsumerState<GoalDetailScreen> {
  bool _isEditing = false;
  bool _isAddingSubgoal = false;

  @override
  void initState() {
    Future.microtask(
      () => ref.read(goalProvider.notifier).loadGoalDetails(widget.goalId),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goal = findGoalById(ref.watch(goalProvider).goals, widget.goalId);
    if (goal == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(goal.title),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : IconsaxOutline.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),

          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.add),
            onPressed: () {
              setState(() {
                _isAddingSubgoal = !_isAddingSubgoal;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        minimum: EdgeInsets.all(TenkaiSpacing.md),
        child: AnimatedSwitcher(
          duration: TenkaiDuration.fast,
          child: Builder(
            builder: (context) {
              if (_isEditing) {
                return GoalForm(existing: goal);
              } else if (_isAddingSubgoal) {
                return GoalForm(parentGoalId: goal.id);
              }
              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        Row(
                          children: [
                            _statusBadge(goal),
                            if (goal.hasPacing) ...[
                              const SizedBox(width: TenkaiSpacing.sm),
                              Chip(label: Text(goal.pace.label)),
                            ],
                          ],
                        ),
                        if (goal.description != null &&
                            goal.description!.isNotEmpty) ...[
                          const SizedBox(height: TenkaiSpacing.md),
                          Text(
                            goal.description!,
                            style: TenkaiTypography.bodyMd.copyWith(
                              color: context.tenkai.mutedForeground,
                            ),
                          ),
                        ],
                        const SizedBox(height: TenkaiSpacing.xl),
                        Text(
                          '${goal.currentValue} ${goal.unit} of '
                          '${goal.targetValue} ${goal.unit}',
                        ),
                        LinearProgressIndicator(value: goal.progress),
                        const SizedBox(height: TenkaiSpacing.xl),
                        _MetricGrid(goal: goal),
                        const SizedBox(height: TenkaiSpacing.xl),
                        Text('SUB GOALS', style: theme.textTheme.labelMedium),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(
                              bottom: TenkaiSpacing.xxxl,
                            ),
                            itemCount: goal.subGoals.length,
                            itemBuilder: (_, index) {
                              final subGoal = goal.subGoals[index];
                              return Dismissible(
                                key: ValueKey(subGoal.id),
                                direction: DismissDirection.endToStart,
                                // onDismissed: (_) => notifier.deleteGoal(subGoal.id),
                                // background: _deleteBackground(),
                                child: GoalCard(
                                  goal: subGoal,
                                  onTap: () =>
                                      context.push('/goals/${subGoal.id}'),
                                ),
                              );
                            },
                          ),
                        ),
                        Text(
                          'TREND',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: TenkaiSpacing.sm),

                        // logsAsync.when(
                        //   loading: () => const SizedBox(
                        //     height: 160,
                        //     child: Center(child: CircularProgressIndicator()),
                        //   ),
                        //   error: (_, __) => SizedBox(
                        //     height: 80,
                        //     child: Center(
                        //       child: Text(
                        //         'Could not load history',
                        //         style: TenkaiTypography.bodySmall.copyWith(
                        //           color: context.tenkai.secondaryForeground,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        //   data: (logs) => GoalPaceChart(goal: goal, logs: logs),
                        // ),
                        const SizedBox(height: TenkaiSpacing.xl),
                        // MilestoneList(goal: goal),
                        const SizedBox(height: TenkaiSpacing.xl),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => {},
                      child: Text(
                        goal.status == GoalStatus.archived
                            ? 'Archived'
                            : 'Log a value',
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(GoalModel goal) => switch (goal.status) {
    GoalStatus.completed => const Chip(
      label: Text('Completed'),
      backgroundColor: Colors.greenAccent,
    ),
    GoalStatus.archived => const Chip(label: Text('Archived')),
    GoalStatus.active => const Chip(label: Text('Active')),
  };

  // void _toggleArchive(WidgetRef ref, Goal goal) {
  //   final notifier = ref.read(goalProvider.notifier);
  //   if (goal.status == GoalStatus.archived) {
  //     notifier.reactivateGoal(goal.id);
  //   } else {
  //     notifier.archiveGoal(goal.id);
  //   }
  // }
}

/// A responsive 2-column grid of the goal's key numbers.
class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.goal});

  final GoalModel goal;

  @override
  Widget build(BuildContext context) {
    final metrics = <Widget>[
      TenkaiMetricCard(
        label: 'Current',
        value: goal.currentValue.toString(),
        subtext: goal.unit,
      ),
      TenkaiMetricCard(
        label: 'Target',
        value: goal.targetValue.toString(),
        subtext: goal.unit,
      ),
      if (goal.hasPacing)
        TenkaiMetricCard(
          label: 'Expected',
          value: goal.expectedValue!.toString(),
          subtext: 'on schedule today',
        ),
      if (goal.daysRemaining != null)
        TenkaiMetricCard(
          label: 'Days left',
          value: '${goal.daysRemaining}',
          subtext: goal.daysRemaining! < 0 ? 'past due' : null,
        ),
    ];

    return Column(
      children: [
        for (var i = 0; i < metrics.length; i += 2)
          Padding(
            padding: EdgeInsets.only(
              bottom: i + 2 < metrics.length ? TenkaiSpacing.md : 0,
            ),
            // IntrinsicHeight bounds the row's height so the stretched cards
            // match heights instead of forcing an infinite constraint inside
            // the (unbounded) ListView.
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: metrics[i]),
                  const SizedBox(width: TenkaiSpacing.md),
                  Expanded(
                    child: i + 1 < metrics.length
                        ? metrics[i + 1]
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// class _ErrorBody extends StatelessWidget {
//   const _ErrorBody({required this.onRetry});

//   final VoidCallback onRetry;

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             'Could not load this goal',
//             style: TenkaiTypography.bodyMd.copyWith(
//               color: context.tenkai.mutedForeground,
//             ),
//           ),
//           const SizedBox(height: TenkaiSpacing.lg),
//           OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
//         ],
//       ),
//     );
//   }
// }
