import 'package:drift/drift.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/features/goal_tracker/enums/goal_pace.dart';
import 'package:tenkai/features/goal_tracker/enums/goal_status.dart';

/// An immutable goal as returned by the API. Progress, pacing and completion
/// are all computed server-side; the client only surfaces them.

enum GoalDirection {
  increase('increase', 'Increase'),
  decrease('decrease', 'Decrease');

  const GoalDirection(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static GoalDirection fromDb(String? value) => values.firstWhere(
    (pace) => pace.dbValue == value,
    orElse: () => GoalDirection.increase,
  );
}

class GoalModel extends Goal {
  final List<GoalLog> goalLogs;
  final GoalStatus status;
  final GoalDirection direction;
  final double percentComplete;
  final double? expectedValue;
  final GoalPace pace;

  bool get isIncrease => direction != GoalDirection.decrease;
  bool get isCompleted => status == GoalStatus.completed;

  /// Whether the server computed a linear schedule (start + end dates set).
  bool get hasPacing => expectedValue != null && pace.isTracked;

  /// Progress clamped to a safe `0.0`–`1.0` for progress bars.
  double get progress => percentComplete.clamp(0.0, 1.0);

  /// Whole days left until [endDate], or null when there's no deadline.
  /// Negative once the deadline has passed.
  int? get daysRemaining {
    final end = endDate;
    if (end == null) return null;
    final today = DateTime.now();
    final endDay = DateTime(end.year, end.month, end.day);
    final startDay = DateTime(today.year, today.month, today.day);
    return endDay.difference(startDay).inDays;
  }

  const GoalModel({
    required super.id,
    required super.title,
    super.description,
    super.unit,
    required super.initialValue,
    required super.currentValue,
    required super.targetValue,
    this.expectedValue,
    required this.status,
    required this.direction,
    required this.percentComplete,
    required this.pace,
    super.startDate,
    super.endDate,
    super.completedAt,
    super.parentGoalId,
    super.goalValueOnParentGoal,
    required super.createdAt,
    required super.updatedAt,
    this.goalLogs = const [],
  });

  factory GoalModel.fromGoal(Goal goal, {List<GoalLog> goalLogs = const []}) {
    return GoalModel(
      id: goal.id,
      title: goal.title,
      description: goal.description,
      unit: goal.unit,
      initialValue: goal.initialValue,
      currentValue: goal.currentValue,
      targetValue: goal.targetValue,
      startDate: goal.startDate,
      endDate: goal.endDate,
      completedAt: goal.completedAt,
      parentGoalId: goal.parentGoalId,
      goalValueOnParentGoal: goal.goalValueOnParentGoal,
      createdAt: goal.createdAt,
      updatedAt: goal.updatedAt,
      status: GoalStatus.active,
      direction: GoalDirection.increase,
      percentComplete: 0,
      pace: GoalPace.onTrack,
    );
  }

  @override
  GoalModel copyWith({
    int? id,
    String? title,
    Value<String?> description = const Value.absent(),
    Value<String?> unit = const Value.absent(),
    double? initialValue,
    double? currentValue,
    Value<double?> targetValue = const Value.absent(),
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
    Value<int?> parentGoalId = const Value.absent(),
    Value<double?> goalValueOnParentGoal = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    List<GoalLog>? goalLogs,
  }) => GoalModel(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.value ?? this.description,
    unit: unit.value ?? this.unit,
    initialValue: initialValue ?? this.initialValue,
    currentValue: currentValue ?? this.currentValue,
    targetValue: targetValue.value ?? this.targetValue,
    startDate: startDate.value ?? this.startDate,
    endDate: endDate.value ?? this.endDate,
    completedAt: completedAt.value ?? this.completedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    goalLogs: goalLogs ?? this.goalLogs,
    status: status ?? this.status,
    direction: direction,
    percentComplete: percentComplete,
    expectedValue: expectedValue,
    pace: pace,
  );

  static double _toDouble(dynamic value) => _toDoubleOrNull(value) ?? 0.0;

  static double? _toDoubleOrNull(dynamic value) =>
      value == null ? null : (value as num).toDouble();

  static DateTime? _parseDate(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());
}
