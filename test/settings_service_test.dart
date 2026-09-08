import 'package:aday/application/aday_controller.dart';
import 'package:aday/application/settings_service.dart';
import 'package:aday/domain/models/aday_snapshot.dart';
import 'package:aday/domain/repositories/aday_repository.dart';
import 'package:aday/domain/services/daily_reminder_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryRepository implements ADayRepository {
  ADaySnapshot value = const ADaySnapshot();

  @override
  Future<ADaySnapshot> load() async => value;

  @override
  Future<void> save(ADaySnapshot snapshot) async => value = snapshot;
}

class _FakeReminderScheduler implements DailyReminderScheduler {
  bool permissionGranted = true;
  bool enabled = true;
  int? scheduledMinute;
  int testNotificationCount = 0;

  @override
  Future<void> cancelDailyReview() async => scheduledMinute = null;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> notificationsEnabled() async => enabled;

  @override
  Future<bool> requestPermission() async => permissionGranted;

  @override
  Future<void> scheduleDailyReview({required int minuteOfDay}) async {
    scheduledMinute = minuteOfDay;
  }

  @override
  Future<void> showTestNotification() async => testNotificationCount++;
}

void main() {
  test('persists permission only after the platform grants it', () async {
    final controller = ADayController(repository: _MemoryRepository());
    await controller.initialize();
    final scheduler = _FakeReminderScheduler()..permissionGranted = false;
    final service = SettingsService(
      controller: controller,
      reminderScheduler: scheduler,
    );

    final allowed = await service.enableDailyReview(minuteOfDay: 20 * 60);

    expect(allowed, isFalse);
    expect(controller.settings.notificationsAllowed, isFalse);
    expect(controller.settings.dailyReviewEnabled, isFalse);
    expect(scheduler.scheduledMinute, isNull);
  });

  test(
    'restore disables a stale granted flag after system revocation',
    () async {
      final controller = ADayController(repository: _MemoryRepository());
      await controller.initialize();
      await controller.updateSettings(
        controller.settings.copyWith(
          notificationsAllowed: true,
          dailyReviewEnabled: true,
        ),
      );
      final scheduler = _FakeReminderScheduler()..enabled = false;
      final service = SettingsService(
        controller: controller,
        reminderScheduler: scheduler,
      );

      await service.restoreSchedule();

      expect(controller.settings.notificationsAllowed, isFalse);
      expect(controller.settings.dailyReviewEnabled, isFalse);
      expect(scheduler.scheduledMinute, isNull);
    },
  );
}
