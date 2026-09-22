import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/features/task_tracker/enums/task_status.dart';
import 'package:tenkai/features/task_tracker/params/create_task_param.dart';
import 'package:tenkai/features/task_tracker/providers/task_provider.dart';

/// Bottom-sheet form for creating a task. Collects a title (required),
/// optional context, a status, and an optional due date, then delegates
/// persistence to [TaskNotifier]. Closes itself on success.
class CreateTaskForm extends ConsumerStatefulWidget {
  const CreateTaskForm({super.key});

  @override
  ConsumerState<CreateTaskForm> createState() => _CreateTaskFormState();
}

class _CreateTaskFormState extends ConsumerState<CreateTaskForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contextController = TextEditingController();

  TaskStatus _status = TaskStatus.active;
  DateTime? _dueDate;
  String? _titleError;

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
    if (title.isEmpty) {
      setState(() => _titleError = 'Title is required');
      return;
    }
    setState(() => _titleError = null);

    final context_ = _contextController.text.trim();
    await ref
        .read(taskProvider.notifier)
        .createTask(
          CreateTaskParam(
            title: title,
            status: _status,
            context: context_.isEmpty ? null : context_,
            dueDate: _dueDate,
          ),
        );

    if (!mounted) return;
    // Only dismiss when the create actually succeeded.
    if (ref.read(taskProvider).error == null) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(taskProvider.select((s) => s.isLoading));

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New Task', style: TenkaiTypography.h2),
          const SizedBox(height: TenkaiSpacing.lg),
          TenkaiInput(
            controller: _titleController,
            label: 'title',
            placeholder: 'What needs doing?',
            textInputAction: TextInputAction.next,
            autofocus: true,
          ),
          if (_titleError != null) ...[
            const SizedBox(height: 6),
            Text(
              _titleError!,
              style: TenkaiTypography.labelSm.copyWith(
                color: TenkaiColors.error,
              ),
            ),
          ],
          const SizedBox(height: TenkaiSpacing.md),
          TenkaiInput(
            controller: _contextController,
            label: 'context',
            placeholder: '@home, @work…',
          ),
          const SizedBox(height: TenkaiSpacing.lg),
          Text('STATUS', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: TenkaiSpacing.sm),
          TenkaiRadioGroup<TaskStatus>(
            options: TaskStatus.values,
            labels: TaskStatus.values.map((s) => s.label).toList(),
            value: _status,
            onChanged: (status) => setState(() => _status = status),
          ),
          const SizedBox(height: TenkaiSpacing.lg),
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
              TenkaiButton(
                label: _dueDate == null ? 'Set date' : 'Change',
                variant: TenkaiButtonVariant.ghost,
                size: TenkaiButtonSize.sm,
                onPressed: _pickDueDate,
              ),
            ],
          ),
          const SizedBox(height: TenkaiSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: TenkaiButton(
              label: 'Create',
              loading: isLoading,
              onPressed: _submit,
            ),
          ),
        ],
      ),
    );
  }
}
