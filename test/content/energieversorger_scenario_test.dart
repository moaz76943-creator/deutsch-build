import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/energieversorger_scenario.dart';

void main() {
  group('EnergieversorgerScenario Unit Tests (L037)', () {
    test('Contains authentic utility contract dialogue with meter reading terminology', () {
      expect(EnergieversorgerScenario.turns.length, equals(5));

      final greenTurn = EnergieversorgerScenario.turns[1];
      expect(greenTurn.utteranceDe, contains('Ökostrom'));

      final meterTurn = EnergieversorgerScenario.turns[2];
      expect(meterTurn.utteranceDe, contains('Zählerstand'));
      expect(meterTurn.utteranceAr, contains('قراءة أرقام العداد'));
    });
  });
}
