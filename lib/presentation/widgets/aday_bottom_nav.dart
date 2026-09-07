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
    this.items = NavigationItemData.defaultItems,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavigationItemData> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
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
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;

              return Expanded(
                child: _BottomNavItem(
                  data: item,
                  isSelected: isSelected,
                  index: index,
                  totalItems: items.length,
                  onTap: () => onTap(index),
                ),
              );
            }),
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
