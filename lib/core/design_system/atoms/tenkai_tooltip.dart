import 'package:flutter/material.dart';
import '../theme/tenkai_semantic_colors.dart';
import '../tokens/tenkai_tokens.dart';

/// A small label bubble shown on hover (desktop) or long-press (touch). Uses
/// the inverted fill (`--fg` background, `--bg` text) with a hairline border.
class TenkaiTooltip extends StatelessWidget {
  const TenkaiTooltip({
    super.key,
    required this.label,
    required this.child,
    this.preferBelow = false,
  });

  final String label;
  final Widget child;
  final bool preferBelow;

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;
    return Tooltip(
      message: label,
      preferBelow: preferBelow,
      verticalOffset: 18,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: c.foreground,
        borderRadius: BorderRadius.circular(TenkaiRadius.badge),
        border: Border.all(color: c.border, width: 1),
      ),
      textStyle: TenkaiTypography.labelMd.copyWith(
        letterSpacing: 0,
        color: c.background,
      ),
      child: child,
    );
  }
}
