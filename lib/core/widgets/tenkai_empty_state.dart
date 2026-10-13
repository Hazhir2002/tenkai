import 'package:flutter/material.dart';
import 'package:tenkai/core/widgets/tenkai_motion.dart';
import 'package:tenkai/core/theme/tenkai_semantic_colors.dart';
import 'package:tenkai/core/tokens/tenkai_typography.dart';

class TenkaiEmptyState extends StatelessWidget {
  const TenkaiEmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.action,
  });

  final String title;
  final String? description;
  final Widget? icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;
    return TenkaiUnfold(
      offset: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Opacity(opacity: 0.9, child: icon!),
              const SizedBox(height: 12),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: TenkaiTypography.titleMd.copyWith(
                fontSize: 19,
                color: c.foreground,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: TenkaiTypography.bodyMd.copyWith(
                    color: c.mutedForeground,
                  ),
                ),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 18), action!],
          ],
        ),
      ),
    );
  }
}
