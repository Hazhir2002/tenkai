import 'dart:ui';

import 'package:flutter/material.dart';
import '../tokens/tenkai_tokens.dart';

/// A frosted "glassmorphism" panel: blurred backdrop, soft translucent fill,
/// a thin light-catching border, and a gentle shadow.
///
/// Honesty check: this is NOT Apple's real Liquid Glass material — it's the
/// blur-and-translucency look that's been common in UI design since ~2020.
/// Real Liquid Glass has dynamic specular highlights and refraction that
/// respond to content and motion, which Skia/Flutter's `BackdropFilter`
/// cannot reproduce; that behavior only exists in Apple's native rendering.
/// For the genuine material, see [NativeGlass] (`native_glass.dart`), which
/// wraps `cupertino_native_better`'s real platform-view Liquid Glass and
/// falls back to *this* widget only where no native material is available.
///
/// This widget still earns its keep though: `NativeGlass`'s platform views
/// are too expensive to place inside scrolling lists (the package's own
/// docs warn about this explicitly), so anywhere glass has to repeat inside
/// a `ListView`/`GridView` — like journal entry cards — this hand-drawn
/// version is the deliberate, correct choice, not a fallback of convenience.
class LiquidGlass extends StatelessWidget {
  const LiquidGlass({
    super.key,
    required this.child,
    this.borderRadius = TenkaiRadius.xl,
    this.padding = const EdgeInsets.all(20),
    this.blurSigma = 24,
    this.tint,
    this.margin,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final double blurSigma;

  /// Optional accent tint mixed into the glass, e.g. a soft red while
  /// recording. Defaults to a neutral white/gray glass.
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    final base = isDark ? Colors.white : Colors.white;
    final baseOpacity = isDark ? 0.08 : 0.45;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.10),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (tint ?? base).withOpacity(
                    (baseOpacity + 0.10).clamp(0.0, 1.0),
                  ),
                  (tint ?? base).withOpacity(
                    (baseOpacity - 0.10).clamp(0.0, 1.0),
                  ),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(isDark ? 0.18 : 0.6),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// The soft, blurred color-wash background every screen sits on. This is
/// just decorative depth behind the glass surfaces (native or hand-drawn) —
/// it isn't itself claiming to be Liquid Glass, it's what gives the real
/// native glass (and the Flutter-drawn fallback) something to sit over.
class LiquidBackground extends StatelessWidget {
  const LiquidBackground({super.key, this.child, this.accent});

  final Widget? child;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final a = accent ?? TenkaiColors.white;

    return Stack(
      fit: StackFit.expand,
      children: [
        // The color wash is blurred with ImageFiltered (a *foreground*
        // filter that blurs only its own child) instead of BackdropFilter.
        // BackdropFilter samples whatever sits behind it in the compositing
        // tree, so stacking one here underneath every LiquidGlass panel
        // elsewhere on screen means two backdrop filters end up nested.
        // That combination is a known trigger for a
        // 'dart:ui/painting.dart ... is not true' crash, especially once
        // anything above it animates. Using ImageFiltered here keeps the
        // whole screen down to a single BackdropFilter layer per glass
        // panel — the one that actually needs to see through to real
        // content behind it.
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [TenkaiColors.gray950, TenkaiColors.gray900]
                        : [const Color(0xFFF3F5FB), const Color(0xFFE9ECF7)],
                  ),
                ),
              ),
              // Monochrome glow blobs — no color accents, just layered
              // white-based washes at varying opacity/size for depth.
              Positioned(
                top: -120,
                left: -80,
                child: _blob(a.withOpacity(isDark ? 0.14 : 0.12), 280),
              ),
              Positioned(
                bottom: -100,
                right: -100,
                child: _blob(
                  TenkaiColors.white.withOpacity(isDark ? 0.10 : 0.10),
                  260,
                ),
              ),
              Positioned(
                top: 220,
                right: -60,
                child: _blob(
                  TenkaiColors.white.withOpacity(isDark ? 0.08 : 0.09),
                  200,
                ),
              ),
            ],
          ),
        ),
        if (child != null) child!,
      ],
    );
  }

  Widget _blob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
