import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/semantic_search/pillar3_search_acceptance_gate.dart';

void main() {
  group('Pillar3SearchAcceptanceGate Unit Tests (N060)', () {
    test('All 20 Pillar 3 engines are registered and verified', () {
      final gate = Pillar3SearchAcceptanceGate();
      final report = gate.auditPillar();

      expect(report['totalEngines'], equals(20));
      expect(report['isComplete'], isTrue);
      expect(report['prohibitedLocaleAuditPassed'], isTrue);
      expect(report['certifiedSealed'], isTrue);
      expect(report['zeroCloudDependency'], isTrue);
    });

    test('Prohibited locales coverage is strict', () {
      expect(Pillar3SearchAcceptanceGate.prohibitedLocales.contains('he'), isTrue);
    });
  });
}
