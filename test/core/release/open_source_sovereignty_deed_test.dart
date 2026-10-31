import 'package:test/test.dart';
import 'package:deutsch_build/src/core/release/open_source_sovereignty_deed.dart';

void main() {
  group('OpenSourceSovereigntyDeed Tests', () {
    const deed = OpenSourceSovereigntyDeed();

    test('Certifies complete digital sovereignty with zero telemetry guarantee', () {
      final cert = deed.executeSovereigntyAudit();

      expect(cert.isZeroTelemetryVerified, isTrue);
      expect(cert.isReproducibleBuildCompliant, isTrue);
      expect(cert.canonicalLicense, equals('GPL-3.0-only'));
      expect(cert.totalAuditedDependencies, greaterThan(0));
      expect(cert.legalSovereigntyDeedText, contains('ZERO TELEMETRY'));
      expect(cert.legalSovereigntyDeedText, contains('GNU General Public License v3.0'));
    });

    test('Certificate serializes to standard open-source verification manifesto', () {
      final cert = deed.executeSovereigntyAudit();
      final json = cert.toJson();

      expect(json['canonicalLicense'], equals('GPL-3.0-only'));
      expect(json['status'], equals('SOVEREIGN_OPEN_SOURCE_CERTIFIED'));
    });
  });
}
