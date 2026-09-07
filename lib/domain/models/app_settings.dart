class AppSettings {
  const AppSettings({
    this.displayName = 'Minh',
    this.dailyReviewEnabled = true,
    this.dailyReviewMinute = 21 * 60 + 45,
    this.notificationsAllowed = false,
    this.themeId = 'default',
    this.dailyQuotes = const [],
    this.driveAccountEmail,
    this.driveLastBackupAt,
    this.avatarPath,
  });

  final String displayName;
  final bool dailyReviewEnabled;
  final int dailyReviewMinute;
  final bool notificationsAllowed;

  /// `default` keeps ADay's original sunrise-blue appearance. The other
  /// values identify the five selectable visual templates.
  final String themeId;

  /// Personal encouragements shown one-at-a-time when the app opens.
  final List<String> dailyQuotes;

  /// Google account that explicitly granted ADay access to its private Drive
  /// application-data area. Never infer this from a display email.
  final String? driveAccountEmail;
  final DateTime? driveLastBackupAt;
  final String? avatarPath;

  AppSettings copyWith({
    String? displayName,
    bool? dailyReviewEnabled,
    int? dailyReviewMinute,
    bool? notificationsAllowed,
    String? themeId,
    List<String>? dailyQuotes,
    String? driveAccountEmail,
    DateTime? driveLastBackupAt,
    bool clearDriveAccountEmail = false,
    bool clearDriveLastBackupAt = false,
    String? avatarPath,
    bool clearAvatarPath = false,
  }) {
    return AppSettings(
      displayName: displayName ?? this.displayName,
      dailyReviewEnabled: dailyReviewEnabled ?? this.dailyReviewEnabled,
      dailyReviewMinute: dailyReviewMinute ?? this.dailyReviewMinute,
      notificationsAllowed: notificationsAllowed ?? this.notificationsAllowed,
      themeId: themeId ?? this.themeId,
      dailyQuotes: dailyQuotes ?? this.dailyQuotes,
      driveAccountEmail: clearDriveAccountEmail
          ? null
          : driveAccountEmail ?? this.driveAccountEmail,
      driveLastBackupAt: clearDriveLastBackupAt
          ? null
          : driveLastBackupAt ?? this.driveLastBackupAt,
      avatarPath: clearAvatarPath ? null : avatarPath ?? this.avatarPath,
    );
  }

  Map<String, Object?> toJson() => {
    'displayName': displayName,
    'dailyReviewEnabled': dailyReviewEnabled,
    'dailyReviewMinute': dailyReviewMinute,
    'notificationsAllowed': notificationsAllowed,
    'themeId': themeId,
    'dailyQuotes': dailyQuotes,
    'driveAccountEmail': driveAccountEmail,
    'driveLastBackupAt': driveLastBackupAt?.toIso8601String(),
    'avatarPath': avatarPath,
  };

  factory AppSettings.fromJson(Map<String, Object?> json) {
    return AppSettings(
      displayName: json['displayName'] as String? ?? 'Minh',
      dailyReviewEnabled: json['dailyReviewEnabled'] as bool? ?? true,
      dailyReviewMinute: json['dailyReviewMinute'] as int? ?? 21 * 60 + 45,
      notificationsAllowed: json['notificationsAllowed'] as bool? ?? false,
      themeId: json['themeId'] as String? ?? 'default',
      dailyQuotes: (json['dailyQuotes'] as List<Object?>? ?? const [])
          .whereType<String>()
          .where((quote) => quote.trim().isNotEmpty)
          .toList(growable: false),
      driveAccountEmail: json['driveAccountEmail'] as String?,
      driveLastBackupAt: _dateOrNull(json['driveLastBackupAt']),
      avatarPath: json['avatarPath'] as String?,
    );
  }
}

DateTime? _dateOrNull(Object? value) =>
    value is String && value.isNotEmpty ? DateTime.tryParse(value) : null;
