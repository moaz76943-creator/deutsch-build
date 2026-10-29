import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/services/cefr_classifier.dart';

void main() {
  group('CefrClassifier - Legacy Methods', () {
    test('detectLevel returns unknown for all inputs to prevent fake A1 assignments', () {
      expect(CefrClassifier.detectLevel(1, 1), CefrLevel.unknown);
      expect(CefrClassifier.detectLevel(100, 5), CefrLevel.unknown);
      expect(CefrClassifier.detectLevel(600, 7), CefrLevel.unknown);
      expect(CefrClassifier.detectLevel(4000, 10), CefrLevel.unknown);
      expect(CefrClassifier.detectLevel(0, 0), CefrLevel.unknown);
    });

    test('getCode returns standard codes', () {
      expect(CefrClassifier.getCode(CefrLevel.a1), 'A1');
      expect(CefrClassifier.getCode(CefrLevel.c2), 'C2');
      expect(CefrClassifier.getCode(CefrLevel.unknown), '--');
    });

    test('getLabelAr / getLabel returns descriptive labels', () {
      expect(CefrClassifier.getLabel(CefrLevel.a1), 'A1 (مبتدئ)');
      expect(CefrClassifier.getLabelAr(CefrLevel.c1), 'C1 (احترافي)');
      expect(CefrClassifier.getLabel(CefrLevel.unknown), 'عام');
    });

    test('getLevelColor returns visual distinction colors', () {
      expect(CefrClassifier.getLevelColor(CefrLevel.a1), const Color(0xFF10B981));
      expect(CefrClassifier.getLevelColor(CefrLevel.c2), const Color(0xFFEF4444));
      expect(CefrClassifier.getLevelColor(CefrLevel.unknown), const Color(0xFF6B7280));
    });

    test('getGroup returns appropriate broad level groupings', () {
      expect(CefrClassifier.getGroup(CefrLevel.a1), CefrGroup.beginner);
      expect(CefrClassifier.getGroup(CefrLevel.a2), CefrGroup.beginner);
      expect(CefrClassifier.getGroup(CefrLevel.b1), CefrGroup.intermediate);
      expect(CefrClassifier.getGroup(CefrLevel.b2), CefrGroup.intermediate);
      expect(CefrClassifier.getGroup(CefrLevel.c1), CefrGroup.advanced);
      expect(CefrClassifier.getGroup(CefrLevel.c2), CefrGroup.advanced);
      expect(CefrClassifier.getGroup(CefrLevel.unknown), CefrGroup.unknown);
    });
  });

  group('CefrClassifier - Evidence-based Word Classification', () {
    test('Explicit policy overrides other sources (Arabic)', () {
      const evidence = LexicalEvidence(
        languageCode: 'ar',
        explicitLevel: CefrLevel.b1,
        sourceLevelMap: {
          'frequency_list': CefrLevel.a1,
          'teacher_review': CefrLevel.a2,
        },
      );

      final result = CefrClassifier.classifyWord(evidence);
      expect(result.level, CefrLevel.b1);
      expect(result.method, CefrClassificationMethod.explicit);
      expect(result.confidence, CefrEvidenceConfidence.high);
    });

    test('Verified sources are used when explicit policy is missing (German)', () {
      const evidence = LexicalEvidence(
        languageCode: 'de',
        sourceLevelMap: {
          'goethe_institut': CefrLevel.b2,
          'dw': CefrLevel.b1,
        },
      );

      final result = CefrClassifier.classifyWord(evidence);
      // Resolves to highest
      expect(result.level, CefrLevel.b2);
      expect(result.method, CefrClassificationMethod.explicit);
      expect(result.confidence, CefrEvidenceConfidence.high);
    });

    test('Infers difficulty for different languages (German - A1)', () {
      const evidence = LexicalEvidence(
        languageCode: 'de',
        frequencyRank: 400,
      );
      final result = CefrClassifier.classifyWord(evidence);
      expect(result.level, CefrLevel.a1);
    });

    test('Infers difficulty for different languages (German - compound bump)', () {
      const evidence = LexicalEvidence(
        languageCode: 'de',
        frequencyRank: 400,
        isCompound: true,
      );
      final result = CefrClassifier.classifyWord(evidence);
      expect(result.level, CefrLevel.a2);
    });

    test('Infers difficulty for different languages (Arabic - B2)', () {
      const evidence = LexicalEvidence(
        languageCode: 'ar',
        frequencyRank: 8000,
      );
      final result = CefrClassifier.classifyWord(evidence);
      expect(result.level, CefrLevel.b2);
    });

    test('Infers difficulty for different languages (Generic - C1)', () {
      const evidence = LexicalEvidence(
        languageCode: 'ja',
        frequencyRank: 12000,
      );
      final result = CefrClassifier.classifyWord(evidence);
      expect(result.level, CefrLevel.c1);
      expect(result.confidence, CefrEvidenceConfidence.low);
    });

    test('Lengthy words bump difficulty', () {
      const evidence = LexicalEvidence(
        languageCode: 'en',
        frequencyRank: 500,
        charLength: 20,
      );
      final result = CefrClassifier.classifyWord(evidence);
      expect(result.level, CefrLevel.a2);
    });

    test('Unsupported / Unknown when insufficient evidence', () {
      const evidence = LexicalEvidence(
        languageCode: 'en',
      );
      final result = CefrClassifier.classifyWord(evidence);
      expect(result.level, CefrLevel.unknown);
      expect(result.confidence, CefrEvidenceConfidence.none);
    });
  });

  group('CefrClassifier - Evidence-based Example Classification', () {
    test('Explicit policy is respected for examples', () {
      const evidence = ExampleEvidence(
        languageCode: 'fr',
        explicitLevel: CefrLevel.c1,
        wordsLevels: [CefrLevel.a1, CefrLevel.a2],
      );

      final result = CefrClassifier.classifyExample(evidence);
      expect(result.level, CefrLevel.c1);
      expect(result.method, CefrClassificationMethod.explicit);
    });

    test('Verified source map is respected for examples', () {
      const evidence = ExampleEvidence(
        languageCode: 'es',
        sourceLevelMap: {
          'textbook_x': CefrLevel.b1,
        },
        wordsLevels: [CefrLevel.a1],
      );

      final result = CefrClassifier.classifyExample(evidence);
      expect(result.level, CefrLevel.b1);
      expect(result.method, CefrClassificationMethod.explicit);
    });

    test('Infers difficulty from words levels with bump (cap at C2)', () {
      const evidence = ExampleEvidence(
        languageCode: 'it',
        wordsLevels: [CefrLevel.a1, CefrLevel.b1, CefrLevel.a2],
      );

      final result = CefrClassifier.classifyExample(evidence);
      // Max is B1, bumped by 1 level to B2 for example complexity
      expect(result.level, CefrLevel.b2);
      expect(result.method, CefrClassificationMethod.inferred);
      expect(result.confidence, CefrEvidenceConfidence.medium);
    });

    test('Inferred difficulty does not exceed C2', () {
      const evidence = ExampleEvidence(
        languageCode: 'ru',
        wordsLevels: [CefrLevel.c2, CefrLevel.a1],
      );

      final result = CefrClassifier.classifyExample(evidence);
      // Max is C2, bumped by 1 cap at C2
      expect(result.level, CefrLevel.c2);
      expect(result.method, CefrClassificationMethod.inferred);
    });

    test('Infers difficulty from word count and rank (A1)', () {
      const evidence = ExampleEvidence(
        languageCode: 'en',
        wordCount: 4,
        clauseCount: 1,
        maxWordFrequencyRank: 300,
      );
      final result = CefrClassifier.classifyExample(evidence);
      expect(result.level, CefrLevel.a1);
    });

    test('Infers difficulty from word count and rank (B1)', () {
      const evidence = ExampleEvidence(
        languageCode: 'en',
        wordCount: 12,
        clauseCount: 2,
        maxWordFrequencyRank: 4000,
      );
      final result = CefrClassifier.classifyExample(evidence);
      expect(result.level, CefrLevel.b1);
    });

    test('Returns unknown for examples with missing properties to prevent fake A1 assignments', () {
      const evidence = ExampleEvidence(
        languageCode: 'en',
        clauseCount: 1,
      );
      final result = CefrClassifier.classifyExample(evidence);
      expect(result.level, CefrLevel.unknown);

      const evidence2 = ExampleEvidence(
        languageCode: 'en',
        wordCount: 5,
      );
      final result2 = CefrClassifier.classifyExample(evidence2);
      expect(result2.level, CefrLevel.unknown);
    });
  });
}
