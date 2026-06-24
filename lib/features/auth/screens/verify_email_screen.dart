import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/validators/otp_validator.dart';
import 'package:tenkai/features/auth/providers/auth_provider.dart';
import 'package:tenkai/features/auth/widgets/auth_widgets.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});
  final String email;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _tokenController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _resendSuccess = false;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    // final success = await ref
    //     .read(authProvider.notifier)
    //     .verifyEmail(_tokenController.text.trim());

    // if (success && mounted) context.go('/login');
  }

  // Future<void> _resend() async {
  //   final success = await ref
  //       .read(authProvider.notifier)
  //       .resendVerification(widget.email);
  //   if (success && mounted) {
  //     setState(() => _resendSuccess = true);
  //     Future.delayed(const Duration(seconds: 4), () {
  //       if (mounted) setState(() => _resendSuccess = false);
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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

                // Animated mail illustration
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFF6B6B),
                          Color(0xFFFF8E53),
                          Color(0xFF7C5CBF),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF7C5CBF).withOpacity(0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.mark_email_unread_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                ShaderMask(
                  shaderCallback: (b) => LinearGradient(
                    colors: [
                      Color(0xFFFF6B6B),
                      Color(0xFFFF8E53),
                      Color(0xFF7C5CBF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(b),
                  child: Text(
                    'Check your\ninbox',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.titleMedium,
                    children: [
                      const TextSpan(text: 'We sent a verification link to\n'),
                      TextSpan(
                        text: widget.email,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Color(0xFF7C5CBF),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                if (authState.errorMessage != null) ...[
                  AuthErrorBanner(message: authState.errorMessage!),
                  const SizedBox(height: 16),
                ],
                if (_resendSuccess) ...[
                  const AuthSuccessBanner(
                    message: 'Verification email resent!',
                  ),
                  const SizedBox(height: 16),
                ],

                // Token input
                Form(
                  key: _formKey,
                  child: AuthTextField(
                    label: 'Verification token',
                    controller: _tokenController,
                    prefixIcon: Icons.vpn_key_outlined,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _verify(),
                    validator: otpValidator,
                  ),
                ),
                const SizedBox(height: 24),

                GradientButton(
                  label: 'Verify Email',
                  isLoading: authState.isLoading,
                  onPressed: authState.isLoading ? null : _verify,
                  icon: Icons.verified_rounded,
                ),
                const SizedBox(height: 24),

                // Resend & back
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive it? ",
                      style: theme.textTheme.bodyMedium,
                    ),
                    // GestureDetector(
                    //   onTap: authState.isLoading ? null : _resend,
                    //   child: ShaderMask(
                    //     shaderCallback: (b) => LinearGradient(
                    //       colors: [
                    //         Color(0xFFFF6B6B),
                    //         Color(0xFFFF8E53),
                    //         Color(0xFF7C5CBF),
                    //       ],
                    //       begin: Alignment.topLeft,
                    //       end: Alignment.bottomRight,
                    //     ).createShader(b),
                    //     child: Text(
                    //       'Resend',
                    //       style: theme.textTheme.bodyMedium?.copyWith(
                    //         fontWeight: FontWeight.w800,
                    //         color: Colors.white,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'Back to Sign In',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Color(0xFF6B6579),
                      fontWeight: FontWeight.w600,
                    ),
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
