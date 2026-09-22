/// How a goal is tracking against its linear schedule, as computed by the API.
///
/// [none] represents a goal without both a start and end date, where the server
/// omits pacing (`pace` is `null`).
enum GoalPace {
  ahead('ahead', 'Ahead'),
  onTrack('on_track', 'On track'),
  behind('behind', 'Behind'),
  none('', 'No schedule');

  const GoalPace(this.apiValue, this.label);

  /// Wire value exchanged with the backend.
  final String apiValue;

  /// Human-readable label shown in the UI.
  final String label;

  /// Whether pacing is meaningful (the goal has a start + end date).
  bool get isTracked => this != GoalPace.none;

  /// Parses the wire value, treating anything unknown/missing as [none].
  static GoalPace fromApi(String? value) => values.firstWhere(
    (pace) => pace.apiValue == value,
    orElse: () => GoalPace.none,
  );
}
