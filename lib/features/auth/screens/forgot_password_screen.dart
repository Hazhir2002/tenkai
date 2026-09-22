import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/core/validators/email_validator.dart';
import 'package:tenkai/features/auth/providers/auth_provider.dart';
import 'package:tenkai/features/auth/widgets/auth_widgets.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    // final success = await ref
    //     .read(authProvider.notifier)
    //     .forgotPassword(_emailController.text.trim());
    // if (success && mounted) setState(() => _emailSent = true);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.pop(),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: c.foreground,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: TenkaiSpacing.xl),

              const AuthHeader(
                title: 'Forgot password?',
                subtitle: "Enter your email and we'll send a reset link.",
              ),
              const SizedBox(height: TenkaiSpacing.xxl),

              if (_emailSent) ...[
                AuthSuccessBanner(
                  message:
                      'Reset link sent to ${_emailController.text.trim()}.',
                ),
                const SizedBox(height: TenkaiSpacing.lg),
                GradientButton(
                  label: 'Back to Sign In',
                  onPressed: () => context.pop(),
                  icon: Icons.arrow_back_rounded,
                ),
              ] else ...[
                if (authState.errorMessage != null) ...[
                  AuthErrorBanner(message: authState.errorMessage!),
                  const SizedBox(height: TenkaiSpacing.lg),
                ],
                Form(
                  key: _formKey,
                  child: AuthTextField(
                    label: 'Email address',
                    controller: _emailController,
                    prefixIcon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.email],
                    onFieldSubmitted: (_) => _submit(),
                    validator: emailValidator,
                  ),
                ),
                const SizedBox(height: TenkaiSpacing.xl),
                GradientButton(
                  label: 'Send Reset Link',
                  isLoading: authState.isLoading,
                  onPressed: authState.isLoading ? null : _submit,
                  icon: Icons.send_rounded,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
