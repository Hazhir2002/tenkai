import 'package:tenkai/features/goal_tracker/enums/goal_status.dart';
import 'package:tenkai/features/goal_tracker/params/date_json.dart';

/// Payload for `PATCH /goals/{id}`. Every field is optional; only the non-null
/// ones are serialized. `current_value` is intentionally absent — it moves only
/// by logging values. Use [status] to archive or manually complete a goal.
class UpdateGoalParam {
  final String? title;
  final String? description;
  final String? unit;
  final double? targetValue;
  final GoalStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;

  const UpdateGoalParam({
    this.title,
    this.description,
    this.unit,
    this.targetValue,
    this.status,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (description != null) 'description': description,
    if (unit != null) 'unit': unit,
    if (targetValue != null) 'target_value': targetValue,
    if (status != null) 'status': status!.apiValue,
    if (startDate != null) 'start_date': startDate!.toApiDate(),
    if (endDate != null) 'end_date': endDate!.toApiDate(),
  };
}
