import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/core/providers.dart';
import 'package:tenkai/core/services/notification_service.dart';

import '../models/habit_enums.dart';
import '../models/habit_view.dart';
import '../providers/habits_provider.dart';
import 'habit_form.dart';

/// Opens the detail sheet for a habit node: shows its cue and today's status,
/// and lets the user mark it done, edit, or delete it.
Future<void> showHabitDetailSheet(
  BuildContext context,
  WidgetRef ref,
  HabitView view,
) {
  return showTenkaiSheet<void>(
    context: context,
    title: view.habit.title,
    child: _HabitDetailSheet(view: view),
  );
}

class _HabitDetailSheet extends ConsumerWidget {
  const _HabitDetailSheet({required this.view});

  final HabitView view;

  Future<void> _markDone(BuildContext context, WidgetRef ref) async {
    final db = ref.read(appDataBaseProvider);
    await db.habitDao.markHabitDone(view.habit.id, dateKeyFor());
    // Schedule follow-up reminders for anything stacked after this habit.
    final all = await db.habitDao.getAllHabits();
    // await ref
    //     .read(notificationServiceProvider)
    //     .scheduleAfterCueReminders(view.habit.id, all);
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _undo(BuildContext context, WidgetRef ref) async {
    await ref
        .read(appDataBaseProvider)
        .habitDao
        .unmarkHabitDone(view.habit.id, dateKeyFor());
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    await ref.read(appDataBaseProvider).habitDao.deleteHabit(view.habit.id);
    // await ref.read(notificationServiceProvider).cancelHabit(view.habit.id);
    if (context.mounted) {
      Navigator.of(context).pop();
      showTenkaiToast(
        context,
        const TenkaiToastData(
          title: 'Habit deleted',
          variant: TenkaiToastVariant.info,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = view.isDoneToday;
    final habit = view.habit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TenkaiBadge(label: view.status.label),
            const SizedBox(width: 8),
            TenkaiBadge(
              label: view.cueType.label,
              variant: TenkaiBadgeVariant.active,
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (habit.description != null && habit.description!.isNotEmpty) ...[
          Text(habit.description!, style: TenkaiTypography.bodyMd),
          const SizedBox(height: 16),
        ],

        _label('Cue'),
        const SizedBox(height: 6),
        Text(view.cueDescription(), style: TenkaiTypography.bodyMd),

        if (view.cueType == HabitCueType.time && view.schedules.isNotEmpty) ...[
          const SizedBox(height: 16),
          _label('Routine'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in view.schedules)
                TenkaiBadge(
                  label:
                      '${weekdayLabel(s.weekday)} ${formatHm(s.hour, s.minute)}',
                ),
            ],
          ),
        ],

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () =>
                done ? _undo(context, ref) : _markDone(context, ref),
            child: Text(done ? 'Mark as not done' : 'Mark done for today'),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                child: const Text('Edit'),
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push('/habits/new');
                  // showHabitFormSheet(context, ref, editing: view);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                style: Theme.of(context).filledButtonTheme.style!.copyWith(
                  backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.error,
                  ),
                ),
                onPressed: () => _delete(context, ref),
                child: Text('Delete'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _label(String text) =>
      Text(text.toUpperCase(), style: TenkaiTypography.labelMd);
}
