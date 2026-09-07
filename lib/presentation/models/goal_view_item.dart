import 'package:flutter/foundation.dart';

import '../../domain/models/goal.dart';

/// Presentation DTO for displaying long-term goals or summary cards.
@immutable
class GoalViewItem {
  const GoalViewItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.category = 'Mục tiêu',
    this.activeGoalsCount = 0,
    this.completedGoalsCount = 0,
    this.totalGoalsCount = 0,
    this.quote = 'Hành trình vạn dặm bắt đầu từ những bước nhỏ.',
    this.actionLabel = 'Xem mục tiêu',
    this.deadlineLabel,
    this.status = GoalStatus.active,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String category;
  final int activeGoalsCount;
  final int completedGoalsCount;
  final int totalGoalsCount;
  final String quote;
  final String actionLabel;
  final String? deadlineLabel;
  final GoalStatus status;

  bool get isActive => status == GoalStatus.active;
  bool get isCompleted => status == GoalStatus.completed;

  /// Builds a sample/default item matching the home screen mockup.
  factory GoalViewItem.sampleHome() {
    return const GoalViewItem(
      id: 'long_term_summary',
      title: 'Mục tiêu dài hạn',
      subtitle: '3 mục tiêu đang thực hiện',
      activeGoalsCount: 3,
      totalGoalsCount: 3,
      quote: 'Hành trình vạn dặm bắt đầu từ những bước nhỏ.',
      actionLabel: 'Xem mục tiêu',
    );
  }

  GoalViewItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? category,
    int? activeGoalsCount,
    int? completedGoalsCount,
    int? totalGoalsCount,
    String? quote,
    String? actionLabel,
    String? deadlineLabel,
    GoalStatus? status,
  }) {
    return GoalViewItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      activeGoalsCount: activeGoalsCount ?? this.activeGoalsCount,
      completedGoalsCount: completedGoalsCount ?? this.completedGoalsCount,
      totalGoalsCount: totalGoalsCount ?? this.totalGoalsCount,
      quote: quote ?? this.quote,
      actionLabel: actionLabel ?? this.actionLabel,
      deadlineLabel: deadlineLabel ?? this.deadlineLabel,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalViewItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          subtitle == other.subtitle &&
          category == other.category &&
          activeGoalsCount == other.activeGoalsCount &&
          completedGoalsCount == other.completedGoalsCount &&
          totalGoalsCount == other.totalGoalsCount &&
          quote == other.quote &&
          actionLabel == other.actionLabel &&
          deadlineLabel == other.deadlineLabel &&
          status == other.status;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    subtitle,
    category,
    activeGoalsCount,
    completedGoalsCount,
    totalGoalsCount,
    quote,
    actionLabel,
    deadlineLabel,
    status,
  );
}
