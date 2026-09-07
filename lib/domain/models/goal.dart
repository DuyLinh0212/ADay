import 'task_item.dart';

enum GoalKind { daily, longTerm }

enum GoalPriority { low, medium, high }

enum GoalStatus { active, completed, postponed, cancelled }

class Goal {
  const Goal({
    required this.id,
    required this.title,
    required this.kind,
    required this.startDate,
    required this.createdAt,
    required this.updatedAt,
    this.description = '',
    this.category = 'Khác',
    this.priority = GoalPriority.medium,
    this.deadline,
    this.reminderEnabled = false,
    this.reminderMinute,
    bool repeatDaily = false,
    this.status = GoalStatus.active,
    this.tasks = const [],
    this.note = '',
    this.completedAt,
    this.postponedUntil,
    this.statusReason,
    this.recurrenceSourceId,
  }) : repeatDaily = kind == GoalKind.daily && repeatDaily;

  final String id;
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
  final GoalStatus status;
  final List<TaskItem> tasks;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final DateTime? postponedUntil;
  final String? statusReason;
  final String? recurrenceSourceId;

  int get completedTaskCount =>
      tasks.where((task) => task.status == TaskStatus.completed).length;

  double get completionRate => tasks.isEmpty
      ? (status == GoalStatus.completed ? 1 : 0)
      : completedTaskCount / tasks.length;

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    GoalKind? kind,
    GoalPriority? priority,
    DateTime? startDate,
    DateTime? deadline,
    bool clearDeadline = false,
    bool? reminderEnabled,
    int? reminderMinute,
    bool clearReminderMinute = false,
    bool? repeatDaily,
    GoalStatus? status,
    List<TaskItem>? tasks,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    DateTime? postponedUntil,
    bool clearPostponedUntil = false,
    String? statusReason,
    bool clearStatusReason = false,
    String? recurrenceSourceId,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      kind: kind ?? this.kind,
      priority: priority ?? this.priority,
      startDate: startDate ?? this.startDate,
      deadline: clearDeadline ? null : deadline ?? this.deadline,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderMinute: clearReminderMinute
          ? null
          : reminderMinute ?? this.reminderMinute,
      repeatDaily: repeatDaily ?? this.repeatDaily,
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
      postponedUntil: clearPostponedUntil
          ? null
          : postponedUntil ?? this.postponedUntil,
      statusReason: clearStatusReason
          ? null
          : statusReason ?? this.statusReason,
      recurrenceSourceId: recurrenceSourceId ?? this.recurrenceSourceId,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'kind': kind.name,
    'priority': priority.name,
    'startDate': startDate.toIso8601String(),
    'deadline': deadline?.toIso8601String(),
    'reminderEnabled': reminderEnabled,
    'reminderMinute': reminderMinute,
    'repeatDaily': repeatDaily,
    'status': status.name,
    'tasks': tasks.map((task) => task.toJson()).toList(),
    'note': note,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'postponedUntil': postponedUntil?.toIso8601String(),
    'statusReason': statusReason,
    'recurrenceSourceId': recurrenceSourceId,
  };

  factory Goal.fromJson(Map<String, Object?> json) {
    final rawTasks = json['tasks'] as List<Object?>? ?? const [];
    return Goal(
      id: json['id']! as String,
      title: json['title']! as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'Khác',
      kind: GoalKind.values.byName(
        json['kind'] as String? ?? GoalKind.daily.name,
      ),
      priority: GoalPriority.values.byName(
        json['priority'] as String? ?? GoalPriority.medium.name,
      ),
      startDate: DateTime.parse(json['startDate']! as String),
      deadline: _dateOrNull(json['deadline']),
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      reminderMinute: json['reminderMinute'] as int?,
      repeatDaily: json['repeatDaily'] as bool? ?? false,
      status: GoalStatus.values.byName(
        json['status'] as String? ?? GoalStatus.active.name,
      ),
      tasks: rawTasks
          .map(
            (task) =>
                TaskItem.fromJson(Map<String, Object?>.from(task! as Map)),
          )
          .toList(growable: false),
      note: json['note'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt']! as String),
      updatedAt: DateTime.parse(json['updatedAt']! as String),
      completedAt: _dateOrNull(json['completedAt']),
      postponedUntil: _dateOrNull(json['postponedUntil']),
      statusReason: json['statusReason'] as String?,
      recurrenceSourceId: json['recurrenceSourceId'] as String?,
    );
  }
}

DateTime? _dateOrNull(Object? value) {
  return value is String && value.isNotEmpty ? DateTime.parse(value) : null;
}
