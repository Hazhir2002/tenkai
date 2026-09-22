import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_icon.dart';
import '../theme/tenkai_semantic_colors.dart';
import '../tokens/tenkai_tokens.dart';

// ─────────────────────────────────────────────
// TENKAI · Atom — TenkaiIconButton (flat)
// Icon-only affordance: transparent background, a muted fill appears on
// hover/press. No glow. Use TenkaiButton for labeled/filled buttons.
// ─────────────────────────────────────────────

enum TenkaiIconButtonSize { sm, md, lg }

class TenkaiIconButton extends StatefulWidget {
  const TenkaiIconButton({
    super.key,
    required this.iconAsset,
    required this.onPressed,
    this.size = TenkaiIconButtonSize.md,
    this.enabled = true,
  });

  final String iconAsset;
  final VoidCallback? onPressed;
  final TenkaiIconButtonSize size;
  final bool enabled;

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
      duration: TenkaiDuration.instant,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.975).animate(
      CurvedAnimation(parent: _pressController, curve: TenkaiCurves.snap),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  bool get _isActive => widget.enabled;

  void _onTapDown(_) {
    if (!_isActive) return;
    setState(() => _pressed = true);
    _pressController.forward();
    HapticFeedback.mediumImpact();
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
    TenkaiIconButtonSize.sm => const EdgeInsets.all(8),
    TenkaiIconButtonSize.md => const EdgeInsets.all(12),
    TenkaiIconButtonSize.lg => const EdgeInsets.all(16),
  };

  double get _iconSize => switch (widget.size) {
    TenkaiIconButtonSize.sm => 20,
    TenkaiIconButtonSize.md => 24,
    TenkaiIconButtonSize.lg => 32,
  };

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;
    final active = _hovered || _pressed;
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
          child: AnimatedContainer(
            duration: TenkaiDuration.fast,
            curve: TenkaiCurves.easeOut,
            padding: _padding,
            decoration: BoxDecoration(
              color: active ? c.card : Colors.transparent,
              borderRadius: BorderRadius.circular(TenkaiRadius.control),
            ),
            child: Opacity(
              opacity: widget.enabled ? 1.0 : 0.4,
              child: TenkaiIcon(
                assetName: widget.iconAsset,
                width: _iconSize,
                height: _iconSize,
                color: c.foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
