import 'package:flutter/material.dart';
import '../theme/tenkai_semantic_colors.dart';
import '../tokens/tenkai_tokens.dart';

// ─────────────────────────────────────────────
// TENKAI · Atoms — Controls (flat)
// Focus is the one place glow is mandatory: the border switches to --accent and
// the focus-ring bloom appears. Toggles/checkboxes/radios/sliders carry no
// ambient glow — emphasis is fill + border weight.
// ─────────────────────────────────────────────

// ── TOGGLE (flat pill) ───────────────────────

class TenkaiToggle extends StatefulWidget {
  const TenkaiToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;

  @override
  State<TenkaiToggle> createState() => _TenkaiToggleState();
}

class _TenkaiToggleState extends State<TenkaiToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _thumbAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: TenkaiDuration.medium,
      value: widget.value ? 1.0 : 0.0,
    );
    _thumbAnim = CurvedAnimation(parent: _ctrl, curve: TenkaiCurves.spring);
  }

  @override
  void didUpdateWidget(TenkaiToggle old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value) {
      widget.value ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    widget.onChanged(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;
    return GestureDetector(
      onTap: _toggle,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _thumbAnim,
            builder: (_, __) {
              final t = _thumbAnim.value;
              return Container(
                width: 44,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(TenkaiRadius.pill),
                  color: Color.lerp(c.card, c.accent, t),
                  border: Border.all(
                    color: Color.lerp(c.border, c.accent, t)!,
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 3 + (20 * t),
                      top: 3,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.lerp(
                            c.secondaryForeground,
                            c.accentForeground,
                            t,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (widget.label != null) ...[
            const SizedBox(width: 10),
            Text(
              widget.label!,
              style: TenkaiTypography.bodySmall.copyWith(color: c.foreground),
            ),
          ],
        ],
      ),
    );
  }
}

// ── CHECKBOX (flat) ──────────────────────────

class TenkaiCheckbox extends StatefulWidget {
  const TenkaiCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;

  @override
  State<TenkaiCheckbox> createState() => _TenkaiCheckboxState();
}

class _TenkaiCheckboxState extends State<TenkaiCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: TenkaiDuration.fast,
      value: widget.value ? 1.0 : 0.0,
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: TenkaiCurves.spring);
  }

  @override
  void didUpdateWidget(TenkaiCheckbox old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value) {
      widget.value ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    widget.onChanged(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;
    return GestureDetector(
      onTap: _toggle,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) {
              final t = _anim.value;
              return Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(TenkaiRadius.check),
                  color: Color.lerp(Colors.transparent, c.accent, t),
                  border: Border.all(
                    color: Color.lerp(c.border, c.accent, t)!,
                    width: 1,
                  ),
                ),
                child: t > 0.5
                    ? CustomPaint(
                        painter: _CheckmarkPainter(t, c.accentForeground),
                      )
                    : null,
              );
            },
          ),
          if (widget.label != null) ...[
            const SizedBox(width: 10),
            Text(
              widget.label!,
              style: TenkaiTypography.bodySmall.copyWith(color: c.foreground),
            ),
          ],
        ],
      ),
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  _CheckmarkPainter(this.t, this.color);
  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.5)
      ..lineTo(size.width * 0.42, size.height * 0.74)
      ..lineTo(size.width * 0.82, size.height * 0.26);

    final metric = path.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, metric.length * ((t - 0.5) * 2).clamp(0, 1)),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CheckmarkPainter old) => old.t != t || old.color != color;
}

class TenkaiSlider extends StatefulWidget {
  const TenkaiSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.showValue = true,
    this.valueFormatter,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final String? label;
  final double min;
  final double max;
  final int? divisions;
  final bool showValue;
  final String Function(double)? valueFormatter;

  @override
  State<TenkaiSlider> createState() => _TenkaiSliderState();
}

class _TenkaiSliderState extends State<TenkaiSlider> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null || widget.showValue) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.label != null)
                Text(
                  widget.label!.toUpperCase(),
                  style: TenkaiTypography.labelMd.copyWith(
                    color: c.mutedForeground,
                  ),
                ),
              if (widget.showValue)
                Text(
                  widget.valueFormatter?.call(widget.value) ??
                      widget.value.toStringAsFixed(0),
                  style: TenkaiTypography.labelMd.copyWith(color: c.foreground),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 1,
            activeTrackColor: c.accent,
            inactiveTrackColor: c.border,
            thumbColor: c.accent,
            thumbShape: _TenkaiThumbShape(_dragging, c.accent, c.card),
            overlayShape: SliderComponentShape.noOverlay,
            trackShape: const RectangularSliderTrackShape(),
          ),
          child: Slider(
            value: widget.value,
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            onChangeStart: (_) => setState(() => _dragging = true),
            onChangeEnd: (_) => setState(() => _dragging = false),
            onChanged: (v) {
              widget.onChanged(v);
            },
          ),
        ),
      ],
    );
  }
}

class _TenkaiThumbShape extends SliderComponentShape {
  const _TenkaiThumbShape(this.active, this.color, this.ringColor);
  final bool active;
  final Color color;
  final Color ringColor;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(14, 14);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    // Flat thumb: a filled accent circle, slightly larger while dragging. No
    // glow, no blur.
    canvas.drawCircle(center, active ? 8 : 7, Paint()..color = color);
  }
}
