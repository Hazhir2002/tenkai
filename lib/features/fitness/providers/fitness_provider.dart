import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/notifications/tenkai_notifications.dart';
import 'package:tenkai/core/providers.dart';
import 'package:tenkai/features/fitness/models/program_model.dart';
import 'package:tenkai/features/fitness/models/program_session_model.dart';

class FitnessState {
  final List<ProgramModel>? programs;
  final bool isLoading;
  final String? error;

  const FitnessState({this.programs, this.error, this.isLoading = false});

  FitnessState copyWith({
    List<ProgramModel>? programs,
    String? error,
    bool? isLoading,
  }) => FitnessState(
    programs: programs ?? this.programs,
    error: error ?? this.error,
    isLoading: isLoading ?? this.isLoading,
  );
}

class FitnessNotifier extends Notifier<FitnessState> {
  late AppDatabase db;

  @override
  FitnessState build() {
    db = ref.read(appDataBaseProvider);
    Future.microtask(() => listPrograms());
    return const FitnessState();
  }

  Future<void> listPrograms() async {
    state = state.copyWith(isLoading: true, error: null, programs: null);
    final result = await db.fitnessDao.getAllPrograms();
    List<ProgramModel> programModels = result
        .map((p) => ProgramModel.fromProgram(p))
        .toList();
    state = state.copyWith(
      isLoading: false,
      error: null,
      programs: programModels,
    );
  }

  Future<void> createProgram(ProgramsCompanion entry) async {
    final result = await db.fitnessDao.createProgram(entry);
    state = state.copyWith(
      programs: state.programs != null
          ? [...state.programs!, ProgramModel.fromProgram(result)]
          : [ProgramModel.fromProgram(result)],
    );
  }

  Future<void> deleteProgram(int programId) async {
    final result = await db.fitnessDao.deleteProgram(programId);
    if (result == 0) {
      state = state.copyWith(error: 'Failed to delete program session');
      return;
    }
    state = state.copyWith(
      programs: state.programs!
          .where((program) => program.id != programId)
          .toList(),
    );
  }

  Future<void> listProgramSessions(int programId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final sessions = await db.fitnessDao.getAllProgramSessions(programId);

      // Map through the list and update only the target program
      final updatedPrograms = state.programs?.map((program) {
        if (program.id == programId) {
          List<ProgramSessionModel> programSessionModels = sessions
              .map((p) => ProgramSessionModel.fromProgramSession(p))
              .toList();
          return program.copyWith(programSessions: programSessionModels);
        }
        return program;
      }).toList();

      state = state.copyWith(isLoading: false, programs: updatedPrograms);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addProgramSession(ProgramSessionsCompanion entry) async {
    final result = await db.fitnessDao.createProgramSession(entry);
    final updatedPrograms = state.programs?.map((program) {
      if (program.id == entry.programId.value) {
        return program.copyWith(
          programSessions: program.programSessions != null
              ? [
                  ...program.programSessions!,
                  ProgramSessionModel.fromProgramSession(result),
                ]
              : [ProgramSessionModel.fromProgramSession(result)],
        );
      }
      return program;
    }).toList();
    state = state.copyWith(programs: updatedPrograms);
    debugPrint(entry.dayOfWeek.value.toString());
    debugPrint(entry.timeOfDay.value.toString());
    debugPrint(
      (entry.dayOfWeek.value != null && entry.timeOfDay.value != null)
          .toString(),
    );
    if (entry.dayOfWeek.value != null && entry.timeOfDay.value != null) {
      await TenkaiNotifications.scheduleProgramSessionReminder(
        id: result.id,
        dayOfWeek: entry.dayOfWeek.value!,
        hour: entry.timeOfDay.value!.hour,
        minute: entry.timeOfDay.value!.minute,
        title: entry.title.value,
        body: 'Time to Start your session',
      );
    }
  }

  Future<void> deleteProgramSession(int programId, int programSessionId) async {
    final result = await db.fitnessDao.deleteProgramSession(programSessionId);
    if (result == 0) {
      state = state.copyWith(error: 'Failed to delete program session');
      return;
    }
    final updatedPrograms = state.programs?.map((program) {
      if (program.id == programId) {
        return program.copyWith(
          programSessions: program.programSessions!
              .where((session) => session.id != programSessionId)
              .toList(),
        );
      }
      return program;
    }).toList();
    state = state.copyWith(programs: updatedPrograms);
    await TenkaiNotifications.deleteProgramSessionReminder(
      id: programSessionId,
    );
  }

  Future<void> listSessionExercises(int programId, int programSessionId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final sessionExercises = await db.fitnessDao.getAllSessionExercises(
        programSessionId,
      );

      final updatedPrograms = state.programs?.map((program) {
        if (program.id == programId) {
          final updatedProgramSessions = program.programSessions?.map((
            programSession,
          ) {
            if (programSession.id == programSessionId) {
              return programSession.copyWith(
                sessionExercises: sessionExercises,
              );
            }
            return programSession;
          }).toList();

          return program.copyWith(programSessions: updatedProgramSessions);
        }
        return program;
      }).toList();

      state = state.copyWith(isLoading: false, programs: updatedPrograms);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addSessionExercise(
    int programId,
    SessionExercisesCompanion entry,
  ) async {
    final result = await db.fitnessDao.createSessionExercise(entry);
    final updatedPrograms = state.programs?.map((program) {
      if (program.id == programId) {
        final updatedProgramSessions = program.programSessions?.map((
          programSession,
        ) {
          if (programSession.id == entry.sessionId.value) {
            return programSession.copyWith(
              sessionExercises: programSession.sessionExercises != null
                  ? [...programSession.sessionExercises!, result]
                  : [result],
            );
          }
          return programSession;
        }).toList();
        return program.copyWith(programSessions: updatedProgramSessions);
      }
      return program;
    }).toList();
    state = state.copyWith(programs: updatedPrograms);
  }

  Future<void> deleteSessionExercise(
    int programId,
    int programSessionId,
    int sessionExerciseId,
  ) async {
    final result = await db.fitnessDao.deleteSessionExercise(sessionExerciseId);
    if (result == 0) {
      state = state.copyWith(error: 'Failed to delete session exercise');
      return;
    }
    final updatedPrograms = state.programs?.map((program) {
      if (program.id == programId) {
        return program.copyWith(
          programSessions: program.programSessions!
              .where((session) => session.id != programSessionId)
              .toList(),
        );
      }
      return program;
    }).toList();
    state = state.copyWith(programs: updatedPrograms);
  }
}

final fitnessProvider = NotifierProvider<FitnessNotifier, FitnessState>(
  FitnessNotifier.new,
);
