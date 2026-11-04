import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'settings_helper.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    await _setLocalTimeZone();
    try {
      const android = AndroidInitializationSettings('ic_stat_task');
      const darwin = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const settings = InitializationSettings(android: android, iOS: darwin);
      await _plugin.initialize(settings: settings);
    } catch (_) {
      // Plugin not available (e.g. tests / web); fall through without failing.
    }
    _initialized = true;
  }

  static Future<void> _setLocalTimeZone() async {
    String name;
    try {
      name = (await FlutterTimezone.getLocalTimezone()).identifier;
    } catch (_) {
      name = 'UTC';
    }
    try {
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  static Future<void> requestAndroidPermission() async {
    await init();
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (_) {
      // Permission APIs are unavailable outside Android.
    }
  }

  static Future<void> requestExactAlarmPermission() async {
    await init();
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
    } catch (_) {
      // Permission APIs are unavailable outside Android.
    }
  }

  static Future<void> show({
    required String channelId,
    required String title,
    required String body,
    required int id,
  }) async {
    if (!SettingsHelper.notifications.value) return;
    if (kIsWeb) return;
    await init();
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      } catch (_) {
        // Permission APIs are unavailable outside Android.
      }
    }
    final android = AndroidNotificationDetails(
      channelId,
      'Task updates',
      channelDescription: 'Notifications about your tasks',
      importance: Importance.high,
      priority: Priority.high,
      color: const Color(0xFF2196F3),
    );
    final details = NotificationDetails(android: android);
    try {
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
      );
    } catch (_) {
      // Notification unavailable (e.g. tests); task actions should still work.
    }
  }

  /// Schedules a one-time notification that fires when a task's due date
  /// (date + time) is reached. Uses [id] as the notification id so editing a
  /// task re-schedules (and deleting cancels) cleanly.
  static Future<void> scheduleDueDateReminder({
    required int id,
    required String title,
    required String body,
    required DateTime dueDate,
  }) async {
    if (!SettingsHelper.notifications.value) return;
    if (kIsWeb) return;
    await init();
    await cancel(id);

    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(dueDate, tz.local);
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    const android = AndroidNotificationDetails(
      'task_due',
      'Task due date',
      channelDescription: "Alerts you when a task's due date arrives",
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFFF4511E),
    );
    const darwin = DarwinNotificationDetails();
    const details = NotificationDetails(android: android, iOS: darwin);

    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {
      try {
        await _plugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } catch (_) {
        // No exact-alarm permission; the reminder cannot be scheduled.
      }
    }
  }

  static Future<void> cancel(int id) async {
    if (kIsWeb) return;
    await init();
    try {
      await _plugin.cancel(id: id);
    } catch (_) {
      // Notification unavailable (e.g. tests).
    }
  }
}