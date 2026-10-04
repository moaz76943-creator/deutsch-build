import 'dart:convert';
import 'dart:io';

import 'package:deutsch_bilarabi/language/german/german_language_pack.dart';
import 'package:deutsch_bilarabi/services/active_pack_runtime_provider.dart';
import 'package:deutsch_bilarabi/services/grammar_hub_service.dart';
import 'package:deutsch_bilarabi/services/pack_database_key_store.dart';
import 'package:deutsch_bilarabi/services/pack_manager_service.dart';
import 'package:deutsch_bilarabi/services/preferences_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const int _fixtureContentRows = 130;
const int _fixtureVerbRows = 12;

final class _TestPackDatabaseKeyStore implements PackDatabaseKeyStore {
  const _TestPackDatabaseKeyStore();

  @override
  Future<String> getOrCreateKey() async =>
      base64Encode(List<int>.filled(32, 9));

  @override
  Future<String?> readKey() => getOrCreateKey();
}

final class _RejectingAdmissionGate implements RuntimePackAdmissionGate {
  const _RejectingAdmissionGate(this.code);

  final String code;

  @override
  Future<void> verify({
    required InstalledLanguagePack pack,
    required String sqlitePath,
  }) async {
    throw RuntimePackAdmissionException(code);
  }
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  test(
    'canonical active pack exposes indexed SQLite corpus and grammar runtime',
    () async {
      final root = await Directory.systemTemp.createTemp('active_pack_');
      final sqlitePath = _sqlitePath(root, 'de-core');
      await _createCanonicalPackDatabase(
        sqlitePath,
        includeGrammar: true,
      );
      SharedPreferences.setMockInitialValues(
        _installedPreferences('de-core'),
      );
      final preferences = await PreferencesService.instance();
      final manager = PackManagerService(
        preferences,
        rootDirectory: root,
      );
      final fallbackGrammar = GrammarHubService(
        factory: databaseFactoryFfi,
        path: p.join(root.path, 'fallback_grammar.db'),
      );

      final runtime = await ActivePackRuntimeProvider(
        packManager: manager,
        languagePack: const GermanLanguagePack(),
        embeddedGrammar: fallbackGrammar,
        databaseFactory: databaseFactoryFfi,
        databaseKeyStore: const _TestPackDatabaseKeyStore(),
      ).resolve();

      expect(runtime.state.origin, RuntimeContentOrigin.activePack);
      expect(runtime.state.activePackId, 'de-core');
      expect(runtime.languagePack.contentPack.items, isEmpty);
      expect(runtime.hasIndexedCorpus, isTrue);

      final repository = runtime.corpusRepository!;
      expect(repository.verification.contentRows, _fixtureContentRows);
      expect(repository.verification.verbRows, _fixtureVerbRows);
      expect(
        repository.verification.expectedContentRows,
        _fixtureContentRows,
      );
      expect(
        repository.verification.expectedVerbRows,
        _fixtureVerbRows,
      );
      expect(repository.verification.hasExpectedCardinality, isTrue);

      final lernen = await repository.fetchByIds(
        const <String>['verb.lernen'],
      );
      expect(lernen, hasLength(1));
      expect(lernen.single.german, 'lernen');
      expect(lernen.single.arabic, 'تعلم');
      expect(lernen.single.accepted, contains('lernen'));

      final verbRows = await repository.fetchVerbRows(
        infinitive: 'lernen',
      );
      expect(verbRows, hasLength(6));
      expect(verbRows.first.person, 'ich');
      expect(verbRows.first.form, 'lerne');

      final bounded = await repository.fetchPage(limit: 999);
      expect(bounded, hasLength(128));

      final topics =
          await runtime.grammarHubService.getTopicsByLevel('A1');
      expect(topics.single.id, 'pack_a1');
      expect(topics.single.titleDe, 'Pack Grammatik');

      await runtime.grammarHubService.saveTopicMastery(
        'pack_a1',
        true,
      );
      final mastered =
          await runtime.grammarHubService.getTopicDetail('pack_a1');
      expect(mastered?.isMastered, isTrue);

      await runtime.closeCorpus();
      await runtime.grammarHubService.close();
      manager.dispose();
      await root.delete(recursive: true);
    },
  );

  test(
    'pack metadata content cardinality mismatch fails closed',
    () async {
      final root =
          await Directory.systemTemp.createTemp('cardinality_mismatch_');
      final sqlitePath = _sqlitePath(root, 'de-core');
      await _createCanonicalPackDatabase(
        sqlitePath,
        includeGrammar: true,
        declaredContentRows: _fixtureContentRows + 1,
      );
      SharedPreferences.setMockInitialValues(
        _installedPreferences('de-core'),
      );
      final preferences = await PreferencesService.instance();
      final manager = PackManagerService(
        preferences,
        rootDirectory: root,
      );
      final fallbackGrammar = GrammarHubService(
        factory: databaseFactoryFfi,
        path: p.join(root.path, 'fallback_cardinality.db'),
      );

      final runtime = await ActivePackRuntimeProvider(
        packManager: manager,
        languagePack: const GermanLanguagePack(),
        embeddedGrammar: fallbackGrammar,
        databaseFactory: databaseFactoryFfi,
        databaseKeyStore: const _TestPackDatabaseKeyStore(),
      ).resolve();

      expect(runtime.state.origin, RuntimeContentOrigin.embeddedFallback);
      expect(
        runtime.state.fallbackReason,
        'pack_content_cardinality_mismatch',
      );
      expect(runtime.corpusRepository, isNull);

      await runtime.closeCorpus();
      await runtime.grammarHubService.close();
      manager.dispose();
      await root.delete(recursive: true);
    },
  );

  test(
    'corrupt active SQLite fails closed without compiled corpus fallback',
    () async {
      final root = await Directory.systemTemp.createTemp('corrupt_pack_');
      final sqlite = File(_sqlitePath(root, 'de-core'));
      await sqlite.parent.create(recursive: true);
      await sqlite.writeAsBytes(<int>[1, 2, 3, 4], flush: true);
      SharedPreferences.setMockInitialValues(
        _installedPreferences('de-core'),
      );
      final preferences = await PreferencesService.instance();
      final manager = PackManagerService(
        preferences,
        rootDirectory: root,
      );
      final fallbackGrammar = GrammarHubService(
        factory: databaseFactoryFfi,
        path: p.join(root.path, 'fallback_corrupt.db'),
      );

      final runtime = await ActivePackRuntimeProvider(
        packManager: manager,
        languagePack: const GermanLanguagePack(),
        embeddedGrammar: fallbackGrammar,
        databaseFactory: databaseFactoryFfi,
        databaseKeyStore: const _TestPackDatabaseKeyStore(),
      ).resolve();

      expect(runtime.state.origin, RuntimeContentOrigin.embeddedFallback);
      expect(runtime.state.activePackId, 'de-core');
      expect(
        runtime.state.fallbackReason,
        'active_pack_runtime_invalid',
      );
      expect(runtime.corpusRepository, isNull);
      expect(runtime.languagePack.contentPack.items, isEmpty);

      await runtime.closeCorpus();
      await runtime.grammarHubService.close();
      manager.dispose();
      await root.delete(recursive: true);
    },
  );

  test(
    'admission rejection fails closed before SQLite trust',
    () async {
      final root = await Directory.systemTemp.createTemp('rejected_pack_');
      final sqlite = File(_sqlitePath(root, 'de-core'));
      await sqlite.parent.create(recursive: true);
      await sqlite.writeAsBytes(<int>[0], flush: true);
      SharedPreferences.setMockInitialValues(
        _installedPreferences('de-core'),
      );
      final preferences = await PreferencesService.instance();
      final manager = PackManagerService(
        preferences,
        rootDirectory: root,
      );
      final fallbackGrammar = GrammarHubService(
        factory: databaseFactoryFfi,
        path: p.join(root.path, 'fallback_rejected.db'),
      );

      final runtime = await ActivePackRuntimeProvider(
        packManager: manager,
        languagePack: const GermanLanguagePack(),
        embeddedGrammar: fallbackGrammar,
        databaseFactory: databaseFactoryFfi,
        databaseKeyStore: const _TestPackDatabaseKeyStore(),
        admissionGate:
            const _RejectingAdmissionGate('signature_failed'),
      ).resolve();

      expect(runtime.state.origin, RuntimeContentOrigin.embeddedFallback);
      expect(runtime.state.fallbackReason, 'signature_failed');
      expect(runtime.corpusRepository, isNull);
      expect(runtime.languagePack.contentPack.items, isEmpty);

      await runtime.closeCorpus();
      await runtime.grammarHubService.close();
      manager.dispose();
      await root.delete(recursive: true);
    },
  );

  test(
    'canonical corpus remains active when grammar routes to fallback',
    () async {
      final root =
          await Directory.systemTemp.createTemp('grammar_fallback_');
      final sqlitePath = _sqlitePath(root, 'de-core');
      await _createCanonicalPackDatabase(
        sqlitePath,
        includeGrammar: false,
      );
      SharedPreferences.setMockInitialValues(
        _installedPreferences('de-core'),
      );
      final preferences = await PreferencesService.instance();
      final manager = PackManagerService(
        preferences,
        rootDirectory: root,
      );
      final fallbackGrammar = GrammarHubService(
        factory: databaseFactoryFfi,
        path: p.join(root.path, 'fallback_grammar_only.db'),
      );

      final runtime = await ActivePackRuntimeProvider(
        packManager: manager,
        languagePack: const GermanLanguagePack(),
        embeddedGrammar: fallbackGrammar,
        databaseFactory: databaseFactoryFfi,
        databaseKeyStore: const _TestPackDatabaseKeyStore(),
      ).resolve();

      expect(runtime.state.origin, RuntimeContentOrigin.activePack);
      expect(runtime.hasIndexedCorpus, isTrue);
      expect(
        runtime.corpusRepository!.verification.hasExpectedCardinality,
        isTrue,
      );

      final topics =
          await runtime.grammarHubService.getTopicsByLevel('A1');
      expect(topics, isNotEmpty);
      expect(topics.first.id, 'a1_nominativ');

      await runtime.closeCorpus();
      await runtime.grammarHubService.close();
      manager.dispose();
      await root.delete(recursive: true);
    },
  );

  test(
    'legacy plaintext registered pack fails closed after Phase 7',
    () async {
      final root =
          await Directory.systemTemp.createTemp('plaintext_pack_');
      final sqlitePath = _sqlitePath(root, 'de-core');
      await _createCanonicalPackDatabase(
        sqlitePath,
        includeGrammar: true,
      );
      SharedPreferences.setMockInitialValues(
        _installedPreferences(
          'de-core',
          databaseEncrypted: false,
        ),
      );
      final preferences = await PreferencesService.instance();
      final manager = PackManagerService(
        preferences,
        rootDirectory: root,
      );
      final fallbackGrammar = GrammarHubService(
        factory: databaseFactoryFfi,
        path: p.join(root.path, 'fallback_plaintext.db'),
      );

      final runtime = await ActivePackRuntimeProvider(
        packManager: manager,
        languagePack: const GermanLanguagePack(),
        embeddedGrammar: fallbackGrammar,
        databaseFactory: databaseFactoryFfi,
        databaseKeyStore: const _TestPackDatabaseKeyStore(),
      ).resolve();

      expect(runtime.state.origin, RuntimeContentOrigin.embeddedFallback);
      expect(
        runtime.state.fallbackReason,
        'pack_database_unencrypted',
      );
      expect(runtime.corpusRepository, isNull);

      await runtime.closeCorpus();
      await runtime.grammarHubService.close();
      manager.dispose();
      await root.delete(recursive: true);
    },
  );
}

Map<String, Object> _installedPreferences(
  String packId, {
  bool databaseEncrypted = true,
}) =>
    <String, Object>{
      PackManagerService.activePackKey: packId,
      PackManagerService.installedRegistryKey: <String>[
        jsonEncode(<String, Object>{
          'id': packId,
          'languageCode': 'de',
          'displayName': 'Deutsch Core',
          'version': '1.0.0',
          'contractVersion': '1.0.0',
          'sha256': List<String>.filled(64, 'a').join(),
          'contentSha256': List<String>.filled(64, 'b').join(),
          'storageBytes': 4096,
          'manifestRevision': 7,
          'manifestKeyId': 'test-key',
          'manifestSignature':
              base64Encode(List<int>.filled(64, 4)),
          'databaseEncrypted': databaseEncrypted,
          'installedAt': '2026-10-02T12:00:00.000Z',
        }),
      ],
    };

String _sqlitePath(Directory root, String packId) =>
    p.join(root.path, 'packs', packId, 'content', 'content.sqlite');

Future<void> _createCanonicalPackDatabase(
  String path, {
  required bool includeGrammar,
  int contentRows = _fixtureContentRows,
  int verbRows = _fixtureVerbRows,
  int? declaredContentRows,
  int? declaredVerbRows,
}) async {
  await Directory(p.dirname(path)).create(recursive: true);
  final db = await databaseFactoryFfi.openDatabase(path);

  await db.execute(
    'CREATE TABLE metadata ('
    'key TEXT PRIMARY KEY, value TEXT NOT NULL)',
  );
  await db.execute(
    'CREATE TABLE lexicon ('
    'id TEXT PRIMARY KEY, surface TEXT NOT NULL, '
    'part_of_speech TEXT NOT NULL, direction TEXT NOT NULL, '
    'fields_json TEXT NOT NULL)',
  );

  for (final entry in <String, String>{
    'schemaVersion': '1',
    'contentRows': (declaredContentRows ?? contentRows).toString(),
    'verbRows': (declaredVerbRows ?? verbRows).toString(),
    'packId': 'de-core',
    'languageCode': 'de',
    'version': '1.0.0',
    'contractVersion': '1.0.0',
    'textDirection': 'ltr',
  }.entries) {
    await db.insert(
      'metadata',
      <String, Object>{
        'key': entry.key,
        'value': entry.value,
      },
    );
  }

  final verbItems = verbRows ~/ 6;
  expect(
    verbItems * 6,
    verbRows,
    reason: 'Fixture verb rows must be divisible into six-person sets.',
  );
  expect(
    verbItems,
    lessThanOrEqualTo(contentRows),
    reason: 'Each six-row verb set requires one lexicon item.',
  );

  const batchSize = 256;
  for (var start = 0; start < contentRows; start += batchSize) {
    final end = (start + batchSize).clamp(0, contentRows).toInt();
    final batch = db.batch();

    for (var index = start; index < end; index += 1) {
      final isVerb = index < verbItems;
      final isLernen = index == 0;
      final generatedIndex = index.toString().padLeft(5, '0');
      final infinitive =
          isLernen ? 'lernen' : 'verb_$generatedIndex';
      final id = isVerb
          ? isLernen
              ? 'verb.lernen'
              : 'verb.generated.$generatedIndex'
          : 'word.generated.$generatedIndex';
      final surface =
          isVerb ? infinitive : 'wort_$generatedIndex';
      final arabic =
          isLernen ? 'تعلم' : 'عنصر $generatedIndex';

      batch.insert(
        'lexicon',
        <String, Object>{
          'id': id,
          'surface': surface,
          'part_of_speech': isVerb ? 'verb' : 'noun',
          'direction': 'ltr',
          'fields_json': jsonEncode(<String, Object>{
            'translation': arabic,
            'example': isLernen
                ? 'Ich lerne Deutsch.'
                : 'Beispiel $generatedIndex.',
            'exampleTranslation': isLernen
                ? 'أنا أتعلم الألمانية.'
                : 'مثال $generatedIndex.',
            'topic': isVerb ? 'study' : 'vocabulary',
            'skill': 'recall',
            'accepted': <String>[surface],
            if (isVerb)
              'verbRows': _sixVerbRows(
                infinitive: infinitive,
                arabic: arabic,
                canonicalLernen: isLernen,
              ),
          }),
        },
      );
    }

    await batch.commit(noResult: true);
  }

  if (includeGrammar) {
    await db.execute(
      'CREATE TABLE grammar_topics ('
      'id TEXT PRIMARY KEY, level TEXT NOT NULL, '
      'title_de TEXT NOT NULL, title_ar TEXT NOT NULL, '
      'explanation_markdown TEXT NOT NULL, '
      'formula_pattern TEXT, order_index INTEGER NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE grammar_quizzes ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'topic_id TEXT NOT NULL, question TEXT NOT NULL, '
      'options_json TEXT NOT NULL, correct_index INTEGER NOT NULL, '
      'explanation TEXT NOT NULL)',
    );
    await db.insert(
      'grammar_topics',
      <String, Object>{
        'id': 'pack_a1',
        'level': 'A1',
        'title_de': 'Pack Grammatik',
        'title_ar': 'قواعد الحزمة',
        'explanation_markdown': 'Aus dem aktiven Paket.',
        'formula_pattern': 'A + B',
        'order_index': 1,
      },
    );
    await db.insert(
      'grammar_quizzes',
      <String, Object>{
        'topic_id': 'pack_a1',
        'question': 'Pack question?',
        'options_json': jsonEncode(<String>['A', 'B']),
        'correct_index': 0,
        'explanation': 'Pack explanation.',
      },
    );
  }

  final countRows = await db.rawQuery(
    'SELECT COUNT(*) AS count FROM lexicon',
  );
  expect(countRows.single['count'], contentRows);

  await db.close();
}

List<Map<String, Object>> _sixVerbRows({
  required String infinitive,
  required String arabic,
  required bool canonicalLernen,
}) {
  const persons = <String>[
    'ich',
    'du',
    'er/sie/es',
    'wir',
    'ihr',
    'sie/Sie',
  ];
  const personsAr = <String>[
    'أنا',
    'أنت',
    'هو/هي',
    'نحن',
    'أنتم',
    'هم/حضرتكم',
  ];

  return List<Map<String, Object>>.generate(
    persons.length,
    (index) {
      final form = canonicalLernen && index == 0
          ? 'lerne'
          : '${infinitive}_${index + 1}';
      return <String, Object>{
        'infinitive': infinitive,
        'arabic': arabic,
        'group': 'regular',
        'person': persons[index],
        'personAr': personsAr[index],
        'form': form,
        'past': 'habe gelernt',
        'pastArabic': 'تعلم',
        'example': '$form Deutsch.',
        'exampleAr': 'مثال',
        'pastExample': 'Ich habe Deutsch gelernt.',
        'pastExampleAr': 'لقد تعلمت الألمانية.',
      };
    },
    growable: false,
  );
}
