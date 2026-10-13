/// Radius scale — nothing is more rounded than 12px (except full pills).
/// Named by role so intent is explicit at call sites.
abstract final class TenkaiRadius {
  static const double check = 4; // Checkbox
  static const double badge = 6; // Badges, chips-as-tags
  static const double control = 8; // Buttons, inputs, icon tiles
  static const double tile = 8; // Icon tiles
  static const double card = 10; // Cards
  static const double sheet = 12; // Bottom sheets, dialogs
  static const double pill = 999; // Toggles / pills only

  // ── Legacy aliases (kept so existing call sites resolve; remapped so the
  //    new "nothing over 12" rule holds — do not use in new code) ──
  static const double sharp = control; // was 8
  static const double sm = card; // was 12 → 10 (cards)
  static const double md = card; // was 16 → 10
  static const double lg = sheet; // was 24 → 12
  static const double xl = sheet; // was 28 → 12
}
