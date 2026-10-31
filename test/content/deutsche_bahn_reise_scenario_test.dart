import 'package:test/test.dart';
import '../../lib/src/content/deutsche_bahn_reise_scenario.dart';

void main() {
  group('DeutscheBahnReiseScenario Unit Tests (L038)', () {
    test('Contains realistic high-speed train booking dialogue with rail travel expressions', () {
      expect(DeutscheBahnReiseScenario.turns.length, equals(5));

      final trainTurn = DeutscheBahnReiseScenario.turns[1];
      expect(trainTurn.utteranceDe, contains('schnellen ICE'));

      final quietAreaTurn = DeutscheBahnReiseScenario.turns[2];
      expect(quietAreaTurn.utteranceDe, contains('Ruhebereich'));
      expect(quietAreaTurn.utteranceAr, contains('مقصورة الهدوء'));
    });
  });
}
