import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'aday_colors.dart';
import 'aday_spacing.dart';
import 'aday_typography.dart';

/// Central theme provider for ADay.
///
/// Implements the design specifications from DESIGN.md and PRODUCT.md:
/// - Creative North Star: "Bình minh có kế hoạch"
/// - Canvas: Cool-light morning canvas (#F7FCFF)
/// - Surfaces: Clean white (#FFFFFF), radius strictly <= 16px
/// - Controls: Radius 12px, primary height 52px, min touch target 44x44
/// - Shadows: Flat by default; Ambient Low only for floating panels
/// - Typography: Be Vietnam Pro with system fallbacks
abstract final class ADayTheme {
  /// Builds the complete authoritative theme for the given themeId.
  static ThemeData forThemeId(String themeId) {
    ADayColors.applyTheme(themeId);
    final palette = ADayColors.current;
    final isDark = palette.isDark;

    final textTheme = ADayTypography.toTextTheme().apply(
      bodyColor: palette.brandNavy,
      displayColor: palette.brandNavy,
    );

    final colorScheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: palette.actionBlue,
      onPrimary: isDark ? const Color(0xFF0B1220) : palette.surface,
      primaryContainer: palette.coolSurface,
      onPrimaryContainer: palette.brandNavy,
      secondary: palette.progressTeal,
      onSecondary: isDark ? const Color(0xFF0B1220) : palette.surface,
      secondaryContainer: palette.progressTealTint,
      onSecondaryContainer: palette.brandNavy,
      tertiary: palette.sunriseGold,
      onTertiary: palette.brandNavy,
      tertiaryContainer: palette.sunriseGoldTint,
      onTertiaryContainer: palette.brandNavy,
      error: palette.cancelCoral,
      onError: isDark ? const Color(0xFF0B1220) : palette.surface,
      errorContainer: palette.cancelCoralTint,
      onErrorContainer: palette.cancelCoral,
      surface: palette.surface,
      onSurface: palette.brandNavy,
      surfaceContainerLowest: palette.canvas,
      surfaceContainerLow: palette.coolSurface,
      surfaceContainer: palette.surface,
      outline: palette.dividerMist,
      outlineVariant: palette.dividerMist,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.canvas,
      fontFamily: ADayTypography.fontFamily,
      fontFamilyFallback: ADayTypography.fontFallbacks,
      textTheme: textTheme,

      // --- AppBar Theme ---
      appBarTheme: AppBarTheme(
        backgroundColor: palette.canvas,
        foregroundColor: palette.brandNavy,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
        titleTextStyle: ADayTypography.title.copyWith(color: palette.brandNavy),
      ),

      // --- Card & Surface Theme ---
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0.0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: ADaySpacing.surfaceRadius,
          side: BorderSide(color: palette.dividerMist, width: 1.0),
        ),
      ),

      // --- Button Themes ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.actionBlue,
          foregroundColor: isDark ? const Color(0xFF0B1220) : palette.surface,
          elevation: 0.0,
          minimumSize: const Size(
            ADaySpacing.minTouchTarget,
            ADaySpacing.buttonHeight,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: ADaySpacing.controlRadius,
          ),
          padding: ADaySpacing.paddingButtonPrimary,
          textStyle: ADayTypography.label.copyWith(
            color: isDark ? const Color(0xFF0B1220) : palette.surface,
            fontSize: 16.0,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.actionBlue,
          minimumSize: const Size(
            ADaySpacing.minTouchTarget,
            ADaySpacing.buttonHeight,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: ADaySpacing.controlRadius,
          ),
          side: BorderSide(color: palette.actionBlue, width: 1.5),
          padding: ADaySpacing.paddingButtonPrimary,
          textStyle: ADayTypography.label.copyWith(
            color: palette.actionBlue,
            fontSize: 16.0,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.actionBlue,
          minimumSize: const Size(
            ADaySpacing.minTouchTarget,
            ADaySpacing.buttonHeightSmall,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: ADaySpacing.controlRadius,
          ),
          textStyle: ADayTypography.label.copyWith(
            color: palette.actionBlue,
          ),
        ),
      ),

      // --- Input Decoration Theme ---
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.coolSurface,
        contentPadding: ADaySpacing.paddingInput,
        hintStyle: ADayTypography.subhead.copyWith(color: palette.mutedInk),
        labelStyle: ADayTypography.label.copyWith(color: palette.brandNavy),
        errorStyle: ADayTypography.caption.copyWith(
          color: palette.cancelCoral,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: ADaySpacing.controlRadius,
          borderSide: BorderSide(color: palette.dividerMist, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: ADaySpacing.controlRadius,
          borderSide: BorderSide(color: palette.actionBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: ADaySpacing.controlRadius,
          borderSide: BorderSide(color: palette.cancelCoral, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: ADaySpacing.controlRadius,
          borderSide: BorderSide(color: palette.cancelCoral, width: 2.0),
        ),
      ),

      // --- Divider Theme ---
      dividerTheme: DividerThemeData(
        color: palette.dividerMist,
        thickness: 1.0,
        space: 1.0,
      ),

      // --- Checkbox Theme ---
      checkboxTheme: CheckboxThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: ADaySpacing.checkboxRadius,
        ),
        side: BorderSide(color: palette.dividerMist, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return palette.progressTeal;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStatePropertyAll<Color>(
          isDark ? const Color(0xFF0B1220) : palette.surface,
        ),
      ),

      // --- Chip Theme ---
      chipTheme: ChipThemeData(
        backgroundColor: palette.coolSurface,
        disabledColor: palette.coolSurface.withValues(alpha: 0.5),
        selectedColor: palette.actionBlueTint,
        padding: ADaySpacing.paddingChip,
        shape: const RoundedRectangleBorder(
          borderRadius: ADaySpacing.pillRadius,
          side: BorderSide(color: Colors.transparent),
        ),
        labelStyle: ADayTypography.caption.copyWith(
          color: palette.brandNavy,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: palette.mutedInk, size: 16.0),
      ),

      // --- Bottom Navigation Theme ---
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.surface,
        selectedItemColor: palette.actionBlue,
        unselectedItemColor: palette.mutedInk,
        selectedLabelStyle: TextStyle(
          fontFamily: ADayTypography.fontFamily,
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: ADayTypography.fontFamily,
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0.0,
      ),

      // --- Extensions ---
      extensions: [
        ADayColorsExtension.fromPalette(palette),
        const ADayTypographyExtension(),
      ],
    );
  }

  /// Backward compatible helper
  static ThemeData light({Color? accentColor}) => forThemeId('default');

  /// Convenience helper to access [ADayColorsExtension] from context.
  static ADayColorsExtension colorsOf(BuildContext context) {
    return Theme.of(context).extension<ADayColorsExtension>() ??
        const ADayColorsExtension();
  }

  /// Convenience helper to access [ADayTypographyExtension] from context.
  static ADayTypographyExtension typographyOf(BuildContext context) {
    return Theme.of(context).extension<ADayTypographyExtension>() ??
        const ADayTypographyExtension();
  }
}

/// Helpful BuildContext extensions for rapid, type-safe token access.
extension ADayThemeContext on BuildContext {
  ADayColorsExtension get adayColors => ADayTheme.colorsOf(this);
  ADayTypographyExtension get adayTypography => ADayTheme.typographyOf(this);
  ThemeData get adayTheme => Theme.of(this);
}
