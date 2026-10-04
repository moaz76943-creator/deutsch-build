import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../lib/core/catalog/language_catalog.dart';
import '../../../lib/core/models/language_catalog_models.dart';
import '../../../lib/core/packs/pack_acquisition_router.dart';

void main() {
  test('registers 100 languages without pre-materializing 9900 pairs', () {
    final storage = _CountingLocalPackCatalog();
    final router = PackAcquisitionRouter(storage: storage);
    final catalog = LanguageCatalog(packRouter: router);

    catalog.registerAll(
      List<LanguageMetadata>.generate(
        100,
        (index) => LanguageMetadata(
          id: 'qaa-${index.toString().padLeft(2, '0')}',
          name: 'Language $index',
          isRtl: index.isEven,
        ),
      ),
    );

    expect(catalog.languageCount, 100);
    expect(catalog.directedPairCapacity, 9900);
    expect(catalog.activePair, isNull);
    expect(catalog.residentPairCount, 0);
    expect(storage.findCalls, 0);
  });

  test('resolvePair queries Phase 14 router only for the requested direction',
      () async {
    final storage = _CountingLocalPackCatalog(
      availablePairs: const <String>{'ar->de'},
    );
    final router = PackAcquisitionRouter(storage: storage);
    final catalog = LanguageCatalog(
      packRouter: router,
      languages: const <LanguageMetadata>[
        LanguageMetadata(id: 'ar', name: 'Arabic', isRtl: true),
        LanguageMetadata(id: 'de', name: 'German', isRtl: false),
      ],
    );

    expect(storage.findCalls, 0);

    final forward = await catalog.resolvePair('ar', 'de');

    expect(forward.pairKey, 'ar->de');
    expect(forward.source.id, 'ar');
    expect(forward.target.id, 'de');
    expect(forward.route.availability, PackAvailabilityStatus.available);
    expect(forward.route.status, PackAcquisitionStatus.localReady);
    expect(storage.findCalls, 1);
    expect(storage.queriedPairKeys, <String>['ar->de']);
    expect(catalog.residentPairCount, 1);

    final reverse = await catalog.resolvePair('de', 'ar');

    expect(reverse.pairKey, 'de->ar');
    expect(reverse.pairKey, isNot(forward.pairKey));
    expect(reverse.route.availability, PackAvailabilityStatus.missing);
    expect(reverse.route.status, PackAcquisitionStatus.requiresDownload);
    expect(storage.findCalls, 2);
    expect(
      storage.queriedPairKeys,
      <String>['ar->de', 'de->ar'],
    );
    expect(catalog.activePair, same(reverse));
    expect(catalog.residentPairCount, 1);
  });

  test('latest requested pair is the only pair retained after concurrent resolves',
      () async {
    final storage = _DelayedLocalPackCatalog();
    final catalog = LanguageCatalog(
      packRouter: PackAcquisitionRouter(storage: storage),
      languages: const <LanguageMetadata>[
        LanguageMetadata(id: 'ar', name: 'Arabic', isRtl: true),
        LanguageMetadata(id: 'de', name: 'German', isRtl: false),
        LanguageMetadata(id: 'sv', name: 'Swedish', isRtl: false),
      ],
    );

    final first = catalog.resolvePair('ar', 'de');
    final second = catalog.resolvePair('ar', 'sv');

    storage.complete('ar->sv');
    final secondResult = await second;
    storage.complete('ar->de');
    final firstResult = await first;

    expect(firstResult.pairKey, 'ar->de');
    expect(secondResult.pairKey, 'ar->sv');
    expect(catalog.activePair, same(secondResult));
    expect(catalog.residentPairCount, 1);
  });

  test('catalog rejects unknown and same-language pairs before router lookup',
      () async {
    final storage = _CountingLocalPackCatalog();
    final catalog = LanguageCatalog(
      packRouter: PackAcquisitionRouter(storage: storage),
      languages: const <LanguageMetadata>[
        LanguageMetadata(id: 'ar', name: 'Arabic', isRtl: true),
        LanguageMetadata(id: 'de', name: 'German', isRtl: false),
      ],
    );

    await expectLater(
      catalog.resolvePair('ar', 'ar'),
      throwsArgumentError,
    );
    await expectLater(
      catalog.resolvePair('ar', 'sv'),
      throwsA(isA<StateError>()),
    );

    expect(storage.findCalls, 0);
    expect(catalog.residentPairCount, 0);
  });

  test('catalog source contains no pre-materialized pair collection', () {
    final source = File(
      'lib/core/catalog/language_catalog.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('List<ResolvedLanguagePair>')));
    expect(source, isNot(contains('Map<String, ResolvedLanguagePair>')));
    expect(source, isNot(contains('Set<ResolvedLanguagePair>')));
    expect(source, contains('int get directedPairCapacity'));
    expect(source, contains('_activePair'));
  });
}

final class _CountingLocalPackCatalog implements LocalPackCatalog {
  _CountingLocalPackCatalog({
    Set<String> availablePairs = const <String>{},
  }) : _availablePairs = availablePairs;

  final Set<String> _availablePairs;
  final List<String> queriedPairKeys = <String>[];
  int findCalls = 0;

  @override
  Future<LocalPackHandle?> find(PackPairRequest request) async {
    findCalls += 1;
    final pairKey = request.pairKey;
    queriedPairKeys.add(pairKey);
    if (!_availablePairs.contains(pairKey)) return null;

    return LocalPackHandle(
      pairKey: pairKey,
      rootPath: '/local/${request.storageKey}',
      reader: const _EmptyReader(),
      hasJsonContent: true,
      hasSqliteContent: false,
    );
  }
}

final class _DelayedLocalPackCatalog implements LocalPackCatalog {
  final Map<String, Completer<LocalPackHandle?>> _pending =
      <String, Completer<LocalPackHandle?>>{};

  @override
  Future<LocalPackHandle?> find(PackPairRequest request) {
    final pairKey = request.pairKey;
    final completer = Completer<LocalPackHandle?>();
    _pending[pairKey] = completer;
    return completer.future;
  }

  void complete(String pairKey) {
    final completer = _pending.remove(pairKey);
    if (completer == null) {
      throw StateError('pair_not_pending:$pairKey');
    }
    completer.complete(null);
  }
}

final class _EmptyReader implements LocalPackReader {
  const _EmptyReader();

  @override
  Future<List<String>> listAssets() async => const <String>[];

  @override
  Future<List<int>> readBytes(String relativePath) async =>
      const <int>[];

  @override
  Future<String> readText(String relativePath) async => '{}';
}
