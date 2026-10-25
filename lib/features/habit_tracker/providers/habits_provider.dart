import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/providers.dart';

import '../models/habit_enums.dart';
import '../models/habit_view.dart';

/// `yyyy-MM-dd` key for a given day (defaults to today). Matches the format
/// stored in `HabitCompletions.dateKey`.
String dateKeyFor([DateTime? day]) {
  final d = day ?? DateTime.now();
  final m = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$dd';
}

/// Reactively streams every habit, ordered by sort order then creation.
final habitsProvider = StreamProvider<List<Habit>>((ref) {
  return ref.watch(appDataBaseProvider).habitDao.watchAllHabits();
});

/// Reactively streams all schedule slots across every habit.
final habitSchedulesProvider = StreamProvider<List<HabitSchedule>>((ref) {
  return ref.watch(appDataBaseProvider).habitDao.watchAllSchedules();
});

/// Reactively streams the completions recorded for today.
final todayCompletionsProvider = StreamProvider<List<HabitCompletion>>((ref) {
  return ref
      .watch(appDataBaseProvider)
      .habitDao
      .watchCompletionsForDate(dateKeyFor());
});

/// Builds the stacking-chain forest of [HabitView]s with each node's derived
/// state for today. Roots are time-cued (or unanchored) habits; children are
/// habits stacked "after" their cue habit. Returns `null` while the underlying
/// streams are still loading.
final habitGraphProvider = Provider<AsyncValue<List<HabitView>>>((ref) {
  final habitsAsync = ref.watch(habitsProvider);
  final schedulesAsync = ref.watch(habitSchedulesProvider);
  final completionsAsync = ref.watch(todayCompletionsProvider);

  // Fold the three async values into one; surface loading/error uniformly.
  return habitsAsync.whenData((habits) {
    final schedules = schedulesAsync.valueOrNull ?? const <HabitSchedule>[];
    final completions =
        completionsAsync.valueOrNull ?? const <HabitCompletion>[];
    return _buildForest(habits, schedules, completions, DateTime.now());
  });
});

List<HabitView> _buildForest(
  List<Habit> habits,
  List<HabitSchedule> schedules,
  List<HabitCompletion> completions,
  DateTime now,
) {
  if (habits.isEmpty) return const [];

  final byId = {for (final h in habits) h.id: h};
  final doneIds = completions.map((c) => c.habitId).toSet();

  final schedulesByHabit = <int, List<HabitSchedule>>{};
  for (final s in schedules) {
    schedulesByHabit.putIfAbsent(s.habitId, () => []).add(s);
  }

  // First pass: today's slot datetimes and next occurrence per habit.
  final todaySlots = <int, List<DateTime>>{};
  final nextOccurrence = <int, DateTime?>{};
  for (final h in habits) {
    final slots = schedulesByHabit[h.id] ?? const [];
    final todays = <DateTime>[];
    for (final s in slots) {
      if (s.weekday == null || s.weekday == now.weekday) {
        todays.add(DateTime(now.year, now.month, now.day, s.hour, s.minute));
      }
    }
    todays.sort();
    todaySlots[h.id] = todays;
    final upcoming = todays.where((d) => !d.isBefore(now)).toList();
    nextOccurrence[h.id] = upcoming.isNotEmpty
        ? upcoming.first
        : (todays.isNotEmpty ? todays.first : null);
  }

  // First pass: base day state (before choosing the single "next").
  final baseState = <int, HabitDayState>{};
  for (final h in habits) {
    final status = HabitStatus.fromDb(h.status);
    final cueType = HabitCueType.fromDb(h.cueType);
    if (status == HabitStatus.planned) {
      baseState[h.id] = HabitDayState.planned;
      continue;
    }
    if (doneIds.contains(h.id)) {
      baseState[h.id] = HabitDayState.doneToday;
      continue;
    }
    if (cueType == HabitCueType.afterHabit) {
      final cueId = h.cueHabitId;
      // Actionable once its cue habit has been completed today.
      if (cueId != null && doneIds.contains(cueId)) {
        baseState[h.id] = HabitDayState.pendingToday;
      } else {
        baseState[h.id] = HabitDayState.notScheduledToday;
      }
      continue;
    }
    // Time-cued.
    if ((todaySlots[h.id] ?? const []).isNotEmpty) {
      baseState[h.id] = HabitDayState.pendingToday;
    } else if (status == HabitStatus.building) {
      baseState[h.id] = HabitDayState.building;
    } else {
      baseState[h.id] = HabitDayState.notScheduledToday;
    }
  }

  // Choose the single "next" habit: the pending one with the earliest
  // effective time (after-habit pending ones act as "now").
  int? nextId;
  DateTime? bestKey;
  for (final h in habits) {
    if (baseState[h.id] != HabitDayState.pendingToday) continue;
    final key = nextOccurrence[h.id] ?? now;
    if (bestKey == null || key.isBefore(bestKey)) {
      bestKey = key;
      nextId = h.id;
    }
  }

  HabitDayState stateFor(int id) =>
      id == nextId ? HabitDayState.next : baseState[id]!;

  // Build children map for afterHabit habits with a valid parent.
  final childIdsByParent = <int, List<int>>{};
  final rootIds = <int>[];
  for (final h in habits) {
    final cueType = HabitCueType.fromDb(h.cueType);
    final parentId = h.cueHabitId;
    if (cueType == HabitCueType.afterHabit &&
        parentId != null &&
        byId.containsKey(parentId) &&
        parentId != h.id) {
      childIdsByParent.putIfAbsent(parentId, () => []).add(h.id);
    } else {
      rootIds.add(h.id);
    }
  }

  final visited = <int>{};

  HabitView buildView(int id, int depth) {
    visited.add(id);
    final h = byId[id]!;
    final childViews = <HabitView>[];
    for (final childId in childIdsByParent[id] ?? const <int>[]) {
      if (visited.contains(childId)) continue; // guard against cycles
      childViews.add(buildView(childId, depth + 1));
    }
    return HabitView(
      habit: h,
      schedules: schedulesByHabit[id] ?? const [],
      dayState: stateFor(id),
      nextOccurrence: nextOccurrence[id],
      cueHabit: h.cueHabitId != null ? byId[h.cueHabitId] : null,
      children: childViews,
      depth: depth,
    );
  }

  return [
    for (final id in rootIds)
      if (!visited.contains(id)) buildView(id, 0),
  ];
}

final habitCompletionProvider =
    FutureProvider.family<List<HabitCompletion>, int>((ref, habitId) async {
      final db = ref.read(appDataBaseProvider);
      return db.habitDao.getAllHabitCompletions(habitId);
    });
