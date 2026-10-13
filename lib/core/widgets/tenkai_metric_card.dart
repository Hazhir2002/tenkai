import 'package:flutter/material.dart';
import 'package:tenkai/core/theme/tenkai_semantic_colors.dart';
import 'package:tenkai/core/tokens/tenkai_spacing.dart';
import 'package:tenkai/core/tokens/tenkai_typography.dart';

class TenkaiMetricCard extends StatelessWidget {
  const TenkaiMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.subtext,
    this.accent,
  });

  final String label;
  final String value;
  final String? subtext;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TenkaiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: TenkaiTypography.labelMd.copyWith(
                color: c.mutedForeground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TenkaiTypography.d3.copyWith(
                fontSize: 28,
                color: accent ?? c.foreground,
              ),
            ),
            if (subtext != null) ...[
              const SizedBox(height: 4),
              Text(
                subtext!,
                style: TenkaiTypography.bodySmall.copyWith(
                  color: c.secondaryForeground,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
