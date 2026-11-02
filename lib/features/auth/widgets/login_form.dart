import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/tokens/tenkai_spacing.dart';
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
  Widget build(BuildContext context) {
    return Form(
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
              onPressed: () {
                ref
                    .read(authProvider.notifier)
                    .login(
                      LoginParams(
                        username: _usernameCtrl.text,
                        password: _passwordCtrl.text,
                      ),
                    );
              },
              child: Text('login'),
            ),
          ),
        ],
      ),
    );
  }
}
