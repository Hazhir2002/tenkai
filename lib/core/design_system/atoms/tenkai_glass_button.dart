import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../sounds/tenkai_sound.dart';
import '../tokens/tenkai_tokens.dart';
import 'tenkai_glow.dart';

/// Which native Liquid Glass surface the button renders on.
enum TenkaiGlassButtonStyle { glass, prominentGlass }

CNButtonStyle _cnStyle(TenkaiGlassButtonStyle s) => switch (s) {
  TenkaiGlassButtonStyle.glass => CNButtonStyle.glass,
  TenkaiGlassButtonStyle.prominentGlass => CNButtonStyle.prominentGlass,
};

/// Drives the Tenkai LED glow + press sound/haptics around any child while
/// leaving the child's own tap handling intact. Used to wrap the native
/// `cupertino_native_better` glass buttons (which are platform views, so the
/// glow has to be a Flutter layer *around* them — the same technique
/// `TenkaiRecordButton` uses).
class _GlowPressLayer extends StatefulWidget {
  const _GlowPressLayer({
    required this.child,
    required this.enabled,
    required this.sound,
    required this.intensity,
    required this.borderRadius,
  });

  final Widget child;
  final bool enabled;
  final TenkaiSoundEvent sound;
  final TenkaiGlowIntensity intensity;
  final double borderRadius;

  @override
  State<_GlowPressLayer> createState() => _GlowPressLayerState();
}

class _GlowPressLayerState extends State<_GlowPressLayer> {
  bool _pressed = false;

  void _down(PointerDownEvent _) {
    if (!widget.enabled) return;
    setState(() => _pressed = true);
    HapticFeedback.mediumImpact();
    TenkaiSound.play(widget.sound);
  }

  void _up([PointerEvent? _]) {
    if (_pressed) setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _down,
      onPointerUp: _up,
      onPointerCancel: _up,
      child: TenkaiGlowWrapper(
        glowing: _pressed,
        intensity: widget.intensity,
        borderRadius: widget.borderRadius,
        borderColor: Colors.transparent,
        glowColor: TenkaiColors.white,
        child: widget.child,
      ),
    );
  }
}

/// A labelled button that mixes the native Liquid Glass surface of
/// `cupertino_native_better` with the Tenkai LED glow + press sound/haptics.
class TenkaiGlassButton extends StatelessWidget {
  const TenkaiGlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = TenkaiGlassButtonStyle.glass,
    this.enabled = true,
    this.sound,
    this.labelColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final CNSymbol? icon;
  final TenkaiGlassButtonStyle style;
  final bool enabled;
  final TenkaiSoundEvent? sound;
  final Color? labelColor;

  bool get _isActive => enabled && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final defaultSound = style == TenkaiGlassButtonStyle.prominentGlass
        ? TenkaiSoundEvent.confirm
        : TenkaiSoundEvent.tap;
    return _GlowPressLayer(
      enabled: _isActive,
      sound: sound ?? defaultSound,
      intensity: style == TenkaiGlassButtonStyle.prominentGlass
          ? TenkaiGlowIntensity.strong
          : TenkaiGlowIntensity.soft,
      borderRadius: TenkaiRadius.pill,
      child: CNButton(
        label: label,
        icon: icon,
        onPressed: _isActive ? onPressed : null,
        config: CNButtonConfig(style: _cnStyle(style), labelColor: labelColor),
      ),
    );
  }
}

/// Icon-only sibling of [TenkaiGlassButton].
class TenkaiGlassIconButton extends StatelessWidget {
  const TenkaiGlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.style = TenkaiGlassButtonStyle.glass,
    this.enabled = true,
    this.sound,
    this.width,
    this.minHeight,
  });

  final CNSymbol icon;
  final VoidCallback? onPressed;
  final TenkaiGlassButtonStyle style;
  final bool enabled;
  final TenkaiSoundEvent? sound;
  final double? width;
  final double? minHeight;

  bool get _isActive => enabled && onPressed != null;

  @override
  Widget build(BuildContext context) {
    return _GlowPressLayer(
      enabled: _isActive,
      sound: sound ?? TenkaiSoundEvent.tap,
      intensity: TenkaiGlowIntensity.soft,
      borderRadius: TenkaiRadius.pill,
      child: CNButton.icon(
        icon: icon,
        onPressed: _isActive ? onPressed : null,
        config: CNButtonConfig(
          style: _cnStyle(style),
          width: width,
          minHeight: minHeight,
        ),
      ),
    );
  }
}
