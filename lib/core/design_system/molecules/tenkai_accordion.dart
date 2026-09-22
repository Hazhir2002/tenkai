import 'package:flutter/material.dart';
import '../theme/tenkai_semantic_colors.dart';
import '../sounds/tenkai_sound.dart';
import '../tokens/tenkai_tokens.dart';

/// A disclosure panel — the "unfold" motif as a component. A tappable header
/// (title + optional uppercase meta) with a chevron that rotates; the body
/// eases open beneath a hairline rule.
class TenkaiAccordion extends StatefulWidget {
  const TenkaiAccordion({
    super.key,
    required this.title,
    required this.child,
    this.meta,
    this.initiallyOpen = false,
  });

  final String title;
  final Widget child;
  final String? meta;
  final bool initiallyOpen;

  @override
  State<TenkaiAccordion> createState() => _TenkaiAccordionState();
}

class _TenkaiAccordionState extends State<TenkaiAccordion> {
  late bool _open = widget.initiallyOpen;

  void _toggle() {
    setState(() => _open = !_open);
    TenkaiSound.tap();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(TenkaiRadius.card),
        border: Border.all(color: c.border, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: TenkaiTypography.labelLg.copyWith(
                            letterSpacing: 0,
                            color: c.foreground,
                          ),
                        ),
                        if (widget.meta != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            widget.meta!.toUpperCase(),
                            style: TenkaiTypography.labelSm.copyWith(
                              letterSpacing: 1.4,
                              color: c.secondaryForeground,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: TenkaiDuration.medium,
                    curve: TenkaiCurves.spring,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: c.secondaryForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: TenkaiDuration.medium,
            curve: TenkaiCurves.spring,
            alignment: Alignment.topCenter,
            child: _open
                ? Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: c.border, width: 1),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    child: DefaultTextStyle.merge(
                      style: TenkaiTypography.bodyMd.copyWith(
                        color: c.mutedForeground,
                      ),
                      child: widget.child,
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
