import 'package:flutter/material.dart';

import '../../core/theme/aday_colors.dart';
import '../../core/theme/aday_spacing.dart';
import '../../core/theme/aday_typography.dart';
import 'aday_button.dart';
import 'mountain_sun_visual.dart';

/// Calming, guilt-free empty state widget for ADay.
///
/// Embodies the Brand Personality:
/// "Tươi sáng, bình tĩnh, động viên. Giọng nói thân thiện và ngắn gọn,
/// ghi nhận nỗ lực, khuyến khích bước tiếp theo, không phán xét."
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    this.visual,
    this.icon,
  });

  /// Preset for when there are no tasks scheduled for today.
  factory EmptyStateView.noTasksToday({Key? key, VoidCallback? onAddTask}) {
    return EmptyStateView(
      key: key,
      title: 'Hôm nay chưa có nhiệm vụ nào',
      description:
          'Một buổi sáng thảnh thơi hoặc là lúc tuyệt vời để đặt ra một bước đi nhỏ cho ngày mới.',
      actionLabel: 'Thêm nhiệm vụ mới',
      onAction: onAddTask,
    );
  }

  /// Preset for when all tasks for the day are finished.
  factory EmptyStateView.allCompleted({
    Key? key,
    VoidCallback? onReviewTomorrow,
  }) {
    return EmptyStateView(
      key: key,
      title: 'Tuyệt vời, bạn đã hoàn tất!',
      description:
          'Mọi kế hoạch hôm nay đã hoàn thành. Hãy dành thời gian nghỉ ngơi hoặc chuẩn bị nhẹ nhàng cho ngày mai.',
      actionLabel: 'Xem kế hoạch ngày mai',
      onAction: onReviewTomorrow,
    );
  }

  /// Preset for when no long term goals have been set.
  factory EmptyStateView.noLongTermGoals({
    Key? key,
    VoidCallback? onCreateGoal,
  }) {
    return EmptyStateView(
      key: key,
      title: 'Chưa có mục tiêu dài hạn',
      description:
          'Hành trình vạn dặm bắt đầu từ những bước nhỏ. Đặt mục tiêu để định hướng cho các ngày tiếp theo.',
      actionLabel: 'Tạo mục tiêu đầu tiên',
      onAction: onCreateGoal,
    );
  }

  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? visual;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$title. $description',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ADaySpacing.lg,
            vertical: ADaySpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Vector illustration or icon
              visual ??
                  const SizedBox(
                    width: 160.0,
                    height: 100.0,
                    child: MountainSunVisual(
                      height: 100.0,
                      showSunRays: true,
                      sunPosition: Offset(0.70, 0.35),
                    ),
                  ),

              const SizedBox(height: ADaySpacing.lg),

              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: ADayTypography.title.copyWith(
                  fontSize: 18.0,
                  color: ADayColors.brandNavy,
                ),
              ),

              const SizedBox(height: ADaySpacing.xs + 2),

              // Description
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320.0),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: ADayTypography.body.copyWith(
                    fontSize: 14.5,
                    color: ADayColors.mutedInk,
                    height: 1.45,
                  ),
                ),
              ),

              // Optional Action Button
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: ADaySpacing.lg),
                ADayButton.primary(
                  label: actionLabel!,
                  onPressed: onAction,
                  icon: Icons.add_rounded,
                  height: 48.0,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
