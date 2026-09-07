import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/theme/aday_colors.dart';
import '../../core/theme/aday_typography.dart';

/// Deterministic CustomPainter for the circular progress ring.
class ProgressRingPainter extends CustomPainter {
  const ProgressRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 1. Background Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // 2. Active Progress Arc
    if (progress > 0.0) {
      final activePaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Start from top (-90 degrees / -pi/2)
      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Reusable circular progress ring widget with state animation and accessibility.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 84.0,
    this.strokeWidth = 8.5,
    this.trackColor = const Color(0x38FFFFFF),
    this.progressColor,
    this.centerTextStyle,
    this.showPercentageText = true,
  });

  /// The progress value between 0.0 and 1.0.
  final double progress;

  /// Diameter of the ring widget.
  final double size;

  /// Stroke width of the ring track.
  final double strokeWidth;

  /// Background circle color.
  final Color trackColor;

  /// Active sweep progress color.
  final Color? progressColor;

  /// Custom text style for the center percentage label.
  final TextStyle? centerTextStyle;

  /// Whether to display percentage in the center.
  final bool showPercentageText;

  @override
  Widget build(BuildContext context) {
    final effectiveProgressColor = progressColor ?? ADayColors.surface;
    final percentInt = (progress.clamp(0.0, 1.0) * 100).round();
    final disableMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return Semantics(
      label: 'Tiến độ hoàn thành: $percentInt%',
      value: '$percentInt%',
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: progress.clamp(0.0, 1.0)),
        duration: disableMotion
            ? Duration.zero
            : const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        builder: (context, animatedValue, child) {
          return SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(size, size),
                  painter: ProgressRingPainter(
                    progress: animatedValue,
                    trackColor: trackColor,
                    progressColor: effectiveProgressColor,
                    strokeWidth: strokeWidth,
                  ),
                ),
                if (showPercentageText)
                  Text(
                    '${(animatedValue * 100).round()}%',
                    style:
                        centerTextStyle ??
                        ADayTypography.title.copyWith(
                          color: ADayColors.surface,
                          fontSize: size * 0.26,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
