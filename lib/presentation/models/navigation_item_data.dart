import 'package:flutter/material.dart';

/// Presentation DTO for an item in the ADay bottom navigation bar.
@immutable
class NavigationItemData {
  const NavigationItemData({
    required this.label,
    required this.icon,
    this.activeIcon,
    this.badgeCount,
    this.semanticsLabel,
  });

  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final int? badgeCount;
  final String? semanticsLabel;

  /// Default 4 tabs for ADay matching DESIGN.md:
  /// Trang chủ, Lịch, Thống kê, Hồ sơ.
  static const List<NavigationItemData> defaultItems = [
    NavigationItemData(
      label: 'Trang chủ',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      semanticsLabel: 'Trang chủ, mục 1 trong 4',
    ),
    NavigationItemData(
      label: 'Lịch',
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_month_rounded,
      semanticsLabel: 'Lịch, mục 2 trong 4',
    ),
    NavigationItemData(
      label: 'Thống kê',
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      semanticsLabel: 'Thống kê, mục 3 trong 4',
    ),
    NavigationItemData(
      label: 'Hồ sơ',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      semanticsLabel: 'Hồ sơ, mục 4 trong 4',
    ),
  ];

  NavigationItemData copyWith({
    String? label,
    IconData? icon,
    IconData? activeIcon,
    int? badgeCount,
    String? semanticsLabel,
  }) {
    return NavigationItemData(
      label: label ?? this.label,
      icon: icon ?? this.icon,
      activeIcon: activeIcon ?? this.activeIcon,
      badgeCount: badgeCount ?? this.badgeCount,
      semanticsLabel: semanticsLabel ?? this.semanticsLabel,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavigationItemData &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          icon == other.icon &&
          activeIcon == other.activeIcon &&
          badgeCount == other.badgeCount &&
          semanticsLabel == other.semanticsLabel;

  @override
  int get hashCode =>
      Object.hash(label, icon, activeIcon, badgeCount, semanticsLabel);
}
