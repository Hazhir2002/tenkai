/// Motion durations. Everything settles; nothing bounces.
abstract final class TenkaiDuration {
  static const instant = Duration(milliseconds: 90); // press
  static const fast = Duration(milliseconds: 150); // checkbox, hover
  static const medium = Duration(milliseconds: 260); // default state change
  static const slow = Duration(milliseconds: 420); // sheets, entries
  static const reveal = Duration(milliseconds: 560); // reveals, unfold

  /// Legacy alias — the glow activation animation. Kept for existing callers.
  static const glow = reveal;
}
