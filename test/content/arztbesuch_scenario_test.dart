import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/arztbesuch_scenario.dart';

void main() {
  group('ArztbesuchScenario Unit Tests (L024)', () {
    test('Contains authentic medical consultation dialogue with symptom expressions', () {
      expect(ArztbesuchScenario.turns.length, equals(5));

      final phoneTurn = ArztbesuchScenario.turns.first;
      expect(phoneTurn.utteranceDe, contains('Praxis Dr. Weber'));

      final symptomTurn = ArztbesuchScenario.turns[1];
      expect(symptomTurn.utteranceDe, contains('Halsschmerzen und Fieber'));
      expect(symptomTurn.utteranceAr, contains('ألم شديد في الحلق'));
    });
  });
}
