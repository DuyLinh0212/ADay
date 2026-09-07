import 'package:flutter/material.dart';

import '../../../core/theme/aday_colors.dart';
import '../../../core/theme/aday_spacing.dart';
import '../../../core/theme/aday_typography.dart';
import '../../models/task_view_item.dart';
import '../../widgets/aday_bottom_nav.dart';
import '../../widgets/aday_logo_header.dart';
import '../../widgets/mountain_sun_visual.dart';
import '../../widgets/section_surface.dart';
import '../../widgets/task_goal_row.dart';
import '../statistics/statistics_view_data.dart';
import '../statistics/widgets/calendar_month_view.dart';

/// The dedicated Calendar and Daily Schedule presentation screen for ADay (Tab 1).
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({
    super.key,
    required this.calendarData,
    required this.selectedDay,
    required this.tasks,
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
    this.onPrevMonth,
    this.onNextMonth,
    this.onTodayTap,
    this.onTodaySummaryTap,
    this.onToggleTask,
    this.onTaskTap,
    this.onAddTask,
    this.onNavTap,
  });

  final CalendarMonthData calendarData;
  final DateTime selectedDay;
  final List<TaskViewItem> tasks;
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
  final VoidCallback? onPrevMonth;
  final VoidCallback? onNextMonth;
  final VoidCallback? onTodayTap;
  final VoidCallback? onTodaySummaryTap;
  final void Function(TaskViewItem task, bool isCompleted)? onToggleTask;
  final ValueChanged<TaskViewItem>? onTaskTap;
  final VoidCallback? onAddTask;
  final ValueChanged<int>? onNavTap;

  @override
  Widget build(BuildContext context) {
    final completedCount = tasks.where((t) => t.isCompleted).length;
    final formattedDate = '${selectedDay.day}/${selectedDay.month}';

    return Scaffold(
      backgroundColor: ADayColors.canvas,
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
                    _buildTitleSection(context),

                    const SizedBox(height: ADaySpacing.md),

                    // Month Calendar View
                    CalendarMonthView(
                      data: calendarData,
                      onDayTap: onDayTap,
                      onPrevMonth: onPrevMonth,
                      onNextMonth: onNextMonth,
                      onTodayTap: onTodayTap,
                      onTodaySummaryTap: onTodaySummaryTap,
                    ),

                    const SizedBox(height: ADaySpacing.md),

                    // Tasks for Selected Day
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
                                      color: ADayColors.mutedInk,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: ADaySpacing.sm),
                                  TextButton.icon(
                                    onPressed: onAddTask,
                                    icon: const Icon(Icons.add_rounded),
                                    label: const Text('Thêm mục tiêu / nhiệm vụ'),
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
                                        style: ADayTypography.caption.copyWith(
                                          color: ADayColors.mutedInk,
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
            )
          : null,
    );
  }

  Widget _buildTitleSection(BuildContext context) {
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
              'Lịch & Kế hoạch',
              style: ADayTypography.headline.copyWith(
                fontSize: 26.0,
                fontWeight: FontWeight.w800,
                color: ADayColors.brandNavy,
              ),
            ),
            const SizedBox(height: 3.0),
            Text(
              'Theo dõi hành trình và kế hoạch chi tiết theo ngày.',
              style: ADayTypography.subhead.copyWith(
                fontSize: 14.0,
                height: 1.4,
                color: ADayColors.mutedInk,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
