import 'package:test/test.dart';
import '../../lib/src/content/pillar3_exams_acceptance_gate.dart';

void main() {
  group('Pillar3ExamsAcceptanceGate Unit Tests (L060)', () {
    test('All 20 Pillar 3 CEFR exam models are registered and certified sealed', () {
      final gate = Pillar3ExamsAcceptanceGate();
      final report = gate.auditPillar();

      expect(report['totalModules'], equals(20));
      expect(report['isComplete'], isTrue);
      expect(report['intellectualPropertyStrictCompliance'], isTrue);
      expect(report['germanCitizenshipExamsPermanentlyExcluded'], isTrue);
      expect(report['ethicalAndHalalPurityPassed'], isTrue);
      expect(report['prohibitedLocaleAuditPassed'], isTrue);
      expect(report['certifiedSealed'], isTrue);
    });

    test('Strictly prohibited locales check includes Hebrew exclusions without omission', () {
      expect(Pillar3ExamsAcceptanceGate.strictlyProhibitedLocales.contains('he'), isTrue);
    });
  });
}
