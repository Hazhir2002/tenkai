import 'package:tenkai/core/database.dart';

class ProgramSessionModel extends ProgramSession {
  final List<SessionExercise>? sessionExercises;

  ProgramSessionModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.title,
    required super.programId,
    required super.hierarchy,
    this.sessionExercises,
  });

  factory ProgramSessionModel.fromProgramSession(
    ProgramSession programSession, {
    List<SessionExercise>? sessionExercises,
  }) {
    return ProgramSessionModel(
      id: programSession.id,
      createdAt: programSession.createdAt,
      updatedAt: programSession.updatedAt,
      title: programSession.title,
      programId: programSession.programId,
      hierarchy: programSession.hierarchy,
      sessionExercises: sessionExercises,
    );
  }

  @override
  ProgramSessionModel copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? title,
    bool? isActive,
    int? programId,
    int? hierarchy,
    List<SessionExercise>? sessionExercises,
  }) {
    return ProgramSessionModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      programId: programId ?? this.programId,
      hierarchy: hierarchy ?? this.hierarchy,
      sessionExercises: sessionExercises ?? this.sessionExercises,
    );
  }
}
