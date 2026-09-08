import 'package:flutter/material.dart';

import '../../../core/theme/aday_colors.dart';
import '../../../core/theme/aday_spacing.dart';
import '../../../core/theme/aday_typography.dart';
import '../../models/status_chip_data.dart';
import '../../widgets/aday_button.dart';
import '../../widgets/mountain_sun_visual.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/section_surface.dart';
import '../../widgets/status_time_chip.dart';
import 'goal_detail_view_data.dart';
import 'reason_picker_sheet.dart';

/// The Goal Detail presentation screen strictly matching ChiTietMucTieu.png.
///
/// Features:
/// - Category icon and editable goal title header
/// - Progress summary card with circular progress ring and encouragement
/// - Metadata strip (Schedule, Reminder time, Start date)
/// - Today's sub-tasks with interactive check toggle
/// - Note taking area with 0/500 character counter and Vietnamese placeholder
/// - Quick action cards: Complete, Postpone (collects reason), Cancel (collects reason)
/// - Bottom fixed action button to update progress
/// - Dynamic text scaling resilience & minimum 44x44 touch targets
class GoalDetailScreen extends StatefulWidget {
  const GoalDetailScreen({
    super.key,
    required this.data,
    this.onToggleTask,
    this.onNoteUpdate,
    this.onEdit,
    this.onComplete,
    this.onPostpone,
    this.onResume,
    this.onCancel,
    this.onUpdateProgress,
    this.onBackTap,
    this.onMoreTap,
  });

  /// The immutable data representing the goal detail state.
  final GoalDetailViewData data;

  /// Callback when a sub-task checkbox is toggled.
  final void Function(String taskId, bool isCompleted)? onToggleTask;

  /// Callback when the goal note is updated or saved.
  final ValueChanged<String>? onNoteUpdate;

  /// Callback to edit the goal.
  final VoidCallback? onEdit;

  /// Callback to mark the goal completed.
  final VoidCallback? onComplete;

  /// Callback when the goal is postponed with a target date and reason.
  final void Function(PostponeSelection selection)? onPostpone;

  /// Callback to resume / reactivate a postponed goal.
  final VoidCallback? onResume;

  /// Callback when the goal is cancelled with a reason.
  final void Function(String reason)? onCancel;

  /// Callback when the "Cập nhật tiến độ" button is tapped.
  final VoidCallback? onUpdateProgress;

  /// Callback when the top app bar back button is tapped.
  final VoidCallback? onBackTap;

  /// Callback when the more options icon is tapped.
  final VoidCallback? onMoreTap;

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.data.note);
  }

  @override
  void didUpdateWidget(covariant GoalDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.note != widget.data.note &&
        _noteController.text != widget.data.note) {
      _noteController.text = widget.data.note;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handlePostpone() async {
    final selection = await ReasonPickerSheet.showPostpone(context);
    if (selection != null && mounted) {
      widget.onPostpone?.call(selection);
    }
  }

  Future<void> _handleCancel() async {
    final reason = await ReasonPickerSheet.showCancel(context);
    if (reason != null && mounted) {
      widget.onCancel?.call(reason);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

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
            onPressed: widget.onBackTap ?? () => Navigator.maybePop(context),
          ),
        ),
        title: Text(
          'Chi tiết mục tiêu',
          style: ADayTypography.title.copyWith(fontSize: 18.0),
        ),
        centerTitle: true,
        actions: [
          Semantics(
            label: 'Tùy chọn khác',
            button: true,
            child: IconButton(
              icon: Icon(Icons.more_horiz_rounded, color: ADayColors.brandNavy),
              onPressed: widget.onMoreTap,
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
                    // --- 1. Goal Header & Edit Button ---
                    _buildGoalHeader(data),

                    if (data.isPostponed) ...[
                      const SizedBox(height: ADaySpacing.md),
                      _buildPostponeStatusCard(data),
                    ],

                    const SizedBox(height: ADaySpacing.md),

                    // --- 2. Progress Summary Hero Card ---
                    _buildProgressHeroCard(data),

                    const SizedBox(height: ADaySpacing.md),

                    // --- 3. Metadata Strip (Schedule, Reminder, Start date) ---
                    _buildMetadataStrip(data),

                    const SizedBox(height: ADaySpacing.md),

                    // --- 4. Today Tasks Section ---
                    _buildTodayTasksSection(data),

                    const SizedBox(height: ADaySpacing.md),

                    // --- 5. Note Section ---
                    _buildNoteSection(data),

                    const SizedBox(height: ADaySpacing.md),

                    // --- 6. Motivational Banner ---
                    _buildEncouragementBanner(data),

                    const SizedBox(height: ADaySpacing.md),

                    // --- 7. Quick Action Cards (Complete, Postpone, Cancel) ---
                    _buildActionCardsRow(),

                    const SizedBox(height: ADaySpacing.lg),
                  ],
                ),
              ),
            ),

            // --- Fixed Bottom Action Button ---
            Container(
              padding: const EdgeInsets.all(ADaySpacing.md),
              decoration: BoxDecoration(
                color: ADayColors.surface,
                border: Border(
                  top: BorderSide(color: ADayColors.dividerMist, width: 1.0),
                ),
              ),
              child: ADayButton.primary(
                label: 'Cập nhật tiến độ',
                height: 52.0,
                onPressed: widget.onUpdateProgress,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildGoalHeader(GoalDetailViewData data) {
    return Container(
      decoration: BoxDecoration(
        color: ADayColors.surface,
        borderRadius: ADaySpacing.surfaceRadius,
        border: Border.all(color: ADayColors.dividerMist, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Mountain Sun Visual on top right
          Positioned(
            right: -10.0,
            top: -10.0,
            width: 170.0,
            height: 95.0,
            child: const MountainSunVisual(
              height: 95.0,
              showFlag: true,
              showSunRays: true,
              sunPosition: Offset(0.75, 0.35),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(ADaySpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Icon / Book stack visual container
                    Container(
                      width: 48.0,
                      height: 48.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F3FD),
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.auto_stories_rounded,
                          color: ADayColors.actionBlue,
                          size: 26.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: ADaySpacing.md),

                    // Title & Category
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.title,
                            style: ADayTypography.title.copyWith(
                              fontSize: 19.0,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            data.category,
                            style: ADayTypography.subhead.copyWith(
                              fontSize: 13.5,
                              color: ADayColors.mutedInk,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Edit Button Pill
                    Semantics(
                      button: true,
                      label: 'Chỉnh sửa mục tiêu',
                      child: InkWell(
                        onTap: widget.onEdit,
                        borderRadius: ADaySpacing.pillRadius,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 6.0,
                          ),
                          decoration: BoxDecoration(
                            color: ADayColors.coolSurface,
                            borderRadius: ADaySpacing.pillRadius,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 14.0,
                                color: ADayColors.actionBlue,
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                'Chỉnh sửa',
                                style: ADayTypography.caption.copyWith(
                                  color: ADayColors.actionBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (data.quote.isNotEmpty) ...[
                  const SizedBox(height: ADaySpacing.md),
                  Text(
                    data.quote,
                    style: ADayTypography.quote.copyWith(
                      fontSize: 13.0,
                      color: ADayColors.brandNavy.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeroCard(GoalDetailViewData data) {
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
      child: Padding(
        padding: const EdgeInsets.all(ADaySpacing.md),
        child: Row(
          children: [
            // Progress Ring
            ProgressRing(
              progress: data.completionRate,
              size: 78.0,
              strokeWidth: 8.0,
              trackColor: Colors.white.withValues(alpha: 0.22),
              progressColor: ADayColors.surface,
            ),
            const SizedBox(width: ADaySpacing.md),

            // Middle Stats
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Đã hoàn thành',
                  style: ADayTypography.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  '${data.completedTasks} / ${data.totalTasks}',
                  style: ADayTypography.title.copyWith(
                    color: ADayColors.surface,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'nhiệm vụ',
                  style: ADayTypography.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),

            const SizedBox(width: ADaySpacing.md),

            // Vertical white divider
            Container(
              width: 1.0,
              height: 48.0,
              color: Colors.white.withValues(alpha: 0.3),
            ),

            const SizedBox(width: ADaySpacing.md),

            // Right Encouragement Message
            Expanded(
              child: Text(
                data.encouragement,
                style: ADayTypography.body.copyWith(
                  color: ADayColors.surface,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataStrip(GoalDetailViewData data) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ADaySpacing.sm,
        vertical: ADaySpacing.md,
      ),
      decoration: BoxDecoration(
        color: ADayColors.surface,
        borderRadius: ADaySpacing.surfaceRadius,
        border: Border.all(color: ADayColors.dividerMist, width: 1.0),
      ),
      child: Row(
        children: [
          // 1. Schedule
          Expanded(
            child: _buildMetaColumn(
              icon: Icons.calendar_today_rounded,
              label: 'Thời gian',
              value: data.scheduleLabel,
            ),
          ),
          Container(width: 1.0, height: 36.0, color: ADayColors.dividerMist),

          // 2. Reminder Time
          Expanded(
            child: _buildMetaColumn(
              icon: Icons.track_changes_rounded,
              label: 'Thời gian nhắc',
              value: data.reminderTimeLabel,
            ),
          ),
          Container(width: 1.0, height: 36.0, color: ADayColors.dividerMist),

          // 3. Start Date
          Expanded(
            child: _buildMetaColumn(
              icon: Icons.bar_chart_rounded,
              label: 'Ngày bắt đầu',
              value: data.startDateLabel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaColumn({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20.0, color: ADayColors.actionBlue),
        const SizedBox(width: 8.0),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: ADayTypography.caption.copyWith(
                  color: ADayColors.mutedInk,
                  fontSize: 11.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1.0),
              Text(
                value,
                style: ADayTypography.label.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: ADayColors.brandNavy,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTodayTasksSection(GoalDetailViewData data) {
    return SectionSurface(
      title: 'Nhiệm vụ hôm nay',
      icon: Icons.checklist_rounded,
      iconColor: ADayColors.progressTeal,
      iconBackgroundColor: ADayColors.progressTealTint,
      headerTrailing: Text(
        data.dateLabel,
        style: ADayTypography.caption.copyWith(
          color: ADayColors.actionBlue,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Column(
        children: [
          ...data.tasks.asMap().entries.map((entry) {
            final index = entry.key;
            final task = entry.value;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ADaySpacing.md,
                    vertical: 10.0,
                  ),
                  child: Row(
                    children: [
                      // Accessible Checkbox (min 44x44)
                      Semantics(
                        checked: task.isCompleted,
                        label: task.isCompleted
                            ? 'Đánh dấu chưa hoàn thành ${task.title}'
                            : 'Đánh dấu hoàn thành ${task.title}',
                        button: true,
                        child: InkWell(
                          onTap: widget.onToggleTask != null
                              ? () => widget.onToggleTask!(
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
                                    width: 1.8,
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

                      // Task Title & Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: ADayTypography.bodyMedium.copyWith(
                                fontSize: 14.5,
                                color: task.isCompleted
                                    ? ADayColors.mutedInk
                                    : ADayColors.brandNavy,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                decorationColor: ADayColors.mutedInk,
                              ),
                            ),
                            if (task.subtitle != null &&
                                task.subtitle!.isNotEmpty) ...[
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

                      // Status Chip: "Đã xong" vs "Chưa làm"
                      if (task.isCompleted)
                        const StatusTimeChip.completed(label: 'Đã xong')
                      else
                        const StatusTimeChip(
                          label: 'Chưa làm',
                          type: StatusChipType.allDay,
                        ),
                    ],
                  ),
                ),
                if (index < data.tasks.length - 1)
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

  Widget _buildNoteSection(GoalDetailViewData data) {
    return Container(
      padding: const EdgeInsets.all(ADaySpacing.md),
      decoration: BoxDecoration(
        color: ADayColors.surface,
        borderRadius: ADaySpacing.surfaceRadius,
        border: Border.all(color: ADayColors.dividerMist, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32.0,
                    height: 32.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F3FD),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(
                      Icons.description_rounded,
                      color: ADayColors.actionBlue,
                      size: 18.0,
                    ),
                  ),
                  const SizedBox(width: ADaySpacing.sm),
                  Text(
                    'Ghi chú',
                    style: ADayTypography.title.copyWith(fontSize: 17.0),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  widget.onNoteUpdate?.call(_noteController.text.trim());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã lưu ghi chú thành công!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'Thêm ghi chú',
                      style: ADayTypography.caption.copyWith(
                        color: ADayColors.actionBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18.0,
                      color: ADayColors.actionBlue,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: ADaySpacing.sm),
          TextField(
            controller: _noteController,
            maxLines: 3,
            maxLength: 500,
            onChanged: (val) => widget.onNoteUpdate?.call(val),
            decoration: InputDecoration(
              hintText:
                  'Viết cảm nhận, bài học rút ra, hoặc bất kỳ điều gì bạn muốn lưu lại...',
              hintStyle: ADayTypography.body.copyWith(
                color: ADayColors.mutedInk.withValues(alpha: 0.7),
                fontSize: 13.5,
              ),
              filled: true,
              fillColor: ADayColors.canvas,
              contentPadding: ADaySpacing.paddingInput,
              border: OutlineInputBorder(
                borderRadius: ADaySpacing.controlRadius,
                borderSide: BorderSide(color: ADayColors.dividerMist),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: ADaySpacing.controlRadius,
                borderSide: BorderSide(color: ADayColors.dividerMist),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: ADaySpacing.controlRadius,
                borderSide: BorderSide(
                  color: ADayColors.actionBlue,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEncouragementBanner(GoalDetailViewData data) {
    return Container(
      padding: const EdgeInsets.all(ADaySpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F9FE),
        borderRadius: ADaySpacing.surfaceRadius,
        border: Border.all(color: ADayColors.dividerMist, width: 1.0),
      ),
      child: Row(
        children: [
          Icon(
            Icons.wb_sunny_rounded,
            color: ADayColors.sunriseGold,
            size: 26.0,
          ),
          const SizedBox(width: ADaySpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.bannerTitle,
                  style: ADayTypography.titleMedium.copyWith(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  data.bannerSubtitle,
                  style: ADayTypography.caption.copyWith(
                    color: ADayColors.mutedInk,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostponeStatusCard(GoalDetailViewData data) {
    return Container(
      padding: const EdgeInsets.all(ADaySpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9EE),
        borderRadius: ADaySpacing.surfaceRadius,
        border: Border.all(color: const Color(0xFFFFD569), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            offset: Offset(0, 2),
            blurRadius: 6.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38.0,
                height: 38.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECC1),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: Color(0xFFD68A0A),
                  size: 22.0,
                ),
              ),
              const SizedBox(width: ADaySpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Mục tiêu đang tạm hoãn',
                            style: ADayTypography.titleMedium.copyWith(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF8A5300),
                            ),
                          ),
                        ),
                        if (data.postponedUntilLabel != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 3.0,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE7A3),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Text(
                              'Đến ${data.postponedUntilLabel}',
                              style: ADayTypography.caption.copyWith(
                                color: const Color(0xFF7A4800),
                                fontWeight: FontWeight.w700,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (data.statusReason != null &&
                        data.statusReason!.isNotEmpty) ...[
                      const SizedBox(height: 4.0),
                      Text(
                        'Lý do: ${data.statusReason}',
                        style: ADayTypography.body.copyWith(
                          fontSize: 13.0,
                          color: const Color(0xFF7A4800),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: ADaySpacing.sm),
          Divider(
            color: const Color(0xFFFFE28A).withValues(alpha: 0.6),
            height: 1.0,
          ),
          const SizedBox(height: ADaySpacing.xs),
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 15.0,
                color: Color(0xFF9E6B15),
              ),
              const SizedBox(width: 6.0),
              Expanded(
                child: Text(
                  'Các nhiệm vụ chưa xong đã được chuyển sang ngày mới.',
                  style: ADayTypography.caption.copyWith(
                    fontSize: 12.0,
                    color: const Color(0xFF9E6B15),
                  ),
                ),
              ),
              if (widget.onResume != null)
                TextButton(
                  onPressed: widget.onResume,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Khôi phục ngay',
                    style: ADayTypography.caption.copyWith(
                      color: ADayColors.actionBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCardsRow() {
    if (widget.data.isPostponed) {
      return Row(
        children: [
          // 1. Hoàn thành
          Expanded(
            child: _buildActionCard(
              icon: Icons.check_circle_rounded,
              iconColor: ADayColors.progressTeal,
              bgColor: const Color(0xFFE8FAF6),
              title: 'Hoàn thành',
              subtitle: 'Đã đạt mục tiêu',
              onTap: widget.onComplete,
            ),
          ),
          const SizedBox(width: 8.0),

          // 2. Khôi phục
          Expanded(
            child: _buildActionCard(
              icon: Icons.play_circle_outline_rounded,
              iconColor: ADayColors.actionBlue,
              bgColor: const Color(0xFFE8F3FD),
              title: 'Khôi phục',
              subtitle: 'Làm lại hôm nay',
              onTap: widget.onResume,
            ),
          ),
          const SizedBox(width: 8.0),

          // 3. Đổi ngày hoãn
          Expanded(
            child: _buildActionCard(
              icon: Icons.edit_calendar_rounded,
              iconColor: const Color(0xFFD68A0A),
              bgColor: const Color(0xFFFFF7E8),
              title: 'Đổi ngày',
              subtitle: 'Dời sang ngày khác',
              onTap: _handlePostpone,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        // 1. Hoàn thành
        Expanded(
          child: _buildActionCard(
            icon: Icons.check_circle_rounded,
            iconColor: ADayColors.progressTeal,
            bgColor: const Color(0xFFE8FAF6),
            title: 'Hoàn thành',
            subtitle: 'Đã đạt mục tiêu',
            onTap: widget.onComplete,
          ),
        ),
        const SizedBox(width: 8.0),

        // 2. Tạm hoãn
        Expanded(
          child: _buildActionCard(
            icon: Icons.schedule_rounded,
            iconColor: const Color(0xFFD68A0A),
            bgColor: const Color(0xFFFFF7E8),
            title: 'Tạm hoãn',
            subtitle: 'Dời ngày thực hiện',
            onTap: _handlePostpone,
          ),
        ),
        const SizedBox(width: 8.0),

        // 3. Hủy mục tiêu
        Expanded(
          child: _buildActionCard(
            icon: Icons.cancel_rounded,
            iconColor: ADayColors.cancelCoral,
            bgColor: const Color(0xFFFEEDEE),
            title: 'Hủy mục tiêu',
            subtitle: 'Chọn lý do',
            onTap: _handleCancel,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return Semantics(
      button: true,
      label: '$title, $subtitle',
      child: InkWell(
        onTap: onTap,
        borderRadius: ADaySpacing.surfaceRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: ADaySpacing.surfaceRadius,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 24.0),
              const SizedBox(height: 6.0),
              Text(
                title,
                textAlign: TextAlign.center,
                style: ADayTypography.label.copyWith(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w700,
                  color: ADayColors.brandNavy,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: ADayTypography.caption.copyWith(
                  fontSize: 11.0,
                  color: ADayColors.mutedInk,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
