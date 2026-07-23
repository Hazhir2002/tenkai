import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_button.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_controls.dart';
import 'package:tenkai/features/profile/provider/user_stat_provider.dart';
import 'package:tenkai/features/profile/repositories/state_repository.dart';

class AddStatForm extends ConsumerStatefulWidget {
  const AddStatForm({super.key});

  @override
  ConsumerState<AddStatForm> createState() => _AddStatFormState();
}

class _AddStatFormState extends ConsumerState<AddStatForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

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
                  .addStat(
                    UserStatCompanion(
                      title: Value(_titleController.text),
                      unit: Value(_unitController.text),
                      value: Value(int.parse(_valueController.text)),
                    ),
                  ),
              label: 'Add',
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
