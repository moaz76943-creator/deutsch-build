import 'package:test/test.dart';
import '../../lib/src/core/curriculum/subconscious_grammar_synthesizer.dart';

void main() {
  group('SubconsciousGrammarSynthesizer Unit Tests (N023)', () {
    final synthesizer = SubconsciousGrammarSynthesizer();

    test('Generates inductive variation drill cleanly isolating direct object case', () {
      const pattern = InductiveGrammarPattern(
        patternId: 'de_akk_01',
        targetFeature: 'German_Akkusativ_Masculine',
        subjects: ['Ich', 'Er', 'Wir'],
        verbBase: 'sehe',
        objectsWithArticle: ['den Hund', 'den Tisch', 'den Mann'],
      );

      final sentences = synthesizer.synthesizePatternDrill(pattern);
      expect(sentences.length, equals(9));
      expect(sentences, contains('Ich sehe den Hund.'));
      expect(sentences, contains('Er sehe den Tisch.'));
      expect(sentences, contains('Wir sehe den Mann.'));

      final isolation = synthesizer.evaluatePatternIsolation(
        generatedSentences: sentences,
        invariantVerb: 'sehe',
      );
      expect(isolation, equals(100.0));
    });

    test('Empty pattern returns zero sentences and zero isolation', () {
      const emptyPattern = InductiveGrammarPattern(
        patternId: 'empty',
        targetFeature: 'none',
        subjects: [],
        verbBase: 'geht',
        objectsWithArticle: [],
      );

      final result = synthesizer.synthesizePatternDrill(emptyPattern);
      expect(result, isEmpty);
      expect(synthesizer.evaluatePatternIsolation(generatedSentences: [], invariantVerb: 'geht'), equals(0.0));
    });
  });
}
