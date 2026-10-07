import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_text_form_field.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/features/habit_tracker/widgets/schedule_builder.dart';

import '../models/habit_enums.dart';
import '../models/habit_view.dart';
import '../providers/habit_form_provider.dart';
import '../providers/habits_provider.dart';

class HabitForm extends ConsumerStatefulWidget {
  const HabitForm({super.key, this.editing});

  final HabitView? editing;

  @override
  ConsumerState<HabitForm> createState() => _HabitFormState();
}

class _HabitFormState extends ConsumerState<HabitForm> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  HabitStatus? _habitStatus = .building;
  HabitCueType? _cueType = .time;

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final form = ref.watch(habitFormProvider);
    final notifier = ref.read(habitFormProvider.notifier);

    return SingleChildScrollView(
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TenkaiTextFormField(
              placeholder: 'e.g. Meditate for 2 minutes',
              controller: titleController,
              onChanged: notifier.setTitle,
              label: 'Habit',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TenkaiTextFormField(
              label: 'Details (optional)',
              placeholder: 'What exactly will you do?',
              controller: descController,
              maxLines: 2,
              onChanged: notifier.setDescription,
            ),
            const SizedBox(height: 20),

            Text('Stage'.toUpperCase(), style: theme.textTheme.labelMedium),
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

            Text('Cue'.toUpperCase(), style: theme.textTheme.labelMedium),
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

            if (form.cueType == HabitCueType.afterHabit)
              _CuePicker(editingId: widget.editing?.habit.id)
            else
              const ScheduleBuilder(),

            const SizedBox(height: 20),
            const TenkaiDivider(),
            const SizedBox(height: 16),

            TenkaiToggle(
              value: form.reminderEnabled,
              onChanged: notifier.setReminderEnabled,
              label: 'Remind me',
            ),
            if (form.reminderEnabled &&
                form.cueType == HabitCueType.afterHabit) ...[
              const SizedBox(height: 16),
              TenkaiSlider(
                label: 'Remind this long after the cue (min)',
                value: form.reminderOffsetMinutes.toDouble(),
                min: 0,
                max: 120,
                divisions: 24,
                valueFormatter: (v) => '${v.round()} min',
                onChanged: (v) => notifier.setReminderOffset(v.round()),
              ),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: TenkaiButton(
                label: widget.editing != null ? 'Save changes' : 'Create habit',
                loading: form.saving,
                enabled: form.isValid && !form.saving,
                onPressed: () async {
                  final id = await notifier.save();
                  if (id != null && context.mounted) {
                    Navigator.of(context).pop();
                    showTenkaiToast(
                      context,
                      TenkaiToastData(
                        title: widget.editing != null
                            ? 'Habit updated'
                            : 'Habit added',
                        variant: TenkaiToastVariant.success,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Picker for "after a habit" cue: a selectable list of existing habits.
class _CuePicker extends ConsumerWidget {
  const _CuePicker({this.editingId});

  final int? editingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);
    final form = ref.watch(habitFormProvider);
    final notifier = ref.read(habitFormProvider.notifier);

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
            for (final h in options)
              GestureDetector(
                onTap: () {
                  notifier.setCueHabit(h.id);
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      _RadioDot(selected: form.cueHabitId == h.id),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'After ${h.title}',
                          style: TenkaiTypography.bodyMd.copyWith(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: selected ? c.accent : c.border, width: 1),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.accent,
                ),
              ),
            )
          : null,
    );
  }
}
