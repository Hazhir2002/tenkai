import 'package:flutter/material.dart';
import '../theme/tenkai_semantic_colors.dart';
import '../sounds/tenkai_sound.dart';
import '../tokens/tenkai_tokens.dart';
import 'tenkai_motion.dart';

enum TenkaiBannerVariant { info, success, warning, error }

/// An inline status banner: a tone dot, a title + optional message, and an
/// optional action / dismiss. Flat tone-tinted surface; unfolds in on mount.
class TenkaiBanner extends StatelessWidget {
  const TenkaiBanner({
    super.key,
    required this.title,
    this.message,
    this.variant = TenkaiBannerVariant.info,
    this.action,
    this.onDismiss,
  });

  final String title;
  final String? message;
  final TenkaiBannerVariant variant;
  final Widget? action;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;

    final (Color fg, Color bg, Color border) = switch (variant) {
      TenkaiBannerVariant.info => (c.foreground, c.card, c.border),
      TenkaiBannerVariant.success => (
        Colors.greenAccent,
        Colors.greenAccent,
        Colors.greenAccent,
      ),
      TenkaiBannerVariant.warning => (
        Colors.yellowAccent,
        Colors.yellowAccent,
        Colors.yellowAccent,
      ),
      TenkaiBannerVariant.error => (
        c.destructive,
        c.destructive,
        c.destructive,
      ),
    };

    return TenkaiUnfold(
      duration: TenkaiDuration.medium,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(TenkaiRadius.card),
          border: Border.all(color: border, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(top: 5, right: 10),
              decoration: BoxDecoration(shape: BoxShape.circle, color: fg),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TenkaiTypography.labelLg.copyWith(
                      fontSize: 13,
                      letterSpacing: 0,
                      color: fg,
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      message!,
                      style: TenkaiTypography.bodySmall.copyWith(
                        height: 1.55,
                        color: c.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (action != null) ...[const SizedBox(width: 8), action!],
            if (onDismiss != null)
              GestureDetector(
                onTap: () {
                  TenkaiSound.tap();
                  onDismiss!();
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: c.secondaryForeground,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
