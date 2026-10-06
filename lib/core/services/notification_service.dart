// import 'package:/awesome_notifications.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:tenkai/core/database.dart';
// import 'package:tenkai/core/design_system/tenkai.dart';
// import 'package:tenkai/features/habit_tracker/models/habit_enums.dart';

// /// Wraps [AwesomeNotifications] for the habit tracker: scheduling repeating
// /// reminders for time-cued habits and one-shot reminders once a cue habit is
// /// completed.
// ///
// /// Every call is guarded — awesome_notifications has no official macOS support,
// /// so on unsupported platforms [initialize] flips [_available] to false and all
// /// operations become no-ops rather than crashing the app.
// class NotificationService {
//   static const String _channelKey = 'habits';
//   static const String _readingChannelKey = 'reading';

//   final AwesomeNotifications _plugin = AwesomeNotifications();
//   bool _available = true;

//   /// Notifications for one habit are grouped so they can be cancelled together.
//   String _groupKey(int habitId) => 'habit_$habitId';

//   /// Deterministic id base for a habit's scheduled notifications. Slot `i`
//   /// uses `base + i`; the after-cue one-shot uses `base + 900`.
//   int _baseId(int habitId) => habitId * 1000;

//   /// Book reminders live in a disjoint id namespace so they never collide with
//   /// habit ids (`habitId * 1000`).
//   String _bookGroupKey(int bookId) => 'book_$bookId';
//   int _bookReminderId(int bookId) => 2000000 + bookId;

//   Future<void> initialize() async {
//     try {
//       await _plugin.initialize(null, [
//         NotificationChannel(
//           channelKey: _channelKey,
//           channelName: 'Habits',
//           channelDescription: 'Reminders for your habits and routines',
//           importance: NotificationImportance.High,
//           defaultColor: TenkaiColors.white,
//           ledColor: TenkaiColors.white,
//           playSound: true,
//         ),
//         NotificationChannel(
//           channelKey: _readingChannelKey,
//           channelName: 'Reading',
//           channelDescription: 'Reminders to read your books',
//           importance: NotificationImportance.High,
//           defaultColor: TenkaiColors.white,
//           ledColor: TenkaiColors.white,
//           playSound: true,
//         ),
//       ], debug: false);
//     } catch (_) {
//       _available = false;
//     }
//   }

//   /// Ensures notification permission, prompting the user if it hasn't been
//   /// granted yet. Returns whether notifications are allowed.
//   Future<bool> requestPermissionIfNeeded() async {
//     if (!_available) return false;
//     try {
//       if (await _plugin.isNotificationAllowed()) return true;
//       return await _plugin.requestPermissionToSendNotifications();
//     } catch (_) {
//       return false;
//     }
//   }

//   /// Rebuilds the scheduled reminders for [habit]: cancels any existing ones,
//   /// then (for time-cued habits with reminders enabled) schedules one repeating
//   /// notification per [schedules] slot. After-habit cues are not time-based, so
//   /// they are scheduled on completion via [scheduleAfterCueReminders].
//   Future<void> syncHabit(Habit habit, List<HabitSchedule> schedules) async {
//     if (!_available) return;
//     await cancelHabit(habit.id);
//     if (!habit.reminderEnabled) return;
//     if (HabitCueType.fromDb(habit.cueType) != HabitCueType.time) return;

//     var i = 0;
//     for (final s in schedules) {
//       final id = _baseId(habit.id) + i;
//       i++;
//       try {
//         await _plugin.createNotification(
//           content: NotificationContent(
//             id: id,
//             channelKey: _channelKey,
//             groupKey: _groupKey(habit.id),
//             title: habit.title,
//             body: habit.description ?? 'Time for your habit.',
//             category: NotificationCategory.Reminder,
//             wakeUpScreen: true,
//           ),
//           schedule: NotificationCalendar(
//             weekday: s.weekday, // null => every day
//             hour: s.hour,
//             minute: s.minute,
//             second: 0,
//             millisecond: 0,
//             repeats: true,
//             preciseAlarm: true,
//             allowWhileIdle: true,
//           ),
//         );
//       } catch (_) {
//         // Ignore individual scheduling failures (e.g. permission revoked).
//       }
//     }
//   }

//   /// When [completedHabitId] is finished, schedules a one-shot reminder for each
//   /// habit stacked after it (cueType afterHabit), fired at `now + offset`.
//   Future<void> scheduleAfterCueReminders(
//     int completedHabitId,
//     List<Habit> allHabits, {
//     DateTime? now,
//   }) async {
//     if (!_available) return;
//     final base = now ?? DateTime.now();
//     for (final h in allHabits) {
//       if (HabitCueType.fromDb(h.cueType) != HabitCueType.afterHabit) continue;
//       if (h.cueHabitId != completedHabitId) continue;
//       if (!h.reminderEnabled) continue;

//       final fireAt = base.add(Duration(minutes: h.reminderOffsetMinutes));
//       try {
//         await _plugin.createNotification(
//           content: NotificationContent(
//             id: _baseId(h.id) + 900,
//             channelKey: _channelKey,
//             groupKey: _groupKey(h.id),
//             title: h.title,
//             body:
//                 h.description ??
//                 'You just finished your cue — time to stack this.',
//             category: NotificationCategory.Reminder,
//             wakeUpScreen: true,
//           ),
//           schedule: NotificationCalendar.fromDate(
//             date: fireAt,
//             preciseAlarm: true,
//           ),
//         );
//       } catch (_) {
//         // Ignore.
//       }
//     }
//   }

//   Future<void> cancelHabit(int habitId) async {
//     if (!_available) return;
//     try {
//       await _plugin.cancelSchedulesByGroupKey(_groupKey(habitId));
//       await _plugin.cancelNotificationsByGroupKey(_groupKey(habitId));
//     } catch (_) {
//       // Ignore.
//     }
//   }

//   // ---- Book reading reminders ----

//   /// Rebuilds the daily reading reminder for [book]: cancels any existing one,
//   /// then (if enabled with a time set and the book isn't finished) schedules a
//   /// repeating daily notification at the chosen time.
//   Future<void> syncBookReminder(Book book) async {
//     if (!_available) return;
//     await cancelBook(book.id);
//     if (!book.reminderEnabled) return;
//     if (book.reminderHour == null || book.reminderMinute == null) return;
//     if (book.status == 'finished') return;

//     final pagesLeft = (book.totalPages - book.currentPage).clamp(
//       0,
//       book.totalPages,
//     );
//     try {
//       await _plugin.createNotification(
//         content: NotificationContent(
//           id: _bookReminderId(book.id),
//           channelKey: _readingChannelKey,
//           groupKey: _bookGroupKey(book.id),
//           title: 'Time to read',
//           body: pagesLeft > 0
//               ? '${book.title} — $pagesLeft pages left.'
//               : book.title,
//           category: NotificationCategory.Reminder,
//           wakeUpScreen: true,
//         ),
//         schedule: NotificationCalendar(
//           weekday: null, // every day
//           hour: book.reminderHour,
//           minute: book.reminderMinute,
//           second: 0,
//           millisecond: 0,
//           repeats: true,
//           preciseAlarm: true,
//           allowWhileIdle: true,
//         ),
//       );
//     } catch (_) {
//       // Ignore individual scheduling failures.
//     }
//   }

//   Future<void> cancelBook(int bookId) async {
//     if (!_available) return;
//     try {
//       await _plugin.cancelSchedulesByGroupKey(_bookGroupKey(bookId));
//       await _plugin.cancelNotificationsByGroupKey(_bookGroupKey(bookId));
//     } catch (_) {
//       // Ignore.
//     }
//   }
// }

// final notificationServiceProvider = Provider<NotificationService>(
//   (ref) => NotificationService(),
// );
