import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tenkai/core/tokens/tenkai_spacing.dart';
import 'package:tenkai/features/auth/widgets/register_form.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
            Text('Welcome', style: theme.textTheme.titleLarge),
            RegisterForm(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("If you're fixture"),
                TextButton(
                  onPressed: () {
                    context.go('/auth/login');
                  },
                  child: Text('Login'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
