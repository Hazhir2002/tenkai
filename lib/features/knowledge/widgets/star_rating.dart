import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import 'package:tenkai/core/theme/tenkai_semantic_colors.dart';

/// A 1–5 star rating. Read-only when [onChanged] is null.
class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.rating,
    this.onChanged,
    this.size = 28,
  });

  final int rating; // 0..5
  final ValueChanged<int>? onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating;
        final star = Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(
            filled ? IconsaxBold.star : IconsaxOutline.star,
            color: filled ? c.foreground : c.border,
          ),
        );
        if (onChanged == null) return star;
        return GestureDetector(
          onTap: () {
            onChanged!(i + 1);
          },
          behavior: HitTestBehavior.opaque,
          child: star,
        );
      }),
    );
  }
}
