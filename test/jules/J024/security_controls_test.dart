import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/security/data_integrity_signer.dart';
import 'package:deutsch_bilarabi/core/security/ed25519_signature_verifier.dart';
import 'package:deutsch_bilarabi/core/security/offline_gate.dart';
import 'package:deutsch_bilarabi/core/security/storage_guard.dart';

void main() {
  group('DataIntegritySigner tests', () {
    test('missing manifest or payload is rejected', () {
      expect(DataIntegritySigner.verifyManifest(null, 'payload'), isFalse);
      expect(DataIntegritySigner.verifyManifest({'hash': 123}, null), isFalse);
    });

    test('altered content (invalid hash) is rejected', () {
      final payload = 'my secret payload';
      final expectedHash = DataIntegritySigner.computeChecksum(payload);
      expect(
        DataIntegritySigner.verifyManifest({
          'algorithm': 'fnv1a',
          'hash': expectedHash + 1, // altered hash
        }, payload),
        isFalse,
      );
    });

    test('valid content is accepted', () {
      final payload = 'my secret payload';
      final expectedHash = DataIntegritySigner.computeChecksum(payload);
      expect(
        DataIntegritySigner.verifyManifest({
          'algorithm': 'fnv1a',
          'hash': expectedHash,
        }, payload),
        isTrue,
      );
    });

    test('expired capabilities are rejected', () {
      final payload = 'my secret payload';
      final expectedHash = DataIntegritySigner.computeChecksum(payload);
      expect(
        DataIntegritySigner.verifyManifest({
          'algorithm': 'fnv1a',
          'hash': expectedHash,
          'expiresAt': DateTime.now().millisecondsSinceEpoch - 1000,
        }, payload),
        isFalse,
      );
    });

    test('unsupported signing metadata (expiresAt not int) is rejected', () {
      final payload = 'my secret payload';
      final expectedHash = DataIntegritySigner.computeChecksum(payload);
      expect(
        DataIntegritySigner.verifyManifest({
          'algorithm': 'fnv1a',
          'hash': expectedHash,
          'expiresAt': '2030-01-01',
        }, payload),
        isFalse,
      );
    });

    test('empty payload is rejected', () {
      expect(
        DataIntegritySigner.verifyManifest({
          'algorithm': 'fnv1a',
          'hash': DataIntegritySigner.computeChecksum(''),
        }, ''),
        isFalse,
      );
    });
  });

  group('OfflineGate tests', () {
    test('network denial throws correct exception', () {
      if (OfflineGate.strictOfflineEnforced) {
        expect(() => OfflineGate.assertZeroNetworkPolicy(), throwsA(isA<StateError>()));
      }
    });

    test('user-directed download only works if explicit consent is true', () {
      expect(OfflineGate.authorizeUserDownload(false), isFalse);
      expect(OfflineGate.authorizeUserDownload(true), equals(OfflineGate.strictOfflineEnforced));
    });

    test('telemetry is forbidden', () {
      expect(OfflineGate.isTelemetryAllowed(), isFalse);
    });
  });

  group('StorageGuard tests', () {
    test('local read is permitted', () {
      expect(StorageGuard.hasPermission(StoragePermission.read), isTrue);
    });

    test('local write is permitted', () {
      expect(StorageGuard.hasPermission(StoragePermission.write), isTrue);
    });
  });

  group('Ed25519SignatureVerifier tests', () {
    test('forged authorization (invalid signature) is rejected', () {
      final pubKeyBytes = Uint8List(32);
      final msgBytes = Uint8List.fromList('hello'.codeUnits);
      final sigBytes = Uint8List(64);

      expect(
        Ed25519SignatureVerifier.verify(
          publicKeyBytes: pubKeyBytes,
          messageBytes: msgBytes,
          signatureBytes: sigBytes,
        ),
        isFalse,
      );
    });
  });
}
