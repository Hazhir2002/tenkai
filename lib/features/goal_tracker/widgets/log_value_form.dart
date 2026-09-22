import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/features/goal_tracker/models/goal.dart';
import 'package:tenkai/features/goal_tracker/params/log_value_param.dart';
import 'package:tenkai/features/goal_tracker/providers/goal_provider.dart';
import 'package:tenkai/features/goal_tracker/widgets/goal_ui.dart';

/// Bottom-sheet form to record a new value for a goal. A slider (bounded by the
/// initial→target range) and a numeric field stay in sync; the field is the
/// source of truth so values beyond the target are still allowed.
class LogValueForm extends ConsumerStatefulWidget {
  const LogValueForm({super.key, required this.goal});

  final Goal goal;

  @override
  ConsumerState<LogValueForm> createState() => _LogValueFormState();
}

class _LogValueFormState extends ConsumerState<LogValueForm> {
  late final TextEditingController _valueController;
  final TextEditingController _noteController = TextEditingController();
  bool _submitting = false;
  String? _error;

  double get _min => widget.goal.initialValue < widget.goal.targetValue
      ? widget.goal.initialValue
      : widget.goal.targetValue;
  double get _max => widget.goal.initialValue > widget.goal.targetValue
      ? widget.goal.initialValue
      : widget.goal.targetValue;

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController(
      text: formatGoalValue(widget.goal.currentValue),
    );
    _valueController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _valueController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double get _sliderValue {
    final parsed = double.tryParse(_valueController.text) ?? _min;
    return parsed.clamp(_min, _max);
  }

  Future<void> _submit() async {
    final value = double.tryParse(_valueController.text.trim());
    if (value == null) {
      setState(() => _error = 'Enter a valid number');
      HapticFeedback.vibrate();
      return;
    }
    setState(() {
      _error = null;
      _submitting = true;
    });

    final wasCompleted = widget.goal.isCompleted;
    final updated = await ref
        .read(goalProvider.notifier)
        .logValue(
          widget.goal.id,
          LogValueParam(
            value: value,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          ),
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (updated == null) {
      setState(() => _error = ref.read(goalProvider).error ?? 'Failed to log');
      HapticFeedback.vibrate();
      return;
    }

    final justCompleted = updated.isCompleted && !wasCompleted;
    Navigator.of(context).pop();
    showTenkaiToast(
      context,
      justCompleted
          ? TenkaiToastData(
              title: 'Goal complete! 🎉',
              message: '“${updated.title}” hit its target.',
              variant: TenkaiToastVariant.success,
            )
          : const TenkaiToastData(
              title: 'Value logged',
              variant: TenkaiToastVariant.success,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;
    final unit = goal.unit ?? '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current: ${formatGoalValue(goal.currentValue, unit)}  ·  '
          'Target: ${formatGoalValue(goal.targetValue, unit)}',
          style: TenkaiTypography.bodySmall.copyWith(
            color: context.tenkai.secondaryForeground,
          ),
        ),
        const SizedBox(height: TenkaiSpacing.lg),
        if (_error != null) ...[
          Text(
            _error!,
            style: TenkaiTypography.labelSm.copyWith(color: TenkaiColors.error),
          ),
          const SizedBox(height: TenkaiSpacing.sm),
        ],
        TenkaiInput(
          controller: _valueController,
          label: 'new value',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          suffix: unit.isEmpty
              ? null
              : Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(unit, style: TenkaiTypography.labelMd),
                ),
        ),
        if (_max > _min) ...[
          const SizedBox(height: TenkaiSpacing.md),
          TenkaiSlider(
            value: _sliderValue,
            min: _min,
            max: _max,
            showValue: false,
            onChanged: (v) => _valueController.text = formatGoalValue(v),
          ),
        ],
        const SizedBox(height: TenkaiSpacing.md),
        TenkaiInput(
          controller: _noteController,
          label: 'note',
          placeholder: 'Optional — how did it go?',
        ),
        const SizedBox(height: TenkaiSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: TenkaiButton(
            label: 'Log value',
            loading: _submitting,
            onPressed: _submit,
          ),
        ),
      ],
    );
  }
}
