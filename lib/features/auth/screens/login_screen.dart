import 'package:flutter/material.dart';
import 'package:tenkai/core/tokens/tenkai_spacing.dart';
import 'package:tenkai/features/auth/widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        minimum: EdgeInsets.all(TenkaiSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: TenkaiSpacing.xxl,
          children: [
            Text('Welcome back', style: theme.textTheme.titleLarge),
            LoginForm(),
          ],
        ),
      ),
    );
  }
}
