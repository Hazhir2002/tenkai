class ApiEndpoints {
  // static String baseUrl = 'https://api.h4zhir.com/';
  static String baseUrl = 'http://192.168.1.113:8000/';
  static String apiUrl = baseUrl;

  // Auth
  static String login = 'auth/login';
  static String register = 'auth/register';
  static String refresh = 'auth/refresh';
  static String logout = 'auth/logout';
  static String me = 'auth/me';

  static String searchExercises = '/exercises/search';

  static String listPrograms = '/programs';

  static final TaskEndpoints taskEndpoints = TaskEndpoints();
  static final GoalEndpoints goalEndpoints = GoalEndpoints();
}

class TaskEndpoints {
  static String baseUrl = '/tasks';
  String get getTasks => baseUrl;
  String get getTodaysTasks => '$baseUrl/today';
  String getTask(String id) => '$baseUrl/$id';
  String get createTask => baseUrl;
  String updateTask(String id) => '$baseUrl/$id';
  String deleteTask(String id) => '$baseUrl/$id';
}

class GoalEndpoints {
  static String baseUrl = '/goals';

  String get getGoals => baseUrl;
  String get createGoal => baseUrl;
  String goal(String id) => '$baseUrl/$id';

  /// GET (history) and POST (record a value) share this path.
  String logs(String id) => '$baseUrl/$id/logs';

  /// GET (list) and POST (create) share this path.
  String milestones(String id) => '$baseUrl/$id/milestones';

  /// PATCH (update) and DELETE share this path.
  String milestone(String id, String milestoneId) =>
      '$baseUrl/$id/milestones/$milestoneId';
}
