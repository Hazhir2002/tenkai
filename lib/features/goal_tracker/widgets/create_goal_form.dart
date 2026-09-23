import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_text_form_field.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/features/goal_tracker/models/goal.dart';
import 'package:tenkai/features/goal_tracker/params/create_goal_param.dart';
import 'package:tenkai/features/goal_tracker/params/update_goal_param.dart';
import 'package:tenkai/features/goal_tracker/providers/goal_provider.dart';
import 'package:tenkai/features/goal_tracker/widgets/goal_ui.dart';

/// Bottom-sheet form to create a goal, or edit an existing one when [existing]
/// is provided. Hosted inside [showTenkaiSheet], so it renders as a plain
/// column (the sheet supplies the title, scrolling and padding).
class CreateGoalForm extends ConsumerStatefulWidget {
  const CreateGoalForm({super.key, this.existing});

  final Goal? existing;

  bool get isEditing => existing != null;

  @override
  ConsumerState<CreateGoalForm> createState() => _CreateGoalFormState();
}

class _CreateGoalFormState extends ConsumerState<CreateGoalForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _unitController;
  late final TextEditingController _initialController;
  late final TextEditingController _targetController;

  DateTime? _startDate;
  DateTime? _endDate;
  String? _error;

  @override
  void initState() {
    super.initState();
    final g = widget.existing;
    _titleController = TextEditingController(text: g?.title ?? '');
    _descriptionController = TextEditingController(text: g?.description ?? '');
    _unitController = TextEditingController(text: g?.unit ?? '');
    _initialController = TextEditingController(
      text: g == null ? '' : formatGoalValue(g.initialValue),
    );
    _targetController = TextEditingController(
      text: g == null ? '' : formatGoalValue(g.targetValue),
    );
    _startDate = g?.startDate;
    _endDate = g?.endDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _unitController.dispose();
    _initialController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = (isStart ? _startDate : _endDate) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _fail('Title is required');
      return;
    }
    final target = double.tryParse(_targetController.text.trim());
    if (target == null) {
      _fail('Enter a valid target value');
      return;
    }
    if (_startDate != null &&
        _endDate != null &&
        !_endDate!.isAfter(_startDate!)) {
      _fail('End date must be after the start date');
      return;
    }

    final unit = _unitController.text.trim();
    final description = _descriptionController.text.trim();

    bool ok;
    if (widget.isEditing) {
      ok = await ref
          .read(goalProvider.notifier)
          .updateGoal(
            widget.existing!.id,
            UpdateGoalParam(
              title: title,
              description: description,
              unit: unit,
              targetValue: target,
              startDate: _startDate,
              endDate: _endDate,
            ),
          );
    } else {
      final initial = double.tryParse(_initialController.text.trim());
      if (initial == null) {
        _fail('Enter a valid starting value');
        return;
      }
      if (initial == target) {
        _fail('Target must differ from the starting value');
        return;
      }
      ok = await ref
          .read(goalProvider.notifier)
          .createGoal(
            CreateGoalParam(
              title: title,
              initialValue: initial,
              targetValue: target,
              description: description,
              unit: unit,
              startDate: _startDate,
              endDate: _endDate,
            ),
          );
    }

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      _fail(ref.read(goalProvider).error ?? 'Something went wrong');
    }
  }

  void _fail(String message) {
    setState(() => _error = message);
    HapticFeedback.vibrate();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(goalProvider.select((s) => s.isLoading));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_error != null) ...[
          Text(
            _error!,
            style: TenkaiTypography.labelSm.copyWith(color: TenkaiColors.error),
          ),
          const SizedBox(height: TenkaiSpacing.md),
        ],
        TenkaiTextFormField(
          controller: _titleController,
          label: 'title',
          placeholder: 'e.g. Bench press',
          textInputAction: TextInputAction.next,
          autofocus: !widget.isEditing,
        ),
        const SizedBox(height: TenkaiSpacing.md),
        TenkaiTextFormField(
          controller: _descriptionController,
          label: 'description',
          placeholder: 'Optional note',
        ),
        const SizedBox(height: TenkaiSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!widget.isEditing) ...[
              Expanded(
                child: TenkaiTextFormField(
                  controller: _initialController,
                  label: 'start',
                  placeholder: '60',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              const SizedBox(width: TenkaiSpacing.md),
            ],
            Expanded(
              child: TenkaiTextFormField(
                controller: _targetController,
                label: 'target',
                placeholder: '100',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
            const SizedBox(width: TenkaiSpacing.md),
            Expanded(
              child: TenkaiTextFormField(
                controller: _unitController,
                label: 'unit',
                placeholder: 'kg',
              ),
            ),
          ],
        ),
        const SizedBox(height: TenkaiSpacing.lg),
        _DateRow(
          label: 'Start date',
          date: _startDate,
          onPick: () => _pickDate(isStart: true),
          onClear: _startDate == null
              ? null
              : () => setState(() => _startDate = null),
        ),
        const SizedBox(height: TenkaiSpacing.sm),
        _DateRow(
          label: 'End date',
          date: _endDate,
          onPick: () => _pickDate(isStart: false),
          onClear: _endDate == null
              ? null
              : () => setState(() => _endDate = null),
        ),
        const SizedBox(height: TenkaiSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: TenkaiButton(
            label: widget.isEditing ? 'Save' : 'Create goal',
            loading: isLoading,
            onPressed: _submit,
          ),
        ),
      ],
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.label,
    required this.date,
    required this.onPick,
    this.onClear,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          date == null
              ? '$label — none'
              : '$label — ${date!.year}-${_pad(date!.month)}-${_pad(date!.day)}',
          style: TenkaiTypography.bodyMd.copyWith(
            color: context.tenkai.mutedForeground,
          ),
        ),
        Row(
          children: [
            if (onClear != null)
              TenkaiButton(
                label: 'Clear',
                variant: TenkaiButtonVariant.ghost,
                size: TenkaiButtonSize.sm,
                onPressed: onClear,
              ),
            TenkaiButton(
              label: date == null ? 'Set' : 'Change',
              variant: TenkaiButtonVariant.ghost,
              size: TenkaiButtonSize.sm,
              onPressed: onPick,
            ),
          ],
        ),
      ],
    );
  }

  static String _pad(int v) => v.toString().padLeft(2, '0');
}
