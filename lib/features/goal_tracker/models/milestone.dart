/// A checkpoint on the way to a goal's target. [achievedAt] is set
/// automatically the first time a logged value crosses [targetValue].
class Milestone {
  final String id;
  final String goalId;
  final String? title;
  final double targetValue;
  final DateTime? achievedAt;
  final DateTime createdAt;

  const Milestone({
    required this.id,
    required this.goalId,
    this.title,
    required this.targetValue,
    this.achievedAt,
    required this.createdAt,
  });

  bool get isAchieved => achievedAt != null;

  factory Milestone.fromJson(Map<String, dynamic> json) => Milestone(
    id: json['id'].toString(),
    goalId: json['goal_id'].toString(),
    title: json['title'] as String?,
    targetValue: (json['target_value'] as num).toDouble(),
    achievedAt: json['achieved_at'] == null
        ? null
        : DateTime.tryParse(json['achieved_at'].toString()),
    createdAt:
        DateTime.tryParse(json['created_at']?.toString() ?? '') ??
        DateTime.now(),
  );
}
