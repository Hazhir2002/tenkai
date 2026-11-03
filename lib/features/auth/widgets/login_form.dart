import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/tokens/tenkai_spacing.dart';
import 'package:tenkai/core/widgets/form_error_widget.dart';
import 'package:tenkai/core/widgets/tenkai_text_form_field.dart';
import 'package:tenkai/features/auth/params/login_params.dart';
import 'package:tenkai/features/auth/providers/auth_provider.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
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
                label: 'username',
                controller: _usernameCtrl,
                textInputAction: TextInputAction.next,
              ),
              TenkaiTextFormField(
                label: 'password',
                controller: _passwordCtrl,
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
                        .login(
                          LoginParams(
                            username: _usernameCtrl.text,
                            password: _passwordCtrl.text,
                          ),
                        );
                    if (result && context.mounted) {
                      context.go('/');
                    }
                  },
                  child: Text('login'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
