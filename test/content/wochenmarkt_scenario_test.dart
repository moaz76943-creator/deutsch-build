import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/wochenmarkt_scenario.dart';

void main() {
  group('WochenmarktScenario Unit Tests (L032)', () {
    test('Contains polite, authentic outdoor farmers market communication', () {
      expect(WochenmarktScenario.turns.length, equals(5));

      final orderTurn = WochenmarktScenario.turns[1];
      expect(orderTurn.utteranceDe, contains('zwei Kilo reife Äpfel'));
      expect(orderTurn.utteranceDe, contains('frische Minze'));

      final bioTurn = WochenmarktScenario.turns[2];
      expect(bioTurn.utteranceDe, contains('regionalem Bio-Anbau'));
    });
  });
}
