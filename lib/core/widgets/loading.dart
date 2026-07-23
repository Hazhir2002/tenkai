import 'package:flutter/material.dart';
import 'package:tenkai/core/design_system/tokens/tenkai_colors.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: TenkaiColors.white),
    );
  }
}
