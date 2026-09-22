/// The lifecycle bucket a [Task] lives in (a lightweight GTD model).
///
/// Each value knows how to (de)serialize itself for the API ([apiValue]) and
/// how to present itself in the UI ([label] + [symbol]), so callers never
/// hard-code status strings or switch on the enum for display concerns.
enum TaskStatus {
  active('Active', 'Active', 'circle'),
  waitingOn('WaitingOn', 'Waiting On', 'clock'),
  someday('Someday', 'Someday', 'moon.stars'),
  done('Done', 'Done', 'checkmark.circle.fill');

  const TaskStatus(this.apiValue, this.label, this.symbol);

  /// Wire value exchanged with the backend.
  final String apiValue;

  /// Human-readable label shown in the UI.
  final String label;

  /// SF Symbol used to represent the status.
  final String symbol;

  /// Parses the wire value into a [TaskStatus], defaulting to [active] for
  /// unknown/missing values so a bad payload never crashes the list.
  static TaskStatus fromApi(String? value) => values.firstWhere(
    (status) => status.apiValue == value,
    orElse: () => TaskStatus.active,
  );
}
