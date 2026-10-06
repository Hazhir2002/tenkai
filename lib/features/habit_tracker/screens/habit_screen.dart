import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_button.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_display.dart';
import 'package:tenkai/core/design_system/molecules/tenkai_molecules.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/core/design_system/tokens/tenkai_typography.dart';
import 'package:tenkai/core/providers.dart';
import 'package:tenkai/core/services/notification_service.dart';
import 'package:tenkai/features/habit_tracker/models/habit_enums.dart';
import 'package:tenkai/features/habit_tracker/models/habit_view.dart';
import 'package:tenkai/features/habit_tracker/providers/habits_provider.dart';
import 'package:tenkai/features/habit_tracker/widgets/habit_form_sheet.dart';

class HabitScreen extends ConsumerWidget {
  final HabitView habitView;

  const HabitScreen({super.key, required this.habitView});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final habit = habitView.habit;
    final done = habitView.isDoneToday;

    Future<void> _markDone(BuildContext context, WidgetRef ref) async {
      final db = ref.read(appDataBaseProvider);
      await db.habitDao.markHabitDone(habitView.habit.id, dateKeyFor());
      // Schedule follow-up reminders for anything stacked after this habit.
      final all = await db.habitDao.getAllHabits();
      // await ref
      //     .read(notificationServiceProvider)
      //     .scheduleAfterCueReminders(habitView.habit.id, all);
      if (context.mounted) Navigator.of(context).pop();
    }

    Future<void> _undo(BuildContext context, WidgetRef ref) async {
      await ref
          .read(appDataBaseProvider)
          .habitDao
          .unmarkHabitDone(habitView.habit.id, dateKeyFor());
      if (context.mounted) Navigator.of(context).pop();
    }

    Future<void> _delete(BuildContext context, WidgetRef ref) async {
      // await ref
      //     .read(appDataBaseProvider)
      //     .habitDao
      //     .deleteHabit(habitView.habit.id);
      // await ref
      //     .read(notificationServiceProvider)
      //     .cancelHabit(habitView.habit.id);
      // if (context.mounted) {
      //   Navigator.of(context).pop();
      //   showTenkaiToast(
      //     context,
      //     const TenkaiToastData(
      //       title: 'Habit deleted',
      //       variant: TenkaiToastVariant.info,
      //     ),
      //   );
      // }
    }

    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'habit-title-${habitView.habit.id}',
          child: Text(habitView.habit.title),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
              showHabitFormSheet(context, ref, editing: habitView);
            },
            icon: Icon(Icons.edit_square),
          ),
          IconButton(
            onPressed: () => _delete(context, ref),
            icon: Icon(Icons.delete),
          ),
        ],
      ),
      persistentFooterButtons: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            child: Text(done ? 'Mark as not done' : 'Mark done for today'),
            onPressed: () =>
                done ? _undo(context, ref) : _markDone(context, ref),
          ),
        ),
      ],
      body: SafeArea(
        minimum: EdgeInsets.all(TenkaiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TenkaiBadge(label: habitView.status.label),
                const SizedBox(width: 8),
                TenkaiBadge(
                  label: habitView.cueType.label,
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
            Text(habitView.cueDescription(), style: TenkaiTypography.bodyMd),

            if (habitView.cueType == HabitCueType.time &&
                habitView.schedules.isNotEmpty) ...[
              const SizedBox(height: 16),
              _label('Routine'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final s in habitView.schedules)
                    TenkaiBadge(
                      label:
                          '${weekdayLabel(s.weekday)} ${formatHm(s.hour, s.minute)}',
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Widget _label(String text) =>
    Text(text.toUpperCase(), style: TenkaiTypography.labelMd);
