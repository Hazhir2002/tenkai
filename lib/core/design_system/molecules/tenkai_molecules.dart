import 'package:flutter/material.dart';
import '../theme/tenkai_semantic_colors.dart';
import '../tokens/tenkai_tokens.dart';

// ─────────────────────────────────────────────
// TENKAI · Molecules — Navigation & Feedback (flat)
// TenkaiTabs, TenkaiToast, TenkaiBottomSheet
// Flat hairline surfaces, no glow, no drop shadows.
// ─────────────────────────────────────────────

// ── TABS ─────────────────────────────────────

class TenkaiTabs extends StatefulWidget {
  const TenkaiTabs({
    super.key,
    required this.tabs,
    required this.initialIndex,
    required this.onChanged,
  });

  final List<String> tabs;
  final int initialIndex;
  final ValueChanged<int> onChanged;

  @override
  State<TenkaiTabs> createState() => _TenkaiTabsState();
}

class _TenkaiTabsState extends State<TenkaiTabs> {
  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.border, width: 1)),
      ),
      child: Row(
        children: List.generate(widget.tabs.length, (i) {
          final active = i == _selected;
          return GestureDetector(
            onTap: () {
              setState(() => _selected = i);
              widget.onChanged(i);
            },
            child: AnimatedContainer(
              duration: TenkaiDuration.medium,
              curve: TenkaiCurves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: active ? c.accent : Colors.transparent,
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                widget.tabs[i].toUpperCase(),
                style: TenkaiTypography.labelMd.copyWith(
                  color: active ? c.foreground : c.secondaryForeground,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── TOAST ────────────────────────────────────

enum TenkaiToastVariant { info, success, warning, error }

class TenkaiToastData {
  const TenkaiToastData({
    required this.title,
    this.message,
    this.variant = TenkaiToastVariant.info,
    this.duration = const Duration(seconds: 3),
  });

  final String title;
  final String? message;
  final TenkaiToastVariant variant;
  final Duration duration;
}

class TenkaiToastOverlay extends StatefulWidget {
  const TenkaiToastOverlay({super.key, required this.data});
  final TenkaiToastData data;

  @override
  State<TenkaiToastOverlay> createState() => _TenkaiToastOverlayState();
}

class _TenkaiToastOverlayState extends State<TenkaiToastOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: TenkaiDuration.medium);
    _anim = CurvedAnimation(parent: _ctrl, curve: TenkaiCurves.spring);
    _ctrl.forward();

    Future.delayed(widget.data.duration, () {
      if (mounted) _ctrl.reverse();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _dotColor(TenkaiSemanticColors c) => switch (widget.data.variant) {
    TenkaiToastVariant.info => c.foreground,
    TenkaiToastVariant.success => Colors.greenAccent,
    TenkaiToastVariant.warning => Colors.yellowAccent,
    TenkaiToastVariant.error => Colors.redAccent,
  };

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, 8 * (1 - _anim.value)),
        child: Opacity(opacity: _anim.value, child: child),
      ),
      child: Container(
        constraints: const BoxConstraints(minWidth: 260, maxWidth: 340),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(TenkaiRadius.card),
          border: Border.all(color: c.border, width: 1),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(top: 6, right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _dotColor(c),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.data.title,
                    style: TenkaiTypography.h3.copyWith(color: c.foreground),
                  ),
                  if (widget.data.message != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.data.message!,
                      style: TenkaiTypography.bodySmall.copyWith(
                        color: c.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Show a toast — call from anywhere with context.
void showTenkaiToast(BuildContext context, TenkaiToastData data) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(child: TenkaiToastOverlay(data: data)),
    ),
  );
  overlay.insert(entry);
  Future.delayed(
    data.duration + const Duration(milliseconds: 400),
    entry.remove,
  );
}

// ── BOTTOM SHEET ─────────────────────────────

Future<T?> showTenkaiSheet<T>({
  required BuildContext context,
  required String title,
  required Widget child,
  bool showHandle = true,
}) async {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) =>
        _TenkaiSheet(title: title, showHandle: showHandle, child: child),
  );
}

class _TenkaiSheet extends StatelessWidget {
  const _TenkaiSheet({
    required this.title,
    required this.child,
    required this.showHandle,
  });

  final String title;
  final Widget child;
  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;
    final media = MediaQuery.of(context);
    final viewInsets = media.viewInsets.bottom; // keyboard height
    final keyboardOpen = viewInsets > 0;

    // Cap the sheet so its top never slides under the status bar. The inner
    // scroll view takes over once the content (or the keyboard) needs more room.
    final maxHeight = media.size.height - 80 - media.padding.top;

    return AnimatedPadding(
      // Lift the whole sheet above the keyboard so the form + submit button
      // stay reachable instead of being covered by it.
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: viewInsets),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Container(
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(TenkaiRadius.sheet),
            ),
            border: Border.all(color: c.border, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showHandle) ...[
                const SizedBox(height: 12),
                Container(width: 32, height: 2, color: c.border),
                const SizedBox(height: 20),
              ],
              Flexible(
                child: GestureDetector(
                  // Tap any empty space inside the sheet to drop the keyboard.
                  onTap: () => FocusScope.of(context).unfocus(),
                  behavior: HitTestBehavior.translucent,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      0,
                      24,
                      // When the keyboard is up the Done bar sits at the bottom;
                      // only pad for the home indicator while it's closed.
                      keyboardOpen ? 16 : media.padding.bottom + 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TenkaiTypography.h2.copyWith(
                            color: c.foreground,
                          ),
                        ),
                        const SizedBox(height: 20),
                        child,
                      ],
                    ),
                  ),
                ),
              ),
              // A dismiss affordance pinned above the keyboard — the only way
              // out of an iOS numeric keypad, which has no return/Done key.
              if (keyboardOpen) const _KeyboardDoneBar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeyboardDoneBar extends StatelessWidget {
  const _KeyboardDoneBar();

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.border, width: 1)),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(
              'Done',
              style: TenkaiTypography.labelMd.copyWith(color: c.foreground),
            ),
          ),
        ),
      ),
    );
  }
}
