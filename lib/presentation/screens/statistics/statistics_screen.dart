import 'package:flutter/material.dart';

import '../../../core/theme/aday_colors.dart';
import '../../../core/theme/aday_spacing.dart';
import '../../../core/theme/aday_typography.dart';
import '../../widgets/aday_bottom_nav.dart';
import '../../widgets/aday_logo_header.dart';
import '../../widgets/mountain_sun_visual.dart';
import 'statistics_view_data.dart';
import 'widgets/category_performance_card.dart';
import 'widgets/completion_trend_chart.dart';
import 'widgets/encouragement_banner_card.dart';
import 'widgets/overview_metrics_card.dart';
import 'widgets/status_breakdown_card.dart';

/// The authoritative Statistics presentation screen for ADay, matching Image 2.
///
/// Features:
/// - Top header bar with logo, search, notifications, avatar
/// - Screen title "Thống kê" and subtitle "Nhìn lại hành trình để cải thiện mỗi ngày."
///   with scenic mountain & sunrise visual background
/// - Segmented period toggle: Tuần | Tháng | Năm
/// - Overview card ("Tổng quan tháng 6, 2025") with 5 metric cards and deltas
/// - Completion trend chart with percentage labels above each bar
/// - Two side-by-side cards: "Phân bố trạng thái" (Donut) & "Hiệu quả theo danh mục" (Progress bars)
/// - Encouragement card ("Bạn đang làm rất tốt!") with trophy, message, mountain flag artwork and quote
/// - Bottom navigation bar with active index 2 ("Thống kê")
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({
    super.key,
    required this.data,
    this.showHeader = true,
    this.showBottomNav = true,
    this.bottomNavIndex = 2,
    this.hasUnreadNotifications = false,
    this.avatarInitials = 'M',
    this.onLogoTap,
    this.onSearchTap,
    this.onNotificationTap,
    this.onAvatarTap,
    this.onPeriodChanged,
    this.onViewOverviewDetails,
    this.onViewTrendDetails,
    this.onBreakdownTap,
    this.onCategoryDetailsTap,
    this.onInsightTap,
    this.onCreateGoalTap,
    this.onNavTap,
  });

  final StatisticsViewData data;
  final bool showHeader;
  final bool showBottomNav;
  final int bottomNavIndex;
  final bool hasUnreadNotifications;
  final String avatarInitials;

  final VoidCallback? onLogoTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;
  final ValueChanged<StatisticsPeriod>? onPeriodChanged;
  final VoidCallback? onViewOverviewDetails;
  final VoidCallback? onViewTrendDetails;
  final VoidCallback? onBreakdownTap;
  final VoidCallback? onCategoryDetailsTap;
  final VoidCallback? onInsightTap;
  final VoidCallback? onCreateGoalTap;
  final ValueChanged<int>? onNavTap;

  @override
  Widget build(BuildContext context) {
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
                    // A. Screen Title with Mountain & Sunrise Illustration
                    _buildTitleSection(context, data),

                    const SizedBox(height: ADaySpacing.md),

                    // B. Period Selector (Tuần | Tháng | Năm)
                    _buildPeriodSelector(context, data.selectedPeriod),

                    const SizedBox(height: ADaySpacing.md),

                    // C. Overview 5 Metric Cards
                    OverviewMetricsCard(
                      title: data.overviewTitle,
                      metrics: data.overviewMetrics,
                      onActionTap: onViewOverviewDetails,
                    ),

                    const SizedBox(height: ADaySpacing.md),

                    // D. Completion Trend Bar Chart
                    CompletionTrendChart(
                      dataPoints: data.trendPoints,
                      onActionTap: onViewTrendDetails,
                    ),

                    const SizedBox(height: ADaySpacing.md),

                    // E. Side-by-side: Status Breakdown & Category Performance
                    _buildDualCardsSection(context, data),

                    const SizedBox(height: ADaySpacing.md),

                    // F. Encouragement Banner Card
                    EncouragementBannerCard(
                      title: data.encouragementTitle,
                      message: data.encouragementMessage,
                      quote: data.encouragementQuote,
                      onTap: onInsightTap,
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
              onCreateGoalTap: onCreateGoalTap,
            )
          : null,
    );
  }

  /// Screen headline with scenic mountain/sunrise background illustration.
  Widget _buildTitleSection(BuildContext context, StatisticsViewData viewData) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Mountain sunrise illustration in top right
        Positioned(
          top: -15.0,
          right: -10.0,
          width: 140.0,
          height: 80.0,
          child: const MountainSunVisual(
            height: 80.0,
            showFlag: false,
            showSunRays: true,
            sunPosition: Offset(0.75, 0.35),
          ),
        ),

        // Text content
        Semantics(
          header: true,
          label: '${viewData.screenTitle}. ${viewData.screenSubtitle}',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                viewData.screenTitle,
                style: ADayTypography.headline.copyWith(
                  fontSize: 26.0,
                  fontWeight: FontWeight.w800,
                  color: ADayColors.brandNavy,
                ),
              ),
              const SizedBox(height: 3.0),
              Text(
                viewData.screenSubtitle,
                style: ADayTypography.subhead.copyWith(
                  fontSize: 14.0,
                  height: 1.4,
                  color: ADayColors.mutedInk,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Full-width pill-shaped period selector matching Image 2.
  Widget _buildPeriodSelector(
    BuildContext context,
    StatisticsPeriod currentPeriod,
  ) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF3FA),
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Row(
        children: StatisticsPeriod.values.map((period) {
          final isSelected = period == currentPeriod;
          return Expanded(
            child: Semantics(
              button: true,
              selected: isSelected,
              label: 'Xem theo ${period.label}',
              child: Material(
                color: isSelected ? ADayColors.actionBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(10.0),
                child: InkWell(
                  onTap: onPeriodChanged != null
                      ? () => onPeriodChanged!(period)
                      : null,
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                    height: 40.0,
                    alignment: Alignment.center,
                    child: Text(
                      period.label,
                      style: TextStyle(
                        fontFamily: ADayTypography.fontFamily,
                        fontSize: 14.0,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : ADayColors.brandNavy.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Side-by-side or stacked layout for Status Breakdown & Category Performance.
  Widget _buildDualCardsSection(
    BuildContext context,
    StatisticsViewData viewData,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StatusBreakdownCard(
                items: viewData.statusBreakdownItems,
                onActionTap: onBreakdownTap,
              ),
              const SizedBox(height: ADaySpacing.md),
              CategoryPerformanceCard(
                categories: viewData.categoryItems,
                onActionTap: onCategoryDetailsTap,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 50,
              child: StatusBreakdownCard(
                items: viewData.statusBreakdownItems,
                onActionTap: onBreakdownTap,
              ),
            ),
            const SizedBox(width: ADaySpacing.sm),
            Expanded(
              flex: 50,
              child: CategoryPerformanceCard(
                categories: viewData.categoryItems,
                onActionTap: onCategoryDetailsTap,
              ),
            ),
          ],
        );
      },
    );
  }
}
