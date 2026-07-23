import 'package:flutter/material.dart';
import 'package:tenkai/core/design_system/tokens/tenkai_colors.dart';

class ProgressBar extends StatelessWidget {
  final double progress;

  const ProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          height: 12,
          width: MediaQuery.of(context).size.width * progress,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [TenkaiColors.white, TenkaiColors.white.withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }
}
