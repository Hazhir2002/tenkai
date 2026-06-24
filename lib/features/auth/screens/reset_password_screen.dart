import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
  bool _success = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    // final success = await ref
    //     .read(authProvider.notifier)
    //     .resetPassword(
    //       // ResetPasswordParams(
    //       //   token: widget.token,
    //       //   password: _passwordController.text,
    //       //   confirmPassword: _passwordController.text,
    //       // ),
    //     );

    // if (success && mounted) setState(() => _success = true);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF0F0), Color(0xFFF3EEFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                const AuthHeader(
                  emoji: '🛡️',
                  title: 'New password',
                  subtitle: 'Choose a strong password to secure your account.',
                ),
                const SizedBox(height: 40),

                if (_success) ...[
                  const AuthSuccessBanner(
                    message:
                        'Password reset successfully! You can now sign in.',
                  ),
                  const SizedBox(height: 28),
                  GradientButton(
                    label: 'Go to Sign In',
                    onPressed: () => context.go('/login'),
                    icon: Icons.login_rounded,
                  ),
                ] else ...[
                  if (authState.errorMessage != null) ...[
                    AuthErrorBanner(message: authState.errorMessage!),
                    const SizedBox(height: 20),
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
                        const SizedBox(height: 16),
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
                  const SizedBox(height: 12),

                  // Password strength hints
                  _PasswordHints(password: _passwordController.text),
                  const SizedBox(height: 28),

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
      ),
    );
  }
}

class _PasswordHints extends StatelessWidget {
  const _PasswordHints({required this.password});
  final String password;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ValueNotifier(password),
      builder: (_, __, ___) => Column(
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
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.label, required this.met});
  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 16,
            color: met ? Color(0xFF00C896) : Color(0xFF6B6579),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: met ? Color(0xFF00C896) : Color(0xFF6B6579),
              fontWeight: met ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
