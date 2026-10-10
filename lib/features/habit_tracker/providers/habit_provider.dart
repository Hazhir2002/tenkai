import 'package:drift/drift.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/notifications/tenkai_notifications.dart';
import 'package:tenkai/core/providers.dart';
import 'package:tenkai/features/habit_tracker/models/habit_model.dart';
import 'package:tenkai/features/habit_tracker/models/schedule_slot_draft.dart';

class HabitState {
  final List<HabitModel> habits;
  final bool isLoading;
  final String? error;

  const HabitState({
    this.habits = const [],
    this.error,
    this.isLoading = false,
  });

  HabitState copyWith({
    List<HabitModel>? habits,
    String? error,
    bool? isLoading,
  }) => HabitState(
    habits: habits ?? this.habits,
    error: error ?? this.error,
    isLoading: isLoading ?? this.isLoading,
  );
}

class HabitNotifier extends Notifier<HabitState> {
  late AppDatabase db;

  @override
  HabitState build() {
    db = ref.read(appDataBaseProvider);
    Future.microtask(() => listHabits());
    return const HabitState();
  }

  Future<void> listHabits() async {
    state = state.copyWith(isLoading: true, error: null, habits: null);
    final result = await db.habitDao.getAllHabits();
    List<HabitModel> habitModels = result
        .map((h) => HabitModel.fromHabit(h))
        .toList();
    state = state.copyWith(isLoading: false, error: null, habits: habitModels);
  }

  Future<void> createHabit(
    HabitsCompanion entry, {
    required List<ScheduleSlotDraft> slots,
  }) async {
    final isTimeCued = entry.cueType.value == 'time';
    final scheduleCompanions = <HabitSchedulesCompanion>[
      if (isTimeCued)
        for (final s in slots)
          HabitSchedulesCompanion.insert(
            habitId: 0, // replaced with the real id on insert
            weekday: Value(s.weekday),
            hour: s.hour,
            minute: s.minute,
          ),
    ];
    final result = await db.habitDao.createHabit(
      entry,
      schedules: scheduleCompanions,
    );
    state = state.copyWith(
      habits: [...state.habits, HabitModel.fromHabit(result)],
    );

    final schedules = await db.habitDao.getSchedulesFor(result.id);
    if (result.reminderEnabled) {
      for (final schedule in schedules) {
        await TenkaiNotifications.scheduleHabitReminder(
          id: schedule.id,
          hour: schedule.hour,
          title: result.title,
          body: "It's time for your habit",
        );
      }
    }
  }

  Future<void> updateHabit(
    HabitsCompanion entry, {
    required List<ScheduleSlotDraft> slots,
  }) async {
    final isTimeCued = entry.cueType.value == 'time';
    final scheduleCompanions = <HabitSchedulesCompanion>[
      if (isTimeCued)
        for (final s in slots)
          HabitSchedulesCompanion.insert(
            habitId: 0, // replaced with the real id on insert
            weekday: Value(s.weekday),
            hour: s.hour,
            minute: s.minute,
          ),
    ];
    final result = await db.habitDao.createHabit(
      entry,
      schedules: scheduleCompanions,
    );
    state = state.copyWith(
      habits: [...state.habits, HabitModel.fromHabit(result)],
    );

    final schedules = await db.habitDao.getSchedulesFor(result.id);
    if (result.reminderEnabled) {
      for (final schedule in schedules) {
        await TenkaiNotifications.scheduleHabitReminder(
          id: schedule.id,
          hour: schedule.hour,
          title: result.title,
          body: "It's time for your habit",
        );
      }
    }
  }

  Future<void> deleteHabit(int habitId) async {
    final result = await db.habitDao.deleteHabit(habitId);
    if (result == 0) {
      state = state.copyWith(error: 'Failed to delete habit');
      return;
    }
    state = state.copyWith(
      habits: state.habits.where((program) => program.id != habitId).toList(),
    );
  }
}

final habitProvider = NotifierProvider<HabitNotifier, HabitState>(
  HabitNotifier.new,
);
