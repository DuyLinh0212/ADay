import 'package:flutter/material.dart';

/// Design tokens for the ADay color palette as specified in DESIGN.md.
///
/// Creative North Star: "Bình minh có kế hoạch" (Sunrise with a plan).
/// The palette travels from morning sky to earth teal, with sunrise gold
/// and cancel coral reserved for status indicators requiring attention.
abstract final class ADayColors {
  // --- Primary Brand Colors ---

  /// Brand Navy: Main titles, high-contrast text, neutral icons.
  static const Color brandNavy = Color(0xFF0A3768);

  /// Action Blue: Primary actions, active navigation tabs, interactive links, focus halo.
  static const Color actionBlue = Color(0xFF168AF2);

  // --- Secondary Accents ---

  /// Sky Cyan: Morning sky accents, hero card gradients, supporting charts.
  static const Color skyCyan = Color(0xFF27BCEB);

  /// Progress Teal: Circular progress sweeps, completion badges, positive trends.
  static const Color progressTeal = Color(0xFF0EB8AC);

  /// Success Mint: Secondary success accents and subtle highlights.
  static const Color successMint = Color(0xFF20C99A);

  // --- Tertiary Status Colors ---

  /// Sunrise Gold: Evening reminders, postponed items, preparation prompts.
  static const Color sunriseGold = Color(0xFFFFB52E);

  /// Cancel Coral: Cancelled goals, overdue markers, critical errors.
  /// Never used purely for decoration.
  static const Color cancelCoral = Color(0xFFF0525E);

  // --- Neutrals & Surfaces ---

  /// Morning Canvas: The crisp, cool-light app background.
  static const Color canvas = Color(0xFFF7FCFF);

  /// Clear Surface: Primary content cards, modals, sheets.
  static const Color surface = Color(0xFFFFFFFF);

  /// Cool Surface: Secondary control groups, inactive buttons, subtle containers.
  static const Color coolSurface = Color(0xFFEEF7FD);

  /// Muted Ink: Secondary descriptions, timestamps, metadata (>= 4.5:1 contrast).
  static const Color mutedInk = Color(0xFF6683A5);

  /// Divider Mist: 1px hairline dividers and subtle borders.
  static const Color dividerMist = Color(0xFFDCE9F3);

  // --- Tints & Translucent Backgrounds ---

  /// Soft Action Blue tint for selected chips and active badges.
  static const Color actionBlueTint = Color(0x1F168AF2);

  /// Soft Progress Teal tint for completed task items.
  static const Color progressTealTint = Color(0x1F0EB8AC);

  /// Soft Sunrise Gold tint for reminder banners and postponed chips.
  static const Color sunriseGoldTint = Color(0x2EFFB52E);

  /// Soft Cancel Coral tint for cancelled chips and error warnings.
  static const Color cancelCoralTint = Color(0x1FF0525E);

  /// Soft Brand Navy tint for category icons and subtle containers.
  static const Color brandNavyTint = Color(0x140A3768);

  // --- Gradients ---

  /// Signature Hero Card Gradient: Action Blue -> Sky Cyan -> Progress Teal.
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF168AF2), Color(0xFF22B4E6), Color(0xFF0EB8AC)],
  );

  /// Morning Sky Gradient for illustrations and empty states.
  static const LinearGradient morningSkyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE8F6FD), Color(0xFFD6F0FA)],
  );

  /// Sunrise banner gentle background gradient.
  static const LinearGradient reminderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF9EE), Color(0xFFFFF2D6)],
  );

  /// Logo app icon background gradient.
  static const LinearGradient appIconGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF38B8F8), Color(0xFF0EB8AC)],
  );

  // --- Elevation & Shadows ---

  /// Ambient Low: Soft ambient shadow for floating bottom navigation and panels.
  /// 0 4px 8px rgba(28, 91, 132, 0.10)
  static const List<BoxShadow> ambientLow = [
    BoxShadow(
      color: Color(0x1A1C5B84),
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  /// Focus Halo: Accessibility focus ring for keyboard navigation or switch control.
  /// 0 0 0 3px rgba(22, 138, 242, 0.24)
  static const List<BoxShadow> focusHalo = [
    BoxShadow(
      color: Color(0x3D168AF2),
      offset: Offset.zero,
      blurRadius: 0,
      spreadRadius: 3,
    ),
  ];
}

/// Theme extension for ADay custom colors to support Theme.of(context).extension.
class ADayColorsExtension extends ThemeExtension<ADayColorsExtension> {
  const ADayColorsExtension({
    this.brandNavy = ADayColors.brandNavy,
    this.actionBlue = ADayColors.actionBlue,
    this.skyCyan = ADayColors.skyCyan,
    this.progressTeal = ADayColors.progressTeal,
    this.successMint = ADayColors.successMint,
    this.sunriseGold = ADayColors.sunriseGold,
    this.cancelCoral = ADayColors.cancelCoral,
    this.canvas = ADayColors.canvas,
    this.surface = ADayColors.surface,
    this.coolSurface = ADayColors.coolSurface,
    this.mutedInk = ADayColors.mutedInk,
    this.dividerMist = ADayColors.dividerMist,
  });

  final Color brandNavy;
  final Color actionBlue;
  final Color skyCyan;
  final Color progressTeal;
  final Color successMint;
  final Color sunriseGold;
  final Color cancelCoral;
  final Color canvas;
  final Color surface;
  final Color coolSurface;
  final Color mutedInk;
  final Color dividerMist;

  @override
  ThemeExtension<ADayColorsExtension> copyWith({
    Color? brandNavy,
    Color? actionBlue,
    Color? skyCyan,
    Color? progressTeal,
    Color? successMint,
    Color? sunriseGold,
    Color? cancelCoral,
    Color? canvas,
    Color? surface,
    Color? coolSurface,
    Color? mutedInk,
    Color? dividerMist,
  }) {
    return ADayColorsExtension(
      brandNavy: brandNavy ?? this.brandNavy,
      actionBlue: actionBlue ?? this.actionBlue,
      skyCyan: skyCyan ?? this.skyCyan,
      progressTeal: progressTeal ?? this.progressTeal,
      successMint: successMint ?? this.successMint,
      sunriseGold: sunriseGold ?? this.sunriseGold,
      cancelCoral: cancelCoral ?? this.cancelCoral,
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      coolSurface: coolSurface ?? this.coolSurface,
      mutedInk: mutedInk ?? this.mutedInk,
      dividerMist: dividerMist ?? this.dividerMist,
    );
  }

  @override
  ThemeExtension<ADayColorsExtension> lerp(
    covariant ThemeExtension<ADayColorsExtension>? other,
    double t,
  ) {
    if (other is! ADayColorsExtension) {
      return this;
    }
    return ADayColorsExtension(
      brandNavy: Color.lerp(brandNavy, other.brandNavy, t) ?? brandNavy,
      actionBlue: Color.lerp(actionBlue, other.actionBlue, t) ?? actionBlue,
      skyCyan: Color.lerp(skyCyan, other.skyCyan, t) ?? skyCyan,
      progressTeal:
          Color.lerp(progressTeal, other.progressTeal, t) ?? progressTeal,
      successMint: Color.lerp(successMint, other.successMint, t) ?? successMint,
      sunriseGold: Color.lerp(sunriseGold, other.sunriseGold, t) ?? sunriseGold,
      cancelCoral: Color.lerp(cancelCoral, other.cancelCoral, t) ?? cancelCoral,
      canvas: Color.lerp(canvas, other.canvas, t) ?? canvas,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      coolSurface: Color.lerp(coolSurface, other.coolSurface, t) ?? coolSurface,
      mutedInk: Color.lerp(mutedInk, other.mutedInk, t) ?? mutedInk,
      dividerMist: Color.lerp(dividerMist, other.dividerMist, t) ?? dividerMist,
    );
  }
}
