import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

// Use relative import for the file in lib/services
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
      expect(result.source, EvidenceSource.explicitPolicy);
      expect(result.confidence, 1.0);
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
      expect(result.source, EvidenceSource.verifiedSource);
      expect(result.confidence, 0.8);
    });

    test('Unsupported / Unknown when insufficient evidence (Japanese)', () {
      const evidence = LexicalEvidence(
        languageCode: 'ja',
      );

      final result = CefrClassifier.classifyWord(evidence);
      expect(result.level, CefrLevel.unknown);
      expect(result.source, EvidenceSource.unsupported);
      expect(result.confidence, 0.0);
    });

    test('Handles source map with only unknown levels', () {
      const evidence = LexicalEvidence(
        languageCode: 'en',
        sourceLevelMap: {
          'source_a': CefrLevel.unknown,
          'source_b': CefrLevel.unknown,
        },
      );

      final result = CefrClassifier.classifyWord(evidence);
      expect(result.level, CefrLevel.unknown);
      expect(result.source, EvidenceSource.unsupported);
    });

    test('Null records do not produce fake A1 assignments', () {
      const evidence = LexicalEvidence(
        languageCode: 'en',
      );
      final result = CefrClassifier.classifyWord(evidence);
      expect(result.level, CefrLevel.unknown);
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
      expect(result.source, EvidenceSource.explicitPolicy);
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
      expect(result.source, EvidenceSource.verifiedSource);
    });

    test('Infers difficulty from words levels with bump (cap at C2)', () {
      const evidence = ExampleEvidence(
        languageCode: 'it',
        wordsLevels: [CefrLevel.a1, CefrLevel.b1, CefrLevel.a2],
      );

      final result = CefrClassifier.classifyExample(evidence);
      // Max is B1, bumped by 1 level to B2 for example complexity
      expect(result.level, CefrLevel.b2);
      expect(result.source, EvidenceSource.inferredDifficulty);
      expect(result.confidence, 0.6);
    });

    test('Inferred difficulty does not exceed C2', () {
      const evidence = ExampleEvidence(
        languageCode: 'ru',
        wordsLevels: [CefrLevel.c2, CefrLevel.a1],
      );

      final result = CefrClassifier.classifyExample(evidence);
      // Max is C2, bumped by 1 cap at C2
      expect(result.level, CefrLevel.c2);
      expect(result.source, EvidenceSource.inferredDifficulty);
    });

    test('Returns unknown for examples with no valid words or sources', () {
      const evidence = ExampleEvidence(
        languageCode: 'zh',
        wordsLevels: [CefrLevel.unknown, CefrLevel.unknown],
      );

      final result = CefrClassifier.classifyExample(evidence);
      expect(result.level, CefrLevel.unknown);
      expect(result.source, EvidenceSource.unsupported);
    });
  });
}
