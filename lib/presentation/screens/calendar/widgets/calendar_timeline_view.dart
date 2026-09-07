import 'package:flutter/material.dart';

import '../../../../core/theme/aday_colors.dart';
import '../../../../core/theme/aday_spacing.dart';
import '../../../../core/theme/aday_typography.dart';
import '../../../models/task_view_item.dart';

/// A day-first schedule view. It intentionally shows an actual sequence of
/// time rather than compressing scheduled work into an undifferentiated list.
class CalendarTimelineView extends StatelessWidget {
  const CalendarTimelineView({
    super.key,
    required this.day,
    required this.tasks,
    this.onToggleTask,
    this.onTaskTap,
  });

  final DateTime day;
  final List<TaskViewItem> tasks;
  final void Function(TaskViewItem task, bool completed)? onToggleTask;
  final ValueChanged<TaskViewItem>? onTaskTap;

  @override
  Widget build(BuildContext context) {
    final allDay = tasks.where((task) => task.isAllDay).toList();
    final timed = tasks.where((task) => !task.isAllDay).toList()
      ..sort((a, b) => _startMinute(a).compareTo(_startMinute(b)));
    final dateLabel = '${day.day} tháng ${day.month}';

    return Container(
      padding: const EdgeInsets.all(ADaySpacing.md),
      decoration: BoxDecoration(
        color: ADayColors.surface,
        borderRadius: ADaySpacing.surfaceRadius,
        border: Border.all(color: ADayColors.dividerMist),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dòng thời gian', style: ADayTypography.title),
                    Text(
                      '$dateLabel · ${tasks.length} nhiệm vụ',
                      style: ADayTypography.caption.copyWith(
                        color: ADayColors.mutedInk,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: ADaySpacing.md),
          if (tasks.isEmpty)
            const _TimelineEmptyState()
          else ...[
            if (allDay.isNotEmpty) ...[
              const _TimelineSectionLabel(
                icon: Icons.wb_sunny_outlined,
                label: 'Cả ngày',
              ),
              const SizedBox(height: 8),
              ...allDay.map(
                (task) => _AllDayTaskChip(
                  task: task,
                  onTap: onTaskTap == null ? null : () => onTaskTap!(task),
                  onToggle: onToggleTask == null
                      ? null
                      : (value) => onToggleTask!(task, value),
                ),
              ),
              if (timed.isNotEmpty) const SizedBox(height: ADaySpacing.md),
            ],
            if (timed.isNotEmpty) ...[
              const _TimelineSectionLabel(
                icon: Icons.timelapse_rounded,
                label: 'Theo giờ',
              ),
              const SizedBox(height: 6),
              ...timed.map(
                (task) => _TimedTaskRow(
                  task: task,
                  onTap: onTaskTap == null ? null : () => onTaskTap!(task),
                  onToggle: onToggleTask == null
                      ? null
                      : (value) => onToggleTask!(task, value),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  static int _startMinute(TaskViewItem task) {
    final firstPart = task.timeLabel?.split(RegExp(r'\s|–|-')).first ?? '';
    final parts = firstPart.split(':');
    if (parts.length != 2) return 24 * 60;
    return (int.tryParse(parts[0]) ?? 24) * 60 + (int.tryParse(parts[1]) ?? 0);
  }
}

class _TimelineSectionLabel extends StatelessWidget {
  const _TimelineSectionLabel({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 16, color: ADayColors.mutedInk),
      const SizedBox(width: 6),
      Text(
        label.toUpperCase(),
        style: ADayTypography.caption.copyWith(
          color: ADayColors.mutedInk,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.7,
        ),
      ),
    ],
  );
}

class _AllDayTaskChip extends StatelessWidget {
  const _AllDayTaskChip({this.onTap, this.onToggle, required this.task});
  final TaskViewItem task;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggle;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Material(
      color: task.iconBackgroundColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: Row(
            children: [
              Checkbox(
                value: task.isCompleted,
                onChanged: onToggle == null
                    ? null
                    : (value) => onToggle!(value ?? false),
                activeColor: Theme.of(context).colorScheme.primary,
                visualDensity: VisualDensity.compact,
              ),
              Icon(task.icon, size: 18, color: task.iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.title,
                  style: ADayTypography.body.copyWith(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    color: task.isCompleted
                        ? ADayColors.mutedInk
                        : ADayColors.brandNavy,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _TimedTaskRow extends StatelessWidget {
  const _TimedTaskRow({this.onTap, this.onToggle, required this.task});
  final TaskViewItem task;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggle;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 58,
          child: Padding(
            padding: const EdgeInsets.only(top: 13),
            child: Text(
              task.timeLabel?.split('–').first.trim() ?? '--:--',
              style: ADayTypography.caption.copyWith(
                color: ADayColors.brandNavy,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 22,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: 13,
                bottom: 0,
                child: Container(width: 2, color: ADayColors.dividerMist),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: task.isCompleted
                      ? Theme.of(context).colorScheme.primary
                      : task.iconColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: ADayColors.surface, width: 2),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: task.iconBackgroundColor,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
                  child: Row(
                    children: [
                      Checkbox(
                        value: task.isCompleted,
                        onChanged: onToggle == null
                            ? null
                            : (value) => onToggle!(value ?? false),
                        activeColor: Theme.of(context).colorScheme.primary,
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              task.title,
                              style: ADayTypography.body.copyWith(
                                fontWeight: FontWeight.w700,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            if (task.timeLabel != null)
                              Text(
                                task.timeLabel!,
                                style: ADayTypography.caption.copyWith(
                                  color: ADayColors.mutedInk,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _TimelineEmptyState extends StatelessWidget {
  const _TimelineEmptyState();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: ADaySpacing.lg),
    child: Column(
      children: [
        Icon(
          Icons.more_time_rounded,
          size: 40,
          color: ADayColors.mutedInk.withValues(alpha: .5),
        ),
        const SizedBox(height: 8),
        Text(
          'Ngày này chưa có nhiệm vụ theo mốc thời gian.',
          textAlign: TextAlign.center,
          style: ADayTypography.body.copyWith(color: ADayColors.mutedInk),
        ),
      ],
    ),
  );
}
