import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/tenkai.dart';

import '../models/habit_enums.dart';
import '../models/habit_view.dart';
import '../providers/habits_provider.dart';
import '../widgets/habit_detail_sheet.dart';
import '../widgets/habit_form_sheet.dart';
import '../widgets/habit_graph.dart';

class HabitDashboard extends HookConsumerWidget {
  const HabitDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final graphAsync = ref.watch(habitGraphProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Habits'),
        actions: [
          IconButton(
            onPressed: () => showHabitFormSheet(context, ref),
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(
        child: graphAsync.when(
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (err, _) => Center(
            child: Text(
              'Couldn\'t load habits: $err',
              style: TenkaiTypography.bodySmall,
            ),
          ),
          data: (roots) {
            if (roots.isEmpty) {
              return _EmptyState(onAdd: () => showHabitFormSheet(context, ref));
            }
            final all = _flatten(roots);
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                TenkaiSpacing.lg,
                TenkaiSpacing.md,
                TenkaiSpacing.lg,
                120,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HabitGraph(
                    roots: roots,
                    // onTap: (v) => showHabitDetailSheet(context, ref, v),
                    onTap: (v) =>
                        context.push('/habits/${v.habit.id}', extra: v),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

List<HabitView> _flatten(List<HabitView> roots) {
  final out = <HabitView>[];
  void walk(HabitView v) {
    out.add(v);
    for (final c in v.children) {
      walk(c);
    }
  }

  for (final r in roots) {
    walk(r);
  }
  return out;
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TenkaiSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TenkaiNode(size: 28),
            const SizedBox(height: TenkaiSpacing.xl),
            Text('No habits yet', style: TenkaiTypography.h2),
            const SizedBox(height: TenkaiSpacing.sm),
            Text(
              'Stack a new habit after something you already do,\nor set it on a schedule.',
              textAlign: TextAlign.center,
              style: TenkaiTypography.bodySmall,
            ),
            const SizedBox(height: TenkaiSpacing.xl),
            TenkaiButton(label: 'Add your first habit', onPressed: onAdd),
          ],
        ),
      ),
    );
  }
}
