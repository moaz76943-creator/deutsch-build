import 'package:test/test.dart';
import '../../lib/src/core/semantic_search/semantic_thesaurus_expander.dart';

void main() {
  group('SemanticThesaurusExpander Unit Tests (N059)', () {
    final expander = SemanticThesaurusExpander();

    test('Expands German schnell with high-quality synonyms (rasch, flott)', () {
      final synonyms = expander.expandSynonyms('schnell');
      expect(synonyms, contains('rasch'));
      expect(synonyms, contains('flott'));
      expect(synonyms, isNot(contains('langsam')));
    });

    test('Retrieves direct antonym for contrastive drill', () {
      final antonyms = expander.getAntonyms('schnell');
      expect(antonyms, contains('langsam'));
    });

    test('Returns empty lists for uncatalogued words', () {
      expect(expander.expandSynonyms('computer'), isEmpty);
      expect(expander.getAntonyms('computer'), isEmpty);
    });
  });
}
