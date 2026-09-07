import 'package:flutter/material.dart';

import '../../core/theme/aday_colors.dart';
import '../../core/theme/aday_spacing.dart';
import '../../core/theme/aday_typography.dart';
import '../models/status_chip_data.dart';
import '../models/task_view_item.dart';
import 'status_time_chip.dart';

/// Reusable interactive task and goal row.
///
/// Features:
/// - Custom accessible checkbox with guaranteed min 44x44 touch target
/// - Category icon badge with soft tint background
/// - Resilient multi-line title supporting large dynamic fonts and Vietnamese diacritics
/// - Trailing status or time chip
/// - Subtle state transition motion (180ms)
class TaskGoalRow extends StatelessWidget {
  const TaskGoalRow({
    super.key,
    required this.item,
    this.onToggleCompleted,
    this.onTap,
    this.showDivider = true,
  });

  final TaskViewItem item;
  final ValueChanged<bool>? onToggleCompleted;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final isCompleted = item.isCompleted;
    final completionColor = Theme.of(context).colorScheme.primary;

    return Semantics(
      container: true,
      button: onTap != null,
      label:
          '${item.title}${item.subtitle != null ? ', ${item.subtitle}' : ''}'
          '${item.timeLabel != null ? ', ${item.timeLabel}' : ''}'
          ', ${isCompleted ? 'Đã hoàn thành' : 'Chưa hoàn thành'}',
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        opacity: isCompleted ? 0.52 : 1,
        child: InkWell(
          onTap: onTap,
          splashColor: ADayColors.coolSurface,
          highlightColor: ADayColors.coolSurface.withValues(alpha: 0.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ADaySpacing.md,
                  vertical: ADaySpacing.sm + 2,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 1. Accessible Checkbox (min 44x44 target)
                    Semantics(
                      checked: isCompleted,
                      label: isCompleted
                          ? 'Đánh dấu chưa hoàn thành'
                          : 'Đánh dấu hoàn thành',
                      button: true,
                      child: InkWell(
                        onTap: onToggleCompleted != null
                            ? () => onToggleCompleted!(!isCompleted)
                            : null,
                        borderRadius: ADaySpacing.smallRadius,
                        child: ConstrainedBox(
                          constraints: ADaySpacing.minTouchTargetConstraints,
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeInOut,
                              width: 24.0,
                              height: 24.0,
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? completionColor
                                    : Colors.transparent,
                                borderRadius: ADaySpacing.checkboxRadius,
                                border: Border.all(
                                  color: isCompleted
                                      ? completionColor
                                      : ADayColors.dividerMist,
                                  width: 1.8,
                                ),
                              ),
                              child: isCompleted
                                  ? Icon(
                                      Icons.check_rounded,
                                      size: 16.0,
                                      color: ADayColors.surface,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: ADaySpacing.xs),

                    // 2. Category Icon Badge
                    Container(
                      width: 36.0,
                      height: 36.0,
                      decoration: BoxDecoration(
                        color: item.iconBackgroundColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Center(
                        child: Icon(
                          item.icon,
                          color: item.iconColor,
                          size: 20.0,
                        ),
                      ),
                    ),

                    const SizedBox(width: ADaySpacing.md),

                    // 3. Title & Subtitle (Resilient text scaling)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.title,
                            style: ADayTypography.titleMedium.copyWith(
                              fontSize: 15.5,
                              color: isCompleted
                                  ? ADayColors.mutedInk
                                  : ADayColors.brandNavy,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              decorationColor: ADayColors.mutedInk,
                            ),
                          ),
                          if (item.subtitle != null &&
                              item.subtitle!.isNotEmpty) ...[
                            const SizedBox(height: 2.0),
                            Text(
                              item.subtitle!,
                              style: ADayTypography.subhead.copyWith(
                                fontSize: 13.0,
                                color: ADayColors.mutedInk,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: ADaySpacing.sm),

                    // 4. Trailing Status / Time Chip
                    if (item.timeLabel != null)
                      StatusTimeChip(
                        label: item.timeLabel!,
                        type: item.isAllDay
                            ? StatusChipType.allDay
                            : StatusChipType.time,
                      ),
                  ],
                ),
              ),
              if (showDivider)
                Divider(
                  indent: ADaySpacing.md,
                  endIndent: ADaySpacing.md,
                  height: 1.0,
                  color: ADayColors.dividerMist,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
