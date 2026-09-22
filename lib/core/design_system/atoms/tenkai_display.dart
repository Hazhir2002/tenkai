import 'package:flutter/material.dart';
import '../theme/tenkai_semantic_colors.dart';
import '../tokens/tenkai_tokens.dart';

// ─────────────────────────────────────────────
// TENKAI · Atoms — Display (flat)
// TenkaiBadge, TenkaiCard, TenkaiMetricCard, TenkaiProgress, TenkaiDivider
// Flat hairline surfaces. No shadows. Glow is reserved for the focus ring and
// the primary action / selected node only — none of these carry ambient glow.
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

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;

    final (Color bg, Color text, Color border) = switch (variant) {
      TenkaiBadgeVariant.neutral => (c.card, c.mutedForeground, c.border),
      TenkaiBadgeVariant.active => (Colors.transparent, c.foreground, c.border),
      TenkaiBadgeVariant.success => (
        Colors.greenAccent,
        Colors.greenAccent,
        Colors.greenAccent,
      ),
      TenkaiBadgeVariant.warning => (
        Colors.yellowAccent,
        Colors.yellowAccent,
        Colors.yellowAccent,
      ),
      TenkaiBadgeVariant.error => (c.destructive, c.destructive, c.destructive),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(TenkaiRadius.badge),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(shape: BoxShape.circle, color: text),
            ),
          ],
          Text(
            label.toUpperCase(),
            style: TenkaiTypography.labelSm.copyWith(color: text),
          ),
        ],
      ),
    );
  }
}

/// Metric card — for KPI / stat display.
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
    final c = context.tenkai;

    return Card(
      // interactive: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TenkaiTypography.labelMd.copyWith(color: c.mutedForeground),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TenkaiTypography.d3.copyWith(
              fontSize: 28,
              color: accent ?? c.foreground,
            ),
          ),
          if (subtext != null) ...[
            const SizedBox(height: 4),
            Text(
              subtext!,
              style: TenkaiTypography.bodySmall.copyWith(
                color: c.secondaryForeground,
              ),
            ),
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
    final c = context.tenkai;
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
                Text(
                  label!,
                  style: TenkaiTypography.bodySmall.copyWith(
                    color: c.mutedForeground,
                  ),
                ),
              if (showPercent)
                Text(
                  '$pct%',
                  style: TenkaiTypography.labelMd.copyWith(
                    color: c.mutedForeground,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: 2,
              width: constraints.maxWidth,
              color: c.border,
              child: animated
                  ? TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: value),
                      duration: TenkaiDuration.reveal,
                      curve: TenkaiCurves.spring,
                      builder: (_, v, __) =>
                          _ProgressFill(v, constraints.maxWidth, c.accent),
                    )
                  : _ProgressFill(value, constraints.maxWidth, c.accent),
            );
          },
        ),
      ],
    );
  }
}

class _ProgressFill extends StatelessWidget {
  const _ProgressFill(this.value, this.maxWidth, this.color);
  final double value;
  final double maxWidth;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: maxWidth * value.clamp(0.0, 1.0),
      height: 2,
      color: color,
    );
  }
}

// ── DIVIDER ──────────────────────────────────

class TenkaiDivider extends StatelessWidget {
  const TenkaiDivider({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;

    if (label != null) {
      return Row(
        children: [
          Expanded(child: _line(c.border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label!.toUpperCase(),
              style: TenkaiTypography.labelSm.copyWith(
                color: c.mutedForeground,
              ),
            ),
          ),
          Expanded(child: _line(c.border)),
        ],
      );
    }
    return _line(c.border);
  }

  Widget _line(Color color) => Container(height: 1, color: color);
}
