import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_page_transition_builder.dart';
import '../tokens/tenkai_tokens.dart';

abstract final class TenkaiTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: TenkaiColors.gray950,
      colorScheme: const ColorScheme.dark(
        surface: TenkaiColors.gray900,
        onSurface: TenkaiColors.white,
        primary: TenkaiColors.white,
        onPrimary: TenkaiColors.black,
        secondary: TenkaiColors.gray400,
        onSecondary: TenkaiColors.black,
        error: TenkaiColors.error,
        onError: TenkaiColors.white,
        outline: TenkaiColors.gray700,
        surfaceContainerHighest: TenkaiColors.gray800,
      ),

      // ── App bar ──
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: TenkaiColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TenkaiTypography.h2,
        iconTheme: IconThemeData(color: TenkaiColors.gray400, size: 20),
      ),

      // ── Text ──
      textTheme: TextTheme(
        displayLarge: TenkaiTypography.d1,
        displayMedium: TenkaiTypography.d2,
        displaySmall: TenkaiTypography.d3,
        headlineLarge: TenkaiTypography.h1,
        headlineMedium: TenkaiTypography.h2,
        headlineSmall: TenkaiTypography.h3,
        bodyLarge: TenkaiTypography.body,
        bodyMedium: TenkaiTypography.body,
        bodySmall: TenkaiTypography.bodySmall,
        labelLarge: TenkaiTypography.labelLg,
        labelMedium: TenkaiTypography.labelMd,
        labelSmall: TenkaiTypography.labelSm,
      ),

      // ── Divider ──
      dividerTheme: const DividerThemeData(
        color: TenkaiColors.gray800,
        thickness: 0.5,
        space: 0,
      ),

      // ── Input ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TenkaiColors.gray900,
        hintStyle: TenkaiTypography.body.copyWith(color: TenkaiColors.gray600),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TenkaiRadius.sharp),
          borderSide: const BorderSide(color: TenkaiColors.gray700, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TenkaiRadius.sharp),
          borderSide: const BorderSide(color: TenkaiColors.gray700, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TenkaiRadius.sharp),
          borderSide: const BorderSide(color: TenkaiColors.white, width: 0.5),
        ),
      ),

      // ── Bottom sheet ──
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: TenkaiColors.gray900,
        modalBackgroundColor: TenkaiColors.gray900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ),

      // ── Slider ──
      sliderTheme: SliderThemeData(
        activeTrackColor: TenkaiColors.white,
        inactiveTrackColor: TenkaiColors.gray700,
        thumbColor: TenkaiColors.white,
        trackHeight: 1,
        overlayShape: SliderComponentShape.noOverlay,
      ),

      // ── Switch ──
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? TenkaiColors.black
              : TenkaiColors.gray500;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? TenkaiColors.white
              : TenkaiColors.gray800;
        }),
      ),

      // ── Checkbox ──
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? TenkaiColors.white
              : Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(TenkaiColors.black),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        side: const BorderSide(color: TenkaiColors.gray600, width: 0.5),
      ),

      // ── Snackbar ──
      snackBarTheme: SnackBarThemeData(
        backgroundColor: TenkaiColors.gray800,
        contentTextStyle: TenkaiTypography.body.copyWith(
          color: TenkaiColors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TenkaiRadius.sm),
          side: const BorderSide(color: TenkaiColors.gray600, width: 0.5),
        ),
        behavior: SnackBarBehavior.floating,
      ),

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
