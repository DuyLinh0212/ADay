enum ActivityType {
  goalCreated,
  goalCompleted,
  goalPostponed,
  goalCancelled,
  taskCompleted,
  taskReopened,
  taskCarriedForward,
  dailyReviewCompleted,
}

class ActivityEvent {
  const ActivityEvent({
    required this.id,
    required this.type,
    required this.occurredAt,
    this.goalId,
    this.taskId,
    this.reason,
    this.metadata = const {},
  });

  final String id;
  final ActivityType type;
  final DateTime occurredAt;
  final String? goalId;
  final String? taskId;
  final String? reason;
  final Map<String, String> metadata;

  Map<String, Object?> toJson() => {
    'id': id,
    'type': type.name,
    'occurredAt': occurredAt.toIso8601String(),
    'goalId': goalId,
    'taskId': taskId,
    'reason': reason,
    'metadata': metadata,
  };

  factory ActivityEvent.fromJson(Map<String, Object?> json) {
    return ActivityEvent(
      id: json['id']! as String,
      type: ActivityType.values.byName(json['type']! as String),
      occurredAt: DateTime.parse(json['occurredAt']! as String),
      goalId: json['goalId'] as String?,
      taskId: json['taskId'] as String?,
      reason: json['reason'] as String?,
      metadata: Map<String, String>.from(json['metadata'] as Map? ?? const {}),
    );
  }
}
