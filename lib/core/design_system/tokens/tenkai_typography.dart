import 'package:flutter/material.dart';
import 'package:tenkai/core/design_system/tokens/tenkai_colors.dart';

abstract final class TenkaiTypography {
  static const fontDisplay = 'Inter';
  static const fontBody = 'Roboto';

  // ── Display ──
  static const TextStyle d1 = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 56,
    fontWeight: FontWeight.w300,
    letterSpacing: -2.24, // -0.04em
    height: 1.05,
    color: TenkaiColors.white,
  );

  static const TextStyle d2 = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 40,
    fontWeight: FontWeight.w300,
    letterSpacing: -1.2,
    height: 1.1,
    color: TenkaiColors.white,
  );

  static const TextStyle d3 = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 32,
    fontWeight: FontWeight.w300,
    letterSpacing: -1.2,
    height: 1.1,
    color: TenkaiColors.white,
  );

  // ── Headings ──
  static const TextStyle h1 = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.56,
    height: 1.2,
    color: TenkaiColors.white,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
    color: TenkaiColors.white,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.15,
    height: 1.4,
    color: TenkaiColors.white,
  );

  // ── title ──
  static const TextStyle titleLg = TextStyle(
    fontFamily: fontBody,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.56,
    height: 1.2,
    color: TenkaiColors.white,
  );

  static const TextStyle titleMd = TextStyle(
    fontFamily: fontBody,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
    color: TenkaiColors.white,
  );

  static const TextStyle titleSm = TextStyle(
    fontFamily: fontBody,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.15,
    height: 1.4,
    color: TenkaiColors.white,
  );

  // ── Body ──
  static const TextStyle bodyLg = TextStyle(
    fontFamily: fontBody,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.6,
    color: TenkaiColors.gray200,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: fontBody,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.6,
    color: TenkaiColors.gray200,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontBody,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
    color: TenkaiColors.gray200,
  );

  // ── Label / Utility ──

  static const TextStyle labelLg = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.2,
    height: 1.4,
    color: TenkaiColors.gray400,
  );

  static const TextStyle labelMd = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.8,
    height: 1.4,
    color: TenkaiColors.gray400,
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.8,
    height: 1.4,
    color: TenkaiColors.gray400,
  );

  static const TextStyle mono = TextStyle(
    fontFamily: fontBody, // no monospace face is bundled; falls back to body
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.5,
    color: TenkaiColors.gray500,
  );

  // ── Navigation (TenkaiAppBar) ──
  static const TextStyle navTitle = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: TenkaiColors.white,
  );

  static const TextStyle navTitleLarge = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: TenkaiColors.white,
  );
}
