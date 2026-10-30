import 'package:test/test.dart';
import '../../lib/src/core/voice_cloning/pillar1_voice_cloning_acceptance_gate.dart';

void main() {
  group('Pillar1VoiceCloningAcceptanceGate Unit Tests (N020)', () {
    test('All 20 Pillar 1 engines are registered and verified', () {
      final gate = Pillar1VoiceCloningAcceptanceGate();
      final report = gate.auditPillar();

      expect(report['totalEngines'], equals(20));
      expect(report['isComplete'], isTrue);
      expect(report['prohibitedLocaleAuditPassed'], isTrue);
      expect(report['certifiedSealed'], isTrue);
      expect(report['sovereignPrivacyStatus'], equals('VERIFIED_100_PERCENT_OFFLINE'));
    });

    test('Prohibited locales list strictly covers Hebrew exclusions', () {
      expect(Pillar1VoiceCloningAcceptanceGate.prohibitedLocales.contains('he'), isTrue);
      expect(Pillar1VoiceCloningAcceptanceGate.prohibitedLocales.contains('heb'), isTrue);
    });
  });
}
