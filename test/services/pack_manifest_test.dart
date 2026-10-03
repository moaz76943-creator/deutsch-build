import 'dart:convert';

import 'package:deutsch_bilarabi/services/pack_manifest.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const publicKeyBase64 = '11qYAYKxCrfVS/7TyWQHOg7hcvPapiMlrwIaaPcHURo=';
  const signedManifest =
      '{"schemaVersion":2,"manifestRevision":7,"algorithm":"Ed25519",'
      '"keyId":"test-rfc8032","packs":[{"id":"de-core",'
      '"languageCode":"de","displayName":"Deutsch Core","version":"1.0.0",'
      '"contractVersion":"1.0.0","bundleFormat":"json-gzip-v1",'
      '"archiveUrl":"https://example.invalid/de-core.pack.gz",'
      '"sha256":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",'
      '"contentSha256":"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",'
      '"archiveSizeBytes":12,"installedSizeBytes":8}],'
      '"signature":"AU4O3xfzfPXvwCBgVgYzPV16wGjdLselCJ5dm8WX+jHZYMy9evHyBFFAR0HxfH60w7G6rJki0kvrpmp6uGXRCg=="}';

  test('verifies OpenSSL/Python canonical Ed25519 manifest vector', () async {
    final verifier = PackManifestVerifiers.fromSingleBase64Key(
      keyId: 'test-rfc8032',
      publicKeyBase64: publicKeyBase64,
    );
    final manifest = await verifier.verifyAndParse(signedManifest);
    expect(manifest.schemaVersion, 2);
    expect(manifest.manifestRevision, 7);
    expect(manifest.algorithm, 'Ed25519');
    expect(manifest.packs.single.contentSha256, List.filled(64, 'b').join());
  });

  test('tampered signed payload is rejected', () async {
    final verifier = PackManifestVerifiers.fromSingleBase64Key(
      keyId: 'test-rfc8032',
      publicKeyBase64: publicKeyBase64,
    );
    final decoded = jsonDecode(signedManifest) as Map<String, dynamic>;
    final packs = decoded['packs'] as List<dynamic>;
    final first = Map<String, dynamic>.from(packs.first as Map);
    first['displayName'] = 'Tampered';
    decoded['packs'] = <Object>[first];
    await expectLater(
      verifier.verifyAndParse(jsonEncode(decoded)),
      throwsA(isA<PackManifestAuthenticityException>()),
    );
  });

  test('unknown manifest key id is rejected', () async {
    final verifier = PackManifestVerifiers.fromSingleBase64Key(
      keyId: 'another-key',
      publicKeyBase64: publicKeyBase64,
    );
    await expectLater(
      verifier.verifyAndParse(signedManifest),
      throwsA(isA<PackManifestAuthenticityException>()),
    );
  });
}
