import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/aday_app.dart';
import 'application/aday_controller.dart';
import 'application/settings_service.dart';
import 'data/local/sqlite_aday_repository.dart';
import 'data/local/shared_preferences_aday_repository.dart';
import 'data/notifications/local_daily_reminder_scheduler.dart';
import 'domain/repositories/aday_repository.dart';
import 'platform/sqlite_platform_setup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  configureLocalDatabase();
  final ADayRepository repository = kIsWeb
      ? SharedPreferencesADayRepository(preferences)
      : SqliteADayRepository(legacyPreferences: preferences);
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
