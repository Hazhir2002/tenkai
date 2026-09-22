import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/core/validators/confirm_password_validator.dart';
import 'package:tenkai/core/validators/password_validator.dart';
import 'package:tenkai/features/auth/providers/auth_provider.dart';
import 'package:tenkai/features/auth/widgets/auth_widgets.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.token});
  final String token;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final bool _success = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    // final success = await ref.read(authProvider.notifier).resetPassword(...);
    // if (success && mounted) setState(() => _success = true);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              const AuthHeader(
                title: 'New password',
                subtitle: 'Choose a strong password to secure your account.',
              ),
              const SizedBox(height: TenkaiSpacing.xxl),

              if (_success) ...[
                const AuthSuccessBanner(
                  message: 'Password reset. You can now sign in.',
                ),
                const SizedBox(height: TenkaiSpacing.lg),
                GradientButton(
                  label: 'Go to Sign In',
                  onPressed: () => context.go('/login'),
                  icon: Icons.login_rounded,
                ),
              ] else ...[
                if (authState.errorMessage != null) ...[
                  AuthErrorBanner(message: authState.errorMessage!),
                  const SizedBox(height: TenkaiSpacing.lg),
                ],
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AuthTextField(
                        label: 'New password',
                        controller: _passwordController,
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        validator: passwordValidator,
                      ),
                      const SizedBox(height: TenkaiSpacing.md),
                      AuthTextField(
                        label: 'Confirm new password',
                        controller: _confirmController,
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        validator: (v) => confirmPasswordValidator(
                          v,
                          _passwordController.text,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TenkaiSpacing.md),
                _PasswordHints(password: _passwordController.text),
                const SizedBox(height: TenkaiSpacing.xl),
                GradientButton(
                  label: 'Reset Password',
                  isLoading: authState.isLoading,
                  onPressed: authState.isLoading ? null : _submit,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordHints extends StatelessWidget {
  const _PasswordHints({required this.password});
  final String password;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Hint(label: 'At least 8 characters', met: password.length >= 8),
        _Hint(
          label: 'Contains a number',
          met: password.contains(RegExp(r'\d')),
        ),
        _Hint(
          label: 'Contains a letter',
          met: password.contains(RegExp(r'[a-zA-Z]')),
        ),
      ],
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.label, required this.met});
  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;
    final color = met ? Colors.green : c.foreground;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(label, style: TenkaiTypography.labelMd.copyWith(color: color)),
        ],
      ),
    );
  }
}
