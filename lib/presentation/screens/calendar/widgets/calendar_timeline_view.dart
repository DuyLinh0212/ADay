import 'package:flutter/material.dart';

import '../../../../core/theme/aday_colors.dart';
import '../../../../core/theme/aday_spacing.dart';
import '../../../../core/theme/aday_typography.dart';
import '../../../models/task_view_item.dart';

/// A day-first schedule timeline view matching Image 2.
/// Features top date navigation with "< > Hôm nay", 3 summary metric cards,
/// a connected vertical timeline with colored status nodes, task cards, and
/// dashed "Thời gian rảnh" slots.
class CalendarTimelineView extends StatelessWidget {
  const CalendarTimelineView({
    super.key,
    required this.day,
    required this.tasks,
    this.onToggleTask,
    this.onTaskTap,
    this.onPrevDay,
    this.onNextDay,
    this.onTodayTap,
    this.onAddTask,
  });

  final DateTime day;
  final List<TaskViewItem> tasks;
  final void Function(TaskViewItem task, bool completed)? onToggleTask;
  final ValueChanged<TaskViewItem>? onTaskTap;
  final VoidCallback? onPrevDay;
  final VoidCallback? onNextDay;
  final VoidCallback? onTodayTap;
  final VoidCallback? onAddTask;

  static const _weekdays = <String>[
    'Thứ Hai',
    'Thứ Ba',
    'Thứ Tư',
    'Thứ Năm',
    'Thứ Sáu',
    'Thứ Bảy',
    'Chủ Nhật',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final totalTasks = tasks.length;
    final progressPercent = totalTasks == 0
        ? 0
        : ((completedTasks / totalTasks) * 100).round();

    // Calculate free time in the day (between 06:00 and 22:00 = 16 hours)
    final busyMinutes = tasks.fold<int>(0, (sum, t) {
      if (t.isAllDay) return sum + 30;
      final start = _startMinute(t);
      final end = _endMinute(t);
      return sum + (end > start ? end - start : 45);
    });
    final freeHours = ((16 * 60 - busyMinutes).clamp(60, 14 * 60) ~/ 60);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Date Navigation Bar (<  Thứ Ba, 24 tháng 6, 2025  >  [ Hôm nay ])
        _buildDateNavigator(context, isDark),

        const SizedBox(height: ADaySpacing.md),

        // 2. Three Summary Metric Cards in a Row
        _buildMetricCards(
          context,
          isDark: isDark,
          completed: completedTasks,
          total: totalTasks,
          freeHours: freeHours,
          progress: progressPercent,
        ),

        const SizedBox(height: ADaySpacing.lg),

        // 3. Vertical Timeline List
        if (tasks.isEmpty)
          _buildEmptyTimeline(context, isDark)
        else
          _buildTimelineBody(context, isDark),
      ],
    );
  }

  /// Top Date Navigation Bar
  Widget _buildDateNavigator(BuildContext context, bool isDark) {
    final dateString =
        '${_weekdays[day.weekday - 1]}, ${day.day} tháng ${day.month}, ${day.year}';
    final now = DateTime.now();
    final isToday =
        day.year == now.year && day.month == now.month && day.day == now.day;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2638) : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3A52) : const Color(0xFFEBF1F6),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrevDay,
            icon: const Icon(Icons.chevron_left_rounded, size: 24.0),
            color: isDark ? Colors.white70 : ADayColors.brandNavy,
            tooltip: 'Ngày trước',
          ),
          Expanded(
            child: Text(
              dateString,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: ADayTypography.fontFamily,
                fontSize: 15.0,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : ADayColors.brandNavy,
              ),
            ),
          ),
          IconButton(
            onPressed: onNextDay,
            icon: const Icon(Icons.chevron_right_rounded, size: 24.0),
            color: isDark ? Colors.white70 : ADayColors.brandNavy,
            tooltip: 'Ngày sau',
          ),
          if (!isToday && onTodayTap != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Material(
                color: isDark
                    ? const Color(0xFF263352)
                    : const Color(0xFFE8F3FF),
                borderRadius: BorderRadius.circular(12.0),
                child: InkWell(
                  onTap: onTodayTap,
                  borderRadius: BorderRadius.circular(12.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 6.0,
                    ),
                    child: Text(
                      'Hôm nay',
                      style: TextStyle(
                        fontFamily: ADayTypography.fontFamily,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? const Color(0xFF60A5FA)
                            : const Color(0xFF168AF2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 3 Summary Metric Cards in a Row
  Widget _buildMetricCards(
    BuildContext context, {
    required bool isDark,
    required int completed,
    required int total,
    required int freeHours,
    required int progress,
  }) {
    final cardBg = isDark ? const Color(0xFF1E2638) : Colors.white;
    final cardBorder = isDark
        ? const Color(0xFF2E3A52)
        : const Color(0xFFEBF1F6);

    return Row(
      children: [
        // Metric 1: Tasks Today (Completed)
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30.0,
                  height: 30.0,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00C48C),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 18.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  '$completed / $total',
                  style: TextStyle(
                    fontFamily: ADayTypography.fontFamily,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : ADayColors.brandNavy,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  'Nhiệm vụ hôm nay',
                  style: TextStyle(
                    fontFamily: ADayTypography.fontFamily,
                    fontSize: 11.0,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white54 : ADayColors.mutedInk,
                  ),
                ),
                Text(
                  'Đã hoàn thành',
                  style: TextStyle(
                    fontFamily: ADayTypography.fontFamily,
                    fontSize: 10.0,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 8.0),

        // Metric 2: Free Time Remaining
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30.0,
                  height: 30.0,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.access_time_filled_rounded,
                    color: Colors.white,
                    size: 18.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  '$freeHours giờ',
                  style: TextStyle(
                    fontFamily: ADayTypography.fontFamily,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : ADayColors.brandNavy,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  'Thời gian rảnh',
                  style: TextStyle(
                    fontFamily: ADayTypography.fontFamily,
                    fontSize: 11.0,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white54 : ADayColors.mutedInk,
                  ),
                ),
                Text(
                  'Còn lại trong ngày',
                  style: TextStyle(
                    fontFamily: ADayTypography.fontFamily,
                    fontSize: 10.0,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 8.0),

        // Metric 3: Today's Progress
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30.0,
                  height: 30.0,
                  decoration: const BoxDecoration(
                    color: Color(0xFF38BDF8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    color: Colors.white,
                    size: 18.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  '$progress%',
                  style: TextStyle(
                    fontFamily: ADayTypography.fontFamily,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : ADayColors.brandNavy,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  'Tiến độ hôm nay',
                  style: TextStyle(
                    fontFamily: ADayTypography.fontFamily,
                    fontSize: 11.0,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white54 : ADayColors.mutedInk,
                  ),
                ),
                const SizedBox(height: 6.0),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: LinearProgressIndicator(
                    value: (progress / 100.0).clamp(0.0, 1.0),
                    minHeight: 4.0,
                    backgroundColor: isDark
                        ? const Color(0xFF2E3A52)
                        : const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF00C48C),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Vertical Timeline Content with Task Cards and Free Time Slots
  Widget _buildTimelineBody(BuildContext context, bool isDark) {
    final allDayTasks = tasks.where((t) => t.isAllDay).toList();
    final timedTasks = tasks.where((t) => !t.isAllDay).toList()
      ..sort((a, b) => _startMinute(a).compareTo(_startMinute(b)));

    // Merge timed tasks and generate free time slots between gaps
    final timelineElements = <_TimelineItem>[];

    // Add all-day tasks first
    for (final task in allDayTasks) {
      timelineElements.add(
        _TimelineItem(
          timeLabel: 'Cả ngày',
          dotColor: const Color(0xFF00C48C),
          task: task,
        ),
      );
    }

    // Process timed tasks and insert free time gaps
    int previousEndMinute = -1;
    for (int i = 0; i < timedTasks.length; i++) {
      final current = timedTasks[i];
      final start = _startMinute(current);
      final end = _endMinute(current);

      if (previousEndMinute != -1 && start - previousEndMinute >= 45) {
        // Free time gap
        final gapStartH = (previousEndMinute ~/ 60).toString().padLeft(2, '0');
        final gapStartM = (previousEndMinute % 60).toString().padLeft(2, '0');
        final gapSubtitle = _freeTimeSubtitle(previousEndMinute);
        timelineElements.add(
          _TimelineItem(
            timeLabel: '$gapStartH:$gapStartM',
            dotColor: const Color(0xFF94A3B8),
            isFreeTime: true,
            freeTimeTitle: 'Thời gian rảnh',
            freeTimeSubtitle: gapSubtitle,
          ),
        );
      }

      final startH = (start ~/ 60).toString().padLeft(2, '0');
      final startM = (start % 60).toString().padLeft(2, '0');
      final endH = (end ~/ 60).toString().padLeft(2, '0');
      final endM = (end % 60).toString().padLeft(2, '0');
      final timeStr = '$startH:$startM\n$endH:$endM';

      final dotColor = current.isCompleted
          ? const Color(0xFF00C48C)
          : current.iconColor;

      timelineElements.add(
        _TimelineItem(timeLabel: timeStr, dotColor: dotColor, task: current),
      );

      previousEndMinute = end;
    }

    // If there is late evening free time
    if (previousEndMinute != -1 && previousEndMinute < 21 * 60) {
      final gapStartH = (previousEndMinute ~/ 60).toString().padLeft(2, '0');
      final gapStartM = (previousEndMinute % 60).toString().padLeft(2, '0');
      timelineElements.add(
        _TimelineItem(
          timeLabel: '$gapStartH:$gapStartM',
          dotColor: const Color(0xFF94A3B8),
          isFreeTime: true,
          freeTimeTitle: 'Thời gian rảnh',
          freeTimeSubtitle: 'Thời gian cá nhân, nghỉ ngơi',
        ),
      );
    }

    return Column(
      children: List.generate(timelineElements.length, (index) {
        final item = timelineElements[index];
        final isLast = index == timelineElements.length - 1;
        return _buildTimelineRow(context, item, isLast: isLast, isDark: isDark);
      }),
    );
  }

  Widget _buildTimelineRow(
    BuildContext context,
    _TimelineItem item, {
    required bool isLast,
    required bool isDark,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Column: Time label
          SizedBox(
            width: 54.0,
            child: Padding(
              padding: const EdgeInsets.only(top: 14.0),
              child: Text(
                item.timeLabel,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: ADayTypography.fontFamily,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  color: isDark ? Colors.white70 : const Color(0xFF64748B),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10.0),

          // Middle Column: Node dot & connecting line
          SizedBox(
            width: 18.0,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if (!isLast)
                  Positioned(
                    top: 18.0,
                    bottom: 0.0,
                    child: Container(
                      width: 2.0,
                      color: isDark
                          ? const Color(0xFF2E3A52)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                Container(
                  margin: const EdgeInsets.only(top: 18.0),
                  width: 12.0,
                  height: 12.0,
                  decoration: BoxDecoration(
                    color: item.dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                      width: 2.0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10.0),

          // Right Column: Task card or Free time dashed card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: item.isFreeTime
                  ? _buildFreeTimeCard(context, item, isDark)
                  : _buildTaskCard(context, item.task!, isDark),
            ),
          ),
        ],
      ),
    );
  }

  /// Task Card matching Image 2
  Widget _buildTaskCard(BuildContext context, TaskViewItem task, bool isDark) {
    // Determine status badge: Completed, In Progress, Pending
    final isDone = task.isCompleted;

    // Pastel styling for task card
    final cardBg = isDark
        ? const Color(0xFF1E2638)
        : _cardBackgroundForCategory(task.category ?? task.title);
    final cardBorder = isDark
        ? const Color(0xFF2E3A52)
        : _cardBorderForCategory(task.category ?? task.title);

    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(16.0),
      child: InkWell(
        onTap: onTaskTap != null ? () => onTaskTap!(task) : null,
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: cardBorder, width: 1.0),
          ),
          child: Row(
            children: [
              // Icon container with vibrant color
              Container(
                width: 38.0,
                height: 38.0,
                decoration: BoxDecoration(
                  color: task.iconBackgroundColor,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(task.icon, color: task.iconColor, size: 20.0),
              ),

              const SizedBox(width: 12.0),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: ADayTypography.fontFamily,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : ADayColors.brandNavy,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      task.subtitle ?? task.category ?? 'Nhiệm vụ trong ngày',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: ADayTypography.fontFamily,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? Colors.white54
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8.0),

              // Trailing Status Indicator / Badge
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (task.timeLabel != null && !task.isAllDay)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        task.timeLabel!,
                        style: TextStyle(
                          fontFamily: ADayTypography.fontFamily,
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white54
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  if (isDone)
                    GestureDetector(
                      onTap: onToggleTask != null
                          ? () => onToggleTask!(task, false)
                          : null,
                      child: Container(
                        padding: task.isAllDay
                            ? const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              )
                            : EdgeInsets.zero,
                        decoration: task.isAllDay
                            ? BoxDecoration(
                                color: const Color(0xFFD1FAE5),
                                borderRadius: BorderRadius.circular(12.0),
                              )
                            : null,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF00C48C),
                              size: 22.0,
                            ),
                            if (task.isAllDay) ...[
                              const SizedBox(width: 4.0),
                              const Text(
                                'Cả ngày',
                                style: TextStyle(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF059669),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: onToggleTask != null
                          ? () => onToggleTask!(task, true)
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12.0,
                              height: 12.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFD97706),
                                  width: 2.0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4.0),
                            const Text(
                              'Chờ thực hiện',
                              style: TextStyle(
                                fontSize: 10.0,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Dashed Free Time Card matching Image 2
  Widget _buildFreeTimeCard(
    BuildContext context,
    _TimelineItem item,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 11.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161E2E) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: isDark ? const Color(0xFF26334D) : const Color(0xFFE2E8F0),
          width: 1.2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.freeTimeTitle ?? 'Thời gian rảnh',
            style: TextStyle(
              fontFamily: ADayTypography.fontFamily,
              fontSize: 13.0,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 1.0),
          Text(
            item.freeTimeSubtitle ?? 'Tự do sắp xếp công việc cá nhân',
            style: TextStyle(
              fontFamily: ADayTypography.fontFamily,
              fontSize: 11.0,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  /// Empty state
  Widget _buildEmptyTimeline(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: ADaySpacing.xl,
        horizontal: ADaySpacing.md,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2638) : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3A52) : const Color(0xFFEBF1F6),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_note_rounded,
            size: 48.0,
            color: isDark ? Colors.white38 : ADayColors.mutedInk,
          ),
          const SizedBox(height: 12.0),
          Text(
            'Chưa có kế hoạch theo mốc thời gian',
            style: TextStyle(
              fontFamily: ADayTypography.fontFamily,
              fontSize: 15.0,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : ADayColors.brandNavy,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Hãy thêm nhiệm vụ để theo dõi một ngày thật ý nghĩa.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: ADayTypography.fontFamily,
              fontSize: 13.0,
              color: isDark ? Colors.white54 : ADayColors.mutedInk,
            ),
          ),
          const SizedBox(height: 14.0),
          if (onAddTask != null)
            FilledButton.icon(
              onPressed: onAddTask,
              icon: const Icon(Icons.add_rounded, size: 18.0),
              label: const Text('Thêm nhiệm vụ mới'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF168AF2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static int _startMinute(TaskViewItem task) {
    final firstPart = task.timeLabel?.split(RegExp(r'\s|–|-')).first ?? '';
    final parts = firstPart.split(':');
    if (parts.length != 2) return 24 * 60;
    return (int.tryParse(parts[0]) ?? 24) * 60 + (int.tryParse(parts[1]) ?? 0);
  }

  static int _endMinute(TaskViewItem task) {
    final parts = task.timeLabel?.split(RegExp(r'\s|–|-')) ?? [];
    if (parts.length >= 2) {
      final endParts = parts[1].split(':');
      if (endParts.length == 2) {
        return (int.tryParse(endParts[0]) ?? 24) * 60 +
            (int.tryParse(endParts[1]) ?? 0);
      }
    }
    return _startMinute(task) + 45;
  }

  static Color _cardBackgroundForCategory(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('thiền') || lower.contains('tâm trí')) {
      return const Color(0xFFF0FDF8);
    }
    if (lower.contains('dục') || lower.contains('thể thao')) {
      return const Color(0xFFF0FDF9);
    }
    if (lower.contains('sách') || lower.contains('đọc')) {
      return const Color(0xFFEFF6FF);
    }
    if (lower.contains('họp') || lower.contains('nhóm')) {
      return const Color(0xFFF5F3FF);
    }
    if (lower.contains('báo cáo') || lower.contains('viết')) {
      return const Color(0xFFECFDF5);
    }
    if (lower.contains('code') || lower.contains('flutter')) {
      return const Color(0xFFFFFBEB);
    }
    return const Color(0xFFF8FAFC);
  }

  static Color _cardBorderForCategory(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('thiền') || lower.contains('tâm trí')) {
      return const Color(0xFFCCFBF1);
    }
    if (lower.contains('dục') || lower.contains('thể thao')) {
      return const Color(0xFFD1FAE5);
    }
    if (lower.contains('sách') || lower.contains('đọc')) {
      return const Color(0xFFDBEAFE);
    }
    if (lower.contains('họp') || lower.contains('nhóm')) {
      return const Color(0xFFEDE9FE);
    }
    if (lower.contains('báo cáo') || lower.contains('viết')) {
      return const Color(0xFFA7F3D0);
    }
    if (lower.contains('code') || lower.contains('flutter')) {
      return const Color(0xFFFDE68A);
    }
    return const Color(0xFFE2E8F0);
  }

  static String _freeTimeSubtitle(int minute) {
    if (minute < 11 * 60 + 30) {
      return 'Tự do sắp xếp công việc cá nhân';
    } else if (minute < 14 * 60) {
      return 'Ăn trưa, nghỉ ngơi, thư giãn';
    } else if (minute < 18 * 60) {
      return 'Nghỉ giải lao, nạp năng lượng';
    } else {
      return 'Thời gian cá nhân, nghỉ ngơi';
    }
  }
}

class _TimelineItem {
  const _TimelineItem({
    required this.timeLabel,
    required this.dotColor,
    this.task,
    this.isFreeTime = false,
    this.freeTimeTitle,
    this.freeTimeSubtitle,
  });

  final String timeLabel;
  final Color dotColor;
  final TaskViewItem? task;
  final bool isFreeTime;
  final String? freeTimeTitle;
  final String? freeTimeSubtitle;
}
