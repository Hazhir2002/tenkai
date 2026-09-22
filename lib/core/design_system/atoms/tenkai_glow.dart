import 'package:flutter/material.dart';
import '../theme/tenkai_semantic_colors.dart';
import '../tokens/tenkai_tokens.dart';

// ─────────────────────────────────────────────
// TENKAI · LED Glow Primitive
// The signature visual element: dormant → activated
// ─────────────────────────────────────────────

enum TenkaiGlowIntensity { none, soft, medium, strong }

/// Wraps any child in the LED glow effect.
/// State is driven externally (e.g. from hover / focus / pressed).
class TenkaiGlowWrapper extends StatefulWidget {
  const TenkaiGlowWrapper({
    super.key,
    required this.child,
    this.glowing = false,
    this.intensity = TenkaiGlowIntensity.medium,
    this.borderRadius = TenkaiRadius.sharp,
    this.borderColor,
    this.glowColor = TenkaiColors.white,
  });

  final Widget child;
  final bool glowing;
  final TenkaiGlowIntensity intensity;
  final double borderRadius;
  final Color? borderColor;
  final Color glowColor;

  @override
  State<TenkaiGlowWrapper> createState() => _TenkaiGlowWrapperState();
}

class _TenkaiGlowWrapperState extends State<TenkaiGlowWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: TenkaiDuration.medium,
    );
    _anim = CurvedAnimation(parent: _controller, curve: TenkaiCurves.spring);
    if (widget.glowing) _controller.forward();
  }

  @override
  void didUpdateWidget(TenkaiGlowWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.glowing != oldWidget.glowing) {
      if (widget.glowing) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<BoxShadow> _shadowsFor(double t) {
    final steps = switch (widget.intensity) {
      TenkaiGlowIntensity.none => const <TenkaiGlowStep>[],
      TenkaiGlowIntensity.soft => TenkaiGlow.softSteps,
      TenkaiGlowIntensity.medium => TenkaiGlow.mediumSteps,
      TenkaiGlowIntensity.strong => TenkaiGlow.strongSteps,
    };
    return TenkaiGlow.build(steps, color: widget.glowColor, t: t);
  }

  @override
  Widget build(BuildContext context) {
    final fallbackBorder = context.tenkai.border;
    final accent = context.tenkai.accent;
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final t = _anim.value;
        final borderOpacity = widget.glowing
            ? Color.lerp(widget.borderColor ?? fallbackBorder, accent, t)!
            : (widget.borderColor ?? fallbackBorder);

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(color: borderOpacity, width: 0.5),
            boxShadow: _shadowsFor(t),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// NOTE: `TenkaiLedGrid` (the ambient scanline animation) was retired — ambient
// glow contradicts the flat system, where glow means "the one thing to act on."
