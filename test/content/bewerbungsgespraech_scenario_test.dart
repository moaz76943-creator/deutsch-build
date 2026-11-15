import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/bewerbungsgespraech_scenario.dart';

void main() {
  group('BewerbungsgespraechScenario Unit Tests (L025)', () {
    test('Contains authentic professional job interview dialogue with career expressions', () {
      expect(BewerbungsgespraechScenario.turns.length, equals(5));

      final introTurn = BewerbungsgespraechScenario.turns.first;
      expect(introTurn.utteranceDe, contains('Werdegang'));

      final strengthsTurn = BewerbungsgespraechScenario.turns[3];
      expect(strengthsTurn.utteranceDe, contains('Zuverlässigkeit'));
      expect(strengthsTurn.utteranceAr, contains('الأمانة والموثوقية'));
    });
  });
}
