import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_button.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_controls.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_text_form_field.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/features/gym_tracker/params/create_program_param.dart';
import 'package:tenkai/features/gym_tracker/providers/program_provider.dart';

class CreateProgramScreen extends ConsumerStatefulWidget {
  const CreateProgramScreen({super.key});

  @override
  ConsumerState<CreateProgramScreen> createState() =>
      _CreateProgramScreenState();
}

class _CreateProgramScreenState extends ConsumerState<CreateProgramScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      await ref
          .read(programProvider.notifier)
          .createProgram(CreateProgramParam(name: _nameController.text));
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
    final programState = ref.watch(programProvider);

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
                    controller: _nameController,
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
