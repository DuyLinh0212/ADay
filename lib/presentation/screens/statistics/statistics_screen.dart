import 'package:flutter/material.dart';

import '../../../core/theme/aday_colors.dart';
import '../../../core/theme/aday_spacing.dart';
import '../../../core/theme/aday_typography.dart';
import '../../widgets/aday_bottom_nav.dart';
import '../../widgets/aday_logo_header.dart';
import 'statistics_view_data.dart';
import 'widgets/calendar_month_view.dart';
import 'widgets/completion_breakdown_section.dart';
import 'widgets/completion_trend_chart.dart';
import 'widgets/statistics_metric_cards.dart';

/// The authoritative Statistics and Calendar presentation screen for ADay, matching Lich.png.
///
/// Follows DESIGN.md and PRODUCT.md strictly:
/// - Screen title: "Lịch & Thống kê" with calming, encouraging subtitle
/// - Month calendar with accessible day states (completed, postponed, cancelled, today, planned)
/// - Week / Month / Year period selector
/// - 4 metric cards: Completed, Postponed, Cancelled, Streak
/// - CustomPainter-driven trend chart (Xu hướng hoàn thành)
/// - Segmented donut completion breakdown and encouraging insight card
/// - All stats come from immutable presentation input types defined in this folder
/// - Accepts all data and callbacks through public constructor parameters
/// - Resilient to narrow screens and textScaleFactor up to 1.5
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({
    super.key,
    this.data,
    this.showHeader = true,
    this.showBottomNav = true,
    this.bottomNavIndex = 1,
    this.hasUnreadNotifications = true,
    this.avatarInitials = 'M',
    this.onLogoTap,
    this.onSearchTap,
    this.onNotificationTap,
    this.onAvatarTap,
    this.onDayTap,
    this.onPrevMonth,
    this.onNextMonth,
    this.onTodayTap,
    this.onTodaySummaryTap,
    this.onPeriodChanged,
    this.onViewTrendDetails,
    this.onBreakdownTap,
    this.onInsightTap,
    this.onNavTap,
  });

  /// Master immutable presentation view data.
  /// If null, a sample matching Lich.png is used.
  final StatisticsViewData? data;

  /// Whether to display the top header bar.
  final bool showHeader;

  /// Whether to display the bottom navigation bar.
  final bool showBottomNav;

  /// Active bottom navigation tab index (default: 1 for "Lịch").
  final int bottomNavIndex;

  /// Whether notification bell shows an unread badge.
  final bool hasUnreadNotifications;

  /// User avatar initials.
  final String avatarInitials;

  // --- Callbacks ---
  final VoidCallback? onLogoTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;
  final ValueChanged<CalendarDayData>? onDayTap;
  final VoidCallback? onPrevMonth;
  final VoidCallback? onNextMonth;
  final VoidCallback? onTodayTap;
  final VoidCallback? onTodaySummaryTap;
  final ValueChanged<StatisticsPeriod>? onPeriodChanged;
  final VoidCallback? onViewTrendDetails;
  final VoidCallback? onBreakdownTap;
  final VoidCallback? onInsightTap;
  final ValueChanged<int>? onNavTap;

  @override
  Widget build(BuildContext context) {
    final effectiveData = data ?? StatisticsViewData.sample();

    return Scaffold(
      backgroundColor: ADayColors.canvas,
      body: SafeArea(
        bottom: !showBottomNav,
        child: Column(
          children: [
            // 1. Top Header Bar
            if (showHeader)
              ADayHeaderBar(
                onLogoTap: onLogoTap,
                onSearchTap: onSearchTap,
                onNotificationTap: onNotificationTap,
                onAvatarTap: onAvatarTap,
                hasUnreadNotifications: hasUnreadNotifications,
                avatarInitials: avatarInitials,
              ),

            // 2. Scrollable Body Content
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: ADaySpacing.md,
                  vertical: ADaySpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // A. Screen Title & Encouraging Subtitle
                    _buildTitleSection(context, effectiveData),

                    const SizedBox(height: ADaySpacing.md),

                    // B. Month Calendar Card with Accessible States
                    CalendarMonthView(
                      data: effectiveData.calendar,
                      onDayTap: onDayTap,
                      onPrevMonth: onPrevMonth,
                      onNextMonth: onNextMonth,
                      onTodayTap: onTodayTap,
                      onTodaySummaryTap: onTodaySummaryTap,
                    ),

                    const SizedBox(height: ADaySpacing.lg),

                    // C. Period Selector & 4 Metric Cards
                    StatisticsMetricCards(
                      selectedPeriod: effectiveData.selectedPeriod,
                      completionMetric: effectiveData.completionMetric,
                      postponedMetric: effectiveData.postponedMetric,
                      cancelledMetric: effectiveData.cancelledMetric,
                      streakMetric: effectiveData.streakMetric,
                      onPeriodChanged: onPeriodChanged,
                    ),

                    const SizedBox(height: ADaySpacing.lg),

                    // D. Completion Trend Chart via CustomPainter
                    CompletionTrendChart(
                      dataPoints: effectiveData.trendPoints,
                      actionLabel: effectiveData.trendSummaryActionLabel,
                      onActionTap: onViewTrendDetails,
                    ),

                    const SizedBox(height: ADaySpacing.lg),

                    // E. Breakdown Donut Chart & Encouraging Insight
                    CompletionBreakdownSection(
                      breakdownItems: effectiveData.breakdownItems,
                      insight: effectiveData.insight,
                      onBreakdownTap: onBreakdownTap,
                      onInsightTap: onInsightTap,
                    ),

                    const SizedBox(height: ADaySpacing.lg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: showBottomNav
          ? ADayBottomNav(
              currentIndex: bottomNavIndex,
              onTap: onNavTap ?? (_) {},
            )
          : null,
    );
  }

  /// Screen headline and subtitle matching Lich.png.
  Widget _buildTitleSection(BuildContext context, StatisticsViewData viewData) {
    return Semantics(
      header: true,
      label: '${viewData.screenTitle}. ${viewData.screenSubtitle}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            viewData.screenTitle,
            style: ADayTypography.headline.copyWith(fontSize: 26.0),
          ),
          const SizedBox(height: 3.0),
          Text(
            viewData.screenSubtitle,
            style: ADayTypography.subhead.copyWith(
              fontSize: 14.5,
              height: 1.4,
              color: ADayColors.mutedInk,
            ),
          ),
        ],
      ),
    );
  }
}
