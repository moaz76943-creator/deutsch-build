import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/sovereign_pack_integrity_verifier.dart';

void main() {
  group('SovereignPackIntegrityVerifier Unit Tests (L082)', () {
    final verifier = SovereignPackIntegrityVerifier();

    test('Validates authentic pack with matching 64-char SHA-256 and expected records', () {
      const sha = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';
      final report = verifier.verifyPack(
        packId: 'de_ar_a1_core',
        computedSha256: sha,
        expectedSha256: sha,
        actualRecordCount: 1500,
        expectedRecordCount: 1500,
      );

      expect(report.isDigestValid, isTrue);
      expect(report.isHeaderTamperFree, isTrue);
      expect(report.securityStatus, equals('PACK_VERIFIED_AUTHENTIC'));
    });

    test('Rejects tampered packs with checksum mismatch', () {
      final report = verifier.verifyPack(
        packId: 'de_ar_a1_core',
        computedSha256: 'corrupted_hash',
        expectedSha256: 'expected_hash_64_characters_long_1234567890123456789012345678901234',
        actualRecordCount: 100,
        expectedRecordCount: 1500,
      );

      expect(report.isDigestValid, isFalse);
      expect(report.securityStatus, equals('PACK_TAMPER_ALERT'));
    });
  });
}
