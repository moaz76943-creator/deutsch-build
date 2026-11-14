import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import '../../../lib/polyglot_core.dart';

void main() {
  group('Task #4987: Unified Multi-Language Exercise Generator & Barrel Tests', () {
    late PolyglotUnifiedRegistry registry;
    late PolyglotSrsScheduler srs;
    late PolyglotExerciseGenerator generator;

    setUp(() {
      registry = PolyglotUnifiedRegistry();
      registry.registerModule(GermanC1C2CoreFeaturePack());
      registry.registerModule(GermanRealWorldDialoguesPack());
      final rawFrEn = File('assets/packs/en_fr_professional_starter.json').readAsStringSync();
      PolyglotJsonPackLoader.loadIntoRegistry(registry, rawFrEn);

      srs = PolyglotSrsScheduler();
      generator = PolyglotExerciseGenerator(registry: registry, srsScheduler: srs);
    });

    test('Generates interactive Cloze, Error-Spotter & Bilingual Recall drills across languages', () {
      final deExercises = generator.generateDueSession(languageCode: 'de', limit: 6);
      expect(deExercises.length, equals(6));
      expect(deExercises.any((e) => e.type == PolyglotExerciseType.contextualCloze), isTrue);
      expect(deExercises.any((e) => e.type == PolyglotExerciseType.errorSpotter), isTrue);
      expect(deExercises.any((e) => e.type == PolyglotExerciseType.bilingualRecall), isTrue);

      final frExercises = generator.generateDueSession(languageCode: 'fr', limit: 5);
      expect(frExercises.length, equals(2));
    });

    test('Submitting exercise answers updates SM-2 SRS schedule immediately', () {
      final t0 = DateTime.utc(2026, 11, 14, 10, 0);
      final session = generator.generateDueSession(languageCode: 'de', limit: 1, now: t0);
      final ex = session.first;

      final res = generator.submitAnswer(ex, ex.correctOptionIndex, now: t0);
      expect(res.isCorrect, isTrue);
      expect(res.updatedSrsCard.repetitions, equals(1));
      expect(res.updatedSrsCard.intervalDays, equals(1));
      expect(srs.trackedCardCount, equals(1));
    });
  });
}
