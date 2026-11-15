import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/wohnungssuche_scenario.dart';

void main() {
  group('WohnungssucheScenario Unit Tests (L023)', () {
    test('Contains realistic apartment viewing and rent breakdown dialogue', () {
      expect(WohnungssucheScenario.turns.length, equals(5));

      final rentTurn = WohnungssucheScenario.turns[1];
      expect(rentTurn.utteranceDe, contains('Warmmiete'));

      final costTurn = WohnungssucheScenario.turns[2];
      expect(costTurn.utteranceDe, contains('Nebenkosten'));
      expect(costTurn.utteranceAr, contains('المصاريف التشغيلية'));
    });
  });
}
