class AppSettings {
  const AppSettings({
    this.displayName = 'Minh',
    this.dailyReviewEnabled = true,
    this.dailyReviewMinute = 21 * 60 + 45,
    this.notificationsAllowed = false,
  });

  final String displayName;
  final bool dailyReviewEnabled;
  final int dailyReviewMinute;
  final bool notificationsAllowed;

  AppSettings copyWith({
    String? displayName,
    bool? dailyReviewEnabled,
    int? dailyReviewMinute,
    bool? notificationsAllowed,
  }) {
    return AppSettings(
      displayName: displayName ?? this.displayName,
      dailyReviewEnabled: dailyReviewEnabled ?? this.dailyReviewEnabled,
      dailyReviewMinute: dailyReviewMinute ?? this.dailyReviewMinute,
      notificationsAllowed: notificationsAllowed ?? this.notificationsAllowed,
    );
  }

  Map<String, Object?> toJson() => {
    'displayName': displayName,
    'dailyReviewEnabled': dailyReviewEnabled,
    'dailyReviewMinute': dailyReviewMinute,
    'notificationsAllowed': notificationsAllowed,
  };

  factory AppSettings.fromJson(Map<String, Object?> json) {
    return AppSettings(
      displayName: json['displayName'] as String? ?? 'Minh',
      dailyReviewEnabled: json['dailyReviewEnabled'] as bool? ?? true,
      dailyReviewMinute: json['dailyReviewMinute'] as int? ?? 21 * 60 + 45,
      notificationsAllowed: json['notificationsAllowed'] as bool? ?? false,
    );
  }
}
