import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/security/data_integrity_signer.dart';
import 'package:deutsch_bilarabi/core/security/storage_guard.dart';
import 'package:deutsch_bilarabi/core/security/offline_gate.dart';

void main() {
  group('J024 Offline Security & Zero-Privilege Gate', () {
    test('OfflineGate denies unrestricted network access', () {
      expect(OfflineGate.isNetworkRequestPermitted(), isFalse);
      expect(() => OfflineGate.assertZeroNetworkPolicy(), throwsStateError);
      expect(OfflineGate.isTelemetryAllowed(), isFalse);
    });

    test('OfflineGate authorizes user download without granting general network access', () {
      // Forged authorization attempt
      expect(OfflineGate.authorizeUserDownload(false), isFalse);
      // Legitimate authorization
      expect(OfflineGate.authorizeUserDownload(true), isTrue);
      // General network permission remains false
      expect(OfflineGate.isNetworkRequestPermitted(), isFalse, reason: 'authorizeUserDownload should not grant general network access');
    });

    test('StorageGuard evaluates permissions explicitly', () {
      expect(StorageGuard.hasPermission(StoragePermission.read), isTrue);
      expect(StorageGuard.hasPermission(StoragePermission.write), isTrue);
    });

    test('DataIntegritySigner rejects missing algorithm or hash (Missing manifests)', () {
      expect(DataIntegritySigner.verifyManifest({'hash': 123}, 'test'), isFalse);
      expect(DataIntegritySigner.verifyManifest({'algorithm': 'fnv1a'}, 'test'), isFalse);
      expect(DataIntegritySigner.verifyManifest(null, 'test'), isFalse);
      expect(DataIntegritySigner.verifyManifest({'hash': 123, 'algorithm': 'fnv1a'}, null), isFalse);
      expect(DataIntegritySigner.verifyManifest({}, 'test'), isFalse);
    });

    test('DataIntegritySigner rejects unsupported algorithm', () {
      expect(DataIntegritySigner.verifyManifest({'hash': 123, 'algorithm': 'md5'}, 'test'), isFalse);
    });

    test('DataIntegritySigner rejects invalid hash', () {
      final payload = 'test payload';
      final expectedHash = DataIntegritySigner.computeChecksum(payload);
      expect(DataIntegritySigner.verifyManifest({'hash': expectedHash + 1, 'algorithm': 'fnv1a'}, payload), isFalse);
    });

    test('DataIntegritySigner accepts valid manifest', () {
      final payload = 'test payload';
      final expectedHash = DataIntegritySigner.computeChecksum(payload);
      expect(DataIntegritySigner.verifyManifest({'hash': expectedHash, 'algorithm': 'fnv1a'}, payload), isTrue);
    });

    test('DataIntegritySigner rejects expired capabilities', () {
      final payload = 'test payload';
      final expectedHash = DataIntegritySigner.computeChecksum(payload);
      final expiredTime = DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch;
      expect(DataIntegritySigner.verifyManifest({'hash': expectedHash, 'algorithm': 'fnv1a', 'expiresAt': expiredTime}, payload), isFalse);
    });
  });
}
