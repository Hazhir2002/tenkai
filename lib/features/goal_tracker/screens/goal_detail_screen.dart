import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/theme/tenkai_semantic_colors.dart';
import 'package:tenkai/core/tokens/tenkai_spacing.dart';
import 'package:tenkai/core/tokens/tenkai_typography.dart';
import 'package:tenkai/core/widgets/tenkai_metric_card.dart';
import 'package:tenkai/features/goal_tracker/enums/goal_status.dart';
import 'package:tenkai/features/goal_tracker/models/goal.dart';
import 'package:tenkai/features/goal_tracker/providers/goal_provider.dart';
import 'package:tenkai/features/goal_tracker/widgets/create_goal_form.dart';
import 'package:tenkai/features/goal_tracker/widgets/goal_pace_chart.dart';
import 'package:tenkai/features/goal_tracker/widgets/goal_ui.dart';
import 'package:tenkai/features/goal_tracker/widgets/log_value_form.dart';
import 'package:tenkai/features/goal_tracker/widgets/milestone_list.dart';

class GoalDetailScreen extends ConsumerWidget {
  const GoalDetailScreen({super.key, required this.goalId});

  final String goalId;

  void _openLogSheet(BuildContext context, Goal goal) {
    showModalBottomSheet(
      context: context,
      // title: 'Log a value',
      builder: (context) => LogValueForm(goal: goal),
    );
  }

  void _openEditSheet(BuildContext context, Goal goal) {
    showModalBottomSheet(
      context: context,
      // title: 'Edit goal',
      builder: (context) => CreateGoalForm(existing: goal),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(goalDetailProvider(goalId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(goalAsync.valueOrNull?.title ?? 'Goal'),
        actions: [
          // if (goalAsync.hasValue) ...[
          //   AppBarAction(
          //     symbol: 'pencil',
          //     onPressed: () => _openEditSheet(context, goalAsync.value!),
          //   ),
          //   TenkaiAppBarAction(
          //     symbol: goalAsync.value!.status == GoalStatus.archived
          //         ? 'arrow.uturn.backward'
          //         : 'archivebox',
          //     onPressed: () => _toggleArchive(ref, goalAsync.value!),
          //   ),
          // ],
        ],
      ),
      body: goalAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _ErrorBody(
          onRetry: () => ref.invalidate(goalDetailProvider(goalId)),
        ),
        data: (goal) => _GoalDetailBody(
          goal: goal,
          onLog: () => _openLogSheet(context, goal),
        ),
      ),
    );
  }

  void _toggleArchive(WidgetRef ref, Goal goal) {
    final notifier = ref.read(goalProvider.notifier);
    if (goal.status == GoalStatus.archived) {
      notifier.reactivateGoal(goal.id);
    } else {
      notifier.archiveGoal(goal.id);
    }
  }
}

class _GoalDetailBody extends ConsumerWidget {
  const _GoalDetailBody({required this.goal, required this.onLog});

  final Goal goal;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(goalLogsProvider(goal.id));

    return ListView(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: TenkaiSpacing.lg,
        right: TenkaiSpacing.lg,
        bottom: TenkaiSpacing.xxxl,
      ),
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
        if (goal.description != null && goal.description!.isNotEmpty) ...[
          const SizedBox(height: TenkaiSpacing.md),
          Text(
            goal.description!,
            style: TenkaiTypography.bodyMd.copyWith(
              color: context.tenkai.mutedForeground,
            ),
          ),
        ],
        const SizedBox(height: TenkaiSpacing.xl),
        LinearProgressIndicator(
          value: goal.progress,
          // label:
          //     '${formatGoalValue(goal.currentValue, goal.unit)} of '
          //     '${formatGoalValue(goal.targetValue, goal.unit)}',
        ),
        const SizedBox(height: TenkaiSpacing.xl),
        _MetricGrid(goal: goal),
        const SizedBox(height: TenkaiSpacing.xl),
        Text('TREND', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: TenkaiSpacing.sm),
        logsAsync.when(
          loading: () => const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => SizedBox(
            height: 80,
            child: Center(
              child: Text(
                'Could not load history',
                style: TenkaiTypography.bodySmall.copyWith(
                  color: context.tenkai.secondaryForeground,
                ),
              ),
            ),
          ),
          data: (logs) => GoalPaceChart(goal: goal, logs: logs),
        ),
        const SizedBox(height: TenkaiSpacing.xl),
        MilestoneList(goal: goal),
        const SizedBox(height: TenkaiSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onLog,
            child: Text(
              goal.status == GoalStatus.archived ? 'Archived' : 'Log a value',
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(Goal goal) => switch (goal.status) {
    GoalStatus.completed => const Chip(
      label: Text('Completed'),
      backgroundColor: Colors.greenAccent,
    ),
    GoalStatus.archived => const Chip(label: Text('Archived')),
    GoalStatus.active => const Chip(label: Text('Active')),
  };
}

/// A responsive 2-column grid of the goal's key numbers.
class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final metrics = <Widget>[
      TenkaiMetricCard(
        label: 'Current',
        value: formatGoalValue(goal.currentValue),
        subtext: goal.unit,
      ),
      TenkaiMetricCard(
        label: 'Target',
        value: formatGoalValue(goal.targetValue),
        subtext: goal.unit,
      ),
      if (goal.hasPacing)
        TenkaiMetricCard(
          label: 'Expected',
          value: formatGoalValue(goal.expectedValue!),
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

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Could not load this goal',
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
