import 'package:flutter/material.dart';
import '../theme/tenkai_semantic_colors.dart';
import '../tokens/tenkai_tokens.dart';

enum TenkaiIconTileSize { sm, md, lg }

/// A muted-fill, hairline-bordered square that holds an icon — for list rows,
/// profile headers, and specimen grids. The container is part of the icon
/// language, not decoration. Optionally selectable (accent fill).
class TenkaiIconTile extends StatelessWidget {
  const TenkaiIconTile({
    super.key,
    required this.child,
    this.size = TenkaiIconTileSize.md,
    this.selected = false,
    this.onTap,
  });

  /// The icon to render (e.g. a `CNIcon`, `TenkaiIcon`, or `Icon`).
  final Widget child;
  final TenkaiIconTileSize size;
  final bool selected;
  final VoidCallback? onTap;

  double get _box => switch (size) {
    TenkaiIconTileSize.sm => 32,
    TenkaiIconTileSize.md => 38,
    TenkaiIconTileSize.lg => 46,
  };

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;
    final tile = AnimatedContainer(
      duration: TenkaiDuration.medium,
      curve: TenkaiCurves.spring,
      width: _box,
      height: _box,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? c.accent : c.card,
        borderRadius: BorderRadius.circular(TenkaiRadius.tile),
        border: Border.all(color: selected ? c.accent : c.border, width: 1),
      ),
      child: IconTheme.merge(
        data: IconThemeData(
          color: selected ? c.accentForeground : c.foreground,
        ),
        child: child,
      ),
    );

    if (onTap == null) return tile;
    return GestureDetector(
      onTap: () {
        onTap!();
      },
      behavior: HitTestBehavior.opaque,
      child: tile,
    );
  }
}
