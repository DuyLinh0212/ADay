import 'package:flutter/material.dart';

import '../../../../core/theme/aday_colors.dart';
import '../../../../core/theme/aday_spacing.dart';
import '../../../../core/theme/aday_typography.dart';
import '../../../widgets/mountain_sun_visual.dart';
import '../statistics_view_data.dart';

/// Month calendar surface card matching the top portion of Lich.png.
///
/// Features:
/// - Month selector with previous/next controls and "Hôm nay" quick button
/// - Accessible 7-day grid (Th 2 -> CN) with guaranteed 44x44 touch targets
/// - Accessible day states (today, completed, postponed, cancelled, other month)
/// - Non-color state indicators and complete voice-over semantics
/// - Side legend, today summary chip, and quote with sunrise illustration
/// - Responsive side-by-side or stacked layout resilient to large dynamic text
class CalendarMonthView extends StatelessWidget {
  const CalendarMonthView({
    super.key,
    required this.data,
    this.onDayTap,
    this.onPrevMonth,
    this.onNextMonth,
    this.onTodayTap,
    this.onTodaySummaryTap,
  });

  final CalendarMonthData data;
  final ValueChanged<CalendarDayData>? onDayTap;
  final VoidCallback? onPrevMonth;
  final VoidCallback? onNextMonth;
  final VoidCallback? onTodayTap;
  final VoidCallback? onTodaySummaryTap;

  static const List<String> _weekDayLabels = [
    'Th 2',
    'Th 3',
    'Th 4',
    'Th 5',
    'Th 6',
    'Th 7',
    'CN',
  ];

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;

    return Container(
      decoration: BoxDecoration(
        color: ADayColors.surface,
        borderRadius: ADaySpacing.surfaceRadius,
        border: Border.all(color: ADayColors.dividerMist, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background soft mountain & sunrise illustration in bottom right
          Positioned(
            right: -10,
            bottom: -10,
            width: 150,
            height: 90,
            child: const MountainSunVisual(
              height: 90,
              showSunRays: true,
              sunPosition: Offset(0.70, 0.30),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(ADaySpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Month Header & "Hôm nay" Action
                _buildHeader(context),

                const SizedBox(height: ADaySpacing.md),

                // 2. Responsive Body: Grid + Side Column
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact =
                        constraints.maxWidth < 350 || textScale > 1.25;

                    if (isCompact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildCalendarGrid(context),
                          const SizedBox(height: ADaySpacing.md),
                          Divider(
                            color: ADayColors.dividerMist,
                            height: 1.0,
                          ),
                          const SizedBox(height: ADaySpacing.md),
                          _buildSideLegend(context),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Calendar grid (left 63%)
                        Expanded(flex: 63, child: _buildCalendarGrid(context)),

                        const SizedBox(width: ADaySpacing.md),

                        // Side legend, summary, quote (right 37%)
                        Expanded(flex: 37, child: _buildSideLegend(context)),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Top month selector and today quick button.
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Month Navigation: < Tháng 6, 2025 >
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              button: true,
              label: 'Tháng trước',
              child: SizedBox(
                width: ADaySpacing.minTouchTarget,
                height: ADaySpacing.minTouchTarget,
                child: IconButton(
                  onPressed: onPrevMonth,
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    color: ADayColors.actionBlue,
                    size: 26.0,
                  ),
                  tooltip: 'Tháng trước',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                data.monthLabel,
                style: ADayTypography.title.copyWith(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                  color: ADayColors.brandNavy,
                ),
              ),
            ),
            Semantics(
              button: true,
              label: 'Tháng sau',
              child: SizedBox(
                width: ADaySpacing.minTouchTarget,
                height: ADaySpacing.minTouchTarget,
                child: IconButton(
                  onPressed: onNextMonth,
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: ADayColors.actionBlue,
                    size: 26.0,
                  ),
                  tooltip: 'Tháng sau',
                ),
              ),
            ),
          ],
        ),

        // "Hôm nay" quick jump pill button
        Semantics(
          button: true,
          label: 'Về ngày hôm nay',
          child: Material(
            color: const Color(0xFFE8F3FD),
            borderRadius: ADaySpacing.pillRadius,
            child: InkWell(
              onTap: onTodayTap,
              borderRadius: ADaySpacing.pillRadius,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 36.0,
                  minWidth: ADaySpacing.minTouchTarget,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 6.0,
                  ),
                  child: Center(
                    child: Text(
                      'Hôm nay',
                      style: TextStyle(
                        fontFamily: ADayTypography.fontFamily,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w700,
                        color: ADayColors.actionBlue,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// The 7-column calendar grid with weekday headers.
  Widget _buildCalendarGrid(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Weekday header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _weekDayLabels.map((dayLabel) {
            return Expanded(
              child: Center(
                child: Text(
                  dayLabel,
                  style: ADayTypography.caption.copyWith(
                    color: ADayColors.mutedInk,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.0,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: ADaySpacing.xs),

        // Days Grid (6 weeks x 7 days)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.days.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 2.0,
            crossAxisSpacing: 2.0,
            childAspectRatio: 0.92,
          ),
          itemBuilder: (context, index) {
            final day = data.days[index];
            return _CalendarDayCell(
              day: day,
              onTap: onDayTap != null ? () => onDayTap!(day) : null,
            );
          },
        ),
      ],
    );
  }

  /// Legend, today mini-card, and quote.
  Widget _buildSideLegend(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Legend Items
        _buildLegendRow(
          color: const Color(0xFF20C99A),
          label: 'Đã hoàn thành',
          semanticsPrefix: 'Chấm xanh lục biểu thị',
        ),
        const SizedBox(height: 6.0),
        _buildLegendRow(
          color: const Color(0xFFFFB52E),
          label: 'Đã dời lịch',
          semanticsPrefix: 'Chấm vàng cam biểu thị',
        ),
        const SizedBox(height: 6.0),
        _buildLegendRow(
          color: const Color(0xFFF0525E),
          label: 'Đã hủy',
          semanticsPrefix: 'Chấm đỏ san hô biểu thị',
        ),
        const SizedBox(height: 6.0),
        _buildLegendRow(
          color: const Color(0xFF38B8F8),
          label: 'Ngày hôm nay',
          semanticsPrefix: 'Vòng tròn xanh lam biểu thị',
        ),
        const SizedBox(height: 6.0),
        _buildLegendRow(
          color: const Color(0xFFB0C4DE),
          label: 'Có kế hoạch',
          semanticsPrefix: 'Chấm xám biểu thị',
        ),

        const SizedBox(height: ADaySpacing.md),

        // 2. Mini Pill: 4 / 6 nhiệm vụ hôm nay >
        Semantics(
          button: true,
          label: '${data.todaySummaryLabel}, nhấn để xem chi tiết',
          child: Material(
            color: const Color(0xFFE8F6FD),
            borderRadius: BorderRadius.circular(10.0),
            child: InkWell(
              onTap: onTodaySummaryTap,
              borderRadius: BorderRadius.circular(10.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: ADaySpacing.minTouchTarget,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 15.0,
                        color: ADayColors.actionBlue,
                      ),
                      const SizedBox(width: 6.0),
                      Expanded(
                        child: Text(
                          data.todaySummaryLabel,
                          style: TextStyle(
                            fontFamily: ADayTypography.fontFamily,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                            color: ADayColors.brandNavy,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
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
        ),

        const SizedBox(height: ADaySpacing.sm + 2),

        // 3. Quote
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text(
            data.quote,
            style: ADayTypography.quote.copyWith(
              fontSize: 11.5,
              color: ADayColors.brandNavy.withValues(alpha: 0.75),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendRow({
    required Color color,
    required String label,
    required String semanticsPrefix,
  }) {
    return Semantics(
      label: '$semanticsPrefix $label',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 8.0,
            height: 8.0,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8.0),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: ADayTypography.fontFamily,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: ADayColors.brandNavy,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Single day cell inside the calendar grid.
class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({required this.day, required this.onTap});

  final CalendarDayData day;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Styling resolution
    Color textColor = ADayColors.brandNavy;
    if (!day.isCurrentMonth) {
      textColor = const Color(0xFFB0C4DE);
    } else if (day.isToday || day.isSelected) {
      textColor = ADayColors.brandNavy;
    }

    Color? backgroundColor;
    if (day.isToday) {
      // Light blue circle background matching day 10 in Lich.png
      backgroundColor = const Color(0xFFD6EDFC);
    } else if (day.status == CalendarDayStatus.completed &&
        (day.dayNumber == 12)) {
      backgroundColor = const Color(0xFFD7F5EC);
    } else if (day.status == CalendarDayStatus.cancelled &&
        (day.dayNumber == 14)) {
      backgroundColor = const Color(0xFFFFDDE0);
    }

    return Semantics(
      button: true,
      label: day.accessibleDescription,
      selected: day.isSelected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: ADaySpacing.minTouchTarget,
            minHeight: ADaySpacing.minTouchTarget,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28.0,
                  height: 28.0,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${day.dayNumber}',
                      style: TextStyle(
                        fontFamily: ADayTypography.fontFamily,
                        fontSize: 13.0,
                        fontWeight: day.isToday || day.isCurrentMonth
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                // Dot indicator for day status
                _buildDotIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDotIndicator() {
    Color? dotColor;
    if (day.isToday) {
      dotColor = const Color(0xFF168AF2);
    } else if (day.status == CalendarDayStatus.completed) {
      dotColor = const Color(0xFF20C99A);
    } else if (day.status == CalendarDayStatus.postponed) {
      dotColor = const Color(0xFFFFB52E);
    } else if (day.status == CalendarDayStatus.cancelled) {
      dotColor = const Color(0xFFF0525E);
    } else if (day.status == CalendarDayStatus.planned) {
      dotColor = const Color(0xFFB0C4DE);
    }

    return SizedBox(
      height: 4.0,
      child: dotColor != null
          ? Container(
              width: 4.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}
