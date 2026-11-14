import 'dart:io';
import 'package:test/test.dart';
import '../../../lib/polyglot_core.dart';

void main() {
  group('Task #4991: Curriculum Analytics & Zero-PII Health Gate Tests', () {
    late PolyglotAppBootstrap app;

    setUp(() {
      final extra = File('assets/packs/de_pragmatics_and_idioms.json').readAsStringSync();
      app = PolyglotAppBootstrap.initialize(extraJsonPacks: [extra]);
    });

    tearDown(() async {
      await app.dispose();
    });

    test('Audits full unified registry and confirms zero PII or incomplete units', () {
      final report = PolyglotAnalyticsAndHealthGate.auditRegistry(
        app.registry,
        srsScheduler: app.srsScheduler,
      );
      expect(report.isHealthy, isTrue);
      expect(report.zeroPiiCompliant, isTrue);
      expect(report.policyViolations, isEmpty);
      expect(report.totalUnits, greaterThanOrEqualTo(350));
      expect(report.unitsByDomain['business'], greaterThanOrEqualTo(3));
    });
  });
}
