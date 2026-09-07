import 'package:flutter/material.dart';

import '../../core/theme/aday_colors.dart';
import '../../core/theme/aday_spacing.dart';
import '../../core/theme/aday_typography.dart';
import '../models/status_chip_data.dart';

/// Reusable status and time pill chip.
///
/// Adheres strictly to DESIGN.md:
/// - Shape: Pill (radius 999px)
/// - The More-Than-Color Rule: Every state is accompanied by an icon or distinct text.
/// - Minimum 44x44 interactive touch target when clickable.
/// - Neutral background for unselected/neutral states.
class StatusTimeChip extends StatelessWidget {
  const StatusTimeChip({
    super.key,
    required this.label,
    this.type = StatusChipType.time,
    this.icon,
    this.isSelected = false,
    this.onTap,
    this.semanticsLabel,
  });

  /// Factory constructor to render directly from a [StatusChipData] model.
  factory StatusTimeChip.fromData(
    StatusChipData data, {
    Key? key,
    VoidCallback? onTap,
  }) {
    return StatusTimeChip(
      key: key,
      label: data.label,
      type: data.type,
      icon: data.icon,
      isSelected: data.isSelected,
      onTap: onTap,
      semanticsLabel: data.semanticsLabel,
    );
  }

  /// Preset for all-day task chip.
  const factory StatusTimeChip.allDay({
    Key? key,
    String label,
    VoidCallback? onTap,
  }) = _AllDayStatusChip;

  /// Preset for time range chip.
  const factory StatusTimeChip.time({
    Key? key,
    required String timeRange,
    VoidCallback? onTap,
  }) = _TimeRangeStatusChip;

  /// Preset for completed task chip.
  const factory StatusTimeChip.completed({
    Key? key,
    String label,
    int? count,
    VoidCallback? onTap,
  }) = _CompletedStatusChip;

  final String label;
  final StatusChipType type;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  (Color bg, Color fg, IconData? defaultIcon) _resolveStyle() {
    switch (type) {
      case StatusChipType.allDay:
        return (
          ADayColors.coolSurface,
          ADayColors.brandNavy.withValues(alpha: 0.85),
          null,
        );
      case StatusChipType.time:
        return (
          ADayColors.coolSurface,
          ADayColors.brandNavy,
          Icons.access_time_rounded,
        );
      case StatusChipType.completed:
        return (
          ADayColors.progressTealTint,
          ADayColors.progressTeal,
          Icons.check_circle_rounded,
        );
      case StatusChipType.postponed:
        return (
          ADayColors.sunriseGoldTint,
          const Color(0xFFC7810A),
          Icons.schedule_rounded,
        );
      case StatusChipType.cancelled:
        return (
          ADayColors.cancelCoralTint,
          ADayColors.cancelCoral,
          Icons.cancel_rounded,
        );
      case StatusChipType.overdue:
        return (
          ADayColors.cancelCoralTint,
          ADayColors.cancelCoral,
          Icons.event_busy_rounded,
        );
      case StatusChipType.filter:
        return (
          isSelected ? ADayColors.actionBlueTint : ADayColors.coolSurface,
          isSelected ? ADayColors.actionBlue : ADayColors.brandNavy,
          null,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _resolveStyle();
    final effectiveIcon = icon ?? style.$3;

    Widget chipContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.5),
      decoration: BoxDecoration(
        color: style.$1,
        borderRadius: ADaySpacing.pillRadius,
        border: Border.all(
          color: isSelected
              ? ADayColors.actionBlue.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (effectiveIcon != null) ...[
            Icon(effectiveIcon, size: 14.0, color: style.$2),
            const SizedBox(width: 4.0),
          ],
          Flexible(
            child: Text(
              label,
              style: ADayTypography.caption.copyWith(
                fontSize: 12.0,
                color: style.$2,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      chipContent = ConstrainedBox(
        constraints: ADaySpacing.minTouchTargetConstraints,
        child: Center(
          child: InkWell(
            onTap: onTap,
            borderRadius: ADaySpacing.pillRadius,
            child: chipContent,
          ),
        ),
      );
    }

    return Semantics(
      label: semanticsLabel ?? label,
      button: onTap != null,
      selected: isSelected,
      child: chipContent,
    );
  }
}

class _AllDayStatusChip extends StatusTimeChip {
  const _AllDayStatusChip({super.key, super.label = 'Cả ngày', super.onTap})
    : super(type: StatusChipType.allDay);
}

class _TimeRangeStatusChip extends StatusTimeChip {
  const _TimeRangeStatusChip({
    super.key,
    required String timeRange,
    super.onTap,
  }) : super(label: timeRange, type: StatusChipType.time);
}

class _CompletedStatusChip extends StatusTimeChip {
  const _CompletedStatusChip({
    super.key,
    String label = 'Đã xong',
    int? count,
    super.onTap,
  }) : super(
         label: count != null ? '$count $label' : label,
         type: StatusChipType.completed,
       );
}
