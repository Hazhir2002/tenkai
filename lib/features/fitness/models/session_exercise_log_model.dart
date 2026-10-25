import 'package:tenkai/core/database.dart';

class SessionExerciseLogModel extends SessionExerciseLog {
  final List<ExerciseSetLog>? exerciseSetLogs;

  SessionExerciseLogModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.durationSec,
    required super.programSessionLogId,
    this.exerciseSetLogs,
  });

  factory SessionExerciseLogModel.fromSessionExerciseLog(
    SessionExerciseLog programSession, {
    List<ExerciseSetLog>? exerciseSetLogs,
  }) {
    return SessionExerciseLogModel(
      id: programSession.id,
      createdAt: programSession.createdAt,
      updatedAt: programSession.updatedAt,
      durationSec: programSession.durationSec,
      programSessionLogId: programSession.programSessionLogId,
      exerciseSetLogs: exerciseSetLogs,
    );
  }

  @override
  SessionExerciseLogModel copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? durationSec,
    int? programSessionLogId,
    List<ExerciseSetLog>? exerciseSetLogs,
  }) {
    return SessionExerciseLogModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      durationSec: durationSec ?? this.durationSec,
      programSessionLogId: programSessionLogId ?? this.programSessionLogId,
      exerciseSetLogs: exerciseSetLogs ?? this.exerciseSetLogs,
    );
  }
}
