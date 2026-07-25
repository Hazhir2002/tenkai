import 'package:flutter/material.dart';
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
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final t = _anim.value;
        final borderOpacity = widget.glowing
            ? Color.lerp(
                widget.borderColor ?? TenkaiColors.gray700,
                TenkaiColors.white,
                t,
              )!
            : (widget.borderColor ?? TenkaiColors.gray700);

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

/// Scanline LED grid — the hero ambient animation for backgrounds / headers
class TenkaiLedGrid extends StatefulWidget {
  const TenkaiLedGrid({
    super.key,
    this.columns = 24,
    this.rows = 4,
    this.dotSize = 6.0,
    this.gap = 3.0,
  });

  final int columns;
  final int rows;
  final double dotSize;
  final double gap;

  @override
  State<TenkaiLedGrid> createState() => _TenkaiLedGridState();
}

class _TenkaiLedGridState extends State<TenkaiLedGrid>
    with TickerProviderStateMixin {
  late List<double> _brightness;
  late AnimationController _scanController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    final total = widget.columns * widget.rows;
    _brightness = List.filled(total, 0.05);

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scanController.addListener(_onScan);
    _triggerRandomWave();
  }

  void _onScan() {
    final col =
        (_scanController.value * widget.columns).floor() % widget.columns;
    setState(() {
      for (var r = 0; r < widget.rows; r++) {
        final idx = r * widget.columns + col;
        if (idx < _brightness.length) {
          _brightness[idx] = 0.35;
        }
        final prev =
            r * widget.columns + ((col - 1 + widget.columns) % widget.columns);
        if (prev < _brightness.length && _brightness[prev] > 0.06) {
          _brightness[prev] = (_brightness[prev] - 0.04).clamp(0.05, 1.0);
        }
      }
    });
  }

  void _triggerRandomWave() {
    Future.delayed(
      Duration(
        milliseconds: 400 + (400 * (DateTime.now().millisecond / 1000)).round(),
      ),
      () {
        if (!mounted) return;
        final rand = DateTime.now().millisecondsSinceEpoch;
        final center = rand % widget.columns;
        final row = (rand ~/ widget.columns) % widget.rows;
        for (var i = 0; i < widget.columns; i++) {
          final dist = (i - center).abs();
          if (dist <= 4) {
            final delay = dist * 40;
            Future.delayed(Duration(milliseconds: delay), () {
              if (!mounted) return;
              final idx = row * widget.columns + i;
              setState(() => _brightness[idx] = 1.0 - dist * 0.18);
              Future.delayed(const Duration(milliseconds: 320), () {
                if (!mounted) return;
                setState(() => _brightness[idx] = 0.05);
              });
            });
          }
        }
        _triggerRandomWave();
      },
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: widget.gap,
          runSpacing: widget.gap,
          children: List.generate(widget.columns * widget.rows, (i) {
            final b = _brightness[i].clamp(0.0, 1.0);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: widget.dotSize,
              height: widget.dotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.lerp(TenkaiColors.gray800, TenkaiColors.white, b),
                boxShadow: b > 0.4
                    ? [
                        BoxShadow(
                          color: TenkaiColors.white.withOpacity(b * 0.7),
                          blurRadius: 6,
                        ),
                        BoxShadow(
                          color: TenkaiColors.white.withOpacity(b * 0.3),
                          blurRadius: 12,
                        ),
                      ]
                    : null,
              ),
            );
          }),
        );
      },
    );
  }
}
