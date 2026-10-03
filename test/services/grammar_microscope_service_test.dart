import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/core/srs_facets.dart';
import 'package:deutsch_bilarabi/models/content.dart';
import 'package:deutsch_bilarabi/models/grammar_microscope.dart';
import 'package:deutsch_bilarabi/models/learner.dart';
import 'package:deutsch_bilarabi/services/grammar_hub_service.dart';
import 'package:deutsch_bilarabi/services/grammar_microscope_service.dart';

final class _GrammarRepository
    implements GrammarHubRepository, GrammarMicroscopeRepository {
  const _GrammarRepository();

  @override
  Future<List<GrammarTopic>> getTopicsByLevel(String level) async =>
      <GrammarTopic>[
        if (level == 'A1') (await getTopicDetail('a1_nominativ'))!,
      ];

  @override
  Future<GrammarTopic?> getTopicDetail(String topicId) async {
    if (topicId != 'a1_nominativ') return null;
    return GrammarTopic(
      id: topicId,
      level: 'A1',
      titleDe: 'Nominativ',
      titleAr: 'حالة الرفع',
      explanationMarkdown: 'شرح',
      orderIndex: 1,
    );
  }

  @override
  Future<List<GrammarRuleDetail>> getRulesForTopic(String topicId) async =>
      topicId == 'a1_nominativ'
      ? const <GrammarRuleDetail>[
          GrammarRuleDetail(
            id: 'a1_nominativ_articles',
            topicId: 'a1_nominativ',
            title: 'أدوات التعريف في حالة الرفع',
            explanationAr: 'شرح الأدوات',
            orderIndex: 1,
          ),
        ]
      : const <GrammarRuleDetail>[];

  @override
  Future<List<GrammarQuiz>> getQuizzesForTopic(String topicId) async =>
      const <GrammarQuiz>[];

  @override
  Future<void> saveTopicMastery(String topicId, bool mastered) async {}

  @override
  Future<void> close() async {}
}

void main() {
  test('microscope explains a grammar topic from facet-SRS evidence', () async {
    final now = DateTime(2026, 10, 2);
    final caseCard = ReviewCard(
      itemId: 'w1',
      facetType: ReviewFacetType.caseForm,
      failures: 2,
      lapses: 1,
      dueAt: now,
    );
    final unrelated = ReviewCard(
      itemId: 'w2',
      facetType: ReviewFacetType.listening,
      failures: 9,
      lapses: 4,
      dueAt: now,
    );
    final state = LearnerState(
      reviewCards: <String, ReviewCard>{
        caseCard.storageKey: caseCard,
        unrelated.storageKey: unrelated,
      },
      updatedAt: now,
    );
    const corpus = <ContentItem>[
      ContentItem(
        id: 'w1',
        german: 'der Mann',
        arabic: 'الرجل',
        sentence: 'Der Mann arbeitet.',
        sentenceAr: 'الرجل يعمل.',
        topic: 'people',
        skill: 'recall',
      ),
      ContentItem(
        id: 'w2',
        german: 'hören',
        arabic: 'يسمع',
        sentence: 'Ich höre.',
        sentenceAr: 'أنا أسمع.',
        topic: 'verbs',
        skill: 'listening',
      ),
    ];

    final snapshot = await GrammarMicroscopeService(const _GrammarRepository())
        .load(topicId: 'a1_nominativ', state: state, corpus: corpus);

    expect(snapshot, isNotNull);
    expect(snapshot!.rules, hasLength(1));
    expect(
      snapshot.linkedFacets,
      containsAll(<ReviewFacetType>[
        ReviewFacetType.gender,
        ReviewFacetType.caseForm,
      ]),
    );
    expect(snapshot.facetEvidence, hasLength(1));
    expect(snapshot.facetEvidence.single.facetType, ReviewFacetType.caseForm);
    expect(snapshot.facetEvidence.single.pressure, 5);
    expect(snapshot.weakItems, hasLength(1));
    expect(snapshot.weakItems.single.itemId, 'w1');
    expect(snapshot.weakItems.single.sourceText, 'der Mann');
    expect(state.reviewCards[caseCard.storageKey], same(caseCard));
  });

  test(
    'microscope does not invent evidence when SRS has no linked weakness',
    () async {
      final state = LearnerState(updatedAt: DateTime(2026, 10, 2));
      final snapshot =
          await GrammarMicroscopeService(const _GrammarRepository()).load(
            topicId: 'a1_nominativ',
            state: state,
            corpus: const <ContentItem>[],
          );

      expect(snapshot, isNotNull);
      expect(snapshot!.hasPersonalEvidence, isFalse);
      expect(snapshot.facetEvidence, isEmpty);
      expect(snapshot.weakItems, isEmpty);
    },
  );
}
