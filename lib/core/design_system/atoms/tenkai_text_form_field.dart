import 'package:flutter/material.dart';
import 'package:tenkai/core/design_system/theme/tenkai_semantic_colors.dart';
import 'package:tenkai/core/design_system/tokens/tenkai_spacing.dart';
import 'package:tenkai/core/validators/required_validatory.dart';

class TenkaiTextFormField extends StatefulWidget {
  const TenkaiTextFormField({
    super.key,
    this.label,
    this.placeholder,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    this.suffix,
    this.prefix,
    this.enabled = true,
    this.maxLines = 1,
    this.autofillHints,
    this.textInputAction,
    this.focusNode,
    this.expands = false,
    this.textAlignVertical,
    this.autofocus = false,
    this.validator,
    this.isRequired = false,
    this.onSaved,
  });

  final String? label;
  final String? placeholder;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;
  final Widget? prefix;
  final bool enabled;
  final int? maxLines;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool expands;
  final TextAlignVertical? textAlignVertical;
  final bool autofocus;
  final String? Function(String?)? validator;
  final bool isRequired;
  final void Function(String?)? onSaved;

  @override
  State<TenkaiTextFormField> createState() => _TenkaiTextFormFieldState();
}

class _TenkaiTextFormFieldState extends State<TenkaiTextFormField> {
  // late final FocusNode _focusNode;
  // late final bool _ownsFocusNode;

  // @override
  // void initState() {
  //   super.initState();
  //   _ownsFocusNode = widget.focusNode == null;
  //   _focusNode = widget.focusNode ?? FocusNode();
  //   _focusNode.addListener(() => setState(() {}));
  // }

  // @override
  // void dispose() {
  //   if (_ownsFocusNode) _focusNode.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.tenkai;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: TenkaiSpacing.xs,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: widget.label!.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: c.mutedForeground,
                  ),
                ),
                if (widget.isRequired)
                  TextSpan(
                    text: ' *',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: c.mutedForeground,
                    ),
                  ),
              ],
            ),
          ),
        // The focus ring: a 1px accent border (via the TextField) plus the
        // focus-glow bloom (the one mandatory glow).
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          onChanged: widget.onChanged,
          onSaved: widget.onSaved,
          // onSubmitted: widget.onSubmitted,
          autofillHints: widget.autofillHints,
          textInputAction: widget.textInputAction,
          textAlignVertical: widget.textAlignVertical,
          autofocus: widget.autofocus,
          style: theme.textTheme.bodyLarge?.copyWith(color: c.foreground),
          expands: widget.expands,
          cursorOpacityAnimates: true,
          decoration: InputDecoration(
            hintText: widget.placeholder,
            prefixIcon: widget.prefix,
            suffixIcon: widget.suffix,
            errorStyle: theme.textTheme.labelMedium?.copyWith(
              color: c.destructive,
            ),
          ),
          validator: (value) {
            if (widget.isRequired) {
              final result = requiredValidator(value, widget.label ?? 'Field');
              if (result == null && widget.validator != null) {
                return widget.validator!(value);
              } else {
                return result;
              }
            } else {
              if (widget.validator != null) {
                return widget.validator!(value);
              }
              return null;
            }
          },
        ),
      ],
    );
  }
}
