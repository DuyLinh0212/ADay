import '../domain/models/app_settings.dart';
import '../domain/services/daily_reminder_scheduler.dart';
import 'aday_controller.dart';

class SettingsService {
  const SettingsService({
    required ADayController controller,
    required DailyReminderScheduler reminderScheduler,
  }) : _controller = controller,
       _reminderScheduler = reminderScheduler;

  final ADayController _controller;
  final DailyReminderScheduler _reminderScheduler;

  Future<bool> enableDailyReview({int minuteOfDay = 21 * 60 + 45}) async {
    final allowed = await _reminderScheduler.requestPermission();
    if (allowed) {
      await _reminderScheduler.scheduleDailyReview(minuteOfDay: minuteOfDay);
    }
    final settings = _controller.settings.copyWith(
      dailyReviewEnabled: allowed,
      dailyReviewMinute: minuteOfDay,
      notificationsAllowed: allowed,
    );
    await _controller.updateSettings(settings);
    return allowed;
  }

  Future<void> disableDailyReview() async {
    await _reminderScheduler.cancelDailyReview();
    await _controller.updateSettings(
      _controller.settings.copyWith(dailyReviewEnabled: false),
    );
  }

  Future<void> restoreSchedule() async {
    final AppSettings settings = _controller.settings;
    if (settings.dailyReviewEnabled && settings.notificationsAllowed) {
      await _reminderScheduler.scheduleDailyReview(
        minuteOfDay: settings.dailyReviewMinute,
      );
    }
  }
}
