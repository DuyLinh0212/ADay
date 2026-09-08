import 'package:flutter/material.dart';

import '../../../../core/theme/aday_colors.dart';
import '../../../../core/theme/aday_spacing.dart';
import '../../../../core/theme/aday_typography.dart';
import '../../../../domain/models/goal.dart';
import '../../../models/task_view_item.dart';

/// A rich, detailed 7-column calendar month view matching Image 3.
/// Features cross-week goal/challenge banners, colorful category task pills,
/// reminder chips (🔔 Nhắc 22:00), active glowing day borders, and quick day selection.
class CalendarDetailedMonthView extends StatelessWidget {
  const CalendarDetailedMonthView({
    super.key,
    required this.month,
    required this.selectedDay,
    required this.tasksForDay,
    required this.longTermGoals,
    this.dailyReminderMinute,
    this.onDayTap,
    this.onPrevMonth,
    this.onNextMonth,
    this.onTodayTap,
    this.onAddTask,
  });

  final DateTime month;
  final DateTime selectedDay;
  final List<TaskViewItem> Function(DateTime day) tasksForDay;
  final List<Goal> longTermGoals;
  final int? dailyReminderMinute;
  final ValueChanged<DateTime>? onDayTap;
  final VoidCallback? onPrevMonth;
  final VoidCallback? onNextMonth;
  final VoidCallback? onTodayTap;
  final VoidCallback? onAddTask;

  static const _weekdays = <String>[
    'Th 2',
    'Th 3',
    'Th 4',
    'Th 5',
    'Th 6',
    'Th 7',
    'CN',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final monthStart = DateTime(month.year, month.month, 1);
    final firstWeekday = monthStart.weekday; // 1 = Mon, 7 = Sun
    final gridStart = monthStart.subtract(Duration(days: firstWeekday - 1));

    // Calculate total days (typically 5 or 6 weeks)
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final totalCells = (firstWeekday - 1 + daysInMonth <= 35) ? 35 : 42;
    final totalWeeks = totalCells ~/ 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Month Navigation Header (<  Tháng 6, 2025  >  [ Hôm nay ])
        _buildMonthNavigator(context, isDark),

        const SizedBox(height: ADaySpacing.md),

        // 2. Weekdays Header (Th 2 ... CN)
        _buildWeekdayHeader(context, isDark),

        const SizedBox(height: 6.0),

        // 3. Multi-Week Grid
        ...List.generate(totalWeeks, (weekIndex) {
          final weekStart = gridStart.add(Duration(days: weekIndex * 7));
          final weekDays = List.generate(
            7,
            (dayIndex) => weekStart.add(Duration(days: dayIndex)),
          );
          return _buildWeekRow(context, weekIndex, weekDays, isDark);
        }),

        const SizedBox(height: ADaySpacing.lg),
      ],
    );
  }

  /// Month Navigator Header matching Image 3
  Widget _buildMonthNavigator(BuildContext context, bool isDark) {
    final title = 'Tháng ${month.month}, ${month.year}';
    final now = DateTime.now();
    final isCurrentMonth = month.year == now.year && month.month == now.month;

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
            onPressed: onPrevMonth,
            icon: const Icon(Icons.chevron_left_rounded, size: 24.0),
            color: isDark ? Colors.white70 : ADayColors.brandNavy,
            tooltip: 'Tháng trước',
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: ADayTypography.fontFamily,
                fontSize: 17.0,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : ADayColors.brandNavy,
              ),
            ),
          ),
          IconButton(
            onPressed: onNextMonth,
            icon: const Icon(Icons.chevron_right_rounded, size: 24.0),
            color: isDark ? Colors.white70 : ADayColors.brandNavy,
            tooltip: 'Tháng sau',
          ),
          if (!isCurrentMonth && onTodayTap != null)
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

  /// Weekdays Header row: Th 2, Th 3, ..., CN
  Widget _buildWeekdayHeader(BuildContext context, bool isDark) {
    return Row(
      children: _weekdays
          .map((w) {
            final isWeekend = w == 'CN';
            return Expanded(
              child: Text(
                w,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: ADayTypography.fontFamily,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  color: isWeekend
                      ? const Color(0xFFF43F5E)
                      : (isDark ? Colors.white54 : const Color(0xFF64748B)),
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }

  /// Builds a 7-day week row, with optional cross-week goal banner at top
  Widget _buildWeekRow(
    BuildContext context,
    int weekIndex,
    List<DateTime> weekDays,
    bool isDark,
  ) {
    final banner = _findBannerForWeek(weekDays);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // If a long-term goal/challenge covers this week, render horizontal banner
          if (banner != null) ...[
            _buildCrossWeekBanner(context, banner, isDark),
            const SizedBox(height: 3.0),
          ],

          // 7-day cell row
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: weekDays
                  .map((day) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: _buildDayCell(context, day, isDark),
                      ),
                    );
                  })
                  .toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }

  /// Cross-week banner matching Image 3 (e.g. 🎯 Mục tiêu: ..., ⚡ Thử thách 7 ngày: ..., 🚩 Dự án: ...)
  Widget _buildCrossWeekBanner(
    BuildContext context,
    _WeekBanner banner,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: banner.backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Text(banner.iconEmoji, style: const TextStyle(fontSize: 12.0)),
          const SizedBox(width: 4.0),
          Expanded(
            child: Text(
              banner.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: ADayTypography.fontFamily,
                fontSize: 11.0,
                fontWeight: FontWeight.w700,
                color: banner.textColor,
              ),
            ),
          ),
          if (banner.hasChevron)
            Icon(
              Icons.chevron_right_rounded,
              size: 14.0,
              color: banner.textColor.withValues(alpha: 0.7),
            ),
        ],
      ),
    );
  }

  /// A single Day cell in the 7-column grid
  Widget _buildDayCell(BuildContext context, DateTime day, bool isDark) {
    final isSelected =
        day.year == selectedDay.year &&
        day.month == selectedDay.month &&
        day.day == selectedDay.day;
    final isCurrentMonth = day.month == month.month;
    final now = DateTime.now();
    final isToday =
        day.year == now.year && day.month == now.month && day.day == now.day;

    final dayTasks = tasksForDay(day);

    // Cell background and border
    final cellBg = isDark ? const Color(0xFF131A29) : Colors.white;
    final cellBorder = isSelected
        ? const Color(0xFF3B82F6)
        : (isDark ? const Color(0xFF1E2638) : const Color(0xFFE8EEF4));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onDayTap != null ? () => onDayTap!(day) : null,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          constraints: const BoxConstraints(minHeight: 74.0),
          padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
          decoration: BoxDecoration(
            color: cellBg,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: cellBorder,
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
                      blurRadius: 6.0,
                      spreadRadius: 1.0,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Day Number Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontFamily: ADayTypography.fontFamily,
                      fontSize: 12.0,
                      fontWeight: isToday || isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: isToday
                          ? const Color(0xFF3B82F6)
                          : (!isCurrentMonth
                                ? (isDark
                                      ? const Color(0xFF475569)
                                      : const Color(0xFFCBD5E1))
                                : (isDark
                                      ? Colors.white
                                      : ADayColors.brandNavy)),
                    ),
                  ),
                  if (isToday)
                    Container(
                      width: 5.0,
                      height: 5.0,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3B82F6),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 3.0),

              // Task Pills stacked vertically
              ..._buildDayPills(context, dayTasks, isDark),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds up to 2 task pills + overflow or reminder chip
  List<Widget> _buildDayPills(
    BuildContext context,
    List<TaskViewItem> dayTasks,
    bool isDark,
  ) {
    final widgets = <Widget>[];

    // Show up to 2 pills
    final maxPills = 2;
    final visibleTasks = dayTasks.take(maxPills).toList();

    for (final task in visibleTasks) {
      final pillStyle = _pillStyleForTask(task.title, isDark);
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 2.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: pillStyle.background,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              task.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: ADayTypography.fontFamily,
                fontSize: 9.0,
                fontWeight: FontWeight.w700,
                color: pillStyle.text,
              ),
            ),
          ),
        ),
      );
    }

    // Overflow chip if > 2 tasks
    if (dayTasks.length > maxPills) {
      final overflow = dayTasks.length - maxPills;
      widgets.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 1.5),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF26334D) : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Text(
            '+$overflow việc khác',
            maxLines: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: ADayTypography.fontFamily,
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF475569),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  /// Determines cross-week banner for a given week from long-term goals
  _WeekBanner? _findBannerForWeek(List<DateTime> weekDays) {
    final weekStart = weekDays.first;
    final weekEnd = weekDays.last;

    for (final goal in longTermGoals) {
      final start = DateTime(
        goal.startDate.year,
        goal.startDate.month,
        goal.startDate.day,
      );
      final end = goal.deadline != null
          ? DateTime(
              goal.deadline!.year,
              goal.deadline!.month,
              goal.deadline!.day,
            )
          : start.add(const Duration(days: 30));

      if (!weekEnd.isBefore(start) && !weekStart.isAfter(end)) {
        final title = goal.title.toLowerCase();
        if (title.contains('thử thách') || title.contains('challenge')) {
          return _WeekBanner(
            iconEmoji: '⚡',
            title: goal.title.startsWith('Thử thách')
                ? goal.title
                : 'Thử thách: ${goal.title}',
            backgroundColor: const Color(0xFF6366F1),
            textColor: Colors.white,
          );
        } else if (title.contains('dự án') || title.contains('project')) {
          return _WeekBanner(
            iconEmoji: '🚩',
            title: goal.title.startsWith('Dự án')
                ? goal.title
                : 'Dự án: ${goal.title}',
            backgroundColor: const Color(0xFF0D9488),
            textColor: Colors.white,
            hasChevron: true,
          );
        } else {
          return _WeekBanner(
            iconEmoji: '🎯',
            title: goal.title.startsWith('Mục tiêu')
                ? goal.title
                : 'Mục tiêu: ${goal.title}',
            backgroundColor: const Color(0xFF059669),
            textColor: Colors.white,
          );
        }
      }
    }

    return null;
  }

  /// Category pill styling matching Image 3
  _PillStyle _pillStyleForTask(String title, bool isDark) {
    final lower = title.toLowerCase();

    // Pink: Đọc sách, Đi chợ
    if (lower.contains('sách') ||
        lower.contains('đọc') ||
        lower.contains('chợ') ||
        lower.contains('mua')) {
      return _PillStyle(
        background: isDark ? const Color(0xFFE11D48) : const Color(0xFFFFE4E6),
        text: isDark ? Colors.white : const Color(0xFFBE123C),
      );
    }

    // Orange: Tập thể dục
    if (lower.contains('dục') ||
        lower.contains('thể thao') ||
        lower.contains('chạy') ||
        lower.contains('gym')) {
      return _PillStyle(
        background: isDark ? const Color(0xFFEA580C) : const Color(0xFFFFEDD5),
        text: isDark ? Colors.white : const Color(0xFFC2410C),
      );
    }

    // Blue: Họp nhóm, Lên kế hoạch, Học Flutter
    if (lower.contains('họp') ||
        lower.contains('nhóm') ||
        lower.contains('kế hoạch') ||
        lower.contains('flutter') ||
        lower.contains('học')) {
      return _PillStyle(
        background: isDark ? const Color(0xFF2563EB) : const Color(0xFFDBEAFE),
        text: isDark ? Colors.white : const Color(0xFF1D4ED8),
      );
    }

    // Yellow: Báo cáo, Công việc
    if (lower.contains('báo cáo') ||
        lower.contains('viết') ||
        lower.contains('công việc')) {
      return _PillStyle(
        background: isDark ? const Color(0xFFD97706) : const Color(0xFFFEF3C7),
        text: isDark ? Colors.white : const Color(0xFFB45309),
      );
    }

    // Teal: Thiền, Nghỉ ngơi
    if (lower.contains('thiền') ||
        lower.contains('tâm trí') ||
        lower.contains('nghỉ')) {
      return _PillStyle(
        background: isDark ? const Color(0xFF0D9488) : const Color(0xFFCCFBF1),
        text: isDark ? Colors.white : const Color(0xFF0F766E),
      );
    }

    // Default: Cool blue
    return _PillStyle(
      background: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
      text: isDark ? Colors.white : const Color(0xFF334155),
    );
  }
}

class _WeekBanner {
  const _WeekBanner({
    required this.iconEmoji,
    required this.title,
    required this.backgroundColor,
    required this.textColor,
    this.hasChevron = false,
  });

  final String iconEmoji;
  final String title;
  final Color backgroundColor;
  final Color textColor;
  final bool hasChevron;
}

class _PillStyle {
  const _PillStyle({required this.background, required this.text});
  final Color background;
  final Color text;
}
