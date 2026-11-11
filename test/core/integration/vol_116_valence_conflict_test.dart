import 'package:test/test.dart';
import 'package:deutsch_build/src/core/content/german_valence_conflict_resolver_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave31_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4931 Valence Conflict Resolver Engine Tests', () {
    test('LING-054: Collision between interessieren für and teilnehmen an is decoupled', () {
      final res = GermanValenceConflictResolverEngine.resolveCoordination(
        subject: 'Er',
        verb1: 'interessiert',
        verb2: 'nimmt',
        verb1ReflexivePronoun: 'sich',
        targetNounPhrase: 'das Projekt',
      );

      expect(res.hasRectionCollision, isTrue);
      expect(res.grammaticallyDecoupledSentence, contains('für das Projekt'));
      expect(res.grammaticallyDecoupledSentence, contains('daran'));
      expect(res.arabicCorrectionNote, contains('تصادم في التعدية الإعرابية'));
    });

    test('LING-054: Collision between achten auf and beitragen zu is resolved with dazu', () {
      final res = GermanValenceConflictResolverEngine.resolveCoordination(
        subject: 'Wir',
        verb1: 'achten',
        verb2: 'tragen',
        targetNounPhrase: 'die Regeln',
      );

      expect(res.hasRectionCollision, isTrue);
      expect(res.grammaticallyDecoupledSentence, contains('auf die Regeln'));
      expect(res.grammaticallyDecoupledSentence, contains('dazu'));
    });

    test('LING-054: Compatible verbs sharing preposition and case pass cleanly', () {
      final res = GermanValenceConflictResolverEngine.resolveCoordination(
        subject: 'Sie',
        verb1: 'achten',
        verb2: 'warten',
        targetNounPhrase: 'das Signal',
      );

      // Both achten and warten govern "auf + Akkusativ"
      expect(res.hasRectionCollision, isFalse);
      expect(res.ruleExplanation, contains('Kompatible Rektion'));
    });

    test('UI Bridge generates accurate Task 4931 diagnostics report', () {
      final bridge = Vol116Wave31UIBridge();
      final report = bridge.getTask4931Diagnostics();

      expect(report['task_id'], equals(4931));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(69));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
