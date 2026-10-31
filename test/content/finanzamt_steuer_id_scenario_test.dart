import 'package:test/test.dart';
import '../../lib/src/content/finanzamt_steuer_id_scenario.dart';

void main() {
  group('FinanzamtSteuerIdScenario Unit Tests (L033)', () {
    test('Contains accurate administrative tax identification procedure dialogue', () {
      expect(FinanzamtSteuerIdScenario.turns.length, equals(5));

      final taxTurn = FinanzamtSteuerIdScenario.turns[1];
      expect(taxTurn.utteranceDe, contains('Steuer-Identifikationsnummer'));
      expect(taxTurn.utteranceDe, contains('Lohnabrechnung'));

      final certTurn = FinanzamtSteuerIdScenario.turns.last;
      expect(certTurn.utteranceDe, contains('Bestätigungsbeleg'));
      expect(certTurn.utteranceAr, contains('إفادة التأكيد'));
    });
  });
}
