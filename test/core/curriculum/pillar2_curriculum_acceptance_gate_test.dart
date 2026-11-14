import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/curriculum/pillar2_curriculum_acceptance_gate.dart';

void main() {
  group('Pillar2CurriculumAcceptanceGate Unit Tests (N040)', () {
    test('All 20 Pillar 2 engines are registered and verified', () {
      final gate = Pillar2CurriculumAcceptanceGate();
      final report = gate.auditPillar();

      expect(report['totalEngines'], equals(20));
      expect(report['isComplete'], isTrue);
      expect(report['prohibitedLocaleAuditPassed'], isTrue);
      expect(report['certifiedSealed'], isTrue);
      expect(report['cefrCoverage'], equals('A1_THROUGH_C2_FULL_SPECTRUM'));
    });

    test('Prohibited locales list covers Hebrew exclusions without omission', () {
      expect(Pillar2CurriculumAcceptanceGate.prohibitedLocales.contains('he'), isTrue);
    });
  });
}
