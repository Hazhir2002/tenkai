import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/widgets/main_shell_wrapper.dart';
import 'package:tenkai/features/fitness/screens/exercises_screen.dart';
import 'package:tenkai/features/fitness/screens/fitness_screen.dart';
import 'package:tenkai/features/fitness/screens/program_detail_screen.dart';
import 'package:tenkai/features/fitness/screens/program_session_detail_screen.dart';
import 'package:tenkai/features/fitness/screens/programs_screen.dart';
import 'package:tenkai/features/goal_tracker/screens/goals_screen.dart';
import 'package:tenkai/features/habit_tracker/screens/habit_form_screen.dart';
import 'package:tenkai/features/home/screens/home_screen.dart';
import 'package:tenkai/features/knowledge/screens/book_detail_screen.dart';
import 'package:tenkai/features/knowledge/screens/book_form_screen.dart';
import 'package:tenkai/features/knowledge/screens/book_library_screen.dart';
import 'package:tenkai/features/knowledge/screens/knowledge_dashboard.dart';
import 'package:tenkai/features/user/screens/fears_screen.dart';
import 'package:tenkai/features/habit_tracker/models/habit_view.dart';
import 'package:tenkai/features/habit_tracker/screens/habit_dashboard.dart';
import 'package:tenkai/features/habit_tracker/screens/habit_screen.dart';
import 'package:tenkai/features/user/screens/profile_screen.dart';

/// Routes that an unauthenticated user is allowed to sit on.
const _authRoutes = {'/login', '/register'};

final goRouterProvider = Provider<GoRouter>((ref) {
  // Bridge Riverpod → go_router: bump this whenever the auth status changes so
  // the router re-evaluates [redirect] on login/logout/session-restore.
  final refresh = ValueNotifier<int>(0);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    debugLogDiagnostics: true,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShellWrapper(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/habits',
                builder: (context, state) => const HabitDashboard(),
                routes: [
                  GoRoute(
                    path: '/new',
                    builder: (context, state) => HabitFormScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) =>
                        HabitScreen(habitView: state.extra as HabitView),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/fitness',
                builder: (context, state) => const FitnessScreen(),
                routes: [
                  GoRoute(
                    path: '/programs',
                    builder: (context, state) => const ProgramsScreen(),
                    routes: [
                      GoRoute(
                        path: ':programId',
                        builder: (context, state) => ProgramDetailScreen(
                          programId: int.parse(
                            state.pathParameters['programId']!,
                          ),
                        ),
                        routes: [
                          GoRoute(
                            path: ':programSessionId',
                            builder: (context, state) =>
                                ProgramSessionDetailScreen(
                                  programId: int.parse(
                                    state.pathParameters['programId']!,
                                  ),
                                  programSessionId: int.parse(
                                    state.pathParameters['programSessionId']!,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // GoRoute(
                  //   path: '/exercises',
                  //   builder: (context, state) => const ExercisesScreen(),
                  // ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/knowledge',
                builder: (context, state) => const KnowledgeDashboard(),
                routes: [
                  GoRoute(
                    path: '/book-library',
                    builder: (context, state) => const BookLibraryScreen(),
                    routes: [
                      GoRoute(
                        path: '/new',
                        builder: (context, state) => const BookFormScreen(),
                      ),
                      GoRoute(
                        path: ':id',
                        builder: (context, state) => BookDetailScreen(
                          bookId: int.parse(state.pathParameters['id']!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/user',
                builder: (context, state) => const GoalsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
