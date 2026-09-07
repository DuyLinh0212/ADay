import 'dart:convert';

import 'package:aday/domain/models/activity_event.dart';
import 'package:aday/domain/models/aday_snapshot.dart';
import 'package:aday/domain/models/goal.dart';
import 'package:aday/domain/models/task_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('snapshot round-trips Vietnamese content and status history', () {
    final now = DateTime(2026, 9, 7, 21, 45);
    final original = ADaySnapshot(
      goals: [
        Goal(
          id: 'goal-1',
          title: 'Chuẩn bị kế hoạch ngày mai',
          kind: GoalKind.daily,
          startDate: now,
          createdAt: now,
          updatedAt: now,
          tasks: [
            TaskItem(
              id: 'task-1',
              title: 'Tổng kết hôm nay',
              scheduledDate: now,
              startMinute: 21 * 60 + 45,
              endMinute: 22 * 60,
            ),
          ],
        ),
      ],
      events: [
        ActivityEvent(
          id: 'event-1',
          type: ActivityType.goalCreated,
          occurredAt: now,
          goalId: 'goal-1',
        ),
      ],
    );

    final decoded = ADaySnapshot.fromJson(
      Map<String, Object?>.from(
        jsonDecode(jsonEncode(original.toJson())) as Map,
      ),
    );

    expect(decoded.goals.single.title, 'Chuẩn bị kế hoạch ngày mai');
    expect(decoded.goals.single.tasks.single.startMinute, 1305);
    expect(decoded.events.single.type, ActivityType.goalCreated);
  });
}
