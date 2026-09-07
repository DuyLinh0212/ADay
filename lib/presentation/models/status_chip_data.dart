import 'package:flutter/material.dart';

/// Enum distinguishing the visual and semantic intent of chips in ADay.
enum StatusChipType {
  /// Displays a time range (e.g., "10:00 – 11:00") with a clock icon.
  time,

  /// Indicates an all-day task ("Cả ngày").
  allDay,

  /// Completed status indicator ("Đã xong") with checkmark.
  completed,

  /// Postponed status indicator ("Tạm hoãn") with clock/reschedule icon.
  postponed,

  /// Cancelled status indicator ("Đã hủy") with cross icon.
  cancelled,

  /// Overdue status indicator ("Quá hạn") with warning/calendar icon.
  overdue,

  /// Generic filter or category chip with toggle selection.
  filter,
}

/// Presentation DTO for status and time chips.
@immutable
class StatusChipData {
  const StatusChipData({
    required this.label,
    this.type = StatusChipType.time,
    this.icon,
    this.isSelected = false,
    this.count,
    this.semanticsLabel,
  });

  final String label;
  final StatusChipType type;
  final IconData? icon;
  final bool isSelected;
  final int? count;
  final String? semanticsLabel;

  /// Builds an all-day chip.
  factory StatusChipData.allDay([String label = 'Cả ngày']) {
    return StatusChipData(
      label: label,
      type: StatusChipType.allDay,
      semanticsLabel: 'Thời gian: Cả ngày',
    );
  }

  /// Builds a scheduled time range chip.
  factory StatusChipData.time(String range) {
    return StatusChipData(
      label: range,
      type: StatusChipType.time,
      icon: Icons.access_time_rounded,
      semanticsLabel: 'Thời gian: $range',
    );
  }

  /// Builds a completed status chip.
  factory StatusChipData.completed({int? count, String label = 'Đã xong'}) {
    return StatusChipData(
      label: count != null ? '$count $label' : label,
      type: StatusChipType.completed,
      icon: Icons.check_circle_rounded,
      count: count,
      semanticsLabel:
          'Trạng thái: $label${count != null ? ', số lượng $count' : ''}',
    );
  }

  /// Builds a postponed status chip.
  factory StatusChipData.postponed({int? count, String label = 'Tạm hoãn'}) {
    return StatusChipData(
      label: count != null ? '$count $label' : label,
      type: StatusChipType.postponed,
      icon: Icons.schedule_rounded,
      count: count,
      semanticsLabel:
          'Trạng thái: $label${count != null ? ', số lượng $count' : ''}',
    );
  }

  /// Builds a cancelled status chip.
  factory StatusChipData.cancelled({int? count, String label = 'Đã hủy'}) {
    return StatusChipData(
      label: count != null ? '$count $label' : label,
      type: StatusChipType.cancelled,
      icon: Icons.cancel_rounded,
      count: count,
      semanticsLabel:
          'Trạng thái: $label${count != null ? ', số lượng $count' : ''}',
    );
  }

  /// Builds an overdue status chip.
  factory StatusChipData.overdue({int? count, String label = 'Quá hạn'}) {
    return StatusChipData(
      label: count != null ? '$count $label' : label,
      type: StatusChipType.overdue,
      icon: Icons.event_busy_rounded,
      count: count,
      semanticsLabel:
          'Trạng thái: $label${count != null ? ', số lượng $count' : ''}',
    );
  }

  StatusChipData copyWith({
    String? label,
    StatusChipType? type,
    IconData? icon,
    bool? isSelected,
    int? count,
    String? semanticsLabel,
  }) {
    return StatusChipData(
      label: label ?? this.label,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      isSelected: isSelected ?? this.isSelected,
      count: count ?? this.count,
      semanticsLabel: semanticsLabel ?? this.semanticsLabel,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatusChipData &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          type == other.type &&
          icon == other.icon &&
          isSelected == other.isSelected &&
          count == other.count &&
          semanticsLabel == other.semanticsLabel;

  @override
  int get hashCode =>
      Object.hash(label, type, icon, isSelected, count, semanticsLabel);
}
