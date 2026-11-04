import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:deutsch_bilarabi/core/content_pipeline/validation_cache.dart';
import 'package:deutsch_bilarabi/services/pack_manifest.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('content fingerprints match the standard SHA256 abc vector', () async {
    expect(await ValidationFingerprint.bytes(utf8.encode('abc')),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad');
  });

  test('trusted Ed25519 manifest verifies and altered revision is rejected',
      () async {
    final algorithm = Ed25519();
    final keyPair = await algorithm.newKeyPair();
    final publicKey = await keyPair.extractPublicKey();
    final manifest = <String, Object>{
      'schemaVersion': 2,
      'manifestRevision': 1,
      'algorithm': 'Ed25519',
      'keyId': 'test-only',
      'packs': <Object>[],
      'signature': base64Encode(List<int>.filled(64, 0)),
    };
    final signature = await algorithm.sign(
      PackManifestCanonicalJson.signingBytes(jsonEncode(manifest)),
      keyPair: keyPair,
    );
    manifest['signature'] = base64Encode(signature.bytes);
    final verifier = Ed25519PackManifestVerifier(
      trustedPublicKeys: {'test-only': publicKey.bytes},
    );
    expect(
        (await verifier.verifyAndParse(jsonEncode(manifest))).manifestRevision,
        1);
    manifest['manifestRevision'] = 2;
    await expectLater(verifier.verifyAndParse(jsonEncode(manifest)),
        throwsA(isA<PackManifestAuthenticityException>()));
  });

  test('unknown signing key cannot enable a manifest', () async {
    final manifest = jsonEncode({
      'schemaVersion': 2,
      'manifestRevision': 1,
      'algorithm': 'Ed25519',
      'keyId': 'untrusted',
      'packs': <Object>[],
      'signature': base64Encode(List<int>.filled(64, 0)),
    });
    await expectLater(
        Ed25519PackManifestVerifier(trustedPublicKeys: {})
            .verifyAndParse(manifest),
        throwsA(isA<PackManifestAuthenticityException>()));
  });
}
