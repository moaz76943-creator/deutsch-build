import 'package:flutter/material.dart';

import '../../../../design_system/app_colors.dart';
import '../../../../design_system/app_glass_card.dart';
import '../../../../design_system/app_typography.dart';
import '../../domain/error_pattern_models.dart';

class GlassDiagnosticCard extends StatelessWidget {
  const GlassDiagnosticCard({required this.diagnostic, super.key});

  final BlindSpotDiagnostic diagnostic;

  @override
  Widget build(BuildContext context) {
    final accent = switch (diagnostic.severity) {
      DiagnosticSeverity.high => AppColors.tertiary,
      DiagnosticSeverity.moderate => AppColors.achievement,
      DiagnosticSeverity.low => AppColors.secondary,
    };
    return AppGlassCard(
      glowColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  diagnostic.type.labelAr,
                  style: AppTypography.title,
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: accent.withAlpha(24),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: accent.withAlpha(90)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  child: Text(
                    diagnostic.severity.labelAr,
                    style: AppTypography.label.copyWith(color: accent),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'التكرار: ${diagnostic.count} · النسبة: ${(diagnostic.frequency * 100).round()}%',
            style: AppTypography.label,
          ),
          if (diagnostic.focus.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              'التركيز الحالي: ${diagnostic.focus}',
              style: AppTypography.body,
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'التصحيح العملي',
            style: AppTypography.label.copyWith(color: accent),
          ),
          const SizedBox(height: 5),
          _ComparisonRow(
            label: 'الشائع',
            value: diagnostic.commonActual.isEmpty
                ? '—'
                : diagnostic.commonActual,
            icon: Icons.close_rounded,
            color: AppColors.tertiary,
          ),
          const SizedBox(height: 6),
          _ComparisonRow(
            label: 'الصحيح',
            value: diagnostic.expectedExample.isEmpty
                ? '—'
                : diagnostic.expectedExample,
            icon: Icons.check_rounded,
            color: AppColors.mastery,
          ),
          const SizedBox(height: 12),
          Text(diagnostic.recommendationAr, style: AppTypography.body),
        ],
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 7),
          SizedBox(
            width: 54,
            child: Text(label, style: AppTypography.label),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              textDirection: TextDirection.ltr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      );
}
