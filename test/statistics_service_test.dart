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

  test('calculates deltas compared to previous period', () {
    const service = StatisticsService();
    final anchor = DateTime(2026, 9, 16); // Week of Sept 14-20, previous is Sept 7-13

    final stats = service.calculate(
      goals: [
        // Previous week (Sept 7-13)
        _goal('prev1', DateTime(2026, 9, 7), GoalStatus.completed),
        _goal('prev2', DateTime(2026, 9, 8), GoalStatus.postponed),
        // Current week (Sept 14-20)
        _goal('curr1', DateTime(2026, 9, 14), GoalStatus.completed),
        _goal('curr2', DateTime(2026, 9, 15), GoalStatus.completed),
      ],
      events: [
        ActivityEvent(
          id: 'e1',
          type: ActivityType.dailyReviewCompleted,
          occurredAt: DateTime(2026, 9, 16, 21),
        ),
        ActivityEvent(
          id: 'e2',
          type: ActivityType.dailyReviewCompleted,
          occurredAt: DateTime(2026, 9, 15, 21),
        ),
        ActivityEvent(
          id: 'e3',
          type: ActivityType.dailyReviewCompleted,
          occurredAt: DateTime(2026, 9, 14, 21),
        ),
      ],
      period: StatisticsPeriod.week,
      anchor: anchor,
    );

    expect(stats.total, 2);
    expect(stats.completed, 2);
    expect(stats.completionRate, 1.0);
    expect(stats.previousTotal, 2);
    expect(stats.previousCompleted, 1);
    // Completion rate improved from 50% to 100% (+50%)
    expect(stats.completionRateDeltaPercent, 50);
    // Completed count improved from 1 to 2 (+100%)
    expect(stats.completedDeltaPercent, 100);
    // Postponed decreased from 1 to 0 (-100%)
    expect(stats.postponedDeltaPercent, -100);
  });

  test('aggregates category performance correctly', () {
    const service = StatisticsService();
    final anchor = DateTime(2026, 9, 16);

    Goal goalWithCat(String id, String category, GoalStatus status) {
      return Goal(
        id: id,
        title: id,
        kind: GoalKind.daily,
        category: category,
        startDate: DateTime(2026, 9, 15),
        status: status,
        createdAt: DateTime(2026, 9, 15),
        updatedAt: DateTime(2026, 9, 15),
      );
    }

    final stats = service.calculate(
      goals: [
        goalWithCat('g1', 'Học tập', GoalStatus.completed),
        goalWithCat('g2', 'Học tập', GoalStatus.active),
        goalWithCat('g3', 'Sức khỏe', GoalStatus.completed),
      ],
      events: [],
      period: StatisticsPeriod.week,
      anchor: anchor,
    );

    final hocTap = stats.categories.firstWhere((c) => c.name == 'Học tập');
    expect(hocTap.total, 2);
    expect(hocTap.completed, 1);
    expect(hocTap.completionRatePercent, 50);

    final sucKhoe = stats.categories.firstWhere((c) => c.name == 'Sức khỏe');
    expect(sucKhoe.total, 1);
    expect(sucKhoe.completed, 1);
    expect(sucKhoe.completionRatePercent, 100);
  });
}
