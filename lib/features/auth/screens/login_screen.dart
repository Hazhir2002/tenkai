import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_button.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_controls.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_form_error.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_icon.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_icon_button.dart';
import 'package:tenkai/core/design_system/tokens/tenkai_duration.dart';
import 'package:tenkai/core/validators/email_validator.dart';
import 'package:tenkai/core/validators/password_validator.dart';
import 'package:tenkai/features/auth/params/login_params.dart';
import 'package:tenkai/features/auth/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      await ref
          .read(authProvider.notifier)
          .login(
            LoginParams(
              username: _usernameController.text.trim(),
              password: _passwordController.text,
            ),
          );

      if (ref.read(authProvider).isAuthenticated && mounted) {
        context.go('/profile');
      } else {
        HapticFeedback.vibrate();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),

        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Welcome Back', style: theme.textTheme.headlineLarge),
                const SizedBox(height: 8),
                Text(
                  'Let\'s get back to work',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 40),

                TenkaiFormError(errorMessage: authState.errorMessage),
                Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUnfocus,
                  child: Column(
                    children: [
                      TenkaiInput(
                        controller: _usernameController,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        onSubmitted: (_) => _passwordFocus.requestFocus(),
                        prefix: Padding(
                          padding: EdgeInsets.all(8),
                          child: TenkaiIcon(assetName: 'user'),
                        ),
                        label: 'Username',
                        placeholder: 'Heisenberg',
                      ),
                      const SizedBox(height: 8),
                      TenkaiInput(
                        focusNode: _passwordFocus,
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        placeholder: 'Your password',
                        prefix: AnimatedSwitcher(
                          duration: TenkaiDuration.fast,
                          child: _obscurePassword
                              ? TenkaiIconButton(
                                  size: TenkaiIconButtonSize.sm,
                                  iconAsset: 'padlock',
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                )
                              : TenkaiIconButton(
                                  size: TenkaiIconButtonSize.sm,
                                  iconAsset: 'lock-slash',
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                        ),
                        label: 'Password',
                        onSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 12),
                      TenkaiButton(
                        variant: TenkaiButtonVariant.link,
                        onPressed: () => context.push('/forgot-password'),
                        label: 'Forgot Password?',
                      ),

                      SizedBox(
                        width: double.infinity,
                        child: TenkaiButton(
                          onPressed: _submit,
                          loading: authState.isLoading,
                          label: 'Sign in',
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: theme.textTheme.bodySmall,
                          ),
                          TextButton(
                            onPressed: () => context.go('/register'),
                            child: const Text('Sign Up'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
