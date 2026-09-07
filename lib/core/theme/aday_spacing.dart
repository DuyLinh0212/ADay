import 'package:flutter/material.dart';

/// Spacing, radius, dimension, and touch-target design tokens for ADay.
///
/// Follows DESIGN.md strictly:
/// - Controls: 12px radius
/// - Surfaces: 16px radius (strictly <= 16px, no large 32px radii)
/// - Pills: 999px radius (only for chips, badges, and icon buttons)
/// - WCAG 2.2 touch target minimum: 44x44
abstract final class ADaySpacing {
  // --- Spacing Steps ---

  /// Extra small spacing (4px).
  static const double xs = 4.0;

  /// Small spacing (8px).
  static const double sm = 8.0;

  /// Medium spacing (16px) - standard padding and margins.
  static const double md = 16.0;

  /// Large spacing (24px) - section gaps and header padding.
  static const double lg = 24.0;

  /// Extra large spacing (32px) - major section separators.
  static const double xl = 32.0;

  // --- Border Radii Values ---

  /// Standard radius for interactive controls (buttons, inputs): 12px.
  static const double radiusControl = 12.0;

  /// Standard radius for cards and major surfaces: 16px (Max <= 16px).
  static const double radiusSurface = 16.0;

  /// Radius for pills, tags, chips, and circular avatars: 999px.
  static const double radiusPill = 999.0;

  /// Small radius for category icon badges, checkboxes: 8px.
  static const double radiusSmall = 8.0;

  /// Extra small radius for checkboxes: 6px.
  static const double radiusCheckbox = 6.0;

  // --- BorderRadius Objects ---

  static const BorderRadius controlRadius = BorderRadius.all(
    Radius.circular(radiusControl),
  );

  static const BorderRadius surfaceRadius = BorderRadius.all(
    Radius.circular(radiusSurface),
  );

  static const BorderRadius pillRadius = BorderRadius.all(
    Radius.circular(radiusPill),
  );

  static const BorderRadius smallRadius = BorderRadius.all(
    Radius.circular(radiusSmall),
  );

  static const BorderRadius checkboxRadius = BorderRadius.all(
    Radius.circular(radiusCheckbox),
  );

  // --- Dimensions & Accessibility ---

  /// Minimum interactive target size for WCAG 2.2 AA compliance: 44x44.
  static const double minTouchTarget = 44.0;

  /// Minimum interactive constraints box.
  static const BoxConstraints minTouchTargetConstraints = BoxConstraints(
    minWidth: minTouchTarget,
    minHeight: minTouchTarget,
  );

  /// Standard primary action button height: 52px.
  static const double buttonHeight = 52.0;

  /// Standard secondary / compact button height: 44px.
  static const double buttonHeightSmall = 44.0;

  /// Standard category icon container size: 40x40.
  static const double categoryIconSize = 40.0;

  /// Standard bottom navigation height: 68.0.
  static const double bottomNavHeight = 68.0;

  // --- Inset / Padding Presets ---

  static const EdgeInsets paddingScreen = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  static const EdgeInsets paddingCard = EdgeInsets.all(md);

  static const EdgeInsets paddingCardLarge = EdgeInsets.all(lg);

  static const EdgeInsets paddingButtonPrimary = EdgeInsets.symmetric(
    horizontal: 20.0,
    vertical: 14.0,
  );

  static const EdgeInsets paddingButtonSecondary = EdgeInsets.symmetric(
    horizontal: md,
    vertical: 12.0,
  );

  static const EdgeInsets paddingChip = EdgeInsets.symmetric(
    horizontal: 12.0,
    vertical: 6.0,
  );

  static const EdgeInsets paddingInput = EdgeInsets.symmetric(
    horizontal: md,
    vertical: 14.0,
  );
}
