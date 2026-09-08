abstract interface class DailyReminderScheduler {
  Future<void> initialize();

  Future<bool> requestPermission();

  Future<bool> notificationsEnabled();

  Future<void> scheduleDailyReview({required int minuteOfDay});

  Future<void> showTestNotification();

  Future<void> cancelDailyReview();
}
