import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/features/user/repositories/state_repository.dart';

class UserStatState {
  final List<UserStatData>? userStats;
  final bool isLoading;
  final String? error;

  const UserStatState({this.userStats, this.error, this.isLoading = false});

  UserStatState copyWith({
    List<UserStatData>? userStats,
    String? error,
    bool? isLoading,
  }) => UserStatState(
    userStats: userStats ?? this.userStats,
    error: error ?? this.error,
    isLoading: isLoading ?? this.isLoading,
  );
}

class UserStatNotifier extends Notifier<UserStatState> {
  late StatRepository statRepository;

  @override
  build() {
    statRepository = ref.read(statRepositoryProvider);
    Future.microtask(() => listStats());
    return const UserStatState();
  }

  Future<void> listStats() async {
    state = state.copyWith(isLoading: true, error: null, userStats: null);
    final result = await statRepository.allUserStats;
    state = state.copyWith(isLoading: false, error: null, userStats: result);
  }

  Future<void> addStat(UserStatCompanion entry) async {
    final result = await statRepository.addStat(entry);
    state = state.copyWith(
      isLoading: false,
      error: null,
      userStats: state.userStats != null
          ? [...state.userStats!, result]
          : [result],
    );
  }

  Future<void> updateStat(UserStatData entry) async {
    final result = await statRepository.updateStat(entry);
    final stats = state.userStats!;
    state = state.copyWith(
      isLoading: false,
      userStats: stats
          .map<UserStatData>((s) => s.id == result.id ? result : s)
          .toList(),
    );
  }
}

final userStatProvider = NotifierProvider<UserStatNotifier, UserStatState>(
  UserStatNotifier.new,
);
