import 'package:flutter/material.dart';
import 'tenkai_colors.dart';

/// A single glow shadow layer at full intensity (t = 1.0): opacity + blur
/// radius. [TenkaiGlow.build] scales these by animation progress and tints
/// them with an arbitrary color — this is the shared source of truth used
/// both by the static presets below and by the animated
/// `TenkaiGlowWrapper` in atoms/tenkai_glow.dart.
class TenkaiGlowStep {
  const TenkaiGlowStep(this.opacity, this.blurRadius);
  final double opacity;
  final double blurRadius;
}

abstract final class TenkaiGlow {
  static const List<TenkaiGlowStep> softSteps = [
    TenkaiGlowStep(0.25, 8),
    TenkaiGlowStep(0.08, 20),
  ];

  static const List<TenkaiGlowStep> mediumSteps = [
    TenkaiGlowStep(0.40, 12),
    TenkaiGlowStep(0.15, 32),
    TenkaiGlowStep(0.05, 60),
  ];

  static const List<TenkaiGlowStep> strongSteps = [
    TenkaiGlowStep(0.60, 16),
    TenkaiGlowStep(0.25, 40),
    TenkaiGlowStep(0.10, 80),
  ];

  static const List<TenkaiGlowStep> errorSteps = [
    TenkaiGlowStep(0.30, 12),
    TenkaiGlowStep(0.10, 32),
  ];

  static const List<TenkaiGlowStep> successSteps = [
    TenkaiGlowStep(0.30, 12),
    TenkaiGlowStep(0.10, 32),
  ];

  /// Builds a shadow list from [steps], tinted by [color] and scaled by
  /// animation progress [t] (1.0 = full intensity, as drawn by the presets
  /// below; callers driving an activation animation pass their own t).
  static List<BoxShadow> build(
    List<TenkaiGlowStep> steps, {
    Color color = TenkaiColors.white,
    double t = 1.0,
  }) {
    return [
      for (final step in steps)
        BoxShadow(
          color: color.withOpacity(step.opacity * t),
          blurRadius: step.blurRadius * t,
        ),
    ];
  }

  static List<BoxShadow> get soft => build(softSteps);
  static List<BoxShadow> get medium => build(mediumSteps);
  static List<BoxShadow> get strong => build(strongSteps);
  static List<BoxShadow> get error => build(errorSteps, color: TenkaiColors.error);
  static List<BoxShadow> get success =>
      build(successSteps, color: TenkaiColors.success);
}
