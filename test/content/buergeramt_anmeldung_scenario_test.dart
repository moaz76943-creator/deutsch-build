import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/buergeramt_anmeldung_scenario.dart';

void main() {
  group('BuergeramtAnmeldungScenario Unit Tests (L021)', () {
    test('Script provides complete realistic and respectful Bürgeramt dialogue', () {
      expect(BuergeramtAnmeldungScenario.turns.length, equals(5));

      final firstTurn = BuergeramtAnmeldungScenario.turns.first;
      expect(firstTurn.speaker, equals('clerk'));
      expect(firstTurn.utteranceDe, contains('Termin zur Anmeldung'));

      final lastTurn = BuergeramtAnmeldungScenario.turns.last;
      expect(lastTurn.utteranceDe, contains('Meldebescheinigung'));
    });
  });
}
