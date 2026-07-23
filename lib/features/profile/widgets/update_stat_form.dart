import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_button.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_controls.dart';
import 'package:tenkai/features/profile/provider/user_stat_provider.dart';
import 'package:tenkai/features/profile/repositories/state_repository.dart';

class UpdateStatForm extends ConsumerStatefulWidget {
  final UserStatData userStat;

  const UpdateStatForm({super.key, required this.userStat});

  @override
  ConsumerState<UpdateStatForm> createState() => _UpdateStatFormState();
}

class _UpdateStatFormState extends ConsumerState<UpdateStatForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _unitController;
  late TextEditingController _valueController;

  @override
  void initState() {
    _titleController = TextEditingController(text: widget.userStat.title);
    _unitController = TextEditingController(text: widget.userStat.unit);
    _valueController = TextEditingController(
      text: widget.userStat.value.toString(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUnfocus,
      child: Column(
        children: [
          TenkaiInput(
            controller: _titleController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            label: 'title',
          ),
          const SizedBox(height: 12),
          TenkaiInput(controller: _unitController, label: 'unit'),
          const SizedBox(height: 12),
          TenkaiInput(
            controller: _valueController,
            label: 'value',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: TenkaiButton(
              onPressed: () => ref
                  .read(userStatProvider.notifier)
                  .updateStat(
                    UserStatData(
                      id: widget.userStat.id,
                      title: _titleController.text,
                      unit: _unitController.text,
                      value: int.parse(_valueController.text),
                      createdAt: widget.userStat.createdAt,
                    ),
                  ),
              label: 'Update',
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _unitController.dispose();
    _valueController.dispose();
    super.dispose();
  }
}
