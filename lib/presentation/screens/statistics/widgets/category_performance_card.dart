import 'package:flutter/material.dart';

import '../../../../core/theme/aday_colors.dart';
import '../../../../core/theme/aday_spacing.dart';
import '../../../../core/theme/aday_typography.dart';
import '../statistics_view_data.dart';

/// Card displaying progress by category matching Image 2 ("Hiệu quả theo danh mục").
class CategoryPerformanceCard extends StatelessWidget {
  const CategoryPerformanceCard({
    super.key,
    required this.categories,
    this.title = 'Hiệu quả theo danh mục',
    this.actionLabel = 'Xem chi tiết',
    this.onActionTap,
  });

  final List<CategoryProgressItem> categories;
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
                  Icon(
                    Icons.layers_rounded,
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
                          style: TextStyle(
                            fontFamily: ADayTypography.fontFamily,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: ADayColors.actionBlue,
                          ),
                        ),
                        const SizedBox(width: 2.0),
                        Icon(
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

          // Category rows
          Column(
            mainAxisSize: MainAxisSize.min,
            children: categories.map((cat) {
              final ratio = (cat.percentage / 100.0).clamp(0.0, 1.0);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.5),
                child: Row(
                  children: [
                    // Category icon
                    Icon(cat.icon, size: 18.0, color: cat.color),
                    const SizedBox(width: 6.0),

                    // Name
                    SizedBox(
                      width: 58.0,
                      child: Text(
                        cat.name,
                        style: TextStyle(
                          fontFamily: ADayTypography.fontFamily,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: ADayColors.brandNavy,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(width: 6.0),

                    // Progress Track & Bar
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Container(
                            height: 7.0,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FB),
                              borderRadius: BorderRadius.circular(3.5),
                            ),
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: ratio,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: cat.color,
                                  borderRadius: BorderRadius.circular(3.5),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 8.0),

                    // Percentage
                    SizedBox(
                      width: 32.0,
                      child: Text(
                        '${cat.percentage}%',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: ADayTypography.fontFamily,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                          color: ADayColors.brandNavy,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
