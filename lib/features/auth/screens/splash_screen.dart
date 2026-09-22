import 'package:flutter/material.dart';
import 'package:tenkai/core/design_system/tenkai.dart';

/// Shown briefly on launch while the persisted session is being restored.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TenkaiLogoLockup(markSize: 52),
            const SizedBox(height: TenkaiSpacing.xxl),
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: context.tenkai.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
