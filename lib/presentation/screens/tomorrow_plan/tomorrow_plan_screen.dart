import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../core/theme/aday_colors.dart';
import '../../../core/theme/aday_spacing.dart';
import '../../../core/theme/aday_typography.dart';
import '../../models/status_chip_data.dart';
import '../../widgets/aday_button.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/section_surface.dart';
import '../../widgets/status_time_chip.dart';
import 'tomorrow_plan_view_data.dart';

/// Evening moon and window custom painter for the hero illustration.
class EveningRestVisualPainter extends CustomPainter {
  const EveningRestVisualPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Window frame / arched background
    final archRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(w * 0.15, 0, w * 0.85, h),
      topLeft: const Radius.circular(50.0),
      topRight: const Radius.circular(50.0),
      bottomLeft: const Radius.circular(12.0),
      bottomRight: const Radius.circular(12.0),
    );

    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF3892EA), Color(0xFF8CD7F6)],
      ).createShader(archRect.outerRect);

    canvas.drawRRect(archRect, bgPaint);

    // Golden Crescent Moon
    final moonCenter = Offset(w * 0.45, h * 0.35);
    final moonRadius = math.min(w, h) * 0.18;

    final moonPath = Path()
      ..addArc(
        Rect.fromCircle(center: moonCenter, radius: moonRadius),
        -math.pi / 2,
        math.pi * 1.5,
      )
      ..arcToPoint(
        Offset(moonCenter.dx, moonCenter.dy - moonRadius),
        radius: Radius.circular(moonRadius * 1.2),
        clockwise: false,
      )
      ..close();

    final moonPaint = Paint()..color = const Color(0xFFFFDF6D);
    canvas.drawPath(moonPath, moonPaint);

    // Subtle twinkling stars
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    canvas.drawCircle(Offset(w * 0.72, h * 0.22), 2.5, starPaint);
    canvas.drawCircle(Offset(w * 0.30, h * 0.58), 2.0, starPaint);
    canvas.drawCircle(Offset(w * 0.78, h * 0.48), 2.0, starPaint);

    // Soft hills at bottom of window
    final hillPaint = Paint()..color = const Color(0xFF67C2F0);
    final hillPath = Path()
      ..moveTo(w * 0.15, h)
      ..quadraticBezierTo(w * 0.5, h * 0.75, w, h * 0.85)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(hillPath, hillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// The Tomorrow Plan presentation screen strictly matching LapKeHoachNgayMai.png.
///
/// Features:
/// - Hero evening preparation banner with reminder badge
/// - Today's summary hero with progress ring and category breakdown
/// - Praise card recognizing today's effort
/// - Unresolved tasks with carry-forward or mark-completed choices
/// - Tomorrow's planned schedule with quick add and item removal
/// - Finish and Skip action triggers
/// - Minimum 44x44 touch targets and dynamic text resilience
class TomorrowPlanScreen extends StatelessWidget {
  const TomorrowPlanScreen({
    super.key,
    required this.data,
    this.onBackTap,
    this.onMoreTap,
    this.onUnresolvedTaskActionChanged,
    this.onQuickAdd,
    this.onAddTomorrowTask,
    this.onRemoveTomorrowTask,
    this.onToggleTomorrowTask,
    this.onFinishPlan,
    this.onSkipPlan,
  });

  /// Immutable data representing the state for Tomorrow Plan.
  final TomorrowPlanViewData data;

  /// Callback when the app bar back button is tapped.
  final VoidCallback? onBackTap;

  /// Callback when the more options icon is tapped.
  final VoidCallback? onMoreTap;

  /// Callback when the choice for an unresolved task changes.
  final void Function(String taskId, UnresolvedTaskAction action)?
  onUnresolvedTaskActionChanged;

  /// Callback for "+ Thêm nhanh" button.
  final VoidCallback? onQuickAdd;

  /// Callback for "+ Thêm mục tiêu mới cho ngày mai" button.
  final VoidCallback? onAddTomorrowTask;

  /// Callback when a tomorrow task is removed.
  final void Function(String taskId)? onRemoveTomorrowTask;

  /// Callback when a tomorrow task checkbox is toggled.
  final void Function(String taskId, bool isCompleted)? onToggleTomorrowTask;

  /// Callback when "Hoàn tất kế hoạch ngày mai" is pressed.
  final VoidCallback? onFinishPlan;

  /// Callback when "Để sau" is pressed.
  final VoidCallback? onSkipPlan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ADayColors.canvas,
      appBar: AppBar(
        backgroundColor: ADayColors.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Semantics(
          label: 'Quay lại',
          button: true,
          child: IconButton(
            icon: Icon(
              Icons.chevron_left_rounded,
              color: ADayColors.brandNavy,
              size: 28.0,
            ),
            onPressed: onBackTap ?? () => Navigator.maybePop(context),
          ),
        ),
        title: Text(
          'Lập kế hoạch ngày mai',
          style: ADayTypography.title.copyWith(fontSize: 18.0),
        ),
        centerTitle: true,
        actions: [
          Semantics(
            label: 'Tùy chọn khác',
            button: true,
            child: IconButton(
              icon: Icon(Icons.more_horiz_rounded, color: ADayColors.brandNavy),
              onPressed: onMoreTap,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: ADaySpacing.md,
                  vertical: ADaySpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. Hero Preparation Header ---
                    _buildHeroHeader(),

                    const SizedBox(height: ADaySpacing.md),

                    // --- 2. Today's Summary Hero Card ---
                    _buildTodaySummaryHero(),

                    const SizedBox(height: ADaySpacing.md),

                    // --- 3. Praise Card ---
                    _buildPraiseCard(),

                    const SizedBox(height: ADaySpacing.md),

                    // --- 4. Unresolved Tasks Section ---
                    if (data.unresolvedTasks.isNotEmpty) ...[
                      _buildUnresolvedTasksSection(),
                      const SizedBox(height: ADaySpacing.md),
                    ],

                    // --- 5. Tomorrow Tasks Section ---
                    _buildTomorrowTasksSection(context),

                    const SizedBox(height: ADaySpacing.md),

                    // --- 6. Motivational Sprout Quote Banner ---
                    _buildSproutBanner(),

                    const SizedBox(height: ADaySpacing.lg),
                  ],
                ),
              ),
            ),

            // --- Bottom Action Buttons ---
            _buildBottomActionButtons(),
          ],
        ),
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildHeroHeader() {
    return Stack(
      children: [
        // Right illustration (Moon & window)
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: 125.0,
          child: const CustomPaint(painter: EveningRestVisualPainter()),
        ),

        // Left Content
        Padding(
          padding: const EdgeInsets.only(right: 120.0, top: 4.0, bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reminder Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2F3FD),
                  borderRadius: ADaySpacing.pillRadius,
                ),
                child: Text(
                  'Nhắc nhở ${data.reminderTimeLabel}',
                  style: ADayTypography.caption.copyWith(
                    color: ADayColors.actionBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: ADaySpacing.sm),

              // Headline
              Text(
                data.greetingHeadline,
                style: ADayTypography.headline.copyWith(
                  fontSize: 22.0,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 6.0),

              // Subtitle
              Text(
                data.greetingSubtitle,
                style: ADayTypography.subhead.copyWith(
                  fontSize: 13.5,
                  height: 1.4,
                  color: ADayColors.brandNavy.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTodaySummaryHero() {
    return Container(
      decoration: BoxDecoration(
        gradient: ADayColors.heroGradient,
        borderRadius: ADaySpacing.surfaceRadius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F168AF2),
            offset: Offset(0, 4),
            blurRadius: 10.0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(ADaySpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title & Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng kết hôm nay',
                style: ADayTypography.title.copyWith(
                  color: ADayColors.surface,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                data.dateLabel,
                style: ADayTypography.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: ADaySpacing.md),

          // Progress ring + breakdown
          Row(
            children: [
              // Circular progress ring
              ProgressRing(
                progress: data.completionRate,
                size: 78.0,
                strokeWidth: 8.0,
                trackColor: Colors.white.withValues(alpha: 0.22),
                progressColor: ADayColors.surface,
              ),
              const SizedBox(width: ADaySpacing.md),

              // Center text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bạn đã hoàn thành',
                      style: ADayTypography.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      '${data.completedCount} / ${data.totalCount} nhiệm vụ',
                      style: ADayTypography.title.copyWith(
                        color: ADayColors.surface,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      'Một ngày tuyệt vời! 🎉',
                      style: ADayTypography.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Right Breakdown Pill Container
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Đã xong
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 14.0,
                          color: Color(0xFF20C99A),
                        ),
                        const SizedBox(width: 5.0),
                        Text(
                          '${data.completedCount} Đã xong',
                          style: ADayTypography.caption.copyWith(
                            color: ADayColors.surface,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5.0),

                    // Còn lại
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.radio_button_unchecked_rounded,
                          size: 14.0,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        const SizedBox(width: 5.0),
                        Text(
                          '${data.remainingCount} Còn lại',
                          style: ADayTypography.caption.copyWith(
                            color: ADayColors.surface,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5.0),

                    // Quá hạn
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 13.0,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        const SizedBox(width: 5.0),
                        Text(
                          '${data.overdueCount} Quá hạn',
                          style: ADayTypography.caption.copyWith(
                            color: ADayColors.surface,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPraiseCard() {
    return Container(
      padding: const EdgeInsets.all(ADaySpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0),
        borderRadius: ADaySpacing.surfaceRadius,
        border: Border.all(color: const Color(0xFFFFEDBE), width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38.0,
            height: 38.0,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1CE),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const Center(
              child: Icon(
                Icons.emoji_events_rounded,
                color: Color(0xFFFFB52E),
                size: 22.0,
              ),
            ),
          ),
          const SizedBox(width: ADaySpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.praiseTitle,
                  style: ADayTypography.titleMedium.copyWith(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3.0),
                Text(
                  data.praiseSubtitle,
                  style: ADayTypography.subhead.copyWith(
                    fontSize: 13.0,
                    height: 1.35,
                    color: ADayColors.brandNavy.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnresolvedTasksSection() {
    return SectionSurface(
      title: 'Các nhiệm vụ chưa hoàn thành',
      icon: Icons.alarm_rounded,
      iconColor: ADayColors.actionBlue,
      iconBackgroundColor: const Color(0xFFE8F3FD),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ADaySpacing.md,
              vertical: 4.0,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Bạn muốn làm gì với những nhiệm vụ này?',
                style: ADayTypography.caption.copyWith(
                  color: ADayColors.mutedInk,
                ),
              ),
            ),
          ),
          const SizedBox(height: ADaySpacing.xs),

          // List of Unresolved Tasks with Choices
          ...data.unresolvedTasks.asMap().entries.map((entry) {
            final index = entry.key;
            final task = entry.value;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(ADaySpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Inactive Checkbox square
                      Container(
                        width: 22.0,
                        height: 22.0,
                        margin: const EdgeInsets.only(top: 2.0),
                        decoration: BoxDecoration(
                          borderRadius: ADaySpacing.checkboxRadius,
                          border: Border.all(
                            color: ADayColors.dividerMist,
                            width: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: ADaySpacing.sm),

                      // Category Icon
                      Container(
                        width: 34.0,
                        height: 34.0,
                        decoration: BoxDecoration(
                          color: task.iconBackgroundColor,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                          child: Icon(
                            task.icon,
                            color: task.iconColor,
                            size: 18.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: ADaySpacing.sm),

                      // Title & Subtitle
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: ADayTypography.bodyMedium.copyWith(
                                fontSize: 14.5,
                              ),
                            ),
                            if (task.subtitle != null) ...[
                              const SizedBox(height: 2.0),
                              Text(
                                task.subtitle!,
                                style: ADayTypography.caption.copyWith(
                                  color: ADayColors.mutedInk,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(width: ADaySpacing.sm),

                      // Action Choices (Radio-like selectors)
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Chuyển sang ngày mai
                            Semantics(
                              button: true,
                              selected:
                                  task.selectedAction ==
                                  UnresolvedTaskAction.carryForward,
                              label: 'Chuyển ${task.title} sang ngày mai',
                              child: InkWell(
                                onTap: () =>
                                    onUnresolvedTaskActionChanged?.call(
                                      task.id,
                                      UnresolvedTaskAction.carryForward,
                                    ),
                                borderRadius: ADaySpacing.controlRadius,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 3.0,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        task.selectedAction ==
                                                UnresolvedTaskAction
                                                    .carryForward
                                            ? Icons.radio_button_checked_rounded
                                            : Icons.radio_button_off_rounded,
                                        size: 17.0,
                                        color:
                                            task.selectedAction ==
                                                UnresolvedTaskAction
                                                    .carryForward
                                            ? ADayColors.actionBlue
                                            : ADayColors.mutedInk,
                                      ),
                                      const SizedBox(width: 5.0),
                                      Flexible(
                                        child: Text(
                                          'Chuyển sang ngày mai',
                                          style: ADayTypography.caption
                                              .copyWith(
                                                fontSize: 12.0,
                                                fontWeight:
                                                    task.selectedAction ==
                                                        UnresolvedTaskAction
                                                            .carryForward
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                                color:
                                                    task.selectedAction ==
                                                        UnresolvedTaskAction
                                                            .carryForward
                                                    ? ADayColors.actionBlue
                                                    : ADayColors.brandNavy,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // 2. Đánh dấu đã hoàn thành
                            Semantics(
                              button: true,
                              selected:
                                  task.selectedAction ==
                                  UnresolvedTaskAction.markCompleted,
                              label: 'Đánh dấu ${task.title} đã hoàn thành',
                              child: InkWell(
                                onTap: () =>
                                    onUnresolvedTaskActionChanged?.call(
                                      task.id,
                                      UnresolvedTaskAction.markCompleted,
                                    ),
                                borderRadius: ADaySpacing.controlRadius,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 3.0,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        task.selectedAction ==
                                                UnresolvedTaskAction
                                                    .markCompleted
                                            ? Icons.radio_button_checked_rounded
                                            : Icons.radio_button_off_rounded,
                                        size: 17.0,
                                        color:
                                            task.selectedAction ==
                                                UnresolvedTaskAction
                                                    .markCompleted
                                            ? ADayColors.progressTeal
                                            : ADayColors.mutedInk,
                                      ),
                                      const SizedBox(width: 5.0),
                                      Flexible(
                                        child: Text(
                                          'Đánh dấu đã hoàn thành',
                                          style: ADayTypography.caption
                                              .copyWith(
                                                fontSize: 12.0,
                                                fontWeight:
                                                    task.selectedAction ==
                                                        UnresolvedTaskAction
                                                            .markCompleted
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                                color:
                                                    task.selectedAction ==
                                                        UnresolvedTaskAction
                                                            .markCompleted
                                                    ? ADayColors.progressTeal
                                                    : ADayColors.brandNavy,
                                              ),
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
                ),
                if (index < data.unresolvedTasks.length - 1)
                  Divider(
                    height: 1.0,
                    indent: ADaySpacing.md,
                    endIndent: ADaySpacing.md,
                    color: ADayColors.dividerMist,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTomorrowTasksSection(BuildContext context) {
    return SectionSurface(
      title: 'Lên lịch cho ngày mai',
      icon: Icons.add_circle_rounded,
      iconColor: ADayColors.actionBlue,
      iconBackgroundColor: const Color(0xFFE8F3FD),
      headerTrailing: Semantics(
        button: true,
        label: 'Thêm nhanh mục tiêu cho ngày mai',
        child: InkWell(
          onTap: onQuickAdd,
          borderRadius: ADaySpacing.pillRadius,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 4.0,
            ),
            decoration: BoxDecoration(
              color: ADayColors.coolSurface,
              borderRadius: ADaySpacing.pillRadius,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_rounded,
                  size: 15.0,
                  color: ADayColors.actionBlue,
                ),
                const SizedBox(width: 3.0),
                Text(
                  'Thêm nhanh',
                  style: ADayTypography.caption.copyWith(
                    color: ADayColors.actionBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ADaySpacing.md,
              vertical: 4.0,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Thêm những mục tiêu mới để có một ngày mai tuyệt vời!',
                style: ADayTypography.caption.copyWith(
                  color: ADayColors.mutedInk,
                ),
              ),
            ),
          ),
          const SizedBox(height: ADaySpacing.xs),

          // Tomorrow tasks list
          ...data.tomorrowTasks.asMap().entries.map((entry) {
            final index = entry.key;
            final task = entry.value;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ADaySpacing.md,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      // Checkbox
                      Semantics(
                        checked: task.isCompleted,
                        label: 'Đánh dấu ${task.title}',
                        button: true,
                        child: InkWell(
                          onTap: onToggleTomorrowTask != null
                              ? () => onToggleTomorrowTask!(
                                  task.id,
                                  !task.isCompleted,
                                )
                              : null,
                          borderRadius: ADaySpacing.smallRadius,
                          child: ConstrainedBox(
                            constraints: ADaySpacing.minTouchTargetConstraints,
                            child: Center(
                              child: Container(
                                width: 22.0,
                                height: 22.0,
                                decoration: BoxDecoration(
                                  color: task.isCompleted
                                      ? ADayColors.progressTeal
                                      : Colors.transparent,
                                  borderRadius: ADaySpacing.checkboxRadius,
                                  border: Border.all(
                                    color: task.isCompleted
                                        ? ADayColors.progressTeal
                                        : ADayColors.dividerMist,
                                    width: 1.5,
                                  ),
                                ),
                                child: task.isCompleted
                                    ? Icon(
                                        Icons.check_rounded,
                                        size: 16.0,
                                        color: ADayColors.surface,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: ADaySpacing.xs),

                      // Category Icon
                      Container(
                        width: 36.0,
                        height: 36.0,
                        decoration: BoxDecoration(
                          color: task.iconBackgroundColor,
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        child: Center(
                          child: Icon(
                            task.icon,
                            color: task.iconColor,
                            size: 19.0,
                          ),
                        ),
                      ),

                      const SizedBox(width: ADaySpacing.sm),

                      // Title & Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: ADayTypography.bodyMedium.copyWith(
                                fontSize: 14.5,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            if (task.subtitle != null) ...[
                              const SizedBox(height: 2.0),
                              Text(
                                task.subtitle!,
                                style: ADayTypography.caption.copyWith(
                                  color: ADayColors.mutedInk,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(width: ADaySpacing.xs),

                      // Time chip
                      if (task.timeLabel != null)
                        StatusTimeChip(
                          label: task.timeLabel!,
                          type: StatusChipType.time,
                        ),

                      // Remove button (✕)
                      Semantics(
                        label: 'Xóa nhiệm vụ ${task.title}',
                        button: true,
                        child: IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            size: 18.0,
                            color: ADayColors.mutedInk,
                          ),
                          constraints: ADaySpacing.minTouchTargetConstraints,
                          onPressed: () => onRemoveTomorrowTask?.call(task.id),
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < data.tomorrowTasks.length - 1)
                  Divider(
                    height: 1.0,
                    indent: ADaySpacing.md,
                    endIndent: ADaySpacing.md,
                    color: ADayColors.dividerMist,
                  ),
              ],
            );
          }),

          // "+ Thêm mục tiêu mới cho ngày mai" button
          Padding(
            padding: const EdgeInsets.all(ADaySpacing.md),
            child: ADayButton.secondary(
              label: 'Thêm mục tiêu mới cho ngày mai',
              icon: Icons.add_rounded,
              height: 44.0,
              onPressed: onAddTomorrowTask,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSproutBanner() {
    return Container(
      padding: const EdgeInsets.all(ADaySpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFF1FAF6),
        borderRadius: ADaySpacing.surfaceRadius,
        border: Border.all(color: const Color(0xFFD6F3E6), width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            width: 36.0,
            height: 36.0,
            decoration: BoxDecoration(
              color: const Color(0xFFDCF6EB),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const Center(
              child: Icon(
                Icons.eco_rounded,
                color: Color(0xFF20C99A),
                size: 20.0,
              ),
            ),
          ),
          const SizedBox(width: ADaySpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.quoteTitle,
                  style: ADayTypography.quote.copyWith(
                    fontSize: 12.5,
                    color: ADayColors.brandNavy.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  data.quoteSubtitle,
                  style: ADayTypography.caption.copyWith(
                    color: ADayColors.mutedInk,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionButtons() {
    return Container(
      padding: const EdgeInsets.all(ADaySpacing.md),
      decoration: BoxDecoration(
        color: ADayColors.surface,
        border: Border(
          top: BorderSide(color: ADayColors.dividerMist, width: 1.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary Finish button
          ADayButton.primary(
            label: 'Hoàn tất kế hoạch ngày mai',
            icon: Icons.check_circle_rounded,
            trailingIcon: Icons.chevron_right_rounded,
            height: 52.0,
            onPressed: onFinishPlan,
          ),

          const SizedBox(height: ADaySpacing.xs),

          // Secondary "Để sau" button
          Semantics(
            button: true,
            label: 'Để sau, bỏ qua lập kế hoạch',
            child: TextButton(
              onPressed: onSkipPlan,
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 44.0),
              ),
              child: Text(
                'Để sau',
                style: ADayTypography.label.copyWith(
                  color: ADayColors.actionBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
