abstract interface class DailyReminderScheduler {
  Future<void> initialize();

  Future<bool> requestPermission();

  Future<void> scheduleDailyReview({required int minuteOfDay});

  Future<void> cancelDailyReview();
}
