import 'package:test/test.dart';
import '../../lib/src/core/semantic_search/fuzzy_ngram_indexer.dart';

void main() {
  group('FuzzyNgramIndexer Unit Tests (N045)', () {
    final indexer = FuzzyNgramIndexer();

    setUp(() {
      indexer.addAll(['Krankenhaus', 'Äpfel', 'Schlüssel', 'Universität', 'Wörterbuch']);
    });

    test('Correctly matches German umlaut substitutions (Aepfel -> Äpfel)', () {
      final matches = indexer.search('Aepfel', maxDistance: 1);
      expect(matches.isNotEmpty, isTrue);
      expect(matches.first.term, equals('Äpfel'));
      expect(matches.first.distance, equals(0)); // Normalized identical
    });

    test('Resolves single-character transposition typo (Shclüssel -> Schlüssel)', () {
      final matches = indexer.search('Shclüssel', maxDistance: 1);
      expect(matches.isNotEmpty, isTrue);
      expect(matches.first.term, equals('Schlüssel'));
      expect(matches.first.distance, equals(1));
    });

    test('Filters out words exceeding max edit distance threshold', () {
      final matches = indexer.search('Auto', maxDistance: 1);
      expect(matches, isEmpty);
    });
  });
}
