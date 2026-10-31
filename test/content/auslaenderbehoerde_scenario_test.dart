import 'package:test/test.dart';
import '../../lib/src/content/auslaenderbehoerde_scenario.dart';

void main() {
  group('AuslaenderbehoerdeScenario Unit Tests (L034)', () {
    test('Contains authentic residence permit extension and documentation dialogue', () {
      expect(AuslaenderbehoerdeScenario.turns.length, equals(5));

      final titleTurn = AuslaenderbehoerdeScenario.turns.first;
      expect(titleTurn.utteranceDe, contains('Aufenthaltstitels'));

      final docTurn = AuslaenderbehoerdeScenario.turns[1];
      expect(docTurn.utteranceDe, contains('Arbeitsvertrag'));
      expect(docTurn.utteranceDe, contains('Gehaltsabrechnungen'));
      expect(docTurn.utteranceAr, contains('عقد عملي'));
    });
  });
}
