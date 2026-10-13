import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/widgets/tenkai_text_form_field.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/features/goal_tracker/models/goal.dart';
import 'package:tenkai/features/goal_tracker/models/milestone.dart';
import 'package:tenkai/features/goal_tracker/params/milestone_param.dart';
import 'package:tenkai/features/goal_tracker/providers/goal_provider.dart';
import 'package:tenkai/features/goal_tracker/widgets/goal_ui.dart';

/// The milestones section of the goal detail screen: an add button plus the
/// list of checkpoints, each marked as achieved once a logged value crosses it.
class MilestoneList extends ConsumerWidget {
  const MilestoneList({super.key, required this.goal});

  final Goal goal;

  void _openForm(BuildContext context, {Milestone? existing}) {
    showModalBottomSheet(
      context: context,
      // title: existing == null ? 'New milestone' : 'Edit milestone',
      builder: (context) => _MilestoneForm(goalId: goal.id, existing: existing),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.tenkai;
    final milestonesAsync = ref.watch(goalMilestonesProvider(goal.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('MILESTONES', style: Theme.of(context).textTheme.labelMedium),
            OutlinedButton(
              child: Text('Add'),
              onPressed: () => _openForm(context),
            ),
          ],
        ),
        const SizedBox(height: TenkaiSpacing.sm),
        milestonesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(TenkaiSpacing.md),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => Text(
            'Could not load milestones',
            style: TenkaiTypography.bodySmall.copyWith(
              color: c.secondaryForeground,
            ),
          ),
          data: (milestones) {
            if (milestones.isEmpty) {
              return Text(
                'No milestones yet',
                style: TenkaiTypography.bodySmall.copyWith(
                  color: c.secondaryForeground,
                ),
              );
            }
            return Column(
              children: [
                for (final m in milestones)
                  _MilestoneRow(
                    milestone: m,
                    unit: goal.unit,
                    onTap: () => _openForm(context, existing: m),
                    onDelete: () => ref
                        .read(goalProvider.notifier)
                        .deleteMilestone(goal.id, m.id),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({
    required this.milestone,
    required this.unit,
    required this.onTap,
    required this.onDelete,
  });

  final Milestone milestone;
  final String? unit;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;
    final achieved = milestone.isAchieved;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TenkaiSpacing.sm),
        child: Row(
          children: [
            TenkaiNode(
              size: 12,
              color: achieved ? TenkaiColors.success : c.border,
              glowing: achieved,
            ),
            const SizedBox(width: TenkaiSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    milestone.title?.isNotEmpty == true
                        ? milestone.title!
                        : 'At ${formatGoalValue(milestone.targetValue, unit)}',
                    style: TenkaiTypography.bodyMd.copyWith(
                      color: achieved ? c.foreground : c.mutedForeground,
                    ),
                  ),
                  Text(
                    achieved
                        ? 'Achieved · ${formatGoalValue(milestone.targetValue, unit)}'
                        : 'Target ${formatGoalValue(milestone.targetValue, unit)}',
                    style: TenkaiTypography.labelSm.copyWith(
                      color: c.secondaryForeground,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.close, size: 16, color: c.secondaryForeground),
            ),
          ],
        ),
      ),
    );
  }
}

class _MilestoneForm extends ConsumerStatefulWidget {
  const _MilestoneForm({required this.goalId, this.existing});

  final String goalId;
  final Milestone? existing;

  @override
  ConsumerState<_MilestoneForm> createState() => _MilestoneFormState();
}

class _MilestoneFormState extends ConsumerState<_MilestoneForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _targetController;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existing?.title ?? '',
    );
    _targetController = TextEditingController(
      text: widget.existing == null
          ? ''
          : formatGoalValue(widget.existing!.targetValue),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final target = double.tryParse(_targetController.text.trim());
    if (target == null) {
      setState(() => _error = 'Enter a valid target value');
      HapticFeedback.vibrate();
      return;
    }
    setState(() {
      _error = null;
      _submitting = true;
    });

    final notifier = ref.read(goalProvider.notifier);
    final title = _titleController.text.trim();
    final param = MilestoneParam(title: title, targetValue: target);
    final ok = widget.existing == null
        ? await notifier.createMilestone(widget.goalId, param)
        : await notifier.updateMilestone(
            widget.goalId,
            widget.existing!.id,
            param,
          );

    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() => _error = 'Could not save milestone');
      HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_error != null) ...[
          Text(
            _error!,
            style: TenkaiTypography.labelSm.copyWith(color: c.destructive),
          ),
          const SizedBox(height: TenkaiSpacing.sm),
        ],
        TenkaiTextFormField(
          controller: _titleController,
          label: 'title',
          placeholder: 'e.g. Halfway',
          autofocus: true,
        ),
        const SizedBox(height: TenkaiSpacing.md),
        TenkaiTextFormField(
          controller: _targetController,
          label: 'target value',
          placeholder: '80',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: TenkaiSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: FilledButton(onPressed: _submit, child: const Text('Save')),
        ),
      ],
    );
  }
}
