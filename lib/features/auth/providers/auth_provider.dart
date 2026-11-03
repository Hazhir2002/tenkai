import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/features/auth/entities/user.dart';
import 'package:tenkai/features/auth/params/login_params.dart';
import 'package:tenkai/features/auth/params/register_params.dart';
import 'package:tenkai/features/auth/repositories/auth_repository.dart';

enum AuthStatus { unknown, unAuthenticated, authenticated }

class AuthState {
  final AuthStatus authStatus;
  final User? user;
  final String? error;
  final bool isLoading;

  const AuthState({
    this.authStatus = AuthStatus.unknown,
    this.user,
    this.error,
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? authStatus,
    User? user,
    String? error,
    bool? isLoading,
  }) => AuthState(
    authStatus: authStatus ?? this.authStatus,
    user: user ?? this.user,
    error: error ?? this.error,
    isLoading: isLoading ?? this.isLoading,
  );
}

class AuthNotifier extends Notifier<AuthState> {
  late AuthRepository _authRepository;

  @override
  AuthState build() {
    _authRepository = ref.read(authRepositoryProvider);
    return const AuthState();
  }

  Future<User?> register(RegisterParams params) async {
    state = AuthState(
      isLoading: true,
      error: null,
      authStatus: AuthStatus.unknown,
    );
    final result = await _authRepository.register(params);

    return result.fold(
      (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.message,
          authStatus: AuthStatus.unAuthenticated,
          user: null,
        );
        return null;
      },
      (user) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          authStatus: AuthStatus.unAuthenticated,
          user: null,
        );
        return user;
      },
    );
  }

  Future<void> login(LoginParams params) async {
    state = AuthState(
      isLoading: true,
      error: null,
      authStatus: AuthStatus.unknown,
    );
    final result = await _authRepository.login(params);
    result.fold(
      (error) => {
        state = state.copyWith(
          isLoading: false,
          error: error.message,
          authStatus: AuthStatus.unAuthenticated,
          user: null,
        ),
      },
      (_) async => {await authenticateUser()},
    );
  }

  Future<void> authenticateUser() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      authStatus: AuthStatus.unknown,
      user: null,
    );
    final result = await _authRepository.authenticateUser();
    result.fold(
      (error) => {
        state = state.copyWith(
          isLoading: false,
          error: error.message,
          authStatus: AuthStatus.unAuthenticated,
          user: null,
        ),
      },
      (user) => {
        state = state.copyWith(
          isLoading: false,
          error: null,
          authStatus: AuthStatus.authenticated,
          user: user,
        ),
      },
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
