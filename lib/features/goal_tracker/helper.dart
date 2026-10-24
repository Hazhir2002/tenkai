import 'package:tenkai/features/goal_tracker/models/goal_model.dart';

GoalModel? findGoalById(List<GoalModel> goals, int id) {
  for (final g in goals) {
    if (g.id == id) return g;
    final found = findGoalById(g.subGoals, id);
    if (found != null) return found;
  }
  return null;
}
