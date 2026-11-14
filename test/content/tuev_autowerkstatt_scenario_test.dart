import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/tuev_autowerkstatt_scenario.dart';

void main() {
  group('TuevAutowerkstattScenario Unit Tests (L039)', () {
    test('Contains technical vehicle safety inspection and workshop integrity dialogue', () {
      expect(TuevAutowerkstattScenario.turns.length, equals(5));

      final tuevTurn = TuevAutowerkstattScenario.turns[1];
      expect(tuevTurn.utteranceDe, contains('Hauptuntersuchung'));
      expect(tuevTurn.utteranceDe, contains('TÜV-Plakette'));

      final trustTurn = TuevAutowerkstattScenario.turns.last;
      expect(trustTurn.utteranceDe, contains('Transparenz und Verkehrssicherheit'));
      expect(trustTurn.utteranceAr, contains('الشفافية التامة والسلامة المرورية'));
    });
  });
}
