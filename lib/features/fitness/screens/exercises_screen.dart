// import 'package:flutter/material.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:tenkai/core/design_system/tenkai.dart';
// import 'package:tenkai/features/fitness/providers/exercise_provider.dart';

// class ExercisesScreen extends ConsumerWidget {
//   const ExercisesScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final exerciseState = ref.watch(exerciseProvider);
//     final c = context.tenkai;

//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(title: Text('Exercises')),
//       body: Builder(
//         builder: (context) {
//           final topPad = MediaQuery.of(context).padding.top;
//           if (exerciseState.isLoading) {
//             return Center(
//               child: SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 1.5,
//                   color: c.mutedForeground,
//                 ),
//               ),
//             );
//           }
//           if (exerciseState.error != null) {
//             return const Center(
//               child: TenkaiEmptyState(title: 'Couldn\'t load exercises'),
//             );
//           }
//           final exercises = exerciseState.exercises;
//           if (exercises == null || exercises.isEmpty) {
//             return const Center(
//               child: TenkaiEmptyState(
//                 title: 'No exercises yet',
//                 description: 'Exercises you add will show up here.',
//               ),
//             );
//           }
//           return ListView.separated(
//             padding: EdgeInsets.fromLTRB(
//               TenkaiSpacing.lg,
//               topPad,
//               TenkaiSpacing.lg,
//               TenkaiSpacing.xl,
//             ),
//             itemCount: exercises.length,
//             separatorBuilder: (_, __) =>
//                 const SizedBox(height: TenkaiSpacing.sm),
//             itemBuilder: (_, index) =>
//                 TenkaiListRow(title: exercises[index].name),
//           );
//         },
//       ),
//     );
//   }
// }
