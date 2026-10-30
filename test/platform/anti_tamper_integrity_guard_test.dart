import 'package:test/test.dart';
import '../../lib/src/platform/anti_tamper_integrity_guard.dart';

void main() {
  group('AntiTamperIntegrityGuard Unit Tests (N095)', () {
    const guard = AntiTamperIntegrityGuard();

    test('Verifies clean sovereign APK package matching trusted signer hash', () {
      final report = guard.auditAppIntegrity(
        runtimeSignerHash: 'POLYGLOT_SOVEREIGN_KEY_CERTIFIED_2026',
        isDebugEnvironment: false,
        installerPackageName: 'org.fdroid.fdroid',
      );

      expect(report.isBinaryTamperFree, isTrue);
      expect(report.isDebuggerAttached, isFalse);
      expect(report.integrityStatus, equals('INTEGRITY_VERIFIED_SECURE'));
    });

    test('Flags suspicious repacks with mismatched signature hash', () {
      final report = guard.auditAppIntegrity(
        runtimeSignerHash: 'MALICIOUS_REPACKER_KEY',
        isDebugEnvironment: false,
        installerPackageName: '',
      );

      expect(report.isBinaryTamperFree, isFalse);
      expect(report.integrityStatus, equals('TAMPER_ALERT_SUSPICIOUS'));
    });
  });
}
