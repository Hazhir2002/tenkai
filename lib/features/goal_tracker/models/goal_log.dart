/// A single recorded value in a goal's history, ready for time-series charting.
class GoalLog {
  final String id;
  final String goalId;
  final double value;
  final String? note;
  final DateTime loggedAt;

  const GoalLog({
    required this.id,
    required this.goalId,
    required this.value,
    this.note,
    required this.loggedAt,
  });

  factory GoalLog.fromJson(Map<String, dynamic> json) => GoalLog(
    id: json['id'].toString(),
    goalId: json['goal_id'].toString(),
    value: (json['value'] as num).toDouble(),
    note: json['note'] as String?,
    loggedAt:
        DateTime.tryParse(json['logged_at']?.toString() ?? '') ??
        DateTime.now(),
  );
}
