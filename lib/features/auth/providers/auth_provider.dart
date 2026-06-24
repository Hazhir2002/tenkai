import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/features/auth/models/user.dart';
import 'package:tenkai/features/auth/params/login_params.dart';
import 'package:tenkai/features/auth/repositories/auth_repository.dart';

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
  late AuthRepository authRepository;

  @override
  AuthState build() {
    // _checkAuthStatus();
    authRepository = ref.read(authRepositoryProvider);
    return const AuthState();
  }

  // Future<void> _checkAuthStatus() async {
  //   final isAuth = await ref.read(authRepositoryProvider).isAuthenticated();
  //   if (isAuth) {
  //     final result = await ref.read(getMeUseCaseProvider).call(NoParams());
  //     result.fold(
  //       (_) => state = state.copyWith(status: AuthStatus.unauthenticated),
  //       (user) => state = state.copyWith(
  //         status: AuthStatus.authenticated,
  //         user: user,
  //       ),
  //     );
  //   } else {
  //     state = state.copyWith(status: AuthStatus.unauthenticated);
  //   }
  // }

  Future<void> login(LoginParams params) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await authRepository.login(params);

    return result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
        status: AuthStatus.unauthenticated,
      ),
      (result) async {
        final meResult = await authRepository.getMe();
        meResult.fold(
          (f) =>
              state = state.copyWith(isLoading: false, errorMessage: f.message),
          (user) => state = state.copyWith(
            isLoading: false,
            status: AuthStatus.authenticated,
            user: user,
          ),
        );
      },
    );
  }

  // Future<bool> register(RegisterParams params) async {
  //   state = state.copyWith(isLoading: true, clearError: true);
  //   final result = await ref.read(registerUseCaseProvider).call(params);

  //   return result.fold(
  //     (failure) {
  //       state = state.copyWith(isLoading: false, errorMessage: failure.message);
  //       return false;
  //     },
  //     (_) {
  //       state = state.copyWith(isLoading: false);
  //       return true;
  //     },
  //   );
  // }

  // Future<bool> verifyEmail(String token) async {
  //   state = state.copyWith(isLoading: true, clearError: true);
  //   final result = await ref.read(verifyEmailUseCaseProvider).call(token);
  //   return result.fold(
  //     (f) {
  //       state = state.copyWith(isLoading: false, errorMessage: f.message);
  //       return false;
  //     },
  //     (_) {
  //       state = state.copyWith(isLoading: false);
  //       return true;
  //     },
  //   );
  // }

  // Future<bool> resendVerification(String email) async {
  //   state = state.copyWith(isLoading: true, clearError: true);
  //   final result = await ref
  //       .read(resendVerificationUseCaseProvider)
  //       .call(email);
  //   return result.fold(
  //     (f) {
  //       state = state.copyWith(isLoading: false, errorMessage: f.message);
  //       return false;
  //     },
  //     (_) {
  //       state = state.copyWith(isLoading: false);
  //       return true;
  //     },
  //   );
  // }

  // Future<bool> forgotPassword(String email) async {
  //   state = state.copyWith(isLoading: true, clearError: true);
  //   final result = await ref.read(forgotPasswordUseCaseProvider).call(email);
  //   return result.fold(
  //     (f) {
  //       state = state.copyWith(isLoading: false, errorMessage: f.message);
  //       return false;
  //     },
  //     (_) {
  //       state = state.copyWith(isLoading: false);
  //       return true;
  //     },
  //   );
  // }

  // Future<bool> resetPassword(ResetPasswordParams params) async {
  //   state = state.copyWith(isLoading: true, clearError: true);
  //   final result = await ref.read(resetPasswordUseCaseProvider).call(params);
  //   return result.fold(
  //     (f) {
  //       state = state.copyWith(isLoading: false, errorMessage: f.message);
  //       return false;
  //     },
  //     (_) {
  //       state = state.copyWith(isLoading: false);
  //       return true;
  //     },
  //   );
  // }

  // Future<bool> changePassword(ChangePasswordParams params) async {
  //   state = state.copyWith(isLoading: true, clearError: true);
  //   final result = await ref.read(changePasswordUseCaseProvider).call(params);
  //   return result.fold(
  //     (f) {
  //       state = state.copyWith(isLoading: false, errorMessage: f.message);
  //       return false;
  //     },
  //     (_) {
  //       state = state.copyWith(isLoading: false);
  //       return true;
  //     },
  //   );
  // }

  // Future<bool> updateProfile(UpdateProfileParams params) async {
  //   state = state.copyWith(isLoading: true, clearError: true);
  //   final result = await ref.read(updateProfileUseCaseProvider).call(params);
  //   return result.fold(
  //     (f) {
  //       state = state.copyWith(isLoading: false, errorMessage: f.message);
  //       return false;
  //     },
  //     (user) {
  //       state = state.copyWith(isLoading: false, user: user);
  //       return true;
  //     },
  //   );
  // }

  // Future<bool> uploadAvatar(File file) async {
  //   state = state.copyWith(isLoading: true, clearError: true);
  //   final result = await ref.read(uploadAvatarUseCaseProvider).call(file);
  //   return result.fold(
  //     (f) {
  //       state = state.copyWith(isLoading: false, errorMessage: f.message);
  //       return false;
  //     },
  //     (user) {
  //       state = state.copyWith(isLoading: false, user: user);
  //       return true;
  //     },
  //   );
  // }

  // Future<bool> deleteAvatar() async {
  //   state = state.copyWith(isLoading: true, clearError: true);
  //   final result = await ref.read(deleteAvatarUseCaseProvider).call(NoParams());
  //   return result.fold(
  //     (f) {
  //       state = state.copyWith(isLoading: false, errorMessage: f.message);
  //       return false;
  //     },
  //     (user) {
  //       state = state.copyWith(isLoading: false, user: user);
  //       return true;
  //     },
  //   );
  // }

  // Future<void> logout() async {
  //   state = state.copyWith(isLoading: true);
  //   await ref.read(logoutUseCaseProvider).call(NoParams());
  //   state = const AuthState(status: AuthStatus.unauthenticated);
  // }

  // Future<void> logoutAll() async {
  //   state = state.copyWith(isLoading: true);
  //   await ref.read(logoutAllUseCaseProvider).call(NoParams());
  //   state = const AuthState(status: AuthStatus.unauthenticated);
  // }

  void clearError() => state = state.copyWith(clearError: true);
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
