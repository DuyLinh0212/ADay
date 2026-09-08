import 'package:flutter/material.dart';

import '../../../core/theme/aday_colors.dart';
import '../../../core/theme/aday_spacing.dart';
import '../../../core/theme/aday_typography.dart';
import '../../../domain/models/goal.dart';
import '../../models/task_view_item.dart';
import '../../widgets/aday_bottom_nav.dart';
import '../../widgets/aday_logo_header.dart';
import '../../widgets/mountain_sun_visual.dart';
import '../../widgets/section_surface.dart';
import '../../widgets/task_goal_row.dart';
import '../statistics/statistics_view_data.dart';
import '../statistics/widgets/calendar_month_view.dart';
import 'widgets/calendar_detailed_month_view.dart';
import 'widgets/calendar_timeline_view.dart';

/// The dedicated Calendar and Daily Schedule presentation screen for ADay (Tab 1).
/// Supports 3 view modes:
/// 1. Timeline (Mốc thời gian - Image 2)
/// 2. Month (Tháng)
/// 3. Detailed (Chi tiết - Image 3)
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({
    super.key,
    required this.calendarData,
    required this.selectedDay,
    required this.tasks,
    this.tasksForDay,
    this.longTermGoals = const [],
    this.dailyReminderMinute,
    this.showHeader = true,
    this.showBottomNav = true,
    this.bottomNavIndex = 1,
    this.hasUnreadNotifications = false,
    this.avatarInitials = 'M',
    this.onLogoTap,
    this.onSearchTap,
    this.onNotificationTap,
    this.onAvatarTap,
    this.onDayTap,
    this.onPrevDay,
    this.onNextDay,
    this.onPrevMonth,
    this.onNextMonth,
    this.onTodayTap,
    this.onTodaySummaryTap,
    this.onToggleTask,
    this.onTaskTap,
    this.onAddTask,
    this.onCreateGoalTap,
    this.onNavTap,
  });

  final CalendarMonthData calendarData;
  final DateTime selectedDay;
  final List<TaskViewItem> tasks;
  final List<TaskViewItem> Function(DateTime day)? tasksForDay;
  final List<Goal> longTermGoals;
  final int? dailyReminderMinute;
  final bool showHeader;
  final bool showBottomNav;
  final int bottomNavIndex;
  final bool hasUnreadNotifications;
  final String avatarInitials;

  final VoidCallback? onLogoTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;
  final ValueChanged<CalendarDayData>? onDayTap;
  final VoidCallback? onPrevDay;
  final VoidCallback? onNextDay;
  final VoidCallback? onPrevMonth;
  final VoidCallback? onNextMonth;
  final VoidCallback? onTodayTap;
  final VoidCallback? onTodaySummaryTap;
  final void Function(TaskViewItem task, bool isCompleted)? onToggleTask;
  final ValueChanged<TaskViewItem>? onTaskTap;
  final VoidCallback? onAddTask;
  final VoidCallback? onCreateGoalTap;
  final ValueChanged<int>? onNavTap;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

enum _CalendarMode { timeline, month, detailed }

class _CalendarScreenState extends State<CalendarScreen> {
  _CalendarMode _mode = _CalendarMode.timeline;

  CalendarMonthData get calendarData => widget.calendarData;
  DateTime get selectedDay => widget.selectedDay;
  List<TaskViewItem> get tasks => widget.tasks;
  bool get showHeader => widget.showHeader;
  bool get showBottomNav => widget.showBottomNav;
  int get bottomNavIndex => widget.bottomNavIndex;
  bool get hasUnreadNotifications => widget.hasUnreadNotifications;
  String get avatarInitials => widget.avatarInitials;
  VoidCallback? get onLogoTap => widget.onLogoTap;
  VoidCallback? get onSearchTap => widget.onSearchTap;
  VoidCallback? get onNotificationTap => widget.onNotificationTap;
  VoidCallback? get onAvatarTap => widget.onAvatarTap;
  ValueChanged<CalendarDayData>? get onDayTap => widget.onDayTap;
  VoidCallback? get onPrevDay => widget.onPrevDay;
  VoidCallback? get onNextDay => widget.onNextDay;
  VoidCallback? get onPrevMonth => widget.onPrevMonth;
  VoidCallback? get onNextMonth => widget.onNextMonth;
  VoidCallback? get onTodayTap => widget.onTodayTap;
  VoidCallback? get onTodaySummaryTap => widget.onTodaySummaryTap;
  void Function(TaskViewItem task, bool isCompleted)? get onToggleTask =>
      widget.onToggleTask;
  ValueChanged<TaskViewItem>? get onTaskTap => widget.onTaskTap;
  VoidCallback? get onAddTask => widget.onAddTask;
  VoidCallback? get onCreateGoalTap => widget.onCreateGoalTap;
  ValueChanged<int>? get onNavTap => widget.onNavTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final completedCount = tasks.where((t) => t.isCompleted).length;
    final formattedDate = '${selectedDay.day}/${selectedDay.month}';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : ADayColors.canvas,
      body: SafeArea(
        bottom: !showBottomNav,
        child: Column(
          children: [
            // 1. Top Header Bar
            if (showHeader)
              ADayHeaderBar(
                onLogoTap: onLogoTap,
                onSearchTap: onSearchTap,
                onNotificationTap: onNotificationTap,
                onAvatarTap: onAvatarTap,
                hasUnreadNotifications: hasUnreadNotifications,
                avatarInitials: avatarInitials,
              ),

            // 2. Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: ADaySpacing.md,
                  vertical: ADaySpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title Section
                    _buildTitleSection(context, isDark),

                    const SizedBox(height: ADaySpacing.md),

                    // 3-Mode Switcher: [ ≡ Mốc thời gian | 📅 Tháng | ⊞ Chi tiết ]
                    _CalendarModeSwitch(
                      value: _mode,
                      onChanged: (value) => setState(() => _mode = value),
                    ),

                    const SizedBox(height: ADaySpacing.md),

                    // Content based on Mode
                    if (_mode == _CalendarMode.timeline)
                      CalendarTimelineView(
                        day: selectedDay,
                        tasks: tasks,
                        onToggleTask: onToggleTask,
                        onTaskTap: onTaskTap,
                        onPrevDay: onPrevDay,
                        onNextDay: onNextDay,
                        onTodayTap: onTodayTap,
                        onAddTask: onAddTask,
                      )
                    else if (_mode == _CalendarMode.month) ...[
                      CalendarMonthView(
                        data: calendarData,
                        onDayTap: onDayTap,
                        onPrevMonth: onPrevMonth,
                        onNextMonth: onNextMonth,
                        onTodayTap: onTodayTap,
                        onTodaySummaryTap: onTodaySummaryTap,
                      ),
                      const SizedBox(height: ADaySpacing.md),

                      // Selected Day's Agenda
                      SectionSurface(
                        title: 'Kế hoạch ngày $formattedDate',
                        icon: Icons.calendar_today_rounded,
                        iconColor: ADayColors.actionBlue,
                        iconBackgroundColor: ADayColors.actionBlueTint,
                        actionLabel: 'Thêm',
                        onActionTap: onAddTask,
                        child: tasks.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: ADaySpacing.lg,
                                  horizontal: ADaySpacing.md,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.event_available_rounded,
                                      size: 40.0,
                                      color: ADayColors.mutedInk.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: ADaySpacing.sm),
                                    Text(
                                      'Chưa có kế hoạch cho ngày $formattedDate',
                                      style: ADayTypography.body.copyWith(
                                        color: isDark
                                            ? Colors.white70
                                            : ADayColors.mutedInk,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: ADaySpacing.sm),
                                    TextButton.icon(
                                      onPressed: onAddTask,
                                      icon: const Icon(Icons.add_rounded),
                                      label: const Text(
                                        'Thêm mục tiêu / nhiệm vụ',
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: ADaySpacing.sm,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Hoàn thành $completedCount/${tasks.length} nhiệm vụ',
                                          style: ADayTypography.caption
                                              .copyWith(
                                                color: isDark
                                                    ? Colors.white54
                                                    : ADayColors.mutedInk,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ...List.generate(tasks.length, (index) {
                                    final task = tasks[index];
                                    final isLast = index == tasks.length - 1;
                                    return TaskGoalRow(
                                      item: task,
                                      showDivider: !isLast,
                                      onToggleCompleted: onToggleTask != null
                                          ? (val) => onToggleTask!(task, val)
                                          : null,
                                      onTap: onTaskTap != null
                                          ? () => onTaskTap!(task)
                                          : null,
                                    );
                                  }),
                                ],
                              ),
                      ),
                    ] else
                      CalendarDetailedMonthView(
                        month: DateTime(calendarData.year, calendarData.month),
                        selectedDay: selectedDay,
                        tasksForDay: widget.tasksForDay ?? (_) => tasks,
                        longTermGoals: widget.longTermGoals,
                        dailyReminderMinute: widget.dailyReminderMinute,
                        onDayTap: (day) {
                          if (onDayTap != null) {
                            // Find matching CalendarDayData or construct
                            CalendarDayData? matched;
                            for (final d in calendarData.days) {
                              if (d.date.year == day.year &&
                                  d.date.month == day.month &&
                                  d.date.day == day.day) {
                                matched = d;
                                break;
                              }
                            }
                            onDayTap!(
                              matched ??
                                  CalendarDayData(
                                    date: day,
                                    dayNumber: day.day,
                                    isCurrentMonth:
                                        day.month == calendarData.month,
                                    isToday: false,
                                    isSelected: true,
                                    status: CalendarDayStatus.none,
                                    completedTasks: 0,
                                    totalTasks: 0,
                                  ),
                            );
                          }
                        },
                        onPrevMonth: onPrevMonth,
                        onNextMonth: onNextMonth,
                        onTodayTap: onTodayTap,
                        onAddTask: onAddTask,
                      ),

                    const SizedBox(height: ADaySpacing.lg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: showBottomNav
          ? ADayBottomNav(
              currentIndex: bottomNavIndex,
              onTap: onNavTap ?? (_) {},
              onCreateGoalTap: onCreateGoalTap,
            )
          : null,
    );
  }

  Widget _buildTitleSection(BuildContext context, bool isDark) {
    final String title;
    final String subtitle;
    final String? quote;

    switch (_mode) {
      case _CalendarMode.timeline:
        title = 'Lịch';
        subtitle = 'Theo dõi kế hoạch hôm nay theo mốc thời gian.';
        quote = '“Mỗi ngày có kế hoạch là một ngày ý nghĩa hơn.”';
      case _CalendarMode.detailed:
        title = 'Lịch';
        subtitle = 'Xem lại kế hoạch của bạn trong chế độ tháng chi tiết.';
        quote = null;
      case _CalendarMode.month:
        title = 'Lịch & Kế hoạch';
        subtitle = 'Theo dõi hành trình và kế hoạch chi tiết theo ngày.';
        quote = null;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -15.0,
          right: -10.0,
          width: 140.0,
          height: 80.0,
          child: const MountainSunVisual(
            height: 80.0,
            showFlag: false,
            showSunRays: true,
            sunPosition: Offset(0.75, 0.35),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: ADayTypography.headline.copyWith(
                fontSize: 26.0,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : ADayColors.brandNavy,
              ),
            ),
            const SizedBox(height: 3.0),
            Text(
              subtitle,
              style: ADayTypography.subhead.copyWith(
                fontSize: 14.0,
                height: 1.4,
                color: isDark ? Colors.white70 : ADayColors.mutedInk,
              ),
            ),
            if (quote != null) ...[
              const SizedBox(height: 4.0),
              Text(
                quote,
                style: TextStyle(
                  fontFamily: ADayTypography.fontFamily,
                  fontSize: 12.0,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFF60A5FA)
                      : const Color(0xFF168AF2),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _CalendarModeSwitch extends StatelessWidget {
  const _CalendarModeSwitch({required this.value, required this.onChanged});

  final _CalendarMode value;
  final ValueChanged<_CalendarMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2638) : ADayColors.coolSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _ModeButton(
            label: 'Mốc thời gian',
            icon: Icons.view_timeline_rounded,
            selected: value == _CalendarMode.timeline,
            onTap: () => onChanged(_CalendarMode.timeline),
          ),
          _ModeButton(
            label: 'Tháng',
            icon: Icons.calendar_month_rounded,
            selected: value == _CalendarMode.month,
            onTap: () => onChanged(_CalendarMode.month),
          ),
          _ModeButton(
            label: 'Chi tiết',
            icon: Icons.grid_view_rounded,
            selected: value == _CalendarMode.detailed,
            onTap: () => onChanged(_CalendarMode.detailed),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeBg = isDark ? const Color(0xFF2E3A52) : ADayColors.surface;

    return Expanded(
      child: Material(
        color: selected ? activeBg : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 17,
                  color: selected
                      ? (isDark
                            ? const Color(0xFF60A5FA)
                            : Theme.of(context).colorScheme.primary)
                      : (isDark ? Colors.white54 : ADayColors.mutedInk),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: ADayTypography.caption.copyWith(
                      color: selected
                          ? (isDark ? Colors.white : ADayColors.brandNavy)
                          : (isDark ? Colors.white54 : ADayColors.mutedInk),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
