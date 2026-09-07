import 'dart:io';

import 'package:flutter/services.dart';

/// Small, explicit bridge to Android's AppWidget system. It has only two
/// operations: copy the current summary to the widget and ask Android to pin
/// it. Other platforms safely report that pinning is unavailable.
abstract final class HomeWidgetBridge {
  static const _channel = MethodChannel('com.ngduylinh.aday/home_widget');

  static Future<void> update({
    required String themeId,
    required int taskCount,
    required int completedCount,
  }) async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod<void>('updateWidget', {
      'themeId': themeId,
      'taskCount': taskCount,
      'completedCount': completedCount,
    });
  }

  static Future<bool> requestPin() async {
    if (!Platform.isAndroid) return false;
    return await _channel.invokeMethod<bool>('requestPin') ?? false;
  }

  static Future<void> setLauncherIcon(String themeId) async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod<void>('setLauncherIcon', {'themeId': themeId});
  }
}
