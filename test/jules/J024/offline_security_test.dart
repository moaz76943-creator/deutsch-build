import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/security/offline_gate.dart';
import 'package:deutsch_bilarabi/core/security/data_integrity_signer.dart';

void main() {
  group('J024 - Offline Security, Content Trust & Zero-Privilege Gate', () {

    test('forged authorization rejection', () {
      final auth = DownloadAuthorization(
        expiresAt: DateTime.now().add(const Duration(days: 1)),
        signature: 'forged',
      );
      expect(auth.isAuthorized(), isFalse);
      expect(OfflineGate.isNetworkRequestPermitted(NetworkOperation.download, auth), isFalse);
      expect(
        () => OfflineGate.assertZeroNetworkPolicy(NetworkOperation.download, auth),
        throwsException,
      );
    });

    test('expired capabilities rejection', () {
      final auth = DownloadAuthorization(
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        signature: 'valid_sig_but_expired',
      );
      expect(auth.isAuthorized(), isFalse);
      expect(OfflineGate.isNetworkRequestPermitted(NetworkOperation.download, auth), isFalse);
      expect(
        () => OfflineGate.assertZeroNetworkPolicy(NetworkOperation.download, auth),
        throwsException,
      );
    });

    test('network telemetry and general operations denial', () {
      expect(OfflineGate.isNetworkRequestPermitted(NetworkOperation.telemetry), isFalse);
      expect(
        () => OfflineGate.assertZeroNetworkPolicy(NetworkOperation.telemetry),
        throwsException,
      );

      expect(OfflineGate.isNetworkRequestPermitted(NetworkOperation.general), isFalse);
      expect(
        () => OfflineGate.assertZeroNetworkPolicy(NetworkOperation.general),
        throwsException,
      );
    });

    test('valid authorized download success', () {
      final auth = DownloadAuthorization(
        expiresAt: DateTime.now().add(const Duration(days: 1)),
        signature: 'valid_signature_123',
      );
      expect(auth.isAuthorized(), isTrue);
      expect(OfflineGate.isNetworkRequestPermitted(NetworkOperation.download, auth), isTrue);
      expect(
        () => OfflineGate.assertZeroNetworkPolicy(NetworkOperation.download, auth),
        returnsNormally,
      );
    });

    test('missing manifest rejection', () {
      expect(DataIntegritySigner.verifyManifestIntegrity(null, 'payload'), isFalse);
    });

    test('altered content hash mismatch rejection', () {
      final payload = 'my secret payload';
      final expectedHash = DataIntegritySigner.computeChecksum(payload);

      final manifest = {
        'trustedKey': true,
        'hash': expectedHash,
      };

      expect(DataIntegritySigner.verifyManifestIntegrity(manifest, 'altered payload'), isFalse);
    });

    test('unsupported signing metadata rejection (trustedKey missing or false)', () {
      final payload = 'my secret payload';
      final expectedHash = DataIntegritySigner.computeChecksum(payload);

      final manifest1 = {
        'hash': expectedHash,
      };
      final manifest2 = {
        'trustedKey': false,
        'hash': expectedHash,
      };

      expect(DataIntegritySigner.verifyManifestIntegrity(manifest1, payload), isFalse);
      expect(DataIntegritySigner.verifyManifestIntegrity(manifest2, payload), isFalse);
    });

    test('missing hash in manifest rejection', () {
      final manifest = {
        'trustedKey': true,
      };

      expect(DataIntegritySigner.verifyManifestIntegrity(manifest, 'payload'), isFalse);
    });

    test('valid content integrity success', () {
      final payload = 'my secret payload';
      final expectedHash = DataIntegritySigner.computeChecksum(payload);

      final manifest = {
        'trustedKey': true,
        'hash': expectedHash,
      };

      expect(DataIntegritySigner.verifyManifestIntegrity(manifest, payload), isTrue);
    });

  });
}
