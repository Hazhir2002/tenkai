import 'package:flutter/material.dart';
import '../design_system/theme/tenkai_semantic_colors.dart';
import '../design_system/tokens/tenkai_tokens.dart';

/// A small dot/pill marker — e.g. for timelines, diagrams, or node-based
/// layouts (the habit stacking chain). Flat by default; [glowing] adds the
/// restrained accent bloom that marks the single next/active node — one of the
/// only two places glow is allowed.
class TenkaiNode extends StatelessWidget {
  const TenkaiNode({
    super.key,
    this.size = 20,
    this.color,
    this.glowing = false,
  });

  final double size;
  final Color? color;
  final bool glowing;

  @override
  Widget build(BuildContext context) {
    final dotColor = color ?? context.tenkai.accent;
    return AnimatedContainer(
      duration: TenkaiDuration.medium,
      curve: TenkaiCurves.easeOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: dotColor,
        boxShadow: glowing
            ? TenkaiGlow.build(TenkaiGlow.accentSteps, color: dotColor)
            : null,
      ),
    );
  }
}
