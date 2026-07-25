import 'package:drift/drift.dart' show Value;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/providers.dart';
import 'package:tenkai/core/services/notification_service.dart';

import '../models/habit_enums.dart';
import '../models/habit_view.dart';

/// A single editable schedule slot in the create/edit form.
class ScheduleSlotDraft {
  const ScheduleSlotDraft({this.weekday, required this.hour, required this.minute});

  /// 1..7 (Mon..Sun), or null for daily.
  final int? weekday;
  final int hour;
  final int minute;

  ScheduleSlotDraft copyWith({
    Object? weekday = _sentinel,
    int? hour,
    int? minute,
  }) {
    return ScheduleSlotDraft(
      weekday: weekday == _sentinel ? this.weekday : weekday as int?,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  static const _sentinel = Object();
}

/// Immutable draft for creating or editing a habit.
class HabitFormState {
  const HabitFormState({
    this.original,
    this.title = '',
    this.description = '',
    this.status = HabitStatus.building,
    this.cueType = HabitCueType.time,
    this.cueHabitId,
    this.slots = const [],
    this.reminderEnabled = true,
    this.reminderOffsetMinutes = 0,
    this.saving = false,
  });

  /// The habit being edited, or null when creating.
  final Habit? original;
  final String title;
  final String description;
  final HabitStatus status;
  final HabitCueType cueType;
  final int? cueHabitId;
  final List<ScheduleSlotDraft> slots;
  final bool reminderEnabled;
  final int reminderOffsetMinutes;
  final bool saving;

  bool get isEditing => original != null;

  bool get isValid {
    if (title.trim().isEmpty) return false;
    if (cueType == HabitCueType.afterHabit) return cueHabitId != null;
    return slots.isNotEmpty;
  }

  HabitFormState copyWith({
    Object? original = _sentinel,
    String? title,
    String? description,
    HabitStatus? status,
    HabitCueType? cueType,
    Object? cueHabitId = _sentinel,
    List<ScheduleSlotDraft>? slots,
    bool? reminderEnabled,
    int? reminderOffsetMinutes,
    bool? saving,
  }) {
    return HabitFormState(
      original: original == _sentinel ? this.original : original as Habit?,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      cueType: cueType ?? this.cueType,
      cueHabitId: cueHabitId == _sentinel ? this.cueHabitId : cueHabitId as int?,
      slots: slots ?? this.slots,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderOffsetMinutes:
          reminderOffsetMinutes ?? this.reminderOffsetMinutes,
      saving: saving ?? this.saving,
    );
  }

  static const _sentinel = Object();
}

class HabitFormNotifier extends Notifier<HabitFormState> {
  @override
  HabitFormState build() => const HabitFormState();

  /// Reset the form for creating a brand-new habit.
  void startCreate() => state = const HabitFormState();

  /// Seed the form from an existing habit for editing.
  void startEdit(HabitView view) {
    final h = view.habit;
    state = HabitFormState(
      original: h,
      title: h.title,
      description: h.description ?? '',
      status: HabitStatus.fromDb(h.status),
      cueType: HabitCueType.fromDb(h.cueType),
      cueHabitId: h.cueHabitId,
      slots: [
        for (final s in view.schedules)
          ScheduleSlotDraft(weekday: s.weekday, hour: s.hour, minute: s.minute),
      ],
      reminderEnabled: h.reminderEnabled,
      reminderOffsetMinutes: h.reminderOffsetMinutes,
    );
  }

  void setTitle(String v) => state = state.copyWith(title: v);
  void setDescription(String v) => state = state.copyWith(description: v);
  void setStatus(HabitStatus v) => state = state.copyWith(status: v);
  void setCueType(HabitCueType v) => state = state.copyWith(cueType: v);
  void setCueHabit(int? id) => state = state.copyWith(cueHabitId: id);
  void setReminderEnabled(bool v) => state = state.copyWith(reminderEnabled: v);
  void setReminderOffset(int minutes) =>
      state = state.copyWith(reminderOffsetMinutes: minutes);

  void addSlot([ScheduleSlotDraft? slot]) {
    state = state.copyWith(
      slots: [...state.slots, slot ?? const ScheduleSlotDraft(hour: 8, minute: 0)],
    );
  }

  void updateSlot(int index, ScheduleSlotDraft slot) {
    final next = [...state.slots];
    next[index] = slot;
    state = state.copyWith(slots: next);
  }

  void removeSlot(int index) {
    final next = [...state.slots]..removeAt(index);
    state = state.copyWith(slots: next);
  }

  /// Persists the draft and (re)schedules notifications. Returns the habit id,
  /// or null if the draft is invalid.
  Future<int?> save() async {
    if (!state.isValid) return null;
    state = state.copyWith(saving: true);
    final db = ref.read(appDataBaseProvider);
    final notifications = ref.read(notificationServiceProvider);

    final isTimeCued = state.cueType == HabitCueType.time;
    final scheduleCompanions = <HabitSchedulesCompanion>[
      if (isTimeCued)
        for (final s in state.slots)
          HabitSchedulesCompanion.insert(
            habitId: 0, // replaced with the real id on insert
            weekday: Value(s.weekday),
            hour: s.hour,
            minute: s.minute,
          ),
    ];

    final int habitId;
    if (state.isEditing) {
      final orig = state.original!;
      habitId = orig.id;
      await db.habitDao.updateHabit(
        orig.copyWith(
          title: state.title.trim(),
          description: Value(
            state.description.trim().isEmpty ? null : state.description.trim(),
          ),
          status: state.status.dbValue,
          cueType: state.cueType.dbValue,
          cueHabitId: Value(isTimeCued ? null : state.cueHabitId),
          reminderEnabled: state.reminderEnabled,
          reminderOffsetMinutes: state.reminderOffsetMinutes,
        ),
      );
      await db.habitDao.replaceSchedules(habitId, scheduleCompanions);
    } else {
      habitId = await db.habitDao.createHabit(
        title: state.title.trim(),
        description:
            state.description.trim().isEmpty ? null : state.description.trim(),
        status: state.status.dbValue,
        cueType: state.cueType.dbValue,
        cueHabitId: isTimeCued ? null : state.cueHabitId,
        reminderEnabled: state.reminderEnabled,
        reminderOffsetMinutes: state.reminderOffsetMinutes,
        schedules: scheduleCompanions,
      );
    }

    final habit = await db.habitDao.getHabit(habitId);
    final schedules = await db.habitDao.getSchedulesFor(habitId);
    if (habit != null && habit.reminderEnabled) {
      // Ensure permission before scheduling (prompts on first use).
      await notifications.requestPermissionIfNeeded();
    }
    if (habit != null) {
      await notifications.syncHabit(habit, schedules);
    }

    state = state.copyWith(saving: false);
    return habitId;
  }
}

final habitFormProvider =
    NotifierProvider<HabitFormNotifier, HabitFormState>(HabitFormNotifier.new);
