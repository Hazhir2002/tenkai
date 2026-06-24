import 'package:flutter/material.dart';

abstract final class TenkaiGlow {
  static List<BoxShadow> soft = [
    BoxShadow(color: Color(0x40FFFFFF), blurRadius: 8, spreadRadius: 0),
    BoxShadow(color: Color(0x14FFFFFF), blurRadius: 20, spreadRadius: 0),
  ];

  static List<BoxShadow> medium = [
    BoxShadow(color: Color(0x66FFFFFF), blurRadius: 12, spreadRadius: 0),
    BoxShadow(color: Color(0x26FFFFFF), blurRadius: 32, spreadRadius: 0),
    BoxShadow(color: Color(0x0DFFFFFF), blurRadius: 60, spreadRadius: 0),
  ];

  static List<BoxShadow> strong = [
    BoxShadow(color: Color(0x99FFFFFF), blurRadius: 16, spreadRadius: 0),
    BoxShadow(color: Color(0x40FFFFFF), blurRadius: 40, spreadRadius: 0),
    BoxShadow(color: Color(0x1AFFFFFF), blurRadius: 80, spreadRadius: 0),
  ];

  static List<BoxShadow> error = [
    BoxShadow(color: Color(0x4DFF4444), blurRadius: 12, spreadRadius: 0),
    BoxShadow(color: Color(0x1AFF4444), blurRadius: 32, spreadRadius: 0),
  ];

  static List<BoxShadow> success = [
    BoxShadow(color: Color(0x4D00CC66), blurRadius: 12, spreadRadius: 0),
    BoxShadow(color: Color(0x1A00CC66), blurRadius: 32, spreadRadius: 0),
  ];
}
