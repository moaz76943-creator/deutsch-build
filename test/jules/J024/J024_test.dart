import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/security/offline_gate.dart';
import 'package:deutsch_bilarabi/core/security/storage_guard.dart';
import 'package:deutsch_bilarabi/core/security/data_integrity_signer.dart';

void main() {
  group('OfflineGate', () {
    test('forged authorization returns null', () {
      final capability = OfflineGate.authorizeUserDownload(false, 'test_content_id');
      expect(capability, isNull);
    });

    test('valid authorization returns capability', () {
      final capability = OfflineGate.authorizeUserDownload(true, 'test_content_id');
      expect(capability, isNotNull);
      expect(capability!.contentId, 'test_content_id');
      expect(capability.isExpired, isFalse);
    });

    test('expired capabilities are rejected', () {
      final pastCapability = DownloadCapability(
        expiresAt: DateTime.now().millisecondsSinceEpoch - 1000,
        contentId: 'test_content_id',
      );
      expect(pastCapability.isExpired, isTrue);

      final isPermitted = OfflineGate.isOperationPermitted(
        OperationType.userRequestedDownload,
        capability: pastCapability,
      );
      expect(isPermitted, isFalse);
    });

    test('network denial throws', () {
      expect(
        () => OfflineGate.assertZeroNetworkPolicy(),
        throwsStateError,
      );
    });

    test('telemetry is forbidden', () {
      expect(OfflineGate.isTelemetryAllowed(), isFalse);
      expect(
        OfflineGate.isOperationPermitted(OperationType.telemetry),
        isFalse,
      );
    });
  });

  group('StorageGuard', () {
    test('local read and write are permitted via OfflineGate delegation', () {
      expect(StorageGuard.isLocalReadPermitted(), isTrue);
      expect(StorageGuard.isLocalWritePermitted(), isTrue);
      expect(StorageGuard.hasPermission(StoragePermission.read), isTrue);
      expect(StorageGuard.hasPermission(StoragePermission.write), isTrue);
    });
  });

  group('DataIntegritySigner', () {
    test('missing or invalid manifests are rejected', () {
      expect(DataIntegritySigner.verifyManifest(null, 'payload'), isFalse);
      expect(DataIntegritySigner.verifyManifest({'keyId': 'key-prod-ed25519-v1'}, null), isFalse);
      expect(DataIntegritySigner.verifyManifest({'keyId': 'key-prod-ed25519-v1'}, ''), isFalse);
      expect(
        DataIntegritySigner.verifyManifest(
          {'keyId': 'wrong-key', 'algorithm': 'fnv1a', 'hash': 123},
          'payload',
        ),
        isFalse,
      );
      expect(
        DataIntegritySigner.verifyManifest(
          {'keyId': 'key-prod-ed25519-v1', 'algorithm': 'wrong-algo', 'hash': 123},
          'payload',
        ),
        isFalse,
      );
    });

    test('altered content is rejected', () {
      final validPayload = '{"test": "data"}';
      final expectedHash = DataIntegritySigner.computeChecksum(validPayload);
      final manifest = {
        'keyId': 'key-prod-ed25519-v1',
        'algorithm': 'fnv1a',
        'hash': expectedHash,
      };

      expect(DataIntegritySigner.verifyManifest(manifest, validPayload), isTrue);
      expect(DataIntegritySigner.verifyManifest(manifest, '{"test": "altered"}'), isFalse);
      expect(
        DataIntegritySigner.verifyManifest(
          {
            'keyId': 'key-prod-ed25519-v1',
            'algorithm': 'fnv1a',
            'hash': expectedHash + 1,
          },
          validPayload,
        ),
        isFalse,
      );
    });

    test('expired manifest is rejected', () {
      final validPayload = '{"test": "data"}';
      final expectedHash = DataIntegritySigner.computeChecksum(validPayload);
      final manifest = {
        'keyId': 'key-prod-ed25519-v1',
        'algorithm': 'fnv1a',
        'hash': expectedHash,
        'expiresAt': DateTime.now().millisecondsSinceEpoch - 1000,
      };

      expect(DataIntegritySigner.verifyManifest(manifest, validPayload), isFalse);
    });
  });
}
