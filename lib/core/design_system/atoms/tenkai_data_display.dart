import 'package:flutter/material.dart';
import '../theme/tenkai_semantic_colors.dart';
import '../tokens/tenkai_tokens.dart';
import 'tenkai_motion.dart';

// ─────────────────────────────────────────────
// TENKAI · Atoms — Data display (flat)
// TenkaiListRow, TenkaiAvatar, TenkaiSkeleton, TenkaiEmptyState
// ─────────────────────────────────────────────

// ── LIST ROW ─────────────────────────────────

/// A single row: optional leading/trailing widgets around a title + subtitle.
/// Flat surface; hover strengthens the border and nudges the row 2px, selected
/// promotes the border to accent.
class TenkaiListRow extends StatefulWidget {
  const TenkaiListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.selected = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool selected;

  @override
  State<TenkaiListRow> createState() => _TenkaiListRowState();
}

class _TenkaiListRowState extends State<TenkaiListRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;
    final interactive = widget.onTap != null;

    final Color border = widget.selected
        ? c.accent
        : (_hovered && interactive ? c.border : c.border);

    final row = AnimatedContainer(
      duration: TenkaiDuration.medium,
      curve: TenkaiCurves.easeOut,
      transform: Matrix4.translationValues(
        _hovered && interactive ? 2 : 0,
        0,
        0,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: widget.selected ? c.card : c.card,
        borderRadius: BorderRadius.circular(TenkaiRadius.card),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        children: [
          if (widget.leading != null) ...[
            widget.leading!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TenkaiTypography.bodyMd.copyWith(color: c.foreground),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TenkaiTypography.labelMd.copyWith(
                      color: c.secondaryForeground,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (widget.trailing != null) ...[
            const SizedBox(width: 12),
            widget.trailing!,
          ],
        ],
      ),
    );

    if (!interactive) return row;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(onTap: widget.onTap, child: row),
    );
  }
}

// ── AVATAR ───────────────────────────────────

enum TenkaiAvatarSize { sm, md, lg }

/// A circular avatar. Shows [image] if given, else the initials of [name] on a
/// muted hairline-bordered circle.
class TenkaiAvatar extends StatelessWidget {
  const TenkaiAvatar({
    super.key,
    this.name = '',
    this.image,
    this.size = TenkaiAvatarSize.md,
  });

  final String name;
  final ImageProvider? image;
  final TenkaiAvatarSize size;

  double get _px => switch (size) {
    TenkaiAvatarSize.sm => 28,
    TenkaiAvatarSize.md => 38,
    TenkaiAvatarSize.lg => 52,
  };

  String get _initials {
    final parts = name.split(' ').where((p) => p.isNotEmpty).take(2);
    return parts.map((p) => p[0]).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;
    return Container(
      width: _px,
      height: _px,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: c.card,
        border: Border.all(color: c.border, width: 1),
        image: image != null
            ? DecorationImage(image: image!, fit: BoxFit.cover)
            : null,
      ),
      child: image == null
          ? Text(
              _initials,
              style: TenkaiTypography.labelMd.copyWith(
                fontSize: _px * 0.34,
                letterSpacing: _px * 0.34 * 0.02,
                color: c.mutedForeground,
              ),
            )
          : null,
    );
  }
}

// ── SKELETON ─────────────────────────────────

/// A shimmering placeholder for content that's still loading (mirrors the CSS
/// `tk-shimmer` sweep). Use [circle] for avatars/dots.
class TenkaiSkeleton extends StatefulWidget {
  const TenkaiSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 14,
    this.radius = TenkaiRadius.badge,
    this.circle = false,
  });

  final double width;
  final double height;
  final double radius;
  final bool circle;

  @override
  State<TenkaiSkeleton> createState() => _TenkaiSkeletonState();
}

class _TenkaiSkeletonState extends State<TenkaiSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final w = widget.circle ? widget.height : widget.width;
    final borderRadius = widget.circle
        ? BorderRadius.circular(widget.height)
        : BorderRadius.circular(widget.radius);

    if (reduce) {
      return Container(
        width: w,
        height: widget.height,
        decoration: BoxDecoration(color: c.card, borderRadius: borderRadius),
      );
    }

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        // Sweep the highlight band across, easing in-out.
        final t = TenkaiCurves.easeInOut.transform(_ctrl.value);
        final pos = -1.5 + 3.0 * t; // -1.5 → 1.5 alignment.x
        return Container(
          width: w,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment(pos - 1, 0),
              end: Alignment(pos + 1, 0),
              colors: [c.card, c.border, c.card],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

// ── EMPTY STATE ──────────────────────────────

/// A centered empty/zero state: optional icon, a display-face title, an
/// optional description, and an optional action. Rises in on mount.
class TenkaiEmptyState extends StatelessWidget {
  const TenkaiEmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.action,
  });

  final String title;
  final String? description;
  final Widget? icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;
    return TenkaiUnfold(
      offset: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Opacity(opacity: 0.9, child: icon!),
              const SizedBox(height: 12),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: TenkaiTypography.titleMd.copyWith(
                fontSize: 19,
                color: c.foreground,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: TenkaiTypography.bodyMd.copyWith(
                    color: c.mutedForeground,
                  ),
                ),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 18), action!],
          ],
        ),
      ),
    );
  }
}
