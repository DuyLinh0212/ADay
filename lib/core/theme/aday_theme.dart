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
  /// Builds the authoritative light theme for ADay.
  static ThemeData light({Color? accentColor}) {
    final textTheme = ADayTypography.toTextTheme();

    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: accentColor ?? ADayColors.actionBlue,
      onPrimary: ADayColors.surface,
      primaryContainer: ADayColors.coolSurface,
      onPrimaryContainer: ADayColors.brandNavy,
      secondary: ADayColors.progressTeal,
      onSecondary: ADayColors.surface,
      secondaryContainer: ADayColors.progressTealTint,
      onSecondaryContainer: ADayColors.brandNavy,
      tertiary: ADayColors.sunriseGold,
      onTertiary: ADayColors.brandNavy,
      tertiaryContainer: ADayColors.sunriseGoldTint,
      onTertiaryContainer: ADayColors.brandNavy,
      error: ADayColors.cancelCoral,
      onError: ADayColors.surface,
      errorContainer: ADayColors.cancelCoralTint,
      onErrorContainer: ADayColors.cancelCoral,
      surface: ADayColors.surface,
      onSurface: ADayColors.brandNavy,
      surfaceContainerLowest: ADayColors.canvas,
      surfaceContainerLow: ADayColors.coolSurface,
      surfaceContainer: ADayColors.surface,
      outline: ADayColors.dividerMist,
      outlineVariant: ADayColors.dividerMist,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ADayColors.canvas,
      fontFamily: ADayTypography.fontFamily,
      fontFamilyFallback: ADayTypography.fontFallbacks,
      textTheme: textTheme,

      // --- AppBar Theme ---
      appBarTheme: const AppBarTheme(
        backgroundColor: ADayColors.canvas,
        foregroundColor: ADayColors.brandNavy,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: ADayTypography.title,
      ),

      // --- Card & Surface Theme ---
      cardTheme: CardThemeData(
        color: ADayColors.surface,
        elevation: 0.0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: ADaySpacing.surfaceRadius,
          side: const BorderSide(color: ADayColors.dividerMist, width: 1.0),
        ),
      ),

      // --- Button Themes ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ADayColors.actionBlue,
          foregroundColor: ADayColors.surface,
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
            color: ADayColors.surface,
            fontSize: 16.0,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ADayColors.actionBlue,
          minimumSize: const Size(
            ADaySpacing.minTouchTarget,
            ADaySpacing.buttonHeight,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: ADaySpacing.controlRadius,
          ),
          side: const BorderSide(color: ADayColors.actionBlue, width: 1.5),
          padding: ADaySpacing.paddingButtonPrimary,
          textStyle: ADayTypography.label.copyWith(
            color: ADayColors.actionBlue,
            fontSize: 16.0,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ADayColors.actionBlue,
          minimumSize: const Size(
            ADaySpacing.minTouchTarget,
            ADaySpacing.buttonHeightSmall,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: ADaySpacing.controlRadius,
          ),
          textStyle: ADayTypography.label.copyWith(
            color: ADayColors.actionBlue,
          ),
        ),
      ),

      // --- Input Decoration Theme ---
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ADayColors.canvas,
        contentPadding: ADaySpacing.paddingInput,
        hintStyle: ADayTypography.subhead,
        labelStyle: ADayTypography.label,
        errorStyle: ADayTypography.caption.copyWith(
          color: ADayColors.cancelCoral,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: ADaySpacing.controlRadius,
          borderSide: BorderSide(color: ADayColors.dividerMist, width: 1.0),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: ADaySpacing.controlRadius,
          borderSide: BorderSide(color: ADayColors.actionBlue, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: ADaySpacing.controlRadius,
          borderSide: BorderSide(color: ADayColors.cancelCoral, width: 1.5),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: ADaySpacing.controlRadius,
          borderSide: BorderSide(color: ADayColors.cancelCoral, width: 2.0),
        ),
      ),

      // --- Divider Theme ---
      dividerTheme: const DividerThemeData(
        color: ADayColors.dividerMist,
        thickness: 1.0,
        space: 1.0,
      ),

      // --- Checkbox Theme ---
      checkboxTheme: CheckboxThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: ADaySpacing.checkboxRadius,
        ),
        side: const BorderSide(color: ADayColors.dividerMist, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return ADayColors.progressTeal;
          }
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll<Color>(ADayColors.surface),
      ),

      // --- Chip Theme ---
      chipTheme: ChipThemeData(
        backgroundColor: ADayColors.coolSurface,
        disabledColor: ADayColors.coolSurface.withValues(alpha: 0.5),
        selectedColor: ADayColors.actionBlueTint,
        padding: ADaySpacing.paddingChip,
        shape: const RoundedRectangleBorder(
          borderRadius: ADaySpacing.pillRadius,
          side: BorderSide(color: Colors.transparent),
        ),
        labelStyle: ADayTypography.caption.copyWith(
          color: ADayColors.brandNavy,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: ADayColors.mutedInk, size: 16.0),
      ),

      // --- Bottom Navigation Theme ---
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ADayColors.surface,
        selectedItemColor: ADayColors.actionBlue,
        unselectedItemColor: ADayColors.mutedInk,
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
      extensions: const [ADayColorsExtension(), ADayTypographyExtension()],
    );
  }

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
