import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/core/srs_facets.dart';
import 'package:deutsch_bilarabi/features/commute/commute_review_queue.dart';
import 'package:deutsch_bilarabi/models/content.dart';
import 'package:deutsch_bilarabi/models/learner.dart';

void main() {
  test(
    'selects only due meaning/listening cards with complete audio sequence',
    () {
      final now = DateTime.utc(2026, 10, 2, 16);
      const item = ContentItem(
        id: 'w0638',
        german: 'Staat',
        arabic: 'دولة',
        sentence: 'Der Staat unterstützt die Schule.',
        sentenceAr: 'الدولة تدعم المدرسة.',
        topic: 'society',
        skill: 'recall',
      );
      const incomplete = ContentItem(
        id: 'missing_example',
        german: 'Hallo',
        arabic: 'مرحبًا',
        sentence: '',
        sentenceAr: '',
        topic: 'daily',
        skill: 'recall',
      );

      final meaningKey = const ReviewFacetKey(
        conceptId: 'w0638',
        facetType: ReviewFacetType.meaningRecall,
      ).storageKey;
      final listeningKey = const ReviewFacetKey(
        conceptId: 'w0638',
        facetType: ReviewFacetType.listening,
      ).storageKey;
      final pronunciationKey = const ReviewFacetKey(
        conceptId: 'w0638',
        facetType: ReviewFacetType.pronunciation,
      ).storageKey;
      final incompleteKey = const ReviewFacetKey(
        conceptId: 'missing_example',
        facetType: ReviewFacetType.listening,
      ).storageKey;

      final state = LearnerState(
        reviewCards: <String, ReviewCard>{
          meaningKey: ReviewCard(
            itemId: item.id,
            facetType: ReviewFacetType.meaningRecall,
            dueAt: now.subtract(const Duration(minutes: 2)),
          ),
          listeningKey: ReviewCard(
            itemId: item.id,
            facetType: ReviewFacetType.listening,
            dueAt: now.subtract(const Duration(minutes: 1)),
          ),
          pronunciationKey: ReviewCard(
            itemId: item.id,
            facetType: ReviewFacetType.pronunciation,
            dueAt: now.subtract(const Duration(hours: 1)),
          ),
          incompleteKey: ReviewCard(
            itemId: incomplete.id,
            facetType: ReviewFacetType.listening,
            dueAt: now.subtract(const Duration(hours: 1)),
          ),
        },
        updatedAt: now,
      );

      final queue = CommuteReviewQueueBuilder<ContentItem>(const <ContentItem>[
        item,
        incomplete,
      ]).build(state, now: now);

      expect(queue, hasLength(2));
      expect(queue.map((entry) => entry.facetType), <ReviewFacetType>[
        ReviewFacetType.meaningRecall,
        ReviewFacetType.listening,
      ]);
    },
  );

  test('future cards are not exposed as pending commute reviews', () {
    final now = DateTime.utc(2026, 10, 2, 16);
    const item = ContentItem(
      id: 'w0638',
      german: 'Staat',
      arabic: 'دولة',
      sentence: 'Der Staat unterstützt die Schule.',
      sentenceAr: 'الدولة تدعم المدرسة.',
      topic: 'society',
      skill: 'recall',
    );
    final key = const ReviewFacetKey(
      conceptId: 'w0638',
      facetType: ReviewFacetType.listening,
    ).storageKey;
    final state = LearnerState(
      reviewCards: <String, ReviewCard>{
        key: ReviewCard(
          itemId: item.id,
          facetType: ReviewFacetType.listening,
          dueAt: now.add(const Duration(hours: 2)),
        ),
      },
      updatedAt: now,
    );

    expect(
      CommuteReviewQueueBuilder<ContentItem>(const <ContentItem>[item])
          .build(state, now: now),
      isEmpty,
    );
  });
}
