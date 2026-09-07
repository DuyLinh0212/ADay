import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/services/daily_reminder_scheduler.dart';

class LocalDailyReminderScheduler implements DailyReminderScheduler {
  LocalDailyReminderScheduler({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const dailyReviewNotificationId = 2200;
  static const channelId = 'aday_daily_review';

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;
    tz_data.initializeTimeZones();
    try {
      final local = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(local.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const linux = LinuxInitializationSettings(defaultActionName: 'Mở ADay');
    const windows = WindowsInitializationSettings(
      appName: 'ADay',
      appUserModelId: 'com.ngduylinh.aday',
      guid: 'c7ec9bde-f429-4a8a-92dd-53ce37b93610',
    );
    const settings = InitializationSettings(
      android: android,
      iOS: darwin,
      macOS: darwin,
      linux: linux,
      windows: windows,
    );
    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    await initialize();
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return await _plugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >()
                ?.requestNotificationsPermission() ??
            true;
      case TargetPlatform.iOS:
        return await _plugin
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >()
                ?.requestPermissions(alert: true, badge: true, sound: true) ??
            false;
      case TargetPlatform.macOS:
        return await _plugin
                .resolvePlatformSpecificImplementation<
                  MacOSFlutterLocalNotificationsPlugin
                >()
                ?.requestPermissions(alert: true, badge: true, sound: true) ??
            false;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return true;
    }
  }

  @override
  Future<void> scheduleDailyReview({required int minuteOfDay}) async {
    if (minuteOfDay < 0 || minuteOfDay >= 1440) {
      throw ArgumentError.value(
        minuteOfDay,
        'minuteOfDay',
        'Giá trị phải từ 0 đến 1439.',
      );
    }
    if (kIsWeb) return;
    await initialize();
    final hour = minuteOfDay ~/ 60;
    final minute = minuteOfDay % 60;
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));

    await _plugin.zonedSchedule(
      id: dailyReviewNotificationId,
      title: 'Đừng quên tổng kết hôm nay nhé',
      body: 'Cập nhật tiến độ và dành vài phút lập kế hoạch cho ngày mai.',
      scheduledDate: next,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'Nhắc tổng kết mỗi ngày',
          channelDescription:
              'Nhắc cập nhật tiến độ và lập kế hoạch cho ngày mai trước 22:00.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'aday://plan-tomorrow',
    );
  }

  @override
  Future<void> cancelDailyReview() async {
    if (kIsWeb) return;
    await initialize();
    await _plugin.cancel(id: dailyReviewNotificationId);
  }
}
