import 'package:flutter/material.dart';

import '../../core/theme/aday_colors.dart';
import '../../core/theme/aday_spacing.dart';
import '../../core/theme/aday_typography.dart';
import '../models/navigation_item_data.dart';

/// Bottom navigation bar for ADay.
///
/// Implements the bottom navigation from TrangChu.png & DESIGN.md:
/// - Surface color with Ambient Low shadow (0 4px 8px rgba(28, 91, 132, 0.10))
/// - Top hairline divider (Divider Mist)
/// - 4 items: Trang chủ, Lịch, Thống kê, Hồ sơ
/// - Active tab: Action Blue with active filled icon and short horizontal indicator bar
/// - Inactive tab: Muted Ink with outlined icon
/// - Guaranteed WCAG 2.2 AA touch target minimum: 44x44 per item
class ADayBottomNav extends StatelessWidget {
  const ADayBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onCreateGoalTap,
    this.items = NavigationItemData.defaultItems,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onCreateGoalTap;
  final List<NavigationItemData> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ADayColors.surface,
        boxShadow: ADayColors.ambientLow,
        border: Border(
          top: BorderSide(color: ADayColors.dividerMist, width: 1.0),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: ADaySpacing.bottomNavHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (items.isNotEmpty)
                Expanded(
                  child: _BottomNavItem(
                    data: items[0],
                    isSelected: currentIndex == 0,
                    index: 0,
                    totalItems: items.length,
                    onTap: () => onTap(0),
                  ),
                ),
              if (items.length > 1)
                Expanded(
                  child: _BottomNavItem(
                    data: items[1],
                    isSelected: currentIndex == 1,
                    index: 1,
                    totalItems: items.length,
                    onTap: () => onTap(1),
                  ),
                ),
              // TikTok-style elevated center Create Goal button
              _TikTokCreateButton(onTap: onCreateGoalTap),
              if (items.length > 2)
                Expanded(
                  child: _BottomNavItem(
                    data: items[2],
                    isSelected: currentIndex == 2,
                    index: 2,
                    totalItems: items.length,
                    onTap: () => onTap(2),
                  ),
                ),
              if (items.length > 3)
                Expanded(
                  child: _BottomNavItem(
                    data: items[3],
                    isSelected: currentIndex == 3,
                    index: 3,
                    totalItems: items.length,
                    onTap: () => onTap(3),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.data,
    required this.isSelected,
    required this.index,
    required this.totalItems,
    required this.onTap,
  });

  final NavigationItemData data;
  final bool isSelected;
  final int index;
  final int totalItems;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? ADayColors.actionBlue : ADayColors.mutedInk;
    final icon = isSelected ? (data.activeIcon ?? data.icon) : data.icon;

    return Semantics(
      button: true,
      selected: isSelected,
      label:
          data.semanticsLabel ??
          '${data.label}, mục ${index + 1} trong $totalItems',
      child: InkWell(
        onTap: onTap,
        splashColor: ADayColors.coolSurface,
        highlightColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: ADaySpacing.minTouchTargetConstraints,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tab Icon
                Icon(icon, size: 24.0, color: color),

                const SizedBox(height: 3.0),

                // Tab Label
                Text(
                  data.label,
                  style: TextStyle(
                    fontFamily: ADayTypography.fontFamily,
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: color,
                    letterSpacing: -0.1,
                  ),
                ),

                const SizedBox(height: 4.0),

                // Active Tab Pill Indicator (Short blue line from TrangChu.png)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  width: isSelected ? 18.0 : 0.0,
                  height: 3.0,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ADayColors.actionBlue
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TikTokCreateButton extends StatefulWidget {
  const _TikTokCreateButton({this.onTap});
  final VoidCallback? onTap;

  @override
  State<_TikTokCreateButton> createState() => _TikTokCreateButtonState();
}

class _TikTokCreateButtonState extends State<_TikTokCreateButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final actionColor = ADayColors.actionBlue;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: 'Tạo mục tiêu mới',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 64.0,
          height: ADaySpacing.bottomNavHeight,
          alignment: Alignment.center,
          child: AnimatedScale(
            scale: _pressed ? 0.90 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutCubic,
            child: Transform.translate(
              offset: const Offset(0, -6),
              child: SizedBox(
                width: 48.0,
                height: 34.0,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Left cyan/teal accent strip (TikTok signature layer style)
                    Positioned(
                      left: -2,
                      top: 1,
                      bottom: 1,
                      width: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          color: ADayColors.skyCyan,
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                      ),
                    ),
                    // Right coral/rose accent strip (TikTok signature layer style)
                    Positioned(
                      right: -2,
                      top: 1,
                      bottom: 1,
                      width: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          color: ADayColors.cancelCoral,
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                      ),
                    ),
                    // Center prominent main container
                    Container(
                      width: 48.0,
                      height: 34.0,
                      decoration: BoxDecoration(
                        gradient: ADayColors.heroGradient,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: isDark ? const Color(0xFF131E33) : Colors.white,
                          width: 1.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: actionColor.withValues(alpha: isDark ? 0.5 : 0.28),
                            offset: const Offset(0, 3),
                            blurRadius: 6,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 24.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

