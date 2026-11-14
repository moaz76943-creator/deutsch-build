import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/krankenkasse_hausarzt_scenario.dart';

void main() {
  group('KrankenkasseHausarztScenario Unit Tests (L035)', () {
    test('Contains practical health insurance and family doctor selection dialogue', () {
      expect(KrankenkasseHausarztScenario.turns.length, equals(5));

      final cardTurn = KrankenkasseHausarztScenario.turns[1];
      expect(cardTurn.utteranceDe, contains('elektronische Gesundheitskarte'));

      final docTurn = KrankenkasseHausarztScenario.turns.last;
      expect(docTurn.utteranceDe, contains('Facharzttermine'));
      expect(docTurn.utteranceAr, contains('الأطباء التخصصيين'));
    });
  });
}
