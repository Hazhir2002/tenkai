import 'package:flutter/material.dart';
import '../tokens/tenkai_tokens.dart';

// ─────────────────────────────────────────────
// TENKAI · Atoms — Display
// TenkaiBadge, TenkaiCard, TenkaiProgress, TenkaiDivider
// ─────────────────────────────────────────────

// ── BADGE ────────────────────────────────────

enum TenkaiBadgeVariant { neutral, active, success, warning, error }

class TenkaiBadge extends StatelessWidget {
  const TenkaiBadge({
    super.key,
    required this.label,
    this.variant = TenkaiBadgeVariant.neutral,
    this.dot = false,
  });

  final String label;
  final TenkaiBadgeVariant variant;
  final bool dot;

  Color get _bg => switch (variant) {
    TenkaiBadgeVariant.neutral => TenkaiColors.gray800,
    TenkaiBadgeVariant.active => Colors.transparent,
    TenkaiBadgeVariant.success => TenkaiColors.successDim,
    TenkaiBadgeVariant.warning => TenkaiColors.warningDim,
    TenkaiBadgeVariant.error => TenkaiColors.errorDim,
  };

  Color get _text => switch (variant) {
    TenkaiBadgeVariant.neutral => TenkaiColors.gray400,
    TenkaiBadgeVariant.active => TenkaiColors.white,
    TenkaiBadgeVariant.success => TenkaiColors.success,
    TenkaiBadgeVariant.warning => TenkaiColors.warning,
    TenkaiBadgeVariant.error => TenkaiColors.error,
  };

  Color get _border => switch (variant) {
    TenkaiBadgeVariant.neutral => TenkaiColors.gray700,
    TenkaiBadgeVariant.active => TenkaiColors.gray500,
    TenkaiBadgeVariant.success => TenkaiColors.successBorder,
    TenkaiBadgeVariant.warning => TenkaiColors.warningBorder,
    TenkaiBadgeVariant.error => TenkaiColors.errorBorder,
  };

  List<BoxShadow>? get _glow => switch (variant) {
    TenkaiBadgeVariant.active => TenkaiGlow.soft,
    TenkaiBadgeVariant.success => TenkaiGlow.success,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(TenkaiRadius.sharp),
        border: Border.all(color: _border, width: 0.5),
        boxShadow: _glow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _text,
                boxShadow: [
                  BoxShadow(color: _text.withOpacity(0.5), blurRadius: 4),
                ],
              ),
            ),
          ],
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(color: _text),
          ),
        ],
      ),
    );
  }
}

// ── CARD ─────────────────────────────────────

class TenkaiCard extends StatefulWidget {
  const TenkaiCard({
    super.key,
    required this.child,
    this.padding,
    this.interactive = false,
    this.onTap,
    this.glowOnHover = false,
  });

  final Widget child;
  final EdgeInsets? padding;
  final bool interactive;
  final VoidCallback? onTap;
  final bool glowOnHover;

  @override
  State<TenkaiCard> createState() => _TenkaiCardState();
}

class _TenkaiCardState extends State<TenkaiCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: TenkaiDuration.medium,
      curve: TenkaiCurves.spring,
      padding: widget.padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TenkaiColors.gray900,
        borderRadius: BorderRadius.circular(TenkaiRadius.sm),
        border: Border.all(
          color: _hovered ? TenkaiColors.gray600 : TenkaiColors.gray800,
          width: 0.5,
        ),
        boxShadow: (_hovered && widget.glowOnHover) ? TenkaiGlow.soft : null,
      ),
      child: widget.child,
    );

    if (!widget.interactive) return card;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(onTap: widget.onTap, child: card),
    );
  }
}

/// Metric card — for KPI / stat display
class TenkaiMetricCard extends StatelessWidget {
  const TenkaiMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.subtext,
    this.accent,
  });

  final String label;
  final String value;
  final String? subtext;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TenkaiCard(
      interactive: true,
      glowOnHover: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
          Text(
            value,
            style: TenkaiTypography.d2.copyWith(
              fontSize: 28,
              color: accent ?? TenkaiColors.white,
            ),
          ),
          if (subtext != null) ...[
            const SizedBox(height: 4),
            Text(subtext!, style: TenkaiTypography.bodySmall),
          ],
        ],
      ),
    );
  }
}

// ── PROGRESS BAR ─────────────────────────────

class TenkaiProgress extends StatelessWidget {
  const TenkaiProgress({
    super.key,
    required this.value,
    this.label,
    this.showPercent = true,
    this.animated = true,
  });

  final double value; // 0.0 – 1.0
  final String? label;
  final bool showPercent;
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final pct = (value * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || showPercent) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                Text(label!, style: TenkaiTypography.bodySmall),
              if (showPercent) Text('$pct%', style: TenkaiTypography.labelMd),
            ],
          ),
          const SizedBox(height: 6),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: 1,
              width: constraints.maxWidth,
              color: TenkaiColors.gray800,
              child: animated
                  ? TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: value),
                      duration: TenkaiDuration.glow,
                      curve: TenkaiCurves.spring,
                      builder: (_, v, __) =>
                          _ProgressFill(v, constraints.maxWidth),
                    )
                  : _ProgressFill(value, constraints.maxWidth),
            );
          },
        ),
      ],
    );
  }
}

class _ProgressFill extends StatelessWidget {
  const _ProgressFill(this.value, this.maxWidth);
  final double value;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: maxWidth * value.clamp(0.0, 1.0),
      height: 1,
      decoration: BoxDecoration(
        color: TenkaiColors.white,
        boxShadow: [
          BoxShadow(color: TenkaiColors.white.withOpacity(0.4), blurRadius: 6),
        ],
      ),
    );
  }
}

// ── DIVIDER ──────────────────────────────────

class TenkaiDivider extends StatelessWidget {
  const TenkaiDivider({super.key, this.glow = false, this.label});

  final bool glow;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (label != null) {
      return Row(
        children: [
          Expanded(child: _line()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label!.toUpperCase(),
              style: theme.textTheme.labelMedium,
            ),
          ),
          Expanded(child: _line()),
        ],
      );
    }
    return _line();
  }

  Widget _line() {
    if (glow) {
      return Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              TenkaiColors.white.withOpacity(0.2),
              Colors.transparent,
            ],
          ),
        ),
      );
    }
    return Container(height: 0.5, color: TenkaiColors.gray800);
  }
}
