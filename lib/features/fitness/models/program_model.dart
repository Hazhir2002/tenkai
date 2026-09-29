import 'package:tenkai/core/database.dart';
import 'package:tenkai/features/fitness/models/program_session_model.dart';

class ProgramModel extends Program {
  final List<ProgramSessionModel>? programSessions;

  ProgramModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.title,
    required super.isActive,
    this.programSessions,
  });

  factory ProgramModel.fromProgram(
    Program program, {
    List<ProgramSessionModel>? programSessions,
  }) {
    return ProgramModel(
      id: program.id,
      createdAt: program.createdAt,
      updatedAt: program.updatedAt,
      title: program.title,
      isActive: program.isActive,
      programSessions: programSessions,
    );
  }

  @override
  ProgramModel copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? title,
    bool? isActive,
    List<ProgramSessionModel>? programSessions,
  }) {
    return ProgramModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      isActive: isActive ?? this.isActive,
      programSessions: programSessions ?? this.programSessions,
    );
  }
}
