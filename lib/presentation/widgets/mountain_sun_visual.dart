import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/theme/aday_colors.dart';
import '../../core/theme/aday_spacing.dart';
import '../../core/theme/aday_typography.dart';
import 'aday_button.dart';

/// Painter for rendering scalable, crisp vector mountain contours and a rising golden sun.
///
/// Implements the "Bình minh có kế hoạch" visual North Star:
/// - Layered mountain ridges with morning atmospheric perspective
/// - Radiant golden sunrise
/// - Optional summit flag for milestone/goal tracking
class MountainSunPainter extends CustomPainter {
  const MountainSunPainter({
    this.themeId = 'default',
    this.canvasColor = const Color(0xFFF7FCFF),
    this.showFlag = false,
    this.showSunRays = true,
    this.sunPosition = const Offset(0.78, 0.32),
    this.sunColor,
    this.ridgePrimary = const Color(0xFF20C99A),
    this.ridgeSecondary = const Color(0xFF27BCEB),
  });

  final String themeId;
  final Color canvasColor;
  final bool showFlag;
  final bool showSunRays;
  final Offset sunPosition;
  final Color? sunColor;
  final Color ridgePrimary;
  final Color ridgeSecondary;

  @override
  void paint(Canvas canvas, Size size) {
    final effectiveSunColor = sunColor ?? ADayColors.sunriseGold;
    final w = size.width;
    final h = size.height;

    // 1. Draw the theme's sky marker. Midnight uses a crescent; the four
    // daylight themes use the warm sun present in their reference boards.
    final sunCenter = Offset(w * sunPosition.dx, h * sunPosition.dy);
    final sunRadius = math.min(w, h) * 0.22;

    if (showSunRays && themeId != 'theme_3') {
      final rayPaint = Paint()
        ..color = effectiveSunColor.withValues(alpha: 0.45)
        ..strokeWidth = math.max(2.0, w * 0.015)
        ..strokeCap = StrokeCap.round;

      const angles = [-1.1, -0.7, -0.3, 0.1, 0.5, 0.9];
      final rInner = sunRadius + w * 0.03;
      final rOuter = rInner + w * 0.07;

      for (final angle in angles) {
        final cosA = math.cos(angle);
        final sinA = math.sin(angle);
        final p1 = Offset(
          sunCenter.dx + rInner * sinA,
          sunCenter.dy - rInner * cosA,
        );
        final p2 = Offset(
          sunCenter.dx + rOuter * sinA,
          sunCenter.dy - rOuter * cosA,
        );
        canvas.drawLine(p1, p2, rayPaint);
      }
    }

    // Sun disc with soft glow
    final sunDiscPaint = Paint()
      ..color = effectiveSunColor.withValues(alpha: .9);
    canvas.drawCircle(sunCenter, sunRadius, sunDiscPaint);
    if (themeId == 'theme_3') {
      canvas.drawCircle(
        sunCenter.translate(sunRadius * .38, -sunRadius * .12),
        sunRadius * .9,
        Paint()..color = canvasColor,
      );
      final starPaint = Paint()..color = ridgeSecondary.withValues(alpha: .8);
      for (final star in const [
        Offset(.12, .18),
        Offset(.28, .34),
        Offset(.54, .15),
        Offset(.9, .22),
      ]) {
        canvas.drawCircle(
          Offset(w * star.dx, h * star.dy),
          math.max(1.1, w * .008),
          starPaint,
        );
      }
    }

    // 2. Far Mountain Ridge (Soft Cyan / Sky tint)
    final farRidgePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          ridgeSecondary.withValues(alpha: 0.22),
          ridgeSecondary.withValues(alpha: 0.08),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final farPath = Path()
      ..moveTo(0, h * 0.70)
      ..quadraticBezierTo(w * 0.25, h * 0.45, w * 0.52, h * 0.65)
      ..quadraticBezierTo(w * 0.76, h * 0.38, w, h * 0.62)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(farPath, farRidgePaint);

    // 3. Middle Mountain Ridge (Teal tint)
    final midRidgePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          ridgePrimary.withValues(alpha: 0.35),
          ridgePrimary.withValues(alpha: 0.15),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final midPeak = Offset(w * 0.60, h * 0.42);
    final midPath = Path()
      ..moveTo(0, h * 0.85)
      ..quadraticBezierTo(w * 0.20, h * 0.68, w * 0.38, h * 0.72)
      ..lineTo(midPeak.dx, midPeak.dy)
      ..quadraticBezierTo(w * 0.78, h * 0.60, w, h * 0.78)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(midPath, midRidgePaint);

    // 4. Foreground Rolling Hill (Mint / Progress Teal)
    final foreRidgePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          ridgePrimary.withValues(alpha: 0.46),
          ridgePrimary.withValues(alpha: 0.18),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final forePath = Path()
      ..moveTo(0, h * 0.80)
      ..quadraticBezierTo(w * 0.30, h * 0.65, w * 0.55, h * 0.82)
      ..quadraticBezierTo(w * 0.80, h * 0.74, w, h * 0.88)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(forePath, foreRidgePaint);

    if (themeId == 'theme_5' || themeId == 'theme_3') {
      final silhouette = Paint()
        ..color = ridgePrimary.withValues(
          alpha: themeId == 'theme_3' ? .62 : .5,
        );
      for (final treeX in const [.1, .2, .86, .94]) {
        final base = Offset(w * treeX, h * .9);
        final treeHeight = h * (treeX == .2 || treeX == .86 ? .32 : .22);
        final crown = Path()
          ..moveTo(base.dx, base.dy - treeHeight)
          ..lineTo(base.dx - w * .035, base.dy - treeHeight * .32)
          ..lineTo(base.dx + w * .035, base.dy - treeHeight * .32)
          ..close();
        canvas.drawPath(crown, silhouette);
      }
    }

    // 5. Summit Flag (Optional milestone marker)
    if (showFlag) {
      final flagPoleBase = midPeak;
      final poleTop = Offset(flagPoleBase.dx, flagPoleBase.dy - h * 0.26);

      // Flag pole
      final polePaint = Paint()
        ..color = ADayColors.actionBlue
        ..strokeWidth = math.max(1.8, w * 0.012)
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(flagPoleBase, poleTop, polePaint);

      // Flag banner (triangular)
      final flagPath = Path()
        ..moveTo(poleTop.dx, poleTop.dy)
        ..lineTo(poleTop.dx + w * 0.12, poleTop.dy + h * 0.08)
        ..lineTo(poleTop.dx, poleTop.dy + h * 0.14)
        ..close();

      final flagPaint = Paint()..color = ADayColors.actionBlue;
      canvas.drawPath(flagPath, flagPaint);
    }
  }

  @override
  bool shouldRepaint(covariant MountainSunPainter oldDelegate) {
    return oldDelegate.showFlag != showFlag ||
        oldDelegate.themeId != themeId ||
        oldDelegate.canvasColor != canvasColor ||
        oldDelegate.showSunRays != showSunRays ||
        oldDelegate.sunPosition != sunPosition ||
        oldDelegate.sunColor != sunColor ||
        oldDelegate.ridgePrimary != ridgePrimary ||
        oldDelegate.ridgeSecondary != ridgeSecondary;
  }
}

/// Scalable Mountain and Sun visual illustration widget.
class MountainSunVisual extends StatelessWidget {
  const MountainSunVisual({
    super.key,
    this.width,
    this.height = 100.0,
    this.showFlag = false,
    this.showSunRays = true,
    this.sunPosition = const Offset(0.78, 0.32),
  });

  final double? width;
  final double height;
  final bool showFlag;
  final bool showSunRays;
  final Offset sunPosition;

  @override
  Widget build(BuildContext context) {
    final palette = ADayColors.current;
    return ExcludeSemantics(
      child: SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: CustomPaint(
          painter: MountainSunPainter(
            themeId: palette.id,
            canvasColor: palette.canvas,
            showFlag: showFlag,
            showSunRays: showSunRays,
            sunPosition: sunPosition,
            sunColor: palette.id == 'theme_3'
                ? palette.skyCyan
                : palette.sunriseGold,
            ridgePrimary: palette.progressTeal,
            ridgeSecondary: palette.skyCyan,
          ),
        ),
      ),
    );
  }
}

/// Morning greeting header section combining user greeting and stylized sunrise visual.
class MountainSunHeader extends StatelessWidget {
  const MountainSunHeader({
    super.key,
    required this.greeting,
    required this.subtext,
    this.bannerQuote = '“Những kế hoạch nhỏ tạo nên ngày mai lớn hơn.”',
  });

  final String greeting;
  final String subtext;
  final String bannerQuote;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: '$greeting. $subtext. $bannerQuote',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background soft illustration
          Positioned(
            top: -10.0,
            right: -10.0,
            width: 170.0,
            height: 120.0,
            child: const MountainSunVisual(
              height: 120.0,
              showSunRays: true,
              sunPosition: Offset(0.72, 0.35),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ADaySpacing.md,
              vertical: ADaySpacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(greeting, style: ADayTypography.headline),
                      const SizedBox(height: ADaySpacing.xs),
                      Text(
                        subtext,
                        style: ADayTypography.subhead.copyWith(
                          fontSize: 15.0,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: ADaySpacing.sm),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0, left: 8.0),
                    child: Text(
                      bannerQuote,
                      textAlign: TextAlign.right,
                      style: ADayTypography.quote.copyWith(
                        fontSize: 12.0,
                        color: ADayColors.brandNavy.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable "Mục tiêu dài hạn" card widget featuring the mountain visual and summit flag.
class MountainSunGoalCard extends StatelessWidget {
  const MountainSunGoalCard({
    super.key,
    required this.title,
    required this.activeCountText,
    required this.quote,
    this.actionText = 'Xem mục tiêu',
    this.onActionTap,
    this.onHeaderTap,
  });

  final String title;
  final String activeCountText;
  final String quote;
  final String actionText;
  final VoidCallback? onActionTap;
  final VoidCallback? onHeaderTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ADayColors.surface,
        borderRadius: ADaySpacing.surfaceRadius,
        border: Border.all(color: ADayColors.dividerMist, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background mountain illustration with summit flag
          Positioned(
            right: 0,
            bottom: 0,
            width: 180.0,
            height: 95.0,
            child: const MountainSunVisual(
              height: 95.0,
              showFlag: true,
              showSunRays: false,
              sunPosition: Offset(0.9, 0.25),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(ADaySpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34.0,
                          height: 34.0,
                          decoration: BoxDecoration(
                            color: ADayColors.progressTealTint,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Icon(
                            Icons.track_changes_rounded,
                            color: ADayColors.progressTeal,
                            size: 20.0,
                          ),
                        ),
                        const SizedBox(width: ADaySpacing.sm),
                        Text(
                          title,
                          style: ADayTypography.title.copyWith(fontSize: 18.0),
                        ),
                      ],
                    ),
                    if (onHeaderTap != null)
                      Semantics(
                        button: true,
                        label: 'Xem tất cả mục tiêu dài hạn',
                        child: InkWell(
                          onTap: onHeaderTap,
                          borderRadius: ADaySpacing.controlRadius,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: ADaySpacing.xs,
                              vertical: ADaySpacing.xs,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Xem tất cả',
                                  style: TextStyle(
                                    fontFamily: ADayTypography.fontFamily,
                                    fontSize: 13.0,
                                    color: ADayColors.actionBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 2.0),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 18.0,
                                  color: ADayColors.actionBlue,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: ADaySpacing.md),

                // Body text and action
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeCountText,
                            style: ADayTypography.titleMedium.copyWith(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            quote,
                            style: ADayTypography.caption.copyWith(
                              fontSize: 13.0,
                              color: ADayColors.mutedInk,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: ADaySpacing.sm),
                    ADayButton.secondary(
                      label: actionText,
                      trailingIcon: Icons.chevron_right_rounded,
                      onPressed: onActionTap,
                      height: 38.0,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
