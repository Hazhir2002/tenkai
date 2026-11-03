import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/tokens/tenkai_spacing.dart';
import 'package:tenkai/core/widgets/form_error_widget.dart';
import 'package:tenkai/core/widgets/tenkai_text_form_field.dart';
import 'package:tenkai/features/auth/params/register_params.dart';
import 'package:tenkai/features/auth/providers/auth_provider.dart';

class RegisterForm extends ConsumerStatefulWidget {
  const RegisterForm({super.key});

  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  final _emailCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Column(
      spacing: TenkaiSpacing.lg,
      children: [
        FormErrorWidget(message: authState.error),
        Form(
          child: Column(
            spacing: TenkaiSpacing.md,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TenkaiTextFormField(
                label: 'email',
                keyboardType: TextInputType.emailAddress,
                controller: _emailCtrl,
                textInputAction: TextInputAction.next,
              ),
              TenkaiTextFormField(
                label: 'username',
                controller: _usernameCtrl,
                textInputAction: TextInputAction.next,
              ),
              TenkaiTextFormField(
                label: 'password',
                controller: _passwordCtrl,
                textInputAction: TextInputAction.next,
                obscureText: true,
              ),
              TenkaiTextFormField(
                label: 'confirm password',
                controller: _confirmPasswordCtrl,
                textInputAction: TextInputAction.done,
                obscureText: true,
              ),
              const SizedBox(height: TenkaiSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final result = await ref
                        .read(authProvider.notifier)
                        .register(
                          RegisterParams(
                            email: _emailCtrl.text,
                            username: _usernameCtrl.text,
                            password: _passwordCtrl.text,
                          ),
                        );
                    if (result != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Welcome ${result.username}')),
                      );
                      context.go('/auth/login');
                    }
                  },
                  child: Text('Register'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
