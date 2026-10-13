import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/widgets/tenkai_text_form_field.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/features/fitness/providers/fitness_provider.dart';

class ProgramForm extends ConsumerStatefulWidget {
  const ProgramForm({super.key});

  @override
  ConsumerState<ProgramForm> createState() => _ProgramFormState();
}

class _ProgramFormState extends ConsumerState<ProgramForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? title;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: TenkaiSpacing.md,
          children: [
            TenkaiTextFormField(
              isRequired: true,
              label: 'Title',
              placeholder: 'e.g. Gym Program',
              onSaved: (value) => title = value,
            ),
            const SizedBox(height: TenkaiSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    ref
                        .read(fitnessProvider.notifier)
                        .createProgram(ProgramsCompanion(title: Value(title!)));
                  }
                },
                child: Text("Create"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
