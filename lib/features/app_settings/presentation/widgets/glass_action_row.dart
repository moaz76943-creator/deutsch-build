import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

final class GlassActionRow extends StatelessWidget {
  const GlassActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onPressed,
    this.destructive = false,
    this.busy = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback? onPressed;
  final bool destructive;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = destructive
        ? Theme.of(context).colorScheme.error
        : AppColors.primary;
    return AppGlassCard(
      borderColor:
          dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
      backgroundColor:
          dark ? AppColors.darkSurface : AppColors.lightSurface,
      glowColor: accent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(icon, color: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppDirectionalText(
                  title,
                  languageCode: 'ar',
                  style: AppTypography.title,
                ),
                const SizedBox(height: 4),
                AppDirectionalText(
                  subtitle,
                  languageCode: 'ar',
                  style: AppTypography.body,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (busy)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          else
            TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(foregroundColor: accent),
              child: AppDirectionalText(
                actionLabel,
                languageCode: 'ar',
                style: AppTypography.label.copyWith(color: accent),
              ),
            ),
        ],
      ),
    );
  }
}
