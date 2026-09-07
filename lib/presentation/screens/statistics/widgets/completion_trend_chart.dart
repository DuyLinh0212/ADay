import 'package:flutter/material.dart';

import '../../../../core/theme/aday_colors.dart';
import '../../../../core/theme/aday_spacing.dart';
import '../../../../core/theme/aday_typography.dart';
import '../statistics_view_data.dart';

/// Interactive completion trend bar chart rendered using [CustomPainter].
///
/// Implements the "Xu hướng hoàn thành" section from Lich.png:
/// - Y-axis percentage markers (0%, 25%, 50%, 75%, 100%)
/// - Soft horizontal grid lines (Divider Mist)
/// - Rounded background capsule tracks
/// - Vibrant progress teal filled bars
/// - Fully scalable for varying screen sizes and text scaling
/// - Complete accessibility semantics announcements
class CompletionTrendChart extends StatelessWidget {
  const CompletionTrendChart({
    super.key,
    required this.dataPoints,
    this.title = 'Xu hướng hoàn thành',
    this.actionLabel = 'Xem chi tiết',
    this.onActionTap,
  });

  final List<TrendDataPoint> dataPoints;
  final String title;
  final String actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ADayColors.surface,
        borderRadius: ADaySpacing.surfaceRadius,
        border: Border.all(color: ADayColors.dividerMist, width: 1.0),
      ),
      padding: const EdgeInsets.all(ADaySpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Header with Title & Action Link
          _buildHeader(context),

          const SizedBox(height: ADaySpacing.md),

          // 2. Custom Painted Chart
          SizedBox(
            height: 180.0,
            child: Semantics(
              label: _buildAccessibleSummary(),
              child: CustomPaint(
                painter: _TrendChartPainter(dataPoints: dataPoints),
                size: const Size(double.infinity, 180.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.trending_up_rounded,
              color: ADayColors.actionBlue,
              size: 24.0,
            ),
            const SizedBox(width: ADaySpacing.sm),
            Text(
              title,
              style: ADayTypography.title.copyWith(
                fontSize: 18.0,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        if (onActionTap != null)
          Semantics(
            button: true,
            label: '$actionLabel biểu đồ xu hướng',
            child: InkWell(
              onTap: onActionTap,
              borderRadius: ADaySpacing.controlRadius,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: ADaySpacing.minTouchTarget,
                  minWidth: ADaySpacing.minTouchTarget,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4.0,
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
                          fontWeight: FontWeight.w600,
                          color: ADayColors.actionBlue,
                        ),
                      ),
                      const SizedBox(width: 2.0),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 16.0,
                        color: ADayColors.actionBlue,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _buildAccessibleSummary() {
    final buffer = StringBuffer('Biểu đồ xu hướng hoàn thành theo ngày: ');
    for (final point in dataPoints) {
      final pct = point.valueLabel ?? '${(point.percentage * 100).round()}%';
      buffer.write('${point.label} đạt $pct, ');
    }
    return buffer.toString();
  }
}

/// CustomPainter drawing the Y-axis guidelines, percentage labels, and capsules.
class _TrendChartPainter extends CustomPainter {
  const _TrendChartPainter({required this.dataPoints});

  final List<TrendDataPoint> dataPoints;

  static const List<double> _ySteps = [1.0, 0.75, 0.50, 0.25, 0.0];
  static const List<String> _yLabels = ['100%', '75%', '50%', '25%', '0%'];

  @override
  void paint(Canvas canvas, Size size) {
    const yAxisLabelWidth = 36.0;
    const labelBottomHeight = 24.0;
    const topPadding = 10.0;

    final chartArea = Rect.fromLTWH(
      yAxisLabelWidth,
      topPadding,
      size.width - yAxisLabelWidth - 8.0,
      size.height - labelBottomHeight - topPadding,
    );

    // 1. Draw Grid Lines & Y-Axis Labels
    final linePaint = Paint()
      ..color = ADayColors.dividerMist
      ..strokeWidth = 1.0;

    for (int i = 0; i < _ySteps.length; i++) {
      final ratio = _ySteps[i];
      final y = chartArea.bottom - (chartArea.height * ratio);

      // Horizontal guideline
      canvas.drawLine(
        Offset(chartArea.left, y),
        Offset(chartArea.right, y),
        linePaint,
      );

      // Label text
      final textPainter = TextPainter(
        text: TextSpan(
          text: _yLabels[i],
          style: const TextStyle(
            fontFamily: ADayTypography.fontFamily,
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            color: ADayColors.mutedInk,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          chartArea.left - textPainter.width - 6.0,
          y - textPainter.height / 2,
        ),
      );
    }

    if (dataPoints.isEmpty) return;

    // 2. Draw Bar Columns
    final barCount = dataPoints.length;
    final columnWidth = chartArea.width / barCount;
    final barWidth = (columnWidth * 0.44).clamp(14.0, 24.0);

    for (int i = 0; i < barCount; i++) {
      final point = dataPoints[i];
      final centerX = chartArea.left + (i + 0.5) * columnWidth;
      final barRect = Rect.fromCenter(
        center: Offset(centerX, chartArea.top + chartArea.height / 2),
        width: barWidth,
        height: chartArea.height,
      );

      // A. Background track capsule
      final trackPaint = Paint()..color = const Color(0xFFEFF6FB);
      final rrectTrack = RRect.fromRectAndRadius(
        barRect,
        Radius.circular(barWidth / 2),
      );
      canvas.drawRRect(rrectTrack, trackPaint);

      // B. Filled Progress Bar
      final filledHeight =
          (chartArea.height * point.percentage.clamp(0.0, 1.0));
      if (filledHeight > 0) {
        final fillRect = Rect.fromLTWH(
          centerX - barWidth / 2,
          chartArea.bottom - filledHeight,
          barWidth,
          filledHeight,
        );

        final fillPaint = Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF20C99A), Color(0xFF0EB8AC)],
          ).createShader(fillRect);

        final rrectFill = RRect.fromRectAndRadius(
          fillRect,
          Radius.circular(barWidth / 2),
        );
        canvas.drawRRect(rrectFill, fillPaint);
      }

      // C. X-Axis Day Label (T2, T3, ...)
      final dayPainter = TextPainter(
        text: TextSpan(
          text: point.label,
          style: TextStyle(
            fontFamily: ADayTypography.fontFamily,
            fontSize: 11.5,
            fontWeight: point.isHighlighted ? FontWeight.w700 : FontWeight.w500,
            color: point.isHighlighted
                ? ADayColors.actionBlue
                : ADayColors.brandNavy,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      dayPainter.paint(
        canvas,
        Offset(centerX - dayPainter.width / 2, chartArea.bottom + 6.0),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints;
  }
}
