import 'package:flutter/material.dart';

import '../../core/text/directional_text.dart';
import '../../models/content.dart';
import '../../models/linguistics/german_word_family.dart';
import '../shared/text/bidi_text.dart';

class WordFamilyCard extends StatelessWidget {
  const WordFamilyCard({
    super.key,
    required this.family,
    required this.contentById,
    required this.learnedIds,
  });

  final GermanWordFamily family;
  final Map<String, ContentItem> contentById;
  final Set<String> learnedIds;

  @override
  Widget build(BuildContext context) {
    final base = family.baseMember;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.account_tree_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: BidiText(
                    DirectionalText.german(
                      base?.concept.lemma ?? family.familyId,
                      semanticRole: LinguisticSemanticRole.word,
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                Text('${family.members.length}'),
              ],
            ),
            if (family.hasInterferenceRisk) ...[
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 18),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'يوجد عنصر متشابه قد يسبب تداخلًا؛ راجع المعنى قبل الربط.',
                    ),
                  ),
                ],
              ),
            ],
            const Divider(height: 24),
            ...family.members.map((member) => _memberRow(context, member)),
          ],
        ),
      ),
    );
  }

  Widget _memberRow(BuildContext context, GermanWordFamilyMember member) {
    final content = contentById[member.concept.id];
    final article = content?.article.trim() ?? '';
    final german = article.isEmpty
        ? member.concept.lemma
        : article + ' ' + member.concept.lemma;
    final learned = learnedIds.contains(member.concept.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (learned)
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(Icons.check_circle_outline, size: 18),
                    ),
                  Expanded(
                    child: BidiText(
                      DirectionalText.german(
                        german,
                        semanticRole: LinguisticSemanticRole.word,
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              if ((content?.arabic.trim() ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                BidiText(
                  DirectionalText.arabic(
                    content!.arabic,
                    semanticRole: LinguisticSemanticRole.translation,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _chip(_relationLabel(member.relationType)),
                  _chip(member.pedagogicalLevel.wireName),
                  _chip(_distanceLabel(member.semanticDistance)),
                  if (member.prefix != null) _chip('Prefix: ${member.prefix}'),
                  if (member.suffix != null) _chip('Suffix: ${member.suffix}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label) =>
      Chip(visualDensity: VisualDensity.compact, label: Text(label));

  String _relationLabel(GermanWordFamilyRelationType relation) =>
      switch (relation) {
        GermanWordFamilyRelationType.base => 'الأساس',
        GermanWordFamilyRelationType.agentNoun => 'اسم الفاعل',
        GermanWordFamilyRelationType.eventNoun => 'اسم حدث',
        GermanWordFamilyRelationType.derivedNoun => 'اسم مشتق',
        GermanWordFamilyRelationType.derivedAdjective => 'صفة مشتقة',
        GermanWordFamilyRelationType.prefixedVerb => 'فعل ببادئة',
        GermanWordFamilyRelationType.compound => 'مركب',
        GermanWordFamilyRelationType.semanticRelative => 'قريب دلاليًا',
        GermanWordFamilyRelationType.historicalRelative => 'قرابة تاريخية',
        GermanWordFamilyRelationType.notPedagogicallyLinked =>
          'لا يربط تعليميًا',
        GermanWordFamilyRelationType.unknown => 'علاقة غير معروفة',
      };

  String _distanceLabel(GermanSemanticDistance distance) => switch (distance) {
        GermanSemanticDistance.low => 'قرب دلالي: منخفض',
        GermanSemanticDistance.medium => 'قرب دلالي: متوسط',
        GermanSemanticDistance.high => 'قرب دلالي: بعيد',
        GermanSemanticDistance.unknown => 'قرب دلالي: غير معروف',
      };
}
