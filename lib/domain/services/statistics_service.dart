import '../models/activity_event.dart';
import '../models/goal.dart';

enum StatisticsPeriod { week, month, year }

class TrendPoint {
  const TrendPoint({required this.date, required this.completionRate});

  final DateTime date;
  final double completionRate;
}

class ProgressStatistics {
  const ProgressStatistics({
    required this.total,
    required this.completed,
    required this.postponed,
    required this.cancelled,
    required this.overdue,
    required this.currentStreak,
    required this.trend,
  });

  final int total;
  final int completed;
  final int postponed;
  final int cancelled;
  final int overdue;
  final int currentStreak;
  final List<TrendPoint> trend;

  double get completionRate => total == 0 ? 0 : completed / total;
  double get postponementRate => total == 0 ? 0 : postponed / total;
  double get cancellationRate => total == 0 ? 0 : cancelled / total;
}

class StatisticsService {
  const StatisticsService();

  ProgressStatistics calculate({
    required List<Goal> goals,
    required List<ActivityEvent> events,
    required StatisticsPeriod period,
    required DateTime anchor,
  }) {
    final range = _rangeFor(period, anchor);
    final inRange = goals
        .where((goal) {
          final date = _dateOnly(goal.startDate);
          return !date.isBefore(range.$1) && date.isBefore(range.$2);
        })
        .toList(growable: false);

    final completed = inRange
        .where((goal) => goal.status == GoalStatus.completed)
        .length;
    final postponed = inRange
        .where((goal) => goal.status == GoalStatus.postponed)
        .length;
    final cancelled = inRange
        .where((goal) => goal.status == GoalStatus.cancelled)
        .length;
    final today = _dateOnly(anchor);
    final overdue = inRange.where((goal) {
      final due = goal.deadline;
      return due != null &&
          _dateOnly(due).isBefore(today) &&
          goal.status == GoalStatus.active;
    }).length;

    return ProgressStatistics(
      total: inRange.length,
      completed: completed,
      postponed: postponed,
      cancelled: cancelled,
      overdue: overdue,
      currentStreak: _completionStreak(events, today),
      trend: _trend(inRange, range.$1, range.$2, period),
    );
  }

  (DateTime, DateTime) _rangeFor(StatisticsPeriod period, DateTime anchor) {
    final day = _dateOnly(anchor);
    switch (period) {
      case StatisticsPeriod.week:
        final start = day.subtract(
          Duration(days: day.weekday - DateTime.monday),
        );
        return (start, start.add(const Duration(days: 7)));
      case StatisticsPeriod.month:
        return (
          DateTime(day.year, day.month),
          DateTime(day.year, day.month + 1),
        );
      case StatisticsPeriod.year:
        return (DateTime(day.year), DateTime(day.year + 1));
    }
  }

  List<TrendPoint> _trend(
    List<Goal> goals,
    DateTime start,
    DateTime end,
    StatisticsPeriod period,
  ) {
    final bucketCount = switch (period) {
      StatisticsPeriod.week => 7,
      StatisticsPeriod.month => end.difference(start).inDays,
      StatisticsPeriod.year => 12,
    };
    return List.generate(bucketCount, (index) {
      final bucketStart = period == StatisticsPeriod.year
          ? DateTime(start.year, index + 1)
          : start.add(Duration(days: index));
      final bucketEnd = period == StatisticsPeriod.year
          ? DateTime(start.year, index + 2)
          : bucketStart.add(const Duration(days: 1));
      final bucketGoals = goals
          .where((goal) {
            final date = _dateOnly(goal.startDate);
            return !date.isBefore(bucketStart) && date.isBefore(bucketEnd);
          })
          .toList(growable: false);
      final completed = bucketGoals
          .where((goal) => goal.status == GoalStatus.completed)
          .length;
      return TrendPoint(
        date: bucketStart,
        completionRate: bucketGoals.isEmpty
            ? 0
            : completed / bucketGoals.length,
      );
    }, growable: false);
  }

  int _completionStreak(List<ActivityEvent> events, DateTime today) {
    final completedReviewDays = events
        .where((event) => event.type == ActivityType.dailyReviewCompleted)
        .map((event) => _dateOnly(event.occurredAt))
        .toSet();
    var cursor = today;
    var streak = 0;
    while (completedReviewDays.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
