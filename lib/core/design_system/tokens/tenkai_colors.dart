import 'dart:ui';

abstract final class TenkaiColors {
  // ── Grayscale (core brand) ──
  static const black = Color(0xFF000000);
  static const gray950 = Color(0xFF080808);
  static const gray900 = Color(0xFF111111);
  static const gray800 = Color(0xFF1A1A1A);
  static const gray700 = Color(0xFF262626);
  static const gray600 = Color(0xFF404040);
  static const gray500 = Color(0xFF737373);
  static const gray400 = Color(0xFFA3A3A3);
  static const gray300 = Color(0xFFD4D4D4);
  static const gray200 = Color(0xFFE5E5E5);
  static const gray100 = Color(0xFFF5F5F5);
  static const white = Color(0xFFFFFFFF);

  // ── Semantic ──
  static const success = Color(0xFF00CC66);
  static const successDim = Color(0x1400CC66);
  static const successBorder = Color(0x2600CC66);

  static const warning = Color(0xFFCC8800);
  static const warningDim = Color(0x14CC8800);
  static const warningBorder = Color(0x26CC8800);

  static const error = Color(0xFFFF4444);
  static const errorDim = Color(0x14FF4444);
  static const errorBorder = Color(0x26FF4444);

  // ── LED Glow (white-based) ──
  static const ledDim = Color(0x0FFFFFFF);
  static const ledSoft = Color(0x2DFFFFFF);
  static const ledMid = Color(0x73FFFFFF);
  static const ledBright = Color(0xD9FFFFFF);
  static const ledFull = Color(0xFFFFFFFF);
}
