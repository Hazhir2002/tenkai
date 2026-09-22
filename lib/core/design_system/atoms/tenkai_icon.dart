import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tenkai/core/design_system/tenkai.dart';

class TenkaiIcon extends StatelessWidget {
  final String assetName;
  final double? width;
  final double? height;

  /// Defaults to the theme foreground (`context.tenkai.fg`) when null.
  final Color? color;

  const TenkaiIcon({
    super.key,
    required this.assetName,
    this.width = 24,
    this.height = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/$assetName.svg',
      width: width,
      height: height,
      colorFilter: ColorFilter.mode(
        color ?? context.tenkai.foreground,
        ui.BlendMode.srcIn,
      ),
    );
  }
}
