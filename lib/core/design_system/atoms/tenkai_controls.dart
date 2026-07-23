import 'package:flutter/material.dart';
import '../tokens/tenkai_tokens.dart';
import '../sounds/tenkai_sound.dart';
import 'tenkai_glow.dart';

class TenkaiInput extends StatefulWidget {
  const TenkaiInput({
    super.key,
    this.label,
    this.placeholder,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    this.suffix,
    this.prefix,
    this.enabled = true,
    this.maxLines = 1,
    this.autofillHints,
    this.textInputAction,
    this.focusNode,
  });

  final String? label;
  final String? placeholder;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;
  final Widget? prefix;
  final bool enabled;
  final int maxLines;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;

  @override
  State<TenkaiInput> createState() => _TenkaiInputState();
}

class _TenkaiInputState extends State<TenkaiInput> {
  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;

  @override
  void initState() {
    super.initState();

    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();

    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!.toUpperCase(), style: theme.textTheme.labelMedium),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          autofillHints: widget.autofillHints,
          textInputAction: widget.textInputAction,
          style: TenkaiTypography.body,
          cursorColor: TenkaiColors.white,
          cursorWidth: 1.8,
          cursorHeight: 20,
          cursorRadius: Radius.circular(TenkaiRadius.md),
          cursorOpacityAnimates: true,
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: TenkaiTypography.body.copyWith(
              color: TenkaiColors.gray600,
              fontWeight: FontWeight.w300,
            ),
            filled: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TenkaiRadius.md),
              borderSide: BorderSide(color: TenkaiColors.gray400),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TenkaiRadius.md),
              borderSide: BorderSide(color: TenkaiColors.gray400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TenkaiRadius.md),
              borderSide: BorderSide(color: TenkaiColors.gray400),
            ),
            prefixIcon: widget.prefix,
            prefixIconConstraints: BoxConstraints(maxWidth: 32, maxHeight: 32),
            suffixIcon: widget.suffix,
          ),
        ),
      ],
    );
  }
}

// ── TOGGLE ───────────────────────────────────

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
    TenkaiSound.tap();
  }

  @override
  Widget build(BuildContext context) {
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
                  borderRadius: BorderRadius.circular(12),
                  color: TenkaiColors.gray800,
                  border: Border.all(
                    color: Color.lerp(
                      TenkaiColors.gray700,
                      TenkaiColors.white,
                      t,
                    )!,
                    width: 0.5,
                  ),
                  boxShadow: t > 0.2
                      ? TenkaiGlow.soft
                            .map(
                              (s) => BoxShadow(
                                color: s.color.withOpacity(s.color.opacity * t),
                                blurRadius: s.blurRadius,
                              ),
                            )
                            .toList()
                      : null,
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
                            TenkaiColors.gray500,
                            TenkaiColors.white,
                            t,
                          ),
                          boxShadow: t > 0.5
                              ? [
                                  BoxShadow(
                                    color: TenkaiColors.white.withOpacity(
                                      0.6 * t,
                                    ),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
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
              style: TenkaiTypography.body.copyWith(fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

// ── CHECKBOX ─────────────────────────────────

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
    TenkaiSound.tap();
  }

  @override
  Widget build(BuildContext context) {
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
                  borderRadius: BorderRadius.circular(TenkaiRadius.sharp),
                  color: Color.lerp(Colors.transparent, TenkaiColors.white, t),
                  border: Border.all(
                    color: Color.lerp(
                      TenkaiColors.gray600,
                      TenkaiColors.white,
                      t,
                    )!,
                    width: 0.5,
                  ),
                  boxShadow: t > 0.3
                      ? [
                          BoxShadow(
                            color: TenkaiColors.white.withOpacity(0.25 * t),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: t > 0.5
                    ? CustomPaint(painter: _CheckmarkPainter(t))
                    : null,
              );
            },
          ),
          if (widget.label != null) ...[
            const SizedBox(width: 10),
            Text(
              widget.label!,
              style: TenkaiTypography.body.copyWith(fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  _CheckmarkPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TenkaiColors.black
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
  bool shouldRepaint(_CheckmarkPainter old) => old.t != t;
}

// ── RADIO ────────────────────────────────────

class TenkaiRadioGroup<T> extends StatelessWidget {
  const TenkaiRadioGroup({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.labels,
  });

  final List<T> options;
  final T value;
  final ValueChanged<T> onChanged;
  final List<String>? labels;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(options.length, (i) {
        final opt = options[i];
        final label = labels?[i] ?? opt.toString();
        final selected = opt == value;
        return GestureDetector(
          onTap: () {
            onChanged(opt);
            TenkaiSound.tap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: TenkaiDuration.medium,
                  curve: TenkaiCurves.spring,
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? TenkaiColors.white
                          : TenkaiColors.gray600,
                      width: 0.5,
                    ),
                    boxShadow: selected ? TenkaiGlow.soft : null,
                  ),
                  child: selected
                      ? Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: TenkaiColors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: TenkaiColors.white.withOpacity(0.8),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TenkaiTypography.body.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ── SLIDER ───────────────────────────────────

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
    final theme = Theme.of(context);

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
                  style: theme.textTheme.labelMedium,
                ),
              if (widget.showValue)
                Text(
                  widget.valueFormatter?.call(widget.value) ??
                      widget.value.toStringAsFixed(0),
                  style: TenkaiTypography.labelMd.copyWith(
                    color: TenkaiColors.white,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 1,
            activeTrackColor: TenkaiColors.white.withOpacity(
              _dragging ? 0.9 : 0.6,
            ),
            inactiveTrackColor: TenkaiColors.gray700,
            thumbColor: TenkaiColors.white,
            thumbShape: _TenkaiThumbShape(_dragging),
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
              if (_dragging) TenkaiSound.play(TenkaiSoundEvent.drag);
            },
          ),
        ),
      ],
    );
  }
}

class _TenkaiThumbShape extends SliderComponentShape {
  const _TenkaiThumbShape(this.active);
  final bool active;

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

    if (active) {
      canvas.drawCircle(
        center,
        18,
        Paint()..color = TenkaiColors.white.withOpacity(0.08),
      );
      canvas.drawCircle(
        center,
        12,
        Paint()..color = TenkaiColors.white.withOpacity(0.15),
      );
    }

    canvas.drawCircle(center, 7, Paint()..color = TenkaiColors.white);

    if (active) {
      canvas.drawCircle(
        center,
        7,
        Paint()
          ..color = TenkaiColors.white.withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
  }
}
