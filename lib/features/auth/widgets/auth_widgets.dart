import 'package:flutter/material.dart';
import 'package:tenkai/core/design_system/tenkai.dart';

// Shared auth UI, in the flat Tenkai language — hairline surfaces, the semantic
// color layer, no gradients or drop shadows. (Login/Register use the design-
// system widgets directly; these wrappers serve the verify/forgot/reset flow.)

// ─── Primary button (full width) ───────────────────────────────────────────

/// A full-width primary action. Kept named `GradientButton` for its call sites,
/// but it is now a flat [TenkaiButton] — no gradient, no shadow.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TenkaiButton(
        label: label,
        loading: isLoading,
        enabled: onPressed != null,
        size: TenkaiButtonSize.lg,
        icon: icon != null
            ? Icon(icon, size: 18, color: context.tenkai.accentForeground)
            : null,
        onPressed: onPressed,
      ),
    );
  }
}

// ─── Auth text field ────────────────────────────────────────────────────────

/// A validated text field for the auth forms (a [TextFormField] so it can plug
/// into a [Form]). Styling comes from the flat, theme-aware
/// `inputDecorationTheme`, so it themes automatically.
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
    this.autofillHints,
    this.focusNode,
  });

  final String label;
  final String? hint;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: widget.isPassword && _obscure,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      autofillHints: widget.autofillHints,
      style: TenkaiTypography.bodyMd.copyWith(color: c.foreground),
      cursorColor: c.accent,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        labelStyle: TenkaiTypography.bodyMd.copyWith(color: c.mutedForeground),
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, size: 20, color: c.secondaryForeground)
            : null,
        suffixIcon: widget.isPassword
            ? GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: c.secondaryForeground,
                ),
              )
            : null,
      ),
    );
  }
}

// ─── Status banners (flat) ──────────────────────────────────────────────────

class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return TenkaiBanner(title: message, variant: TenkaiBannerVariant.error);
  }
}

class AuthSuccessBanner extends StatelessWidget {
  const AuthSuccessBanner({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return TenkaiBanner(title: message, variant: TenkaiBannerVariant.success);
  }
}

// ─── Auth header ────────────────────────────────────────────────────────────

/// The flat header for the verify/forgot/reset screens: the Tenkai mark, a
/// display-face title, and a muted subtitle. (The `emoji` parameter is retained
/// for call-site compatibility but no longer rendered — the system uses no
/// emoji; the logo mark carries the brand.)
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    this.emoji,
    required this.title,
    required this.subtitle,
  });

  final String? emoji;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.tenkai;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TenkaiLogoMark(size: 40),
        const SizedBox(height: TenkaiSpacing.lg),
        Text(title, style: TenkaiTypography.h1.copyWith(color: c.foreground)),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TenkaiTypography.bodyMd.copyWith(color: c.mutedForeground),
        ),
      ],
    );
  }
}
