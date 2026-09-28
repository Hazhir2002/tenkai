import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_text_form_field.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/features/fitness/providers/fitness_provider.dart';

class CreateProgramScreen extends ConsumerStatefulWidget {
  const CreateProgramScreen({super.key});

  @override
  ConsumerState<CreateProgramScreen> createState() =>
      _CreateProgramScreenState();
}

class _CreateProgramScreenState extends ConsumerState<CreateProgramScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      await ref
          .read(fitnessProvider.notifier)
          .createProgram(
            ProgramsCompanion(title: Value(_titleController.text)),
          );
      if (mounted) {
        context.pop();
      } else {
        HapticFeedback.vibrate();
      }
    } else {
      HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final programState = ref.watch(fitnessProvider);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(TenkaiSpacing.lg),
        child: SafeArea(
          child: Center(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUnfocus,
              child: Column(
                children: [
                  TenkaiTextFormField(
                    controller: _titleController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    onSubmitted: (_) => _submit(),
                    placeholder: 'new program',
                    label: 'program name',
                  ),

                  const SizedBox(height: 20),

                  Hero(
                    tag: 'auth-submit',
                    child: SizedBox(
                      width: double.infinity,
                      child: TenkaiButton(
                        onPressed: programState.isLoading ? null : _submit,
                        enabled: programState.isLoading ? false : true,
                        loading: programState.isLoading,
                        label: 'Add',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
