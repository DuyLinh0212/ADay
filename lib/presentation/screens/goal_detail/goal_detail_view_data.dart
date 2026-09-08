import 'package:flutter/material.dart';

/// Immutable presentation DTO for an individual task in the goal detail view.
@immutable
class GoalDetailTaskItem {
  const GoalDetailTaskItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.isCompleted = false,
    this.completedTimeLabel,
  });

  final String id;
  final String title;
  final String? subtitle;
  final bool isCompleted;
  final String? completedTimeLabel;

  GoalDetailTaskItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    bool? isCompleted,
    String? completedTimeLabel,
  }) {
    return GoalDetailTaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      isCompleted: isCompleted ?? this.isCompleted,
      completedTimeLabel: completedTimeLabel ?? this.completedTimeLabel,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalDetailTaskItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          subtitle == other.subtitle &&
          isCompleted == other.isCompleted &&
          completedTimeLabel == other.completedTimeLabel;

  @override
  int get hashCode =>
      Object.hash(id, title, subtitle, isCompleted, completedTimeLabel);
}

/// Immutable presentation DTO for the entire Goal Detail screen.
@immutable
class GoalDetailViewData {
  const GoalDetailViewData({
    required this.id,
    required this.title,
    required this.category,
    required this.quote,
    required this.completedTasks,
    required this.totalTasks,
    required this.encouragement,
    this.scheduleLabel = 'Mỗi ngày',
    this.reminderTimeLabel = '10:00',
    this.startDateLabel = '01/06/2025',
    this.dateLabel = 'Thứ Ba, 24 tháng 6, 2025',
    this.tasks = const [],
    this.note = '',
    this.bannerTitle = 'Kiến thức hôm nay, thành công ngày mai!',
    this.bannerSubtitle = 'Cố gắng thêm một chút nữa, bạn nhé! 💙',
    this.isPostponed = false,
    this.isCancelled = false,
    this.postponedUntilLabel,
    this.statusReason,
  });

  final String id;
  final String title;
  final String category;
  final String quote;
  final int completedTasks;
  final int totalTasks;
  final String encouragement;
  final String scheduleLabel;
  final String reminderTimeLabel;
  final String startDateLabel;
  final String dateLabel;
  final List<GoalDetailTaskItem> tasks;
  final String note;
  final String bannerTitle;
  final String bannerSubtitle;
  final bool isPostponed;
  final bool isCancelled;
  final String? postponedUntilLabel;
  final String? statusReason;

  /// Completion percentage ratio from 0.0 to 1.0.
  double get completionRate {
    if (totalTasks <= 0) return 0.0;
    return (completedTasks / totalTasks).clamp(0.0, 1.0);
  }

  /// Completion percentage integer (e.g. 67).
  int get completionPercent => (completionRate * 100).round();

  /// Creates a sample data instance strictly matching ChiTietMucTieu.png.
  factory GoalDetailViewData.sample() {
    return const GoalDetailViewData(
      id: 'sample_goal_read_books',
      title: 'Đọc sách 30 phút',
      category: 'Phát triển bản thân',
      quote:
          '“Mỗi trang sách là một bước tiến đến phiên bản tốt hơn của bạn.” 💙',
      completedTasks: 4,
      totalTasks: 6,
      encouragement:
          'Bạn đang đi rất đúng hướng! Hãy tiếp tục duy trì thói quen này nhé! 🌱',
      scheduleLabel: 'Mỗi ngày',
      reminderTimeLabel: '10:00',
      startDateLabel: '01/06/2025',
      dateLabel: 'Thứ Ba, 24 tháng 6, 2025',
      tasks: [
        GoalDetailTaskItem(
          id: 'task_1',
          title: 'Đọc sách 30 phút',
          subtitle: 'Hoàn thành lúc 09:45',
          isCompleted: true,
          completedTimeLabel: 'Hoàn thành lúc 09:45',
        ),
        GoalDetailTaskItem(
          id: 'task_2',
          title: 'Ghi lại 1 điều học được',
          subtitle: 'Tổng kết sau khi đọc',
          isCompleted: false,
        ),
        GoalDetailTaskItem(
          id: 'task_3',
          title: 'Áp dụng vào thực tế',
          subtitle: 'Chọn 1 ý để thực hành',
          isCompleted: false,
        ),
      ],
      note: '',
      bannerTitle: 'Kiến thức hôm nay, thành công ngày mai!',
      bannerSubtitle: 'Cố gắng thêm một chút nữa, bạn nhé! 💙',
    );
  }

  GoalDetailViewData copyWith({
    String? id,
    String? title,
    String? category,
    String? quote,
    int? completedTasks,
    int? totalTasks,
    String? encouragement,
    String? scheduleLabel,
    String? reminderTimeLabel,
    String? startDateLabel,
    String? dateLabel,
    List<GoalDetailTaskItem>? tasks,
    String? note,
    String? bannerTitle,
    String? bannerSubtitle,
    bool? isPostponed,
    bool? isCancelled,
    String? postponedUntilLabel,
    String? statusReason,
  }) {
    return GoalDetailViewData(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      quote: quote ?? this.quote,
      completedTasks: completedTasks ?? this.completedTasks,
      totalTasks: totalTasks ?? this.totalTasks,
      encouragement: encouragement ?? this.encouragement,
      scheduleLabel: scheduleLabel ?? this.scheduleLabel,
      reminderTimeLabel: reminderTimeLabel ?? this.reminderTimeLabel,
      startDateLabel: startDateLabel ?? this.startDateLabel,
      dateLabel: dateLabel ?? this.dateLabel,
      tasks: tasks ?? this.tasks,
      note: note ?? this.note,
      bannerTitle: bannerTitle ?? this.bannerTitle,
      bannerSubtitle: bannerSubtitle ?? this.bannerSubtitle,
      isPostponed: isPostponed ?? this.isPostponed,
      isCancelled: isCancelled ?? this.isCancelled,
      postponedUntilLabel: postponedUntilLabel ?? this.postponedUntilLabel,
      statusReason: statusReason ?? this.statusReason,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalDetailViewData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          category == other.category &&
          quote == other.quote &&
          completedTasks == other.completedTasks &&
          totalTasks == other.totalTasks &&
          encouragement == other.encouragement &&
          scheduleLabel == other.scheduleLabel &&
          reminderTimeLabel == other.reminderTimeLabel &&
          startDateLabel == other.startDateLabel &&
          dateLabel == other.dateLabel &&
          note == other.note &&
          bannerTitle == other.bannerTitle &&
          bannerSubtitle == other.bannerSubtitle &&
          isPostponed == other.isPostponed &&
          isCancelled == other.isCancelled &&
          postponedUntilLabel == other.postponedUntilLabel &&
          statusReason == other.statusReason &&
          _listEquals(tasks, other.tasks);

  @override
  int get hashCode => Object.hash(
    id,
    title,
    category,
    quote,
    completedTasks,
    totalTasks,
    encouragement,
    scheduleLabel,
    reminderTimeLabel,
    startDateLabel,
    dateLabel,
    note,
    bannerTitle,
    bannerSubtitle,
    isPostponed,
    isCancelled,
    postponedUntilLabel,
    statusReason,
    Object.hashAll(tasks),
  );

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
