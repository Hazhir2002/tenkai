import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:tenkai/core/design_system/tenkai.dart';

abstract final class TenkaiNotifications {
  static const String _channelKey = 'tenkai_reminders';
  static const String _knowledgeChannelKey = 'knowledge_reminders';

  static const int _welcomeId = 1;
  static const int _programSessionId = 10;
  static const int _habitId = 100;
  static const int _readingReminderId = 100000;

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      await AwesomeNotifications().initialize(null, [
        NotificationChannel(
          channelKey: _channelKey,
          channelName: 'Tenkai Reminders',
          channelDescription: 'reminders from tenkai',
          importance: NotificationImportance.High,
          defaultColor: TenkaiSemanticColors.dark.primary,
          ledColor: TenkaiSemanticColors.dark.primary,
          playSound: true,
        ),
        NotificationChannel(
          channelKey: _knowledgeChannelKey,
          channelName: 'Knowledge Reminders',
          channelDescription: 'reminders from tenkai knowledge',
          importance: NotificationImportance.Default,
          defaultColor: TenkaiSemanticColors.dark.primary,
          ledColor: TenkaiSemanticColors.dark.primary,
          playSound: true,
        ),
      ], debug: kDebugMode);
      _initialized = true;
    } catch (err) {
      debugPrint('[TenkaiNotifications] ❌ init failed: $err');
    }
  }

  static Future<bool> ensurePermission() async {
    try {
      final allowed = await AwesomeNotifications().isNotificationAllowed();
      if (allowed) return true;
      return AwesomeNotifications().requestPermissionToSendNotifications();
    } catch (err) {
      debugPrint('[TenkaiNotifications] ❌ permission check failed: $err');
      return false;
    }
  }

  static Future<void> showWelcome() async {
    await _create(
      id: _welcomeId,
      title: 'Welcome',
      body: 'Tenkai will be your assistant from now on',
    );
  }

  static Future<void> scheduleHabitReminder({
    required int id,
    required int hour,
    int minute = 0,
    required String title,
    required String body,
  }) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id * _habitId,
          channelKey: _channelKey,
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
          wakeUpScreen: true,
        ),
        schedule: NotificationCalendar(
          hour: hour,
          minute: minute,
          second: 0,
          millisecond: 0,
          repeats: true,
          allowWhileIdle: true,
        ),
      );
      debugPrint(
        '[TenkaiNotifications] created habit reminder hour: $hour:$minute',
      );
    } catch (err) {
      debugPrint('[TenkaiNotifications] ❌ schedule($_habitId) failed: $err');
    }
  }

  static Future<void> scheduleProgramSessionReminder({
    required int id,
    required int dayOfWeek,
    required int hour,
    int minute = 0,
    required String title,
    required String body,
  }) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id * _programSessionId,
          channelKey: _channelKey,
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
          wakeUpScreen: true,
        ),
        schedule: NotificationCalendar(
          hour: hour,
          minute: minute,
          second: 0,
          millisecond: 0,
          weekday: dayOfWeek,
          repeats: true,
          allowWhileIdle: true,
        ),
      );
      debugPrint(
        '[TenkaiNotifications] created hour: $hour:$minute on $dayOfWeek',
      );
    } catch (err) {
      debugPrint(
        '[TenkaiNotifications] ❌ schedule($_programSessionId) failed: $err',
      );
    }
  }

  static Future<void> deleteProgramSessionReminder({required int id}) async {
    try {
      await AwesomeNotifications().cancel(id * _programSessionId);
      debugPrint('[TenkaiNotifications] deleted notification with id $id');
    } catch (err) {
      debugPrint('[TenkaiNotifications] ❌ delete reminder failed: $err');
    }
  }

  static Future<void> scheduleReadingSessionReminder({
    required int id,
    required int hour,
    int minute = 0,
    required String bookTitle,
  }) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id + _readingReminderId,
          channelKey: _knowledgeChannelKey,
          title: 'Time to read',
          body: 'Expand your knowledge by reading $bookTitle',
          notificationLayout: NotificationLayout.Default,
          wakeUpScreen: true,
        ),
        schedule: NotificationCalendar(
          hour: hour,
          minute: minute,
          second: 0,
          millisecond: 0,
          repeats: true,
          allowWhileIdle: true,
        ),
      );
      debugPrint(
        '[TenkaiNotifications] created reading reminder: $hour:$minute',
      );
    } catch (err) {
      debugPrint(
        '[TenkaiNotifications] ❌ schedule($_readingReminderId) failed: $err',
      );
    }
  }

  static Future<void> deleteReadingSessionReminder({required int id}) async {
    try {
      await AwesomeNotifications().cancel(id + _readingReminderId);
      debugPrint('[TenkaiNotifications] deleted notification with id $id');
    } catch (err) {
      debugPrint('[TenkaiNotifications] ❌ delete reminder failed: $err');
    }
  }

  static Future<void> _create({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: _channelKey,
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
        ),
      );
    } catch (err) {
      debugPrint('[TenkaiNotifications] ❌ create($id) failed: $err');
    }
  }
}
