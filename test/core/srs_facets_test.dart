import 'package:deutsch_bilarabi/core/srs_facets.dart';
import 'package:deutsch_bilarabi/models/learner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 10, 2, 12);

  test('legacy review card is the meaning_recall facet without key churn', () {
    final card = ReviewCard(itemId: 'noun.tisch', dueAt: now);

    expect(card.facetType, ReviewFacetType.meaningRecall);
    expect(card.variantKey, isNull);
    expect(card.storageKey, 'noun.tisch');

    final restored = ReviewCard.fromJson(card.toJson());
    expect(restored.storageKey, 'noun.tisch');
    expect(restored.facetType, ReviewFacetType.meaningRecall);
  });

  test('non-default facets get stable collision-safe storage keys', () {
    const key = ReviewFacetKey(
      conceptId: 'noun.tisch',
      facetType: ReviewFacetType.caseForm,
      variantKey: 'dative',
    );

    final encoded = key.storageKey;
    final decoded = ReviewFacetKey.fromStorageKey(encoded);

    expect(encoded, isNot('noun.tisch'));
    expect(decoded.conceptId, 'noun.tisch');
    expect(decoded.facetType, ReviewFacetType.caseForm);
    expect(decoded.variantKey, 'dative');
  });

  test('facet rows remain lazy and independent for one concept', () {
    final meaning = ReviewCard(itemId: 'noun.tisch', dueAt: now);
    final gender = ReviewCard(
      itemId: 'noun.tisch',
      facetType: ReviewFacetType.gender,
      dueAt: now,
    );
    final state = LearnerState(
      reviewCards: <String, ReviewCard>{
        meaning.storageKey: meaning,
        gender.storageKey: gender,
      },
      updatedAt: now,
    );

    expect(
      state.reviewCardForFacet(
        'noun.tisch',
        facetType: ReviewFacetType.meaningRecall,
      ),
      same(meaning),
    );
    expect(
      state.reviewCardForFacet(
        'noun.tisch',
        facetType: ReviewFacetType.gender,
      ),
      same(gender),
    );
    expect(
      state.reviewCardForFacet(
        'noun.tisch',
        facetType: ReviewFacetType.pronunciation,
      ),
      isNull,
    );
  });
}
