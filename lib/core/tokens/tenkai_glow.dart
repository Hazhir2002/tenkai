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
  // Aligned to the Claude Design export (tokens/glow.css). Glow is emphasis
  // only — the focus ring and the primary action / selected node. Never
  // ambient decoration.
  static const List<TenkaiGlowStep> softSteps = [
    TenkaiGlowStep(0.18, 8),
  ];

  static const List<TenkaiGlowStep> mediumSteps = [
    TenkaiGlowStep(0.28, 12),
    TenkaiGlowStep(0.10, 32),
  ];

  static const List<TenkaiGlowStep> strongSteps = [
    TenkaiGlowStep(0.40, 16),
    TenkaiGlowStep(0.14, 40),
  ];

  static const List<TenkaiGlowStep> errorSteps = [
    TenkaiGlowStep(0.30, 12),
  ];

  static const List<TenkaiGlowStep> successSteps = [
    TenkaiGlowStep(0.30, 12),
  ];

  /// The focus-ring bloom (the 1px accent ring itself is drawn as a border).
  static const List<TenkaiGlowStep> focusSteps = [
    TenkaiGlowStep(0.18, 12),
  ];

  /// The restrained bloom on the primary button / selected node.
  static const List<TenkaiGlowStep> accentSteps = [
    TenkaiGlowStep(0.30, 16),
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

  /// Focus-ring bloom — pair with a 1px accent border.
  static List<BoxShadow> get focus => build(focusSteps);

  /// Primary action / selected-node bloom.
  static List<BoxShadow> get accent => build(accentSteps);

  /// Theme-aware variants — tint the bloom by the current accent so it reads on
  /// both light and dark (white glow on dark, near-black on light).
  static List<BoxShadow> focusOf(Color color) => build(focusSteps, color: color);
  static List<BoxShadow> accentOf(Color color) =>
      build(accentSteps, color: color);
}
