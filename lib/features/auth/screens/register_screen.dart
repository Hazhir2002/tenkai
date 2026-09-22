import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/core/validators/confirm_password_validator.dart';
import 'package:tenkai/core/validators/email_validator.dart';
import 'package:tenkai/core/validators/password_validator.dart';
import 'package:tenkai/core/validators/required_validatory.dart';
import 'package:tenkai/features/auth/params/register_params.dart';
import 'package:tenkai/features/auth/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _validationError;

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
    FocusScope.of(context).unfocus();
    final username = _nameController.text.trim();
    final email = _emailController.text.trim();
    final error =
        requiredValidator(username, 'Username') ??
        emailValidator(email) ??
        passwordValidator(_passwordController.text) ??
        confirmPasswordValidator(
          _confirmController.text,
          _passwordController.text,
        );
    if (error != null) {
      setState(() => _validationError = error);
      HapticFeedback.vibrate();
      return;
    }
    setState(() => _validationError = null);

    await ref
        .read(authProvider.notifier)
        .register(
          RegisterParams(
            email: email,
            username: username,
            password: _passwordController.text,
          ),
        );

    if (!mounted) return;
    // The router guard sends authenticated users into the app.
    if (ref.read(authProvider).isAuthenticated) {
      context.go('/');
    } else {
      HapticFeedback.vibrate();
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
                TenkaiFormError(
                  errorMessage: _validationError ?? authState.errorMessage,
                ),
                TenkaiInput(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newUsername],
                  onSubmitted: (_) => _emailFocus.requestFocus(),
                  prefix: const Padding(
                    padding: EdgeInsets.all(8),
                    child: TenkaiIcon(assetName: 'user'),
                  ),
                  label: 'Username',
                  placeholder: 'heisenberg',
                ),
                const SizedBox(height: 8),
                TenkaiInput(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  onSubmitted: (_) => _passwordFocus.requestFocus(),
                  label: 'Email',
                  placeholder: 'jane@example.com',
                ),
                const SizedBox(height: 8),
                TenkaiInput(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  label: 'Password',
                  autofillHints: const [AutofillHints.newPassword],
                  onSubmitted: (_) => _confirmFocus.requestFocus(),
                  prefix: AnimatedSwitcher(
                    duration: TenkaiDuration.fast,
                    child: TenkaiIconButton(
                      size: TenkaiIconButtonSize.sm,
                      iconAsset: _obscurePassword ? 'padlock' : 'lock-slash',
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
                    child: TenkaiIconButton(
                      size: TenkaiIconButtonSize.sm,
                      iconAsset: _obscureConfirm ? 'padlock' : 'lock-slash',
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
        ),
      ),
    );
  }
}
