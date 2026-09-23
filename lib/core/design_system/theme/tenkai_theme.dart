import 'package:flutter/material.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_page_transition_builder.dart';
import '../tokens/tenkai_tokens.dart';
import 'tenkai_semantic_colors.dart';

/// The Tenkai theme. Dark is the shipped default; [light] is a supported scope
/// built from the same flat spec. Both are flat — 1px hairline borders, muted
/// fills, no shadows, no blur, no glass. Glow lives in components (focus ring +
/// primary action), never in the base theme.
abstract final class TenkaiTheme {
  static ThemeData get dark =>
      _build(brightness: Brightness.dark, c: TenkaiSemanticColors.dark);

  static ThemeData get light =>
      _build(brightness: Brightness.light, c: TenkaiSemanticColors.light);

  static ThemeData _build({
    required Brightness brightness,
    required TenkaiSemanticColors c,
  }) {
    final textColor = c.foreground;
    return ThemeData(
      useMaterial3: false,
      brightness: brightness,
      scaffoldBackgroundColor: c.background,
      extensions: [c],
      primaryColor: c.primary,

      cardTheme: CardThemeData(
        color: c.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: c.border),
          borderRadius: BorderRadius.circular(TenkaiRadius.md),
        ),
      ),

      // ── App bar ──
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: c.foreground,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TenkaiTypography.h2.copyWith(color: c.foreground),
        iconTheme: IconThemeData(color: c.mutedForeground, size: 20),
      ),

      // ── Text ──
      textTheme: TextTheme(
        displayLarge: TenkaiTypography.d1.copyWith(color: textColor),
        displayMedium: TenkaiTypography.d2.copyWith(color: textColor),
        displaySmall: TenkaiTypography.d3.copyWith(color: textColor),
        headlineLarge: TenkaiTypography.h1.copyWith(color: textColor),
        headlineMedium: TenkaiTypography.h2.copyWith(color: textColor),
        headlineSmall: TenkaiTypography.h3.copyWith(color: textColor),
        titleLarge: TenkaiTypography.titleLg.copyWith(color: textColor),
        titleMedium: TenkaiTypography.titleMd.copyWith(color: textColor),
        titleSmall: TenkaiTypography.titleSm.copyWith(color: textColor),
        bodyLarge: TenkaiTypography.bodyLg.copyWith(color: c.mutedForeground),
        bodyMedium: TenkaiTypography.bodyMd.copyWith(color: c.mutedForeground),
        bodySmall: TenkaiTypography.bodySmall.copyWith(
          color: c.mutedForeground,
        ),
        labelLarge: TenkaiTypography.labelLg.copyWith(color: c.mutedForeground),
        labelMedium: TenkaiTypography.labelMd.copyWith(
          color: c.mutedForeground,
        ),
        labelSmall: TenkaiTypography.labelSm.copyWith(color: c.mutedForeground),
      ),

      // ── Divider (hairline) ──
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 0),

      inputDecorationTheme: InputDecorationThemeData(
        filled: false,
        hintStyle: TenkaiTypography.bodyLg.copyWith(color: c.mutedForeground),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        floatingLabelAlignment: FloatingLabelAlignment.start,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: TenkaiSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TenkaiRadius.control),
          borderSide: BorderSide(color: c.input, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TenkaiRadius.control),
          borderSide: BorderSide(color: c.input, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TenkaiRadius.control),
          borderSide: BorderSide(color: c.input, width: 1),
        ),
        outlineBorder: BorderSide(),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TenkaiRadius.control),
          borderSide: BorderSide(color: c.destructive, width: 1),
        ),
      ),

      // ── Bottom sheet (flat) ──
      bottomSheetTheme: BottomSheetThemeData(
        // backgroundColor: c.surface,
        // modalBackgroundColor: c.surface,
        elevation: 0,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(TenkaiRadius.sheet),
          ),
          side: BorderSide(color: c.border, width: 1),
        ),
      ),

      // ── Slider (thin track, accent thumb) ──
      sliderTheme: SliderThemeData(
        activeTrackColor: c.accent,
        inactiveTrackColor: c.border,
        thumbColor: c.accent,
        trackHeight: 1,
        overlayShape: SliderComponentShape.noOverlay,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: TenkaiColors.white,
        side: BorderSide(color: TenkaiColors.zinc200),
        // shape:
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(),

      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          animationDuration: TenkaiDuration.medium,
          enableFeedback: true,
          textStyle: WidgetStatePropertyAll(TenkaiTypography.labelLg),
          backgroundColor: WidgetStateProperty.fromMap({
            // WidgetState.pressed: Colors.white,
            WidgetState.any: c.primary,
          }),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TenkaiRadius.md),
            ),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          animationDuration: TenkaiDuration.medium,
          enableFeedback: true,
          backgroundColor: WidgetStateProperty.fromMap({
            // WidgetState.pressed: c.primary,
            WidgetState.any: Colors.transparent,
          }),
          foregroundColor: WidgetStateProperty.fromMap({
            WidgetState.any: c.foreground,
          }),
          textStyle: WidgetStatePropertyAll(TenkaiTypography.labelLg),
          side: WidgetStateProperty.fromMap({
            WidgetState.disabled: BorderSide(
              color: c.border.withValues(alpha: 0.4),
              width: 1,
            ),
            WidgetState.pressed: BorderSide(color: c.border, width: 2),
            WidgetState.any: BorderSide(color: c.border, width: 1),
          }),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TenkaiRadius.md),
            ),
          ),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        height: 60,
        backgroundColor: c.card,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        overlayColor: WidgetStatePropertyAll(Colors.transparent),
        indicatorColor: Colors.transparent,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TenkaiRadius.pill),
        ),
      ),

      // ── Switch ──
      // switchTheme: SwitchThemeData(
      //   thumbColor: WidgetStateProperty.resolveWith((states) {
      //     return states.contains(WidgetState.selected)
      //         ? c.accentFg
      //         : c.fgSubtle;
      //   }),
      //   trackColor: WidgetStateProperty.resolveWith((states) {
      //     return states.contains(WidgetState.selected)
      //         ? c.accent
      //         : c.surfaceMuted;
      //   }),
      // ),

      // // ── Checkbox ──
      // checkboxTheme: CheckboxThemeData(
      //   fillColor: WidgetStateProperty.resolveWith((states) {
      //     return states.contains(WidgetState.selected)
      //         ? c.accent
      //         : Colors.transparent;
      //   }),
      //   checkColor: WidgetStateProperty.all(c.accentFg),
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(TenkaiRadius.check),
      //   ),
      //   side: BorderSide(color: c.borderStrong, width: 1),
      // ),

      // // ── Snackbar (flat, hairline) ──
      // snackBarTheme: SnackBarThemeData(
      //   backgroundColor: c.surfaceMuted,
      //   contentTextStyle: TenkaiTypography.bodyMd.copyWith(color: c.fg),
      //   elevation: 0,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(TenkaiRadius.card),
      //     side: BorderSide(color: c.border, width: 1),
      //   ),
      //   behavior: SnackBarBehavior.floating,
      // ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: TenkaiPageTransitionBuilder(),
          TargetPlatform.iOS: TenkaiPageTransitionBuilder(),
          TargetPlatform.macOS: TenkaiPageTransitionBuilder(),
          TargetPlatform.windows: TenkaiPageTransitionBuilder(),
          TargetPlatform.linux: TenkaiPageTransitionBuilder(),
        },
      ),
    );
  }
}
