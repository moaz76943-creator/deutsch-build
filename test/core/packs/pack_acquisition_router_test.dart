import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../lib/core/packs/pack_acquisition_router.dart';
import '../../../lib/core/storage/modular_pack_storage.dart';

void main() {
  test('router returns localReady for an installed directed-pair pack', () async {
    final root = await Directory.systemTemp.createTemp('phase14_pack_');
    addTearDown(() => root.delete(recursive: true));

    final storage = FileSystemModularPackStorage(rootDirectory: root);
    await storage.initialize();
    await _writeReadyPack(
      storage,
      source: 'ar',
      target: 'de',
      jsonContent: '{"pair":"ar->de"}',
    );

    final provider = _RecordingProvider(
      id: 'cdn',
      requiresNetwork: true,
    );
    final router = PackAcquisitionRouter(
      storage: storage,
      providers: <PackAcquisitionProvider>[provider],
    );

    final decision = await router.route(
      const PackPairRequest(
        sourceLanguageTag: 'ar',
        targetLanguageTag: 'de',
      ),
    );

    expect(decision.availability, PackAvailabilityStatus.available);
    expect(decision.status, PackAcquisitionStatus.localReady);
    expect(decision.localPack, isNotNull);
    expect(decision.localPack!.pairKey, 'ar->de');
    expect(provider.acquireCalls, 0);

    final json = await decision.localPack!.reader.readText(
      'content/pack.json',
    );
    expect(json, '{"pair":"ar->de"}');
  });

  test('directed pair identity is not implicitly reversed', () async {
    final root = await Directory.systemTemp.createTemp('phase14_direction_');
    addTearDown(() => root.delete(recursive: true));

    final storage = FileSystemModularPackStorage(rootDirectory: root);
    await storage.initialize();
    await _writeReadyPack(
      storage,
      source: 'ar',
      target: 'de',
      jsonContent: '{"pair":"ar->de"}',
    );

    final router = PackAcquisitionRouter(storage: storage);
    final reverse = await router.route(
      const PackPairRequest(
        sourceLanguageTag: 'de',
        targetLanguageTag: 'ar',
      ),
    );

    expect(reverse.availability, PackAvailabilityStatus.missing);
    expect(reverse.status, PackAcquisitionStatus.requiresDownload);
    expect(reverse.localPack, isNull);
  });

  test('missing pack returns requiresDownload without calling providers', () async {
    final root = await Directory.systemTemp.createTemp('phase14_missing_');
    addTearDown(() => root.delete(recursive: true));

    final storage = FileSystemModularPackStorage(rootDirectory: root);
    await storage.initialize();
    final provider = _RecordingProvider(
      id: 'play-asset-delivery',
      requiresNetwork: false,
    );
    final networkProvider = _RecordingProvider(
      id: 'cdn',
      requiresNetwork: true,
    );
    final router = PackAcquisitionRouter(
      storage: storage,
      providers: <PackAcquisitionProvider>[
        provider,
        networkProvider,
      ],
    );

    final decision = await router.route(
      const PackPairRequest(
        sourceLanguageTag: 'ar',
        targetLanguageTag: 'sv',
      ),
    );

    expect(decision.availability, PackAvailabilityStatus.missing);
    expect(decision.status, PackAcquisitionStatus.requiresDownload);
    expect(
      decision.providerCandidates,
      <String>['play-asset-delivery', 'cdn'],
    );
    expect(provider.acquireCalls, 0);
    expect(networkProvider.acquireCalls, 0);
  });

  test('explicit acquisition is disabled and never invokes providers', () async {
    final root = await Directory.systemTemp.createTemp('phase14_acquire_');
    addTearDown(() => root.delete(recursive: true));

    final storage = FileSystemModularPackStorage(rootDirectory: root);
    await storage.initialize();
    final networkProvider = _RecordingProvider(
      id: 'cdn',
      requiresNetwork: true,
    );
    final router = PackAcquisitionRouter(
      storage: storage,
      providers: <PackAcquisitionProvider>[networkProvider],
    );
    const request = PackPairRequest(
      sourceLanguageTag: 'ar',
      targetLanguageTag: 'sv',
    );

    await expectLater(
      router.acquire(request),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'pack_acquisition_disabled_offline_phase14',
        ),
      ),
    );
    expect(networkProvider.acquireCalls, 0);
  });

  test('local reader rejects traversal outside the pack directory', () async {
    final root = await Directory.systemTemp.createTemp('phase14_safe_');
    addTearDown(() => root.delete(recursive: true));

    final storage = FileSystemModularPackStorage(rootDirectory: root);
    await storage.initialize();
    await _writeReadyPack(
      storage,
      source: 'en',
      target: 'sv',
      jsonContent: '{"pair":"en->sv"}',
    );
    final local = await storage.find(
      const PackPairRequest(
        sourceLanguageTag: 'en',
        targetLanguageTag: 'sv',
      ),
    );

    expect(local, isNotNull);
    await expectLater(
      local!.reader.readText('../outside.json'),
      throwsArgumentError,
    );
  });

  test('phase14 production pack core has no network implementation', () {
    final roots = <Directory>[
      Directory('lib/core/packs'),
      Directory('lib/core/storage'),
    ];
    final violations = <String>[];

    for (final root in roots) {
      if (!root.existsSync()) continue;
      for (final entity in root.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final source = entity.readAsStringSync();
        if (source.contains('package:http/') ||
            source.contains('HttpClient(') ||
            source.contains('HttpRequest') ||
            source.contains('Socket.connect(')) {
          violations.add(entity.path);
        }
      }
    }

    expect(violations, isEmpty);
  });
}

Future<void> _writeReadyPack(
  FileSystemModularPackStorage storage, {
  required String source,
  required String target,
  required String jsonContent,
}) async {
  final staging = await storage.prepareStaging(
    PackPairRequest(
      sourceLanguageTag: source,
      targetLanguageTag: target,
    ),
  );
  final file = File(
    '${staging.path}${Platform.pathSeparator}content'
    '${Platform.pathSeparator}pack.json',
  );
  await file.create(recursive: true);
  await file.writeAsString(jsonContent, flush: true);
  await storage.commitStaged(
    PackPairRequest(
      sourceLanguageTag: source,
      targetLanguageTag: target,
    ),
    staging,
  );
}

final class _RecordingProvider implements PackAcquisitionProvider {
  _RecordingProvider({
    required this.id,
    required this.requiresNetwork,
  });

  @override
  final String id;

  @override
  final bool requiresNetwork;

  int acquireCalls = 0;

  @override
  Future<void> acquire(PackPairRequest request) async {
    acquireCalls += 1;
  }
}
