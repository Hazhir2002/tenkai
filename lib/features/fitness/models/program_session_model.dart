import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show TimeOfDay;
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
    super.dayOfWeek,
    super.timeOfDay,
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
      dayOfWeek: programSession.dayOfWeek,
      timeOfDay: programSession.timeOfDay,
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
    Value<int?> dayOfWeek = const Value.absent(),
    Value<TimeOfDay?> timeOfDay = const Value.absent(),
    List<SessionExercise>? sessionExercises,
  }) {
    return ProgramSessionModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      programId: programId ?? this.programId,
      hierarchy: hierarchy ?? this.hierarchy,
      dayOfWeek: dayOfWeek.present ? dayOfWeek.value : this.dayOfWeek,
      timeOfDay: timeOfDay.present ? timeOfDay.value : this.timeOfDay,
      sessionExercises: sessionExercises ?? this.sessionExercises,
    );
  }
}
