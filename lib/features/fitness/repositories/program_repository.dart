// import 'package:dartz/dartz.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:tenkai/core/errors/failures.dart';
// import 'package:tenkai/core/helpers/repository_helper.dart';
// import 'package:tenkai/core/network/api_endpoints.dart';
// import 'package:tenkai/core/network/dio_client.dart';
// import 'package:tenkai/features/fitness/models/program.dart';
// import 'package:tenkai/features/fitness/params/create_program_param.dart';

// class ProgramRepository {
//   final DioClient _dioClient;

//   const ProgramRepository(this._dioClient);

//   Future<Either<Failure, List<Program>>> listPrograms() {
//     return RepositoryHelper.executeList<Program>(
//       () => _dioClient.dio.get(ApiEndpoints.listPrograms),
//       itemParser: Program.fromJson,
//     );
//   }

//   Future<Either<Failure, Program>> createProgram(CreateProgramParam params) {
//     return RepositoryHelper.execute<Program>(
//       () => _dioClient.dio.post(
//         ApiEndpoints.listPrograms,
//         data: params.toJson(params),
//       ),
//       parser: Program.fromJson,
//     );
//   }
// }

// final programRepositoryProvider = Provider<ProgramRepository>(
//   (ref) => ProgramRepository(ref.read(dioClientProvider)),
// );
