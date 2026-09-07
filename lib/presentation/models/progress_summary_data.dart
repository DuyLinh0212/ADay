import 'package:flutter/foundation.dart';

/// Immutable presentation DTO for the signature daily progress hero card.
///
/// Ensures strict adherence to DESIGN.md:
/// - 0/0 tasks displays 0% safely without division-by-zero errors.
/// - Unifies the progress percentage and breakdown numbers.
@immutable
class ProgressSummaryData {
  const ProgressSummaryData({
    required this.date,
    required this.dateLabel,
    this.greeting = 'Xin chào, bạn!',
    this.greetingSubtext =
        'Hôm nay là một ngày tuyệt vời để tiến về phiên bản tốt hơn của bạn. 💙',
    this.quote = 'Kiên trì hôm nay, thành công ngày mai!',
    this.headerBannerQuote = '“Những kế hoạch nhỏ tạo nên ngày mai lớn hơn.”',
    this.completedCount = 0,
    this.totalCount = 0,
    this.remainingCount = 0,
    this.overdueCount = 0,
    this.postponedCount = 0,
  });

  final DateTime date;
  final String dateLabel;
  final String greeting;
  final String greetingSubtext;
  final String quote;
  final String headerBannerQuote;
  final int completedCount;
  final int totalCount;
  final int remainingCount;
  final int overdueCount;
  final int postponedCount;

  /// Completion rate as a double clamped between 0.0 and 1.0.
  /// 0 / 0 returns 0.0 per DESIGN.md specifications.
  double get completionRate {
    if (totalCount <= 0) return 0.0;
    return (completedCount / totalCount).clamp(0.0, 1.0);
  }

  /// Percentage integer between 0 and 100.
  int get percentageInt => (completionRate * 100).round();

  /// Formatted percentage string, e.g. "67%".
  String get percentLabel => '$percentageInt%';

  /// Summary phrase, e.g. "4 / 6 nhiệm vụ".
  String get completedSummaryText => '$completedCount / $totalCount nhiệm vụ';

  /// Accessible voice-over announcement label.
  String get accessibleSummary {
    return 'Hôm nay, $dateLabel. Tiến độ $percentLabel. $completedCount trên $totalCount nhiệm vụ đã hoàn thành. '
        '$completedCount đã xong, $remainingCount còn lại, $overdueCount quá hạn.';
  }

  /// Factory helper to build from raw counts.
  factory ProgressSummaryData.fromCounts({
    required DateTime date,
    required String dateLabel,
    String? greeting,
    String? greetingSubtext,
    String? quote,
    String? headerBannerQuote,
    required int completed,
    required int total,
    int? remaining,
    int overdue = 0,
    int postponed = 0,
  }) {
    final calcRemaining = remaining ?? (total - completed).clamp(0, total);
    return ProgressSummaryData(
      date: date,
      dateLabel: dateLabel,
      greeting: greeting ?? 'Xin chào, Minh!',
      greetingSubtext:
          greetingSubtext ??
          'Hôm nay là một ngày tuyệt vời để tiến về phiên bản tốt hơn của bạn. 💙',
      quote: quote ?? 'Kiên trì hôm nay, thành công ngày mai!',
      headerBannerQuote:
          headerBannerQuote ?? '“Những kế hoạch nhỏ tạo nên ngày mai lớn hơn.”',
      completedCount: completed,
      totalCount: total,
      remainingCount: calcRemaining,
      overdueCount: overdue,
      postponedCount: postponed,
    );
  }

  ProgressSummaryData copyWith({
    DateTime? date,
    String? dateLabel,
    String? greeting,
    String? greetingSubtext,
    String? quote,
    String? headerBannerQuote,
    int? completedCount,
    int? totalCount,
    int? remainingCount,
    int? overdueCount,
    int? postponedCount,
  }) {
    return ProgressSummaryData(
      date: date ?? this.date,
      dateLabel: dateLabel ?? this.dateLabel,
      greeting: greeting ?? this.greeting,
      greetingSubtext: greetingSubtext ?? this.greetingSubtext,
      quote: quote ?? this.quote,
      headerBannerQuote: headerBannerQuote ?? this.headerBannerQuote,
      completedCount: completedCount ?? this.completedCount,
      totalCount: totalCount ?? this.totalCount,
      remainingCount: remainingCount ?? this.remainingCount,
      overdueCount: overdueCount ?? this.overdueCount,
      postponedCount: postponedCount ?? this.postponedCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressSummaryData &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          dateLabel == other.dateLabel &&
          greeting == other.greeting &&
          greetingSubtext == other.greetingSubtext &&
          quote == other.quote &&
          headerBannerQuote == other.headerBannerQuote &&
          completedCount == other.completedCount &&
          totalCount == other.totalCount &&
          remainingCount == other.remainingCount &&
          overdueCount == other.overdueCount &&
          postponedCount == other.postponedCount;

  @override
  int get hashCode => Object.hash(
    date,
    dateLabel,
    greeting,
    greetingSubtext,
    quote,
    headerBannerQuote,
    completedCount,
    totalCount,
    remainingCount,
    overdueCount,
    postponedCount,
  );
}
