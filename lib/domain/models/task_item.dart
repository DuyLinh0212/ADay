enum TaskStatus { pending, completed, postponed, cancelled }

class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.scheduledDate,
    this.note = '',
    this.startMinute,
    this.endMinute,
    this.status = TaskStatus.pending,
    this.completedAt,
    this.carriedFromDate,
  });

  final String id;
  final String title;
  final String note;
  final DateTime scheduledDate;
  final int? startMinute;
  final int? endMinute;
  final TaskStatus status;
  final DateTime? completedAt;
  final DateTime? carriedFromDate;

  bool get isAllDay => startMinute == null;

  TaskItem copyWith({
    String? id,
    String? title,
    String? note,
    DateTime? scheduledDate,
    int? startMinute,
    int? endMinute,
    bool clearTime = false,
    TaskStatus? status,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    DateTime? carriedFromDate,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      startMinute: clearTime ? null : startMinute ?? this.startMinute,
      endMinute: clearTime ? null : endMinute ?? this.endMinute,
      status: status ?? this.status,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
      carriedFromDate: carriedFromDate ?? this.carriedFromDate,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'note': note,
    'scheduledDate': scheduledDate.toIso8601String(),
    'startMinute': startMinute,
    'endMinute': endMinute,
    'status': status.name,
    'completedAt': completedAt?.toIso8601String(),
    'carriedFromDate': carriedFromDate?.toIso8601String(),
  };

  factory TaskItem.fromJson(Map<String, Object?> json) {
    return TaskItem(
      id: json['id']! as String,
      title: json['title']! as String,
      note: json['note'] as String? ?? '',
      scheduledDate: DateTime.parse(json['scheduledDate']! as String),
      startMinute: json['startMinute'] as int?,
      endMinute: json['endMinute'] as int?,
      status: TaskStatus.values.byName(
        json['status'] as String? ?? TaskStatus.pending.name,
      ),
      completedAt: _dateOrNull(json['completedAt']),
      carriedFromDate: _dateOrNull(json['carriedFromDate']),
    );
  }
}

DateTime? _dateOrNull(Object? value) {
  return value is String && value.isNotEmpty ? DateTime.parse(value) : null;
}
