import 'package:test/test.dart';
import '../../lib/src/platform/keystore_signing_v4_pipeline.dart';

void main() {
  group('KeystoreSigningV4Pipeline Unit Tests (N091)', () {
    final pipeline = KeystoreSigningV4Pipeline();

    test('Validates untampered APK Signature Scheme v4 with full 64-character SHA256 digest', () {
      final report = pipeline.verifyApkSignature(
        packageSignatureHex: '308203f...',
        computedSha256: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
        hasApkChannelV4Block: true,
      );

      expect(report.isV4SignatureValid, isTrue);
      expect(report.isIntegrityTamperFree, isTrue);
      expect(report.signingAlgorithm, equals('RSA-PSS-SHA256'));
      expect(report.certFingerprintSha256, equals(KeystoreSigningV4Pipeline.trustedPolyglotFingerprint));
    });

    test('Rejects packages missing v4 channel signature block', () {
      final report = pipeline.verifyApkSignature(
        packageSignatureHex: '3082...',
        computedSha256: 'abc',
        hasApkChannelV4Block: false,
      );

      expect(report.isV4SignatureValid, isFalse);
      expect(report.isIntegrityTamperFree, isFalse);
    });
  });
}
