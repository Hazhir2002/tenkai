import 'package:health/health.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

var types = [HealthDataType.STEPS, HealthDataType.BLOOD_GLUCOSE];
var permissions = [HealthDataAccess.READ_WRITE, HealthDataAccess.READ_WRITE];

class HealthState {
  final Health health;
  final bool isLoading;
  final int? steps;
  final String? error;

  HealthState({Health? health, this.isLoading = false, this.steps, this.error})
    : health = health ?? Health();

  HealthState copyWith({
    Health? health,
    bool? isLoading,
    int? steps,
    String? error,
  }) => HealthState(
    health: health ?? this.health,
    isLoading: isLoading ?? this.isLoading,
    steps: steps ?? this.steps,
    error: error ?? this.error,
  );
}

class HealthNotifier extends Notifier<HealthState> {
  @override
  HealthState build() {
    // Run initialization logic in microtask
    Future.microtask(() async {
      await state.health.configure();
      bool requested = await state.health.requestAuthorization(
        types,
        permissions: permissions,
      );
      if (requested) {
        await getTotalStepsInInterval();
      } else {
        state = state.copyWith(error: "HealthKit authorization denied");
      }
    });

    return HealthState();
  }

  Future<void> getTotalStepsInInterval() async {
    state = state.copyWith(isLoading: true, error: null);
    var now = DateTime.now();
    var midnight = DateTime(now.year, now.month, now.day);

    try {
      final stepsCount = await state.health.getTotalStepsInInterval(
        midnight,
        now,
      );
      state = state.copyWith(steps: stepsCount, isLoading: false, error: null);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
        steps: null,
      );
    }
  }
}

final healthProvider = NotifierProvider<HealthNotifier, HealthState>(
  HealthNotifier.new,
);
