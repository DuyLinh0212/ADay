import 'package:flutter/material.dart';

import '../../core/theme/aday_colors.dart';
import '../../core/theme/aday_spacing.dart';
import '../../core/theme/aday_typography.dart';

/// Deterministic vector painter for the signature ADay app icon.
///
/// Features:
/// - Morning sky gradient (Sky Cyan -> Progress Teal)
/// - Rolling green hill at the bottom
/// - Rising warm golden sun with gentle rays
/// - Bold white humanist letter "A"
/// - Embedded teal checkmark symbol in the crossbar
class ADayAppIconPainter extends CustomPainter {
  const ADayAppIconPainter({
    required this.background,
    required this.sunColor,
    required this.hillColor,
    required this.checkColor,
    required this.isDark,
  });

  final LinearGradient background;
  final Color sunColor;
  final Color hillColor;
  final Color checkColor;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = Radius.circular(size.width * 0.24);
    final rrect = RRect.fromRectAndRadius(rect, radius);

    canvas.save();
    canvas.clipRRect(rrect);

    // 1. Sky Gradient Background
    final skyPaint = Paint()..shader = background.createShader(rect);
    canvas.drawRect(rect, skyPaint);

    // 2. Rising Sun with Rays
    final sunCenter = Offset(size.width * 0.65, size.height * 0.36);
    final sunRadius = size.width * 0.18;

    // Sun rays
    final rayPaint = Paint()
      ..color = sunColor
      ..strokeWidth = size.width * 0.055
      ..strokeCap = StrokeCap.round;

    final rayAngles = [-0.9, -0.4, 0.1, 0.6];
    final rayInner = sunRadius + size.width * 0.04;
    final rayOuter = rayInner + size.width * 0.09;

    for (final angle in rayAngles) {
      final dx = size.width * 0.05 * (angle > 0 ? 1 : -0.5);
      final p1 = Offset(
        sunCenter.dx + rayInner * 0.9 * (angle + 0.5) + dx,
        sunCenter.dy - rayInner * (1.1 - (angle * 0.3).abs()),
      );
      final p2 = Offset(
        sunCenter.dx + rayOuter * 0.9 * (angle + 0.5) + dx,
        sunCenter.dy - rayOuter * (1.1 - (angle * 0.3).abs()),
      );
      canvas.drawLine(p1, p2, rayPaint);
    }

    // Sun disc
    final sunPaint = Paint()..color = sunColor;
    canvas.drawCircle(sunCenter, sunRadius, sunPaint);
    if (isDark) {
      canvas.drawCircle(
        sunCenter.translate(sunRadius * .42, -sunRadius * .15),
        sunRadius * .88,
        Paint()..color = background.colors.first,
      );
    }

    // 3. Rolling Hills in the background
    final hillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [hillColor.withValues(alpha: .88), hillColor],
      ).createShader(rect);

    final hillPath = Path()
      ..moveTo(0, size.height * 0.60)
      ..quadraticBezierTo(
        size.width * 0.30,
        size.height * 0.50,
        size.width * 0.60,
        size.height * 0.62,
      )
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.54,
        size.width,
        size.height * 0.58,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hillPath, hillPaint);

    // 4. White Letter "A"
    final aPath = Path();
    final topA = Offset(size.width * 0.50, size.height * 0.22);
    final leftFoot = Offset(size.width * 0.22, size.height * 0.78);
    final rightFoot = Offset(size.width * 0.78, size.height * 0.78);
    // Outer outline of 'A'
    aPath.moveTo(topA.dx, topA.dy);
    aPath.lineTo(leftFoot.dx, leftFoot.dy);
    aPath.quadraticBezierTo(
      size.width * 0.28,
      size.height * 0.82,
      size.width * 0.36,
      size.height * 0.75,
    );
    aPath.lineTo(size.width * 0.44, size.height * 0.58);
    aPath.lineTo(size.width * 0.56, size.height * 0.58);
    aPath.lineTo(size.width * 0.64, size.height * 0.75);
    aPath.quadraticBezierTo(
      size.width * 0.72,
      size.height * 0.82,
      rightFoot.dx,
      rightFoot.dy,
    );
    aPath.close();

    final aStrokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.16
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final aDrawPath = Path()
      ..moveTo(leftFoot.dx + size.width * 0.05, leftFoot.dy - size.width * 0.05)
      ..lineTo(topA.dx, topA.dy + size.width * 0.05)
      ..lineTo(
        rightFoot.dx - size.width * 0.05,
        rightFoot.dy - size.width * 0.05,
      );

    canvas.drawPath(aDrawPath, aStrokePaint);

    // 5. Embedded Checkmark in Crossbar
    final checkPaint = Paint()
      ..color = checkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final checkPath = Path()
      ..moveTo(size.width * 0.41, size.height * 0.55)
      ..lineTo(size.width * 0.48, size.height * 0.62)
      ..lineTo(size.width * 0.63, size.height * 0.47);

    canvas.drawPath(checkPath, checkPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ADayAppIconPainter oldDelegate) =>
      oldDelegate.background != background ||
      oldDelegate.sunColor != sunColor ||
      oldDelegate.hillColor != hillColor ||
      oldDelegate.checkColor != checkColor ||
      oldDelegate.isDark != isDark;
}

/// Standalone visual widget for the ADay App Icon.
class ADayAppIcon extends StatelessWidget {
  const ADayAppIcon({super.key, this.size = 40.0});

  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = ADayColors.current;
    return Semantics(
      label: 'Biểu tượng ADay',
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: ADayAppIconPainter(
            background: palette.appIconGradient,
            sunColor: palette.id == 'theme_3'
                ? palette.skyCyan
                : palette.sunriseGold,
            hillColor: palette.progressTeal,
            checkColor: palette.isDark ? palette.skyCyan : palette.progressTeal,
            isDark: palette.isDark,
          ),
        ),
      ),
    );
  }
}

/// Compact ADay logo displaying the app icon, title, and optional slogan.
class ADayLogo extends StatelessWidget {
  const ADayLogo({
    super.key,
    this.compact = false,
    this.iconSize = 36.0,
    this.onTap,
  });

  final bool compact;
  final double iconSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ADayAppIcon(size: iconSize),
        const SizedBox(width: ADaySpacing.sm),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'A',
                    style: ADayTypography.title.copyWith(
                      color: ADayColors.brandNavy,
                      fontSize: compact ? 18.0 : 22.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text: 'Day',
                    style: ADayTypography.title.copyWith(
                      color: ADayColors.skyCyan,
                      fontSize: compact ? 18.0 : 22.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            if (!compact) ...[
              const SizedBox(height: 2.0),
              Text(
                'Plan Today • A Better Tomorrow',
                style: ADayTypography.caption.copyWith(
                  fontSize: 10.0,
                  color: ADayColors.mutedInk,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ],
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: ADaySpacing.controlRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: content,
        ),
      );
    }

    return Semantics(
      label: 'ADay: Plan Today, A Better Tomorrow',
      button: onTap != null,
      child: content,
    );
  }
}

/// Top application header bar matching the TrangChu design specification.
///
/// Contains:
/// - Compact ADay logo on the left
/// - Search action button
/// - Notification bell with optional unread indicator
/// - User avatar button
/// - WCAG 2.2 AA compliant 44x44 tap targets
class ADayHeaderBar extends StatelessWidget {
  const ADayHeaderBar({
    super.key,
    this.onLogoTap,
    this.onSearchTap,
    this.onNotificationTap,
    this.onAvatarTap,
    this.hasUnreadNotifications = true,
    this.avatarUrl,
    this.avatarImage,
    this.avatarInitials = 'M',
  });

  final VoidCallback? onLogoTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;
  final bool hasUnreadNotifications;
  final String? avatarUrl;
  final ImageProvider? avatarImage;
  final String avatarInitials;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ADaySpacing.md,
          vertical: ADaySpacing.xs,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: Compact Logo
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: ADayLogo(
                  compact: false,
                  iconSize: 38.0,
                  onTap: onLogoTap,
                ),
              ),
            ),

            // Right: Action controls
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Notification Bell with Badge
                Semantics(
                  label: hasUnreadNotifications
                      ? 'Thông báo, có thông báo chưa đọc'
                      : 'Thông báo',
                  button: true,
                  child: SizedBox(
                    width: ADaySpacing.minTouchTarget,
                    height: ADaySpacing.minTouchTarget,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          onPressed: onNotificationTap,
                          splashRadius: 22.0,
                          icon: Icon(
                            Icons.notifications_none_rounded,
                            color: ADayColors.brandNavy,
                            size: 24.0,
                          ),
                          tooltip: 'Thông báo',
                        ),
                        if (hasUnreadNotifications)
                          Positioned(
                            top: 10.0,
                            right: 10.0,
                            child: Container(
                              width: 8.0,
                              height: 8.0,
                              decoration: BoxDecoration(
                                color: ADayColors.cancelCoral,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: ADaySpacing.xs),

                // Avatar button
                Semantics(
                  label: 'Hồ sơ người dùng',
                  button: true,
                  child: InkWell(
                    onTap: onAvatarTap,
                    borderRadius: ADaySpacing.pillRadius,
                    child: Container(
                      width: ADaySpacing.minTouchTarget,
                      height: ADaySpacing.minTouchTarget,
                      alignment: Alignment.center,
                      child: Container(
                        width: 36.0,
                        height: 36.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFFD4C2),
                          border: Border.all(
                            color: ADayColors.surface,
                            width: 2.0,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x140A3768),
                              blurRadius: 4.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: avatarImage == null
                            ? Center(
                                child: Text(
                                  avatarInitials,
                                  style: ADayTypography.label.copyWith(
                                    color: const Color(0xFFC04F15),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.0,
                                  ),
                                ),
                              )
                            : ClipOval(
                                child: Image(
                                  image: avatarImage!,
                                  width: 36.0,
                                  height: 36.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
