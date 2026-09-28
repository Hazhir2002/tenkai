// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:tenkai/features/fitness/models/exercise.dart';
// import 'package:tenkai/features/fitness/repositories/exercise_repository.dart';

// class ExerciseState {
//   final List<Exercise>? exercises;
//   final bool isLoading;
//   final String? error;

//   const ExerciseState({this.exercises, this.error, this.isLoading = false});

//   ExerciseState copyWith({
//     List<Exercise>? exercises,
//     String? error,
//     bool? isLoading,
//   }) => ExerciseState(
//     exercises: exercises ?? this.exercises,
//     error: error ?? this.error,
//     isLoading: isLoading ?? this.isLoading,
//   );
// }

// class ExerciseNotifier extends Notifier<ExerciseState> {
//   late ExerciseRepository exerciseRepository;

//   @override
//   build() {
//     exerciseRepository = ref.read(exerciseRepositoryProvider);
//     Future.microtask(() => searchExercises());
//     return const ExerciseState();
//   }

//   Future<void> searchExercises() async {
//     state = state.copyWith(isLoading: true, error: null);
//     final result = await exerciseRepository.searchExercises();

//     return result.fold(
//       (failure) =>
//           state = state.copyWith(isLoading: false, error: failure.message),
//       (exercises) => state = state.copyWith(
//         isLoading: false,
//         error: null,
//         exercises: exercises,
//       ),
//     );
//   }
// }

// final exerciseProvider = NotifierProvider<ExerciseNotifier, ExerciseState>(
//   ExerciseNotifier.new,
// );
