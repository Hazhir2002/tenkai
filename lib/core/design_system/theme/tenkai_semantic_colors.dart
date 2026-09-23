import 'package:flutter/material.dart';

@immutable
class TenkaiSemanticColors extends ThemeExtension<TenkaiSemanticColors> {
  const TenkaiSemanticColors({
    required this.background,
    required this.foreground,
    required this.card,
    required this.cardForeground,
    required this.popover,
    required this.popoverForeground,
    required this.primary,
    required this.primaryForeground,
    required this.secondary,
    required this.secondaryForeground,
    required this.muted,
    required this.mutedForeground,
    required this.accent,
    required this.accentForeground,
    required this.destructive,
    required this.border,
    required this.input,
    required this.ring,
    required this.chart1,
    required this.chart2,
    required this.chart3,
    required this.chart4,
    required this.chart5,
    required this.sidebar,
    required this.sidebarForeground,
    required this.sidebarPrimary,
    required this.sidebarPrimaryForeground,
    required this.sidebarAccent,
    required this.sidebarAccentForeground,
    required this.sidebarBorder,
    required this.sidebarRing,
  });

  final Color background;
  final Color foreground;
  final Color card;
  final Color cardForeground;
  final Color popover;
  final Color popoverForeground;
  final Color primary;
  final Color primaryForeground;
  final Color secondary;
  final Color secondaryForeground;
  final Color muted;
  final Color mutedForeground;
  final Color accent;
  final Color accentForeground;
  final Color destructive;
  final Color border;
  final Color input;
  final Color ring;
  final Color chart1;
  final Color chart2;
  final Color chart3;
  final Color chart4;
  final Color chart5;
  final Color sidebar;
  final Color sidebarForeground;
  final Color sidebarPrimary;
  final Color sidebarPrimaryForeground;
  final Color sidebarAccent;
  final Color sidebarAccentForeground;
  final Color sidebarBorder;
  final Color sidebarRing;

  static const TenkaiSemanticColors dark = TenkaiSemanticColors(
    background: Color(0xFF090B0C),
    foreground: Color(0xFFF9FBFB),

    card: Color(0xFF161B1D),
    cardForeground: Color(0xFFF9FBFB),

    popover: Color(0xFF161B1D),
    popoverForeground: Color(0xFFF9FBFB),

    // Kept unchanged as requested
    primary: Color(0xFF4FA6A0),
    primaryForeground: Color(0xFFF0FDFA),

    secondary: Color(0xFF27272A),
    secondaryForeground: Color(0xFFFAFAFA),

    muted: Color(0xFF22292B),
    mutedForeground: Color(0xFF9CA8AB),

    accent: Color(0xFF22292B),
    accentForeground: Color(0xFFF9FBFB),

    destructive: Color(0xFFFF6467),

    border: Color(0x1AFFFFFF),
    input: Color(0x26FFFFFF),
    ring: Color(0xFF67787C),

    chart1: Color(0xFFD0D6D8),
    chart2: Color(0xFF67787C),
    chart3: Color(0xFF4B585B),
    chart4: Color(0xFF394447),
    chart5: Color(0xFF22292B),

    sidebar: Color(0xFF161B1D),
    sidebarForeground: Color(0xFFF9FBFB),

    sidebarPrimary: Color(0xFF00BBA7),
    sidebarPrimaryForeground: Color(0xFF022F2E),

    sidebarAccent: Color(0xFF22292B),
    sidebarAccentForeground: Color(0xFFF9FBFB),

    sidebarBorder: Color(0x1AFFFFFF),
    sidebarRing: Color(0xFF67787C),
  );

  static const TenkaiSemanticColors light = TenkaiSemanticColors(
    background: Color(0xFFFFFFFF),
    foreground: Color(0xFF0A0A0A),
    card: Color(0xFFFFFFFF),
    cardForeground: Color(0xFF0A0A0A),
    popover: Color(0xFFFFFFFF),
    popoverForeground: Color(0xFF0A0A0A),
    primary: Color(0xFFCCCCFF),
    primaryForeground: Color(0xFFFAFAFA),
    secondary: Color(0xFFF5F5F5),
    secondaryForeground: Color(0xFF171717),
    muted: Color(0xFFF5F5F5),
    mutedForeground: Color(0xFF737373),
    accent: Color(0xFFF5F5F5),
    accentForeground: Color(0xFF171717),
    destructive: Color(0xFFE7000B),
    border: Color(0xFFE5E5E5),
    input: Color(0xFFE5E5E5),
    ring: Color(0xFFA1A1A1),
    chart1: Color(0xFFD4D4D4),
    chart2: Color(0xFF737373),
    chart3: Color(0xFF525252),
    chart4: Color(0xFF404040),
    chart5: Color(0xFF262626),
    sidebar: Color(0xFFFAFAFA),
    sidebarForeground: Color(0xFF0A0A0A),
    sidebarPrimary: Color(0xFF171717),
    sidebarPrimaryForeground: Color(0xFFFAFAFA),
    sidebarAccent: Color(0xFFF5F5F5),
    sidebarAccentForeground: Color(0xFF171717),
    sidebarBorder: Color(0xFFE5E5E5),
    sidebarRing: Color(0xFFA1A1A1),
  );

  @override
  TenkaiSemanticColors copyWith({
    Color? background,
    Color? foreground,
    Color? card,
    Color? cardForeground,
    Color? popover,
    Color? popoverForeground,
    Color? primary,
    Color? primaryForeground,
    Color? secondary,
    Color? secondaryForeground,
    Color? muted,
    Color? mutedForeground,
    Color? accent,
    Color? accentForeground,
    Color? destructive,
    Color? border,
    Color? input,
    Color? ring,
    Color? chart1,
    Color? chart2,
    Color? chart3,
    Color? chart4,
    Color? chart5,
    Color? sidebar,
    Color? sidebarForeground,
    Color? sidebarPrimary,
    Color? sidebarPrimaryForeground,
    Color? sidebarAccent,
    Color? sidebarAccentForeground,
    Color? sidebarBorder,
    Color? sidebarRing,
  }) {
    return TenkaiSemanticColors(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      card: card ?? this.card,
      cardForeground: cardForeground ?? this.cardForeground,
      popover: popover ?? this.popover,
      popoverForeground: popoverForeground ?? this.popoverForeground,
      primary: primary ?? this.primary,
      primaryForeground: primaryForeground ?? this.primaryForeground,
      secondary: secondary ?? this.secondary,
      secondaryForeground: secondaryForeground ?? this.secondaryForeground,
      muted: muted ?? this.muted,
      mutedForeground: mutedForeground ?? this.mutedForeground,
      accent: accent ?? this.accent,
      accentForeground: accentForeground ?? this.accentForeground,
      destructive: destructive ?? this.destructive,
      border: border ?? this.border,
      input: input ?? this.input,
      ring: ring ?? this.ring,
      chart1: chart1 ?? this.chart1,
      chart2: chart2 ?? this.chart2,
      chart3: chart3 ?? this.chart3,
      chart4: chart4 ?? this.chart4,
      chart5: chart5 ?? this.chart5,
      sidebar: sidebar ?? this.sidebar,
      sidebarForeground: sidebarForeground ?? this.sidebarForeground,
      sidebarPrimary: sidebarPrimary ?? this.sidebarPrimary,
      sidebarPrimaryForeground:
          sidebarPrimaryForeground ?? this.sidebarPrimaryForeground,
      sidebarAccent: sidebarAccent ?? this.sidebarAccent,
      sidebarAccentForeground:
          sidebarAccentForeground ?? this.sidebarAccentForeground,
      sidebarBorder: sidebarBorder ?? this.sidebarBorder,
      sidebarRing: sidebarRing ?? this.sidebarRing,
    );
  }

  @override
  TenkaiSemanticColors lerp(
    covariant ThemeExtension<TenkaiSemanticColors>? other,
    double t,
  ) {
    if (other is! TenkaiSemanticColors) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return TenkaiSemanticColors(
      background: c(background, other.background),
      foreground: c(foreground, other.foreground),
      card: c(card, other.card),
      cardForeground: c(cardForeground, other.cardForeground),
      popover: c(popover, other.popover),
      popoverForeground: c(popoverForeground, other.popoverForeground),
      primary: c(primary, other.primary),
      primaryForeground: c(primaryForeground, other.primaryForeground),
      secondary: c(secondary, other.secondary),
      secondaryForeground: c(secondaryForeground, other.secondaryForeground),
      muted: c(muted, other.muted),
      mutedForeground: c(mutedForeground, other.mutedForeground),
      accent: c(accent, other.accent),
      accentForeground: c(accentForeground, other.accentForeground),
      destructive: c(destructive, other.destructive),
      border: c(border, other.border),
      input: c(input, other.input),
      ring: c(ring, other.ring),
      chart1: c(chart1, other.chart1),
      chart2: c(chart2, other.chart2),
      chart3: c(chart3, other.chart3),
      chart4: c(chart4, other.chart4),
      chart5: c(chart5, other.chart5),
      sidebar: c(sidebar, other.sidebar),
      sidebarForeground: c(sidebarForeground, other.sidebarForeground),
      sidebarPrimary: c(sidebarPrimary, other.sidebarPrimary),
      sidebarPrimaryForeground: c(
        sidebarPrimaryForeground,
        other.sidebarPrimaryForeground,
      ),
      sidebarAccent: c(sidebarAccent, other.sidebarAccent),
      sidebarAccentForeground: c(
        sidebarAccentForeground,
        other.sidebarAccentForeground,
      ),
      sidebarBorder: c(sidebarBorder, other.sidebarBorder),
      sidebarRing: c(sidebarRing, other.sidebarRing),
    );
  }
}

/// Ergonomic access: `context.tenkai.primary`, `context.tenkai.mutedForeground`, …
extension TenkaiSemanticColorsX on BuildContext {
  TenkaiSemanticColors get tenkai =>
      Theme.of(this).extension<TenkaiSemanticColors>() ??
      TenkaiSemanticColors.dark;
}
