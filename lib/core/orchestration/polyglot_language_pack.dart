import 'dart:convert';

import '../storage/validation_hash_cache.dart';

final class PolyglotLanguagePack {
  PolyglotLanguagePack._({
    required this.schemaVersion,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.readiness,
    required this.curriculumTasks,
    required this.vocabularyPool,
    required this.grammarMatrix,
    required this.checksum,
  });

  static const int currentSchemaVersion = 1;
  static const String checksumAlgorithm = 'validation-checksum-128-v1';
  static const String validatorVersion = 'phase11.pack.v1';

  final int schemaVersion;
  final String sourceLanguage;
  final String targetLanguage;
  final String readiness;
  final List<Map<String, Object?>> curriculumTasks;
  final List<Map<String, Object?>> vocabularyPool;
  final List<Map<String, Object?>> grammarMatrix;
  final String checksum;

  String get directedPair => '$sourceLanguage->$targetLanguage';

  // Headless compatibility path. Runtime loading uses the persistent worker.
  static PolyglotLanguagePack parse(String encoded) =>
      fromDecoded(jsonDecode(encoded));

  static PolyglotLanguagePack fromDecoded(
    Object? raw, {
    String? computedChecksum,
  }) {
    if (raw is! Map) {
      throw const FormatException('Language pack root must be an object.');
    }

    final root = _stringMap(raw, 'root');
    final schemaVersion = _requiredInt(root['schemaVersion'], 'schemaVersion');
    if (schemaVersion != currentSchemaVersion) {
      throw FormatException(
        'Unsupported language pack schema: $schemaVersion.',
      );
    }

    final pair = _stringMap(root['pair'], 'pair');
    final source = _language(pair['sourceLanguage'], 'sourceLanguage');
    final target = _language(pair['targetLanguage'], 'targetLanguage');
    if (source == target) {
      throw const FormatException(
        'Language pack source and target must be different.',
      );
    }
    final id = _requiredString(pair['id'], 'pair.id').toLowerCase();
    final expectedPair = '$source->$target';
    if (id != expectedPair) {
      throw FormatException(
        'Language pack pair id mismatch: $id != $expectedPair.',
      );
    }

    final readiness = _requiredString(
      pair['readiness'],
      'pair.readiness',
    ).toLowerCase();
    if (!const <String>{'ready', 'partial'}.contains(readiness)) {
      throw FormatException(
        'Loadable pack readiness must be ready or partial.',
      );
    }

    final checksumMap = _stringMap(root['checksum'], 'checksum');
    final algorithm = _requiredString(
      checksumMap['algorithm'],
      'checksum.algorithm',
    );
    final validator = _requiredString(
      checksumMap['validatorVersion'],
      'checksum.validatorVersion',
    );
    final checksum = _requiredString(
      checksumMap['value'],
      'checksum.value',
    ).toLowerCase();

    if (algorithm != checksumAlgorithm) {
      throw FormatException(
        'Unsupported language pack checksum algorithm: $algorithm.',
      );
    }
    if (validator != validatorVersion) {
      throw FormatException(
        'Unsupported language pack validator version: $validator.',
      );
    }
    if (!_isChecksum(checksum)) {
      throw const FormatException(
        'Language pack checksum must be a 128-bit hex token.',
      );
    }

    final unsigned = Map<String, Object?>.from(root)..remove('checksum');
    final expectedChecksum = computedChecksum ??
        ContentChecksum.compute(
          scopeKey: '$expectedPair|pack',
          content: jsonEncode(unsigned),
          validatorVersion: validatorVersion,
        );
    if (expectedChecksum != checksum) {
      throw const FormatException('Language pack checksum mismatch.');
    }

    final tasks = _objectList(root['curriculumTasks'], 'curriculumTasks');
    if (tasks.isEmpty || tasks.length > 50) {
      throw const FormatException(
        'Language pack curriculum task count must be 1..50.',
      );
    }
    final taskIds = <String>{};
    for (final task in tasks) {
      final taskId = _requiredString(task['id'], 'curriculumTasks.id');
      if (!_canonicalTaskId(taskId) || !taskIds.add(taskId)) {
        throw FormatException(
          'Invalid or duplicate curriculum task id: $taskId.',
        );
      }
    }

    final vocabulary = _objectList(
      root['vocabularyPool'],
      'vocabularyPool',
    );
    final vocabularyIds = <String>{};
    for (final item in vocabulary) {
      final vocabularyId = _requiredString(
        item['id'],
        'vocabularyPool.id',
      );
      if (!vocabularyIds.add(vocabularyId)) {
        throw FormatException(
          'Duplicate vocabulary id: $vocabularyId.',
        );
      }
      _requiredString(item['source'], 'vocabularyPool.source');
      _requiredString(item['target'], 'vocabularyPool.target');
    }

    final grammar = _objectList(root['grammarMatrix'], 'grammarMatrix');
    final grammarIds = <String>{};
    for (final item in grammar) {
      final grammarId = _requiredString(item['id'], 'grammarMatrix.id');
      if (!grammarIds.add(grammarId)) {
        throw FormatException('Duplicate grammar id: $grammarId.');
      }
      final taskId = _requiredString(
        item['taskId'],
        'grammarMatrix.taskId',
      );
      if (!taskIds.contains(taskId)) {
        throw FormatException(
          'Grammar item references unknown task id: $taskId.',
        );
      }
    }

    for (final task in tasks) {
      final taskId = task['id'] as String;
      for (final ref in _stringList(
        task['vocabularyRefs'],
        'curriculumTasks.vocabularyRefs',
      )) {
        if (!vocabularyIds.contains(ref)) {
          throw FormatException(
            'Task $taskId references unknown vocabulary id: $ref.',
          );
        }
      }
      for (final ref in _stringList(
        task['grammarRefs'],
        'curriculumTasks.grammarRefs',
      )) {
        if (!grammarIds.contains(ref)) {
          throw FormatException(
            'Task $taskId references unknown grammar id: $ref.',
          );
        }
      }
    }

    return PolyglotLanguagePack._(
      schemaVersion: schemaVersion,
      sourceLanguage: source,
      targetLanguage: target,
      readiness: readiness,
      curriculumTasks: List<Map<String, Object?>>.unmodifiable(tasks),
      vocabularyPool: List<Map<String, Object?>>.unmodifiable(vocabulary),
      grammarMatrix: List<Map<String, Object?>>.unmodifiable(grammar),
      checksum: checksum,
    );
  }

  Map<String, Object?> taskById(String taskId) {
    final normalized = taskId.trim();
    for (final task in curriculumTasks) {
      if (task['id'] == normalized) return task;
    }
    throw ArgumentError.value(
      taskId,
      'taskId',
      'Unknown task in active language pack.',
    );
  }

  Map<String, Object?> vocabularyById(String id) {
    final normalized = id.trim();
    for (final item in vocabularyPool) {
      if (item['id'] == normalized) return item;
    }
    throw ArgumentError.value(
      id,
      'id',
      'Unknown vocabulary id in active language pack.',
    );
  }
}

final class LanguagePackCatalogEntry {
  const LanguagePackCatalogEntry({
    required this.id,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.readiness,
    required this.assetPath,
    required this.checksum,
    required this.vocabularyCount,
    required this.grammarCount,
    required this.reason,
  });

  final String id;
  final String sourceLanguage;
  final String targetLanguage;
  final String readiness;
  final String? assetPath;
  final String? checksum;
  final int vocabularyCount;
  final int grammarCount;
  final String? reason;

  bool get isLoadable =>
      assetPath != null &&
      (readiness == 'ready' || readiness == 'partial');
}

final class PolyglotLanguagePackCatalog {
  PolyglotLanguagePackCatalog._({
    required this.schemaVersion,
    required this.languageCount,
    required this.directedPairCount,
    required this.generatedPairCount,
    required this.entries,
    required this.checksum,
  });

  static const int currentSchemaVersion = 1;
  static const String validatorVersion = 'phase11.catalog.v1';

  final int schemaVersion;
  final int languageCount;
  final int directedPairCount;
  final int generatedPairCount;
  final List<LanguagePackCatalogEntry> entries;
  final String checksum;

  // Headless compatibility path. Runtime loading uses the persistent worker.
  static PolyglotLanguagePackCatalog parse(String encoded) =>
      fromDecoded(jsonDecode(encoded));

  static PolyglotLanguagePackCatalog fromDecoded(
    Object? raw, {
    String? computedChecksum,
  }) {
    if (raw is! Map) {
      throw const FormatException(
        'Language pack catalog root must be an object.',
      );
    }

    final root = _stringMap(raw, 'catalog');
    final schemaVersion = _requiredInt(
      root['schemaVersion'],
      'catalog.schemaVersion',
    );
    if (schemaVersion != currentSchemaVersion) {
      throw FormatException(
        'Unsupported language pack catalog schema: $schemaVersion.',
      );
    }

    final languageCount = _requiredInt(
      root['languageCount'],
      'catalog.languageCount',
    );
    final directedPairCount = _requiredInt(
      root['directedPairCount'],
      'catalog.directedPairCount',
    );
    final generatedPairCount = _requiredInt(
      root['generatedPairCount'],
      'catalog.generatedPairCount',
    );
    if (languageCount < 2 ||
        directedPairCount != languageCount * (languageCount - 1) ||
        generatedPairCount < 0 ||
        generatedPairCount > directedPairCount) {
      throw const FormatException(
        'Language pack catalog counts are invalid.',
      );
    }

    final checksumMap = _stringMap(
      root['checksum'],
      'catalog.checksum',
    );
    final algorithm = _requiredString(
      checksumMap['algorithm'],
      'catalog.checksum.algorithm',
    );
    final validator = _requiredString(
      checksumMap['validatorVersion'],
      'catalog.checksum.validatorVersion',
    );
    final checksum = _requiredString(
      checksumMap['value'],
      'catalog.checksum.value',
    ).toLowerCase();

    if (algorithm != PolyglotLanguagePack.checksumAlgorithm) {
      throw FormatException(
        'Unsupported catalog checksum algorithm: $algorithm.',
      );
    }
    if (validator != validatorVersion) {
      throw FormatException(
        'Unsupported catalog validator version: $validator.',
      );
    }
    if (!_isChecksum(checksum)) {
      throw const FormatException(
        'Catalog checksum must be a 128-bit hex token.',
      );
    }

    final unsigned = Map<String, Object?>.from(root)..remove('checksum');
    final expectedChecksum = computedChecksum ??
        ContentChecksum.compute(
          scopeKey: 'polyglot-catalog|$languageCount'
              'x$directedPairCount',
          content: jsonEncode(unsigned),
          validatorVersion: validatorVersion,
        );
    if (expectedChecksum != checksum) {
      throw const FormatException(
        'Language pack catalog checksum mismatch.',
      );
    }

    final rawEntries = _objectList(root['pairs'], 'catalog.pairs');
    if (rawEntries.length != directedPairCount) {
      throw const FormatException(
        'Catalog pair entry count does not match directedPairCount.',
      );
    }

    final ids = <String>{};
    final entries = <LanguagePackCatalogEntry>[];
    for (final row in rawEntries) {
      final source = _language(
        row['sourceLanguage'],
        'catalog.pairs.sourceLanguage',
      );
      final target = _language(
        row['targetLanguage'],
        'catalog.pairs.targetLanguage',
      );
      final id = _requiredString(
        row['id'],
        'catalog.pairs.id',
      ).toLowerCase();

      if (source == target || id != '$source->$target' || !ids.add(id)) {
        throw FormatException(
          'Invalid or duplicate catalog pair: $id.',
        );
      }

      final readiness = _requiredString(
        row['readiness'],
        'catalog.pairs.readiness',
      ).toLowerCase();
      if (!const <String>{
        'ready',
        'partial',
        'supported_not_generated',
        'not_ready',
      }.contains(readiness)) {
        throw FormatException(
          'Unsupported catalog readiness value: $readiness.',
        );
      }

      final assetPath = _optionalString(row['assetPath']);
      final entryChecksum = _optionalString(
        row['checksum'],
      )?.toLowerCase();
      if (entryChecksum != null && !_isChecksum(entryChecksum)) {
        throw FormatException(
          'Invalid pack checksum for catalog pair $id.',
        );
      }

      final vocabularyCount = _requiredInt(
        row['vocabularyCount'],
        'catalog.pairs.vocabularyCount',
      );
      final grammarCount = _requiredInt(
        row['grammarCount'],
        'catalog.pairs.grammarCount',
      );
      if (vocabularyCount < 0 || grammarCount < 0) {
        throw FormatException(
          'Catalog pair counts must be non-negative for $id.',
        );
      }

      final loadable =
          readiness == 'ready' || readiness == 'partial';
      if (loadable && (assetPath == null || entryChecksum == null)) {
        throw FormatException(
          'Loadable catalog pair $id must declare assetPath and checksum.',
        );
      }
      if (!loadable && assetPath != null) {
        throw FormatException(
          'Non-loadable catalog pair $id must not declare an assetPath.',
        );
      }

      entries.add(
        LanguagePackCatalogEntry(
          id: id,
          sourceLanguage: source,
          targetLanguage: target,
          readiness: readiness,
          assetPath: assetPath,
          checksum: entryChecksum,
          vocabularyCount: vocabularyCount,
          grammarCount: grammarCount,
          reason: _optionalString(row['reason']),
        ),
      );
    }

    final loadableCount =
        entries.where((entry) => entry.isLoadable).length;
    if (loadableCount != generatedPairCount) {
      throw FormatException(
        'Catalog generatedPairCount $generatedPairCount does not match '
        'loadable entry count $loadableCount.',
      );
    }

    return PolyglotLanguagePackCatalog._(
      schemaVersion: schemaVersion,
      languageCount: languageCount,
      directedPairCount: directedPairCount,
      generatedPairCount: generatedPairCount,
      entries: List<LanguagePackCatalogEntry>.unmodifiable(entries),
      checksum: checksum,
    );
  }

  LanguagePackCatalogEntry requirePair(
    String sourceLanguage,
    String targetLanguage,
  ) {
    final source = _language(sourceLanguage, 'sourceLanguage');
    final target = _language(targetLanguage, 'targetLanguage');
    final id = '$source->$target';
    for (final entry in entries) {
      if (entry.id == id) return entry;
    }
    throw ArgumentError.value(
      id,
      'directedPair',
      'Pair is not present in the language pack catalog.',
    );
  }
}

Map<String, Object?> _stringMap(Object? value, String field) {
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

List<Map<String, Object?>> _objectList(Object? value, String field) {
  if (value is! List) {
    throw FormatException('$field must be an array.');
  }
  return List<Map<String, Object?>>.unmodifiable(
    value.map((item) => _stringMap(item, field)),
  );
}

List<String> _stringList(Object? value, String field) {
  if (value is! List) {
    throw FormatException('$field must be an array.');
  }
  return List<String>.unmodifiable(
    value.map((item) => _requiredString(item, field)),
  );
}

String _requiredString(Object? value, String field) {
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$field must be a non-empty string.');
  }
  return value.trim();
}

int _requiredInt(Object? value, String field) {
  if (value is! num) {
    throw FormatException('$field must be numeric.');
  }
  return value.toInt();
}

String? _optionalString(Object? value) {
  if (value == null) return null;
  if (value is! String) {
    throw const FormatException(
      'Optional catalog text must be a string.',
    );
  }
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

String _language(Object? value, String field) {
  final normalized = _requiredString(value, field)
      .replaceAll('_', '-')
      .toLowerCase();
  if (!RegExp(r'^[a-z]{2,8}(?:-[a-z0-9]{1,8})*$')
      .hasMatch(normalized)) {
    throw FormatException('$field is not a valid language tag.');
  }
  return normalized;
}

bool _canonicalTaskId(String value) {
  final match = RegExp(r'^task-(\d{2})$').firstMatch(value);
  if (match == null) return false;
  final number = int.tryParse(match.group(1) ?? '');
  return number != null && number >= 1 && number <= 50;
}

bool _isChecksum(String value) =>
    value.length == 32 &&
    !RegExp(r'[^0-9a-f]').hasMatch(value);
