import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/release/anti_tamper_integrity_guard.dart';

void main() {
  group('AntiTamperIntegrityGuard Tests', () {
    const guard = AntiTamperIntegrityGuard();

    test('Clean genuine build passes sovereign security audit with green posture', () {
      final report = guard.auditRuntimeIntegrity(
        runtimePackageName: 'com.deutsch.polyglot',
        runtimeCertThumbprint: 'CERT_SHA256_POLYGLOT_SOVEREIGN_KEY_2026',
        loadedDynamicLibraries: ['libc.so', 'libflutter.so', 'libsqlite3.so'],
      );

      expect(report.isSignatureIntact, isTrue);
      expect(report.isPackageIdentityGenuine, isTrue);
      expect(report.isHookingFree, isTrue);
      expect(report.posture, equals(SecurityIntegrityPosture.sovereignSecure));
      expect(report.diagnosticNotice, equals('SOVEREIGN_INTEGRITY_VERIFIED_CLEAN'));
    });

    test('Intercepts repackaged counterfeit APK with modified signature', () {
      final report = guard.auditRuntimeIntegrity(
        runtimePackageName: 'com.deutsch.polyglot',
        runtimeCertThumbprint: 'MODIFIED_PIRATED_CERTIFICATE_KEY',
        loadedDynamicLibraries: ['libc.so'],
      );

      expect(report.isSignatureIntact, isFalse);
      expect(report.posture, equals(SecurityIntegrityPosture.tamperingDetectedContainment));
      expect(report.diagnosticNotice, contains('Repackaged or cloned binary detected'));
    });

    test('Detects active Frida instrumentation hooking library and triggers read-only lock', () {
      final report = guard.auditRuntimeIntegrity(
        runtimePackageName: 'com.deutsch.polyglot',
        runtimeCertThumbprint: 'CERT_SHA256_POLYGLOT_SOVEREIGN_KEY_2026',
        loadedDynamicLibraries: ['libc.so', 'libfrida-gadget.so'],
      );

      expect(report.isHookingFree, isFalse);
      expect(report.posture, equals(SecurityIntegrityPosture.hookingDetectedReadOnlyLock));
      expect(report.diagnosticNotice, contains('Dynamic instrumentation hook detected'));
    });
  });
}
