import 'package:flutter/material.dart';
import '../design_system/tokens/tenkai_tokens.dart';

// ─────────────────────────────────────────────
// TENKAI · Motion — the "unfold"
// Content arrives by rising a few px and easing open, one step at a time,
// never all at once. Everything settles; nothing bounces. Collapses under
// reduced-motion.
// ─────────────────────────────────────────────

/// A one-shot entrance: the child fades in while rising ~8px (and easing open
/// on the y-axis) on the spring curve. Mirrors the CSS `tk-unfold` keyframe.
/// Respects the platform "reduce motion" setting.
class TenkaiUnfold extends StatefulWidget {
  const TenkaiUnfold({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = TenkaiDuration.reveal,
    this.offset = 8,
    this.scaleY = false,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  /// Vertical rise distance in logical pixels.
  final double offset;

  /// Whether to also ease open on the y-axis (`scaleY .97 → 1`), as the CSS
  /// keyframe does for unfolding panels.
  final bool scaleY;

  @override
  State<TenkaiUnfold> createState() => _TenkaiUnfoldState();
}

class _TenkaiUnfoldState extends State<TenkaiUnfold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _anim = CurvedAnimation(
    parent: _ctrl,
    curve: TenkaiCurves.spring,
  );

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _ctrl.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduce) return widget.child;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final t = _anim.value;
        Widget result = Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, widget.offset * (1 - t)),
            child: child,
          ),
        );
        if (widget.scaleY) {
          result = Transform(
            alignment: Alignment.topCenter,
            transform: Matrix4.identity()..scale(1.0, 0.97 + 0.03 * t),
            child: result,
          );
        }
        return result;
      },
      child: widget.child,
    );
  }
}

/// Staggers a list of children so a list unfolds one row at a time
/// (`staggerStep` apart) rather than all at once.
class TenkaiStagger extends StatelessWidget {
  const TenkaiStagger({
    super.key,
    required this.children,
    this.step = TenkaiCurves.staggerStep,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.maxStaggered = 8,
  });

  final List<Widget> children;
  final Duration step;
  final CrossAxisAlignment crossAxisAlignment;

  /// Rows beyond this index all share the last delay, so long lists don't
  /// wait an absurd amount before the tail appears (mirrors the CSS
  /// `:nth-child(n+9)` clamp).
  final int maxStaggered;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++)
          TenkaiUnfold(
            delay: step * (i < maxStaggered ? i : maxStaggered),
            child: children[i],
          ),
      ],
    );
  }
}
