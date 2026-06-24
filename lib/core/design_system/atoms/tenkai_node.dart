import 'package:flutter/material.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_glow.dart';
import 'package:tenkai/core/design_system/tokens/tenkai_tokens.dart';

class TenkaiNode extends StatelessWidget {
  const TenkaiNode({super.key});

  @override
  Widget build(BuildContext context) {
    return TenkaiGlowWrapper(
      borderRadius: TenkaiRadius.pill,
      glowing: true,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TenkaiRadius.pill),
          color: TenkaiColors.white,
        ),
      ),
    );
  }
}
