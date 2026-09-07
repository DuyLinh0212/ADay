import 'package:flutter/material.dart';

/// Available actions for an unresolved task from today.
enum UnresolvedTaskAction {
  carryForward('Chuyển sang ngày mai'),
  markCompleted('Đánh dấu đã hoàn thành');

  const UnresolvedTaskAction(this.label);
  final String label;
}

/// Immutable presentation DTO for an unresolved task from today.
@immutable
class UnresolvedTaskItem {
  const UnresolvedTaskItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.category,
    this.icon = Icons.menu_book_rounded,
    this.iconColor = const Color(0xFF168AF2),
    this.iconBackgroundColor = const Color(0xFFE8F3FD),
    this.selectedAction = UnresolvedTaskAction.carryForward,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? category;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final UnresolvedTaskAction selectedAction;

  UnresolvedTaskItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? category,
    IconData? icon,
    Color? iconColor,
    Color? iconBackgroundColor,
    UnresolvedTaskAction? selectedAction,
  }) {
    return UnresolvedTaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      iconBackgroundColor: iconBackgroundColor ?? this.iconBackgroundColor,
      selectedAction: selectedAction ?? this.selectedAction,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnresolvedTaskItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          subtitle == other.subtitle &&
          category == other.category &&
          icon == other.icon &&
          iconColor == other.iconColor &&
          iconBackgroundColor == other.iconBackgroundColor &&
          selectedAction == other.selectedAction;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    subtitle,
    category,
    icon,
    iconColor,
    iconBackgroundColor,
    selectedAction,
  );
}

/// Immutable presentation DTO for a task planned for tomorrow.
@immutable
class TomorrowTaskItem {
  const TomorrowTaskItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.category,
    this.icon = Icons.menu_book_rounded,
    this.iconColor = const Color(0xFF168AF2),
    this.iconBackgroundColor = const Color(0xFFE8F3FD),
    this.timeLabel,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? category;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String? timeLabel;
  final bool isCompleted;

  TomorrowTaskItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? category,
    IconData? icon,
    Color? iconColor,
    Color? iconBackgroundColor,
    String? timeLabel,
    bool? isCompleted,
  }) {
    return TomorrowTaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      iconBackgroundColor: iconBackgroundColor ?? this.iconBackgroundColor,
      timeLabel: timeLabel ?? this.timeLabel,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TomorrowTaskItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          subtitle == other.subtitle &&
          category == other.category &&
          icon == other.icon &&
          iconColor == other.iconColor &&
          iconBackgroundColor == other.iconBackgroundColor &&
          timeLabel == other.timeLabel &&
          isCompleted == other.isCompleted;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    subtitle,
    category,
    icon,
    iconColor,
    iconBackgroundColor,
    timeLabel,
    isCompleted,
  );
}

/// Immutable presentation DTO for the Tomorrow Plan screen.
@immutable
class TomorrowPlanViewData {
  const TomorrowPlanViewData({
    this.reminderTimeLabel = '22:00',
    this.greetingHeadline = 'Đã đến lúc chuẩn bị cho ngày mai nhé!',
    this.greetingSubtitle =
        'Một vài phút hôm nay sẽ giúp bạn có một ngày mai nhẹ nhàng và hiệu quả hơn. 💙',
    this.dateLabel = 'Thứ Ba, 24 tháng 6, 2025',
    this.completedCount = 4,
    this.totalCount = 6,
    this.remainingCount = 2,
    this.overdueCount = 0,
    this.praiseTitle = 'Bạn đã nỗ lực rất tốt hôm nay!',
    this.praiseSubtitle =
        'Hãy dành chút thời gian để sắp xếp ngày mai thật suôn sẻ. Sự chủ động hôm nay tạo nên ngày mai tốt hơn.',
    this.unresolvedTasks = const [],
    this.tomorrowTasks = const [],
    this.quoteTitle =
        '“Kế hoạch tốt hôm nay là bước đầu của những thành công ngày mai.”',
    this.quoteSubtitle = 'Cùng nhau, mỗi ngày tốt hơn! 💙',
  });

  final String reminderTimeLabel;
  final String greetingHeadline;
  final String greetingSubtitle;
  final String dateLabel;
  final int completedCount;
  final int totalCount;
  final int remainingCount;
  final int overdueCount;
  final String praiseTitle;
  final String praiseSubtitle;
  final List<UnresolvedTaskItem> unresolvedTasks;
  final List<TomorrowTaskItem> tomorrowTasks;
  final String quoteTitle;
  final String quoteSubtitle;

  /// Completion rate from 0.0 to 1.0.
  double get completionRate {
    if (totalCount <= 0) return 0.0;
    return (completedCount / totalCount).clamp(0.0, 1.0);
  }

  /// Completion percentage integer (e.g. 67).
  int get completionPercent => (completionRate * 100).round();

  /// Creates a sample data instance strictly matching LapKeHoachNgayMai.png.
  factory TomorrowPlanViewData.sample() {
    return const TomorrowPlanViewData(
      reminderTimeLabel: '22:00',
      greetingHeadline: 'Đã đến lúc chuẩn bị cho ngày mai nhé!',
      greetingSubtitle:
          'Một vài phút hôm nay sẽ giúp bạn có một ngày mai nhẹ nhàng và hiệu quả hơn. 💙',
      dateLabel: 'Thứ Ba, 24 tháng 6, 2025',
      completedCount: 4,
      totalCount: 6,
      remainingCount: 2,
      overdueCount: 0,
      praiseTitle: 'Bạn đã nỗ lực rất tốt hôm nay!',
      praiseSubtitle:
          'Hãy dành chút thời gian để sắp xếp ngày mai thật suôn sẻ. Sự chủ động hôm nay tạo nên ngày mai tốt hơn.',
      unresolvedTasks: [
        UnresolvedTaskItem(
          id: 'unres_1',
          title: 'Tập thể dục',
          subtitle: 'Sức khỏe là nền tảng',
          category: 'Sức khỏe',
          icon: Icons.fitness_center_rounded,
          iconColor: Color(0xFF0EB8AC),
          iconBackgroundColor: Color(0xFFE6F8F7),
          selectedAction: UnresolvedTaskAction.carryForward,
        ),
        UnresolvedTaskItem(
          id: 'unres_2',
          title: 'Học Flutter 1 giờ',
          subtitle: 'Nâng cao kỹ năng',
          category: 'Học tập',
          icon: Icons.code_rounded,
          iconColor: Color(0xFF168AF2),
          iconBackgroundColor: Color(0xFFE8F3FD),
          selectedAction: UnresolvedTaskAction.carryForward,
        ),
      ],
      tomorrowTasks: [
        TomorrowTaskItem(
          id: 'tom_1',
          title: 'Đọc sách 30 phút',
          subtitle: 'Phát triển bản thân',
          category: 'Học tập',
          icon: Icons.menu_book_rounded,
          iconColor: Color(0xFF168AF2),
          iconBackgroundColor: Color(0xFFE8F3FD),
          timeLabel: '07:00 - 07:30',
        ),
        TomorrowTaskItem(
          id: 'tom_2',
          title: 'Tập thể dục',
          subtitle: 'Sức khỏe là nền tảng',
          category: 'Sức khỏe',
          icon: Icons.fitness_center_rounded,
          iconColor: Color(0xFF0EB8AC),
          iconBackgroundColor: Color(0xFFE6F8F7),
          timeLabel: '06:30 - 07:00',
        ),
        TomorrowTaskItem(
          id: 'tom_3',
          title: 'Họp nhóm dự án',
          subtitle: 'Trao đổi tiến độ',
          category: 'Công việc',
          icon: Icons.people_alt_rounded,
          iconColor: Color(0xFF7A5AF8),
          iconBackgroundColor: Color(0xFFF4F0FD),
          timeLabel: '10:00 - 11:00',
        ),
      ],
      quoteTitle:
          '“Kế hoạch tốt hôm nay là bước đầu của những thành công ngày mai.”',
      quoteSubtitle: 'Cùng nhau, mỗi ngày tốt hơn! 💙',
    );
  }

  TomorrowPlanViewData copyWith({
    String? reminderTimeLabel,
    String? greetingHeadline,
    String? greetingSubtitle,
    String? dateLabel,
    int? completedCount,
    int? totalCount,
    int? remainingCount,
    int? overdueCount,
    String? praiseTitle,
    String? praiseSubtitle,
    List<UnresolvedTaskItem>? unresolvedTasks,
    List<TomorrowTaskItem>? tomorrowTasks,
    String? quoteTitle,
    String? quoteSubtitle,
  }) {
    return TomorrowPlanViewData(
      reminderTimeLabel: reminderTimeLabel ?? this.reminderTimeLabel,
      greetingHeadline: greetingHeadline ?? this.greetingHeadline,
      greetingSubtitle: greetingSubtitle ?? this.greetingSubtitle,
      dateLabel: dateLabel ?? this.dateLabel,
      completedCount: completedCount ?? this.completedCount,
      totalCount: totalCount ?? this.totalCount,
      remainingCount: remainingCount ?? this.remainingCount,
      overdueCount: overdueCount ?? this.overdueCount,
      praiseTitle: praiseTitle ?? this.praiseTitle,
      praiseSubtitle: praiseSubtitle ?? this.praiseSubtitle,
      unresolvedTasks: unresolvedTasks ?? this.unresolvedTasks,
      tomorrowTasks: tomorrowTasks ?? this.tomorrowTasks,
      quoteTitle: quoteTitle ?? this.quoteTitle,
      quoteSubtitle: quoteSubtitle ?? this.quoteSubtitle,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TomorrowPlanViewData &&
          runtimeType == other.runtimeType &&
          reminderTimeLabel == other.reminderTimeLabel &&
          greetingHeadline == other.greetingHeadline &&
          greetingSubtitle == other.greetingSubtitle &&
          dateLabel == other.dateLabel &&
          completedCount == other.completedCount &&
          totalCount == other.totalCount &&
          remainingCount == other.remainingCount &&
          overdueCount == other.overdueCount &&
          praiseTitle == other.praiseTitle &&
          praiseSubtitle == other.praiseSubtitle &&
          quoteTitle == other.quoteTitle &&
          quoteSubtitle == other.quoteSubtitle &&
          _listEquals(unresolvedTasks, other.unresolvedTasks) &&
          _listEquals(tomorrowTasks, other.tomorrowTasks);

  @override
  int get hashCode => Object.hash(
    reminderTimeLabel,
    greetingHeadline,
    greetingSubtitle,
    dateLabel,
    completedCount,
    totalCount,
    remainingCount,
    overdueCount,
    praiseTitle,
    praiseSubtitle,
    quoteTitle,
    quoteSubtitle,
    Object.hashAll(unresolvedTasks),
    Object.hashAll(tomorrowTasks),
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
