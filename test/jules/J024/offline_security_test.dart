import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/security/offline_gate.dart';
import 'package:deutsch_bilarabi/core/security/storage_guard.dart';
import 'package:deutsch_bilarabi/core/security/data_integrity_signer.dart';

void main() {
  group('Offline Security and Integrity Tests (J024)', () {
    test('Unrestricted network access is denied by default', () {
      expect(OfflineGate.isNetworkRequestPermitted(), isFalse);
      expect(() => OfflineGate.assertZeroNetworkPolicy(), throwsStateError);
    });

    test('User-directed download authorization does not grant general network access', () {
      final authorized = OfflineGate.authorizeUserDownload(true);
      expect(authorized, isTrue);
      // General network should still be denied
      expect(OfflineGate.isNetworkRequestPermitted(), isFalse);
    });

    test('Telemetry is forbidden', () {
      expect(OfflineGate.isTelemetryAllowed(), isFalse);
    });

    test('Forged authorization is rejected', () {
      expect(OfflineGate.authorizeUserDownload(false), isFalse);
    });

    test('Storage local operations are explicitly permitted', () {
      expect(StorageGuard.isLocalReadPermitted(), isTrue);
      expect(StorageGuard.isLocalWritePermitted(), isTrue);
      expect(StorageGuard.hasPermission(StoragePermission.read), isTrue);
      expect(StorageGuard.hasPermission(StoragePermission.write), isTrue);
    });

    test('Missing manifests are rejected', () {
      expect(DataIntegritySigner.verifyManifest(null, 'payload'), isFalse);
      expect(DataIntegritySigner.verifyManifest({'algorithm': 'fnv1a', 'hash': 123}, null), isFalse);
    });

    test('Altered content is rejected', () {
      final payload = 'my secure content';
      final hash = DataIntegritySigner.computeChecksum(payload);

      final manifest = {
        'algorithm': 'fnv1a',
        'hash': hash,
      };

      expect(DataIntegritySigner.verifyManifest(manifest, payload), isTrue);
      expect(DataIntegritySigner.verifyManifest(manifest, 'altered content'), isFalse);
    });

    test('Expired capabilities are rejected', () {
      final payload = 'content';
      final hash = DataIntegritySigner.computeChecksum(payload);
      final manifest = {
        'algorithm': 'fnv1a',
        'hash': hash,
        'expiresAt': DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch,
      };

      expect(DataIntegritySigner.verifyManifest(manifest, payload), isFalse);
    });

    test('Unsupported signing metadata is rejected', () {
      final payload = 'content';
      final hash = DataIntegritySigner.computeChecksum(payload);

      expect(DataIntegritySigner.verifyManifest({
        'algorithm': 'unknown_algo',
        'hash': hash,
      }, payload), isFalse);
    });
  });
}
