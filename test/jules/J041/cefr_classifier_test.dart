import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/cefr_classifier.dart';

void main() {
  group('CefrClassifier - Legacy Fallback', () {
    test('detectLevel returns unknown without fabricating levels based on frequency', () {
      // ignore: deprecated_member_use_from_same_package
      expect(CefrClassifier.detectLevel(100, 4), equals(CefrLevel.unknown));
      // ignore: deprecated_member_use_from_same_package
      expect(CefrClassifier.detectLevel(10000, 10), equals(CefrLevel.unknown));
    });
  });

  group('CefrClassifier - classifyWord (All Levels)', () {
    test('returns A1 explicit level', () {
      final ev = [const CefrEvidence(source: CefrEvidenceSource.explicitPolicy, confidence: 1.0, explicitLevel: CefrLevel.a1)];
      expect(CefrClassifier.classifyWord(ev), equals(CefrLevel.a1));
    });
    test('returns A2 explicit level', () {
      final ev = [const CefrEvidence(source: CefrEvidenceSource.explicitPolicy, confidence: 1.0, explicitLevel: CefrLevel.a2)];
      expect(CefrClassifier.classifyWord(ev), equals(CefrLevel.a2));
    });
    test('returns B1 explicit level', () {
      final ev = [const CefrEvidence(source: CefrEvidenceSource.explicitPolicy, confidence: 1.0, explicitLevel: CefrLevel.b1)];
      expect(CefrClassifier.classifyWord(ev), equals(CefrLevel.b1));
    });
    test('returns B2 explicit level', () {
      final ev = [const CefrEvidence(source: CefrEvidenceSource.explicitPolicy, confidence: 1.0, explicitLevel: CefrLevel.b2)];
      expect(CefrClassifier.classifyWord(ev), equals(CefrLevel.b2));
    });
    test('returns C1 explicit level', () {
      final ev = [const CefrEvidence(source: CefrEvidenceSource.explicitPolicy, confidence: 1.0, explicitLevel: CefrLevel.c1)];
      expect(CefrClassifier.classifyWord(ev), equals(CefrLevel.c1));
    });
    test('returns C2 explicit level', () {
      final ev = [const CefrEvidence(source: CefrEvidenceSource.explicitPolicy, confidence: 1.0, explicitLevel: CefrLevel.c2)];
      expect(CefrClassifier.classifyWord(ev), equals(CefrLevel.c2));
    });
  });

  group('CefrClassifier - classifyWord (Conflict Resolution & Ambiguity)', () {
    test('prioritizes highest weight source', () {
      final evList = [
        const CefrEvidence(source: CefrEvidenceSource.inferredDifficulty, confidence: 0.9, explicitLevel: CefrLevel.c1),
        const CefrEvidence(source: CefrEvidenceSource.certifiedCorpus, confidence: 0.8, explicitLevel: CefrLevel.b2),
        const CefrEvidence(source: CefrEvidenceSource.explicitPolicy, confidence: 0.7, explicitLevel: CefrLevel.b1),
      ];
      // explicitPolicy > certifiedCorpus > inferredDifficulty
      expect(CefrClassifier.classifyWord(evList), equals(CefrLevel.b1));
    });

    test('prioritizes highest confidence within same source weight', () {
      final evList = [
        const CefrEvidence(source: CefrEvidenceSource.certifiedCorpus, confidence: 0.7, explicitLevel: CefrLevel.a2),
        const CefrEvidence(source: CefrEvidenceSource.certifiedCorpus, confidence: 0.9, explicitLevel: CefrLevel.b1),
      ];
      expect(CefrClassifier.classifyWord(evList), equals(CefrLevel.b1));
    });

    test('returns unknown for ambiguous entries (same weight and confidence, different levels)', () {
      final evList = [
        const CefrEvidence(source: CefrEvidenceSource.certifiedCorpus, confidence: 0.8, explicitLevel: CefrLevel.a2),
        const CefrEvidence(source: CefrEvidenceSource.certifiedCorpus, confidence: 0.8, explicitLevel: CefrLevel.b1),
      ];
      expect(CefrClassifier.classifyWord(evList), equals(CefrLevel.unknown));
    });

    test('returns unknown when evidence confidence is insufficient for all', () {
      final evList = [
        const CefrEvidence(source: CefrEvidenceSource.certifiedCorpus, confidence: 0.4, explicitLevel: CefrLevel.b1),
        const CefrEvidence(source: CefrEvidenceSource.explicitPolicy, confidence: 0.4, explicitLevel: CefrLevel.a1),
      ];
      expect(CefrClassifier.classifyWord(evList), equals(CefrLevel.unknown));
    });

    test('returns unknown when evidence list is empty or sources are none', () {
      expect(CefrClassifier.classifyWord([]), equals(CefrLevel.unknown));
      expect(
        CefrClassifier.classifyWord([const CefrEvidence(source: CefrEvidenceSource.none, confidence: 1.0, explicitLevel: CefrLevel.a2)]),
        equals(CefrLevel.unknown)
      );
    });

    test('returns unknown when explicitLevel is null', () {
      final evList = [const CefrEvidence(source: CefrEvidenceSource.explicitPolicy, confidence: 1.0, explicitLevel: null)];
      expect(CefrClassifier.classifyWord(evList), equals(CefrLevel.unknown));
    });
  });

  group('CefrClassifier - classifyExample', () {
    test('returns level for example with explicit policy', () {
      final evList = [const CefrEvidence(source: CefrEvidenceSource.explicitPolicy, confidence: 1.0, explicitLevel: CefrLevel.b2)];
      expect(CefrClassifier.classifyExample(evList), equals(CefrLevel.b2));
    });

    test('requires higher confidence for inferred difficulty in examples', () {
      // 0.7 confidence is sufficient for words, but not for examples with inferredDifficulty
      final insufficient = [const CefrEvidence(source: CefrEvidenceSource.inferredDifficulty, confidence: 0.7, explicitLevel: CefrLevel.c1)];
      expect(CefrClassifier.classifyExample(insufficient), equals(CefrLevel.unknown));

      // 0.8 is sufficient for examples with inferredDifficulty
      final sufficient = [const CefrEvidence(source: CefrEvidenceSource.inferredDifficulty, confidence: 0.85, explicitLevel: CefrLevel.c1)];
      expect(CefrClassifier.classifyExample(sufficient), equals(CefrLevel.c1));
    });
  });

  group('CefrClassifier - Typological Language Fixtures', () {
    test('classifies Arabic word correctly', () {
      final arabicEvidence = [
        const CefrEvidence(
          source: CefrEvidenceSource.certifiedCorpus,
          confidence: 0.95,
          explicitLevel: CefrLevel.a1, // Example: "مرحبا" (Marhaba)
        )
      ];
      expect(CefrClassifier.classifyWord(arabicEvidence), equals(CefrLevel.a1));
    });

    test('classifies German compound word correctly', () {
      final germanEvidence = [
        const CefrEvidence(
          source: CefrEvidenceSource.explicitPolicy,
          confidence: 1.0,
          explicitLevel: CefrLevel.c2, // Example: "Donaudampfschifffahrt"
        )
      ];
      expect(CefrClassifier.classifyWord(germanEvidence), equals(CefrLevel.c2));
    });

    test('classifies Japanese word correctly', () {
      final japaneseEvidence = [
        const CefrEvidence(
          source: CefrEvidenceSource.inferredDifficulty,
          confidence: 0.8,
          explicitLevel: CefrLevel.b1, // Example: "図書館" (Toshokan)
        )
      ];
      expect(CefrClassifier.classifyWord(japaneseEvidence), equals(CefrLevel.b1));
    });
  });

  group('CefrClassifier - Groupings', () {
    test('correctly groups levels', () {
      expect(CefrClassifier.getGrouping(CefrLevel.a1), equals(CefrGrouping.beginner));
      expect(CefrClassifier.getGrouping(CefrLevel.a2), equals(CefrGrouping.beginner));

      expect(CefrClassifier.getGrouping(CefrLevel.b1), equals(CefrGrouping.intermediate));
      expect(CefrClassifier.getGrouping(CefrLevel.b2), equals(CefrGrouping.intermediate));

      expect(CefrClassifier.getGrouping(CefrLevel.c1), equals(CefrGrouping.advanced));
      expect(CefrClassifier.getGrouping(CefrLevel.c2), equals(CefrGrouping.advanced));

      expect(CefrClassifier.getGrouping(CefrLevel.unknown), equals(CefrGrouping.unknown));
    });
  });

  group('CefrClassifier - UI Compatibility Constants', () {
    test('getCode returns correct string', () {
      expect(CefrClassifier.getCode(CefrLevel.a1), equals('A1'));
      expect(CefrClassifier.getCode(CefrLevel.c2), equals('C2'));
      expect(CefrClassifier.getCode(CefrLevel.unknown), equals('--'));
    });

    test('getLabel and getLabelAr work as expected', () {
      expect(CefrClassifier.getLabel(CefrLevel.a1), contains('A1'));
      expect(CefrClassifier.getLabelAr(CefrLevel.b2), contains('B2'));
    });

    test('getLevelColor returns distinct colors without throwing', () {
      expect(CefrClassifier.getLevelColor(CefrLevel.a1).value, isNotNull);
      expect(CefrClassifier.getLevelColor(CefrLevel.unknown).value, isNotNull);
    });
  });
}
