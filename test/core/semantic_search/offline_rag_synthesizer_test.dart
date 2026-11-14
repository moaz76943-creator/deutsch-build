import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/semantic_search/offline_rag_synthesizer.dart';

void main() {
  group('OfflineRAGSynthesizer Unit Tests (N046)', () {
    const synthesizer = OfflineRAGSynthesizer(maxContextTokenBudget: 100);

    test('Assembles grounded prompt containing retrieved passages and target vocabulary', () {
      final prompt = synthesizer.buildPrompt(
        query: 'Wie bestelle ich Kaffee?',
        retrievedPassages: [
          'Im Café sagt man höflich: Ich hätte gerne einen Kaffee.',
          'Der Kellner antwortet: Gerne, mit Milch und Zucker?',
        ],
        targetVocabulary: ['hätte gerne', 'Kellner'],
        cefrTarget: 'A1',
      );

      expect(prompt.assembledContext, contains('Ich hätte gerne'));
      expect(prompt.assembledContext, contains('MANDATORY TARGET VOCABULARY: hätte gerne, Kellner'));
      expect(prompt.assembledContext, contains('TARGET CEFR LEVEL: A1'));
      expect(prompt.totalEstimatedTokens, greaterThan(0));
    });

    test('Respects max token budget and avoids overflow', () {
      final hugePassages = List.generate(50, (i) => 'Langer Satz über die deutsche Grammatik und Vokabeln $i.');
      final prompt = synthesizer.buildPrompt(
        query: 'Frage',
        retrievedPassages: hugePassages,
        targetVocabulary: [],
        cefrTarget: 'B1',
      );

      expect(prompt.totalEstimatedTokens, lessThan(250));
    });
  });
}
