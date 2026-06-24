import 'package:flutter/material.dart';
import 'package:tenkai/core/design_system/tokens/tenkai_tokens.dart';

class TenkaiFormError extends StatelessWidget {
  final String? errorMessage;

  const TenkaiFormError({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      // Fade duration and opacity
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      opacity: errorMessage != null ? 1.0 : 0.0,
      child: AnimatedScale(
        // Scale duration and scale factor (e.g., starts at 85% size and grows to 100%)
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack, // Gives it a nice, subtle pop effect
        scale: errorMessage != null ? 1.0 : 0.85,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          // Use an empty string if null to prevent crashes while animating out
          child: Text(
            errorMessage ?? '',
            style: TenkaiTypography.bodySmall.copyWith(
              color: TenkaiColors.error,
            ),
          ),
        ),
      ),
    );
  }
}
