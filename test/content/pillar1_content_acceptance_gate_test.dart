import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/pillar1_content_acceptance_gate.dart';

void main() {
  group('Pillar1ContentAcceptanceGate Unit Tests (L020)', () {
    test('All 20 Pillar 1 lexical banks are registered and certified', () {
      final gate = Pillar1ContentAcceptanceGate();
      final report = gate.auditPillar();

      expect(report['totalBanks'], equals(20));
      expect(report['isComplete'], isTrue);
      expect(report['ethicalPurityAuditPassed'], isTrue);
      expect(report['citizenshipExamsExcluded'], isTrue);
      expect(report['prohibitedLocaleAuditPassed'], isTrue);
      expect(report['certifiedSealed'], isTrue);
    });

    test('Prohibited locales list covers Hebrew exclusions without omission', () {
      expect(Pillar1ContentAcceptanceGate.strictlyProhibitedLocales.contains('he'), isTrue);
    });
  });
}
