import 'package:flutter/material.dart';

import '../sounds/tenkai_sound.dart';
import '../theme/tenkai_semantic_colors.dart';
import '../tokens/tenkai_tokens.dart';

/// A small selectable pill. Selected = accent fill on accent-fg text;
/// unselected = flat hairline outline. Used for filters, day pickers, tags.
/// Flat — emphasis is fill + border, not glow.
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
    final c = context.tenkai;
    return GestureDetector(
      onTap: () {
        onTap();
        TenkaiSound.tap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: TenkaiDuration.fast,
        curve: TenkaiCurves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? c.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(TenkaiRadius.badge),
          border: Border.all(color: selected ? c.accent : c.border, width: 1),
        ),
        child: Text(
          label,
          style: TenkaiTypography.labelSm.copyWith(
            color: selected ? c.accentForeground : c.mutedForeground,
          ),
        ),
      ),
    );
  }
}
