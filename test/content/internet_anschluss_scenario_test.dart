import 'package:test/test.dart';
import '../../lib/src/content/internet_anschluss_scenario.dart';

void main() {
  group('InternetAnschlussScenario Unit Tests (L031)', () {
    test('Contains realistic telecommunications and router activation dialogue', () {
      expect(InternetAnschlussScenario.turns.length, equals(5));

      final fiberTurn = InternetAnschlussScenario.turns[1];
      expect(fiberTurn.utteranceDe, contains('Glasfaser-Internetanschluss'));

      final activationTurn = InternetAnschlussScenario.turns.last;
      expect(activationTurn.utteranceDe, contains('Freischaltung'));
      expect(activationTurn.utteranceAr, contains('تفعيل الخط'));
    });
  });
}
