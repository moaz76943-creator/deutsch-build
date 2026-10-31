import 'package:test/test.dart';
import '../../lib/src/content/halal_einkauf_scenario.dart';

void main() {
  group('HalalEinkaufScenario Unit Tests (L026)', () {
    test('Contains ethical grocery shopping dialogue focusing on clean halal nutrition', () {
      expect(HalalEinkaufScenario.turns.length, equals(5));

      final inquiryTurn = HalalEinkaufScenario.turns[1];
      expect(inquiryTurn.utteranceDe, contains('ohne tierische Gelatine'));
      expect(inquiryTurn.utteranceDe, contains('ohne Alkohol'));

      final certTurn = HalalEinkaufScenario.turns[2];
      expect(certTurn.utteranceDe, contains('halal-zertifizierte Artikel'));
    });
  });
}
