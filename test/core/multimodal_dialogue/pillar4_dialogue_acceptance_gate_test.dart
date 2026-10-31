import 'package:test/test.dart';
import '../../lib/src/core/multimodal_dialogue/pillar4_dialogue_acceptance_gate.dart';

void main() {
  group('Pillar4DialogueAcceptanceGate Unit Tests (N080)', () {
    test('All 20 Pillar 4 engines are registered and verified', () {
      final gate = Pillar4DialogueAcceptanceGate();
      final report = gate.auditPillar();

      expect(report['totalEngines'], equals(20));
      expect(report['isComplete'], isTrue);
      expect(report['prohibitedLocaleAuditPassed'], isTrue);
      expect(report['fullDuplexCertified'], isTrue);
      expect(report['certifiedSealed'], isTrue);
    });

    test('Prohibited locales list covers Hebrew exclusions without omission', () {
      expect(Pillar4DialogueAcceptanceGate.prohibitedLocales.contains('he'), isTrue);
    });
  });
}
