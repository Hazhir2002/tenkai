import 'package:flutter/material.dart';
import '../theme/tenkai_semantic_colors.dart';
import '../sounds/tenkai_sound.dart';
import '../tokens/tenkai_tokens.dart';
import 'tenkai_motion.dart';

// ─────────────────────────────────────────────
// TENKAI · Forms (flat) — Select, SearchInput, Textarea
// Focus promotes the border to --accent and shows the focus-ring bloom.
// ─────────────────────────────────────────────

// ── SELECT ───────────────────────────────────

/// A flat dropdown select. Renders each option via [labelBuilder] (defaults to
/// `toString`). The panel unfolds below the field and dismisses on outside tap.
class TenkaiSelect<T> extends StatefulWidget {
  const TenkaiSelect({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.label,
    this.placeholder = 'Select…',
    this.enabled = true,
    this.labelBuilder,
  });

  final List<T> options;
  final T? value;
  final ValueChanged<T> onChanged;
  final String? label;
  final String placeholder;
  final bool enabled;
  final String Function(T)? labelBuilder;

  @override
  State<TenkaiSelect<T>> createState() => _TenkaiSelectState<T>();
}

class _TenkaiSelectState<T> extends State<TenkaiSelect<T>> {
  final _link = LayerLink();
  final _controller = OverlayPortalController();
  final _fieldKey = GlobalKey();
  bool _open = false;

  String _text(T v) => widget.labelBuilder?.call(v) ?? v.toString();

  void _toggle() {
    if (!widget.enabled) return;
    setState(() => _open = !_open);
    _open ? _controller.show() : _controller.hide();
    TenkaiSound.tap();
  }

  void _close() {
    if (!_open) return;
    setState(() => _open = false);
    _controller.hide();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TenkaiTypography.labelMd.copyWith(color: c.mutedForeground),
          ),
          const SizedBox(height: 7),
        ],
        CompositedTransformTarget(
          link: _link,
          child: OverlayPortal(
            controller: _controller,
            overlayChildBuilder: (context) => _buildOverlay(context, c),
            child: _buildField(context, c),
          ),
        ),
      ],
    );
  }

  Widget _buildField(BuildContext context, TenkaiSemanticColors c) {
    return GestureDetector(
      onTap: _toggle,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        key: _fieldKey,
        duration: TenkaiDuration.medium,
        curve: TenkaiCurves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(TenkaiRadius.control),
          border: Border.all(color: _open ? c.accent : c.border, width: 1),
          boxShadow: _open ? TenkaiGlow.focusOf(c.accent) : null,
        ),
        child: Opacity(
          opacity: widget.enabled ? 1.0 : 0.5,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.value != null
                      ? _text(widget.value as T)
                      : widget.placeholder,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TenkaiTypography.bodyMd.copyWith(
                    color: widget.value != null
                        ? c.foreground
                        : c.secondaryForeground,
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
    );
  }

  Widget _buildOverlay(BuildContext context, TenkaiSemanticColors c) {
    return Stack(
      children: [
        // Outside-tap barrier.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _close,
          ),
        ),
        CompositedTransformFollower(
          link: _link,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 4),
          child: Align(
            alignment: Alignment.topLeft,
            child: TenkaiUnfold(
              duration: TenkaiDuration.medium,
              child: _OverlayPanel(
                width:
                    (_fieldKey.currentContext?.findRenderObject() as RenderBox?)
                        ?.size
                        .width,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: c.card,
                      borderRadius: BorderRadius.circular(TenkaiRadius.control),
                      border: Border.all(color: c.border, width: 1),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final o in widget.options) _option(context, c, o),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _option(BuildContext context, TenkaiSemanticColors c, T o) {
    final selected = o == widget.value;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        widget.onChanged(o);
        TenkaiSound.tap();
        _close();
      },
      child: Container(
        width: double.infinity,
        color: selected ? c.card : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Text(
          _text(o),
          style: TenkaiTypography.bodyMd.copyWith(
            color: selected ? c.foreground : c.mutedForeground,
          ),
        ),
      ),
    );
  }
}

/// Constrains the overlay panel to the field's width.
class _OverlayPanel extends StatelessWidget {
  const _OverlayPanel({required this.child, this.width});
  final Widget child;
  final double? width;

  @override
  Widget build(BuildContext context) {
    if (width == null) return child;
    return SizedBox(width: width, child: child);
  }
}

// ── SEARCH INPUT ─────────────────────────────

/// A search field on a muted surface with a leading magnifier and a clear
/// button that appears once there's text.
class TenkaiSearchInput extends StatefulWidget {
  const TenkaiSearchInput({
    super.key,
    this.controller,
    this.placeholder = 'Search',
    this.onChanged,
    this.onClear,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String placeholder;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final FocusNode? focusNode;

  @override
  State<TenkaiSearchInput> createState() => _TenkaiSearchInputState();
}

class _TenkaiSearchInputState extends State<TenkaiSearchInput> {
  late final TextEditingController _controller;
  late final bool _ownsController;
  late final FocusNode _focusNode;
  late final bool _ownsFocus;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _ownsFocus = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _controller.addListener(_onChange);
    _focusNode.addListener(() => setState(() {}));
  }

  void _onChange() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onChange);
    if (_ownsController) _controller.dispose();
    if (_ownsFocus) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;
    final focused = _focusNode.hasFocus;
    final hasText = _controller.text.isNotEmpty;

    return AnimatedContainer(
      duration: TenkaiDuration.medium,
      curve: TenkaiCurves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(TenkaiRadius.control),
        border: Border.all(color: focused ? c.accent : c.border, width: 1),
        boxShadow: focused ? TenkaiGlow.focusOf(c.accent) : null,
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 16, color: c.secondaryForeground),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              style: TenkaiTypography.bodyMd.copyWith(color: c.foreground),
              cursorColor: c.accent,
              cursorWidth: 1.8,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: widget.placeholder,
                hintStyle: TenkaiTypography.bodyMd.copyWith(
                  color: c.secondaryForeground,
                ),
              ),
            ),
          ),
          if (hasText)
            GestureDetector(
              onTap: () {
                _controller.clear();
                widget.onChanged?.call('');
                widget.onClear?.call();
                TenkaiSound.tap();
              },
              child: Icon(Icons.close, size: 15, color: c.secondaryForeground),
            ),
        ],
      ),
    );
  }
}

// ── TEXTAREA ─────────────────────────────────

/// A multi-line text field on a flat surface. Focus promotes the border to
/// accent and shows the focus bloom; optional live character counter.
class TenkaiTextarea extends StatefulWidget {
  const TenkaiTextarea({
    super.key,
    this.controller,
    this.label,
    this.placeholder,
    this.onChanged,
    this.rows = 4,
    this.enabled = true,
    this.maxLength,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? label;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final int rows;
  final bool enabled;
  final int? maxLength;
  final FocusNode? focusNode;

  @override
  State<TenkaiTextarea> createState() => _TenkaiTextareaState();
}

class _TenkaiTextareaState extends State<TenkaiTextarea> {
  late final TextEditingController _controller;
  late final bool _ownsController;
  late final FocusNode _focusNode;
  late final bool _ownsFocus;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _ownsFocus = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
    if (widget.maxLength != null) _controller.addListener(_onChange);
    _focusNode.addListener(() => setState(() {}));
  }

  void _onChange() => setState(() {});

  @override
  void dispose() {
    if (widget.maxLength != null) _controller.removeListener(_onChange);
    if (_ownsController) _controller.dispose();
    if (_ownsFocus) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;
    final focused = _focusNode.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TenkaiTypography.labelMd.copyWith(color: c.mutedForeground),
          ),
          const SizedBox(height: 7),
        ],
        Opacity(
          opacity: widget.enabled ? 1.0 : 0.5,
          child: AnimatedContainer(
            duration: TenkaiDuration.medium,
            curve: TenkaiCurves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(TenkaiRadius.control),
              border: Border.all(
                color: focused ? c.accent : c.border,
                width: 1,
              ),
              boxShadow: focused ? TenkaiGlow.focusOf(c.accent) : null,
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              onChanged: widget.onChanged,
              minLines: widget.rows,
              maxLines: null,
              maxLength: widget.maxLength,
              style: TenkaiTypography.bodyMd.copyWith(
                color: c.foreground,
                height: 1.6,
              ),
              cursorColor: c.accent,
              cursorWidth: 1.8,
              buildCounter:
                  (
                    _, {
                    required currentLength,
                    required isFocused,
                    maxLength,
                  }) => null,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: widget.placeholder,
                hintStyle: TenkaiTypography.bodyMd.copyWith(
                  color: c.secondaryForeground,
                ),
              ),
            ),
          ),
        ),
        if (widget.maxLength != null) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_controller.text.length}/${widget.maxLength}',
              style: TenkaiTypography.labelSm.copyWith(
                letterSpacing: 0,
                color: c.secondaryForeground,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
