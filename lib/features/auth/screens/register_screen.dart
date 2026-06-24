import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_controls.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_icon.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_icon_button.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/core/validators/confirm_password_validator.dart';
import 'package:tenkai/core/validators/email_validator.dart';
import 'package:tenkai/core/validators/password_validator.dart';
import 'package:tenkai/core/validators/required_validatory.dart';
import 'package:tenkai/features/auth/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    // final success = await ref
    //     .read(authProvider.notifier)
    //     .register(
    //       // RegisterParams(
    //       //   fullName: _nameController.text.trim(),
    //       //   email: _emailController.text.trim(),
    //       //   password: _passwordController.text,
    //       //   confirmPassword: _confirmController.text,
    //       // ),
    //     );

    // if (success && mounted) {
    //   context.go('/verify-email?email=${_emailController.text.trim()}');
    // }
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
                Hero(
                  tag: 'auth-title',
                  child: Text(
                    'Create Account',
                    style: theme.textTheme.headlineLarge,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Let us begin',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 40),
                // if (authState.errorMessage != null)
                //   Padding(
                //     padding: const EdgeInsets.only(bottom: 24.0),
                //     child: ErrorTile(message: authState.errorMessage!),
                //   ),
                Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUnfocus,
                  child: Column(
                    children: [
                      TenkaiInput(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        onSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_emailFocus),
                        prefix: Padding(
                          padding: EdgeInsets.all(8),
                          child: TenkaiIcon(assetName: 'user'),
                        ),
                        label: 'Username',
                      ),
                      const SizedBox(height: 8),
                      TenkaiInput(
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        label: 'Password',
                        autofillHints: const [AutofillHints.newPassword],
                        onSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_confirmFocus),
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
                      ),
                      const SizedBox(height: 8),
                      TenkaiInput(
                        controller: _confirmController,
                        focusNode: _confirmFocus,
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        label: 'Confirm Password',
                        onSubmitted: (_) => _submit(),
                        prefix: AnimatedSwitcher(
                          duration: TenkaiDuration.fast,
                          child: _obscureConfirm
                              ? TenkaiIconButton(
                                  size: TenkaiIconButtonSize.sm,
                                  iconAsset: 'padlock',
                                  onPressed: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm,
                                  ),
                                )
                              : TenkaiIconButton(
                                  size: TenkaiIconButtonSize.sm,
                                  iconAsset: 'lock-slash',
                                  onPressed: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: TenkaiButton(
                          onPressed: _submit,
                          loading: authState.isLoading,
                          label: 'Sign Up',
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: theme.textTheme.bodySmall,
                          ),
                          TextButton(
                            onPressed: () => context.go('/login'),
                            child: const Text('Login'),
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
