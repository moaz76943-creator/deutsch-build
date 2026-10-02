import 'dart:convert';
import 'dart:io';

import 'package:deutsch_bilarabi/services/pack_database_key_store.dart';
import 'package:deutsch_bilarabi/services/pack_database_security.dart';
import 'package:deutsch_bilarabi/services/pack_manager_service.dart';
import 'package:deutsch_bilarabi/services/preferences_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class BytesDownloader implements PackDownloader {
  BytesDownloader(this.bytes);
  final List<int> bytes;

  @override
  Future<int> download(
    Uri source,
    File destination, {
    required int expectedBytes,
    required void Function(double) onProgress,
  }) async {
    await destination.parent.create(recursive: true);
    await destination.writeAsBytes(bytes, flush: true);
    onProgress(1);
    return bytes.length;
  }
}

final class AcceptingManifestVerifier implements PackManifestVerifier {
  const AcceptingManifestVerifier();

  @override
  Future<PackManifest> verifyAndParse(String rawJson) async =>
      PackManifest.parse(rawJson);
}

final class TrackingExtractor implements PackArchiveExtractor {
  bool called = false;

  @override
  Future<void> extract(
    File archiveFile,
    Directory destination,
    LanguagePackDescriptor descriptor,
  ) async {
    called = true;
  }
}

final class TestKeyStore implements PackDatabaseKeyStore {
  const TestKeyStore();

  @override
  Future<String> getOrCreateKey() async =>
      base64Encode(List<int>.filled(32, 7));

  @override
  Future<String?> readKey() => getOrCreateKey();
}

final class PassthroughCipher implements PackDatabaseCipher {
  PassthroughCipher();
  bool called = false;

  @override
  Future<void> encryptPlaintextInPlace(
    File plaintextDatabase, {
    required String password,
  }) async {
    called = true;
    expect(base64Decode(password), hasLength(32));
  }
}

void main() {
  test('signed manifest parser is versioned and SHA-256 is correct', () {
    final manifest = PackManifest.parse(
      _manifestJson(
        sha256: List<String>.filled(64, 'a').join(),
        contentSha256: List<String>.filled(64, 'b').join(),
        archiveSizeBytes: 12,
        installedSizeBytes: 8,
      ),
    );
    expect(manifest.schemaVersion, 2);
    expect(manifest.algorithm, 'Ed25519');
    expect(manifest.manifestRevision, 7);
    expect(
      PackChecksum.sha256Hex(utf8.encode('abc')),
      'ba7816bf8f01cfea414140de5dae2223'
      'b00361a396177a9cb410ff61f20015ad',
    );
  });

  test('corrupted archive is rejected before extraction or encryption', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await PreferencesService.instance();
    final root = await Directory.systemTemp.createTemp('pack_corrupt_');
    final extractor = TrackingExtractor();
    final cipher = PassthroughCipher();
    final service = PackManagerService(
      prefs,
      rootDirectory: root,
      manifestVerifier: const AcceptingManifestVerifier(),
      databaseKeyStore: const TestKeyStore(),
      databaseCipher: cipher,
      downloader: BytesDownloader(utf8.encode('abd')),
      extractor: extractor,
    );
    await service.loadManifestJson(
      _manifestJson(
        sha256:
            'ba7816bf8f01cfea414140de5dae2223'
            'b00361a396177a9cb410ff61f20015ad',
        contentSha256: List<String>.filled(64, 'b').join(),
        archiveSizeBytes: 3,
        installedSizeBytes: 1,
      ),
    );

    await expectLater(
      service.install(service.availablePacks.single),
      throwsA(isA<PackIntegrityException>()),
    );
    expect(extractor.called, isFalse);
    expect(cipher.called, isFalse);

    service.dispose();
    await root.delete(recursive: true);
  });

  test('install encrypts SQLite before registering active pack', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await PreferencesService.instance();
    final root = await Directory.systemTemp.createTemp('pack_install_');
    final bundle = _bundleBytes();
    final cipher = PassthroughCipher();
    final service = PackManagerService(
      prefs,
      rootDirectory: root,
      manifestVerifier: const AcceptingManifestVerifier(),
      databaseKeyStore: const TestKeyStore(),
      databaseCipher: cipher,
      downloader: BytesDownloader(bundle),
    );
    await service.loadManifestJson(
      _manifestJson(
        sha256: PackChecksum.sha256Hex(bundle),
        contentSha256: PackChecksum.sha256Hex(utf8.encode('SQLite')),
        archiveSizeBytes: bundle.length,
        installedSizeBytes: 14,
      ),
    );

    final installed = await service.install(service.availablePacks.single);

    expect(cipher.called, isTrue);
    expect(installed.databaseEncrypted, isTrue);
    expect(installed.storageBytes, 14);
    expect(service.activePackId, 'de-core');

    service.dispose();
    await root.delete(recursive: true);
  });

  test('same revision with different signed content is rejected', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await PreferencesService.instance();
    final root = await Directory.systemTemp.createTemp('pack_replay_');
    final service = PackManagerService(
      prefs,
      rootDirectory: root,
      manifestVerifier: const AcceptingManifestVerifier(),
    );
    final first = _manifestJson(
      sha256: List<String>.filled(64, 'a').join(),
      contentSha256: List<String>.filled(64, 'b').join(),
      archiveSizeBytes: 12,
      installedSizeBytes: 8,
    );
    await service.loadManifestJson(first);
    final decoded = jsonDecode(first) as Map<String, dynamic>;
    decoded['signature'] = base64Encode(List<int>.filled(64, 2));

    await expectLater(
      service.loadManifestJson(jsonEncode(decoded)),
      throwsStateError,
    );

    service.dispose();
    await root.delete(recursive: true);
  });
}

String _manifestJson({
  required String sha256,
  required String contentSha256,
  required int archiveSizeBytes,
  required int installedSizeBytes,
}) => jsonEncode(<String, Object>{
  'schemaVersion': 2,
  'manifestRevision': 7,
  'algorithm': 'Ed25519',
  'keyId': 'test-key',
  'packs': <Object>[
    <String, Object>{
      'id': 'de-core',
      'languageCode': 'de',
      'displayName': 'Deutsch Core',
      'version': '1.0.0',
      'contractVersion': '1.0.0',
      'bundleFormat': 'json-gzip-v1',
      'archiveUrl': 'https://example.invalid/de-core.pack.gz',
      'sha256': sha256,
      'contentSha256': contentSha256,
      'archiveSizeBytes': archiveSizeBytes,
      'installedSizeBytes': installedSizeBytes,
    },
  ],
  'signature': base64Encode(List<int>.filled(64, 1)),
});

List<int> _bundleBytes() {
  final payload = jsonEncode(<String, Object>{
    'packId': 'de-core',
    'version': '1.0.0',
    'contractVersion': '1.0.0',
    'files': <Object>[
      <String, Object>{
        'path': 'content/items.json',
        'contentBase64': base64Encode(utf8.encode('abc')),
      },
      <String, Object>{
        'path': 'meta/info.txt',
        'contentBase64': base64Encode(utf8.encode('12345')),
      },
      <String, Object>{
        'path': 'content/content.sqlite',
        'contentBase64': base64Encode(utf8.encode('SQLite')),
      },
    ],
  });
  return gzip.encode(utf8.encode(payload));
}
