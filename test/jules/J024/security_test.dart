import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/security/data_integrity_signer.dart';
import 'package:deutsch_bilarabi/core/security/offline_gate.dart';
import 'package:deutsch_bilarabi/core/security/storage_guard.dart';

void main() {
  group('Security Gate Tests', () {
    test('missing manifest is rejected', () {
      expect(DataIntegritySigner.verifyManifestIntegrity(null, 'test'), isFalse);
    });

    test('altered content is rejected', () {
      final payload = 'test payload';
      final hash = DataIntegritySigner.computeChecksum(payload);
      final manifest = {'trustedKey': true, 'hash': hash};

      expect(DataIntegritySigner.verifyManifestIntegrity(manifest, 'test payload'), isTrue);
      expect(DataIntegritySigner.verifyManifestIntegrity(manifest, 'altered payload'), isFalse);
    });

    test('expired capabilities are rejected', () {
      final auth = DownloadAuthorization(
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        signature: 'valid-signature',
      );
      expect(auth.isAuthorized(), isFalse);
      expect(OfflineGate.isNetworkRequestPermitted(NetworkOperation.download, auth), isFalse);
    });

    test('forged authorization is rejected', () {
      final auth = DownloadAuthorization(
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        signature: 'forged',
      );
      expect(auth.isAuthorized(), isFalse);
      expect(OfflineGate.isNetworkRequestPermitted(NetworkOperation.download, auth), isFalse);
    });

    test('network denial by default', () {
      expect(OfflineGate.isNetworkRequestPermitted(), isFalse);
      expect(OfflineGate.isNetworkRequestPermitted(NetworkOperation.telemetry), isFalse);
      expect(() => OfflineGate.assertZeroNetworkPolicy(NetworkOperation.general), throwsException);
      expect(() => OfflineGate.assertZeroNetworkPolicy(NetworkOperation.telemetry), throwsException);
    });

    test('unsupported signing metadata is rejected', () {
      final payload = 'test payload';
      final hash = DataIntegritySigner.computeChecksum(payload);
      final manifest1 = {'trustedKey': true, 'hash': hash, 'unsupportedAlgorithm': true};
      final manifest2 = {'trustedKey': true, 'hash': hash, 'algorithm': 'unsupported'};

      expect(DataIntegritySigner.verifyManifestIntegrity(manifest1, payload), isFalse);
      expect(DataIntegritySigner.verifyManifestIntegrity(manifest2, payload), isFalse);
    });

    test('isolated download authorization does not grant general access', () {
      final auth = DownloadAuthorization(
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        signature: 'valid-signature',
      );
      expect(auth.isAuthorized(), isTrue);
      expect(OfflineGate.isNetworkRequestPermitted(NetworkOperation.download, auth), isTrue);
      expect(OfflineGate.isNetworkRequestPermitted(NetworkOperation.general, auth), isFalse);
      expect(OfflineGate.isNetworkRequestPermitted(NetworkOperation.telemetry, auth), isFalse);
    });

    test('local read/write operations are permitted', () {
      expect(StorageGuard.hasPermission(StoragePermission.read), isTrue);
      expect(StorageGuard.hasPermission(StoragePermission.write), isTrue);
    });

    test('sanitizeWordEntries handles malformed entries gracefully', () {
       final malformedEntries = [
         {'validKey': 'validValue'},
         ['not', 'a', 'map'],
         'string entry',
         42,
       ];
       final sanitized = StorageGuard.sanitizeWordEntries(malformedEntries);
       expect(sanitized.length, 1);
       expect(sanitized.first, {'validKey': 'validValue'});
    });
  });
}
