import 'package:flutter/material.dart';

import '../sounds/tenkai_sound.dart';
import '../tokens/tenkai_tokens.dart';

/// A small selectable pill. Selected = white fill on black text with a soft
/// LED glow; unselected = outlined. Used for filters, day pickers, tags, etc.
class TenkaiChip extends StatelessWidget {
  const TenkaiChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
        TenkaiSound.tap();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? TenkaiColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(TenkaiRadius.sharp),
          border: Border.all(
            color: selected ? TenkaiColors.white : TenkaiColors.gray700,
            width: 0.5,
          ),
          boxShadow: selected ? TenkaiGlow.soft : null,
        ),
        child: Text(
          label,
          style: TenkaiTypography.labelSm.copyWith(
            color: selected ? TenkaiColors.black : TenkaiColors.gray400,
          ),
        ),
      ),
    );
  }
}
