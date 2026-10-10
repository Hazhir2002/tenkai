class ScheduleSlotDraft {
  const ScheduleSlotDraft({
    this.weekday,
    required this.hour,
    required this.minute,
  });

  /// 1..7 (Mon..Sun), or null for daily.
  final int? weekday;
  final int hour;
  final int minute;

  ScheduleSlotDraft copyWith({
    Object? weekday = _sentinel,
    int? hour,
    int? minute,
  }) {
    return ScheduleSlotDraft(
      weekday: weekday == _sentinel ? this.weekday : weekday as int?,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  static const _sentinel = Object();
}
