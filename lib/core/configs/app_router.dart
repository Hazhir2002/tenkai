import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/widgets/main_shell_wrapper.dart';
import 'package:tenkai/features/auth/screens/login_screen.dart';
import 'package:tenkai/features/auth/screens/register_screen.dart';
import 'package:tenkai/features/gym_tracker/screens/create_program_screen.dart';
import 'package:tenkai/features/gym_tracker/screens/exercises_screen.dart';
import 'package:tenkai/features/gym_tracker/screens/gym_tracker_screen.dart';
import 'package:tenkai/features/gym_tracker/screens/programs_screen.dart';
import 'package:tenkai/features/habit_tracker/presentation/habit_tracker_screen.dart';
import 'package:tenkai/features/journal/screens/journal_dashboard.dart';
import 'package:tenkai/features/journal/screens/journal_logs.dart';
import 'package:tenkai/features/knowledge/screens/knowledge_dashboard.dart';
import 'package:tenkai/features/profile/screens/profile_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/profile',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShellWrapper(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HabitTrackerScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/knowledge',
                builder: (context, state) => const KnowledgeDashboard(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/journal',
                builder: (context, state) => const JournalDashboard(),
                routes: [
                  GoRoute(
                    path: '/logs',
                    builder: (context, state) => const JournalLogsScreen(),
                  ),
                ],
              ),
            ],
          ),
          // StatefulShellBranch(
          //   routes: [
          //     GoRoute(
          //       path: '/gym-tracker',
          //       builder: (context, state) => const GymTrackerScreen(),
          //       routes: [
          //         GoRoute(
          //           path: '/exercises',
          //           builder: (context, state) => const ExercisesScreen(),
          //         ),
          //         GoRoute(
          //           path: '/programs',
          //           builder: (context, state) => const ProgramsScreen(),
          //           routes: [
          //             GoRoute(
          //               path: '/create',
          //               builder: (context, state) =>
          //                   const CreateProgramScreen(),
          //             ),
          //           ],
          //         ),
          //       ],
          //     ),
          //   ],
          // ),
        ],
      ),

      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
    ],
  );
});
