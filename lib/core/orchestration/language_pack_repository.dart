import '../worker/persistent_cpu_worker.dart';
import '../worker/worker_contract.dart';
import 'polyglot_language_pack.dart';

typedef LanguagePackTextLoader = Future<String> Function(String path);

final class LanguagePackRepository {
  LanguagePackRepository({
    required LanguagePackTextLoader loadText,
    this.assetRoot = 'assets/lang_data',
    PersistentCpuWorker? cpuWorker,
  })  : _loadText = loadText,
        _cpuWorker = cpuWorker;

  final LanguagePackTextLoader _loadText;
  final PersistentCpuWorker? _cpuWorker;
  final String assetRoot;

  PolyglotLanguagePackCatalog? _catalog;
  PolyglotLanguagePack? _activePack;

  String? get activePair => _activePack?.directedPair;
  PolyglotLanguagePack? get activePack => _activePack;
  PolyglotLanguagePackCatalog? get catalog => _catalog;

  Future<PolyglotLanguagePackCatalog> loadCatalog() async {
    final current = _catalog;
    if (current != null) return current;

    final encoded = await _loadText(_pathFor('catalog.json'));
    final worker = _cpuWorker;
    final loaded = worker == null
        ? PolyglotLanguagePackCatalog.parse(encoded)
        : await _loadCatalogWithWorker(worker, encoded);
    _catalog = loaded;
    return loaded;
  }

  Future<PolyglotLanguagePack> loadPair(
    String sourceLanguage,
    String targetLanguage,
  ) async {
    final source = _language(sourceLanguage, 'sourceLanguage');
    final target = _language(targetLanguage, 'targetLanguage');
    if (source == target) {
      throw ArgumentError(
        'Source and target language must be different.',
      );
    }

    final pair = '$source->$target';
    final active = _activePack;
    if (active != null && active.directedPair == pair) {
      return active;
    }

    final catalog = await loadCatalog();
    final entry = catalog.requirePair(source, target);
    if (!entry.isLoadable) {
      throw StateError(
        'Language pack $pair is not loadable: '
        '${entry.reason ?? entry.readiness}.',
      );
    }

    final encoded = await _loadText(
      _pathFor(fileNameForPair(source, target)),
    );
    final worker = _cpuWorker;
    final loaded = worker == null
        ? PolyglotLanguagePack.parse(encoded)
        : await _loadPackWithWorker(
            worker,
            encoded,
            source: source,
            target: target,
          );
    if (loaded.directedPair != pair) {
      throw FormatException(
        'Loaded pack pair ${loaded.directedPair} does not match $pair.',
      );
    }
    if (entry.checksum != loaded.checksum) {
      throw FormatException(
        'Catalog checksum does not match loaded pack $pair.',
      );
    }

    _activePack = loaded;
    return loaded;
  }

  Future<PolyglotLanguagePackCatalog> _loadCatalogWithWorker(
    PersistentCpuWorker worker,
    String encoded,
  ) async {
    final decoded = await _decode(
      worker,
      encoded,
      id: 'pack.catalog.decode',
    );
    if (decoded is! Map) {
      throw const FormatException(
        'Language pack catalog root must be an object.',
      );
    }

    final root = _stringObjectMap(decoded, 'catalog');
    final languageCount = _intValue(
      root['languageCount'],
      'catalog.languageCount',
    );
    final directedPairCount = _intValue(
      root['directedPairCount'],
      'catalog.directedPairCount',
    );
    final unsigned = Map<String, Object?>.from(root)..remove('checksum');
    final checksum = await _checksumJson(
      worker,
      id: 'pack.catalog.checksum',
      scopeKey: 'polyglot-catalog|$languageCount'
          'x$directedPairCount',
      jsonValue: unsigned,
      validatorVersion: PolyglotLanguagePackCatalog.validatorVersion,
    );

    return PolyglotLanguagePackCatalog.fromDecoded(
      root,
      computedChecksum: checksum,
    );
  }

  Future<PolyglotLanguagePack> _loadPackWithWorker(
    PersistentCpuWorker worker,
    String encoded, {
    required String source,
    required String target,
  }) async {
    final decoded = await _decode(
      worker,
      encoded,
      id: 'pack.$source.$target.decode',
    );
    if (decoded is! Map) {
      throw const FormatException(
        'Language pack root must be an object.',
      );
    }

    final root = _stringObjectMap(decoded, 'pack');
    final unsigned = Map<String, Object?>.from(root)..remove('checksum');
    final checksum = await _checksumJson(
      worker,
      id: 'pack.$source.$target.checksum',
      scopeKey: '$source->$target|pack',
      jsonValue: unsigned,
      validatorVersion: PolyglotLanguagePack.validatorVersion,
    );

    return PolyglotLanguagePack.fromDecoded(
      root,
      computedChecksum: checksum,
    );
  }

  Future<Object?> _decode(
    PersistentCpuWorker worker,
    String encoded, {
    required String id,
  }) async {
    final result = await worker.submit<Object?>(
      WorkerJob<Map<String, Object?>>(
        id: id,
        type: WorkerJobTypes.jsonDecode,
        epoch: worker.currentEpoch,
        payload: <String, Object?>{'encoded': encoded},
      ),
    );
    if (result.status == WorkerStatuses.stale) {
      throw StateError(
        'Language pack decode became stale after pair switch.',
      );
    }
    if (result.status != WorkerStatuses.ok) {
      throw StateError(
        'Language pack decode failed: '
        '${result.errorCode ?? result.status}.',
      );
    }
    return result.payload;
  }

  Future<String> _checksumJson(
    PersistentCpuWorker worker, {
    required String id,
    required String scopeKey,
    required Object? jsonValue,
    required String validatorVersion,
  }) async {
    final result = await worker.submit<String>(
      WorkerJob<Map<String, Object?>>(
        id: id,
        type: WorkerJobTypes.checksum128,
        epoch: worker.currentEpoch,
        payload: <String, Object?>{
          'scopeKey': scopeKey,
          'jsonValue': jsonValue,
          'validatorVersion': validatorVersion,
        },
      ),
    );
    if (result.status == WorkerStatuses.stale) {
      throw StateError(
        'Language pack checksum became stale after pair switch.',
      );
    }
    if (result.status != WorkerStatuses.ok || result.payload == null) {
      throw StateError(
        'Language pack checksum failed: '
        '${result.errorCode ?? result.status}.',
      );
    }
    return result.payload!;
  }

  void clear() {
    _activePack = null;
  }

  void clearAll() {
    _activePack = null;
    _catalog = null;
  }

  String _pathFor(String fileName) {
    final root = assetRoot.trim();
    if (root.isEmpty) return fileName;

    final normalizedRoot = root.endsWith('/')
        ? root.substring(0, root.length - 1)
        : root;
    return '$normalizedRoot/$fileName';
  }

  static String fileNameForPair(
    String sourceLanguage,
    String targetLanguage,
  ) {
    final source = _language(sourceLanguage, 'sourceLanguage');
    final target = _language(targetLanguage, 'targetLanguage');
    return '${source.replaceAll('-', '_')}_'
        '${target.replaceAll('-', '_')}.json';
  }
}

Map<String, Object?> _stringObjectMap(
  Object? value,
  String field,
) {
  if (value is! Map) {
    throw FormatException('$field must be an object.');
  }
  final result = <String, Object?>{};
  for (final entry in value.entries) {
    if (entry.key is! String) {
      throw FormatException('$field keys must be strings.');
    }
    result[entry.key as String] = entry.value;
  }
  return result;
}

int _intValue(Object? value, String field) {
  if (value is! num) {
    throw FormatException('$field must be numeric.');
  }
  return value.toInt();
}

String _language(String value, String field) {
  final normalized = value.trim().replaceAll('_', '-').toLowerCase();
  if (!RegExp(r'^[a-z]{2,8}(?:-[a-z0-9]{1,8})*$')
      .hasMatch(normalized)) {
    throw ArgumentError.value(
      value,
      field,
      'must be a valid language tag',
    );
  }
  return normalized;
}
