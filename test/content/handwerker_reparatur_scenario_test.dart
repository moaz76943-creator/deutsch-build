import 'package:test/test.dart';
import '../../lib/src/content/handwerker_reparatur_scenario.dart';

void main() {
  group('HandwerkerReparaturScenario Unit Tests (L036)', () {
    test('Contains realistic tenant maintenance communication and heating repair expressions', () {
      expect(HandwerkerReparaturScenario.turns.length, equals(5));

      final issueTurn = HandwerkerReparaturScenario.turns[1];
      expect(issueTurn.utteranceDe, contains('Heizung im Wohnzimmer'));
      expect(issueTurn.utteranceDe, contains('Thermostatventil'));

      final costTurn = HandwerkerReparaturScenario.turns.last;
      expect(costTurn.utteranceDe, contains('Reparaturkosten übernimmt'));
      expect(costTurn.utteranceAr, contains('تكاليف الإصلاح يتحملها'));
    });
  });
}
