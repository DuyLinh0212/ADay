import 'package:flutter/material.dart';

import '../../../../core/theme/aday_colors.dart';
import '../../../../core/theme/aday_spacing.dart';
import '../../../../core/theme/aday_typography.dart';
import '../statistics_view_data.dart';

/// Card displaying the 5 overview metrics matching Image 2 ("Tổng quan tháng 6, 2025").
class OverviewMetricsCard extends StatelessWidget {
  const OverviewMetricsCard({
    super.key,
    required this.title,
    required this.metrics,
    this.actionLabel = 'Xem chi tiết',
    this.onActionTap,
  });

  final String title;
  final List<OverviewMetricItem> metrics;
  final String actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
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
          // 1. Header with icon, title, and action link
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.bar_chart_rounded,
                    color: ADayColors.actionBlue,
                    size: 24.0,
                  ),
                  const SizedBox(width: ADaySpacing.sm),
                  Text(
                    title,
                    style: ADayTypography.title.copyWith(
                      fontSize: 16.5,
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
                      horizontal: 4.0,
                      vertical: 4.0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          actionLabel,
                          style: const TextStyle(
                            fontFamily: ADayTypography.fontFamily,
                            fontSize: 12.5,
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
            ],
          ),

          const SizedBox(height: ADaySpacing.md),

          // 2. Horizontal Scroll of 5 mini-cards
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(metrics.length, (index) {
                final item = metrics[index];
                final isLast = index == metrics.length - 1;
                return Padding(
                  padding: EdgeInsets.only(right: isLast ? 0.0 : 8.0),
                  child: _MiniMetricCard(item: item),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetricCard extends StatelessWidget {
  const _MiniMetricCard({required this.item});

  final OverviewMetricItem item;

  @override
  Widget build(BuildContext context) {
    final parts = item.deltaText.split(' so với ');
    final deltaMain = parts.first;
    final deltaSub = parts.length > 1 ? 'so với ${parts[1]}' : '';

    return Container(
      width: 104.0,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: item.iconBgColor,
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon badge circle
          Container(
            width: 32.0,
            height: 32.0,
            decoration: BoxDecoration(
              color: item.iconColor,
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: Colors.white, size: 18.0),
          ),

          const SizedBox(height: 10.0),

          // Value
          Text(
            item.value,
            style: const TextStyle(
              fontFamily: ADayTypography.fontFamily,
              fontSize: 22.0,
              fontWeight: FontWeight.w800,
              color: ADayColors.brandNavy,
              height: 1.1,
            ),
          ),

          const SizedBox(height: 4.0),

          // Title
          SizedBox(
            height: 28.0,
            child: Text(
              item.title,
              style: const TextStyle(
                fontFamily: ADayTypography.fontFamily,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: ADayColors.brandNavy,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 6.0),

          // Delta tag
          Text(
            deltaMain,
            style: const TextStyle(
              fontFamily: ADayTypography.fontFamily,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF20C99A),
              height: 1.2,
            ),
          ),
          if (deltaSub.isNotEmpty)
            Text(
              deltaSub,
              style: const TextStyle(
                fontFamily: ADayTypography.fontFamily,
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
                color: ADayColors.mutedInk,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}
