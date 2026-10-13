import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/widgets/tenkai_text_form_field.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/features/habit_tracker/providers/habit_provider.dart';
import 'package:tenkai/features/habit_tracker/widgets/schedule_builder.dart';

import '../models/habit_enums.dart';
import '../models/habit_view.dart';
import '../providers/habits_provider.dart';

class HabitForm extends ConsumerStatefulWidget {
  const HabitForm({super.key, this.editing});

  final HabitView? editing;

  @override
  ConsumerState<HabitForm> createState() => _HabitFormState();
}

class _HabitFormState extends ConsumerState<HabitForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descController = TextEditingController();
  HabitStatus? _habitStatus = .building;
  HabitCueType? _cueType = .time;
  bool _reminderEnabled = true;
  int? _cueHabitId;

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habitState = ref.read(habitProvider);
    final habitNotifier = ref.read(habitProvider.notifier);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TenkaiTextFormField(
                    isRequired: true,
                    placeholder: 'e.g. Meditate for 2 minutes',
                    controller: titleController,
                    label: 'Habit',
                  ),
                  const SizedBox(height: 16),
                  TenkaiTextFormField(
                    label: 'Details',
                    placeholder: 'What exactly will you do?',
                    controller: descController,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Stage *'.toUpperCase(),
                    style: theme.textTheme.labelMedium,
                  ),
                  RadioGroup<HabitStatus>(
                    groupValue: _habitStatus,
                    onChanged: (HabitStatus? value) {
                      setState(() {
                        _habitStatus = value;
                      });
                    },
                    child: const Column(
                      children: <Widget>[
                        RadioListTile<HabitStatus>(
                          title: Text('Estasblished'),
                          value: HabitStatus.established,
                          contentPadding: EdgeInsets.all(0),
                        ),
                        RadioListTile<HabitStatus>(
                          title: Text('Building'),
                          value: HabitStatus.building,
                          contentPadding: EdgeInsets.all(0),
                        ),
                        RadioListTile<HabitStatus>(
                          title: Text('Planned'),
                          value: HabitStatus.planned,
                          contentPadding: EdgeInsets.all(0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Cue *'.toUpperCase(),
                    style: theme.textTheme.labelMedium,
                  ),
                  RadioGroup<HabitCueType>(
                    groupValue: _cueType,
                    onChanged: (HabitCueType? value) {
                      setState(() {
                        _cueType = value;
                      });
                    },
                    child: const Column(
                      children: <Widget>[
                        RadioListTile<HabitCueType>(
                          title: Text('At a time'),
                          value: HabitCueType.time,
                          contentPadding: EdgeInsets.all(0),
                        ),
                        RadioListTile<HabitCueType>(
                          title: Text('After a habit'),
                          value: HabitCueType.afterHabit,
                          contentPadding: EdgeInsets.all(0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (_cueType == HabitCueType.afterHabit)
                    DropdownMenuFormField<int>(
                      width: double.infinity,
                      dropdownMenuEntries: [
                        ...habitState.habits.map(
                          (habit) => DropdownMenuEntry<int>(
                            value: habit.id,
                            label: habit.title,
                          ),
                        ),
                      ],
                      onSelected: (value) {},
                    ),
                  // _CuePicker(editingId: widget.editing?.habit.id),

                  // else
                  //   const ScheduleBuilder(),
                  const SizedBox(height: 20),
                  CheckboxListTile(
                    value: _reminderEnabled,
                    onChanged: (value) => setState(() {
                      _reminderEnabled = value!;
                    }),
                    title: Text('Remind me'),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: true
                  ? () async {
                      await habitNotifier.createHabit(
                        HabitsCompanion(),
                        slots: [],
                      );
                      if (context.mounted) {
                        context.pop();
                        // showTenkaiToast(
                        //   context,
                        //   TenkaiToastData(
                        //     title: widget.editing != null
                        //         ? 'Habit updated'
                        //         : 'Habit added',
                        //     variant: TenkaiToastVariant.success,
                        //   ),
                        // );
                      }
                    }
                  : null,
              child: Text(
                widget.editing != null ? 'Save changes' : 'Create habit',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Picker for "after a habit" cue: a selectable list of existing habits.
class _CuePicker extends ConsumerWidget {
  const _CuePicker({this.editingId, this.cueHabitId});

  final int? editingId;
  final int? cueHabitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final habitsAsync = ref.watch(habitsProvider);

    return habitsAsync.when(
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (_, _) =>
          Text('Couldn\'t load habits', style: TenkaiTypography.bodySmall),
      data: (habits) {
        final options = habits.where((h) => h.id != editingId).toList();
        if (options.isEmpty) {
          return Text(
            'Create a habit first to stack this one after it.',
            style: TenkaiTypography.bodySmall,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('After:', style: theme.textTheme.labelMedium),
            Wrap(
              spacing: TenkaiSpacing.sm,
              children: [
                ...options.map(
                  (h) => ChoiceChip(
                    label: Text(h.title),
                    selected: cueHabitId == h.id,
                    // onSelected: (value) => notifier.setCueHabit(h.id),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
