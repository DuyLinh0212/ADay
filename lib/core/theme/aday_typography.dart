import 'package:flutter/material.dart';
import 'aday_colors.dart';

/// Typography definitions for ADay.
///
/// Follows DESIGN.md strictly:
/// - Display Font & Body Font: Be Vietnam Pro with system-ui fallbacks.
/// - Humanist sans ensuring Vietnamese diacritics remain legible at all sizes.
/// - The Vietnamese First Rule: Flexible height, no fixed clipping, supports dynamic type.
abstract final class ADayTypography {
  static const String fontFamily = 'Be Vietnam Pro';

  static const List<String> fontFallbacks = [
    'Be Vietnam Pro',
    'system-ui',
    '-apple-system',
    'BlinkMacSystemFont',
    'Segoe UI',
    'Roboto',
    'Helvetica Neue',
    'Arial',
    'sans-serif',
  ];

  /// Headline: Screen greetings and top page titles (700, 28px, height 1.25, letter-spacing -0.02em).
  static const TextStyle headline = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallbacks,
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.56, // -0.02em * 28
    color: ADayColors.brandNavy,
  );

  /// Title: Group headers, section titles, major card titles (700, 20px, height 1.3).
  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallbacks,
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.2,
    color: ADayColors.brandNavy,
  );

  /// Title Medium: Item titles in task lists and summaries (600, 18px, height 1.35).
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallbacks,
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: ADayColors.brandNavy,
  );

  /// Body: Descriptions, task notes, regular reading content (400, 16px, height 1.5).
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallbacks,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: ADayColors.brandNavy,
  );

  /// Body Medium: Emphasized reading content or task titles (600, 16px, height 1.45).
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallbacks,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    height: 1.45,
    color: ADayColors.brandNavy,
  );

  /// Label: Buttons, chips, key metadata (600, 14px, height 1.35).
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallbacks,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: ADayColors.brandNavy,
  );

  /// Subhead: Secondary descriptions, dates, category subtitles (400, 14px, height 1.4).
  static const TextStyle subhead = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallbacks,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: ADayColors.mutedInk,
  );

  /// Caption: Microcopy, timestamps, small tags (500, 12px, height 1.33).
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallbacks,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    height: 1.33,
    color: ADayColors.mutedInk,
  );

  /// Quote: Motivational header quotes (400, 13px, height 1.4, italic).
  static const TextStyle quote = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallbacks,
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    height: 1.4,
    color: ADayColors.mutedInk,
  );

  /// Builds a Flutter standard [TextTheme] adhering to the ADay design hierarchy.
  static TextTheme toTextTheme() {
    return const TextTheme(
      headlineLarge: headline,
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 24.0,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: ADayColors.brandNavy,
      ),
      headlineSmall: title,
      titleLarge: title,
      titleMedium: titleMedium,
      titleSmall: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 15.0,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: ADayColors.brandNavy,
      ),
      bodyLarge: body,
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: ADayColors.brandNavy,
      ),
      bodySmall: caption,
      labelLarge: label,
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 13.0,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: ADayColors.brandNavy,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 11.0,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: ADayColors.mutedInk,
      ),
    );
  }
}

/// Theme extension for ADay typography.
class ADayTypographyExtension extends ThemeExtension<ADayTypographyExtension> {
  const ADayTypographyExtension({
    this.headline = ADayTypography.headline,
    this.title = ADayTypography.title,
    this.titleMedium = ADayTypography.titleMedium,
    this.body = ADayTypography.body,
    this.bodyMedium = ADayTypography.bodyMedium,
    this.label = ADayTypography.label,
    this.subhead = ADayTypography.subhead,
    this.caption = ADayTypography.caption,
    this.quote = ADayTypography.quote,
  });

  final TextStyle headline;
  final TextStyle title;
  final TextStyle titleMedium;
  final TextStyle body;
  final TextStyle bodyMedium;
  final TextStyle label;
  final TextStyle subhead;
  final TextStyle caption;
  final TextStyle quote;

  @override
  ThemeExtension<ADayTypographyExtension> copyWith({
    TextStyle? headline,
    TextStyle? title,
    TextStyle? titleMedium,
    TextStyle? body,
    TextStyle? bodyMedium,
    TextStyle? label,
    TextStyle? subhead,
    TextStyle? caption,
    TextStyle? quote,
  }) {
    return ADayTypographyExtension(
      headline: headline ?? this.headline,
      title: title ?? this.title,
      titleMedium: titleMedium ?? this.titleMedium,
      body: body ?? this.body,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      label: label ?? this.label,
      subhead: subhead ?? this.subhead,
      caption: caption ?? this.caption,
      quote: quote ?? this.quote,
    );
  }

  @override
  ThemeExtension<ADayTypographyExtension> lerp(
    covariant ThemeExtension<ADayTypographyExtension>? other,
    double t,
  ) {
    if (other is! ADayTypographyExtension) {
      return this;
    }
    return ADayTypographyExtension(
      headline: TextStyle.lerp(headline, other.headline, t) ?? headline,
      title: TextStyle.lerp(title, other.title, t) ?? title,
      titleMedium:
          TextStyle.lerp(titleMedium, other.titleMedium, t) ?? titleMedium,
      body: TextStyle.lerp(body, other.body, t) ?? body,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t) ?? bodyMedium,
      label: TextStyle.lerp(label, other.label, t) ?? label,
      subhead: TextStyle.lerp(subhead, other.subhead, t) ?? subhead,
      caption: TextStyle.lerp(caption, other.caption, t) ?? caption,
      quote: TextStyle.lerp(quote, other.quote, t) ?? quote,
    );
  }
}
