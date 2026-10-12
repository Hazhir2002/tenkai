import 'package:flutter/material.dart';
import 'package:tenkai/core/design_system/tokens/tenkai_spacing.dart';
import 'package:tenkai/core/design_system/tokens/tenkai_typography.dart';

class EmptyStateWidget extends StatelessWidget {
  final Widget? icon;
  final String title;
  final String? subtitle;
  final Widget? actionWidget;

  const EmptyStateWidget({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.actionWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TenkaiSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(height: TenkaiSpacing.xl),
            ],
            Text(title, style: TenkaiTypography.h2),
            if (subtitle != null) ...[
              const SizedBox(height: TenkaiSpacing.sm),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TenkaiTypography.bodySmall,
              ),
            ],
            if (actionWidget != null) ...[
              const SizedBox(height: TenkaiSpacing.xl),
              actionWidget!,
            ],
          ],
        ),
      ),
    );
  }
}
