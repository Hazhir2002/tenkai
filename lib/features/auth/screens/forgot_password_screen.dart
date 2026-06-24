import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  bool _emailSent = false;

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
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: Color(0xFF1A1025),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                const AuthHeader(
                  emoji: '🔑',
                  title: 'Forgot\npassword?',
                  subtitle:
                      "No worries! Enter your email and we'll send a reset link.",
                ),
                const SizedBox(height: 40),

                if (_emailSent) ...[
                  AuthSuccessBanner(
                    message:
                        'Reset link sent to ${_emailController.text.trim()}. Check your inbox!',
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    label: 'Back to Sign In',
                    onPressed: () => context.pop(),
                    icon: Icons.arrow_back_rounded,
                  ),
                ] else ...[
                  if (authState.errorMessage != null) ...[
                    AuthErrorBanner(message: authState.errorMessage!),
                    const SizedBox(height: 20),
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
                  const SizedBox(height: 28),

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
      ),
    );
  }
}
