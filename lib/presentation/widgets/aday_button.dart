import 'package:flutter/material.dart';

import '../../core/theme/aday_colors.dart';
import '../../core/theme/aday_spacing.dart';
import '../../core/theme/aday_typography.dart';

enum ADayButtonVariant { primary, secondary, destructive, ghost }

/// Accessible action button matching the ADay design specification.
///
/// Features:
/// - Primary: Action Blue with white text, 52px default height, 12px corner radius
/// - Secondary: Cool Surface with Action Blue text
/// - Destructive: Tinted Cancel Coral with Coral text
/// - WCAG 2.2 AA compliant minimum 44x44 touch target
/// - Focus Halo support for keyboard & assistive device navigation
/// - Built-in loading indicator that preserves button dimensions
class ADayButton extends StatefulWidget {
  const ADayButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ADayButtonVariant.primary,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.height = ADaySpacing.buttonHeight,
    this.width,
    this.padding,
    this.semanticsLabel,
  });

  /// Factory constructor for the standard Primary button (Action Blue, 52px).
  const factory ADayButton.primary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    IconData? trailingIcon,
    bool isLoading,
    double height,
    double? width,
    EdgeInsetsGeometry? padding,
    String? semanticsLabel,
  }) = _ADayPrimaryButton;

  /// Factory constructor for the Secondary button (Cool Surface, Action Blue text).
  const factory ADayButton.secondary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    IconData? trailingIcon,
    bool isLoading,
    double height,
    double? width,
    EdgeInsetsGeometry? padding,
    String? semanticsLabel,
  }) = _ADaySecondaryButton;

  /// Factory constructor for Destructive actions (Cancel Coral).
  const factory ADayButton.destructive({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    IconData? trailingIcon,
    bool isLoading,
    double height,
    double? width,
    EdgeInsetsGeometry? padding,
    String? semanticsLabel,
  }) = _ADayDestructiveButton;

  final String label;
  final VoidCallback? onPressed;
  final ADayButtonVariant variant;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isLoading;
  final double height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final String? semanticsLabel;

  @override
  State<ADayButton> createState() => _ADayButtonState();
}

class _ADayButtonState extends State<ADayButton> {
  bool _isFocused = false;

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  (Color bg, Color fg, Color border) _resolveColors() {
    switch (widget.variant) {
      case ADayButtonVariant.primary:
        return (
          _isEnabled
              ? ADayColors.actionBlue
              : ADayColors.actionBlue.withValues(alpha: 0.45),
          ADayColors.surface,
          Colors.transparent,
        );
      case ADayButtonVariant.secondary:
        return (
          _isEnabled
              ? ADayColors.coolSurface
              : ADayColors.coolSurface.withValues(alpha: 0.6),
          _isEnabled ? ADayColors.actionBlue : ADayColors.mutedInk,
          Colors.transparent,
        );
      case ADayButtonVariant.destructive:
        return (
          _isEnabled ? ADayColors.cancelCoralTint : ADayColors.coolSurface,
          _isEnabled ? ADayColors.cancelCoral : ADayColors.mutedInk,
          _isEnabled
              ? ADayColors.cancelCoral.withValues(alpha: 0.3)
              : Colors.transparent,
        );
      case ADayButtonVariant.ghost:
        return (
          Colors.transparent,
          _isEnabled ? ADayColors.actionBlue : ADayColors.mutedInk,
          Colors.transparent,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors();
    final effectiveHeight = widget.height.clamp(
      ADaySpacing.minTouchTarget,
      64.0,
    );

    return Semantics(
      button: true,
      enabled: _isEnabled,
      label: widget.semanticsLabel ?? widget.label,
      child: FocusableActionDetector(
        onShowFocusHighlight: (hasHighlight) {
          setState(() {
            _isFocused = hasHighlight;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: ADaySpacing.controlRadius,
            boxShadow: _isFocused ? ADayColors.focusHalo : null,
          ),
          child: Material(
            color: colors.$1,
            shape: RoundedRectangleBorder(
              borderRadius: ADaySpacing.controlRadius,
              side: colors.$3 != Colors.transparent
                  ? BorderSide(color: colors.$3, width: 1.0)
                  : BorderSide.none,
            ),
            child: InkWell(
              onTap: _isEnabled ? widget.onPressed : null,
              borderRadius: ADaySpacing.controlRadius,
              splashColor: colors.$2.withValues(alpha: 0.15),
              highlightColor: colors.$2.withValues(alpha: 0.08),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: widget.width ?? ADaySpacing.minTouchTarget,
                  minHeight: effectiveHeight,
                  maxWidth: widget.width ?? double.infinity,
                ),
                child: Padding(
                  padding:
                      widget.padding ??
                      (widget.variant == ADayButtonVariant.primary
                          ? ADaySpacing.paddingButtonPrimary
                          : ADaySpacing.paddingButtonSecondary),
                  child: Center(
                    child: widget.isLoading
                        ? SizedBox(
                            width: 20.0,
                            height: 20.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colors.$2,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (widget.icon != null) ...[
                                Icon(widget.icon, size: 18.0, color: colors.$2),
                                const SizedBox(width: ADaySpacing.xs + 2),
                              ],
                              Flexible(
                                child: Text(
                                  widget.label,
                                  textAlign: TextAlign.center,
                                  style: ADayTypography.label.copyWith(
                                    color: colors.$2,
                                    fontSize: widget.height >= 50.0
                                        ? 15.0
                                        : 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (widget.trailingIcon != null) ...[
                                const SizedBox(width: ADaySpacing.xs + 2),
                                Icon(
                                  widget.trailingIcon,
                                  size: 18.0,
                                  color: colors.$2,
                                ),
                              ],
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ADayPrimaryButton extends ADayButton {
  const _ADayPrimaryButton({
    super.key,
    required super.label,
    required super.onPressed,
    super.icon,
    super.trailingIcon,
    super.isLoading,
    super.height,
    super.width,
    super.padding,
    super.semanticsLabel,
  }) : super(variant: ADayButtonVariant.primary);
}

class _ADaySecondaryButton extends ADayButton {
  const _ADaySecondaryButton({
    super.key,
    required super.label,
    required super.onPressed,
    super.icon,
    super.trailingIcon,
    super.isLoading,
    super.height,
    super.width,
    super.padding,
    super.semanticsLabel,
  }) : super(variant: ADayButtonVariant.secondary);
}

class _ADayDestructiveButton extends ADayButton {
  const _ADayDestructiveButton({
    super.key,
    required super.label,
    required super.onPressed,
    super.icon,
    super.trailingIcon,
    super.isLoading,
    super.height,
    super.width,
    super.padding,
    super.semanticsLabel,
  }) : super(variant: ADayButtonVariant.destructive);
}
