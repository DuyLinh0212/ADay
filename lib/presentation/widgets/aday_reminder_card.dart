import 'package:flutter/material.dart';

import '../../core/theme/aday_colors.dart';
import '../../core/theme/aday_spacing.dart';
import '../../core/theme/aday_typography.dart';

/// Evening preparation reminder banner matching TrangChu.png.
///
/// Embodies the ADay rhythm:
/// "Họ thường mở ứng dụng nhanh vào đầu ngày, trong lúc cập nhật tiến độ,
/// và trước 22:00 để tổng kết hôm nay và chuẩn bị ngày mai."
class ADayReminderCard extends StatelessWidget {
  const ADayReminderCard({
    super.key,
    this.title = 'Đừng quên nhé!',
    this.message =
        'Trước 22:00, ADay sẽ nhắc bạn cập nhật tiến độ và tạo kế hoạch cho ngày mai.',
    this.actionLabel = 'Tạo kế hoạch ngày mai',
    this.onActionTap,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$title. $message',
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9EC),
          borderRadius: ADaySpacing.surfaceRadius,
          border: Border.all(color: const Color(0xFFFFE6B0), width: 1.0),
        ),
        padding: const EdgeInsets.all(ADaySpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Golden Bell Icon
            Container(
              width: 42.0,
              height: 42.0,
              decoration: const BoxDecoration(
                color: Color(0xFFFFECC4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: Color(0xFFD98A00),
                size: 22.0,
              ),
            ),

            const SizedBox(width: ADaySpacing.md),

            // Content & Action
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: ADayTypography.titleMedium.copyWith(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    message,
                    style: ADayTypography.subhead.copyWith(
                      fontSize: 13.0,
                      color: ADayColors.brandNavy.withValues(alpha: 0.8),
                    ),
                  ),
                  if (onActionTap != null) ...[
                    const SizedBox(height: ADaySpacing.sm),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Semantics(
                        button: true,
                        label: actionLabel,
                        child: Material(
                          color: const Color(0xFFFFD57A),
                          borderRadius: BorderRadius.circular(10.0),
                          child: InkWell(
                            onTap: onActionTap,
                            borderRadius: BorderRadius.circular(10.0),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                minHeight: ADaySpacing.buttonHeightSmall,
                                minWidth: ADaySpacing.minTouchTarget,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14.0,
                                  vertical: 8.0,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      actionLabel,
                                      style: const TextStyle(
                                        fontFamily: ADayTypography.fontFamily,
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF6B4500),
                                      ),
                                    ),
                                    const SizedBox(width: 4.0),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      size: 16.0,
                                      color: Color(0xFF6B4500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
