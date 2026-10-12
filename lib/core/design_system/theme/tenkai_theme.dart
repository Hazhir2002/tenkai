import 'package:flutter/material.dart';
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
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: c.primary,
        onPrimary: c.foreground,
        secondary: c.secondary,
        onSecondary: c.secondaryForeground,
        secondaryContainer: c.muted,
        error: c.destructive,
        errorContainer: Color(0x14FF4444),
        onError: c.foreground,
        surface: c.background,
        onSurface: c.foreground,
        surfaceContainer: c.card,
      ),

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
        isDense: true,
        hintStyle: TenkaiTypography.bodyMd.copyWith(color: c.mutedForeground),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        floatingLabelAlignment: FloatingLabelAlignment.start,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: TenkaiSpacing.md,
          vertical: TenkaiSpacing.sm,
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
        suffixIconConstraints: BoxConstraints(maxWidth: 45, maxHeight: 45),
      ),

      // ── Bottom sheet (flat) ──
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.background,
        modalBackgroundColor: c.background,
        showDragHandle: true,
        dragHandleColor: c.muted,
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
        showCheckmark: false,
        labelStyle: TenkaiTypography.labelSm.copyWith(
          color: c.primaryForeground,
        ),
        secondaryLabelStyle: TenkaiTypography.labelSm.copyWith(
          color: c.primaryForeground,
        ),
        labelPadding: EdgeInsets.symmetric(
          horizontal: TenkaiSpacing.xs,
          vertical: 0,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: TenkaiSpacing.xs,
          vertical: 0,
        ),
        backgroundColor: c.background,
        selectedColor: c.primary,
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.circular(TenkaiRadius.sm),
        ),
        color: WidgetStateProperty<Color>.fromMap({
          WidgetState.any: Colors.red,
        }),
        side: BorderSide(color: c.input, width: 1),
        // shape:
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(),

      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(c.foreground),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          animationDuration: TenkaiDuration.medium,
          enableFeedback: true,
          textStyle: WidgetStatePropertyAll(TenkaiTypography.labelLg),
          backgroundColor: WidgetStateProperty.fromMap({
            WidgetState.disabled: c.muted,
            // WidgetState.pressed: Colors.white,
            // WidgetState.any: c.primary,
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

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.primary,
        strokeCap: StrokeCap.round,
        borderRadius: BorderRadius.circular(TenkaiRadius.pill),
        linearTrackColor: c.border,
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.fromMap({
          WidgetState.selected: c.primary,
        }),
        splashRadius: TenkaiRadius.md,
        side: BorderSide(color: c.input),
        visualDensity: VisualDensity.compact,
      ),
      listTileTheme: ListTileThemeData(
        horizontalTitleGap: TenkaiSpacing.sm,
        dense: true,
        enableFeedback: true,
        contentPadding: EdgeInsets.symmetric(
          vertical: TenkaiSpacing.xs,
          horizontal: TenkaiSpacing.md,
        ),
        titleTextStyle: TenkaiTypography.labelLg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TenkaiRadius.md),
        ),
      ),

      switchTheme: SwitchThemeData(
        trackColor: WidgetStateColor.fromMap({
          WidgetState.selected: c.primaryForeground,
          WidgetState.any: c.muted,
        }),
        thumbColor: WidgetStateColor.fromMap({
          WidgetState.selected: c.primary,
          WidgetState.any: c.mutedForeground,
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateColor.fromMap({WidgetState.any: c.primary}),
        fillColor: WidgetStateColor.fromMap({WidgetState.any: c.muted}),
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.circular(TenkaiRadius.check),
        ),
        visualDensity: VisualDensity.compact,
        side: BorderSide.none,
      ),

      menuTheme: MenuThemeData(
        style: MenuStyle(backgroundColor: WidgetStatePropertyAll(Colors.red)),
      ),

      menuButtonTheme: MenuButtonThemeData(
        style: ButtonStyle(
          animationDuration: TenkaiDuration.medium,
          enableFeedback: true,
          textStyle: WidgetStatePropertyAll(TenkaiTypography.labelLg),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TenkaiRadius.md),
            ),
          ),
        ),
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(c.card),
          visualDensity: VisualDensity.compact,
          padding: WidgetStatePropertyAll(EdgeInsets.all(TenkaiSpacing.xs)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TenkaiRadius.md),
            ),
          ),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.card,
        behavior: SnackBarBehavior.floating,
        contentTextStyle: TenkaiTypography.bodyMd.copyWith(color: c.foreground),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: c.border),
          borderRadius: BorderRadius.circular(TenkaiRadius.md),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: c.card,
        titleTextStyle: TenkaiTypography.titleMd,
        contentTextStyle: TenkaiTypography.bodyMd,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TenkaiRadius.md),
        ),
      ),
    );
  }
}
