import '../domain/models/goal.dart';

class TaskDraft {
  const TaskDraft({
    required this.title,
    this.note = '',
    this.startMinute,
    this.endMinute,
  });

  final String title;
  final String note;
  final int? startMinute;
  final int? endMinute;
}

class GoalDraft {
  const GoalDraft({
    required this.title,
    required this.kind,
    required this.startDate,
    this.description = '',
    this.category = 'Khác',
    this.priority = GoalPriority.medium,
    this.deadline,
    this.reminderEnabled = false,
    this.reminderMinute,
    this.repeatDaily = false,
    this.tasks = const [],
  });

  final String title;
  final String description;
  final String category;
  final GoalKind kind;
  final GoalPriority priority;
  final DateTime startDate;
  final DateTime? deadline;
  final bool reminderEnabled;
  final int? reminderMinute;
  final bool repeatDaily;
  final List<TaskDraft> tasks;
}
