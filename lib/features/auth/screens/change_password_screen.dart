import 'package:flutter/material.dart';
import 'package:tenkai/core/design_system/tenkai.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text('Change password')),
      body: Center(
        child: TenkaiEmptyState(
          title: 'Not available yet',
          description: 'Changing your password from here is coming soon.',
        ),
      ),
    );
  }
}
