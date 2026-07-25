import 'package:flutter/material.dart';
import '../tokens/tenkai_tokens.dart';
import 'tenkai_glow.dart';

/// A small glowing pill/dot marker — e.g. for timelines, diagrams, or
/// node-based layouts.
class TenkaiNode extends StatelessWidget {
  const TenkaiNode({
    super.key,
    this.size = 20,
    this.color = TenkaiColors.white,
    this.glowing = true,
  });

  final double size;
  final Color color;
  final bool glowing;

  @override
  Widget build(BuildContext context) {
    return TenkaiGlowWrapper(
      borderRadius: TenkaiRadius.pill,
      glowing: glowing,
      glowColor: color,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TenkaiRadius.pill),
          color: color,
        ),
      ),
    );
  }
}
