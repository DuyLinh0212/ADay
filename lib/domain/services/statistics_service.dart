import '../models/activity_event.dart';
import '../models/goal.dart';
import '../models/task_item.dart';

enum StatisticsPeriod { week, month, year }

class TrendPoint {
  const TrendPoint({required this.date, required this.completionRate});

  final DateTime date;
  final double completionRate;
}

class CategoryPerformance {
  const CategoryPerformance({
    required this.name,
    required this.total,
    required this.completed,
  });

  final String name;
  final int total;
  final int completed;

  double get completionRate => total == 0 ? 0 : completed / total;
  int get completionRatePercent => (completionRate * 100).round();
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
    this.categories = const [],
    this.previousTotal = 0,
    this.previousCompleted = 0,
    this.previousPostponed = 0,
    this.previousCancelled = 0,
    this.previousStreak = 0,
  });

  final int total;
  final int completed;
  final int postponed;
  final int cancelled;
  final int overdue;
  final int currentStreak;
  final List<TrendPoint> trend;
  final List<CategoryPerformance> categories;

  final int previousTotal;
  final int previousCompleted;
  final int previousPostponed;
  final int previousCancelled;
  final int previousStreak;

  double get completionRate => total == 0 ? 0 : completed / total;
  double get postponementRate => total == 0 ? 0 : postponed / total;
  double get cancellationRate => total == 0 ? 0 : cancelled / total;
  double get remainingRate {
    final rem = 1.0 - completionRate - postponementRate - cancellationRate;
    return rem < 0 ? 0 : rem;
  }

  double get previousCompletionRate =>
      previousTotal == 0 ? 0 : previousCompleted / previousTotal;

  int get completionRateDeltaPercent =>
      ((completionRate - previousCompletionRate) * 100).round();

  int get completedDeltaPercent => previousCompleted == 0
      ? (completed > 0 ? 100 : 0)
      : (((completed - previousCompleted) / previousCompleted) * 100).round();

  int get postponedDeltaPercent => previousPostponed == 0
      ? (postponed > 0 ? 100 : 0)
      : (((postponed - previousPostponed) / previousPostponed) * 100).round();

  int get cancelledDeltaPercent => previousCancelled == 0
      ? (cancelled > 0 ? 100 : 0)
      : (((cancelled - previousCancelled) / previousCancelled) * 100).round();

  int get streakDeltaDays => currentStreak - previousStreak;
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
    final entries = _entriesFor(goals);
    final inRange = _entriesInRange(entries, range);

    final completed = inRange
        .where((entry) => entry.status == _StatisticsStatus.completed)
        .length;
    final postponed = inRange
        .where((entry) => entry.status == _StatisticsStatus.postponed)
        .length;
    final cancelled = inRange
        .where((entry) => entry.status == _StatisticsStatus.cancelled)
        .length;
    final today = _dateOnly(anchor);
    final overdue = inRange.where((entry) {
      final due = entry.dueDate;
      return due != null &&
          _dateOnly(due).isBefore(today) &&
          entry.status == _StatisticsStatus.active;
    }).length;

    // Previous period stats for delta comparison
    final prevRange = _previousRangeFor(period, anchor);
    final inPrevRange = _entriesInRange(entries, prevRange);
    final prevCompleted = inPrevRange
        .where((entry) => entry.status == _StatisticsStatus.completed)
        .length;
    final prevPostponed = inPrevRange
        .where((entry) => entry.status == _StatisticsStatus.postponed)
        .length;
    final prevCancelled = inPrevRange
        .where((entry) => entry.status == _StatisticsStatus.cancelled)
        .length;

    final prevAnchor = switch (period) {
      StatisticsPeriod.week => anchor.subtract(const Duration(days: 7)),
      StatisticsPeriod.month => DateTime(
        anchor.year,
        anchor.month - 1,
        anchor.day,
      ),
      StatisticsPeriod.year => DateTime(
        anchor.year - 1,
        anchor.month,
        anchor.day,
      ),
    };
    final prevStreak = _completionStreak(events, _dateOnly(prevAnchor));

    // Only return categories that actually exist in the selected period.
    // Pre-populating categories with zeroes made the statistics page look like
    // a demo dashboard and hid malformed/empty category data.
    final categoriesMap = <String, (int total, int completed)>{};
    for (final entry in inRange) {
      final cat = entry.category;
      final current = categoriesMap[cat] ?? (0, 0);
      final isDone = entry.status == _StatisticsStatus.completed;
      categoriesMap[cat] = (current.$1 + 1, current.$2 + (isDone ? 1 : 0));
    }
    final categoryList =
        categoriesMap.entries
            .map(
              (e) => CategoryPerformance(
                name: e.key,
                total: e.value.$1,
                completed: e.value.$2,
              ),
            )
            .toList(growable: false)
          ..sort((a, b) {
            const preferred = ['Học tập', 'Sức khỏe', 'Công việc', 'Cá nhân'];
            final aIndex = preferred.indexOf(a.name);
            final bIndex = preferred.indexOf(b.name);
            if (aIndex >= 0 && bIndex >= 0) return aIndex.compareTo(bIndex);
            if (aIndex >= 0) return -1;
            if (bIndex >= 0) return 1;
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });

    return ProgressStatistics(
      total: inRange.length,
      completed: completed,
      postponed: postponed,
      cancelled: cancelled,
      overdue: overdue,
      currentStreak: _completionStreak(events, today),
      trend: _trend(inRange, range.$1, range.$2, period),
      categories: categoryList,
      previousTotal: inPrevRange.length,
      previousCompleted: prevCompleted,
      previousPostponed: prevPostponed,
      previousCancelled: prevCancelled,
      previousStreak: prevStreak,
    );
  }

  List<_StatisticsEntry> _entriesFor(List<Goal> goals) {
    final entries = <_StatisticsEntry>[];
    for (final goal in goals) {
      final category = goal.category.trim().isEmpty
          ? 'Khác'
          : goal.category.trim();
      if (goal.tasks.isEmpty) {
        entries.add(
          _StatisticsEntry(
            date: _dateOnly(goal.startDate),
            status: _goalStatus(goal.status),
            category: category,
            dueDate: goal.deadline,
          ),
        );
        continue;
      }

      for (final task in goal.tasks) {
        final taskStatus = _taskStatus(task.status);
        final effectiveStatus = switch ((goal.status, taskStatus)) {
          (_, _StatisticsStatus.completed) => _StatisticsStatus.completed,
          (GoalStatus.cancelled, _) => _StatisticsStatus.cancelled,
          (GoalStatus.postponed, _) => _StatisticsStatus.postponed,
          _ => taskStatus,
        };
        entries.add(
          _StatisticsEntry(
            date: _dateOnly(task.scheduledDate),
            status: effectiveStatus,
            category: category,
            // A scheduled task becomes overdue after its scheduled day. A
            // goal-level deadline is used only when it is earlier.
            dueDate:
                goal.deadline != null &&
                    goal.deadline!.isBefore(task.scheduledDate)
                ? goal.deadline
                : task.scheduledDate,
          ),
        );
      }
    }
    return entries;
  }

  List<_StatisticsEntry> _entriesInRange(
    List<_StatisticsEntry> entries,
    (DateTime, DateTime) range,
  ) => entries
      .where(
        (entry) =>
            !entry.date.isBefore(range.$1) && entry.date.isBefore(range.$2),
      )
      .toList(growable: false);

  _StatisticsStatus _goalStatus(GoalStatus status) => switch (status) {
    GoalStatus.active => _StatisticsStatus.active,
    GoalStatus.completed => _StatisticsStatus.completed,
    GoalStatus.postponed => _StatisticsStatus.postponed,
    GoalStatus.cancelled => _StatisticsStatus.cancelled,
  };

  _StatisticsStatus _taskStatus(TaskStatus status) => switch (status) {
    TaskStatus.pending => _StatisticsStatus.active,
    TaskStatus.completed => _StatisticsStatus.completed,
    TaskStatus.postponed => _StatisticsStatus.postponed,
    TaskStatus.cancelled => _StatisticsStatus.cancelled,
  };

  (DateTime, DateTime) _previousRangeFor(
    StatisticsPeriod period,
    DateTime anchor,
  ) {
    final day = _dateOnly(anchor);
    switch (period) {
      case StatisticsPeriod.week:
        final start = day
            .subtract(Duration(days: day.weekday - DateTime.monday))
            .subtract(const Duration(days: 7));
        return (start, start.add(const Duration(days: 7)));
      case StatisticsPeriod.month:
        final prevMonth = DateTime(day.year, day.month - 1);
        return (prevMonth, DateTime(day.year, day.month));
      case StatisticsPeriod.year:
        return (DateTime(day.year - 1), DateTime(day.year));
    }
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
    List<_StatisticsEntry> entries,
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
      final bucketEntries = entries
          .where((entry) {
            final date = entry.date;
            return !date.isBefore(bucketStart) && date.isBefore(bucketEnd);
          })
          .toList(growable: false);
      final completed = bucketEntries
          .where((entry) => entry.status == _StatisticsStatus.completed)
          .length;
      return TrendPoint(
        date: bucketStart,
        completionRate: bucketEntries.isEmpty
            ? 0
            : completed / bucketEntries.length,
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

enum _StatisticsStatus { active, completed, postponed, cancelled }

class _StatisticsEntry {
  const _StatisticsEntry({
    required this.date,
    required this.status,
    required this.category,
    this.dueDate,
  });

  final DateTime date;
  final _StatisticsStatus status;
  final String category;
  final DateTime? dueDate;
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
