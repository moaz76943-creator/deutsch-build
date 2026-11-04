import 'package:deutsch_bilarabi/core/srs_facets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('existing writer keys remain unchanged including variant bytes', () {
    expect(const ReviewFacetKey(conceptId: 'word').storageKey,
        'word:meaningRecall');
    expect(
        const ReviewFacetKey(conceptId: 'word', variantKey: 'variant')
            .isLegacyMeaningKey,
        isFalse);
    expect(
        const ReviewFacetKey(
                conceptId: 'word',
                facetType: ReviewFacetType.grammar,
                variantKey: 'Case:X')
            .storageKey,
        'word:grammar:Case:X');
  });
  test('current and historical Unicode keys roundtrip without rewriting', () {
    const raw = 'معنى:grammar:Case:X';
    final current = ReviewFacetKey.fromStorageKey(raw);
    expect(current.storageKey, raw);
    expect(current.conceptId, 'معنى');
    expect(current.normalizedVariantKey, 'case:x');
    const historical = '@facet::%D9%85%D8%B9%D9%86%D9%89::case_form::Nominativ';
    final key = ReviewFacetKey.fromStorageKey(historical);
    expect(key.storageKey, historical);
    expect(key.conceptId, 'معنى');
    expect(key.facetType, ReviewFacetType.caseForm);
    expect(
        ReviewFacetKey.fromStorageKey('legacy-word').storageKey, 'legacy-word');
  });
  test('unknown and ambiguous facets cannot receive meaning recall credit', () {
    expect(ReviewFacetType.fromWire('future_unsupported'),
        ReviewFacetType.unknown);
    expect(
        ReviewFacetKey.fromStorageKey('@facet::x::future_unsupported::')
            .isValid,
        isFalse);
    expect(
        ReviewFacetKey.fromStorageKey('x:grammar:spelling').isValid, isFalse);
    expect(ReviewFacetKey.fromStorageKey('x:unknown').isValid, isFalse);
    expect(ReviewFacetKey.fromStorageKey('@facet::%oops::grammar::').isValid,
        isFalse);
  });
  test('all known facet wire names preserve their identity', () {
    for (final facet in ReviewFacetType.values) {
      expect(ReviewFacetType.fromWire(facet.wireName), facet);
    }
  });
}
