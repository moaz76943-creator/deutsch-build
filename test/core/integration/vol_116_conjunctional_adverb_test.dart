import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/content/german_conjunctional_adverb_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave27_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4927 Conjunctional Adverb Engine Tests', () {
    test('LING-050: Position 1 enforces inversion without comma', () {
      final res = GermanConjunctionalAdverbEngine.constructSentence(
        adverb: 'folglich',
        subject: 'wir',
        finiteVerb: 'müssen',
        remainder: 'den Plan anpassen',
        slot: AdverbPlacementSlot.positionOneVorfeld,
      );

      expect(res.adheresToInversion, isTrue);
      // Inversion: "Folglich müssen wir..."
      expect(res.generatedSentence, equals('Folglich müssen wir den Plan anpassen.'));
      // Must NOT contain English-style comma after adverb
      expect(res.generatedSentence.startsWith('Folglich, '), isFalse);
    });

    test('LING-050: trotzdem in Position 1 constructs concessive sentence', () {
      final res = GermanConjunctionalAdverbEngine.constructSentence(
        adverb: 'trotzdem',
        subject: 'er',
        finiteVerb: 'ging',
        remainder: 'zur Arbeit',
        slot: AdverbPlacementSlot.positionOneVorfeld,
      );

      expect(res.category, equals(ConjunctionalAdverbCategory.concessive));
      expect(res.generatedSentence, equals('Trotzdem ging er zur Arbeit.'));
    });

    test('LING-050: nämlich strictly forbidden at Position 1', () {
      expect(
        () => GermanConjunctionalAdverbEngine.constructSentence(
          adverb: 'nämlich',
          subject: 'er',
          finiteVerb: 'war',
          remainder: 'krank',
          slot: AdverbPlacementSlot.positionOneVorfeld,
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Mittelfeld placement of nämlich must succeed
      final resMiddle = GermanConjunctionalAdverbEngine.constructSentence(
        adverb: 'nämlich',
        subject: 'Er',
        finiteVerb: 'war',
        remainder: 'krank',
        slot: AdverbPlacementSlot.middleFieldSlot,
      );
      expect(resMiddle.generatedSentence, equals('Er war nämlich krank.'));
    });

    test('UI Bridge generates accurate Task 4927 diagnostics report', () {
      final bridge = Vol116Wave27UIBridge();
      final report = bridge.getTask4927Diagnostics();

      expect(report['task_id'], equals(4927));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(73));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
