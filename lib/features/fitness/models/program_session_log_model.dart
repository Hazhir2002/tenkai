import 'package:tenkai/core/database.dart';
import 'package:tenkai/features/fitness/models/session_exercise_log_model.dart';

class ProgramSessionLogModel extends SessionLog {
  final List<SessionExerciseLogModel>? sessionExerciseLogs;

  ProgramSessionLogModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.sessionDuration,
    required super.programSessionId,
    this.sessionExerciseLogs,
  });

  factory ProgramSessionLogModel.fromProgram(
    SessionLog sessionLog, {
    List<SessionExerciseLogModel>? sessionExerciseLogs,
  }) {
    return ProgramSessionLogModel(
      id: sessionLog.id,
      createdAt: sessionLog.createdAt,
      updatedAt: sessionLog.updatedAt,
      sessionDuration: sessionLog.sessionDuration,
      programSessionId: sessionLog.programSessionId,
      sessionExerciseLogs: sessionExerciseLogs,
    );
  }

  @override
  ProgramSessionLogModel copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? sessionDuration,
    int? programSessionId,
    List<SessionExerciseLogModel>? sessionExerciseLogs,
  }) {
    return ProgramSessionLogModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sessionDuration: sessionDuration ?? this.sessionDuration,
      programSessionId: programSessionId ?? this.programSessionId,
      sessionExerciseLogs: sessionExerciseLogs ?? this.sessionExerciseLogs,
    );
  }
}
