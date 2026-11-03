import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/theme/tenkai_semantic_colors.dart'
    show TenkaiSemanticColorsX;
import 'package:tenkai/core/tokens/tenkai_spacing.dart';
import 'package:tenkai/core/tokens/tenkai_typography.dart';
import 'package:tenkai/core/widgets/tenkai_text_form_field.dart';
import 'package:tenkai/features/task_tracker/enums/task_status.dart';
import 'package:tenkai/features/task_tracker/params/create_task_param.dart';
import 'package:tenkai/features/task_tracker/providers/task_provider.dart';

class CreateTaskForm extends ConsumerStatefulWidget {
  const CreateTaskForm({super.key});

  @override
  ConsumerState<CreateTaskForm> createState() => _CreateTaskFormState();
}

class _CreateTaskFormState extends ConsumerState<CreateTaskForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contextController = TextEditingController();
  DateTime? _dueDate;

  @override
  void dispose() {
    _titleController.dispose();
    _contextController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final context_ = _contextController.text.trim();
    await ref
        .read(taskProvider.notifier)
        .createTask(
          CreateTaskParam(
            title: title,
            status: TaskStatus.active,
            context: context_.isEmpty ? null : context_,
            dueDate: _dueDate,
          ),
        );

    if (!mounted) return;
    if (ref.read(taskProvider).error == null) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: TenkaiSpacing.md,
      children: [
        TenkaiTextFormField(
          controller: _titleController,
          label: 'title',
          placeholder: 'What needs doing?',
          textInputAction: TextInputAction.next,
          autofocus: true,
        ),
        TenkaiTextFormField(
          controller: _contextController,
          label: 'context',
          placeholder: '@home, @work…',
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _dueDate == null
                  ? 'No due date'
                  : 'Due ${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}',
              style: TenkaiTypography.bodyMd.copyWith(
                color: context.tenkai.mutedForeground,
              ),
            ),
            OutlinedButton(
              onPressed: _pickDueDate,
              child: Text(_dueDate == null ? 'Set date' : 'Change'),
            ),
          ],
        ),
        const SizedBox(height: TenkaiSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: FilledButton(onPressed: _submit, child: const Text('Create')),
        ),
      ],
    );
  }
}
