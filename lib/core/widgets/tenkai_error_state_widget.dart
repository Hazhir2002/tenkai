import 'package:flutter/material.dart';
import 'package:tenkai/core/theme/tenkai_semantic_colors.dart';
import 'package:tenkai/core/tokens/tenkai_spacing.dart';
import 'package:tenkai/core/tokens/tenkai_typography.dart';

class TenkaiErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const TenkaiErrorStateWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TenkaiTypography.bodyMd.copyWith(
              color: context.tenkai.mutedForeground,
            ),
          ),
          const SizedBox(height: TenkaiSpacing.lg),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
