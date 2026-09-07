import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/theme/aday_colors.dart';
import '../../../../core/theme/aday_spacing.dart';
import '../../../../core/theme/aday_typography.dart';
import '../statistics_view_data.dart';

/// Card showing status breakdown donut chart matching Image 2 ("Phân bố trạng thái").
class StatusBreakdownCard extends StatelessWidget {
  const StatusBreakdownCard({
    super.key,
    required this.items,
    this.title = 'Phân bố trạng thái',
    this.actionLabel = 'Xem chi tiết',
    this.onActionTap,
  });

  final List<CompletionBreakdownItem> items;
  final String title;
  final String actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final completedItem = items.isNotEmpty ? items.first : null;
    final centerPercentage =
        completedItem != null ? '${completedItem.percentage}%' : '0%';

    return Container(
      decoration: BoxDecoration(
        color: ADayColors.surface,
        borderRadius: ADaySpacing.surfaceRadius,
        border: Border.all(color: ADayColors.dividerMist, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x081C5B84),
            blurRadius: 10.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(ADaySpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.pie_chart_rounded,
                    color: ADayColors.actionBlue,
                    size: 22.0,
                  ),
                  const SizedBox(width: ADaySpacing.xs + 2),
                  Text(
                    title,
                    style: ADayTypography.title.copyWith(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700,
                      color: ADayColors.brandNavy,
                    ),
                  ),
                ],
              ),
              if (onActionTap != null)
                InkWell(
                  onTap: onActionTap,
                  borderRadius: BorderRadius.circular(6.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2.0,
                      vertical: 2.0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          actionLabel,
                          style: const TextStyle(
                            fontFamily: ADayTypography.fontFamily,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: ADayColors.actionBlue,
                          ),
                        ),
                        const SizedBox(width: 2.0),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 15.0,
                          color: ADayColors.actionBlue,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: ADaySpacing.md),

          // Donut and Legend
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Donut Chart with center percentage
              SizedBox(
                width: 86.0,
                height: 86.0,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(86.0, 86.0),
                      painter: _StatusDonutPainter(items: items),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          centerPercentage,
                          style: const TextStyle(
                            fontFamily: ADayTypography.fontFamily,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: ADayColors.brandNavy,
                            height: 1.1,
                          ),
                        ),
                        const Text(
                          'Hoàn thành',
                          style: TextStyle(
                            fontFamily: ADayTypography.fontFamily,
                            fontSize: 9.0,
                            fontWeight: FontWeight.w600,
                            color: ADayColors.mutedInk,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: ADaySpacing.sm),

              // Legend
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.5),
                      child: Row(
                        children: [
                          Container(
                            width: 8.0,
                            height: 8.0,
                            decoration: BoxDecoration(
                              color: item.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          Expanded(
                            child: Text(
                              item.label,
                              style: const TextStyle(
                                fontFamily: ADayTypography.fontFamily,
                                fontSize: 11.5,
                                color: ADayColors.brandNavy,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${item.percentage}%',
                            style: const TextStyle(
                              fontFamily: ADayTypography.fontFamily,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w700,
                              color: ADayColors.brandNavy,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusDonutPainter extends CustomPainter {
  const _StatusDonutPainter({required this.items});

  final List<CompletionBreakdownItem> items;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.17;
    final radius = (size.width - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    final totalPercentage = items.fold<int>(
      0,
      (sum, item) => sum + item.percentage,
    );
    if (totalPercentage <= 0) return;

    double startAngle = -math.pi / 2; // Start from top 12 o'clock

    for (final item in items) {
      if (item.percentage <= 0) continue;
      final sweepAngle = (item.percentage / totalPercentage) * (2 * math.pi);

      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(arcRect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _StatusDonutPainter oldDelegate) {
    return oldDelegate.items != items;
  }
}
