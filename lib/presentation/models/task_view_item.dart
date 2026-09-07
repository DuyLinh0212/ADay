import 'package:flutter/material.dart';

import '../../core/theme/aday_colors.dart';
import '../../domain/models/goal.dart';
import '../../domain/models/task_item.dart';

/// Immutable presentation DTO for displaying a task or daily goal row.
///
/// Designed for accessible, resilient rendering in lists and section surfaces.
@immutable
class TaskViewItem {
  const TaskViewItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.category,
    this.icon = Icons.check_circle_outline,
    this.iconColor = ADayColors.brandNavy,
    this.iconBackgroundColor = ADayColors.coolSurface,
    this.status = TaskStatus.pending,
    this.timeLabel,
    this.isAllDay = true,
    this.isOverdue = false,
    this.completedAt,
    this.goalId,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? category;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final TaskStatus status;
  final String? timeLabel;
  final bool isAllDay;
  final bool isOverdue;
  final DateTime? completedAt;
  final String? goalId;

  bool get isCompleted => status == TaskStatus.completed;
  bool get isPending => status == TaskStatus.pending;
  bool get isPostponed => status == TaskStatus.postponed;
  bool get isCancelled => status == TaskStatus.cancelled;

  /// Creates a [TaskViewItem] from domain [TaskItem] with optional contextual metadata.
  factory TaskViewItem.fromDomain({
    required TaskItem task,
    String? category,
    String? goalTitle,
    String? goalId,
    IconData? icon,
    Color? iconColor,
    Color? iconBackgroundColor,
    bool isOverdue = false,
  }) {
    String? timeStr;
    if (task.isAllDay) {
      timeStr = 'Cả ngày';
    } else if (task.startMinute != null) {
      final startH = (task.startMinute! ~/ 60).toString().padLeft(2, '0');
      final startM = (task.startMinute! % 60).toString().padLeft(2, '0');
      if (task.endMinute != null) {
        final endH = (task.endMinute! ~/ 60).toString().padLeft(2, '0');
        final endM = (task.endMinute! % 60).toString().padLeft(2, '0');
        timeStr = '$startH:$startM – $endH:$endM';
      } else {
        timeStr = '$startH:$startM';
      }
    }

    final cat = category ?? 'Chung';
    final resolvedIcon = icon ?? _resolveCategoryIcon(cat);
    final resolvedColors = _resolveCategoryPalette(cat);

    return TaskViewItem(
      id: task.id,
      title: task.title,
      subtitle: task.note.isNotEmpty ? task.note : (category ?? goalTitle),
      category: category,
      icon: resolvedIcon,
      iconColor: iconColor ?? resolvedColors.$1,
      iconBackgroundColor: iconBackgroundColor ?? resolvedColors.$2,
      status: task.status,
      timeLabel: timeStr,
      isAllDay: task.isAllDay,
      isOverdue: isOverdue,
      completedAt: task.completedAt,
      goalId: goalId,
    );
  }

  /// Creates a [TaskViewItem] from a daily [Goal].
  factory TaskViewItem.fromGoal(Goal goal, {bool isOverdue = false}) {
    final resolvedIcon = _resolveCategoryIcon(goal.category);
    final resolvedColors = _resolveCategoryPalette(goal.category);

    String? timeStr;
    if (goal.reminderMinute != null) {
      final h = (goal.reminderMinute! ~/ 60).toString().padLeft(2, '0');
      final m = (goal.reminderMinute! % 60).toString().padLeft(2, '0');
      timeStr = '$h:$m';
    } else {
      timeStr = 'Cả ngày';
    }

    TaskStatus taskStatus = TaskStatus.pending;
    switch (goal.status) {
      case GoalStatus.completed:
        taskStatus = TaskStatus.completed;
      case GoalStatus.postponed:
        taskStatus = TaskStatus.postponed;
      case GoalStatus.cancelled:
        taskStatus = TaskStatus.cancelled;
      case GoalStatus.active:
        taskStatus = TaskStatus.pending;
    }

    return TaskViewItem(
      id: goal.id,
      title: goal.title,
      subtitle: goal.description.isNotEmpty ? goal.description : goal.category,
      category: goal.category,
      icon: resolvedIcon,
      iconColor: resolvedColors.$1,
      iconBackgroundColor: resolvedColors.$2,
      status: taskStatus,
      timeLabel: timeStr,
      isAllDay: goal.reminderMinute == null,
      isOverdue: isOverdue,
      completedAt: goal.completedAt,
      goalId: goal.id,
    );
  }

  static IconData _resolveCategoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('sách') ||
        lower.contains('đọc') ||
        lower.contains('học')) {
      return Icons.menu_book_rounded;
    }
    if (lower.contains('dục') ||
        lower.contains('thể thao') ||
        lower.contains('sức khỏe')) {
      return Icons.fitness_center_rounded;
    }
    if (lower.contains('họp') ||
        lower.contains('nhóm') ||
        lower.contains('bạn')) {
      return Icons.people_alt_rounded;
    }
    if (lower.contains('báo cáo') ||
        lower.contains('tài liệu') ||
        lower.contains('viết')) {
      return Icons.description_rounded;
    }
    if (lower.contains('code') ||
        lower.contains('flutter') ||
        lower.contains('lập trình')) {
      return Icons.code_rounded;
    }
    if (lower.contains('thiền') ||
        lower.contains('tâm trí') ||
        lower.contains('nghỉ ngơi')) {
      return Icons.spa_rounded;
    }
    return Icons.task_alt_rounded;
  }

  static (Color, Color) _resolveCategoryPalette(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('sách') || lower.contains('đọc')) {
      return (const Color(0xFF168AF2), const Color(0xFFE8F3FD));
    }
    if (lower.contains('dục') || lower.contains('thể thao')) {
      return (const Color(0xFF0EB8AC), const Color(0xFFE6F8F7));
    }
    if (lower.contains('họp') || lower.contains('nhóm')) {
      return (const Color(0xFF7A5AF8), const Color(0xFFF4F0FD));
    }
    if (lower.contains('báo cáo') || lower.contains('viết')) {
      return (const Color(0xFF20C99A), const Color(0xFFEAF9F5));
    }
    if (lower.contains('code') || lower.contains('flutter')) {
      return (const Color(0xFF168AF2), const Color(0xFFE8F3FD));
    }
    if (lower.contains('thiền') || lower.contains('tâm trí')) {
      return (const Color(0xFFFF9E2C), const Color(0xFFFFF6EB));
    }
    return (ADayColors.brandNavy, ADayColors.coolSurface);
  }

  TaskViewItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? category,
    IconData? icon,
    Color? iconColor,
    Color? iconBackgroundColor,
    TaskStatus? status,
    String? timeLabel,
    bool? isAllDay,
    bool? isOverdue,
    DateTime? completedAt,
    String? goalId,
  }) {
    return TaskViewItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      iconBackgroundColor: iconBackgroundColor ?? this.iconBackgroundColor,
      status: status ?? this.status,
      timeLabel: timeLabel ?? this.timeLabel,
      isAllDay: isAllDay ?? this.isAllDay,
      isOverdue: isOverdue ?? this.isOverdue,
      completedAt: completedAt ?? this.completedAt,
      goalId: goalId ?? this.goalId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskViewItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          subtitle == other.subtitle &&
          category == other.category &&
          icon == other.icon &&
          iconColor == other.iconColor &&
          iconBackgroundColor == other.iconBackgroundColor &&
          status == other.status &&
          timeLabel == other.timeLabel &&
          isAllDay == other.isAllDay &&
          isOverdue == other.isOverdue &&
          completedAt == other.completedAt &&
          goalId == other.goalId;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    subtitle,
    category,
    icon,
    iconColor,
    iconBackgroundColor,
    status,
    timeLabel,
    isAllDay,
    isOverdue,
    completedAt,
    goalId,
  );
}
