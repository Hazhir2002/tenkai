import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/features/auth/models/user.dart';
import 'package:tenkai/features/auth/params/login_params.dart';
import 'package:tenkai/features/auth/params/register_params.dart';
import 'package:tenkai/features/auth/repositories/auth_repository.dart';

/// [initial] means "still restoring the session on launch" — the router shows a
/// splash until it resolves to [authenticated] or [unauthenticated].
enum AuthStatus { initial, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    bool? isLoading,
    bool clearUser = false,
    bool clearError = false,
  }) => AuthState(
    status: status ?? this.status,
    user: clearUser ? null : (user ?? this.user),
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    isLoading: isLoading ?? this.isLoading,
  );
}

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.read(authRepositoryProvider);
    Future.microtask(restoreSession);
    return const AuthState();
  }

  /// Attempts to silently resume a persisted session on app launch.
  Future<void> restoreSession() async {
    final result = await _repository.restoreSession();
    state = result.fold(
      (_) => const AuthState(status: AuthStatus.unauthenticated),
      (user) => AuthState(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> login(LoginParams params) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.login(params);
    state = result.fold(
      (failure) => state.copyWith(
        isLoading: false,
        status: AuthStatus.unauthenticated,
        errorMessage: failure.message,
      ),
      (user) => AuthState(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> register(RegisterParams params) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.register(params);
    state = result.fold(
      (failure) => state.copyWith(
        isLoading: false,
        status: AuthStatus.unauthenticated,
        errorMessage: failure.message,
      ),
      (user) => AuthState(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Invoked by the network layer when a token refresh fails unrecoverably, so
  /// the router guard can bounce the user back to login.
  void markSessionExpired() {
    if (state.status == AuthStatus.unauthenticated) return;
    state = const AuthState(
      status: AuthStatus.unauthenticated,
      errorMessage: 'Session expired. Please log in again.',
    );
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
