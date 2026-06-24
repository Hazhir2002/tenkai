import 'package:flutter/material.dart';

abstract final class TenkaiCurves {
  static const spring = Cubic(0.16, 1, 0.3, 1);
  static const snap = Cubic(0.4, 0, 0.2, 1);
}
