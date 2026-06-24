import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/features/auth/providers/auth_provider.dart';
import 'package:tenkai/features/auth/screens/login_screen.dart';
import 'package:tenkai/features/auth/screens/register_screen.dart';
import 'package:tenkai/features/habit_tracker/presentation/habit_tracker_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',

    redirect: (context, state) {
      print('redirect called');
      final authState = ref.read(authProvider);

      if (authState.isAuthenticated && state.matchedLocation == '/login') {
        return '/profile';
      }

      if (!authState.isAuthenticated && state.matchedLocation == '/profile') {
        return '/login';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HabitTrackerScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const HabitTrackerScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
    ],
  );
});
