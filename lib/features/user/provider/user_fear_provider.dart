import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/features/user/repositories/fear_repository.dart';

class UserFearState {
  final List<UserFearData>? userFears;
  final bool isLoading;
  final String? error;

  const UserFearState({this.userFears, this.error, this.isLoading = false});

  UserFearState copyWith({
    List<UserFearData>? userFears,
    String? error,
    bool? isLoading,
  }) => UserFearState(
    userFears: userFears ?? this.userFears,
    error: error ?? this.error,
    isLoading: isLoading ?? this.isLoading,
  );
}

class UserFearNotifier extends Notifier<UserFearState> {
  late FearRepository fearRepository;

  @override
  UserFearState build() {
    fearRepository = ref.read(fearRepositoryProvider);
    // Future.microtask(() => listFears());
    return const UserFearState();
  }

  Future<void> listFears() async {
    state = state.copyWith(isLoading: true, error: null, userFears: null);
    final result = await fearRepository.allUserFears;
    state = state.copyWith(isLoading: false, error: null, userFears: result);
  }

  Future<void> addFear(UserFearCompanion entry) async {
    final result = await fearRepository.addFear(entry);
    state = state.copyWith(
      isLoading: false,
      error: null,
      userFears: state.userFears != null
          ? [...state.userFears!, result]
          : [result],
    );
  }
}

final userFearProvider = NotifierProvider<UserFearNotifier, UserFearState>(
  UserFearNotifier.new,
);
