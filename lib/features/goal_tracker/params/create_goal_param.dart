import 'package:tenkai/features/goal_tracker/params/date_json.dart';

/// Payload for `POST /goals`. Only [title], [initialValue] and [targetValue]
/// are required; the goal's direction is inferred server-side.
class CreateGoalParam {
  final String title;
  final double initialValue;
  final double targetValue;
  final String? description;
  final String? unit;
  final DateTime? startDate;
  final DateTime? endDate;

  const CreateGoalParam({
    required this.title,
    required this.initialValue,
    required this.targetValue,
    this.description,
    this.unit,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'initial_value': initialValue,
    'target_value': targetValue,
    if (description != null && description!.isNotEmpty)
      'description': description,
    if (unit != null && unit!.isNotEmpty) 'unit': unit,
    if (startDate != null) 'start_date': startDate!.toApiDate(),
    if (endDate != null) 'end_date': endDate!.toApiDate(),
  };
}
