// ignore_for_file: use_null_aware_elements

import 'dart:io';

import 'package:flutter/foundation.dart';
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
    int? percent,
    String? dateLabel,
    String? task1Title,
    bool? task1Done,
    String? task1Time,
    String? task2Title,
    bool? task2Done,
    String? task2Time,
    String? task3Title,
    bool? task3Done,
    String? task3Time,
  }) async {
    if (kIsWeb || !Platform.isAndroid) return;
    await _channel.invokeMethod<void>('updateWidget', {
      'themeId': themeId,
      'taskCount': taskCount,
      'completedCount': completedCount,
      if (percent != null) 'percent': percent,
      if (dateLabel != null) 'dateLabel': dateLabel,
      if (task1Title != null) 'task1Title': task1Title,
      if (task1Done != null) 'task1Done': task1Done,
      if (task1Time != null) 'task1Time': task1Time,
      if (task2Title != null) 'task2Title': task2Title,
      if (task2Done != null) 'task2Done': task2Done,
      if (task2Time != null) 'task2Time': task2Time,
      if (task3Title != null) 'task3Title': task3Title,
      if (task3Done != null) 'task3Done': task3Done,
      if (task3Time != null) 'task3Time': task3Time,
    });
  }

  static Future<bool> requestPin() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    return await _channel.invokeMethod<bool>('requestPin') ?? false;
  }

  static Future<void> setLauncherIcon(String themeId) async {
    if (kIsWeb || !Platform.isAndroid) return;
    await _channel.invokeMethod<void>('setLauncherIcon', {'themeId': themeId});
  }
}
