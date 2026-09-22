import 'package:tenkai/features/goal_tracker/enums/goal_pace.dart';
import 'package:tenkai/features/goal_tracker/enums/goal_status.dart';

/// An immutable goal as returned by the API. Progress, pacing and completion
/// are all computed server-side; the client only surfaces them.
class Goal {
  final String id;
  final String title;
  final String? description;
  final String? unit;
  final double initialValue;
  final double targetValue;
  final double currentValue;
  final GoalStatus status;

  /// `"increase"` or `"decrease"`, inferred by the server from initial→target.
  final String direction;

  /// Direction-aware progress from initial to target, `0.0`–`1.0`.
  final double percentComplete;

  /// Where the goal "should" be today on a linear schedule. Null unless both
  /// [startDate] and [endDate] are set.
  final double? expectedValue;
  final GoalPace pace;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Goal({
    required this.id,
    required this.title,
    this.description,
    this.unit,
    required this.initialValue,
    required this.targetValue,
    required this.currentValue,
    required this.status,
    required this.direction,
    required this.percentComplete,
    this.expectedValue,
    required this.pace,
    this.startDate,
    this.endDate,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isIncrease => direction != 'decrease';
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

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
    id: json['id'].toString(),
    title: json['title'] as String,
    description: json['description'] as String?,
    unit: json['unit'] as String?,
    initialValue: _toDouble(json['initial_value']),
    targetValue: _toDouble(json['target_value']),
    currentValue: _toDouble(json['current_value']),
    status: GoalStatus.fromApi(json['status'] as String?),
    direction: (json['direction'] as String?) ?? 'increase',
    percentComplete: _toDouble(json['percent_complete']),
    expectedValue: _toDoubleOrNull(json['expected_value']),
    pace: GoalPace.fromApi(json['pace'] as String?),
    startDate: _parseDate(json['start_date']),
    endDate: _parseDate(json['end_date']),
    completedAt: _parseDate(json['completed_at']),
    createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
    updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
  );

  Goal copyWith({GoalStatus? status}) => Goal(
    id: id,
    title: title,
    description: description,
    unit: unit,
    initialValue: initialValue,
    targetValue: targetValue,
    currentValue: currentValue,
    status: status ?? this.status,
    direction: direction,
    percentComplete: percentComplete,
    expectedValue: expectedValue,
    pace: pace,
    startDate: startDate,
    endDate: endDate,
    completedAt: completedAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  static double _toDouble(dynamic value) => _toDoubleOrNull(value) ?? 0.0;

  static double? _toDoubleOrNull(dynamic value) =>
      value == null ? null : (value as num).toDouble();

  static DateTime? _parseDate(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());
}
