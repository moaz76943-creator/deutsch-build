import 'package:flutter/material.dart';

import '../../models/diagnostic_placement.dart';

class PlacementResultPanel extends StatelessWidget {
  const PlacementResultPanel({
    super.key,
    required this.result,
    required this.onClose,
  });

  final PlacementDiagnosticResult result;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Icon(
            Icons.assessment_outlined,
            size: 56,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'نتيجة التشخيص',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            _bandLabel(result.band),
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          _metric(context, 'الدقة', '${result.score.round()}%'),
          _metric(
              context, 'ثقة التشخيص', '${(result.confidence * 100).round()}%'),
          _metric(
            context,
            'إجابات محسوبة',
            '${result.scoredAnswers}/${result.answered}',
          ),
          const SizedBox(height: 14),
          Text(
            'تفصيل المهارات',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          ...DiagnosticDimension.values
              .where(result.dimensionScores.containsKey)
              .map(
                (dimension) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(child: Text(_dimensionLabel(dimension))),
                      Text(
                        '${((result.dimensionScores[dimension] ?? 0) * 100).round()}%',
                      ),
                    ],
                  ),
                ),
              ),
          if (result.weakDimensions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'الأولوية التالية: ${result.weakDimensions.map(_dimensionLabel).join(' • ')}',
            ),
          ],
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'هذه نقطة بداية تعليمية مبنية على عينة محلية متكيّفة، وليست شهادة CEFR.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: onClose, child: const Text('متابعة التعلم')),
        ],
      );

  Widget _metric(BuildContext context, String label, String value) => Card(
        child: ListTile(
          title: Text(label),
          trailing: Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
      );

  static String _bandLabel(DiagnosticPlacementBand band) => switch (band) {
        DiagnosticPlacementBand.foundation => 'نقطة بداية تأسيسية',
        DiagnosticPlacementBand.basic => 'أساسيات قيد التثبيت',
        DiagnosticPlacementBand.developing => 'قاعدة متطورة تحتاج توسيعًا',
        DiagnosticPlacementBand.strong => 'قاعدة قوية للتقدم',
      };

  static String _dimensionLabel(DiagnosticDimension dimension) =>
      switch (dimension) {
        DiagnosticDimension.meaning => 'المعنى والاستدعاء',
        DiagnosticDimension.grammar => 'القواعد',
        DiagnosticDimension.listening => 'الاستماع',
        DiagnosticDimension.transfer => 'النقل والترجمة',
        DiagnosticDimension.production => 'الإنتاج',
      };
}
