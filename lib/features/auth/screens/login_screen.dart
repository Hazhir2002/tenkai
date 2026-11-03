import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("If you're new"),
                TextButton(
                  onPressed: () {
                    context.go('/auth/register');
                  },
                  child: Text('Register'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
