import 'package:flutter/material.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/features/goal_tracker/enums/goal_pace.dart';

/// Shared presentation helpers for goal widgets: mapping the server's pace to
/// Tenkai colors/badges, and formatting goal values for display.

extension GoalPaceUi on GoalPace {
  TenkaiBadgeVariant get badgeVariant => switch (this) {
    GoalPace.ahead => TenkaiBadgeVariant.success,
    GoalPace.onTrack => TenkaiBadgeVariant.active,
    GoalPace.behind => TenkaiBadgeVariant.warning,
    GoalPace.none => TenkaiBadgeVariant.neutral,
  };

  /// Chart/accent color for this pace (ahead & on-track read as "good").
  /// `none` uses a mid-gray that reads on both light and dark themes.
  Color get color => switch (this) {
    GoalPace.ahead => TenkaiColors.success,
    GoalPace.onTrack => TenkaiColors.success,
    GoalPace.behind => TenkaiColors.warning,
    GoalPace.none => TenkaiColors.gray500,
  };
}

/// Formats a goal value without a trailing `.0` (e.g. `90` not `90.0`), with an
/// optional [unit] appended.
String formatGoalValue(double value, [String? unit]) {
  final rounded = value.roundToDouble();
  final text = value == rounded
      ? rounded.toInt().toString()
      : value.toStringAsFixed(1);
  return unit == null || unit.isEmpty ? text : '$text $unit';
}
