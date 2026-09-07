import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/aday_colors.dart';
import '../../../core/theme/aday_spacing.dart';
import '../../../core/theme/aday_typography.dart';
import '../../widgets/aday_bottom_nav.dart';
import '../../widgets/aday_logo_header.dart';
import '../../widgets/mountain_sun_visual.dart';
import 'profile_view_data.dart';

/// The authoritative Profile & Settings presentation screen for ADay, matching media_1788785465312.png.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.data,
    this.showHeader = true,
    this.showBottomNav = true,
    this.bottomNavIndex = 3,
    this.hasUnreadNotifications = false,
    this.driveAccountEmail,
    this.avatarPath,
    this.onLogoTap,
    this.onSearchTap,
    this.onNotificationTap,
    this.onAvatarTap,
    this.onEditAvatar,
    this.onEditDisplayName,
    this.onEditEmail,
    this.onSecurityTap,
    this.onToggleReminderBefore22,
    this.onToggleDailyNotification,
    this.onLanguageTap,
    this.onThemeTap,
    this.onWidgetTap,
    this.onDriveBackupTap,
    this.onHelpCenterTap,
    this.onTermsTap,
    this.onLogoutTap,
    this.onChangeReminderTime,
    this.onCreateGoalTap,
    this.onNavTap,
  });

  final ProfileViewData data;
  final bool showHeader;
  final bool showBottomNav;
  final int bottomNavIndex;
  final bool hasUnreadNotifications;
  final String? driveAccountEmail;
  final String? avatarPath;

  final VoidCallback? onLogoTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onEditAvatar;
  final VoidCallback? onEditDisplayName;
  final VoidCallback? onEditEmail;
  final VoidCallback? onSecurityTap;
  final ValueChanged<bool>? onToggleReminderBefore22;
  final VoidCallback? onChangeReminderTime;
  final ValueChanged<bool>? onToggleDailyNotification;
  final VoidCallback? onLanguageTap;
  final VoidCallback? onThemeTap;
  final VoidCallback? onWidgetTap;
  final VoidCallback? onDriveBackupTap;
  final VoidCallback? onHelpCenterTap;
  final VoidCallback? onTermsTap;
  final VoidCallback? onLogoutTap;
  final VoidCallback? onCreateGoalTap;
  final ValueChanged<int>? onNavTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ADayColors.canvas,
      body: SafeArea(
        bottom: !showBottomNav,
        child: Column(
          children: [
            // 1. Top Header Bar
            if (showHeader)
              ADayHeaderBar(
                onLogoTap: onLogoTap,
                onSearchTap: onSearchTap,
                onNotificationTap: onNotificationTap,
                onAvatarTap: onAvatarTap,
                hasUnreadNotifications: hasUnreadNotifications,
                avatarInitials: data.displayName.isNotEmpty
                    ? data.displayName.trim().split(' ').last[0].toUpperCase()
                    : 'M',
                avatarImage: _avatarImage,
              ),

            // 2. Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: ADaySpacing.md,
                  vertical: ADaySpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // A. Title Section with Mountain & Sun
                    _buildTitleSection(context),

                    const SizedBox(height: ADaySpacing.md),

                    // B. Hero Profile Card with Avatar & 3 Metrics
                    _buildHeroCard(context),

                    const SizedBox(height: ADaySpacing.md),

                    // C. Section: Tài khoản
                    _buildAccountSection(context),

                    const SizedBox(height: ADaySpacing.md),

                    // D. Section: Tùy chỉnh
                    _buildPreferencesSection(context),

                    const SizedBox(height: ADaySpacing.md),

                    // E. Section: Hỗ trợ
                    _buildSupportSection(context),

                    const SizedBox(height: ADaySpacing.md),

                    // F. Action: Đăng xuất
                    _buildLogoutCard(context),

                    const SizedBox(height: ADaySpacing.lg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: showBottomNav
          ? ADayBottomNav(
              currentIndex: bottomNavIndex,
              onTap: onNavTap ?? (_) {},
              onCreateGoalTap: onCreateGoalTap,
            )
          : null,
    );
  }

  /// Screen headline with scenic mountain/sunrise background illustration.
  Widget _buildTitleSection(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Mountain sunrise illustration in top right
        Positioned(
          top: -15.0,
          right: -10.0,
          width: 140.0,
          height: 80.0,
          child: const MountainSunVisual(
            height: 80.0,
            showFlag: false,
            showSunRays: true,
            sunPosition: Offset(0.75, 0.35),
          ),
        ),

        // Text content
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hồ sơ',
              style: ADayTypography.headline.copyWith(
                fontSize: 26.0,
                fontWeight: FontWeight.w800,
                color: ADayColors.brandNavy,
              ),
            ),
            const SizedBox(height: 3.0),
            Text(
              'Quản lý tài khoản và cài đặt cá nhân của bạn.',
              style: ADayTypography.subhead.copyWith(
                fontSize: 14.0,
                height: 1.4,
                color: ADayColors.mutedInk,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Hero profile card with Avatar, user details, quote and 3 metrics.
  Widget _buildHeroCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ADayColors.surface,
        borderRadius: ADaySpacing.surfaceRadius,
        border: Border.all(color: ADayColors.dividerMist, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x081C5B84),
            blurRadius: 10.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(ADaySpacing.md),
      child: Column(
        children: [
          // Top Part: Avatar + Info + Quote
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with edit badge
              Stack(
                children: [
                  Container(
                    width: 62.0,
                    height: 62.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCEEFB),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x101C5B84),
                          blurRadius: 6.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _avatarImage == null
                        ? Center(
                            child: Text(
                              data.displayName.isNotEmpty
                                  ? data.displayName
                                        .trim()
                                        .split(' ')
                                        .last[0]
                                        .toUpperCase()
                                  : 'M',
                              style: TextStyle(
                                fontFamily: ADayTypography.fontFamily,
                                fontSize: 24.0,
                                fontWeight: FontWeight.w800,
                                color: ADayColors.actionBlue,
                              ),
                            ),
                          )
                        : ClipOval(
                            child: Image(
                              image: _avatarImage!,
                              width: 62,
                              height: 62,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: onEditAvatar,
                      borderRadius: BorderRadius.circular(12.0),
                      child: Container(
                        width: 22.0,
                        height: 22.0,
                        decoration: BoxDecoration(
                          color: ADayColors.actionBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 11.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: ADaySpacing.sm + 2),

              // Name and join date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.displayName,
                      style: ADayTypography.title.copyWith(
                        fontSize: 17.5,
                        fontWeight: FontWeight.w800,
                        color: ADayColors.brandNavy,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      data.memberSince,
                      style: TextStyle(
                        fontFamily: ADayTypography.fontFamily,
                        fontSize: 12.0,
                        color: ADayColors.mutedInk,
                      ),
                    ),
                  ],
                ),
              ),

              // Right side: Quote with decorative leaves
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.quote,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: ADayTypography.fontFamily,
                      fontSize: 10.5,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: ADayColors.brandNavy.withValues(alpha: 0.75),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  const Icon(
                    Icons.eco_rounded,
                    size: 14.0,
                    color: Color(0xFF20C99A),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: ADaySpacing.md),
          const Divider(height: 1.0, color: Color(0xFFF0F4F8)),
          const SizedBox(height: ADaySpacing.md),

          // Bottom Part: 3 Metric Columns
          Row(
            children: [
              // Metric 1: Mục tiêu đang theo dõi
              Expanded(
                child: _buildHeroMetric(
                  icon: Icons.track_changes_rounded,
                  iconColor: const Color(0xFF168AF2),
                  bgColor: const Color(0xFFEBF4FE),
                  value: '${data.activeGoalsCount}',
                  label: 'Mục tiêu\nđang theo dõi',
                ),
              ),

              // Divider
              Container(
                width: 1.0,
                height: 42.0,
                color: const Color(0xFFEDF2F7),
              ),

              // Metric 2: Đã hoàn thành tháng này
              Expanded(
                child: _buildHeroMetric(
                  icon: Icons.check_circle_rounded,
                  iconColor: const Color(0xFF20C99A),
                  bgColor: const Color(0xFFEAF8F4),
                  value: '${data.completedThisMonthCount}',
                  label: 'Đã hoàn thành\ntháng này',
                ),
              ),

              // Divider
              Container(
                width: 1.0,
                height: 42.0,
                color: const Color(0xFFEDF2F7),
              ),

              // Metric 3: Tỉ lệ hoàn thành
              Expanded(
                child: _buildHeroMetric(
                  icon: Icons.bar_chart_rounded,
                  iconColor: const Color(0xFF8E59FF),
                  bgColor: const Color(0xFFF3EDFF),
                  value: '${data.completionRate}%',
                  label: 'Tỉ lệ\nhoàn thành',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ImageProvider? get _avatarImage {
    final path = avatarPath;
    if (path == null || path.isEmpty || !File(path).existsSync()) return null;
    return FileImage(File(path));
  }

  Widget _buildHeroMetric({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String value,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30.0,
            height: 30.0,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 17.0),
          ),
          const SizedBox(width: 6.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: ADayTypography.fontFamily,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w800,
                  color: ADayColors.brandNavy,
                  height: 1.1,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontFamily: ADayTypography.fontFamily,
                  fontSize: 10.0,
                  fontWeight: FontWeight.w500,
                  color: ADayColors.mutedInk,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Card Section: Tài khoản
  Widget _buildAccountSection(BuildContext context) {
    return _buildGroupCard(
      icon: Icons.person_rounded,
      iconColor: ADayColors.actionBlue,
      title: 'Tài khoản',
      children: [
        _buildActionRow(
          icon: Icons.person_outline_rounded,
          iconColor: ADayColors.mutedInk,
          title: 'Tên hiển thị',
          value: data.displayName,
          onTap: onEditDisplayName,
        ),
        const Divider(height: 1.0, color: Color(0xFFF0F4F8)),
        _buildActionRow(
          icon: Icons.mail_outline_rounded,
          iconColor: const Color(0xFF168AF2),
          title: 'Email',
          value: data.email,
          onTap: onEditEmail,
        ),
        const Divider(height: 1.0, color: Color(0xFFF0F4F8)),
        _buildActionRow(
          icon: Icons.lock_outline_rounded,
          iconColor: ADayColors.mutedInk,
          title: 'Bảo mật',
          onTap: onSecurityTap,
        ),
      ],
    );
  }

  /// Card Section: Tùy chỉnh
  Widget _buildPreferencesSection(BuildContext context) {
    return _buildGroupCard(
      icon: Icons.settings_rounded,
      iconColor: ADayColors.actionBlue,
      title: 'Tùy chỉnh',
      children: [
        _buildSwitchRow(
          icon: Icons.notifications_active_rounded,
          iconColor: const Color(0xFFFFB52E),
          title: 'Nhắc nhở trước 22:00',
          value: data.reminderBefore22Enabled,
          onChanged: onToggleReminderBefore22,
          onTap: onChangeReminderTime,
        ),
        const Divider(height: 1.0, color: Color(0xFFF0F4F8)),
        _buildSwitchRow(
          icon: Icons.notifications_rounded,
          iconColor: const Color(0xFFFFB52E),
          title: 'Thông báo hằng ngày',
          value: data.dailyNotificationEnabled,
          onChanged: onToggleDailyNotification,
        ),
        const Divider(height: 1.0, color: Color(0xFFF0F4F8)),
        _buildActionRow(
          icon: Icons.language_rounded,
          iconColor: const Color(0xFF168AF2),
          title: 'Ngôn ngữ',
          value: data.language,
          onTap: onLanguageTap,
        ),
        const Divider(height: 1.0, color: Color(0xFFF0F4F8)),
        _buildActionRow(
          icon: Icons.palette_outlined,
          iconColor: const Color(0xFF8E59FF),
          title: 'Giao diện',
          value: data.themeMode,
          onTap: onThemeTap,
        ),
        const Divider(height: 1.0, color: Color(0xFFF0F4F8)),
        _buildActionRow(
          icon: Icons.widgets_outlined,
          iconColor: const Color(0xFF168AF2),
          title: 'Tiện ích màn hình chính',
          onTap: onWidgetTap,
        ),
        const Divider(height: 1.0, color: Color(0xFFF0F4F8)),
        _buildActionRow(
          icon: Icons.cloud_upload_outlined,
          iconColor: const Color(0xFF168AF2),
          title: 'Sao lưu Google Drive',
          value: driveAccountEmail ?? 'Chưa kết nối',
          onTap: onDriveBackupTap,
        ),
      ],
    );
  }

  /// Card Section: Hỗ trợ
  Widget _buildSupportSection(BuildContext context) {
    return _buildGroupCard(
      icon: Icons.help_rounded,
      iconColor: ADayColors.actionBlue,
      title: 'Hỗ trợ',
      children: [
        _buildActionRow(
          icon: Icons.headset_mic_outlined,
          iconColor: const Color(0xFF168AF2),
          title: 'Trung tâm hỗ trợ',
          onTap: onHelpCenterTap,
        ),
        const Divider(height: 1.0, color: Color(0xFFF0F4F8)),
        _buildActionRow(
          icon: Icons.description_outlined,
          iconColor: const Color(0xFF168AF2),
          title: 'Điều khoản & chính sách',
          onTap: onTermsTap,
        ),
      ],
    );
  }

  /// Card Action: Đăng xuất
  Widget _buildLogoutCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2F3),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: const Color(0xFFFFDDE0), width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onLogoutTap,
          borderRadius: BorderRadius.circular(14.0),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 13.0),
            child: Row(
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFF0525E),
                  size: 20.0,
                ),
                SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    'Đăng xuất',
                    style: TextStyle(
                      fontFamily: ADayTypography.fontFamily,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF0525E),
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFF0525E),
                  size: 18.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Container for a grouped card with header icon & title.
  Widget _buildGroupCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ADayColors.surface,
        borderRadius: ADaySpacing.surfaceRadius,
        border: Border.all(color: ADayColors.dividerMist, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x081C5B84),
            blurRadius: 10.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(ADaySpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20.0),
              const SizedBox(width: 8.0),
              Text(
                title,
                style: ADayTypography.title.copyWith(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                  color: ADayColors.brandNavy,
                ),
              ),
            ],
          ),

          const SizedBox(height: ADaySpacing.sm),

          // Rows
          ...children,
        ],
      ),
    );
  }

  /// Single selectable row with icon, title, optional value and trailing chevron.
  Widget _buildActionRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 2.0),
        child: Row(
          children: [
            Icon(icon, size: 20.0, color: iconColor),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: ADayTypography.fontFamily,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  color: ADayColors.brandNavy,
                ),
              ),
            ),
            if (value != null) ...[
              Text(
                value,
                style: TextStyle(
                  fontFamily: ADayTypography.fontFamily,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: ADayColors.mutedInk,
                ),
              ),
              const SizedBox(width: 4.0),
            ],
            const Icon(
              Icons.chevron_right_rounded,
              size: 18.0,
              color: Color(0xFFB0C4DE),
            ),
          ],
        ),
      ),
    );
  }

  /// Single switch row with icon, title and Switch toggle.
  Widget _buildSwitchRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool value,
    ValueChanged<bool>? onChanged,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 2.0),
        child: Row(
          children: [
            Icon(icon, size: 20.0, color: iconColor),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: ADayTypography.fontFamily,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  color: ADayColors.brandNavy,
                ),
              ),
            ),
            Switch.adaptive(
              value: value,
              activeTrackColor: const Color(0xFF20C99A),
              activeThumbColor: Colors.white,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
