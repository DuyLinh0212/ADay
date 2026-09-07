import 'package:flutter/material.dart';

/// Presentation model for ProfileScreen matching media_1788785465312.png.
@immutable
class ProfileViewData {
  const ProfileViewData({
    this.displayName = 'Minh Nguyễn',
    this.email = 'minh.aday@gmail.com',
    this.memberSince = 'Thành viên từ 06/2025',
    this.activeGoalsCount = 3,
    this.completedThisMonthCount = 4,
    this.completionRate = 67,
    this.quote = '“Kế hoạch nhỏ\ntạo nên ngày mai tốt hơn!”',
    this.reminderBefore22Enabled = true,
    this.dailyNotificationEnabled = true,
    this.language = 'Tiếng Việt',
    this.themeMode = 'Sáng',
    this.avatarUrl,
  });

  final String displayName;
  final String email;
  final String memberSince;
  final int activeGoalsCount;
  final int completedThisMonthCount;
  final int completionRate;
  final String quote;
  final bool reminderBefore22Enabled;
  final bool dailyNotificationEnabled;
  final String language;
  final String themeMode;
  final String? avatarUrl;

  /// Sample factory matching the screenshot exactly.
  factory ProfileViewData.sample() {
    return const ProfileViewData();
  }
}
