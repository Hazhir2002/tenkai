import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/theme/tenkai_semantic_colors.dart';
import 'package:tenkai/core/tokens/tenkai_spacing.dart';
import 'package:tenkai/core/tokens/tenkai_typography.dart';
import 'package:tenkai/core/widgets/tenkai_text_form_field.dart';
import 'package:tenkai/features/goal_tracker/models/goal_model.dart';
import 'package:tenkai/features/goal_tracker/providers/goal_provider.dart';

class GoalForm extends ConsumerStatefulWidget {
  const GoalForm({super.key, this.existing, this.parentGoalId});

  final GoalModel? existing;
  final int? parentGoalId;

  bool get isEditing => existing != null;

  @override
  ConsumerState<GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends ConsumerState<GoalForm> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _initialController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _goalValueController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final g = widget.existing;
    if (g == null) return;
    _titleController.text = g.title;
    _descriptionController.text = g.description ?? '';
    _unitController.text = g.unit ?? '';
    _initialController.text = g.initialValue.toString();
    _targetController.text = g.targetValue != null
        ? g.targetValue.toString()
        : '';
    _currentController.text = g.currentValue.toString();
    _startDate = g.startDate;
    _endDate = g.endDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _unitController.dispose();
    _initialController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    _goalValueController.dispose();
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
    // if (title.isEmpty) {
    //   _fail('Title is required');
    //   return;
    // }
    final target = double.tryParse(_targetController.text.trim());
    // if (target == null) {
    //   _fail('Enter a valid target value');
    //   return;
    // }
    // if (_startDate != null &&
    //     _endDate != null &&
    //     !_endDate!.isAfter(_startDate!)) {
    //   _fail('End date must be after the start date');
    //   return;
    // }

    final unit = _unitController.text.trim();
    final description = _descriptionController.text.trim();

    bool ok;
    if (widget.isEditing) {
      await ref
          .read(goalProvider.notifier)
          .updateGoal(
            GoalsCompanion(
              title: Value(title),
              description: Value(description),
              // initialValue: Value(initial),
              targetValue: Value(target),
              currentValue: Value(double.parse(_currentController.text)),
              unit: Value(unit),
              startDate: Value(_startDate),
              endDate: Value(_endDate),
            ),
          );
    } else {
      final initial = double.parse(_initialController.text.trim());
      // if (initial == null) {
      //   _fail('Enter a valid starting value');
      //   return;
      // }
      // if (initial == target) {
      //   _fail('Target must differ from the starting value');
      //   return;
      // }
      await ref
          .read(goalProvider.notifier)
          .createGoal(
            GoalsCompanion(
              title: Value(title),
              description: Value(description),
              initialValue: Value(initial),
              targetValue: Value(target),
              currentValue: Value(double.parse(_currentController.text)),
              unit: Value(unit),
              startDate: Value(_startDate),
              endDate: Value(_endDate),
              parentGoalId: Value(widget.parentGoalId),
              goalValueOnParentGoal: Value(
                double.tryParse(_goalValueController.text),
              ),
            ),
          );
    }

    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formkey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: TenkaiSpacing.md,
                children: [
                  TenkaiTextFormField(
                    isRequired: true,
                    controller: _titleController,
                    label: 'title',
                    placeholder: 'e.g. Bench press',
                    textInputAction: TextInputAction.next,
                    autofocus: !widget.isEditing,
                  ),
                  TenkaiTextFormField(
                    controller: _descriptionController,
                    label: 'description',
                    placeholder: 'Optional note',
                    maxLines: 3,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: TenkaiSpacing.sm,
                    children: [
                      if (!widget.isEditing) ...[
                        Expanded(
                          child: TenkaiTextFormField(
                            isRequired: true,
                            controller: _initialController,
                            label: 'start',
                            placeholder: '60',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
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
                      Expanded(
                        child: TenkaiTextFormField(
                          controller: _currentController,
                          isRequired: true,
                          label: 'current',
                          placeholder: '50',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TenkaiTextFormField(
                          controller: _unitController,
                          isRequired: true,
                          label: 'unit',
                          placeholder: 'kg',
                        ),
                      ),
                      if (widget.parentGoalId != null)
                        Expanded(
                          child: TenkaiTextFormField(
                            controller: _goalValueController,
                            isRequired: true,
                            label: 'goal value',
                            placeholder: '0.2',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                    ],
                  ),
                  _DateRow(
                    label: 'Start date',
                    date: _startDate,
                    onPick: () => _pickDate(isStart: true),
                    onClear: _startDate == null
                        ? null
                        : () => setState(() => _startDate = null),
                  ),
                  _DateRow(
                    label: 'End date',
                    date: _endDate,
                    onPick: () => _pickDate(isStart: false),
                    onClear: _endDate == null
                        ? null
                        : () => setState(() => _endDate = null),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submit,
              child: Text(widget.isEditing ? 'Save' : 'Create goal'),
            ),
          ),
        ],
      ),
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
              OutlinedButton(onPressed: onClear, child: Text('Clear')),
            OutlinedButton(
              onPressed: onPick,
              child: Text(date == null ? 'Set' : 'Change'),
            ),
          ],
        ),
      ],
    );
  }

  static String _pad(int v) => v.toString().padLeft(2, '0');
}
