import 'package:flutter/material.dart';

/// Complete color palette for a specific ADay theme matching the 5 templates.
class ADayThemePalette {
  const ADayThemePalette({
    required this.id,
    required this.name,
    required this.isDark,
    required this.brandNavy,
    required this.actionBlue,
    required this.skyCyan,
    required this.progressTeal,
    required this.successMint,
    required this.sunriseGold,
    required this.cancelCoral,
    required this.canvas,
    required this.surface,
    required this.coolSurface,
    required this.mutedInk,
    required this.dividerMist,
    required this.actionBlueTint,
    required this.progressTealTint,
    required this.sunriseGoldTint,
    required this.cancelCoralTint,
    required this.brandNavyTint,
    required this.heroGradient,
    required this.morningSkyGradient,
    required this.reminderGradient,
    required this.appIconGradient,
    required this.ambientLow,
    required this.focusHalo,
  });

  final String id;
  final String name;
  final bool isDark;
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
  final Color actionBlueTint;
  final Color progressTealTint;
  final Color sunriseGoldTint;
  final Color cancelCoralTint;
  final Color brandNavyTint;
  final LinearGradient heroGradient;
  final LinearGradient morningSkyGradient;
  final LinearGradient reminderGradient;
  final LinearGradient appIconGradient;
  final List<BoxShadow> ambientLow;
  final List<BoxShadow> focusHalo;

  /// Default: Bình minh ADay (Sunrise Blue)
  static const defaultPalette = ADayThemePalette(
    id: 'default',
    name: 'Bình minh ADay',
    isDark: false,
    brandNavy: Color(0xFF0A3768),
    actionBlue: Color(0xFF168AF2),
    skyCyan: Color(0xFF27BCEB),
    progressTeal: Color(0xFF0EB8AC),
    successMint: Color(0xFF20C99A),
    sunriseGold: Color(0xFFFFB52E),
    cancelCoral: Color(0xFFF0525E),
    canvas: Color(0xFFF7FCFF),
    surface: Color(0xFFFFFFFF),
    coolSurface: Color(0xFFEEF7FD),
    mutedInk: Color(0xFF6683A5),
    dividerMist: Color(0xFFDCE9F3),
    actionBlueTint: Color(0x1F168AF2),
    progressTealTint: Color(0x1F0EB8AC),
    sunriseGoldTint: Color(0x2EFFB52E),
    cancelCoralTint: Color(0x1FF0525E),
    brandNavyTint: Color(0x140A3768),
    heroGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF168AF2), Color(0xFF22B4E6), Color(0xFF0EB8AC)],
    ),
    morningSkyGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFE8F6FD), Color(0xFFD6F0FA)],
    ),
    reminderGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFF9EE), Color(0xFFFFF2D6)],
    ),
    appIconGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF38B8F8), Color(0xFF0EB8AC)],
    ),
    ambientLow: [
      BoxShadow(
        color: Color(0x1A1C5B84),
        offset: Offset(0, 4),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ],
    focusHalo: [
      BoxShadow(
        color: Color(0x3D168AF2),
        offset: Offset.zero,
        blurRadius: 0,
        spreadRadius: 3,
      ),
    ],
  );

  /// Theme 1: Lavender Dream (1224c664...png)
  static const lavenderDream = ADayThemePalette(
    id: 'theme_1',
    name: 'Lavender Dream',
    isDark: false,
    brandNavy: Color(0xFF241442),
    actionBlue: Color(0xFF7C3AED),
    skyCyan: Color(0xFF885CF6),
    progressTeal: Color(0xFFA855F7),
    successMint: Color(0xFF22C55E),
    sunriseGold: Color(0xFFF59E0B),
    cancelCoral: Color(0xFFEF4444),
    canvas: Color(0xFFF9F6FF),
    surface: Color(0xFFFFFFFF),
    coolSurface: Color(0xFFEDE7FF),
    mutedInk: Color(0xFF6D5F8A),
    dividerMist: Color(0xFFE5DBFF),
    actionBlueTint: Color(0x247C3AED),
    progressTealTint: Color(0x24A855F7),
    sunriseGoldTint: Color(0x28F59E0B),
    cancelCoralTint: Color(0x24EF4444),
    brandNavyTint: Color(0x14241442),
    heroGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF885CF6), Color(0xFF7C3AED), Color(0xFF5B21B6)],
    ),
    morningSkyGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFF5EEFF), Color(0xFFEDE7FF)],
    ),
    reminderGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFAF5FF), Color(0xFFEDE7FF)],
    ),
    appIconGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFD084FE), Color(0xFF7C3AED)],
    ),
    ambientLow: [
      BoxShadow(
        color: Color(0x1F4C1D95),
        offset: Offset(0, 4),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ],
    focusHalo: [
      BoxShadow(
        color: Color(0x3D7C3AED),
        offset: Offset.zero,
        blurRadius: 0,
        spreadRadius: 3,
      ),
    ],
  );

  /// Theme 2: Sunset Peach (5cd0c0f3...png)
  static const sunsetPeach = ADayThemePalette(
    id: 'theme_2',
    name: 'Sunset Peach',
    isDark: false,
    brandNavy: Color(0xFF3D1C06),
    actionBlue: Color(0xFFF97316),
    skyCyan: Color(0xFFFB923C),
    progressTeal: Color(0xFFEA580C),
    successMint: Color(0xFF10B981),
    sunriseGold: Color(0xFFF59E0B),
    cancelCoral: Color(0xFFEF4444),
    canvas: Color(0xFFFFF8F4),
    surface: Color(0xFFFFFFFF),
    coolSurface: Color(0xFFFFEDE2),
    mutedInk: Color(0xFF8C644E),
    dividerMist: Color(0xFFFED7AA),
    actionBlueTint: Color(0x26F97316),
    progressTealTint: Color(0x26EA580C),
    sunriseGoldTint: Color(0x26F59E0B),
    cancelCoralTint: Color(0x26EF4444),
    brandNavyTint: Color(0x143D1C06),
    heroGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFB923C), Color(0xFFF97316), Color(0xFFEA580C)],
    ),
    morningSkyGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
    ),
    reminderGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
    ),
    appIconGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFDBA74), Color(0xFFEA580C)],
    ),
    ambientLow: [
      BoxShadow(
        color: Color(0x1F9A3412),
        offset: Offset(0, 4),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ],
    focusHalo: [
      BoxShadow(
        color: Color(0x3DF97316),
        offset: Offset.zero,
        blurRadius: 0,
        spreadRadius: 3,
      ),
    ],
  );

  /// Theme 3: Midnight Indigo (7c918954...png) - Dark Mode!
  static const midnightIndigo = ADayThemePalette(
    id: 'theme_3',
    name: 'Midnight Indigo',
    isDark: true,
    brandNavy: Color(0xFFF1F5F9),
    actionBlue: Color(0xFF38BDF8),
    skyCyan: Color(0xFF06B6D4),
    progressTeal: Color(0xFF22D3EE),
    successMint: Color(0xFF34D399),
    sunriseGold: Color(0xFFFBBF24),
    cancelCoral: Color(0xFFF87171),
    canvas: Color(0xFF0B1220),
    surface: Color(0xFF131E33),
    coolSurface: Color(0xFF1E293B),
    mutedInk: Color(0xFF94A3B8),
    dividerMist: Color(0xFF27354A),
    actionBlueTint: Color(0x3838BDF8),
    progressTealTint: Color(0x3822D3EE),
    sunriseGoldTint: Color(0x38FBBF24),
    cancelCoralTint: Color(0x38F87171),
    brandNavyTint: Color(0x29F1F5F9),
    heroGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1E3A8A), Color(0xFF1D4ED8), Color(0xFF06B6D4)],
    ),
    morningSkyGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF131E33), Color(0xFF0B1220)],
    ),
    reminderGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1E293B), Color(0xFF131E33)],
    ),
    appIconGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF818CF8), Color(0xFF06B6D4)],
    ),
    ambientLow: [
      BoxShadow(
        color: Color(0x40000000),
        offset: Offset(0, 4),
        blurRadius: 10,
        spreadRadius: 0,
      ),
    ],
    focusHalo: [
      BoxShadow(
        color: Color(0x5238BDF8),
        offset: Offset.zero,
        blurRadius: 0,
        spreadRadius: 3,
      ),
    ],
  );

  /// Theme 4: Rose Blush (7fa13b9e...png)
  static const roseBlush = ADayThemePalette(
    id: 'theme_4',
    name: 'Rose Blush',
    isDark: false,
    brandNavy: Color(0xFF460D27),
    actionBlue: Color(0xFFE11D48),
    skyCyan: Color(0xFFFB7185),
    progressTeal: Color(0xFFF43F5E),
    successMint: Color(0xFF10B981),
    sunriseGold: Color(0xFFF59E0B),
    cancelCoral: Color(0xFFE11D48),
    canvas: Color(0xFFFFF5F7),
    surface: Color(0xFFFFFFFF),
    coolSurface: Color(0xFFFDE7EA),
    mutedInk: Color(0xFF885B6D),
    dividerMist: Color(0xFFFCE7F3),
    actionBlueTint: Color(0x26E11D48),
    progressTealTint: Color(0x26F43F5E),
    sunriseGoldTint: Color(0x26F59E0B),
    cancelCoralTint: Color(0x26E11D48),
    brandNavyTint: Color(0x14460D27),
    heroGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF472B6), Color(0xFFE11D48), Color(0xFF9D174D)],
    ),
    morningSkyGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFFF1F2), Color(0xFFFDE7EA)],
    ),
    reminderGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFF1F2), Color(0xFFFCE7F3)],
    ),
    appIconGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFF884C2), Color(0xFF881E4D)],
    ),
    ambientLow: [
      BoxShadow(
        color: Color(0x1F881E4D),
        offset: Offset(0, 4),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ],
    focusHalo: [
      BoxShadow(
        color: Color(0x3DE11D48),
        offset: Offset.zero,
        blurRadius: 0,
        spreadRadius: 3,
      ),
    ],
  );

  /// Theme 5: Forest Sage (e060c34f...png)
  static const forestSage = ADayThemePalette(
    id: 'theme_5',
    name: 'Forest Sage',
    isDark: false,
    brandNavy: Color(0xFF123524),
    actionBlue: Color(0xFF2E7D57),
    skyCyan: Color(0xFF7FB069),
    progressTeal: Color(0xFF185E3F),
    successMint: Color(0xFF10B981),
    sunriseGold: Color(0xFFF59E0B),
    cancelCoral: Color(0xFFEF4444),
    canvas: Color(0xFFF6FAF7),
    surface: Color(0xFFFFFFFF),
    coolSurface: Color(0xFFD8EAD7),
    mutedInk: Color(0xFF4A6B59),
    dividerMist: Color(0xFFC7E2C6),
    actionBlueTint: Color(0x262E7D57),
    progressTealTint: Color(0x26185E3F),
    sunriseGoldTint: Color(0x26F59E0B),
    cancelCoralTint: Color(0x26EF4444),
    brandNavyTint: Color(0x14123524),
    heroGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF2E7D57), Color(0xFF185E3F), Color(0xFF144D33)],
    ),
    morningSkyGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFF1F8F3), Color(0xFFD8EAD7)],
    ),
    reminderGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF8F7EE), Color(0xFFE8F2E8)],
    ),
    appIconGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF7FB069), Color(0xFF185E3F)],
    ),
    ambientLow: [
      BoxShadow(
        color: Color(0x1F185E3F),
        offset: Offset(0, 4),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ],
    focusHalo: [
      BoxShadow(
        color: Color(0x3D2E7D57),
        offset: Offset.zero,
        blurRadius: 0,
        spreadRadius: 3,
      ),
    ],
  );

  static ADayThemePalette forId(String id) => switch (id) {
    'theme_1' => lavenderDream,
    'theme_2' => sunsetPeach,
    'theme_3' => midnightIndigo,
    'theme_4' => roseBlush,
    'theme_5' => forestSage,
    _ => defaultPalette,
  };
}

/// Dynamic design tokens for ADay. Automatically updates when active theme changes.
abstract class ADayColors {
  static ADayThemePalette _current = ADayThemePalette.defaultPalette;
  static ADayThemePalette get current => _current;

  static void applyTheme(String themeId) {
    _current = ADayThemePalette.forId(themeId);
  }

  // --- Primary Brand Colors ---
  static Color get brandNavy => _current.brandNavy;
  static Color get actionBlue => _current.actionBlue;

  // --- Secondary Accents ---
  static Color get skyCyan => _current.skyCyan;
  static Color get progressTeal => _current.progressTeal;
  static Color get successMint => _current.successMint;

  // --- Tertiary Status Colors ---
  static Color get sunriseGold => _current.sunriseGold;
  static Color get cancelCoral => _current.cancelCoral;

  // --- Neutrals & Surfaces ---
  static Color get canvas => _current.canvas;
  static Color get surface => _current.surface;
  static Color get coolSurface => _current.coolSurface;
  static Color get mutedInk => _current.mutedInk;
  static Color get dividerMist => _current.dividerMist;

  // --- Tints & Translucent Backgrounds ---
  static Color get actionBlueTint => _current.actionBlueTint;
  static Color get progressTealTint => _current.progressTealTint;
  static Color get sunriseGoldTint => _current.sunriseGoldTint;
  static Color get cancelCoralTint => _current.cancelCoralTint;
  static Color get brandNavyTint => _current.brandNavyTint;

  // --- Gradients ---
  static LinearGradient get heroGradient => _current.heroGradient;
  static LinearGradient get morningSkyGradient => _current.morningSkyGradient;
  static LinearGradient get reminderGradient => _current.reminderGradient;
  static LinearGradient get appIconGradient => _current.appIconGradient;

  // --- Elevation & Shadows ---
  static List<BoxShadow> get ambientLow => _current.ambientLow;
  static List<BoxShadow> get focusHalo => _current.focusHalo;

  // Compile-time fallbacks for const contexts
  static const Color defaultBrandNavy = Color(0xFF0A3768);
  static const Color defaultActionBlue = Color(0xFF168AF2);
  static const Color defaultCanvas = Color(0xFFF7FCFF);
  static const Color defaultSurface = Color(0xFFFFFFFF);
  static const Color defaultDividerMist = Color(0xFFDCE9F3);
}

/// Theme extension for ADay custom colors to support Theme.of(context).extension.
class ADayColorsExtension extends ThemeExtension<ADayColorsExtension> {
  const ADayColorsExtension({
    this.brandNavy = ADayColors.defaultBrandNavy,
    this.actionBlue = ADayColors.defaultActionBlue,
    this.skyCyan = const Color(0xFF27BCEB),
    this.progressTeal = const Color(0xFF0EB8AC),
    this.successMint = const Color(0xFF20C99A),
    this.sunriseGold = const Color(0xFFFFB52E),
    this.cancelCoral = const Color(0xFFF0525E),
    this.canvas = ADayColors.defaultCanvas,
    this.surface = ADayColors.defaultSurface,
    this.coolSurface = const Color(0xFFEEF7FD),
    this.mutedInk = const Color(0xFF6683A5),
    this.dividerMist = ADayColors.defaultDividerMist,
  });

  factory ADayColorsExtension.fromPalette(ADayThemePalette palette) {
    return ADayColorsExtension(
      brandNavy: palette.brandNavy,
      actionBlue: palette.actionBlue,
      skyCyan: palette.skyCyan,
      progressTeal: palette.progressTeal,
      successMint: palette.successMint,
      sunriseGold: palette.sunriseGold,
      cancelCoral: palette.cancelCoral,
      canvas: palette.canvas,
      surface: palette.surface,
      coolSurface: palette.coolSurface,
      mutedInk: palette.mutedInk,
      dividerMist: palette.dividerMist,
    );
  }

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
