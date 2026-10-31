import 'package:test/test.dart';
import 'package:deutsch_build/src/core/security/zero_telemetry_policy_guard.dart';

void main() {
  group('ZeroTelemetryPolicyGuard Tests', () {
    const guard = ZeroTelemetryPolicyGuard();

    test('Blocks external outbound network hosts strictly', () {
      expect(guard.isOutboundAllowed('api.google.com'), isFalse);
      expect(guard.isOutboundAllowed('telemetry.analytics.io'), isFalse);
      expect(guard.isOutboundAllowed('firebase.com'), isFalse);
    });

    test('Allows loopback for internal testing', () {
      expect(guard.isOutboundAllowed('localhost'), isTrue);
      expect(guard.isOutboundAllowed('127.0.0.1'), isTrue);
    });

    test('Produces valid compliance report', () {
      final report = guard.generateComplianceReport();
      expect(report['isCompliant'], isTrue);
      expect(report['thirdPartyTrackers'], equals(0));
    });
  });
}
