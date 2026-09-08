import 'package:flutter/material.dart';

import '../../application/aday_controller.dart';
import '../../application/goal_draft.dart';
import '../../domain/models/goal.dart' as domain;
import '../../domain/models/task_item.dart';
import '../../domain/services/statistics_service.dart' as domain_stats;
import '../../core/theme/aday_colors.dart';
import '../models/goal_view_item.dart';
import '../models/progress_summary_data.dart';
import '../models/task_view_item.dart';
import '../screens/create_goal/create_goal_form_value.dart' as form;
import '../screens/goal_detail/goal_detail_view_data.dart';
import '../screens/profile/profile_view_data.dart';
import '../screens/statistics/statistics_view_data.dart' as view_stats;
import '../screens/tomorrow_plan/tomorrow_plan_view_data.dart';

abstract final class ADayViewMapper {
  static const _weekdays = <String>[
    'Thứ Hai',
    'Thứ Ba',
    'Thứ Tư',
    'Thứ Năm',
    'Thứ Sáu',
    'Thứ Bảy',
    'Chủ Nhật',
  ];

  static String dateLabel(DateTime date) =>
      '${_weekdays[date.weekday - 1]}, ${date.day} tháng ${date.month}, ${date.year}';

  static String shortDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  static String minuteLabel(int? minute, {String fallback = 'Không đặt'}) {
    if (minute == null) return fallback;
    final hour = (minute ~/ 60).toString().padLeft(2, '0');
    final minutes = (minute % 60).toString().padLeft(2, '0');
    return '$hour:$minutes';
  }

  static GoalDraft toGoalDraft(form.CreateGoalFormValue value) {
    return GoalDraft(
      title: value.title,
      description: value.description,
      category: value.category,
      kind: value.goalType == form.CreateGoalType.daily
          ? domain.GoalKind.daily
          : domain.GoalKind.longTerm,
      priority: switch (value.priority) {
        form.GoalPriority.low => domain.GoalPriority.low,
        form.GoalPriority.medium => domain.GoalPriority.medium,
        form.GoalPriority.high => domain.GoalPriority.high,
      },
      startDate: value.startDate,
      deadline: value.endDate,
      reminderEnabled: value.hasReminder,
      reminderMinute: value.reminderMinute,
      repeatDaily:
          value.goalType == form.CreateGoalType.daily && value.isRepeating,
      tasks: value.tasks
          .map(
            (task) => TaskDraft(
              title: task.title,
              startMinute: task.isAllDay ? null : task.startMinute,
              endMinute: task.isAllDay ? null : task.endMinute,
            ),
          )
          .toList(growable: false),
    );
  }

  static List<TaskViewItem> homeTasks(ADayController controller, DateTime day) {
    final rows = <TaskViewItem>[];
    // Long-term goals have their own dedicated area. Only daily work belongs
    // in the daily agenda and calendar timeline.
    for (final goal
        in controller
            .goalsForDay(day)
            .where((goal) => goal.kind == domain.GoalKind.daily)) {
      final tasks = goal.tasks
          .where((task) => _sameDay(task.scheduledDate, day))
          .toList(growable: false);
      if (tasks.isEmpty) {
        rows.add(TaskViewItem.fromGoal(goal));
      } else {
        rows.addAll(
          tasks.map(
            (task) => TaskViewItem.fromDomain(
              task: task,
              category: goal.category,
              goalTitle: goal.title,
              goalId: goal.id,
            ),
          ),
        );
      }
    }
    // Notes-style completion: keep unfinished work visible first, and place
    // completed items at the bottom without disturbing their relative order.
    return [
      ...rows.where((task) => !task.isCompleted),
      ...rows.where((task) => task.isCompleted),
    ];
  }

  static ProgressSummaryData homeProgress(
    ADayController controller,
    DateTime day,
  ) {
    final tasks = homeTasks(controller, day);
    final completed = tasks.where((task) => task.isCompleted).length;
    final postponed = tasks.where((task) => task.isPostponed).length;
    return ProgressSummaryData.fromCounts(
      date: day,
      dateLabel: dateLabel(day),
      greeting: 'Xin chào, ${controller.settings.displayName}!',
      completed: completed,
      total: tasks.length,
      remaining: tasks.length - completed - postponed,
      postponed: postponed,
    );
  }

  static GoalViewItem? longTermSummary(ADayController controller) {
    final goals = controller.longTermGoals;
    if (goals.isEmpty) return null;
    final completed = controller.goals
        .where(
          (goal) =>
              goal.kind == domain.GoalKind.longTerm &&
              goal.status == domain.GoalStatus.completed,
        )
        .length;
    return GoalViewItem(
      id: goals.first.id,
      title: goals.length == 1 ? goals.first.title : 'Mục tiêu dài hạn',
      subtitle: '${goals.length} mục tiêu đang thực hiện',
      category: goals.first.category,
      activeGoalsCount: goals.length,
      completedGoalsCount: completed,
      totalGoalsCount: goals.length + completed,
      deadlineLabel: goals.first.deadline == null
          ? null
          : shortDate(goals.first.deadline!),
      actionLabel: goals.length == 1 ? 'Xem mục tiêu' : 'Xem tất cả',
    );
  }

  static GoalDetailViewData goalDetail(domain.Goal goal) {
    return GoalDetailViewData(
      id: goal.id,
      title: goal.title,
      category: goal.category,
      quote: goal.description.isEmpty
          ? '“Mỗi bước nhỏ hôm nay đều đưa bạn gần mục tiêu hơn.” 💙'
          : '“${goal.description}”',
      completedTasks: goal.completedTaskCount,
      totalTasks: goal.tasks.length,
      encouragement: goal.completionRate >= 1
          ? 'Tuyệt vời! Bạn đã hoàn thành mục tiêu này.'
          : 'Bạn đang đi đúng hướng. Cứ tiếp tục từng bước nhỏ nhé! 🌱',
      scheduleLabel: goal.repeatDaily ? 'Mỗi ngày' : 'Một lần',
      reminderTimeLabel: minuteLabel(goal.reminderMinute),
      startDateLabel: shortDate(goal.startDate),
      dateLabel: dateLabel(goal.startDate),
      tasks: goal.tasks
          .map(
            (task) => GoalDetailTaskItem(
              id: task.id,
              title: task.title,
              subtitle: _taskSubtitle(task),
              isCompleted: task.status == TaskStatus.completed,
              completedTimeLabel: task.completedAt == null
                  ? null
                  : 'Hoàn thành lúc ${minuteLabel(task.completedAt!.hour * 60 + task.completedAt!.minute)}',
            ),
          )
          .toList(growable: false),
      note: goal.note,
    );
  }

  static TomorrowPlanViewData tomorrowPlan(
    ADayController controller,
    DateTime today,
  ) {
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    final todayTasks = homeTasks(controller, today);
    final unresolved = todayTasks
        .where((task) => !task.isCompleted && !task.isCancelled)
        .map(
          (task) => UnresolvedTaskItem(
            id: task.id,
            title: task.title,
            subtitle: task.subtitle,
            category: task.category,
            icon: task.icon,
            iconColor: task.iconColor,
            iconBackgroundColor: task.iconBackgroundColor,
          ),
        )
        .toList(growable: false);
    final tomorrowTasks = homeTasks(controller, tomorrow)
        .map(
          (task) => TomorrowTaskItem(
            id: task.id,
            title: task.title,
            subtitle: task.subtitle,
            category: task.category,
            icon: task.icon,
            iconColor: task.iconColor,
            iconBackgroundColor: task.iconBackgroundColor,
            timeLabel: task.timeLabel,
            isCompleted: task.isCompleted,
          ),
        )
        .toList(growable: false);
    final completed = todayTasks.where((task) => task.isCompleted).length;
    return TomorrowPlanViewData(
      reminderTimeLabel: minuteLabel(controller.settings.dailyReviewMinute),
      dateLabel: dateLabel(today),
      completedCount: completed,
      totalCount: todayTasks.length,
      remainingCount: unresolved.length,
      overdueCount: todayTasks.where((task) => task.isOverdue).length,
      unresolvedTasks: unresolved,
      tomorrowTasks: tomorrowTasks,
    );
  }

  static ProfileViewData profile(ADayController controller, DateTime anchor) {
    final monthStart = DateTime(anchor.year, anchor.month);
    final nextMonth = DateTime(anchor.year, anchor.month + 1);

    final inMonthGoals = controller.goals
        .where((g) {
          final date = DateTime(
            g.startDate.year,
            g.startDate.month,
            g.startDate.day,
          );
          return !date.isBefore(monthStart) && date.isBefore(nextMonth);
        })
        .toList(growable: false);

    final activeCount = controller.goals
        .where((g) => g.status == domain.GoalStatus.active)
        .length;

    final completedThisMonth = inMonthGoals
        .where((g) => g.status == domain.GoalStatus.completed)
        .length;

    final completionRate = inMonthGoals.isEmpty
        ? 0
        : ((completedThisMonth / inMonthGoals.length) * 100).round();

    return ProfileViewData(
      displayName: controller.settings.displayName,
      email: controller.settings.email,
      memberSince: 'Thành viên từ 06/2025',
      activeGoalsCount: activeCount,
      completedThisMonthCount: completedThisMonth,
      completionRate: completionRate,
      reminderBefore22Enabled:
          controller.settings.dailyReviewEnabled &&
          controller.settings.notificationsAllowed,
      dailyNotificationEnabled: controller.settings.notificationsAllowed,
      language: 'Tiếng Việt',
      themeMode: controller.settings.themeId == 'theme_3' ? 'Tối' : 'Sáng',
    );
  }

  static view_stats.StatisticsViewData statistics({
    required ADayController controller,
    required DateTime month,
    required DateTime selectedDay,
    required view_stats.StatisticsPeriod period,
  }) {
    const service = domain_stats.StatisticsService();
    final domainPeriod = switch (period) {
      view_stats.StatisticsPeriod.week => domain_stats.StatisticsPeriod.week,
      view_stats.StatisticsPeriod.month => domain_stats.StatisticsPeriod.month,
      view_stats.StatisticsPeriod.year => domain_stats.StatisticsPeriod.year,
    };
    final result = service.calculate(
      goals: controller.goals,
      events: controller.snapshot.events,
      period: domainPeriod,
      anchor: selectedDay,
    );
    final completion = (result.completionRate * 100).round();
    final postponed = (result.postponementRate * 100).round();
    final cancelled = (result.cancellationRate * 100).round();
    final remaining = result.total == 0
        ? 0
        : (result.remainingRate * 100).round();

    final periodCompareLabel = switch (period) {
      view_stats.StatisticsPeriod.week => 'so với tuần trước',
      view_stats.StatisticsPeriod.month => 'so với tháng trước',
      view_stats.StatisticsPeriod.year => 'so với năm trước',
    };

    final overviewTitle = switch (period) {
      view_stats.StatisticsPeriod.week => 'Tổng quan tuần này',
      view_stats.StatisticsPeriod.month =>
        'Tổng quan tháng ${selectedDay.month}, ${selectedDay.year}',
      view_stats.StatisticsPeriod.year => 'Tổng quan năm ${selectedDay.year}',
    };

    String formatDeltaPercent(int delta) {
      if (delta > 0) return '↑ $delta% $periodCompareLabel';
      if (delta < 0) return '↓ ${delta.abs()}% $periodCompareLabel';
      return '0% $periodCompareLabel';
    }

    String formatDeltaDays(int days) {
      if (days > 0) return '↑ $days ngày $periodCompareLabel';
      if (days < 0) return '↓ ${days.abs()} ngày $periodCompareLabel';
      return '0 ngày $periodCompareLabel';
    }

    final overviewMetrics = [
      view_stats.OverviewMetricItem(
        title: 'Tỉ lệ hoàn thành',
        value: '$completion%',
        deltaText: formatDeltaPercent(result.completionRateDeltaPercent),
        isPositiveDelta: result.completionRateDeltaPercent >= 0,
        icon: Icons.check_circle_rounded,
        iconColor: ADayColors.progressTeal,
        iconBgColor: ADayColors.progressTealTint,
      ),
      view_stats.OverviewMetricItem(
        title: 'Đã hoàn thành',
        value: '${result.completed}',
        deltaText: formatDeltaPercent(result.completedDeltaPercent),
        isPositiveDelta: result.completedDeltaPercent >= 0,
        icon: Icons.description_rounded,
        iconColor: ADayColors.actionBlue,
        iconBgColor: ADayColors.actionBlueTint,
      ),
      view_stats.OverviewMetricItem(
        title: 'Tạm hoãn',
        value: '${result.postponed}',
        deltaText: formatDeltaPercent(result.postponedDeltaPercent),
        isPositiveDelta: result.postponedDeltaPercent <= 0,
        icon: Icons.schedule_rounded,
        iconColor: ADayColors.sunriseGold,
        iconBgColor: ADayColors.sunriseGoldTint,
      ),
      view_stats.OverviewMetricItem(
        title: 'Đã hủy',
        value: '${result.cancelled}',
        deltaText: formatDeltaPercent(result.cancelledDeltaPercent),
        isPositiveDelta: result.cancelledDeltaPercent <= 0,
        icon: Icons.cancel_rounded,
        iconColor: ADayColors.cancelCoral,
        iconBgColor: ADayColors.cancelCoralTint,
      ),
      view_stats.OverviewMetricItem(
        title: 'Ngày liên tiếp',
        value: '${result.currentStreak}',
        deltaText: formatDeltaDays(result.streakDeltaDays),
        isPositiveDelta: result.streakDeltaDays >= 0,
        icon: Icons.local_fire_department_rounded,
        iconColor: ADayColors.skyCyan,
        iconBgColor: ADayColors.actionBlueTint,
      ),
    ];

    final statusBreakdownItems = [
      view_stats.CompletionBreakdownItem(
        label: 'Đã hoàn thành',
        percentage: completion,
        color: ADayColors.progressTeal,
      ),
      view_stats.CompletionBreakdownItem(
        label: 'Còn lại',
        percentage: remaining,
        color: ADayColors.skyCyan,
      ),
      view_stats.CompletionBreakdownItem(
        label: 'Tạm hoãn',
        percentage: postponed,
        color: ADayColors.sunriseGold,
      ),
      view_stats.CompletionBreakdownItem(
        label: 'Đã hủy',
        percentage: cancelled,
        color: ADayColors.cancelCoral,
      ),
    ];

    (Color, IconData) categoryStyle(String cat) {
      final lower = cat.toLowerCase();
      if (lower.contains('học')) {
        return (ADayColors.progressTeal, Icons.menu_book_rounded);
      }
      if (lower.contains('khỏe')) {
        return (ADayColors.actionBlue, Icons.fitness_center_rounded);
      }
      if (lower.contains('việc')) {
        return (ADayColors.skyCyan, Icons.business_center_rounded);
      }
      if (lower.contains('nhân')) {
        return (ADayColors.sunriseGold, Icons.person_rounded);
      }
      return (ADayColors.mutedInk, Icons.folder_rounded);
    }

    final categoryItems = result.categories
        .map((cat) {
          final style = categoryStyle(cat.name);
          return view_stats.CategoryProgressItem(
            name: cat.name,
            percentage: cat.completionRatePercent,
            color: style.$1,
            icon: style.$2,
            total: cat.total,
            completed: cat.completed,
          );
        })
        .toList(growable: false);

    final String encouragementTitle;
    final String encouragementMessage;
    const String encouragementQuote =
        '“Tiến bộ mỗi ngày luôn tạo nên những điều tuyệt vời!”';

    if (result.total == 0) {
      encouragementTitle = 'Bạn đang làm rất tốt!';
      encouragementMessage =
          'Hãy tạo mục tiêu và hoàn thành các nhiệm vụ mỗi ngày để cùng chinh phục ước mơ nhé!';
    } else if (completion >= 70) {
      encouragementTitle = 'Bạn đang làm rất tốt!';
      final delta = result.completionRateDeltaPercent;
      final deltaStr = delta >= 0 ? 'tăng $delta%' : 'giảm ${delta.abs()}%';
      encouragementMessage =
          'Tỉ lệ hoàn thành $deltaStr $periodCompareLabel. Hãy tiếp tục duy trì và chinh phục những mục tiêu tiếp theo nhé!';
    } else if (completion >= 40) {
      encouragementTitle = 'Khởi đầu đầy hứa hẹn!';
      encouragementMessage =
          'Bạn đã hoàn thành ${result.completed} trên ${result.total} mục tiêu trong kỳ này. Cố lên nhé!';
    } else {
      encouragementTitle = 'Từng bước một nhé!';
      encouragementMessage =
          'Mỗi hành động nhỏ đều đưa bạn đến gần hơn với mục tiêu lớn. Hãy bắt đầu ngay hôm nay!';
    }

    return view_stats.StatisticsViewData(
      selectedPeriod: period,
      calendar: _calendar(controller, month, selectedDay),
      completionMetric: view_stats.StatisticMetricItem(
        type: view_stats.MetricType.completed,
        title: 'Tỷ lệ\nhoàn thành',
        value: '$completion%',
        trendText: result.total == 0
            ? 'Chưa có dữ liệu'
            : '${result.completed}/${result.total}',
        isNote: result.total == 0,
      ),
      postponedMetric: view_stats.StatisticMetricItem(
        type: view_stats.MetricType.postponed,
        title: 'Đã dời lịch',
        value: '${result.postponed}',
        trendText: '$postponed%',
      ),
      cancelledMetric: view_stats.StatisticMetricItem(
        type: view_stats.MetricType.cancelled,
        title: 'Đã hủy',
        value: '${result.cancelled}',
        trendText: '$cancelled%',
      ),
      streakMetric: view_stats.StatisticMetricItem(
        type: view_stats.MetricType.streak,
        title: 'Ngày liên tiếp',
        value: '${result.currentStreak}',
        trendText: result.currentStreak == 0
            ? 'Bắt đầu hôm nay!'
            : 'Giữ vững\nphong độ!',
        isNote: true,
      ),
      trendPoints: _trendPoints(result.trend, period, selectedDay),
      breakdownItems: statusBreakdownItems,
      insight: view_stats.EncouragingInsightData(
        title: encouragementTitle,
        message: encouragementMessage,
        highlightText: result.total == 0 ? '0%' : '$completion%',
      ),
      overviewTitle: overviewTitle,
      overviewMetrics: overviewMetrics,
      categoryItems: categoryItems,
      statusBreakdownItems: statusBreakdownItems,
      encouragementTitle: encouragementTitle,
      encouragementMessage: encouragementMessage,
      encouragementQuote: encouragementQuote,
    );
  }

  static view_stats.CalendarMonthData _calendar(
    ADayController controller,
    DateTime month,
    DateTime selectedDay,
  ) {
    final monthStart = DateTime(month.year, month.month);
    final gridStart = monthStart.subtract(
      Duration(days: monthStart.weekday - 1),
    );
    final today = DateTime.now();
    final days = List.generate(42, (index) {
      final date = gridStart.add(Duration(days: index));
      final goals = controller.goals
          .where((goal) {
            if (_sameDay(goal.startDate, date)) return true;
            return goal.tasks.any((task) => _sameDay(task.scheduledDate, date));
          })
          .toList(growable: false);
      final tasks = goals
          .expand(
            (goal) =>
                goal.tasks.where((task) => _sameDay(task.scheduledDate, date)),
          )
          .toList(growable: false);
      final total = tasks.isEmpty ? goals.length : tasks.length;
      final completedTasks = tasks.isEmpty
          ? goals
                .where((goal) => goal.status == domain.GoalStatus.completed)
                .length
          : tasks.where((task) => task.status == TaskStatus.completed).length;
      final status = _calendarStatus(goals, total, completedTasks);
      return view_stats.CalendarDayData(
        date: date,
        dayNumber: date.day,
        isCurrentMonth: date.month == month.month && date.year == month.year,
        isToday: _sameDay(date, today),
        isSelected: _sameDay(date, selectedDay),
        status: status,
        completedTasks: completedTasks,
        totalTasks: total,
      );
    }, growable: false);
    final selectedTasks = homeTasks(controller, selectedDay);
    final selectedCompleted = selectedTasks
        .where((task) => task.isCompleted)
        .length;
    return view_stats.CalendarMonthData(
      year: month.year,
      month: month.month,
      monthLabel: 'Tháng ${month.month}, ${month.year}',
      days: days,
      todaySummaryLabel:
          '$selectedCompleted / ${selectedTasks.length} nhiệm vụ ngày ${selectedDay.day}/${selectedDay.month}',
      todayCompletedCount: selectedCompleted,
      todayTotalCount: selectedTasks.length,
    );
  }

  static view_stats.CalendarDayStatus _calendarStatus(
    List<domain.Goal> goals,
    int total,
    int completed,
  ) {
    if (goals.any((goal) => goal.status == domain.GoalStatus.cancelled)) {
      return view_stats.CalendarDayStatus.cancelled;
    }
    if (goals.any((goal) => goal.status == domain.GoalStatus.postponed)) {
      return view_stats.CalendarDayStatus.postponed;
    }
    if (total > 0 && completed == total) {
      return view_stats.CalendarDayStatus.completed;
    }
    return total > 0
        ? view_stats.CalendarDayStatus.planned
        : view_stats.CalendarDayStatus.none;
  }

  static List<view_stats.TrendDataPoint> _trendPoints(
    List<domain_stats.TrendPoint> source,
    view_stats.StatisticsPeriod period,
    DateTime anchor,
  ) {
    if (period == view_stats.StatisticsPeriod.month) {
      const weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
      final weekdayGroups = List.generate(7, (_) => <double>[]);
      for (final point in source) {
        final dayIndex = point.date.weekday - 1;
        if (dayIndex >= 0 && dayIndex < 7) {
          weekdayGroups[dayIndex].add(point.completionRate);
        }
      }
      return List.generate(7, (i) {
        final rates = weekdayGroups[i];
        final avgRate = rates.isEmpty
            ? 0.0
            : rates.fold<double>(0.0, (s, r) => s + r) / rates.length;
        return view_stats.TrendDataPoint(
          label: weekdays[i],
          percentage: avgRate,
          valueLabel: '${(avgRate * 100).round()}%',
          isHighlighted: anchor.weekday - 1 == i,
        );
      });
    }
    return source
        .map((point) {
          final label = period == view_stats.StatisticsPeriod.week
              ? const [
                  'T2',
                  'T3',
                  'T4',
                  'T5',
                  'T6',
                  'T7',
                  'CN',
                ][point.date.weekday - 1]
              : 'T${point.date.month}';
          return view_stats.TrendDataPoint(
            label: label,
            percentage: point.completionRate,
            valueLabel: '${(point.completionRate * 100).round()}%',
            isHighlighted: _sameDay(point.date, anchor),
          );
        })
        .toList(growable: false);
  }

  static String? _taskSubtitle(TaskItem task) {
    if (task.completedAt != null) {
      return 'Hoàn thành lúc ${minuteLabel(task.completedAt!.hour * 60 + task.completedAt!.minute)}';
    }
    if (task.note.isNotEmpty) return task.note;
    if (task.isAllDay) return 'Cả ngày';
    final start = minuteLabel(task.startMinute);
    final end = minuteLabel(task.endMinute, fallback: '');
    return end.isEmpty ? start : '$start – $end';
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
