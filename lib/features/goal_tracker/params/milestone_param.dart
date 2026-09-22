/// Payload for creating or updating a milestone. [title] is optional; both
/// fields are sent on update (matching the API's create shape).
class MilestoneParam {
  final String? title;
  final double targetValue;

  const MilestoneParam({this.title, required this.targetValue});

  Map<String, dynamic> toJson() => {
    if (title != null && title!.isNotEmpty) 'title': title,
    'target_value': targetValue,
  };
}
