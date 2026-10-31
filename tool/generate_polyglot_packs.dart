import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:deutsch_bilarabi/core/agents/memory_models.dart';
import 'package:deutsch_bilarabi/core/agents/polyglot_agent_models.dart';
import 'package:deutsch_bilarabi/core/agents/system_agent_runtime.dart';
import 'package:deutsch_bilarabi/core/curriculum/canonical_curriculum_50.dart';
import 'package:deutsch_bilarabi/core/curriculum/curriculum_models.dart';
import 'package:deutsch_bilarabi/core/curriculum/omni_directional_matrix.dart';
import 'package:deutsch_bilarabi/core/orchestration/agent_data_integrity.dart';
import 'package:deutsch_bilarabi/core/orchestration/headless_localization_bridge.dart';
import 'package:deutsch_bilarabi/core/orchestration/language_pack_repository.dart';
import 'package:deutsch_bilarabi/core/orchestration/polyglot_language_pack.dart';
import 'package:deutsch_bilarabi/core/storage/validation_hash_cache.dart';
import 'package:deutsch_bilarabi/data/content_a1.dart';
import 'package:deutsch_bilarabi/models/content.dart';

const Set<String> _supportedPairs = <String>{
  'ar->de',
  'de->ar',
};

Future<void> main(List<String> args) async {
  final options = _Options.parse(args);
  final output = Directory(options.outputDirectory);
  await output.create(recursive: true);

  final bridge = HeadlessLocalizationBridge.start();
  final runtime = await SystemAgentRuntime.start(
    memoryStore: _MemoryStore(),
  );

  final generated = <String, _GeneratedPack>{};
  final stopwatch = Stopwatch()..start();

  try {
    for (final pair in options.pairs) {
      if (!_supportedPairs.contains(pair)) {
        throw StateError(
          'Pair $pair is not content-ready. '
          'Only ar->de and de->ar have canonical bilingual evidence.',
        );
      }

      final separator = pair.indexOf('->');
      final source = pair.substring(0, separator);
      final target = pair.substring(separator + 2);
      await _activatePair(runtime, source, target);

      final generatedPack = await _generatePair(
        runtime: runtime,
        source: source,
        target: target,
      );
      generated[pair] = generatedPack;

      final fileName = LanguagePackRepository.fileNameForPair(
        source,
        target,
      );
      await _writeJson(
        File('${output.path}/$fileName'),
        generatedPack.document,
      );
    }

    final catalog = _buildCatalog(
      OmniDirectionalLearningMatrix.standard20(),
      generated,
    );
    await _writeJson(
      File('${output.path}/catalog.json'),
      catalog,
    );

    stopwatch.stop();
    stdout.writeln(
      jsonEncode(
        <String, Object?>{
          'ok': true,
          'outputDirectory': output.path,
          'generatedPairs': generated.keys.toList(growable: false),
          'packCount': generated.length,
          'catalogPairs':
              OmniDirectionalLearningMatrix.standard20().directedPairCount,
          'elapsedMs': stopwatch.elapsedMilliseconds,
          'networkUsed': false,
        },
      ),
    );
  } finally {
    await runtime.close();
    await bridge.close();
  }
}

Future<void> _activatePair(
  SystemAgentRuntime runtime,
  String source,
  String target,
) async {
  final next = runtime.polyglotMatrixChanges.firstWhere(
    (state) =>
        state.sourceLanguageCode == source &&
        state.targetLanguageCode == target,
  );
  runtime.requestLearningPair(
    sourceLanguageTag: source,
    targetLanguageTag: target,
  );
  await next.timeout(const Duration(seconds: 2));
}

Future<_GeneratedPack> _generatePair({
  required SystemAgentRuntime runtime,
  required String source,
  required String target,
}) async {
  final vocabulary = <Map<String, Object?>>[
    for (final item in a1) _vocabularyRecord(item, source, target),
  ];
  final grammar = target == 'de'
      ? await _generateGermanGrammar(runtime)
      : <Map<String, Object?>>[];

  final refsByTask = _buildTaskVocabularyRefs(a1);
  final grammarRefs = <String, List<String>>{};
  for (final item in grammar) {
    final taskId = item['taskId'] as String;
    grammarRefs.putIfAbsent(taskId, () => <String>[]).add(
          item['id'] as String,
        );
  }

  final tasks = <Map<String, Object?>>[
    for (final task in CanonicalCurriculum50.tasks)
      _taskRecord(
        task: task,
        source: source,
        target: target,
        vocabularyRefs: refsByTask[task.id] ?? const <String>[],
        grammarRefs: grammarRefs[task.id] ?? const <String>[],
      ),
  ];

  const readiness = 'partial';
  final unsigned = <String, Object?>{
    'schemaVersion': PolyglotLanguagePack.currentSchemaVersion,
    'pair': <String, Object?>{
      'id': '$source->$target',
      'sourceLanguage': source,
      'targetLanguage': target,
      'readiness': readiness,
    },
    'generation': <String, Object?>{
      'source': 'canonical-runtime',
      'curriculum': 'CanonicalCurriculum50',
      'taskCount': tasks.length,
      'vocabularyCount': vocabulary.length,
      'grammarCount': grammar.length,
      'grammarEngineAvailable': target == 'de',
      'networkUsed': false,
      'vocabularyAssignment': 'canonical-topic-overlap-v1',
    },
    'curriculumTasks': tasks,
    'vocabularyPool': vocabulary,
    'grammarMatrix': grammar,
  };

  final unsignedPayload = jsonEncode(unsigned);
  final integrity = _verifyVocabularyIntegrity(
    vocabulary,
    source: source,
    target: target,
  );
  final validation = await runtime.validateContentOnce(
    scopeType: 'language_pack',
    sourceLanguageTag: source,
    targetLanguageTag: target,
    canonicalKey: '$source->$target',
    content: unsignedPayload,
    validatorVersion: PolyglotLanguagePack.validatorVersion,
    validator: () async =>
        tasks.length == 50 &&
        vocabulary.isNotEmpty &&
        integrity.isValid,
  );
  if (!validation.validated) {
    throw StateError(
      'SystemAgentRuntime rejected $source->$target pack validation.',
    );
  }

  final checksum = ContentChecksum.compute(
    scopeKey: '$source->$target|pack',
    content: unsignedPayload,
    validatorVersion: PolyglotLanguagePack.validatorVersion,
  );
  final document = <String, Object?>{
    ...unsigned,
    'checksum': <String, Object?>{
      'algorithm': PolyglotLanguagePack.checksumAlgorithm,
      'validatorVersion': PolyglotLanguagePack.validatorVersion,
      'value': checksum,
    },
  };

  PolyglotLanguagePack.parse(jsonEncode(document));

  return _GeneratedPack(
    pair: '$source->$target',
    readiness: readiness,
    checksum: checksum,
    document: document,
    vocabularyCount: vocabulary.length,
    grammarCount: grammar.length,
  );
}

Future<List<Map<String, Object?>>> _generateGermanGrammar(
  SystemAgentRuntime runtime,
) async {
  final specs = <(String, String, UniversalGrammarCapability)>[
    (
      'task-27',
      'comparison',
      UniversalGrammarCapability.comparativeSuperlative,
    ),
    (
      'task-28',
      'konjunktiv-ii',
      UniversalGrammarCapability.konjunktivIi,
    ),
  ];

  final output = <Map<String, Object?>>[];
  for (final spec in specs) {
    final result = await runtime.requestGrammar(
      capability: spec.$3,
      seed: int.parse(spec.$1.substring(5)),
      count: 8,
    );
    if (!result.ok) {
      throw StateError(
        'Grammar runtime rejected ${spec.$3.wireName}: '
        '${result.errorCode ?? result.message ?? 'unknown'}',
      );
    }

    for (var index = 0; index < result.items.length; index++) {
      final raw = result.items[index];
      final rawId = raw['id'];
      final suffix = rawId is String && rawId.trim().isNotEmpty
          ? rawId.trim()
          : index.toString().padLeft(2, '0');
      output.add(
        <String, Object?>{
          'id': '${spec.$1}:${spec.$3.wireName}:$suffix',
          'taskId': spec.$1,
          'canonicalTopic': spec.$2,
          'capability': spec.$3.wireName,
          'targetLanguage': result.targetLanguageTag,
          'engineId': result.engineId,
          'data': raw,
        },
      );
    }
  }
  return output;
}

Map<String, Object?> _vocabularyRecord(
  ContentItem item,
  String source,
  String target,
) {
  final germanToArabic = source == 'de' && target == 'ar';
  final arabicToGerman = source == 'ar' && target == 'de';
  if (!germanToArabic && !arabicToGerman) {
    throw StateError('Unsupported canonical content pair: $source->$target');
  }

  final sourceText = germanToArabic ? item.german : item.arabic;
  final targetText = germanToArabic ? item.arabic : item.german;
  final sourceExample = germanToArabic ? item.sentence : item.sentenceAr;
  final targetExample = germanToArabic ? item.sentenceAr : item.sentence;

  return <String, Object?>{
    'id': item.id,
    'source': sourceText,
    'target': targetText,
    'sourceExample': sourceExample,
    'targetExample': targetExample,
    'topic': item.topic,
    'skill': item.skill,
    'acceptedTargetForms': target == 'de'
        ? <String>{item.german, ...item.accepted}.toList(growable: false)
        : <String>[item.arabic],
    'languageSpecific': <String, Object?>{
      'de': <String, Object?>{
        'article': item.article,
        'plural': item.plural,
      },
    },
  };
}

Map<String, List<String>> _buildTaskVocabularyRefs(
  List<ContentItem> items,
) {
  final output = <String, List<String>>{};
  for (final task in CanonicalCurriculum50.tasks) {
    final refs = <String>[];
    for (final item in items) {
      if (_topicOverlaps(task.titleAr, item.topic)) {
        refs.add(item.id);
        if (refs.length >= 32) break;
      }
    }
    output[task.id] = List<String>.unmodifiable(refs);
  }
  return output;
}

bool _topicOverlaps(String taskTitleAr, String itemTopic) {
  final taskTokens = _semanticTokens(taskTitleAr);
  final topicTokens = _semanticTokens(itemTopic);
  if (taskTokens.isEmpty || topicTokens.isEmpty) return false;
  return topicTokens.any(taskTokens.contains);
}

Set<String> _semanticTokens(String value) {
  final normalized = value
      .toLowerCase()
      .replaceAll(RegExp(r'[^\u0600-\u06ffA-Za-z0-9]+'), ' ')
      .trim();
  if (normalized.isEmpty) return const <String>{};

  const stop = <String>{
    'في',
    'من',
    'مع',
    'على',
    'إلى',
    'عن',
    'و',
    'أو',
    'der',
    'die',
    'das',
    'mit',
    'und',
  };

  return normalized
      .split(RegExp(r'\s+'))
      .map(_stripArabicArticle)
      .where((token) => token.length >= 3 && !stop.contains(token))
      .toSet();
}

String _stripArabicArticle(String value) {
  if (value.startsWith('ال') && value.length > 4) {
    return value.substring(2);
  }
  return value;
}

Map<String, Object?> _taskRecord({
  required CurriculumTask task,
  required String source,
  required String target,
  required List<String> vocabularyRefs,
  required List<String> grammarRefs,
}) {
  final sourceTitle = source == 'ar' ? task.titleAr : task.titleDe;
  final targetTitle = target == 'ar' ? task.titleAr : task.titleDe;

  return <String, Object?>{
    'id': task.id,
    'order': task.order,
    'stage': task.stage.code,
    'kind': task.kind.name,
    'topic': task.topic,
    'skill': task.skill,
    'sourceTitle': sourceTitle,
    'targetTitle': targetTitle,
    'masteryThreshold': task.masteryThreshold,
    'targetItemCount': task.targetItemCount,
    'prerequisiteIds': task.prerequisiteIds,
    'vocabularyRefs': vocabularyRefs,
    'grammarRefs': grammarRefs,
  };
}

AgentDataIntegrityReport _verifyVocabularyIntegrity(
  List<Map<String, Object?>> vocabulary, {
  required String source,
  required String target,
}) {
  final records = <AgentDataRecord>[
    for (final item in vocabulary)
      AgentDataRecord(
        recordId: '$source->$target:${item['id']}',
        domain: AgentDataDomain.vocabulary,
        sourceLanguage: source,
        targetLanguage: target,
        canonicalKey: item['id']! as String,
        fingerprint: jsonEncode(
          <String, Object?>{
            'source': item['source'],
            'target': item['target'],
            'topic': item['topic'],
          },
        ),
      ),
  ];
  return const AgentDataIntegrityVerifier().verify(records);
}

Map<String, Object?> _buildCatalog(
  OmniDirectionalLearningMatrix matrix,
  Map<String, _GeneratedPack> generated,
) {
  final pairs = <Object?>[];
  for (final pair in matrix.allPairs) {
    final ready = generated[pair.id];
    final supported = _supportedPairs.contains(pair.id);
    pairs.add(
      <String, Object?>{
        'id': pair.id,
        'sourceLanguage': pair.source.id,
        'targetLanguage': pair.target.id,
        'readiness': ready?.readiness ??
            (supported ? 'supported_not_generated' : 'not_ready'),
        'assetPath': ready == null
            ? null
            : 'assets/lang_data/${LanguagePackRepository.fileNameForPair(
                pair.source.id,
                pair.target.id,
              )}',
        'checksum': ready?.checksum,
        'vocabularyCount': ready?.vocabularyCount ?? 0,
        'grammarCount': ready?.grammarCount ?? 0,
        'reason': ready != null
            ? null
            : supported
                ? 'Canonical pair is supported but was not requested.'
                : 'No canonical bilingual content evidence is available.',
      },
    );
  }

  final unsigned = <String, Object?>{
    'schemaVersion': 1,
    'languageCount': matrix.languages.length,
    'directedPairCount': matrix.directedPairCount,
    'generatedPairCount': generated.length,
    'networkUsed': false,
    'pairs': pairs,
  };
  final checksum = ContentChecksum.compute(
    scopeKey:
        'polyglot-catalog|${matrix.languages.length}x${matrix.directedPairCount}',
    content: jsonEncode(unsigned),
    validatorVersion: 'phase11.catalog.v1',
  );

  return <String, Object?>{
    ...unsigned,
    'checksum': <String, Object?>{
      'algorithm': PolyglotLanguagePack.checksumAlgorithm,
      'validatorVersion': 'phase11.catalog.v1',
      'value': checksum,
    },
  };
}

Future<void> _writeJson(
  File destination,
  Map<String, Object?> document,
) async {
  await destination.parent.create(recursive: true);
  final temp = File('${destination.path}.tmp');
  await temp.writeAsString(
    '${const JsonEncoder.withIndent('  ').convert(document)}\n',
    flush: true,
  );
  if (await destination.exists()) {
    await destination.delete();
  }
  await temp.rename(destination.path);
}

final class _GeneratedPack {
  const _GeneratedPack({
    required this.pair,
    required this.readiness,
    required this.checksum,
    required this.document,
    required this.vocabularyCount,
    required this.grammarCount,
  });

  final String pair;
  final String readiness;
  final String checksum;
  final Map<String, Object?> document;
  final int vocabularyCount;
  final int grammarCount;
}

final class _MemoryStore implements MemoryAgentStore {
  String? _encoded;

  @override
  Future<String?> read() async => _encoded;

  @override
  Future<void> write(String encoded) async {
    _encoded = encoded;
  }
}

final class _Options {
  const _Options({
    required this.outputDirectory,
    required this.pairs,
  });

  final String outputDirectory;
  final List<String> pairs;

  static _Options parse(List<String> args) {
    var output = 'assets/lang_data';
    var pairs = <String>['ar->de', 'de->ar'];

    for (final arg in args) {
      if (arg.startsWith('--output-dir=')) {
        output = arg.substring('--output-dir='.length).trim();
      } else if (arg.startsWith('--pairs=')) {
        pairs = arg
            .substring('--pairs='.length)
            .split(',')
            .map((item) => item.trim().toLowerCase())
            .where((item) => item.isNotEmpty)
            .toList(growable: false);
      } else {
        throw ArgumentError('Unknown Phase 11 argument: $arg');
      }
    }

    if (output.isEmpty) {
      throw ArgumentError('Output directory must not be empty.');
    }
    if (pairs.isEmpty) {
      throw ArgumentError('At least one directed pair is required.');
    }
    for (final pair in pairs) {
      if (!RegExp(r'^[a-z]{2,8}(?:-[a-z0-9]{1,8})?->'
              r'[a-z]{2,8}(?:-[a-z0-9]{1,8})?$')
          .hasMatch(pair)) {
        throw ArgumentError('Invalid directed pair: $pair');
      }
    }

    return _Options(
      outputDirectory: output,
      pairs: List<String>.unmodifiable(pairs.toSet()),
    );
  }
}
