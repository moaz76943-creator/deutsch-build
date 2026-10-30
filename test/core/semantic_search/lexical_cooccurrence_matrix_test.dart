import 'package:test/test.dart';
import '../../lib/src/core/semantic_search/lexical_cooccurrence_matrix.dart';

void main() {
  group('LexicalCooccurrenceMatrix Unit Tests (N057)', () {
    final matrix = LexicalCooccurrenceMatrix(windowRadius: 2);

    test('Ingests thematic culinary text and links related co-occurrences', () {
      matrix.ingestPassage('In der Küche kocht die Köchin Suppe mit dem scharfen Messer.');
      matrix.ingestPassage('Die Köchin schneidet Gemüse in der Küche.');

      expect(matrix.uniqueWordCount, greaterThan(5));

      final associates = matrix.getTopAssociates('küche', topK: 3);
      expect(associates.isNotEmpty, isTrue);
      expect(associates.any((a) => a.wordB == 'köchin'), isTrue);
    });

    test('Returns empty list for words with no co-occurrence history', () {
      expect(matrix.getTopAssociates('astronomie'), isEmpty);
    });
  });
}
