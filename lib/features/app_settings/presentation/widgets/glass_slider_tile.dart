import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

final class GlassSliderTile extends StatelessWidget {
  const GlassSliderTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.valueLabel,
    required this.minimum,
    required this.maximum,
    required this.divisions,
    required this.onChanged,
    this.icon = Icons.tune,
    super.key,
  });

  final String title;
  final String subtitle;
  final double value;
  final String valueLabel;
  final double minimum;
  final double maximum;
  final int divisions;
  final ValueChanged<double>? onChanged;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final border =
        dark ? AppColors.glassBorderDark : AppColors.glassBorderLight;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;

    return AppGlassCard(
      borderColor: border,
      backgroundColor: surface,
      glowColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, color: AppColors.primary),
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
              const SizedBox(width: 10),
              AppDirectionalText(
                valueLabel,
                languageCode: 'ar',
                style: AppTypography.label.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Slider(
            value: value.clamp(minimum, maximum).toDouble(),
            min: minimum,
            max: maximum,
            divisions: divisions,
            label: valueLabel,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
