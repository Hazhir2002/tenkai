import 'package:flutter/material.dart';
import 'package:tenkai/core/tokens/tenkai_colors.dart';
import 'package:tenkai/features/goal_tracker/enums/goal_pace.dart';

/// Shared presentation helpers for goal widgets: mapping the server's pace to
/// Tenkai colors/badges, and formatting goal values for display.

extension GoalPaceUi on GoalPace {
  Color get badgeVariant => switch (this) {
    GoalPace.ahead => Colors.greenAccent,
    GoalPace.onTrack => Colors.blueAccent,
    GoalPace.behind => Colors.yellowAccent,
    GoalPace.none => Colors.transparent,
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
