import 'package:aday/domain/models/activity_event.dart';
import 'package:aday/domain/models/goal.dart';
import 'package:aday/domain/services/statistics_service.dart';
import 'package:flutter_test/flutter_test.dart';

Goal _goal(String id, DateTime day, GoalStatus status) {
  return Goal(
    id: id,
    title: id,
    kind: GoalKind.daily,
    startDate: day,
    status: status,
    createdAt: day,
    updatedAt: day,
  );
}

void main() {
  test('calculates weekly rates and consecutive daily reviews', () {
    final anchor = DateTime(2026, 9, 9);
    final service = const StatisticsService();
    final stats = service.calculate(
      goals: [
        _goal('a', DateTime(2026, 9, 7), GoalStatus.completed),
        _goal('b', DateTime(2026, 9, 8), GoalStatus.postponed),
        _goal('c', DateTime(2026, 9, 9), GoalStatus.cancelled),
      ],
      events: [
        ActivityEvent(
          id: 'e1',
          type: ActivityType.dailyReviewCompleted,
          occurredAt: DateTime(2026, 9, 9, 21),
        ),
        ActivityEvent(
          id: 'e2',
          type: ActivityType.dailyReviewCompleted,
          occurredAt: DateTime(2026, 9, 8, 21),
        ),
      ],
      period: StatisticsPeriod.week,
      anchor: anchor,
    );

    expect(stats.total, 3);
    expect(stats.completed, 1);
    expect(stats.postponed, 1);
    expect(stats.cancelled, 1);
    expect(stats.completionRate, closeTo(1 / 3, 0.0001));
    expect(stats.currentStreak, 2);
    expect(stats.trend, hasLength(7));
  });
}
