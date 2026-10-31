import 'package:test/test.dart';
import 'package:deutsch_build/src/core/dialogue/pillar4_dialogue_acceptance_gate.dart';

void main() {
  group('Pillar4DialogueAcceptanceGate Tests', () {
    const gate = Pillar4DialogueAcceptanceGate();

    test('All 20 Pillar 4 dialogue engines pass end-to-end integration gate', () {
      final report = gate.executeFullPillarAudit();

      expect(report.all20DialogueEnginesOperational, isTrue);
      expect(report.zeroCloudTelemetryGuaranteed, isTrue);
      expect(report.verifiedPeakRamFootprintMb, lessThan(180.0));
      expect(report.hallucinationRatePercent, equals(0.0));
      expect(report.complianceVerdict, equals('PILLAR_4_PASSED_SOVEREIGN_GRADE'));
    });

    test('Audit report serializes to complete release metadata', () {
      final report = gate.executeFullPillarAudit();
      final json = report.toJson();

      expect(json['all20DialogueEnginesOperational'], isTrue);
      expect(json['complianceVerdict'], contains('PASSED'));
    });
  });
}
