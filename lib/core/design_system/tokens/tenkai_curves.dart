import 'package:flutter/material.dart';

abstract final class TenkaiCurves {
  /// The signature "unfold" curve — content rises and eases open, never bounces.
  static const spring = Cubic(0.16, 1, 0.3, 1);
  static const snap = Cubic(0.4, 0, 0.2, 1);
  static const easeOut = Cubic(0.22, 0.61, 0.36, 1);
  static const easeInOut = Cubic(0.65, 0, 0.35, 1);

  /// Delay between successive rows in a staggered list ("one step at a time").
  static const staggerStep = Duration(milliseconds: 55);
}
