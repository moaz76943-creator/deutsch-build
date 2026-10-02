import 'dart:convert';

import 'package:deutsch_bilarabi/core/srs_facets.dart';
import 'package:deutsch_bilarabi/services/progress_tracker_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('SQLite progress store keeps independent rows per facet', () async {
    final service = ProgressTrackerService.withFactory(databaseFactoryFfi);
    final database = await service.database;
    await database.delete('spaced_repetition');

    await service.processFacetReview(
      conceptId: 'noun.tisch',
      facetType: ReviewFacetType.meaningRecall,
      correct: true,
      hinted: false,
      at: DateTime.utc(2026, 10, 2, 12),
    );
    await service.processFacetReview(
      conceptId: 'noun.tisch',
      facetType: ReviewFacetType.gender,
      correct: false,
      hinted: false,
      at: DateTime.utc(2026, 10, 2, 12),
    );

    final meaning = await service.getFacetReviewCard(
      conceptId: 'noun.tisch',
      facetType: ReviewFacetType.meaningRecall,
    );
    final gender = await service.getFacetReviewCard(
      conceptId: 'noun.tisch',
      facetType: ReviewFacetType.gender,
    );
    final exported = jsonDecode(await service.exportProgressState());

    expect(meaning, isNotNull);
    expect(gender, isNotNull);
    expect(meaning?.storageKey, 'noun.tisch');
    expect(gender?.storageKey, isNot('noun.tisch'));
    expect((exported['spaced_repetition'] as List), hasLength(2));

    await service.close();
  });

  test('legacy quality API delegates into meaning_recall facet', () async {
    final service = ProgressTrackerService.withFactory(databaseFactoryFfi);
    final database = await service.database;
    await database.delete('spaced_repetition');

    await service.processSpacedRepetitionReview(
      itemId: 'verb.fahren',
      quality: 4,
    );

    final card = await service.getFacetReviewCard(
      conceptId: 'verb.fahren',
      facetType: ReviewFacetType.meaningRecall,
    );

    expect(card, isNotNull);
    expect(card?.facetType, ReviewFacetType.meaningRecall);
    await service.close();
  });
}
