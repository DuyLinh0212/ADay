import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/aday_app.dart';
import 'application/aday_controller.dart';
import 'application/settings_service.dart';
import 'data/local/sqlite_aday_repository.dart';
import 'data/notifications/local_daily_reminder_scheduler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final repository = SqliteADayRepository(legacyPreferences: preferences);
  final controller = ADayController(repository: repository);
  await controller.initialize();

  final reminderScheduler = LocalDailyReminderScheduler();
  try {
    await reminderScheduler.initialize();
  } catch (_) {
    // ADay remains usable when notifications are unavailable on a platform.
  }

  runApp(
    ADayApp(
      controller: controller,
      settingsService: SettingsService(
        controller: controller,
        reminderScheduler: reminderScheduler,
      ),
    ),
  );
}
