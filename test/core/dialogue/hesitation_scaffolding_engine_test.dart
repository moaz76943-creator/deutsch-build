import 'package:test/test.dart';
import 'package:deutsch_build/src/core/dialogue/hesitation_scaffolding_engine.dart';

void main() {
  group('HesitationScaffoldingEngine Tests', () {
    const engine = HesitationScaffoldingEngine();

    test('Triggers scaffolding on prolonged silence over 2.5s in restaurant context', () {
      final hint = engine.evaluateHesitation(
        partialTranscript: 'Hallo...',
        elapsedSilenceMs: 2800,
        currentScenarioContext: 'restaurant',
      );

      expect(hint, isNotNull);
      expect(hint!.trigger, equals(HesitationTrigger.prolongedSilence));
      expect(hint.sentenceStarter, contains('Ich möchte gerne'));
      expect(hint.keywordSuggestions, contains('die Speisekarte'));
    });

    test('Detects excessive filler hesitation sounds "ähm"', () {
      final hint = engine.evaluateHesitation(
        partialTranscript: 'Ich möchte... ähm... vielleicht... ähm...',
        elapsedSilenceMs: 800,
        currentScenarioContext: 'travel',
      );

      expect(hint, isNotNull);
      expect(hint!.trigger, equals(HesitationTrigger.fillerOverload));
      expect(hint.keywordSuggestions, contains('Gleis'));
    });

    test('Detects dangling conjunction "weil" and provides syntactic support', () {
      final hint = engine.evaluateHesitation(
        partialTranscript: 'Ich lerne Deutsch, weil',
        elapsedSilenceMs: 1200,
        currentScenarioContext: 'general',
      );

      expect(hint, isNotNull);
      expect(hint!.trigger, equals(HesitationTrigger.danglingIncompleteClause));
      expect(hint.sentenceStarter, contains('Ich denke, dass'));
    });

    test('Returns null when user is speaking fluently without delay', () {
      final hint = engine.evaluateHesitation(
        partialTranscript: 'Guten Tag, ich möchte bitte bezahlen.',
        elapsedSilenceMs: 300,
        currentScenarioContext: 'restaurant',
      );

      expect(hint, isNull);
    });
  });
}
