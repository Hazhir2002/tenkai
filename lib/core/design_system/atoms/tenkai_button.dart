import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/tenkai_semantic_colors.dart';
import '../tokens/tenkai_tokens.dart';
import '../sounds/tenkai_sound.dart';

// ─────────────────────────────────────────────
// TENKAI · Atom — TenkaiButton (flat)
// Variants: primary, secondary, ghost, danger, link.
// Emphasis is carried by fill + border weight, not color. Glow is restricted
// to the primary action (a restrained accent bloom); no ambient hover glow.
// ─────────────────────────────────────────────

enum TenkaiButtonVariant { primary, secondary, ghost, danger, link }

enum TenkaiButtonSize { sm, md, lg }

class TenkaiButton extends StatefulWidget {
  const TenkaiButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = TenkaiButtonVariant.primary,
    this.size = TenkaiButtonSize.md,
    this.icon,
    this.loading = false,
    this.enabled = true,
    this.sound,
  });

  final String label;
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
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: TenkaiDuration.instant,
    );
    // Press = 2.5% scale-down on the snap curve.
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.975).animate(
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
      TenkaiButtonVariant.danger => TenkaiSoundEvent.error,
      _ => TenkaiSoundEvent.tap,
    };
  }

  void _onTapDown(_) {
    if (!_isActive) return;
    _pressController.forward();
    HapticFeedback.mediumImpact();
    TenkaiSound.play(widget.sound ?? _defaultSound);
  }

  void _onTapUp(_) {
    if (!_isActive) return;
    _pressController.reverse();
    widget.onPressed?.call();
  }

  void _onTapCancel() => _pressController.reverse();

  EdgeInsets get _padding => switch (widget.size) {
    TenkaiButtonSize.sm => const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 7,
    ),
    TenkaiButtonSize.md => const EdgeInsets.symmetric(
      horizontal: 18,
      vertical: 10,
    ),
    TenkaiButtonSize.lg => const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 13,
    ),
  };

  double get _fontSize => switch (widget.size) {
    TenkaiButtonSize.sm => 11,
    TenkaiButtonSize.md => 12,
    TenkaiButtonSize.lg => 13,
  };

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;

    final (Color bg, Color fg, Color border) = switch (widget.variant) {
      TenkaiButtonVariant.primary => (c.accent, c.accentForeground, c.accent),
      TenkaiButtonVariant.secondary => (c.card, c.foreground, c.border),
      TenkaiButtonVariant.ghost => (Colors.transparent, c.foreground, c.border),
      TenkaiButtonVariant.danger => (
        Colors.transparent,
        c.destructive,
        c.border,
      ),
      TenkaiButtonVariant.link => (
        Colors.transparent,
        c.foreground,
        Colors.transparent,
      ),
    };

    // Glow is emphasis only: the primary action carries a restrained bloom.
    final shadow = widget.variant == TenkaiButtonVariant.primary && _isActive
        ? TenkaiGlow.accentOf(c.accent)
        : null;

    final labelStyle = TenkaiTypography.labelMd.copyWith(
      fontSize: _fontSize,
      color: fg,
      letterSpacing: _fontSize * 0.08,
    );

    return Opacity(
      opacity: widget.enabled ? 1.0 : 0.45,
      child: MouseRegion(
        cursor: _isActive
            ? SystemMouseCursors.click
            : SystemMouseCursors.forbidden,
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: AnimatedContainer(
              duration: TenkaiDuration.medium,
              curve: TenkaiCurves.easeOut,
              padding: _padding,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(TenkaiRadius.control),
                border: Border.all(color: border, width: 1),
                boxShadow: shadow,
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
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: fg,
                            ),
                          )
                        : Text(widget.label.toUpperCase(), style: labelStyle),
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
