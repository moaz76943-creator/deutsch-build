import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/security/offline_gate.dart';
import 'package:deutsch_bilarabi/core/security/data_integrity_signer.dart';
import 'package:deutsch_bilarabi/core/security/storage_guard.dart';

void main() {
  group('OfflineGate J024 Tests', () {
    test('OfflineGate denies network access by default', () {
      expect(OfflineGate.isNetworkRequestPermitted(), isFalse);
      expect(OfflineGate.strictOfflineEnforced, isTrue);

      expect(
        () => OfflineGate.assertZeroNetworkPolicy(),
        throwsA(isA<StateError>()),
      );
    });

    test('OfflineGate authorizes download strictly on consent', () {
      expect(OfflineGate.authorizeUserDownload(true), isTrue);
      expect(OfflineGate.authorizeUserDownload(false), isFalse);

      // Ensure authorization doesn't flip global state
      expect(OfflineGate.strictOfflineEnforced, isTrue);
      expect(OfflineGate.isNetworkRequestPermitted(), isFalse);
    });

    test('OfflineGate denies telemetry', () {
      expect(OfflineGate.isTelemetryAllowed(), isFalse);
    });
  });

  group('DataIntegritySigner J024 Tests', () {
    final validPayload = '{"data": "test"}';
    final validHash = DataIntegritySigner.computeChecksum(validPayload);

    test('DataIntegritySigner rejects missing/empty payload', () {
      final manifest = {'algorithm': 'fnv1a', 'hash': validHash};
      expect(DataIntegritySigner.verifyManifest(manifest, null), isFalse);
      expect(DataIntegritySigner.verifyManifest(manifest, ''), isFalse);
    });

    test('DataIntegritySigner rejects invalid algorithm', () {
      final manifest = {'algorithm': 'sha256', 'hash': validHash};
      expect(DataIntegritySigner.verifyManifest(manifest, validPayload), isFalse);

      final manifest2 = {'hash': validHash};
      expect(DataIntegritySigner.verifyManifest(manifest2, validPayload), isFalse);
    });

    test('DataIntegritySigner rejects missing or invalid hash', () {
      final manifest = {'algorithm': 'fnv1a'};
      expect(DataIntegritySigner.verifyManifest(manifest, validPayload), isFalse);

      final manifest2 = {'algorithm': 'fnv1a', 'hash': 'not-an-int'};
      expect(DataIntegritySigner.verifyManifest(manifest2, validPayload), isFalse);

      final manifest3 = {'algorithm': 'fnv1a', 'hash': 12345};
      expect(DataIntegritySigner.verifyManifest(manifest3, validPayload), isFalse);
    });

    test('DataIntegritySigner rejects expired manifest or invalid expiresAt', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch;
      final manifest = {'algorithm': 'fnv1a', 'hash': validHash, 'expiresAt': pastDate};
      expect(DataIntegritySigner.verifyManifest(manifest, validPayload), isFalse);

      final manifest2 = {'algorithm': 'fnv1a', 'hash': validHash, 'expiresAt': 'not-an-int'};
      expect(DataIntegritySigner.verifyManifest(manifest2, validPayload), isFalse);
    });

    test('DataIntegritySigner accepts valid manifest', () {
      final futureDate = DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch;
      final manifest = {'algorithm': 'fnv1a', 'hash': validHash, 'expiresAt': futureDate};
      expect(DataIntegritySigner.verifyManifest(manifest, validPayload), isTrue);

      final manifest2 = {'algorithm': 'fnv1a', 'hash': validHash};
      expect(DataIntegritySigner.verifyManifest(manifest2, validPayload), isTrue);
    });
  });

  group('StorageGuard J024 Tests', () {
    test('StorageGuard allows local read/write', () {
      expect(StorageGuard.hasPermission(StoragePermission.read), isTrue);
      expect(StorageGuard.hasPermission(StoragePermission.write), isTrue);
    });
  });
}
