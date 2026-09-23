import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_text_form_field.dart';
import 'package:tenkai/core/design_system/tenkai.dart';

import '../models/habit_enums.dart';
import '../models/habit_view.dart';
import '../providers/habit_form_provider.dart';
import '../providers/habits_provider.dart';

/// Opens the create/edit habit form. Seeds the shared [habitFormProvider]
/// synchronously (so the sheet renders with the right values immediately),
/// then presents it as a Tenkai bottom sheet.
Future<void> showHabitFormSheet(
  BuildContext context,
  WidgetRef ref, {
  HabitView? editing,
}) {
  final notifier = ref.read(habitFormProvider.notifier);
  if (editing != null) {
    notifier.startEdit(editing);
  } else {
    notifier.startCreate();
    notifier.addSlot(); // sensible default: one 08:00 daily slot
  }
  return showTenkaiSheet<void>(
    context: context,
    title: editing != null ? 'Edit habit' : 'New habit',
    child: _HabitFormSheet(editing: editing),
  );
}

class _HabitFormSheet extends HookConsumerWidget {
  const _HabitFormSheet({this.editing});

  final HabitView? editing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(habitFormProvider);
    final notifier = ref.read(habitFormProvider.notifier);

    final titleController = useTextEditingController(text: form.title);
    final descController = useTextEditingController(text: form.description);

    final maxHeight = MediaQuery.of(context).size.height * 0.72;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Habit'),
            const SizedBox(height: 6),
            TenkaiTextFormField(
              placeholder: 'e.g. Meditate for 2 minutes',
              controller: titleController,
              onChanged: notifier.setTitle,
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

            _label('Stage'),
            const SizedBox(height: 8),
            TenkaiRadioGroup<HabitStatus>(
              options: HabitStatus.values,
              labels: HabitStatus.values.map((s) => s.label).toList(),
              value: form.status,
              onChanged: notifier.setStatus,
            ),
            const SizedBox(height: 20),

            _label('Cue'),
            const SizedBox(height: 8),
            TenkaiRadioGroup<HabitCueType>(
              options: HabitCueType.values,
              labels: HabitCueType.values.map((c) => c.label).toList(),
              value: form.cueType,
              onChanged: notifier.setCueType,
            ),
            const SizedBox(height: 14),

            if (form.cueType == HabitCueType.afterHabit)
              _CuePicker(editingId: editing?.habit.id)
            else
              const _ScheduleBuilder(),

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
                label: editing != null ? 'Save changes' : 'Create habit',
                loading: form.saving,
                enabled: form.isValid && !form.saving,
                onPressed: () async {
                  final id = await notifier.save();
                  if (id != null && context.mounted) {
                    Navigator.of(context).pop();
                    showTenkaiToast(
                      context,
                      TenkaiToastData(
                        title: editing != null
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

  Widget _label(String text) =>
      Text(text.toUpperCase(), style: TenkaiTypography.labelMd);
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

/// Dynamic routine builder: any number of (weekday(s), time) slots.
class _ScheduleBuilder extends ConsumerWidget {
  const _ScheduleBuilder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(habitFormProvider);
    final notifier = ref.read(habitFormProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < form.slots.length; i++)
          _SlotEditor(
            slot: form.slots[i],
            onChanged: (s) => notifier.updateSlot(i, s),
            onRemove: form.slots.length > 1
                ? () => notifier.removeSlot(i)
                : null,
          ),
        const SizedBox(height: 8),
        TenkaiButton(
          label: 'Add time',
          variant: TenkaiButtonVariant.ghost,
          size: TenkaiButtonSize.sm,
          onPressed: () => notifier.addSlot(),
        ),
      ],
    );
  }
}

class _SlotEditor extends StatelessWidget {
  const _SlotEditor({
    required this.slot,
    required this.onChanged,
    this.onRemove,
  });

  final ScheduleSlotDraft slot;
  final ValueChanged<ScheduleSlotDraft> onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final picked = await _pickTime(
                      context,
                      slot.hour,
                      slot.minute,
                    );
                    if (picked != null) {
                      onChanged(
                        slot.copyWith(hour: picked.$1, minute: picked.$2),
                      );
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: context.tenkai.muted,
                      borderRadius: BorderRadius.circular(TenkaiRadius.control),
                      border: Border.all(
                        color: context.tenkai.border,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatHm(slot.hour, slot.minute),
                          style: TenkaiTypography.mono.copyWith(
                            color: context.tenkai.foreground,
                          ),
                        ),
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: context.tenkai.secondaryForeground,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (onRemove != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onRemove,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: context.tenkai.secondaryForeground,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              TenkaiChip(
                label: 'Daily',
                selected: slot.weekday == null,
                onTap: () => onChanged(slot.copyWith(weekday: null)),
              ),
              for (var d = 1; d <= 7; d++)
                TenkaiChip(
                  label: weekdayLabel(d),
                  selected: slot.weekday == d,
                  onTap: () => onChanged(slot.copyWith(weekday: d)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Presents a dark Cupertino time wheel; returns (hour, minute) or null.
Future<(int, int)?> _pickTime(
  BuildContext context,
  int hour,
  int minute,
) async {
  var h = hour;
  var m = minute;
  final ok = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: context.tenkai.card,
    builder: (sheetContext) {
      return CupertinoTheme(
        data: CupertinoThemeData(brightness: Theme.of(context).brightness),
        child: SizedBox(
          height: 300,
          child: Column(
            children: [
              SizedBox(
                height: 216,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: DateTime(2024, 1, 1, hour, minute),
                  onDateTimeChanged: (dt) {
                    h = dt.hour;
                    m = dt.minute;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: TenkaiButton(
                    label: 'Done',
                    onPressed: () => Navigator.of(sheetContext).pop(true),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  return ok == true ? (h, m) : null;
}
