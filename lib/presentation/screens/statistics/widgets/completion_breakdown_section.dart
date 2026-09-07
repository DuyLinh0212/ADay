import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/theme/aday_colors.dart';
import '../../../../core/theme/aday_spacing.dart';
import '../../../../core/theme/aday_typography.dart';
import '../../../widgets/mountain_sun_visual.dart';
import '../statistics_view_data.dart';

/// The bottom section containing the donut completion breakdown and encouraging insight cards.
///
/// Implements the two bottom surface cards from Lich.png:
/// - Donut chart with segmented percentages (Đã hoàn thành, Còn lại, Đã dời/hủy)
/// - Encouraging insight card with trophy icon and mountain summit flag
/// - Responsive side-by-side or stacked layout resilient to large text scales
class CompletionBreakdownSection extends StatelessWidget {
  const CompletionBreakdownSection({
    super.key,
    required this.breakdownItems,
    required this.insight,
    this.breakdownTitle = 'Tỉ lệ hoàn thành lịch trình',
    this.onBreakdownTap,
    this.onInsightTap,
  });

  final List<CompletionBreakdownItem> breakdownItems;
  final EncouragingInsightData insight;
  final String breakdownTitle;
  final VoidCallback? onBreakdownTap;
  final VoidCallback? onInsightTap;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360 || textScale > 1.25;

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBreakdownCard(context),
              const SizedBox(height: ADaySpacing.md),
              _buildInsightCard(context),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 54, child: _buildBreakdownCard(context)),
            const SizedBox(width: ADaySpacing.md),
            Expanded(flex: 46, child: _buildInsightCard(context)),
          ],
        );
      },
    );
  }

  /// Donut breakdown card on the left.
  Widget _buildBreakdownCard(BuildContext context) {
    final completedItem = breakdownItems.isNotEmpty
        ? breakdownItems.first
        : null;
    final centerPercentage = completedItem != null
        ? '${completedItem.percentage}%'
        : '0%';

    return Container(
      decoration: BoxDecoration(
        color: ADayColors.surface,
        borderRadius: ADaySpacing.surfaceRadius,
        border: Border.all(color: ADayColors.dividerMist, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onBreakdownTap,
          borderRadius: ADaySpacing.surfaceRadius,
          child: Padding(
            padding: const EdgeInsets.all(ADaySpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Card Header
                Row(
                  children: [
                    Container(
                      width: 28.0,
                      height: 28.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD7F5EC),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Icon(
                        Icons.playlist_add_check_rounded,
                        color: Color(0xFF20C99A),
                        size: 18.0,
                      ),
                    ),
                    const SizedBox(width: ADaySpacing.xs + 2),
                    Expanded(
                      child: Text(
                        breakdownTitle,
                        style: ADayTypography.titleMedium.copyWith(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: ADaySpacing.md),

                // Donut Chart & Side Legend
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Donut Chart (76x76)
                    SizedBox(
                      width: 76.0,
                      height: 76.0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(76.0, 76.0),
                            painter: _DonutChartPainter(items: breakdownItems),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                centerPercentage,
                                style: const TextStyle(
                                  fontFamily: ADayTypography.fontFamily,
                                  fontSize: 16.0,
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
                                  fontWeight: FontWeight.w500,
                                  color: ADayColors.mutedInk,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: ADaySpacing.md),

                    // Legend
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: breakdownItems.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3.0),
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
          ),
        ),
      ),
    );
  }

  /// Encouraging insight card on the right.
  Widget _buildInsightCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ADayColors.surface,
        borderRadius: ADaySpacing.surfaceRadius,
        border: Border.all(color: ADayColors.dividerMist, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background mountain illustration with summit flag
          Positioned(
            right: 0,
            bottom: 0,
            width: 140.0,
            height: 75.0,
            child: const MountainSunVisual(
              height: 75.0,
              showFlag: true,
              showSunRays: false,
              sunPosition: Offset(0.85, 0.25),
            ),
          ),

          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onInsightTap,
              borderRadius: ADaySpacing.surfaceRadius,
              child: Padding(
                padding: const EdgeInsets.all(ADaySpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Green Trophy Icon Badge
                    Container(
                      width: 32.0,
                      height: 32.0,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD7F5EC),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        insight.icon,
                        color: insight.iconColor,
                        size: 18.0,
                      ),
                    ),

                    const SizedBox(height: ADaySpacing.sm),

                    // Insight Title
                    Text(
                      insight.title,
                      style: ADayTypography.titleMedium.copyWith(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 3.0),

                    // Insight Message with bold highlighted portion
                    Text.rich(
                      TextSpan(
                        style: ADayTypography.subhead.copyWith(
                          fontSize: 12.5,
                          height: 1.35,
                          color: ADayColors.brandNavy.withValues(alpha: 0.82),
                        ),
                        children: _buildHighlightedMessage(
                          insight.message,
                          insight.highlightText,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _buildHighlightedMessage(String message, String highlight) {
    if (!message.contains(highlight)) {
      return [TextSpan(text: message)];
    }

    final parts = message.split(highlight);
    return [
      TextSpan(text: parts[0]),
      TextSpan(
        text: highlight,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF20C99A),
        ),
      ),
      if (parts.length > 1) TextSpan(text: parts[1]),
    ];
  }
}

/// CustomPainter drawing the segmented donut arcs.
class _DonutChartPainter extends CustomPainter {
  const _DonutChartPainter({required this.items});

  final List<CompletionBreakdownItem> items;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.18;
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
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.items != items;
  }
}
