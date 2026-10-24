import 'package:tenkai/features/goal_tracker/models/goal_model.dart';

/// The lifecycle state of a goal, mirrored from the API's PascalCase status.
///
/// Each value knows how to (de)serialize itself ([apiValue]) and how to present
/// itself ([label] + [symbol]), so callers never hard-code status strings.
enum GoalStatus {
  active('Active', 'Active', 'circle'),
  completed('Completed', 'Completed', 'checkmark.circle.fill'),
  archived('Archived', 'Archived', 'archivebox');

  const GoalStatus(this.apiValue, this.label, this.symbol);

  /// Wire value exchanged with the backend.
  final String apiValue;

  /// Human-readable label shown in the UI.
  final String label;

  /// SF Symbol used to represent the status.
  final String symbol;

  /// Parses the wire value, defaulting to [active] for unknown/missing values
  /// so a bad payload never crashes the list.
  static GoalStatus fromApi(String? value) => values.firstWhere(
    (status) => status.apiValue == value,
    orElse: () => GoalStatus.active,
  );
}
