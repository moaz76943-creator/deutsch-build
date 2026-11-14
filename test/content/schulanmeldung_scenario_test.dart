import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/schulanmeldung_scenario.dart';

void main() {
  group('SchulanmeldungScenario Unit Tests (L027)', () {
    test('Contains positive and constructive school enrollment parent dialogue', () {
      expect(SchulanmeldungScenario.turns.length, equals(5));

      final schoolTurn = SchulanmeldungScenario.turns.first;
      expect(schoolTurn.utteranceDe, contains('Grundschule anmelden'));

      final supportTurn = SchulanmeldungScenario.turns.last;
      expect(supportTurn.utteranceDe, contains('Förderprogramm für zweisprachige Kinder'));
      expect(supportTurn.utteranceAr, contains('ثنائيي اللغة'));
    });
  });
}
