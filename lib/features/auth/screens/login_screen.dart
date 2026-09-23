import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_button.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_form_error.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_icon.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_icon_button.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_text_form_field.dart';
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;
  String? _validationError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final error =
        emailValidator(email) ?? passwordValidator(_passwordController.text);
    if (error != null) {
      setState(() => _validationError = error);
      HapticFeedback.vibrate();
      return;
    }
    setState(() => _validationError = null);

    await ref
        .read(authProvider.notifier)
        .login(LoginParams(email: email, password: _passwordController.text));

    if (!mounted) return;
    // The router guard redirects on success; this is a belt-and-braces nudge.
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
                Text('Welcome Back', style: theme.textTheme.headlineLarge),
                const SizedBox(height: 8),
                Text(
                  'Let\'s get back to work',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 40),
                TenkaiFormError(
                  errorMessage: _validationError ?? authState.errorMessage,
                ),
                TenkaiTextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  onSubmitted: (_) => _passwordFocus.requestFocus(),
                  prefix: const Padding(
                    padding: EdgeInsets.all(8),
                    child: TenkaiIcon(assetName: 'user'),
                  ),
                  label: 'Email',
                  placeholder: 'jane@example.com',
                ),
                const SizedBox(height: 8),
                TenkaiTextFormField(
                  focusNode: _passwordFocus,
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  placeholder: 'Your password',
                  autofillHints: const [AutofillHints.password],
                  prefix: AnimatedSwitcher(
                    duration: TenkaiDuration.fast,
                    child: TenkaiIconButton(
                      size: TenkaiIconButtonSize.sm,
                      iconAsset: _obscurePassword ? 'padlock' : 'lock-slash',
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  label: 'Password',
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 20),
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
        ),
      ),
    );
  }
}
