import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/tenkai_tokens.dart';
import '../sounds/tenkai_sound.dart';
import 'tenkai_glow.dart';

// ─────────────────────────────────────────────
// TENKAI · Atom — TenkaiButton
// Three variants: primary, ghost, danger
// Context-aware LED: ghost = soft, primary = strong on press
// ─────────────────────────────────────────────

enum TenkaiButtonVariant { primary, ghost, danger, link }

enum TenkaiButtonSize { sm, md, lg }

class TenkaiButton extends StatefulWidget {
  const TenkaiButton({
    super.key,
    this.label,
    required this.onPressed,
    this.variant = TenkaiButtonVariant.primary,
    this.size = TenkaiButtonSize.md,
    this.icon,
    this.loading = false,
    this.enabled = true,
    this.sound,
  });

  final String? label;
  final VoidCallback? onPressed;
  final TenkaiButtonVariant variant;
  final TenkaiButtonSize size;
  final Widget? icon;
  final bool loading;
  final bool enabled;
  final TenkaiSoundEvent? sound;

  @override
  State<TenkaiButton> createState() => _TenkaiButtonState();
}

class _TenkaiButtonState extends State<TenkaiButton>
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

  bool get _isActive => widget.enabled && !widget.loading;

  TenkaiSoundEvent get _defaultSound {
    return switch (widget.variant) {
      TenkaiButtonVariant.primary => TenkaiSoundEvent.confirm,
      TenkaiButtonVariant.ghost => TenkaiSoundEvent.tap,
      TenkaiButtonVariant.danger => TenkaiSoundEvent.error,
      TenkaiButtonVariant.link => TenkaiSoundEvent.tap,
    };
  }

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
    TenkaiButtonSize.sm => const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 8,
    ),
    TenkaiButtonSize.md => const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 12,
    ),
    TenkaiButtonSize.lg => const EdgeInsets.symmetric(
      horizontal: 28,
      vertical: 16,
    ),
  };

  TextStyle get _labelStyle {
    final base = switch (widget.size) {
      TenkaiButtonSize.sm => TenkaiTypography.labelMd.copyWith(fontSize: 11),
      TenkaiButtonSize.md => TenkaiTypography.labelMd,
      TenkaiButtonSize.lg => TenkaiTypography.labelMd.copyWith(fontSize: 13),
    };
    return base.copyWith(color: _textColor, letterSpacing: 1.0);
  }

  Color get _textColor => switch (widget.variant) {
    TenkaiButtonVariant.primary => TenkaiColors.black,
    TenkaiButtonVariant.ghost => TenkaiColors.white,
    TenkaiButtonVariant.link => TenkaiColors.white,
    TenkaiButtonVariant.danger => TenkaiColors.error,
  };

  Color get _bgColor => switch (widget.variant) {
    TenkaiButtonVariant.primary => TenkaiColors.white,
    TenkaiButtonVariant.ghost => TenkaiColors.gray900,
    TenkaiButtonVariant.link => Colors.transparent,
    TenkaiButtonVariant.danger => TenkaiColors.gray900,
  };

  Color get _borderColor {
    if (_hovered || _pressed) {
      return switch (widget.variant) {
        TenkaiButtonVariant.primary => TenkaiColors.white,
        TenkaiButtonVariant.ghost => TenkaiColors.white,
        TenkaiButtonVariant.link => Colors.transparent,
        TenkaiButtonVariant.danger => TenkaiColors.error,
      };
    }
    return switch (widget.variant) {
      TenkaiButtonVariant.primary => TenkaiColors.white,
      TenkaiButtonVariant.ghost => TenkaiColors.gray700,
      TenkaiButtonVariant.link => Colors.transparent,
      TenkaiButtonVariant.danger => TenkaiColors.errorBorder,
    };
  }

  TenkaiGlowIntensity get _glowIntensity {
    if (!(_hovered || _pressed)) return TenkaiGlowIntensity.none;
    return switch (widget.variant) {
      TenkaiButtonVariant.primary => TenkaiGlowIntensity.strong,
      TenkaiButtonVariant.ghost => TenkaiGlowIntensity.soft,
      TenkaiButtonVariant.link => TenkaiGlowIntensity.soft,
      TenkaiButtonVariant.danger => TenkaiGlowIntensity.soft,
    };
  }

  Color get _glowColor => switch (widget.variant) {
    TenkaiButtonVariant.primary => TenkaiColors.white,
    TenkaiButtonVariant.ghost => TenkaiColors.white,
    TenkaiButtonVariant.link => TenkaiColors.white,
    TenkaiButtonVariant.danger => TenkaiColors.error,
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
            borderColor: _borderColor,
            glowColor: _glowColor,
            child: AnimatedContainer(
              duration: TenkaiDuration.medium,
              curve: TenkaiCurves.spring,
              padding: _padding,
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(TenkaiRadius.md),
                // Subtle inner fill on hover for ghost
                gradient:
                    (widget.variant != TenkaiButtonVariant.primary && _hovered)
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          TenkaiColors.white.withOpacity(0.04),
                          TenkaiColors.white.withOpacity(0.01),
                        ],
                      )
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    widget.icon!,
                    const SizedBox(width: 8),
                  ],
                  AnimatedSwitcher(
                    duration: TenkaiDuration.fast,
                    child: widget.loading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 1,
                              color: _textColor,
                            ),
                          )
                        : Text(widget.label!, style: _labelStyle),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
