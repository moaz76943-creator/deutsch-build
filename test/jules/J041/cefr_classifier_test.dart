import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/cefr_classifier.dart';

void main() {
  group('CefrClassifier - LexicalEntryEvidence', () {
    test('explicit sources override inferred metrics', () {
      const evidence = LexicalEntryEvidence(
        languageId: 'de',
        sourceProvidedCefr: CefrLevel.b2,
        frequencyRank: 10,
        charLength: 2,
      );

      final result = CefrClassifier.classifyLexicalEntry(evidence);
      expect(result.level, CefrLevel.b2);
      expect(result.grouping, CefrGrouping.intermediate);
      expect(result.method, CefrClassificationMethod.explicit);
      expect(result.confidence, CefrEvidenceConfidence.high);
    });

    test('German profile inferred logic', () {
      const a1Evidence = LexicalEntryEvidence(
        languageId: 'de',
        frequencyRank: 100,
      );
      expect(CefrClassifier.classifyLexicalEntry(a1Evidence).level, CefrLevel.a1);

      const a2CompoundEvidence = LexicalEntryEvidence(
        languageId: 'de',
        frequencyRank: 100,
        isCompound: true,
      );
      expect(CefrClassifier.classifyLexicalEntry(a2CompoundEvidence).level, CefrLevel.a2);

      const b1Evidence = LexicalEntryEvidence(
        languageId: 'de',
        frequencyRank: 3000,
      );
      expect(CefrClassifier.classifyLexicalEntry(b1Evidence).level, CefrLevel.b1);

      const b2Evidence = LexicalEntryEvidence(
        languageId: 'de',
        frequencyRank: 6000,
      );
      expect(CefrClassifier.classifyLexicalEntry(b2Evidence).level, CefrLevel.b2);

      const c1Evidence = LexicalEntryEvidence(
        languageId: 'de',
        frequencyRank: 10000,
      );
      expect(CefrClassifier.classifyLexicalEntry(c1Evidence).level, CefrLevel.c1);
    });

    test('Arabic profile inferred logic', () {
      const a1Evidence = LexicalEntryEvidence(
        languageId: 'ar',
        frequencyRank: 500,
      );
      expect(CefrClassifier.classifyLexicalEntry(a1Evidence).level, CefrLevel.a1);

      const a2Evidence = LexicalEntryEvidence(
        languageId: 'ar',
        frequencyRank: 2000,
      );
      expect(CefrClassifier.classifyLexicalEntry(a2Evidence).level, CefrLevel.a2);
    });

    test('generic fallback inferred logic with extremely long words', () {
      const fallbackEvidence = LexicalEntryEvidence(
        languageId: 'fr',
        frequencyRank: 500,
      );
      final result = CefrClassifier.classifyLexicalEntry(fallbackEvidence);
      expect(result.level, CefrLevel.a1);
      expect(result.confidence, CefrEvidenceConfidence.low);

      const longWordEvidence = LexicalEntryEvidence(
        languageId: 'fr',
        frequencyRank: 500,
        charLength: 20, // Should bump A1 to A2
      );
      expect(CefrClassifier.classifyLexicalEntry(longWordEvidence).level, CefrLevel.a2);
    });

    test('invalid/null records returning unknown', () {
      const nullEvidence = LexicalEntryEvidence(
        languageId: 'en',
      );
      final result = CefrClassifier.classifyLexicalEntry(nullEvidence);
      expect(result.level, CefrLevel.unknown);
      expect(result.grouping, CefrGrouping.unknown);
      expect(result.method, CefrClassificationMethod.inferred);
      expect(result.confidence, CefrEvidenceConfidence.none);
    });
  });

  group('CefrClassifier - LearningExampleEvidence', () {
    test('explicit sources override inferred metrics', () {
      const evidence = LearningExampleEvidence(
        languageId: 'es',
        sourceProvidedCefr: CefrLevel.c1,
        wordCount: 3,
        maxWordFrequencyRank: 100,
      );
      final result = CefrClassifier.classifyLearningExample(evidence);
      expect(result.level, CefrLevel.c1);
      expect(result.method, CefrClassificationMethod.explicit);
      expect(result.confidence, CefrEvidenceConfidence.high);
    });

    test('inferred logic based on example complexity vs isolated words', () {
      // Very simple short sentence
      const a1Evidence = LearningExampleEvidence(
        languageId: 'it',
        wordCount: 4,
        maxWordFrequencyRank: 300,
        clauseCount: 1,
      );
      expect(CefrClassifier.classifyLearningExample(a1Evidence).level, CefrLevel.a1);

      // Slightly longer sentence, more complex words
      const a2Evidence = LearningExampleEvidence(
        languageId: 'it',
        wordCount: 8,
        maxWordFrequencyRank: 1500,
        clauseCount: 2,
      );
      expect(CefrClassifier.classifyLearningExample(a2Evidence).level, CefrLevel.a2);

      // Even more complex
      const b1Evidence = LearningExampleEvidence(
        languageId: 'it',
        wordCount: 12,
        maxWordFrequencyRank: 4000,
        clauseCount: 2,
      );
      expect(CefrClassifier.classifyLearningExample(b1Evidence).level, CefrLevel.b1);

      // Highly complex
      const c1Evidence = LearningExampleEvidence(
        languageId: 'it',
        wordCount: 25,
        maxWordFrequencyRank: 15000,
        clauseCount: 4,
      );
      expect(CefrClassifier.classifyLearningExample(c1Evidence).level, CefrLevel.c1);
    });

    test('invalid/null records returning unknown', () {
      const nullEvidence = LearningExampleEvidence(
        languageId: 'en',
      );
      final result = CefrClassifier.classifyLearningExample(nullEvidence);
      expect(result.level, CefrLevel.unknown);
      expect(result.confidence, CefrEvidenceConfidence.none);
    });
  });

  group('CefrClassifier - Legacy and enum preservation', () {
    test('detectLevel is deprecated and returns unknown', () {
      expect(CefrClassifier.detectLevel(10, 5), CefrLevel.unknown);
    });

    test('getCode returns correct standard codes', () {
      expect(CefrClassifier.getCode(CefrLevel.a1), 'A1');
      expect(CefrClassifier.getCode(CefrLevel.c2), 'C2');
      expect(CefrClassifier.getCode(CefrLevel.unknown), '--');
    });
  });

  group('CefrClassifier - C2 Edge Cases', () {
    test('explicit C2 source is respected', () {
      const evidence = LexicalEntryEvidence(
        languageId: 'en',
        sourceProvidedCefr: CefrLevel.c2,
      );
      final result = CefrClassifier.classifyLexicalEntry(evidence);
      expect(result.level, CefrLevel.c2);
      expect(result.grouping, CefrGrouping.advanced);
      expect(result.method, CefrClassificationMethod.explicit);
    });
  });
}
