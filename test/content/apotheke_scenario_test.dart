import 'package:test/test.dart';
import '../../lib/src/content/apotheke_scenario.dart';

void main() {
  group('ApothekeScenario Unit Tests (L029)', () {
    test('Contains authentic pharmacy consultation dialogue emphasizing clean medication', () {
      expect(ApothekeScenario.turns.length, equals(5));

      final rxTurn = ApothekeScenario.turns[1];
      expect(rxTurn.utteranceDe, contains('Rezept vom Arzt einlösen'));

      final alcoholCheckTurn = ApothekeScenario.turns[3];
      expect(alcoholCheckTurn.utteranceDe, contains('alkoholfrei'));
      expect(alcoholCheckTurn.utteranceAr, contains('خالٍ تماماً من الكحول'));
    });
  });
}
