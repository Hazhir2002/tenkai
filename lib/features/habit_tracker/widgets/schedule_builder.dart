import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/theme/tenkai_semantic_colors.dart';
import 'package:tenkai/core/tokens/tenkai_radius.dart';
import 'package:tenkai/core/tokens/tenkai_typography.dart';
import 'package:tenkai/features/habit_tracker/models/habit_enums.dart';
import 'package:tenkai/features/habit_tracker/models/schedule_slot_draft.dart';
import 'package:tenkai/features/habit_tracker/providers/habit_provider.dart';

class ScheduleBuilder extends ConsumerWidget {
  const ScheduleBuilder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final form = ref.watch(habitFormProvider);
    final habitState = ref.read(habitProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < habitState.habits.length; i++)
          _SlotEditor(
            // slot: habitState.habits[i],
            slot: ScheduleSlotDraft(hour: 1, minute: 1),
            // onChanged: (s) => notifier.updateSlot(i, s),
            onChanged: (s) => {},
            // onRemove: form.slots.length > 1
            //     ? () => notifier.removeSlot(i)
            //     : null,
          ),
        const SizedBox(height: 8),
        OutlinedButton(
          child: Text('Add time'),
          // onPressed: () => notifier.addSlot(),
          onPressed: () => {},
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
              ChoiceChip(
                label: Text('Daily'),
                selected: slot.weekday == null,
                onSelected: (value) => onChanged(slot.copyWith(weekday: null)),
              ),
              for (var d = 1; d <= 7; d++)
                ChoiceChip(
                  label: Text(weekdayLabel(d)),
                  selected: slot.weekday == d,
                  onSelected: (value) => onChanged(slot.copyWith(weekday: d)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

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
                  child: FilledButton.tonal(
                    child: Text('Done'),
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
