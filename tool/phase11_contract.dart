import 'dart:convert';
import 'dart:io';

import 'package:deutsch_bilarabi/core/orchestration/language_pack_repository.dart';
import 'package:deutsch_bilarabi/core/orchestration/polyglot_language_pack.dart';
import 'package:deutsch_bilarabi/core/storage/validation_hash_cache.dart';

Future<void> main() async {
  final seedCatalog = PolyglotLanguagePackCatalog.parse(
    await File('assets/lang_data/catalog.json').readAsString(),
  );
  _expect(seedCatalog.languageCount, 20, 'seed catalog language count');
  _expect(seedCatalog.directedPairCount, 380, 'seed catalog pair count');
  _expect(
    seedCatalog.requirePair('ar', 'de').readiness,
    'supported_not_generated',
    'supported seed pair fails closed before generation',
  );

  final unsigned = <String, Object?>{
    'schemaVersion': 1,
    'pair': <String, Object?>{
      'id': 'ar->de',
      'sourceLanguage': 'ar',
      'targetLanguage': 'de',
      'readiness': 'ready',
    },
    'curriculumTasks': <Object?>[
      <String, Object?>{
        'id': 'task-01',
        'order': 1,
        'topic': 'onboarding',
        'skill': 'orientation',
        'vocabularyRefs': const <String>['w0001'],
        'grammarRefs': const <String>[],
      },
    ],
    'vocabularyPool': <Object?>[
      <String, Object?>{
        'id': 'w0001',
        'source': 'مرحبًا',
        'target': 'Hallo',
        'sourceExample': 'مرحبًا! كيف حالك؟',
        'targetExample': 'Hallo! Wie geht es dir?',
        'topic': 'التحية',
        'skill': 'recall',
      },
    ],
    'grammarMatrix': const <Object?>[],
  };
  final payload = jsonEncode(unsigned);
  final checksum = ContentChecksum.compute(
    scopeKey: 'ar->de|pack',
    content: payload,
    validatorVersion: PolyglotLanguagePack.validatorVersion,
  );
  final encoded = jsonEncode(<String, Object?>{
    ...unsigned,
    'checksum': <String, Object?>{
      'algorithm': PolyglotLanguagePack.checksumAlgorithm,
      'validatorVersion': PolyglotLanguagePack.validatorVersion,
      'value': checksum,
    },
  });

  final pack = PolyglotLanguagePack.parse(encoded);
  _expect(pack.directedPair, 'ar->de', 'pair identity');
  _expect(pack.curriculumTasks.length, 1, 'task parsed');
  _expect(pack.vocabularyPool.length, 1, 'vocabulary parsed');
  _expect(pack.checksum, checksum, 'checksum preserved');

  var loads = 0;
  final reversed = _reversePack(encoded);
  final sources = <String, String>{
    'assets/lang_data/catalog.json': _catalog(
      arDeChecksum: checksum,
      deArChecksum: PolyglotLanguagePack.parse(reversed).checksum,
    ),
    'assets/lang_data/ar_de.json': encoded,
    'assets/lang_data/de_ar.json': reversed,
  };
  final repository = LanguagePackRepository(
    loadText: (path) async {
      loads += 1;
      final value = sources[path];
      if (value == null) throw StateError('missing $path');
      return value;
    },
  );

  final first = await repository.loadPair('ar', 'de');
  _expect(first.directedPair, 'ar->de', 'lazy pair load');
  _expect(loads, 2, 'first load reads catalog plus one pair file');

  final same = await repository.loadPair('ar', 'de');
  _expect(identical(first, same), true, 'active pair is reused in memory');
  _expect(loads, 2, 'same pair does not reload');

  final reverse = await repository.loadPair('de', 'ar');
  _expect(reverse.directedPair, 'de->ar', 'reverse pair load');
  _expect(loads, 3, 'switch loads only the newly requested pair');
  _expect(repository.activePair, 'de->ar', 'only latest pair is active');

  var unsupportedRejected = false;
  try {
    await repository.loadPair('en', 'de');
  } on StateError {
    unsupportedRejected = true;
  }
  _expect(
    unsupportedRejected,
    true,
    'catalog rejects unsupported pair before file loading',
  );
  _expect(loads, 3, 'unsupported pair does not touch another pack file');

  var tampered = jsonDecode(encoded) as Map<String, Object?>;
  tampered = Map<String, Object?>.from(tampered);
  final vocab = List<Object?>.from(tampered['vocabularyPool']! as List);
  final row = Map<String, Object?>.from(vocab.first! as Map);
  row['target'] = 'Manipulated';
  vocab[0] = row;
  tampered['vocabularyPool'] = vocab;

  var rejected = false;
  try {
    PolyglotLanguagePack.parse(jsonEncode(tampered));
  } on FormatException {
    rejected = true;
  }
  _expect(rejected, true, 'checksum rejects tampered pack');

  repository.clear();
  _expect(repository.activePair, null, 'clear releases active pack');

  final temp = await Directory.systemTemp.createTemp('phase11-pack-contract-');
  try {
    await File('${temp.path}/catalog.json').writeAsString(
      sources['assets/lang_data/catalog.json']!,
    );
    await File('${temp.path}/ar_de.json').writeAsString(encoded);

    final local = LanguagePackRepository(
      assetRoot: '',
      loadText: (path) =>
          File('${temp.path}/$path').readAsString(),
    );
    final localPack = await local.loadPair('ar', 'de');
    _expect(
      localPack.directedPair,
      'ar->de',
      'sandbox local-directory loader reads requested pair',
    );
  } finally {
    await temp.delete(recursive: true);
  }
}

String _catalog({
  required String arDeChecksum,
  required String deArChecksum,
}) {
  final rows = <Object?>[
    <String, Object?>{
      'id': 'ar->de',
      'sourceLanguage': 'ar',
      'targetLanguage': 'de',
      'readiness': 'ready',
      'assetPath': 'assets/lang_data/ar_de.json',
      'checksum': arDeChecksum,
      'vocabularyCount': 1,
      'grammarCount': 0,
      'reason': null,
    },
    <String, Object?>{
      'id': 'de->ar',
      'sourceLanguage': 'de',
      'targetLanguage': 'ar',
      'readiness': 'partial',
      'assetPath': 'assets/lang_data/de_ar.json',
      'checksum': deArChecksum,
      'vocabularyCount': 1,
      'grammarCount': 0,
      'reason': null,
    },
    for (final pair in const <(String, String)>[
      ('ar', 'en'),
      ('en', 'ar'),
      ('de', 'en'),
      ('en', 'de'),
    ])
      <String, Object?>{
        'id': '${pair.$1}->${pair.$2}',
        'sourceLanguage': pair.$1,
        'targetLanguage': pair.$2,
        'readiness': 'not_ready',
        'assetPath': null,
        'checksum': null,
        'vocabularyCount': 0,
        'grammarCount': 0,
        'reason': 'No canonical bilingual content evidence is available.',
      },
  ];

  final unsigned = <String, Object?>{
    'schemaVersion': 1,
    'languageCount': 3,
    'directedPairCount': 6,
    'generatedPairCount': 2,
    'networkUsed': false,
    'pairs': rows,
  };
  final checksum = ContentChecksum.compute(
    scopeKey: 'polyglot-catalog|3x6',
    content: jsonEncode(unsigned),
    validatorVersion: PolyglotLanguagePackCatalog.validatorVersion,
  );
  return jsonEncode(
    <String, Object?>{
      ...unsigned,
      'checksum': <String, Object?>{
        'algorithm': PolyglotLanguagePack.checksumAlgorithm,
        'validatorVersion':
            PolyglotLanguagePackCatalog.validatorVersion,
        'value': checksum,
      },
    },
  );
}

String _reversePack(String encoded) {
  final root = Map<String, Object?>.from(
    jsonDecode(encoded) as Map,
  );
  root['pair'] = <String, Object?>{
    'id': 'de->ar',
    'sourceLanguage': 'de',
    'targetLanguage': 'ar',
    'readiness': 'partial',
  };
  final vocabulary = <Object?>[];
  for (final raw in root['vocabularyPool']! as List) {
    final row = Map<String, Object?>.from(raw as Map);
    final source = row['source'];
    final target = row['target'];
    final sourceExample = row['sourceExample'];
    final targetExample = row['targetExample'];
    row['source'] = target;
    row['target'] = source;
    row['sourceExample'] = targetExample;
    row['targetExample'] = sourceExample;
    vocabulary.add(row);
  }
  root['vocabularyPool'] = vocabulary;
  root.remove('checksum');

  final payload = jsonEncode(root);
  final checksum = ContentChecksum.compute(
    scopeKey: 'de->ar|pack',
    content: payload,
    validatorVersion: PolyglotLanguagePack.validatorVersion,
  );
  root['checksum'] = <String, Object?>{
    'algorithm': PolyglotLanguagePack.checksumAlgorithm,
    'validatorVersion': PolyglotLanguagePack.validatorVersion,
    'value': checksum,
  };
  return jsonEncode(root);
}

void _expect(Object? actual, Object? expected, String contract) {
  if (actual != expected) {
    throw StateError(
      'Phase 11 contract failed: $contract. '
      'Expected <$expected>, got <$actual>.',
    );
  }
}
