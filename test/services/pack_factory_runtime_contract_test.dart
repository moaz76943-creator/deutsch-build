import 'dart:convert';
import 'dart:io';

import 'package:deutsch_bilarabi/services/pack_database_key_store.dart';
import 'package:deutsch_bilarabi/services/pack_database_security.dart';
import 'package:deutsch_bilarabi/services/pack_manager_service.dart';
import 'package:deutsch_bilarabi/services/preferences_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class _ContractManifestVerifier implements PackManifestVerifier {
  const _ContractManifestVerifier();

  @override
  Future<PackManifest> verifyAndParse(String rawJson) async =>
      PackManifest.parse(rawJson);
}

final class _ContractKeyStore implements PackDatabaseKeyStore {
  const _ContractKeyStore();

  @override
  Future<String> getOrCreateKey() async =>
      base64Encode(List<int>.filled(32, 5));

  @override
  Future<String?> readKey() => getOrCreateKey();
}

final class _ContractCipher implements PackDatabaseCipher {
  const _ContractCipher();

  @override
  Future<void> encryptPlaintextInPlace(
    File plaintextDatabase, {
    required String password,
  }) async {}
}

final class _FactoryContractDownloader implements PackDownloader {
  const _FactoryContractDownloader(this.bytes);

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

void main() {
  test(
    'factory json-gzip-v1 envelope installs through PackManagerService',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final preferences = await PreferencesService.instance();
      final root = await Directory.systemTemp.createTemp(
        'pack_factory_contract_',
      );

      final files = <String, List<int>>{
        'content/content.json': utf8.encode(
          '{"pack":{"id":"sample-core"},"schemaVersion":1}\\n',
        ),
        'content/content.sqlite': <int>[83, 81, 76, 105, 116, 101],
        'metadata/pack.json': utf8.encode(
          '{"contractVersion":"1.0.0","packId":"sample-core"}\\n',
        ),
      };
      final envelope = <String, Object>{
        'packId': 'sample-core',
        'version': '1.0.0',
        'contractVersion': '1.0.0',
        'files': files.entries
            .map(
              (entry) => <String, String>{
                'path': entry.key,
                'contentBase64': base64Encode(entry.value),
              },
            )
            .toList(growable: false),
      };
      final bundle = gzip.encode(utf8.encode(jsonEncode(envelope)));
      final installedSize = files.values.fold<int>(
        0,
        (total, bytes) => total + bytes.length,
      );
      final manifest = jsonEncode(<String, Object>{
        'schemaVersion': 2,
        'manifestRevision': 11,
        'algorithm': 'Ed25519',
        'keyId': 'contract-test',
        'packs': <Object>[
          <String, Object>{
            'id': 'sample-core',
            'languageCode': 'de',
            'displayName': 'Sample Core',
            'version': '1.0.0',
            'contractVersion': '1.0.0',
            'bundleFormat': 'json-gzip-v1',
            'archiveUrl':
                'https://packs.example.test/sample-core-1.0.0.pack.gz',
            'sha256': PackChecksum.sha256Hex(bundle),
            'contentSha256': PackChecksum.sha256Hex(
              files['content/content.sqlite']!,
            ),
            'archiveSizeBytes': bundle.length,
            'installedSizeBytes': installedSize,
          },
        ],
        'signature': base64Encode(List<int>.filled(64, 3)),
      });
      final service = PackManagerService(
        preferences,
        rootDirectory: root,
        manifestVerifier: const _ContractManifestVerifier(),
        databaseKeyStore: const _ContractKeyStore(),
        databaseCipher: const _ContractCipher(),
        downloader: _FactoryContractDownloader(bundle),
        clock: () => DateTime.utc(2026, 10, 2, 15),
      );

      await service.loadManifestJson(manifest);
      final installed = await service.install(service.availablePacks.single);

      expect(installed.id, 'sample-core');
      expect(installed.databaseEncrypted, isTrue);
      expect(installed.storageBytes, installedSize);
      expect(service.activePackId, 'sample-core');
      expect(
        await File('${root.path}/packs/sample-core/content/content.json')
            .readAsString(),
        '{"pack":{"id":"sample-core"},"schemaVersion":1}\\n',
      );
      expect(
        await File('${root.path}/packs/sample-core/content/content.sqlite')
            .readAsBytes(),
        <int>[83, 81, 76, 105, 116, 101],
      );

      service.dispose();
      await root.delete(recursive: true);
    },
  );
}
