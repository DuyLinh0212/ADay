import 'package:flutter/material.dart';

import '../../core/theme/aday_colors.dart';
import '../../core/theme/aday_spacing.dart';
import '../../core/theme/aday_typography.dart';

/// Reusable section container matching the ADay design specification.
///
/// Principles:
/// - Single unified surface layer with 16px corner radius (strictly <= 16px)
/// - Flat by default with 1px Divider Mist border
/// - Avoids card-in-card anti-pattern
/// - Header icon badge, title, and accessible action trigger
/// - Flexible child slots for lists, grids, or custom layouts
class SectionSurface extends StatelessWidget {
  const SectionSurface({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    this.actionLabel = 'Xem tất cả',
    this.onActionTap,
    this.headerTrailing,
    this.padding = EdgeInsets.zero,
    this.contentPadding,
  });

  final String title;
  final Widget child;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final Widget? headerTrailing;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ADayColors.surface,
        borderRadius: ADaySpacing.surfaceRadius,
        border: Border.all(color: ADayColors.dividerMist, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- Section Header ---
            Semantics(
              header: true,
              label: 'Mục: $title',
              child: Padding(
                padding: const EdgeInsets.only(
                  left: ADaySpacing.md,
                  right: ADaySpacing.sm,
                  top: ADaySpacing.md - 2,
                  bottom: ADaySpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon + Title
                    Expanded(
                      child: Row(
                        children: [
                          if (icon != null) ...[
                            Container(
                              width: 34.0,
                              height: 34.0,
                              decoration: BoxDecoration(
                                color: iconBackgroundColor ??
                                    ADayColors.progressTealTint,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Center(
                                child: Icon(
                                  icon,
                                  color: iconColor ?? ADayColors.progressTeal,
                                  size: 18.0,
                                ),
                              ),
                            ),
                            const SizedBox(width: ADaySpacing.sm),
                          ],
                          Flexible(
                            child: Text(
                              title,
                              style: ADayTypography.title.copyWith(
                                fontSize: 18.0,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Trailing action or custom widget
                    if (headerTrailing != null)
                      headerTrailing!
                    else if (onActionTap != null && actionLabel != null)
                      Semantics(
                        button: true,
                        label: '$actionLabel cho $title',
                        child: InkWell(
                          onTap: onActionTap,
                          borderRadius: ADaySpacing.controlRadius,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              minWidth: ADaySpacing.minTouchTarget,
                              minHeight: ADaySpacing.minTouchTarget,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: ADaySpacing.xs + 2,
                                vertical: ADaySpacing.xs,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    actionLabel!,
                                    style: TextStyle(
                                      fontFamily: ADayTypography.fontFamily,
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w600,
                                      color: ADayColors.actionBlue,
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
                      ),
                  ],
                ),
              ),
            ),

            // Subtle divider below header
            Divider(
              height: 1.0,
              thickness: 1.0,
              color: ADayColors.dividerMist,
            ),

            // --- Body Content ---
            Padding(padding: contentPadding ?? EdgeInsets.zero, child: child),
          ],
        ),
      ),
    );
  }
}
