import 'package:flutter/material.dart';

import '../../core/theme/aday_colors.dart';
import '../../core/theme/aday_spacing.dart';
import '../../core/theme/aday_typography.dart';
import '../models/progress_summary_data.dart';
import 'progress_ring.dart';

/// The signature Hero Progress Card for ADay.
///
/// Implements the visual centerpiece from TrangChu.png:
/// - Morning sky-to-earth linear gradient
/// - Circular progress ring showing live percentage
/// - Clear ratio representation (e.g., 4 / 6 nhiệm vụ)
/// - Translucent breakdown pill for Completed, Remaining, and Overdue counts
/// - Fully accessible semantics announcement
/// - Dynamic text scaling resilience without layout clipping
class ProgressSummaryHero extends StatelessWidget {
  const ProgressSummaryHero({super.key, required this.data, this.onTap});

  final ProgressSummaryData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: data.accessibleSummary,
      child: Container(
        decoration: BoxDecoration(
          gradient: ADayColors.heroGradient,
          borderRadius: ADaySpacing.surfaceRadius,
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F168AF2),
              offset: Offset(0, 4),
              blurRadius: 12.0,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: ADaySpacing.surfaceRadius,
            splashColor: Colors.white.withValues(alpha: 0.12),
            highlightColor: Colors.white.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.all(ADaySpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- 1. Header: Date & Quote ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hôm nay',
                              style: ADayTypography.title.copyWith(
                                color: ADayColors.surface,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              data.dateLabel,
                              style: ADayTypography.subhead.copyWith(
                                color: ADayColors.surface.withValues(
                                  alpha: 0.85,
                                ),
                                fontSize: 13.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: ADaySpacing.sm),
                      Flexible(
                        child: Text(
                          data.quote,
                          textAlign: TextAlign.right,
                          style: ADayTypography.quote.copyWith(
                            color: ADayColors.surface.withValues(alpha: 0.88),
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: ADaySpacing.md + 2),

                  // --- 2. Progress Ring & Metrics Breakdown ---
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isCompact = constraints.maxWidth < 340;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Progress Ring
                          ProgressRing(
                            progress: data.completionRate,
                            size: isCompact ? 72.0 : 80.0,
                            strokeWidth: isCompact ? 7.5 : 8.5,
                            trackColor: Colors.white.withValues(alpha: 0.22),
                            progressColor: ADayColors.surface,
                          ),

                          const SizedBox(width: ADaySpacing.md),

                          // Text Label
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Đã hoàn thành',
                                  style: ADayTypography.subhead.copyWith(
                                    color: ADayColors.surface.withValues(
                                      alpha: 0.88,
                                    ),
                                    fontSize: 13.5,
                                  ),
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  data.completedSummaryText,
                                  style: ADayTypography.title.copyWith(
                                    color: ADayColors.surface,
                                    fontSize: isCompact ? 17.0 : 19.0,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: ADaySpacing.sm),

                          // Breakdown Pill Container
                          _buildBreakdownCapsule(isCompact),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownCapsule(bool isCompact) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10.0 : 12.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBreakdownItem(
            icon: Icons.check_circle_rounded,
            iconColor: const Color(0xFF20C99A),
            count: data.completedCount,
            label: 'Đã xong',
            isCompact: isCompact,
          ),
          const SizedBox(height: 5.0),
          _buildBreakdownItem(
            icon: Icons.radio_button_unchecked_rounded,
            iconColor: Colors.white.withValues(alpha: 0.85),
            count: data.remainingCount,
            label: 'Còn lại',
            isCompact: isCompact,
          ),
          const SizedBox(height: 5.0),
          _buildBreakdownItem(
            icon: Icons.calendar_today_rounded,
            iconColor: Colors.white.withValues(alpha: 0.85),
            count: data.overdueCount,
            label: 'Quá hạn',
            isCompact: isCompact,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem({
    required IconData icon,
    required Color iconColor,
    required int count,
    required String label,
    required bool isCompact,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 14.0, color: iconColor),
        const SizedBox(width: 5.0),
        Text(
          '$count',
          style: TextStyle(
            fontFamily: ADayTypography.fontFamily,
            fontSize: isCompact ? 11.5 : 12.5,
            fontWeight: FontWeight.w700,
            color: ADayColors.surface,
          ),
        ),
        const SizedBox(width: 3.5),
        Text(
          label,
          style: TextStyle(
            fontFamily: ADayTypography.fontFamily,
            fontSize: isCompact ? 11.0 : 12.0,
            fontWeight: FontWeight.w500,
            color: ADayColors.surface.withValues(alpha: 0.90),
          ),
        ),
      ],
    );
  }
}
