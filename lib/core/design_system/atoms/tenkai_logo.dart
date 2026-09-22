import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/tenkai_semantic_colors.dart';
import '../tokens/tenkai_tokens.dart';

/// The Tenkai mark — three panels stepping upward (the day unfolding one step
/// at a time), the near step solid and the further steps falling back in
/// opacity. Drawn in `currentColor` so it inverts cleanly between themes.
///
/// Never re-color it beyond the single [color], outline it, add gloss, or
/// rotate it. Use [solid] for small/inverted tiles where the stepped opacity
/// would be lost.
class TenkaiLogoMark extends StatelessWidget {
  const TenkaiLogoMark({
    super.key,
    this.size = 32,
    this.color,
    this.solid = false,
  });

  final double size;
  final Color? color;
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? context.tenkai.foreground;
    return SvgPicture.asset(
      solid ? 'assets/logo/logo-mark-solid.svg' : 'assets/logo/logo-mark.svg',
      width: size,
      height: size,
      theme: SvgTheme(currentColor: resolved),
    );
  }
}

/// The lockup: the mark paired with the wordmark TENKAI set in Violet Sans at
/// 0.16em tracking. Vertical by default (mark over wordmark).
class TenkaiLogoLockup extends StatelessWidget {
  const TenkaiLogoLockup({
    super.key,
    this.markSize = 44,
    this.color,
    this.horizontal = false,
  });

  final double markSize;
  final Color? color;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? context.tenkai.foreground;
    final mark = TenkaiLogoMark(size: markSize, color: resolved);
    final wordmark = Text(
      'TENKAI',
      style: TextStyle(
        fontFamily: TenkaiTypography.h1.fontFamily,
        fontSize: markSize * 0.5,
        fontWeight: FontWeight.w400,
        letterSpacing: markSize * 0.5 * 0.16, // 0.16em
        color: resolved,
      ),
    );

    if (horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          mark,
          SizedBox(width: markSize * 0.32),
          wordmark,
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(height: markSize * 0.36),
        wordmark,
      ],
    );
  }
}
