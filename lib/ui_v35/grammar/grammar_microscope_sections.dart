import 'package:flutter/material.dart';

import '../../core/text/directional_text.dart';
import '../../models/grammar_microscope.dart';
import '../../services/grammar_microscope_service.dart';
import '../shared/text/bidi_text.dart';

class GrammarMicroscopeEvidenceSection extends StatelessWidget {
  const GrammarMicroscopeEvidenceSection({super.key, required this.snapshot});

  final GrammarMicroscopeSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (!snapshot.hasPersonalEvidence) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'لا توجد إشارة ضعف محفوظة مرتبطة بهذه القاعدة بعد. '
            'يمكنك دراسة الشرح بدون افتراض وجود مشكلة لديك.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'لماذا قد تكون هذه القاعدة مفيدة الآن؟',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'هذه إشارات من بطاقات المراجعة حسب المهارة، وليست تشخيصًا '
          'بأن هذه القاعدة وحدها سببت الخطأ.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: snapshot.facetEvidence
              .map(
                (evidence) => Chip(
                  avatar: const Icon(Icons.insights_outlined, size: 18),
                  label: Text(
                    '${_facetLabel(evidence.facetType)} • '
                    'ضغط ${evidence.pressure} • '
                    '${evidence.cardCount} بطاقات',
                  ),
                ),
              )
              .toList(growable: false),
        ),
        if (snapshot.weakItems.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(
            'أمثلة من بطاقات تحتاج مراجعة',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          for (final item in snapshot.weakItems)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: BidiText(
                  DirectionalText.german(
                    item.sourceText,
                    semanticRole: LinguisticSemanticRole.word,
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 4),
                    BidiText(
                      DirectionalText.arabic(
                        item.translationText,
                        semanticRole: LinguisticSemanticRole.translation,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_facetLabel(item.facetType)} • '
                      'أخطاء ${item.failures} • تعثرات ${item.lapses}',
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class GrammarMicroscopeRulesSection extends StatelessWidget {
  const GrammarMicroscopeRulesSection({super.key, required this.snapshot});

  final GrammarMicroscopeSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot.rules.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('تفاصيل القاعدة غير متاحة في مصدر القواعد النشط حاليًا.'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'تفكيك القاعدة',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        for (final rule in snapshot.rules) _GrammarRuleCard(rule: rule),
      ],
    );
  }
}

class _GrammarRuleCard extends StatelessWidget {
  const _GrammarRuleCard({required this.rule});

  final GrammarRuleDetail rule;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BidiText(
                _directional(
                  rule.title,
                  semanticRole: LinguisticSemanticRole.grammarLabel,
                ),
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              BidiText(
                DirectionalText.arabic(
                  rule.explanationAr,
                  semanticRole: LinguisticSemanticRole.explanation,
                ),
                style: const TextStyle(height: 1.5),
              ),
              if (rule.table.isNotEmpty) ...[
                const SizedBox(height: 14),
                for (final row in rule.table)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final cell in row)
                          DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              child: BidiText(
                                _directional(
                                  cell,
                                  semanticRole:
                                      LinguisticSemanticRole.grammarLabel,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
              if (rule.examples.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'أمثلة',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                for (final example in rule.examples)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        BidiText(
                          DirectionalText.german(
                            example.german,
                            semanticRole: LinguisticSemanticRole.example,
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        BidiText(
                          DirectionalText.arabic(
                            example.arabic,
                            semanticRole: LinguisticSemanticRole.translation,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      );
}

DirectionalText _directional(
  String text, {
  required LinguisticSemanticRole semanticRole,
}) =>
    DirectionalText.forLanguage(
      text,
      languageCode: RegExp(r'[\u0600-\u06FF]').hasMatch(text) ? 'ar' : 'de',
      semanticRole: semanticRole,
    );

String _facetLabel(Object facet) {
  final wire = facet.toString().split('.').last;
  return switch (wire) {
    'gender' => 'الجنس وأداة الاسم',
    'plural' => 'الجمع',
    'caseForm' => 'الحالة الإعرابية',
    'verbValency' => 'تعدية الفعل',
    'prepositionCase' => 'حرف الجر والحالة',
    'separablePrefix' => 'الفعل المنفصل',
    'auxiliary' => 'الفعل المساعد',
    'collocation' => 'التركيب الثابت',
    'production' => 'الإنتاج',
    _ => 'مهارة نحوية',
  };
}
