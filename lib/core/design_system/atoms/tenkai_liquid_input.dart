import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/material.dart';

import '../sounds/tenkai_sound.dart';
import '../tokens/tenkai_tokens.dart';
import 'native_glass.dart';
import 'tenkai_glow.dart';

/// A text input rendered on a native Liquid Glass capsule (`NativeGlass`) with
/// the Tenkai focus glow + sound. `cupertino_native_better` ships no text
/// field, so this is our own — structured like `TenkaiInput` but on glass.
///
/// It's a single static surface, so it's safe to use `NativeGlass` here; do
/// NOT place it inside a scrolling list (per `NativeGlass` guidance).
class TenkaiLiquidInput extends StatefulWidget {
  const TenkaiLiquidInput({
    super.key,
    this.controller,
    this.placeholder,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.prefix,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.autofocus = false,
    this.obscureText = false,
  });

  final TextEditingController? controller;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final Widget? prefix;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final bool obscureText;

  @override
  State<TenkaiLiquidInput> createState() => _TenkaiLiquidInputState();
}

class _TenkaiLiquidInputState extends State<TenkaiLiquidInput> {
  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;

  @override
  void initState() {
    super.initState();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) TenkaiSound.tap(); // `focus` asset is unwired
    setState(() {}); // drive the glow
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TenkaiGlowWrapper(
      glowing: _focusNode.hasFocus,
      intensity: TenkaiGlowIntensity.soft,
      borderRadius: TenkaiRadius.pill,
      borderColor: Colors.transparent,
      child: NativeGlass(
        shape: CNGlassEffectShape.capsule,
        cornerRadius: TenkaiRadius.pill,
        interactive: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: Row(
          children: [
            if (widget.prefix != null) ...[
              widget.prefix!,
              const SizedBox(width: 10),
            ],
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                autofocus: widget.autofocus,
                obscureText: widget.obscureText,
                style: TenkaiTypography.bodyMd,
                cursorColor: TenkaiColors.white,
                cursorWidth: 1.8,
                cursorHeight: 20,
                cursorRadius: Radius.circular(TenkaiRadius.md),
                cursorOpacityAnimates: true,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  hintText: widget.placeholder,
                  hintStyle: TenkaiTypography.bodyMd.copyWith(
                    color: TenkaiColors.gray600,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
            if (widget.suffix != null) ...[
              const SizedBox(width: 10),
              widget.suffix!,
            ],
          ],
        ),
      ),
    );
  }
}
