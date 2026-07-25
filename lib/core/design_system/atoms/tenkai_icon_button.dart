import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_icon.dart';
import '../tokens/tenkai_tokens.dart';
import '../sounds/tenkai_sound.dart';
import 'tenkai_glow.dart';

// ─────────────────────────────────────────────
// TENKAI · Atom — TenkaiIconButton
// Minimal icon-only affordance: transparent background,
// soft LED glow on hover/press. No variants — use TenkaiButton
// for labeled/filled buttons.
// ─────────────────────────────────────────────

enum TenkaiIconButtonSize { sm, md, lg }

class TenkaiIconButton extends StatefulWidget {
  const TenkaiIconButton({
    super.key,
    required this.iconAsset,
    required this.onPressed,
    this.size = TenkaiIconButtonSize.md,
    this.enabled = true,
    this.sound,
  });

  final String iconAsset;
  final VoidCallback? onPressed;
  final TenkaiIconButtonSize size;
  final bool enabled;
  final TenkaiSoundEvent? sound;

  @override
  State<TenkaiIconButton> createState() => _TenkaiIconButtonState();
}

class _TenkaiIconButtonState extends State<TenkaiIconButton>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  bool _pressed = false;

  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: TenkaiDuration.fast,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: TenkaiCurves.snap),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  bool get _isActive => widget.enabled;

  final TenkaiSoundEvent _defaultSound = TenkaiSoundEvent.tap;

  void _onTapDown(_) {
    if (!_isActive) return;
    setState(() => _pressed = true);
    _pressController.forward();
    HapticFeedback.mediumImpact();
    TenkaiSound.play(widget.sound ?? _defaultSound);
  }

  void _onTapUp(_) {
    if (!_isActive) return;
    setState(() => _pressed = false);
    _pressController.reverse();
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    setState(() => _pressed = false);
    _pressController.reverse();
  }

  EdgeInsets get _padding => switch (widget.size) {
    TenkaiIconButtonSize.sm => const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 8,
    ),
    TenkaiIconButtonSize.md => const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 12,
    ),
    TenkaiIconButtonSize.lg => const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 16,
    ),
  };

  TenkaiGlowIntensity get _glowIntensity {
    if (!(_hovered || _pressed)) return TenkaiGlowIntensity.none;
    return TenkaiGlowIntensity.soft;
  }

  double get _iconSize => switch (widget.size) {
    TenkaiIconButtonSize.sm => 20,
    TenkaiIconButtonSize.md => 24,
    TenkaiIconButtonSize.lg => 32,
  };

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: _isActive
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: TenkaiGlowWrapper(
            glowing: _hovered || _pressed,
            intensity: _glowIntensity,
            borderRadius: TenkaiRadius.md,
            borderColor: Colors.transparent,
            glowColor: TenkaiColors.white,
            child: AnimatedContainer(
              duration: TenkaiDuration.medium,
              curve: TenkaiCurves.spring,
              padding: _padding,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(TenkaiRadius.md),
              ),
              child: TenkaiIcon(
                assetName: widget.iconAsset,
                width: _iconSize,
                height: _iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
