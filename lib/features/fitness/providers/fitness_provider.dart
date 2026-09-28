import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/providers.dart';

class FitnessState {
  final List<Program>? programs;
  final bool isLoading;
  final String? error;

  const FitnessState({this.programs, this.error, this.isLoading = false});

  FitnessState copyWith({
    List<Program>? programs,
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
    return const FitnessState();
  }

  Future<void> listPrograms() async {
    state = state.copyWith(isLoading: true, error: null, programs: null);
    final result = await db.fitnessDao.getAllPrograms();
    state = state.copyWith(isLoading: false, error: null, programs: result);
  }

  Future<void> createProgram(ProgramsCompanion entry) async {
    final result = await db.fitnessDao.createProgram(entry);
    state = state.copyWith(
      programs: state.programs != null
          ? [...state.programs!, result]
          : [result],
    );
  }
}

final fitnessProvider = NotifierProvider<FitnessNotifier, FitnessState>(
  FitnessNotifier.new,
);
