import 'package:test/test.dart';
import '../../lib/src/content/pillar4_corpora_acceptance_gate.dart';

void main() {
  group('Pillar4CorporaAcceptanceGate Unit Tests (L080)', () {
    test('All 20 Pillar 4 bitext corpora and stories are registered and certified sealed', () {
      final gate = Pillar4CorporaAcceptanceGate();
      final report = gate.auditPillar();

      expect(report['totalCorpora'], equals(20));
      expect(report['isComplete'], isTrue);
      expect(report['ethicalPurityAuditPassed'], isTrue);
      expect(report['germanCitizenshipExamsPermanentlyExcluded'], isTrue);
      expect(report['prohibitedLocaleAuditPassed'], isTrue);
      expect(report['certifiedSealed'], isTrue);
    });

    test('Strictly prohibited locales check includes Hebrew exclusions without omission', () {
      expect(Pillar4CorporaAcceptanceGate.strictlyProhibitedLocales.contains('he'), isTrue);
    });
  });
}
