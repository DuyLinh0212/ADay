import 'package:flutter/material.dart';

import '../../../../core/theme/aday_colors.dart';
import '../../../../core/theme/aday_spacing.dart';
import '../../../../core/theme/aday_typography.dart';
import '../statistics_view_data.dart';

/// Section container for the period selector and 4 metric cards matching Lich.png.
///
/// Features:
/// - "Thống kê tiến độ" header with period pills (Tuần, Tháng, Năm)
/// - 4 distinct metric cards with pastel backgrounds and icons
/// - Positive trends with directional arrows and accessibility announcements
/// - Responsive layout transitioning to a 2x2 grid on narrow devices or large text scale
class StatisticsMetricCards extends StatelessWidget {
  const StatisticsMetricCards({
    super.key,
    required this.selectedPeriod,
    required this.completionMetric,
    required this.postponedMetric,
    required this.cancelledMetric,
    required this.streakMetric,
    this.onPeriodChanged,
    this.title = 'Thống kê tiến độ',
  });

  final StatisticsPeriod selectedPeriod;
  final StatisticMetricItem completionMetric;
  final StatisticMetricItem postponedMetric;
  final StatisticMetricItem cancelledMetric;
  final StatisticMetricItem streakMetric;
  final ValueChanged<StatisticsPeriod>? onPeriodChanged;
  final String title;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Header with Period Selector
        _buildHeader(context),

        const SizedBox(height: ADaySpacing.md),

        // 2. Metrics Cards Row / Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 360 || textScale > 1.15;

            final metrics = [
              completionMetric,
              postponedMetric,
              cancelledMetric,
              streakMetric,
            ];

            if (isNarrow) {
              // 2x2 Grid for narrow screens or large dynamic text
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCardItem(
                          item: metrics[0],
                          period: selectedPeriod,
                        ),
                      ),
                      const SizedBox(width: ADaySpacing.sm),
                      Expanded(
                        child: _MetricCardItem(
                          item: metrics[1],
                          period: selectedPeriod,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ADaySpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCardItem(
                          item: metrics[2],
                          period: selectedPeriod,
                        ),
                      ),
                      const SizedBox(width: ADaySpacing.sm),
                      Expanded(
                        child: _MetricCardItem(
                          item: metrics[3],
                          period: selectedPeriod,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            // 4 side-by-side columns matching Lich.png
            return Row(
              children: [
                Expanded(
                  child: _MetricCardItem(
                    item: metrics[0],
                    period: selectedPeriod,
                  ),
                ),
                const SizedBox(width: ADaySpacing.xs + 2),
                Expanded(
                  child: _MetricCardItem(
                    item: metrics[1],
                    period: selectedPeriod,
                  ),
                ),
                const SizedBox(width: ADaySpacing.xs + 2),
                Expanded(
                  child: _MetricCardItem(
                    item: metrics[2],
                    period: selectedPeriod,
                  ),
                ),
                const SizedBox(width: ADaySpacing.xs + 2),
                Expanded(
                  child: _MetricCardItem(
                    item: metrics[3],
                    period: selectedPeriod,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Title with blue bar chart icon
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              color: ADayColors.actionBlue,
              size: 26.0,
            ),
            const SizedBox(width: ADaySpacing.xs + 2),
            Text(
              title,
              style: ADayTypography.title.copyWith(
                fontSize: 18.0,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),

        // Period pills (Tuần, Tháng, Năm)
        Container(
          padding: const EdgeInsets.all(3.0),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F3FD),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: StatisticsPeriod.values.map((period) {
              final isSelected = period == selectedPeriod;

              return Semantics(
                button: true,
                selected: isSelected,
                label: 'Xem theo ${period.label}',
                child: Material(
                  color: isSelected
                      ? ADayColors.actionBlue
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.0),
                  child: InkWell(
                    onTap: onPeriodChanged != null
                        ? () => onPeriodChanged!(period)
                        : null,
                    borderRadius: BorderRadius.circular(8.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 44.0,
                        minHeight: 32.0,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 6.0,
                        ),
                        child: Center(
                          child: Text(
                            period.label,
                            style: TextStyle(
                              fontFamily: ADayTypography.fontFamily,
                              fontSize: 12.5,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isSelected
                                  ? ADayColors.surface
                                  : ADayColors.brandNavy,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Single pastel metric card matching Lich.png.
class _MetricCardItem extends StatelessWidget {
  const _MetricCardItem({required this.item, required this.period});

  final StatisticMetricItem item;
  final StatisticsPeriod period;

  @override
  Widget build(BuildContext context) {
    final style = item.visualStyle;
    final periodPhrase = period == StatisticsPeriod.week
        ? 'so với tuần trước'
        : (period == StatisticsPeriod.year
              ? 'so với năm trước'
              : 'so với tháng trước');

    return Container(
      decoration: BoxDecoration(
        color: style.$1,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: style.$2.withValues(alpha: 0.6), width: 1.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon badge
          Container(
            width: 32.0,
            height: 32.0,
            decoration: BoxDecoration(color: style.$3, shape: BoxShape.circle),
            child: Icon(style.$4, color: Colors.white, size: 18.0),
          ),

          const SizedBox(height: 8.0),

          // Value
          Text(
            item.value,
            style: TextStyle(
              fontFamily: ADayTypography.fontFamily,
              fontSize: 20.0,
              fontWeight: FontWeight.w800,
              color: ADayColors.brandNavy,
              height: 1.1,
            ),
          ),

          const SizedBox(height: 3.0),

          // Title
          Text(
            item.title,
            style: TextStyle(
              fontFamily: ADayTypography.fontFamily,
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              color: ADayColors.brandNavy,
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 6.0),

          // Trend badge / Note
          if (item.isNote) ...[
            Text(
              item.trendText ?? '',
              style: ADayTypography.quote.copyWith(
                fontSize: 10.5,
                color: ADayColors.brandNavy.withValues(alpha: 0.75),
                height: 1.2,
              ),
            ),
          ] else if (item.trendText != null) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.trendText!,
                  style: const TextStyle(
                    fontFamily: ADayTypography.fontFamily,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF20C99A),
                  ),
                ),
                Text(
                  periodPhrase,
                  style: TextStyle(
                    fontFamily: ADayTypography.fontFamily,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    color: ADayColors.mutedInk,
                    height: 1.15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
