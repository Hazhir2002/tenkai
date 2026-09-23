import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class TenkaiTypography {
  static TextStyle d1 = GoogleFonts.roboto(
    fontSize: 54,
    fontWeight: FontWeight.w400,
    letterSpacing: -1.08,
    height: 1.04,
  );

  static TextStyle d2 = GoogleFonts.roboto(
    fontSize: 40,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.72,
    height: 1.08,
  );

  static TextStyle d3 = GoogleFonts.roboto(
    fontSize: 30,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.45, // -0.015em
    height: 1.14,
  );

  static TextStyle h1 = GoogleFonts.roboto(
    fontSize: 26,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.312,
    height: 1.22,
  );

  static TextStyle h2 = GoogleFonts.roboto(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.16,
    height: 1.3,
  );

  static TextStyle h3 = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );

  static TextStyle titleLg = GoogleFonts.roboto(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  static TextStyle titleMd = GoogleFonts.roboto(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  static TextStyle titleSm = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static TextStyle bodyLg = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static TextStyle bodyMd = GoogleFonts.roboto(
    fontSize: 14.5,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static TextStyle bodySmall = GoogleFonts.roboto(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static TextStyle labelLg = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.14, // 0.01em
    height: 1.4,
  );

  static TextStyle labelMd = GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.12, // 0.01em
    height: 1.4,
  );

  static TextStyle labelSm = GoogleFonts.roboto(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.6, // 0.16em — wide-tracked all-caps meta
    height: 1.4,
  );

  static TextStyle mono = GoogleFonts.roboto(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.5,
  );
}
