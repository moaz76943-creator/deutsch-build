import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/features/study_session/domain/models.dart';
import 'package:deutsch_bilarabi/features/study_session/domain/vocabulary_search_service.dart';

void main() {
  group('VocabularySearchService Domain Tests', () {
    const searchService = VocabularySearchService();

    final testCards = [
      const Flashcard(
        id: '1',
        conceptId: 'apple_concept',
        german: 'Apfel',
        arabic: 'تفاحة',
      ),
      const Flashcard(
        id: '2',
        conceptId: 'bear_concept',
        german: 'Bär',
        arabic: 'دب',
      ),
      const Flashcard(
        id: '3',
        conceptId: 'lion_concept',
        german: 'Löwe',
        arabic: 'أسد',
      ),
      const Flashcard(
        id: '4',
        conceptId: 'sweet_concept',
        german: 'Süß',
        arabic: 'حلو',
      ),
      const Flashcard(
        id: '5',
        conceptId: 'greetings_concept',
        german: 'Guten Morgen!',
        arabic: 'صباح الخير، صديقي؟',
      ),
    ];

    test('Search filtering - matches concept_id', () {
      final results = searchService.search(testCards, 'apple');
      expect(results.length, 1);
      expect(results.first.id, '1');
    });

    test('Search filtering - matches arabic text', () {
      final results = searchService.search(testCards, 'أسد');
      expect(results.length, 1);
      expect(results.first.id, '3');
    });

    test('Search filtering - case insensitive', () {
      final results = searchService.search(testCards, 'aPfEl');
      expect(results.length, 1);
      expect(results.first.id, '1');
    });

    test('Search filtering - handles German umlauts ä/ö/ü/ß', () {
      // Bär -> bar
      final resultsA = searchService.search(testCards, 'bar');
      expect(resultsA.length, 1);
      expect(resultsA.first.id, '2');

      // Löwe -> lowe
      final resultsO = searchService.search(testCards, 'lowe');
      expect(resultsO.length, 1);
      expect(resultsO.first.id, '3');

      // Süß -> suss
      final resultsU_SS = searchService.search(testCards, 'suss');
      expect(resultsU_SS.length, 1);
      expect(resultsU_SS.first.id, '4');
    });

    test('Search filtering - ignores punctuation', () {
      final results = searchService.search(testCards, 'morgen');
      expect(results.length, 1);
      expect(results.first.id, '5');

      final resultsAr = searchService.search(testCards, 'صديقي');
      expect(resultsAr.length, 1);
      expect(resultsAr.first.id, '5');
    });

    test('Search filtering - empty query returns all', () {
      final results = searchService.search(testCards, '   ');
      expect(results.length, 5);
    });
  });
}
