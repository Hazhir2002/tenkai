import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/widgets/main_shell_wrapper.dart';
import 'package:tenkai/features/auth/providers/auth_provider.dart';
import 'package:tenkai/features/auth/screens/login_screen.dart';
import 'package:tenkai/features/auth/screens/register_screen.dart';
import 'package:tenkai/features/auth/screens/splash_screen.dart';
import 'package:tenkai/features/goal_tracker/screens/goal_detail_screen.dart';
import 'package:tenkai/features/goal_tracker/screens/goals_screen.dart';
import 'package:tenkai/features/habit_tracker/screens/habit_dashboard.dart';
import 'package:tenkai/features/journal/screens/journal_dashboard.dart';
import 'package:tenkai/features/journal/screens/journal_logs.dart';
import 'package:tenkai/features/knowledge/screens/book_detail_screen.dart';
import 'package:tenkai/features/knowledge/screens/books_screen.dart';
import 'package:tenkai/features/knowledge/screens/knowledge_dashboard.dart';
import 'package:tenkai/features/profile/screens/profile_screen.dart';
import 'package:tenkai/features/task_tracker/screens/tasks_screen.dart';

/// Routes that an unauthenticated user is allowed to sit on.
const _authRoutes = {'/login', '/register'};

final goRouterProvider = Provider<GoRouter>((ref) {
  // Bridge Riverpod → go_router: bump this whenever the auth status changes so
  // the router re-evaluates [redirect] on login/logout/session-restore.
  final refresh = ValueNotifier<int>(0);
  ref.listen(authProvider.select((s) => s.status), (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/habits',
    refreshListenable: refresh,
    redirect: (context, state) {
      final status = ref.read(authProvider).status;
      final location = state.matchedLocation;

      // Still restoring the persisted session — hold on the splash.
      if (status == AuthStatus.initial) {
        return location == '/splash' ? null : '/splash';
      }

      final loggedIn = status == AuthStatus.authenticated;
      if (!loggedIn) {
        return _authRoutes.contains(location) ? null : '/login';
      }

      // Authenticated: keep users out of the auth/splash screens.
      if (_authRoutes.contains(location) || location == '/splash') {
        return '/habits';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShellWrapper(navigationShell: navigationShell),
        branches: [
          // StatefulShellBranch(
          //   routes: [
          //     GoRoute(
          //       path: '/',
          //       builder: (context, state) => const TasksScreen(),
          //     ),
          //   ],
          // ),
          // StatefulShellBranch(
          //   routes: [
          //     GoRoute(
          //       path: '/goals',
          //       builder: (context, state) => const GoalsScreen(),
          //       routes: [
          //         GoRoute(
          //           path: ':id',
          //           builder: (context, state) => GoalDetailScreen(
          //             goalId: state.pathParameters['id']!,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ],
          // ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/habits',
                builder: (context, state) => const HabitDashboard(),
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
          // StatefulShellBranch(
          //   routes: [
          //     GoRoute(
          //       path: '/knowledge',
          //       builder: (context, state) => const KnowledgeDashboard(),
          //       routes: [
          //         GoRoute(
          //           path: '/books',
          //           builder: (context, state) => const BooksScreen(),
          //           routes: [
          //             GoRoute(
          //               path: '/:id',
          //               builder: (context, state) => BookDetailScreen(
          //                 bookId: int.parse(state.pathParameters['id']!),
          //               ),
          //             ),
          //           ],
          //         ),
          //       ],
          //     ),
          //   ],
          // ),
          // StatefulShellBranch(
          //   routes: [
          //     GoRoute(
          //       path: '/journal',
          //       builder: (context, state) => const JournalDashboard(),
          //       routes: [
          //         GoRoute(
          //           path: '/logs',
          //           builder: (context, state) => const JournalLogsScreen(),
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
