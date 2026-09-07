import 'package:flutter/material.dart';

/// Available time periods for statistics aggregation.
enum StatisticsPeriod {
  week('Tuần'),
  month('Tháng'),
  year('Năm');

  const StatisticsPeriod(this.label);
  final String label;
}

/// Status of a calendar day in the month overview.
enum CalendarDayStatus {
  completed('Đã hoàn thành', Color(0xFF20C99A), Icons.check_circle_rounded),
  postponed('Đã dời lịch', Color(0xFFFFB52E), Icons.schedule_rounded),
  cancelled('Đã hủy', Color(0xFFF0525E), Icons.cancel_rounded),
  planned('Có kế hoạch', Color(0xFFB0C4DE), Icons.circle_outlined),
  none('Không có sự kiện', Colors.transparent, null);

  const CalendarDayStatus(this.label, this.indicatorColor, this.icon);
  final String label;
  final Color indicatorColor;
  final IconData? icon;
}

/// Presentation data for an individual day cell in the month calendar.
@immutable
class CalendarDayData {
  const CalendarDayData({
    required this.date,
    required this.dayNumber,
    this.isCurrentMonth = true,
    this.isToday = false,
    this.isSelected = false,
    this.status = CalendarDayStatus.none,
    this.completedTasks = 0,
    this.totalTasks = 0,
    this.semanticsLabel,
  });

  final DateTime date;
  final int dayNumber;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelected;
  final CalendarDayStatus status;
  final int completedTasks;
  final int totalTasks;
  final String? semanticsLabel;

  /// Builds an accessible description for assistive technologies.
  String get accessibleDescription {
    if (semanticsLabel != null) return semanticsLabel!;
    final todayPart = isToday ? ', hôm nay' : '';
    final monthPart = isCurrentMonth ? '' : ', tháng khác';
    final taskPart = totalTasks > 0
        ? ', $completedTasks trên $totalTasks nhiệm vụ'
        : '';
    final statusPart = status != CalendarDayStatus.none
        ? ', trạng thái: ${status.label}'
        : '';
    return 'Ngày $dayNumber$todayPart$monthPart$taskPart$statusPart';
  }

  CalendarDayData copyWith({
    DateTime? date,
    int? dayNumber,
    bool? isCurrentMonth,
    bool? isToday,
    bool? isSelected,
    CalendarDayStatus? status,
    int? completedTasks,
    int? totalTasks,
    String? semanticsLabel,
  }) {
    return CalendarDayData(
      date: date ?? this.date,
      dayNumber: dayNumber ?? this.dayNumber,
      isCurrentMonth: isCurrentMonth ?? this.isCurrentMonth,
      isToday: isToday ?? this.isToday,
      isSelected: isSelected ?? this.isSelected,
      status: status ?? this.status,
      completedTasks: completedTasks ?? this.completedTasks,
      totalTasks: totalTasks ?? this.totalTasks,
      semanticsLabel: semanticsLabel ?? this.semanticsLabel,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarDayData &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          dayNumber == other.dayNumber &&
          isCurrentMonth == other.isCurrentMonth &&
          isToday == other.isToday &&
          isSelected == other.isSelected &&
          status == other.status &&
          completedTasks == other.completedTasks &&
          totalTasks == other.totalTasks;

  @override
  int get hashCode => Object.hash(
    date,
    dayNumber,
    isCurrentMonth,
    isToday,
    isSelected,
    status,
    completedTasks,
    totalTasks,
  );
}

/// Presentation data for the entire month calendar card.
@immutable
class CalendarMonthData {
  const CalendarMonthData({
    required this.year,
    required this.month,
    required this.monthLabel,
    required this.days,
    this.todaySummaryLabel = '4 / 6 nhiệm vụ hôm nay',
    this.quote = '“Kỷ luật hôm nay là tự do ngày mai.”',
    this.todayCompletedCount = 4,
    this.todayTotalCount = 6,
  });

  final int year;
  final int month;
  final String monthLabel;
  final List<CalendarDayData> days;
  final String todaySummaryLabel;
  final String quote;
  final int todayCompletedCount;
  final int todayTotalCount;

  CalendarMonthData copyWith({
    int? year,
    int? month,
    String? monthLabel,
    List<CalendarDayData>? days,
    String? todaySummaryLabel,
    String? quote,
    int? todayCompletedCount,
    int? todayTotalCount,
  }) {
    return CalendarMonthData(
      year: year ?? this.year,
      month: month ?? this.month,
      monthLabel: monthLabel ?? this.monthLabel,
      days: days ?? this.days,
      todaySummaryLabel: todaySummaryLabel ?? this.todaySummaryLabel,
      quote: quote ?? this.quote,
      todayCompletedCount: todayCompletedCount ?? this.todayCompletedCount,
      todayTotalCount: todayTotalCount ?? this.todayTotalCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarMonthData &&
          runtimeType == other.runtimeType &&
          year == other.year &&
          month == other.month &&
          monthLabel == other.monthLabel &&
          days == other.days &&
          todaySummaryLabel == other.todaySummaryLabel &&
          quote == other.quote &&
          todayCompletedCount == other.todayCompletedCount &&
          todayTotalCount == other.todayTotalCount;

  @override
  int get hashCode => Object.hash(
    year,
    month,
    monthLabel,
    days,
    todaySummaryLabel,
    quote,
    todayCompletedCount,
    todayTotalCount,
  );
}

/// Metric card types matching Lich.png.
enum MetricType { completed, postponed, cancelled, streak }

/// Presentation data for an individual metric card.
@immutable
class StatisticMetricItem {
  const StatisticMetricItem({
    required this.type,
    required this.title,
    required this.value,
    this.trendText,
    this.isPositiveTrend = true,
    this.isNote = false,
  });

  final MetricType type;
  final String title;
  final String value;
  final String? trendText;
  final bool isPositiveTrend;
  final bool isNote;

  (Color bg, Color iconBg, Color iconFg, IconData icon) get visualStyle {
    switch (type) {
      case MetricType.completed:
        return (
          const Color(0xFFF0FAF6),
          const Color(0xFFD7F5EC),
          const Color(0xFF20C99A),
          Icons.check_rounded,
        );
      case MetricType.postponed:
        return (
          const Color(0xFFFFF9EE),
          const Color(0xFFFFECC4),
          const Color(0xFFFFB52E),
          Icons.schedule_rounded,
        );
      case MetricType.cancelled:
        return (
          const Color(0xFFFFF0F1),
          const Color(0xFFFFDDE0),
          const Color(0xFFF0525E),
          Icons.close_rounded,
        );
      case MetricType.streak:
        return (
          const Color(0xFFF0F7FD),
          const Color(0xFFD6EDFC),
          const Color(0xFF168AF2),
          Icons.local_fire_department_rounded,
        );
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatisticMetricItem &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          title == other.title &&
          value == other.value &&
          trendText == other.trendText &&
          isPositiveTrend == other.isPositiveTrend &&
          isNote == other.isNote;

  @override
  int get hashCode =>
      Object.hash(type, title, value, trendText, isPositiveTrend, isNote);
}

/// Presentation data for an individual column in the trend chart.
@immutable
class TrendDataPoint {
  const TrendDataPoint({
    required this.label,
    required this.percentage,
    this.valueLabel,
    this.isHighlighted = false,
  });

  /// Day or period label, e.g. "T2", "T3".
  final String label;

  /// Value as double between 0.0 and 1.0 (e.g. 0.67 for 67%).
  final double percentage;

  /// Optional tooltip or voice-over label, e.g. "67%".
  final String? valueLabel;

  /// Highlight state.
  final bool isHighlighted;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrendDataPoint &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          percentage == other.percentage &&
          valueLabel == other.valueLabel &&
          isHighlighted == other.isHighlighted;

  @override
  int get hashCode => Object.hash(label, percentage, valueLabel, isHighlighted);
}

/// An individual segment in the donut breakdown chart.
@immutable
class CompletionBreakdownItem {
  const CompletionBreakdownItem({
    required this.label,
    required this.percentage,
    required this.color,
  });

  final String label;
  final int percentage;
  final Color color;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletionBreakdownItem &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          percentage == other.percentage &&
          color == other.color;

  @override
  int get hashCode => Object.hash(label, percentage, color);
}

/// Presentation data for the encouraging insight card.
@immutable
class EncouragingInsightData {
  const EncouragingInsightData({
    required this.title,
    required this.message,
    this.icon = Icons.emoji_events_rounded,
    this.iconColor = const Color(0xFF20C99A),
    this.highlightText = '12%',
  });

  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final String highlightText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EncouragingInsightData &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          message == other.message &&
          icon == other.icon &&
          iconColor == other.iconColor &&
          highlightText == other.highlightText;

  @override
  int get hashCode =>
      Object.hash(title, message, icon, iconColor, highlightText);
}

/// Presentation data for category progress bar.
@immutable
class CategoryProgressItem {
  const CategoryProgressItem({
    required this.name,
    required this.percentage,
    required this.color,
    required this.icon,
    this.total = 0,
    this.completed = 0,
  });

  final String name;
  final int percentage;
  final Color color;
  final IconData icon;
  final int total;
  final int completed;
}

/// Presentation data for the 5 overview metric cards matching Image 2.
@immutable
class OverviewMetricItem {
  const OverviewMetricItem({
    required this.title,
    required this.value,
    required this.deltaText,
    required this.isPositiveDelta,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  final String title;
  final String value;
  final String deltaText;
  final bool isPositiveDelta;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
}

/// Master presentation model for StatisticsScreen.
@immutable
class StatisticsViewData {
  const StatisticsViewData({
    this.screenTitle = 'Thống kê',
    this.screenSubtitle = 'Nhìn lại hành trình để cải thiện mỗi ngày.',
    this.selectedPeriod = StatisticsPeriod.month,
    required this.calendar,
    required this.completionMetric,
    required this.postponedMetric,
    required this.cancelledMetric,
    required this.streakMetric,
    required this.trendPoints,
    required this.breakdownItems,
    required this.insight,
    this.trendSummaryActionLabel = 'Xem chi tiết',
    this.overviewTitle = 'Tổng quan tháng 6, 2025',
    this.overviewMetrics = const [],
    this.categoryItems = const [],
    this.statusBreakdownItems = const [],
    this.encouragementTitle = 'Bạn đang làm rất tốt!',
    this.encouragementMessage =
        'Tỉ lệ hoàn thành tăng 12% so với tháng trước. Hãy tiếp tục duy trì và chinh phục những mục tiêu tiếp theo nhé!',
    this.encouragementQuote =
        '“Tiến bộ mỗi ngày luôn tạo nên những điều tuyệt vời!”',
  });

  final String screenTitle;
  final String screenSubtitle;
  final StatisticsPeriod selectedPeriod;
  final CalendarMonthData calendar;
  final StatisticMetricItem completionMetric;
  final StatisticMetricItem postponedMetric;
  final StatisticMetricItem cancelledMetric;
  final StatisticMetricItem streakMetric;
  final List<TrendDataPoint> trendPoints;
  final List<CompletionBreakdownItem> breakdownItems;
  final EncouragingInsightData insight;
  final String trendSummaryActionLabel;

  final String overviewTitle;
  final List<OverviewMetricItem> overviewMetrics;
  final List<CategoryProgressItem> categoryItems;
  final List<CompletionBreakdownItem> statusBreakdownItems;
  final String encouragementTitle;
  final String encouragementMessage;
  final String encouragementQuote;

  /// Default sample data matching Lich.png exactly.
  factory StatisticsViewData.sample() {
    return StatisticsViewData(
      screenTitle: 'Lịch & Thống kê',
      screenSubtitle:
          'Theo dõi hành trình, kiến tạo phiên bản tốt hơn mỗi ngày.',
      selectedPeriod: StatisticsPeriod.month,
      calendar: _buildSampleMonth(),
      completionMetric: const StatisticMetricItem(
        type: MetricType.completed,
        title: 'Tỷ lệ\nhoàn thành',
        value: '67%',
        trendText: '↑ 12%',
        isPositiveTrend: true,
      ),
      postponedMetric: const StatisticMetricItem(
        type: MetricType.postponed,
        title: 'Đã dời lịch',
        value: '4',
        trendText: '↓ 33%',
        isPositiveTrend: true,
      ),
      cancelledMetric: const StatisticMetricItem(
        type: MetricType.cancelled,
        title: 'Đã hủy',
        value: '2',
        trendText: '↓ 50%',
        isPositiveTrend: true,
      ),
      streakMetric: const StatisticMetricItem(
        type: MetricType.streak,
        title: 'Ngày liên tiếp',
        value: '12',
        trendText: 'Giữ vững\nphong độ!',
        isNote: true,
      ),
      trendPoints: const [
        TrendDataPoint(label: 'T2', percentage: 0.62, valueLabel: '62%'),
        TrendDataPoint(label: 'T3', percentage: 0.78, valueLabel: '78%'),
        TrendDataPoint(label: 'T4', percentage: 0.65, valueLabel: '65%'),
        TrendDataPoint(label: 'T5', percentage: 0.80, valueLabel: '80%'),
        TrendDataPoint(label: 'T6', percentage: 0.72, valueLabel: '72%'),
        TrendDataPoint(label: 'T7', percentage: 0.68, valueLabel: '68%'),
        TrendDataPoint(label: 'CN', percentage: 0.81, valueLabel: '81%'),
      ],
      breakdownItems: const [
        CompletionBreakdownItem(
          label: 'Đã hoàn thành',
          percentage: 78,
          color: Color(0xFF20C99A),
        ),
        CompletionBreakdownItem(
          label: 'Còn lại',
          percentage: 12,
          color: Color(0xFF38B8F8),
        ),
        CompletionBreakdownItem(
          label: 'Tạm hoãn',
          percentage: 7,
          color: Color(0xFFFFB52E),
        ),
        CompletionBreakdownItem(
          label: 'Đã hủy',
          percentage: 3,
          color: Color(0xFFF0525E),
        ),
      ],
      statusBreakdownItems: const [
        CompletionBreakdownItem(
          label: 'Đã hoàn thành',
          percentage: 78,
          color: Color(0xFF20C99A),
        ),
        CompletionBreakdownItem(
          label: 'Còn lại',
          percentage: 12,
          color: Color(0xFF38B8F8),
        ),
        CompletionBreakdownItem(
          label: 'Tạm hoãn',
          percentage: 7,
          color: Color(0xFFFFB52E),
        ),
        CompletionBreakdownItem(
          label: 'Đã hủy',
          percentage: 3,
          color: Color(0xFFF0525E),
        ),
      ],
      categoryItems: const [
        CategoryProgressItem(
          name: 'Học tập',
          percentage: 85,
          color: Color(0xFF0EB8AC),
          icon: Icons.menu_book_rounded,
        ),
        CategoryProgressItem(
          name: 'Sức khỏe',
          percentage: 72,
          color: Color(0xFF168AF2),
          icon: Icons.fitness_center_rounded,
        ),
        CategoryProgressItem(
          name: 'Công việc',
          percentage: 68,
          color: Color(0xFF8E59FF),
          icon: Icons.business_center_rounded,
        ),
        CategoryProgressItem(
          name: 'Cá nhân',
          percentage: 75,
          color: Color(0xFFFFB52E),
          icon: Icons.person_rounded,
        ),
      ],
      overviewTitle: 'Tổng quan tháng 6, 2025',
      overviewMetrics: const [
        OverviewMetricItem(
          title: 'Tỉ lệ hoàn thành',
          value: '78%',
          deltaText: '↑ 12% so với tháng trước',
          isPositiveDelta: true,
          icon: Icons.check_circle_rounded,
          iconColor: Color(0xFF20C99A),
          iconBgColor: Color(0xFFE8F8F3),
        ),
        OverviewMetricItem(
          title: 'Đã hoàn thành',
          value: '26',
          deltaText: '↑ 8% so với tháng trước',
          isPositiveDelta: true,
          icon: Icons.description_rounded,
          iconColor: Color(0xFF168AF2),
          iconBgColor: Color(0xFFE7F3FE),
        ),
        OverviewMetricItem(
          title: 'Tạm hoãn',
          value: '5',
          deltaText: '↓ 29% so với tháng trước',
          isPositiveDelta: true,
          icon: Icons.schedule_rounded,
          iconColor: Color(0xFFFFB52E),
          iconBgColor: Color(0xFFFFF7E8),
        ),
        OverviewMetricItem(
          title: 'Đã hủy',
          value: '2',
          deltaText: '↓ 50% so với tháng trước',
          isPositiveDelta: true,
          icon: Icons.cancel_rounded,
          iconColor: Color(0xFFF0525E),
          iconBgColor: Color(0xFFFFECEE),
        ),
        OverviewMetricItem(
          title: 'Ngày liên tiếp',
          value: '14',
          deltaText: '↑ 3 ngày so với tháng trước',
          isPositiveDelta: true,
          icon: Icons.local_fire_department_rounded,
          iconColor: Color(0xFF8E59FF),
          iconBgColor: Color(0xFFF3EDFF),
        ),
      ],
      insight: const EncouragingInsightData(
        title: 'Bạn đang làm rất tốt!',
        message:
            'Tỉ lệ hoàn thành tăng 12% so với tháng trước. Hãy tiếp tục duy trì và chinh phục những mục tiêu tiếp theo nhé!',
        highlightText: '12%',
      ),
      encouragementTitle: 'Bạn đang làm rất tốt!',
      encouragementMessage:
          'Tỉ lệ hoàn thành tăng 12% so với tháng trước. Hãy tiếp tục duy trì và chinh phục những mục tiêu tiếp theo nhé!',
      encouragementQuote:
          '“Tiến bộ mỗi ngày luôn tạo nên những điều tuyệt vời!”',
    );
  }

  /// Helper generating the 42 cells of June 2025 as seen in Lich.png.
  static CalendarMonthData _buildSampleMonth() {
    final days = <CalendarDayData>[
      // Previous month (May 26-31)
      CalendarDayData(
        date: DateTime(2025, 5, 26),
        dayNumber: 26,
        isCurrentMonth: false,
      ),
      CalendarDayData(
        date: DateTime(2025, 5, 27),
        dayNumber: 27,
        isCurrentMonth: false,
      ),
      CalendarDayData(
        date: DateTime(2025, 5, 28),
        dayNumber: 28,
        isCurrentMonth: false,
      ),
      CalendarDayData(
        date: DateTime(2025, 5, 29),
        dayNumber: 29,
        isCurrentMonth: false,
      ),
      CalendarDayData(
        date: DateTime(2025, 5, 30),
        dayNumber: 30,
        isCurrentMonth: false,
      ),
      CalendarDayData(
        date: DateTime(2025, 5, 31),
        dayNumber: 31,
        isCurrentMonth: false,
      ),

      // June 1 to 30
      CalendarDayData(date: DateTime(2025, 6, 1), dayNumber: 1),
      CalendarDayData(
        date: DateTime(2025, 6, 2),
        dayNumber: 2,
        status: CalendarDayStatus.completed,
      ),
      CalendarDayData(
        date: DateTime(2025, 6, 3),
        dayNumber: 3,
        status: CalendarDayStatus.postponed,
      ),
      CalendarDayData(date: DateTime(2025, 6, 4), dayNumber: 4),
      CalendarDayData(date: DateTime(2025, 6, 5), dayNumber: 5),
      CalendarDayData(
        date: DateTime(2025, 6, 6),
        dayNumber: 6,
        status: CalendarDayStatus.postponed,
      ),
      CalendarDayData(
        date: DateTime(2025, 6, 7),
        dayNumber: 7,
        status: CalendarDayStatus.completed,
      ),
      CalendarDayData(date: DateTime(2025, 6, 8), dayNumber: 8),
      CalendarDayData(date: DateTime(2025, 6, 9), dayNumber: 9),
      CalendarDayData(
        date: DateTime(2025, 6, 10),
        dayNumber: 10,
        isToday: true,
        isSelected: true,
        completedTasks: 4,
        totalTasks: 6,
      ),
      CalendarDayData(date: DateTime(2025, 6, 11), dayNumber: 11),
      CalendarDayData(
        date: DateTime(2025, 6, 12),
        dayNumber: 12,
        status: CalendarDayStatus.completed,
      ),
      CalendarDayData(date: DateTime(2025, 6, 13), dayNumber: 13),
      CalendarDayData(
        date: DateTime(2025, 6, 14),
        dayNumber: 14,
        status: CalendarDayStatus.cancelled,
      ),
      CalendarDayData(date: DateTime(2025, 6, 15), dayNumber: 15),
      CalendarDayData(date: DateTime(2025, 6, 16), dayNumber: 16),
      CalendarDayData(date: DateTime(2025, 6, 17), dayNumber: 17),
      CalendarDayData(date: DateTime(2025, 6, 18), dayNumber: 18),
      CalendarDayData(date: DateTime(2025, 6, 19), dayNumber: 19),
      CalendarDayData(date: DateTime(2025, 6, 20), dayNumber: 20),
      CalendarDayData(date: DateTime(2025, 6, 21), dayNumber: 21),
      CalendarDayData(date: DateTime(2025, 6, 22), dayNumber: 22),
      CalendarDayData(date: DateTime(2025, 6, 23), dayNumber: 23),
      CalendarDayData(date: DateTime(2025, 6, 24), dayNumber: 24),
      CalendarDayData(date: DateTime(2025, 6, 25), dayNumber: 25),
      CalendarDayData(date: DateTime(2025, 6, 26), dayNumber: 26),
      CalendarDayData(date: DateTime(2025, 6, 27), dayNumber: 27),
      CalendarDayData(date: DateTime(2025, 6, 28), dayNumber: 28),
      CalendarDayData(date: DateTime(2025, 6, 29), dayNumber: 29),
      CalendarDayData(date: DateTime(2025, 6, 30), dayNumber: 30),

      // Next month (July 1-6)
      CalendarDayData(
        date: DateTime(2025, 7, 1),
        dayNumber: 1,
        isCurrentMonth: false,
      ),
      CalendarDayData(
        date: DateTime(2025, 7, 2),
        dayNumber: 2,
        isCurrentMonth: false,
      ),
      CalendarDayData(
        date: DateTime(2025, 7, 3),
        dayNumber: 3,
        isCurrentMonth: false,
      ),
      CalendarDayData(
        date: DateTime(2025, 7, 4),
        dayNumber: 4,
        isCurrentMonth: false,
      ),
      CalendarDayData(
        date: DateTime(2025, 7, 5),
        dayNumber: 5,
        isCurrentMonth: false,
      ),
      CalendarDayData(
        date: DateTime(2025, 7, 6),
        dayNumber: 6,
        isCurrentMonth: false,
      ),
    ];

    return CalendarMonthData(
      year: 2025,
      month: 6,
      monthLabel: 'Tháng 6, 2025',
      days: days,
      todaySummaryLabel: '4 / 6 nhiệm vụ hôm nay',
      quote: '“Kỷ luật hôm nay là tự do ngày mai.”',
      todayCompletedCount: 4,
      todayTotalCount: 6,
    );
  }
}
