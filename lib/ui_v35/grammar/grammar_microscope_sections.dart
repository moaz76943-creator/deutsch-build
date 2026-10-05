import 'package:flutter/material.dart';

import '../../core/text/directional_text.dart';
import '../../design_system/app_audio_button.dart';
import '../../design_system/app_colors.dart';
import '../../design_system/app_glass_card.dart';
import '../../design_system/app_typography.dart';
import '../../models/grammar_microscope.dart';
import '../../services/grammar_microscope_service.dart';
import '../shared/text/bidi_text.dart';

class GrammarMicroscopeEvidenceSection extends StatelessWidget {
  const GrammarMicroscopeEvidenceSection({
    super.key,
    required this.snapshot,
  });

  final GrammarMicroscopeSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (!snapshot.hasPersonalEvidence) {
      return AppGlassCard(
        backgroundColor: scheme.surface,
        opacity: Theme.of(context).brightness == Brightness.dark ? .38 : .72,
        child: AppDirectionalText(
          'لا توجد إشارة ضعف محفوظة مرتبطة بهذه القاعدة بعد. '
          'يمكنك دراسة الشرح بدون افتراض وجود مشكلة لديك.',
          languageCode: 'ar',
          style: AppTypography.body,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppDirectionalText(
          'لماذا قد تكون هذه القاعدة مفيدة الآن؟',
          languageCode: 'ar',
          style: AppTypography.title,
        ),
        const SizedBox(height: 8),
        BidiText(
          DirectionalText.arabic(
            'هذه إشارات من بطاقات المراجعة حسب المهارة، وليست تشخيصًا '
            'بأن هذه القاعدة وحدها سببت الخطأ.',
            semanticRole: LinguisticSemanticRole.explanation,
          ),
          style: AppTypography.body,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: snapshot.facetEvidence
              .map(
                (evidence) => Chip(
                  avatar: const Icon(Icons.insights_outlined, size: 18),
                  label: AppDirectionalText(
                    '${_facetLabel(evidence.facetType)} • '
                    'ضغط ${evidence.pressure} • '
                    '${evidence.cardCount} بطاقات',
                    languageCode: 'ar',
                    style: AppTypography.label,
                  ),
                ),
              )
              .toList(growable: false),
        ),
        if (snapshot.weakItems.isNotEmpty) ...<Widget>[
          const SizedBox(height: 18),
          AppDirectionalText(
            'أمثلة من بطاقات تحتاج مراجعة',
            languageCode: 'ar',
            style: AppTypography.title.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 8),
          for (final item in snapshot.weakItems)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppGlassCard(
                backgroundColor: scheme.surface,
                opacity:
                    Theme.of(context).brightness == Brightness.dark ? .38 : .72,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AppDirectionalText(
                      item.sourceText,
                      languageCode: 'de',
                      style: AppTypography.title.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 4),
                    AppDirectionalText(
                      item.translationText,
                      languageCode: 'ar',
                      style: AppTypography.body,
                    ),
                    const SizedBox(height: 4),
                    AppDirectionalText(
                      '${_facetLabel(item.facetType)} • '
                      'أخطاء ${item.failures} • تعثرات ${item.lapses}',
                      languageCode: 'ar',
                      style: AppTypography.label.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
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
  const GrammarMicroscopeRulesSection({
    super.key,
    required this.snapshot,
    required this.onSpeakGerman,
  });

  final GrammarMicroscopeSnapshot snapshot;
  final void Function(String text, String conceptId) onSpeakGerman;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (snapshot.rules.isEmpty) {
      return AppGlassCard(
        backgroundColor: scheme.surface,
        opacity: Theme.of(context).brightness == Brightness.dark ? .38 : .72,
        child: AppDirectionalText(
          'تفاصيل القاعدة غير متاحة في مصدر القواعد النشط حاليًا.',
          languageCode: 'ar',
          style: AppTypography.body,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppDirectionalText(
          'تفكيك القاعدة',
          languageCode: 'ar',
          style: AppTypography.title,
        ),
        const SizedBox(height: 10),
        for (final rule in snapshot.rules)
          _GrammarRuleCard(
            rule: rule,
            onSpeakGerman: onSpeakGerman,
          ),
      ],
    );
  }
}

class _GrammarRuleCard extends StatelessWidget {
  const _GrammarRuleCard({
    required this.rule,
    required this.onSpeakGerman,
  });

  final GrammarRuleDetail rule;
  final void Function(String text, String conceptId) onSpeakGerman;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppGlassCard(
        backgroundColor: scheme.surface,
        opacity: Theme.of(context).brightness == Brightness.dark ? .38 : .72,
        glowColor: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            BidiText(
              _directional(
                rule.title,
                semanticRole: LinguisticSemanticRole.grammarLabel,
              ),
              style: AppTypography.title.copyWith(fontSize: 17),
            ),
            const SizedBox(height: 8),
            AppDirectionalText(
              rule.explanationAr,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            if (rule.table.isNotEmpty) ...<Widget>[
              const SizedBox(height: 14),
              for (final row in rule.table)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: <Widget>[
                      for (final cell in row)
                        DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: scheme.outlineVariant,
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
                              style: AppTypography.label,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
            if (rule.examples.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              AppDirectionalText(
                'أمثلة',
                languageCode: 'ar',
                style: AppTypography.label,
              ),
              const SizedBox(height: 6),
              for (var index = 0; index < rule.examples.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppGlassCard(
                    backgroundColor: scheme.surface,
                    opacity: .18,
                    borderColor: scheme.outlineVariant.withAlpha(90),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              AppDirectionalText(
                                rule.examples[index].german,
                                languageCode: 'de',
                                style: AppTypography.body.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              AppDirectionalText(
                                rule.examples[index].arabic,
                                languageCode: 'ar',
                                style: AppTypography.body,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        AppAudioButton(
                          onPressed: () => onSpeakGerman(
                            rule.examples[index].german,
                            'grammar.rule.${rule.id}.example.$index',
                          ),
                          semanticLabel: 'استمع إلى المثال الألماني',
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
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
