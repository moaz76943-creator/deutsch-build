import 'package:test/test.dart';
import '../../lib/src/content/pillar2_scenarios_acceptance_gate.dart';

void main() {
  group('Pillar2ScenariosAcceptanceGate Unit Tests (L040)', () {
    test('All 20 Pillar 2 real-world scenarios are registered and certified sealed', () {
      final gate = Pillar2ScenariosAcceptanceGate();
      final report = gate.auditPillar();

      expect(report['totalScenarios'], equals(20));
      expect(report['isComplete'], isTrue);
      expect(report['ethicalAndHalalPurityPassed'], isTrue);
      expect(report['citizenshipExamsPermanentlyExcluded'], isTrue);
      expect(report['prohibitedLocaleAuditPassed'], isTrue);
      expect(report['certifiedSealed'], isTrue);
    });

    test('Strictly prohibited locales check includes Hebrew exclusions without omission', () {
      expect(Pillar2ScenariosAcceptanceGate.strictlyProhibitedLocales.contains('he'), isTrue);
    });
  });
}
