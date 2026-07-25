import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/material.dart';
import 'package:tenkai/core/design_system/tenkai.dart';

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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating;
        final star = Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: TenkaiColors.white.withOpacity(0.35),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: CNIcon(
            symbol: CNSymbol(
              filled ? 'star.fill' : 'star',
              size: size,
              color: filled ? TenkaiColors.white : TenkaiColors.gray600,
            ),
          ),
        );
        if (onChanged == null) return star;
        return GestureDetector(
          onTap: () {
            onChanged!(i + 1);
            TenkaiSound.tap();
          },
          behavior: HitTestBehavior.opaque,
          child: star,
        );
      }),
    );
  }
}
