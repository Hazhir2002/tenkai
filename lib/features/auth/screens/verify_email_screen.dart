import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
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
  final bool _resendSuccess = false;

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
              const SizedBox(height: 12),
              const AuthHeader(
                title: 'Check your inbox',
                subtitle: 'We sent a verification link to your email.',
              ),
              const SizedBox(height: 6),
              Text(
                widget.email,
                style: TenkaiTypography.bodyMd.copyWith(color: c.foreground),
              ),
              const SizedBox(height: TenkaiSpacing.xl),

              if (authState.errorMessage != null) ...[
                AuthErrorBanner(message: authState.errorMessage!),
                const SizedBox(height: TenkaiSpacing.md),
              ],
              if (_resendSuccess) ...[
                const AuthSuccessBanner(message: 'Verification email resent'),
                const SizedBox(height: TenkaiSpacing.md),
              ],

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
              const SizedBox(height: TenkaiSpacing.xl),

              GradientButton(
                label: 'Verify Email',
                isLoading: authState.isLoading,
                onPressed: authState.isLoading ? null : _verify,
                icon: Icons.verified_rounded,
              ),
              const SizedBox(height: TenkaiSpacing.lg),

              Center(
                child: TenkaiButton(
                  label: 'Back to Sign In',
                  variant: TenkaiButtonVariant.link,
                  size: TenkaiButtonSize.sm,
                  onPressed: () => context.go('/login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
