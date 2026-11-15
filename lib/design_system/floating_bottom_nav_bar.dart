import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_typography.dart';

class FloatingBottomNavBar extends StatelessWidget {
  const FloatingBottomNavBar({
    required this.currentIndex,
    required this.items,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final List<NavBarItemData> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer.withOpacity(isDark ? 0.85 : 0.92),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.18),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Row(
              children: List.generate(items.length, (index) {
                final item = items[index];
                final selected = index == currentIndex;
                return Expanded(
                  child: Semantics(
                    button: true,
                    selected: selected,
                    label: item.label,
                    child: GestureDetector(
                      onTap: () => onTap(index),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        constraints: const BoxConstraints(minHeight: 48),
                        decoration: BoxDecoration(
                          color: selected
                              ? colorScheme.secondaryContainer
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item.icon,
                              color: selected
                                  ? colorScheme.onSecondaryContainer
                                  : colorScheme.onSurfaceVariant,
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.label.copyWith(
                                color: selected
                                    ? colorScheme.onSecondaryContainer
                                    : colorScheme.onSurfaceVariant,
                                fontSize: 11,
                                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class NavBarItemData {
  const NavBarItemData({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}
