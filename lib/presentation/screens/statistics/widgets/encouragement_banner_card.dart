import 'package:flutter/material.dart';

import '../../../../core/theme/aday_colors.dart';
import '../../../../core/theme/aday_spacing.dart';
import '../../../../core/theme/aday_typography.dart';
import '../../../widgets/mountain_sun_visual.dart';

/// Encouragement card at the bottom matching Image 2 ("Bạn đang làm rất tốt!").
class EncouragementBannerCard extends StatelessWidget {
  const EncouragementBannerCard({
    super.key,
    required this.title,
    required this.message,
    required this.quote,
    this.highlightText = '12%',
    this.onTap,
  });

  final String title;
  final String message;
  final String quote;
  final String highlightText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE9FBF5), Color(0xFFE5F4FE)],
        ),
        borderRadius: ADaySpacing.surfaceRadius,
        border: Border.all(color: const Color(0xFFD3EDE4), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x081C5B84),
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Mountain artwork with summit flag in bottom right
          Positioned(
            right: -10.0,
            bottom: -5.0,
            width: 170.0,
            height: 85.0,
            child: const MountainSunVisual(
              height: 85.0,
              showFlag: true,
              showSunRays: false,
              sunPosition: Offset(0.82, 0.25),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(ADaySpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Content
                Expanded(
                  flex: 60,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Trophy Icon + Title
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.emoji_events_rounded,
                            color: Color(0xFFFFB52E),
                            size: 28.0,
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              title,
                              style: ADayTypography.title.copyWith(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700,
                                color: ADayColors.brandNavy,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6.0),

                      // Message with green highlight
                      Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontFamily: ADayTypography.fontFamily,
                            fontSize: 12.0,
                            height: 1.35,
                            color: ADayColors.mutedInk,
                          ),
                          children: _buildHighlightedMessage(
                            message,
                            highlightText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8.0),

                // Right Content: Speech Bubble Quote
                Expanded(
                  flex: 40,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2.0, left: 4.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: const Color(0xFFCBEAE2),
                          width: 0.8,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 4.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        quote,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: ADayTypography.fontFamily,
                          fontSize: 10.5,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          color: ADayColors.brandNavy,
                          height: 1.25,
                        ),
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

  List<TextSpan> _buildHighlightedMessage(String text, String highlight) {
    if (!text.contains(highlight)) {
      return [TextSpan(text: text)];
    }

    final parts = text.split(highlight);
    return [
      TextSpan(text: parts[0]),
      TextSpan(
        text: highlight,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF20C99A),
        ),
      ),
      if (parts.length > 1) TextSpan(text: parts[1]),
    ];
  }
}
