import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/sprachkurs_bibliothek_scenario.dart';

void main() {
  group('SprachkursBibliothekScenario Unit Tests (L030)', () {
    test('Contains enriching language course and library membership dialogue', () {
      expect(SprachkursBibliothekScenario.turns.length, equals(5));

      final applyTurn = SprachkursBibliothekScenario.turns[1];
      expect(applyTurn.utteranceDe, contains('B2-Sprachkurs anmelden'));
      expect(applyTurn.utteranceDe, contains('Bibliotheksausweis beantragen'));

      final testTurn = SprachkursBibliothekScenario.turns[2];
      expect(testTurn.utteranceDe, contains('Einstufungstest'));
    });
  });
}
