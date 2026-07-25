import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/material.dart';

import '../tokens/tenkai_tokens.dart';
import 'tenkai_glass_button.dart';

// NOTE: there are two classes in this file — don't confuse them.
//   • GlassAppBar        → the actual bar. THIS is what goes in
//                          `Scaffold(appBar: ...)`. It implements
//                          PreferredSizeWidget.
//   • GlassAppBarAction  → a small 36x36 icon-button helper for the bar's
//                          `actions` row. It is NOT a bar itself and is not
//                          a PreferredSizeWidget.

/// A single action for [TenkaiAppBar]'s trailing row: a native glass icon
/// button with the Tenkai glow + press sound (via [TenkaiGlassIconButton]),
/// at a fixed 36x36 tap target so callers don't fight CNButton's own sizing.
class TenkaiAppBarAction extends StatelessWidget {
  const TenkaiAppBarAction({
    super.key,
    required this.symbol,
    required this.onPressed,
    this.size = 18,
  });

  /// SF Symbol name, e.g. 'heart.fill', 'square.list', 'trash'.
  final String symbol;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: TenkaiGlassIconButton(
        icon: CNSymbol(symbol, size: size),
        onPressed: onPressed,
        width: 36,
        minHeight: 36,
      ),
    );
  }
}

/// `compact` behaves like a standard nav bar: one line, small title.
/// `large` adds a big title beneath the compact bar (iOS "large title"
/// style) that fades into the compact title as [scrollController] scrolls.
enum TenkaiAppBarStyle { compact, large }

/// A Liquid Glass replacement for Flutter's [AppBar]. It's a drop-in for
/// `Scaffold(appBar: ...)` — same [PreferredSizeWidget] contract — rendered
/// as a real native Liquid Glass bar (via [NativeGlass]) instead of a solid
/// Material one.
///
/// There's no native "app bar" widget in `cupertino_native_better` to reuse
/// directly (it ships buttons, icons, a tab bar, slider, switch, segmented
/// control, popup menu, and a generic `LiquidGlassContainer` — no bar), so
/// this composes that generic native glass container as the bar surface,
/// with `CNButton`/`CNIcon` for every interactive piece.
///
/// Handles: safe-area top inset automatically, an automatic native-style
/// back chevron when the current route can pop, an optional large-title
/// mode that collapses into the compact title on scroll, and a trailing
/// row of consistently-sized [GlassAppBarAction]s.
class TenkaiAppBar extends StatefulWidget implements PreferredSizeWidget {
  const TenkaiAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions = const [],
    this.style = TenkaiAppBarStyle.compact,
    this.scrollController,
    this.centerTitle = true,
    this.showBackButton,
    this.bottom,
  });

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget> actions;
  final TenkaiAppBarStyle style;

  /// Drives the large-title → compact-title collapse. Pass the same
  /// controller you give your `ListView`/`CustomScrollView`.
  final ScrollController? scrollController;
  final bool centerTitle;

  /// Defaults to `Navigator.canPop`. Set explicitly to override.
  final bool? showBackButton;
  final PreferredSizeWidget? bottom;

  /// Height of the compact title row. Screens using `extendBodyBehindAppBar`
  /// should pad their scroll content by `MediaQuery.padding.top + compactHeight`
  /// so the first item clears the opaque title area.
  static const double compactHeight = 52;
  static const double _largeTitleExtra = 46;

  /// Extra height below the title over which the background gradient fades to
  /// transparent, so scrolling content dissolves under the bar.
  static const double _fadeExtra = 16;

  @override
  Size get preferredSize {
    final extra = style == TenkaiAppBarStyle.large ? _largeTitleExtra : 0.0;
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(compactHeight + _fadeExtra + extra + bottomHeight);
  }

  @override
  State<TenkaiAppBar> createState() => _TenkaiAppBarState();
}

class _TenkaiAppBarState extends State<TenkaiAppBar> {
  double _collapse = 0; // 0 = large title fully shown, 1 = fully collapsed

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant TenkaiAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_onScroll);
      widget.scrollController?.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final offset = widget.scrollController?.offset ?? 0;
    final next = (offset / TenkaiAppBar._largeTitleExtra).clamp(0.0, 1.0);
    if (next != _collapse) setState(() => _collapse = next);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isLarge = widget.style == TenkaiAppBarStyle.large;
    final canPop = Navigator.of(context).canPop();
    final showBack = widget.showBackButton ?? canPop;

    final compactTitleOpacity = isLarge ? _collapse : 1.0;
    final largeTitleOpacity = isLarge ? 1 - _collapse : 0.0;

    final defaultTitleStyle = TenkaiTypography.navTitle.copyWith(
      color: TenkaiColors.white.withOpacity(0.85),
    );
    final defaultLargeTitleStyle = TenkaiTypography.navTitleLarge.copyWith(
      color: TenkaiColors.white.withOpacity(0.9),
    );

    // The bar is not a glass panel — it's a fade. The background is solid
    // scaffold color (gray950) through the status bar + title area, then
    // dissolves to transparent over the bottom `_fadeExtra` band, so scroll
    // content passing behind the bar melts into the background.
    final largeExtra = isLarge ? TenkaiAppBar._largeTitleExtra : 0.0;
    final bottomHeight = widget.bottom?.preferredSize.height ?? 0;
    final contentHeight =
        topPadding + TenkaiAppBar.compactHeight + largeExtra + bottomHeight;
    final totalHeight = contentHeight + TenkaiAppBar._fadeExtra;
    final opaqueStop = (contentHeight / totalHeight).clamp(0.0, 1.0);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            TenkaiColors.gray950,
            TenkaiColors.gray950,
            TenkaiColors.gray950.withOpacity(0.0),
          ],
          stops: [0.0, opaqueStop, 1.0],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: TenkaiAppBar.compactHeight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 6),
                      if (widget.leading != null)
                        widget.leading!
                      else if (showBack)
                        TenkaiAppBarAction(
                          symbol: 'chevron.backward',
                          onPressed: () => Navigator.of(context).maybePop(),
                        )
                      else
                        const SizedBox(width: 36),
                      const Spacer(),
                      for (final action in widget.actions) ...[
                        action,
                        const SizedBox(width: 4),
                      ],
                      const SizedBox(width: 4),
                    ],
                  ),
                  // Compact title overlays the row, centered, and fades in
                  // as the large title (below) fades out on scroll.
                  IgnorePointer(
                    child: Opacity(
                      opacity: compactTitleOpacity,
                      child:
                          widget.titleWidget ??
                          Text(widget.title ?? '', style: defaultTitleStyle),
                    ),
                  ),
                ],
              ),
            ),
            if (isLarge)
              Opacity(
                opacity: largeTitleOpacity,
                child: Align(
                  alignment: widget.centerTitle
                      ? Alignment.center
                      : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child:
                        widget.titleWidget ??
                        Text(widget.title ?? '', style: defaultLargeTitleStyle),
                  ),
                ),
              ),
            if (widget.bottom != null) widget.bottom!,
            // Transparent band the gradient fades into.
            const SizedBox(height: TenkaiAppBar._fadeExtra),
          ],
        ),
      ),
    );
  }
}
