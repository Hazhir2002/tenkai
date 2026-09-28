// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:tenkai/features/fitness/models/program.dart';
// import 'package:tenkai/features/fitness/params/create_program_param.dart';
// import 'package:tenkai/features/fitness/repositories/program_repository.dart';

// class ProgramState {
//   final List<Program>? programs;
//   final bool isLoading;
//   final String? error;

//   const ProgramState({this.programs, this.error, this.isLoading = false});

//   ProgramState copyWith({
//     List<Program>? programs,
//     String? error,
//     bool? isLoading,
//   }) => ProgramState(
//     programs: programs ?? this.programs,
//     error: error ?? this.error,
//     isLoading: isLoading ?? this.isLoading,
//   );
// }

// class ProgramNotifier extends Notifier<ProgramState> {
//   late ProgramRepository programRepository;

//   @override
//   build() {
//     programRepository = ref.read(programRepositoryProvider);
//     Future.microtask(() => listPrograms());
//     return const ProgramState();
//   }

//   Future<void> listPrograms() async {
//     state = state.copyWith(isLoading: true, error: null);
//     final result = await programRepository.listPrograms();

//     return result.fold(
//       (failure) =>
//           state = state.copyWith(isLoading: false, error: failure.message),
//       (programs) => state = state.copyWith(
//         isLoading: false,
//         error: null,
//         programs: programs,
//       ),
//     );
//   }

//   Future<void> createProgram(CreateProgramParam params) async {
//     state = state.copyWith(isLoading: true, error: null);
//     final result = await programRepository.createProgram(params);

//     return result.fold(
//       (failure) =>
//           state = state.copyWith(isLoading: false, error: failure.message),
//       (program) => state = state.copyWith(
//         isLoading: false,
//         error: null,
//         programs: state.programs != null
//             ? [...state.programs!, program]
//             : [program],
//       ),
//     );
//   }
// }

// final programProvider = NotifierProvider<ProgramNotifier, ProgramState>(
//   ProgramNotifier.new,
// );
