import '../../application/aday_controller.dart';
import '../../application/goal_draft.dart';
import '../../core/theme/aday_colors.dart';
import '../../domain/models/goal.dart' as domain;
import '../../domain/models/task_item.dart';
import '../../domain/services/statistics_service.dart' as domain_stats;
import '../models/goal_view_item.dart';
import '../models/progress_summary_data.dart';
import '../models/task_view_item.dart';
import '../screens/create_goal/create_goal_form_value.dart' as form;
import '../screens/goal_detail/goal_detail_view_data.dart';
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
      repeatDaily: value.isRepeating,
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
    for (final goal in controller.goalsForDay(day)) {
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
    return rows;
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
    final remaining = (100 - completion - postponed - cancelled).clamp(0, 100);

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
      breakdownItems: [
        view_stats.CompletionBreakdownItem(
          label: 'Đã hoàn thành',
          percentage: completion,
          color: ADayColors.successMint,
        ),
        view_stats.CompletionBreakdownItem(
          label: 'Còn lại',
          percentage: remaining,
          color: ADayColors.skyCyan,
        ),
        view_stats.CompletionBreakdownItem(
          label: 'Đã dời / Đã hủy',
          percentage: postponed + cancelled,
          color: ADayColors.mutedInk,
        ),
      ],
      insight: view_stats.EncouragingInsightData(
        title: result.total == 0 ? 'Sẵn sàng bắt đầu!' : 'Bạn đang tiến bộ!',
        message: result.total == 0
            ? 'Hãy tạo mục tiêu đầu tiên để ADay bắt đầu thống kê hành trình của bạn.'
            : 'Bạn đã hoàn thành ${result.completed} trên ${result.total} mục tiêu trong kỳ này.',
        highlightText: result.total == 0 ? '0%' : '$completion%',
      ),
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
      final points = <view_stats.TrendDataPoint>[];
      for (var start = 0; start < source.length; start += 7) {
        final group = source.skip(start).take(7).toList(growable: false);
        final rate = group.isEmpty
            ? 0.0
            : group.fold<double>(0, (sum, item) => sum + item.completionRate) /
                  group.length;
        points.add(
          view_stats.TrendDataPoint(
            label: 'T${points.length + 1}',
            percentage: rate,
            valueLabel: '${(rate * 100).round()}%',
          ),
        );
      }
      return points;
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
