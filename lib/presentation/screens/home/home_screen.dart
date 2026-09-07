import 'package:flutter/material.dart';

import '../../../core/theme/aday_colors.dart';
import '../../../core/theme/aday_spacing.dart';
import '../../../core/theme/aday_typography.dart';
import '../../../domain/models/task_item.dart';
import '../../models/goal_view_item.dart';
import '../../models/progress_summary_data.dart';
import '../../models/task_view_item.dart';
import '../../widgets/aday_bottom_nav.dart';
import '../../widgets/aday_logo_header.dart';
import '../../widgets/aday_reminder_card.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/mountain_sun_visual.dart';
import '../../widgets/progress_summary_hero.dart';
import '../../widgets/section_surface.dart';
import '../../widgets/task_goal_row.dart';

/// The primary Home presentation screen for ADay, matching TrangChu.png.
///
/// Follows DESIGN.md and PRODUCT.md strictly:
/// - Creative North Star: "Bình minh có kế hoạch" (Sunrise with a plan).
/// - Today is always the clearest starting point.
/// - Accepts all data and callbacks through public constructor parameters;
///   no repository imports or business calculations.
/// - Resilient to textScaleFactor up to 1.5 and narrow phone viewports.
/// - Minimum 44x44 touch targets for WCAG 2.2 AA compliance.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.greeting = 'Xin chào, Minh!',
    this.greetingSubtext =
        'Hôm nay là một ngày tuyệt vời để tiến về phiên bản tốt hơn của bạn. 💙',
    this.greetingQuote = '“Những kế hoạch nhỏ tạo nên ngày mai lớn hơn.”',
    this.progressData,
    this.todayTasks,
    this.longTermGoal,
    this.showEveningReminder = true,
    this.reminderTitle = 'Đừng quên nhé!',
    this.reminderMessage =
        'Trước 22:00, ADay sẽ nhắc bạn cập nhật tiến độ và tạo kế hoạch cho ngày mai.',
    this.reminderActionLabel = 'Tạo kế hoạch ngày mai',
    this.hasUnreadNotifications = true,
    this.avatarInitials = 'M',
    this.avatarImage,
    this.showHeader = true,
    this.showBottomNav = true,
    this.bottomNavIndex = 0,
    this.onLogoTap,
    this.onSearchTap,
    this.onNotificationTap,
    this.onAvatarTap,
    this.onProgressCardTap,
    this.onToggleTask,
    this.onTaskTap,
    this.onViewAllTodayTasks,
    this.onAddTodayTask,
    this.onViewAllLongTermGoals,
    this.onViewLongTermGoalAction,
    this.onCreateLongTermGoal,
    this.onReminderAction,
    this.onGreetingQuoteTap,
    this.onCreateGoalTap,
    this.onNavTap,
  });

  /// User greeting title (e.g. "Xin chào, Minh!").
  final String greeting;

  /// Motivational subtext below greeting.
  final String greetingSubtext;

  /// Header banner quote displayed next to the sunrise visual.
  final String greetingQuote;

  /// Progress hero data. If null, a sample matching TrangChu.png is used.
  final ProgressSummaryData? progressData;

  /// Today's tasks list. If null, sample tasks matching TrangChu.png are used.
  final List<TaskViewItem>? todayTasks;

  /// Long-term goal summary item. If null, sample goal item is used.
  final GoalViewItem? longTermGoal;

  /// Whether to display the pre-22:00 reminder banner.
  final bool showEveningReminder;

  /// Reminder card title.
  final String reminderTitle;

  /// Reminder card message.
  final String reminderMessage;

  /// Reminder card button label.
  final String reminderActionLabel;

  /// Whether the notification bell displays an unread indicator.
  final bool hasUnreadNotifications;

  /// Initials displayed inside the profile avatar.
  final String avatarInitials;
  final ImageProvider? avatarImage;

  /// Whether to show the top header bar.
  final bool showHeader;

  /// Whether to show the bottom navigation bar.
  final bool showBottomNav;

  /// Active tab index for the bottom navigation bar (default: 0).
  final int bottomNavIndex;

  // --- Callbacks ---
  final VoidCallback? onLogoTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onProgressCardTap;
  final void Function(TaskViewItem task, bool isCompleted)? onToggleTask;
  final ValueChanged<TaskViewItem>? onTaskTap;
  final VoidCallback? onViewAllTodayTasks;
  final VoidCallback? onAddTodayTask;
  final VoidCallback? onViewAllLongTermGoals;
  final VoidCallback? onViewLongTermGoalAction;
  final VoidCallback? onCreateLongTermGoal;
  final VoidCallback? onReminderAction;
  final VoidCallback? onGreetingQuoteTap;
  final VoidCallback? onCreateGoalTap;
  final ValueChanged<int>? onNavTap;

  /// Sample progress data matching TrangChu.png (67%, 4/6 completed).
  static ProgressSummaryData get sampleProgressData {
    return ProgressSummaryData(
      date: _SampleDate.today,
      dateLabel: 'Thứ Ba, 24 tháng 6, 2025',
      quote: 'Kiên trì hôm nay,\nthành công ngày mai!',
      completedCount: 4,
      totalCount: 6,
      remainingCount: 2,
      overdueCount: 0,
    );
  }

  /// Sample tasks matching TrangChu.png list.
  static List<TaskViewItem> get sampleTasks {
    return const [
      TaskViewItem(
        id: 'task_1',
        title: 'Đọc sách 30 phút',
        subtitle: 'Phát triển bản thân',
        category: 'Sách',
        icon: Icons.menu_book_rounded,
        iconColor: Color(0xFF168AF2),
        iconBackgroundColor: Color(0xFFE8F3FD),
        isAllDay: true,
        status: TaskStatus.completed,
      ),
      TaskViewItem(
        id: 'task_2',
        title: 'Tập thể dục',
        subtitle: 'Sức khỏe là nền tảng',
        category: 'Thể thao',
        icon: Icons.fitness_center_rounded,
        iconColor: Color(0xFF0EB8AC),
        iconBackgroundColor: Color(0xFFE6F8F7),
        isAllDay: true,
        status: TaskStatus.completed,
      ),
      TaskViewItem(
        id: 'task_3',
        title: 'Họp nhóm dự án',
        subtitle: 'Trao đổi tiến độ tuần này',
        category: 'Họp nhóm',
        icon: Icons.people_alt_rounded,
        iconColor: Color(0xFF7A5AF8),
        iconBackgroundColor: Color(0xFFF4F0FD),
        timeLabel: '10:00 – 11:00',
        isAllDay: false,
        status: TaskStatus.pending,
      ),
      TaskViewItem(
        id: 'task_4',
        title: 'Hoàn thành báo cáo tháng',
        subtitle: 'Công việc',
        category: 'Báo cáo',
        icon: Icons.description_rounded,
        iconColor: Color(0xFF20C99A),
        iconBackgroundColor: Color(0xFFEAF9F5),
        timeLabel: '14:00 – 16:00',
        isAllDay: false,
        status: TaskStatus.completed,
      ),
      TaskViewItem(
        id: 'task_5',
        title: 'Học Flutter 1 giờ',
        subtitle: 'Nâng cao kỹ năng',
        category: 'Lập trình',
        icon: Icons.code_rounded,
        iconColor: Color(0xFF168AF2),
        iconBackgroundColor: Color(0xFFE8F3FD),
        timeLabel: '20:00 – 21:00',
        isAllDay: false,
        status: TaskStatus.pending,
      ),
      TaskViewItem(
        id: 'task_6',
        title: 'Thiền 10 phút',
        subtitle: 'Giữ tâm trí bình an',
        category: 'Thiền',
        icon: Icons.spa_rounded,
        iconColor: Color(0xFFFF9E2C),
        iconBackgroundColor: Color(0xFFFFF6EB),
        isAllDay: true,
        status: TaskStatus.pending,
      ),
    ];
  }

  /// Sample long term goal matching TrangChu.png.
  static GoalViewItem get sampleLongTermGoal {
    return GoalViewItem.sampleHome();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveProgress =
        progressData ??
        ProgressSummaryData.fromCounts(
          date: DateTime.now(),
          dateLabel: 'Hôm nay',
          completed: 0,
          total: 0,
        );
    final effectiveTasks = todayTasks ?? const <TaskViewItem>[];
    final effectiveLongTermGoal = longTermGoal;

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
                avatarImage: avatarImage,
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
                    // A. Greeting & Sunrise Illustration
                    _buildGreetingSection(context),

                    const SizedBox(height: ADaySpacing.md),

                    // B. Meaningful Progress Hero Card
                    ProgressSummaryHero(
                      data: effectiveProgress,
                      onTap: onProgressCardTap,
                    ),

                    const SizedBox(height: ADaySpacing.md),

                    // C. Today's Goals/Tasks Section
                    _buildTodayTasksSection(context, effectiveTasks),

                    const SizedBox(height: ADaySpacing.md),

                    // D. Long-Term Goal Summary
                    _buildLongTermGoalSection(context, effectiveLongTermGoal),

                    // E. Pre-22:00 Reminder Card
                    if (showEveningReminder) ...[
                      const SizedBox(height: ADaySpacing.md),
                      ADayReminderCard(
                        title: reminderTitle,
                        message: reminderMessage,
                        actionLabel: reminderActionLabel,
                        onActionTap: onReminderAction,
                      ),
                    ],

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

  /// Builds the greeting banner with responsive layout and sunrise illustration.
  Widget _buildGreetingSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;

        return Semantics(
          header: true,
          label: '$greeting. $greetingSubtext. $greetingQuote',
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Background soft mountain & sunrise illustration
              Positioned(
                top: -8.0,
                right: -12.0,
                width: isNarrow ? 130.0 : 160.0,
                height: 110.0,
                child: const MountainSunVisual(
                  height: 110.0,
                  showSunRays: true,
                  sunPosition: Offset(0.72, 0.35),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.only(
                  top: ADaySpacing.xs,
                  bottom: ADaySpacing.xs,
                  right: ADaySpacing.xs,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting texts
                    Expanded(
                      flex: isNarrow ? 6 : 7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            greeting,
                            style: ADayTypography.headline.copyWith(
                              fontSize: isNarrow ? 24.0 : 28.0,
                            ),
                          ),
                          const SizedBox(height: ADaySpacing.xs),
                          Text(
                            greetingSubtext,
                            style: ADayTypography.subhead.copyWith(
                              fontSize: isNarrow ? 13.5 : 15.0,
                              height: 1.4,
                              color: ADayColors.brandNavy.withValues(
                                alpha: 0.85,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: ADaySpacing.sm),

                    // Quote on right
                    Expanded(
                      flex: isNarrow ? 4 : 4,
                      child: InkWell(
                        onTap: onGreetingQuoteTap,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                greetingQuote,
                                textAlign: TextAlign.right,
                                style: ADayTypography.quote.copyWith(
                                  fontSize: isNarrow ? 11.0 : 12.5,
                                  color: ADayColors.brandNavy.withValues(
                                    alpha: 0.72,
                                  ),
                                ),
                              ),
                              if (onGreetingQuoteTap != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Icon(
                                    Icons.edit_outlined,
                                    size: 14,
                                    color: ADayColors.actionBlue,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the "Mục tiêu hôm nay" list section with empty state fallback.
  Widget _buildTodayTasksSection(
    BuildContext context,
    List<TaskViewItem> tasks,
  ) {
    return SectionSurface(
      title: 'Mục tiêu hôm nay',
      icon: Icons.checklist_rounded,
      iconColor: ADayColors.actionBlue,
      iconBackgroundColor: ADayColors.actionBlueTint,
      actionLabel: 'Xem tất cả',
      onActionTap: onViewAllTodayTasks,
      child: tasks.isEmpty
          ? EmptyStateView.noTasksToday(onAddTask: onAddTodayTask)
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(tasks.length, (index) {
                final task = tasks[index];
                final isLast = index == tasks.length - 1;

                return TaskGoalRow(
                  item: task,
                  showDivider: !isLast,
                  onToggleCompleted: onToggleTask != null
                      ? (isCompleted) => onToggleTask!(task, isCompleted)
                      : null,
                  onTap: onTaskTap != null ? () => onTaskTap!(task) : null,
                );
              }),
            ),
    );
  }

  /// Builds the "Mục tiêu dài hạn" summary card with empty state fallback.
  Widget _buildLongTermGoalSection(BuildContext context, GoalViewItem? goal) {
    if (goal == null) {
      return SectionSurface(
        title: 'Mục tiêu dài hạn',
        icon: Icons.track_changes_rounded,
        child: EmptyStateView.noLongTermGoals(
          onCreateGoal: onCreateLongTermGoal,
        ),
      );
    }

    final activeCount = goal.activeGoalsCount;
    final activeText = goal.subtitle ?? '$activeCount mục tiêu đang thực hiện';

    return MountainSunGoalCard(
      title: goal.title,
      activeCountText: activeText,
      quote: goal.quote,
      actionText: goal.actionLabel,
      onHeaderTap: onViewAllLongTermGoals,
      onActionTap: onViewLongTermGoalAction,
    );
  }
}

/// Fallback date for sample progress data.
abstract final class _SampleDate {
  static final DateTime today = DateTime(2025, 6, 24);
}
