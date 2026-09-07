import 'package:flutter/material.dart';

/// Type of goal: daily habit/goal or long-term objective.
enum CreateGoalType {
  daily(
    'Mục tiêu hằng ngày',
    'Tạo thói quen tốt, hoàn thành mỗi ngày để tiến bộ hơn.',
  ),
  longTerm(
    'Mục tiêu dài hạn',
    'Xây dựng mục tiêu dài hạn, chia nhỏ thành các bước rõ ràng.',
  );

  const CreateGoalType(this.label, this.description);
  final String label;
  final String description;
}

/// Priority levels for a goal.
enum GoalPriority {
  high('Cao', Icons.flag_rounded, Color(0xFFF0525E)),
  medium('Trung bình', Icons.flag_outlined, Color(0xFFFFB52E)),
  low('Thấp', Icons.outlined_flag_rounded, Color(0xFF6683A5));

  const GoalPriority(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

/// An immutable sub-task item inside a goal being created or edited.
@immutable
class CreateGoalTaskItem {
  const CreateGoalTaskItem({
    required this.id,
    required this.title,
    this.isAllDay = true,
    this.startMinute,
    this.endMinute,
  });

  final String id;
  final String title;
  final bool isAllDay;
  final int? startMinute;
  final int? endMinute;

  /// Formatted time string representation (e.g. "08:00 – 09:00" or "Cả ngày").
  String get timeLabel {
    if (isAllDay || startMinute == null) {
      return 'Cả ngày';
    }
    final startH = (startMinute! ~/ 60).toString().padLeft(2, '0');
    final startM = (startMinute! % 60).toString().padLeft(2, '0');
    if (endMinute != null) {
      final endH = (endMinute! ~/ 60).toString().padLeft(2, '0');
      final endM = (endMinute! % 60).toString().padLeft(2, '0');
      return '$startH:$startM – $endH:$endM';
    }
    return '$startH:$startM';
  }

  CreateGoalTaskItem copyWith({
    String? id,
    String? title,
    bool? isAllDay,
    int? startMinute,
    int? endMinute,
  }) {
    return CreateGoalTaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isAllDay: isAllDay ?? this.isAllDay,
      startMinute: startMinute ?? this.startMinute,
      endMinute: endMinute ?? this.endMinute,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateGoalTaskItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          isAllDay == other.isAllDay &&
          startMinute == other.startMinute &&
          endMinute == other.endMinute;

  @override
  int get hashCode => Object.hash(id, title, isAllDay, startMinute, endMinute);
}

/// Immutable form value submitted by [CreateGoalScreen].
@immutable
class CreateGoalFormValue {
  const CreateGoalFormValue({
    required this.goalType,
    required this.title,
    this.description = '',
    required this.category,
    this.priority = GoalPriority.medium,
    required this.startDate,
    this.endDate,
    this.hasReminder = true,
    this.reminderMinute = 480, // Default 08:00 (8 * 60)
    this.isRepeating = true,
    this.tasks = const [],
  });

  final CreateGoalType goalType;
  final String title;
  final String description;
  final String category;
  final GoalPriority priority;
  final DateTime startDate;
  final DateTime? endDate;
  final bool hasReminder;
  final int? reminderMinute;
  final bool isRepeating;
  final List<CreateGoalTaskItem> tasks;

  /// Formatted reminder time string (e.g. "08:00").
  String get reminderTimeLabel {
    if (reminderMinute == null) return '08:00';
    final h = (reminderMinute! ~/ 60).toString().padLeft(2, '0');
    final m = (reminderMinute! % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  CreateGoalFormValue copyWith({
    CreateGoalType? goalType,
    String? title,
    String? description,
    String? category,
    GoalPriority? priority,
    DateTime? startDate,
    DateTime? endDate,
    bool? hasReminder,
    int? reminderMinute,
    bool? isRepeating,
    List<CreateGoalTaskItem>? tasks,
  }) {
    return CreateGoalFormValue(
      goalType: goalType ?? this.goalType,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      isRepeating: isRepeating ?? this.isRepeating,
      tasks: tasks ?? this.tasks,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateGoalFormValue &&
          runtimeType == other.runtimeType &&
          goalType == other.goalType &&
          title == other.title &&
          description == other.description &&
          category == other.category &&
          priority == other.priority &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          hasReminder == other.hasReminder &&
          reminderMinute == other.reminderMinute &&
          isRepeating == other.isRepeating &&
          _listEquals(tasks, other.tasks);

  @override
  int get hashCode => Object.hash(
    goalType,
    title,
    description,
    category,
    priority,
    startDate,
    endDate,
    hasReminder,
    reminderMinute,
    isRepeating,
    Object.hashAll(tasks),
  );

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
