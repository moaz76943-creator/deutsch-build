import 'dart:convert';
import 'dart:io';

import 'package:deutsch_bilarabi/language/german/german_language_pack.dart';
import 'package:deutsch_bilarabi/services/active_pack_runtime_provider.dart';
import 'package:deutsch_bilarabi/services/grammar_hub_service.dart';
import 'package:deutsch_bilarabi/services/pack_database_key_store.dart';
import 'package:deutsch_bilarabi/services/pack_manager_service.dart';
import 'package:deutsch_bilarabi/services/preferences_service.dart';
import 'package:deutsch_bilarabi/services/search_index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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

  test('active SQLite pack becomes corpus, search, verb and grammar runtime source', () async {
    final root = await Directory.systemTemp.createTemp('active_pack_');
    final sqlitePath = _sqlitePath(root, 'de-core');
    await _createCompatiblePackDatabase(sqlitePath, includeGrammar: true);
    SharedPreferences.setMockInitialValues(_installedPreferences('de-core'));
    final preferences = await PreferencesService.instance();
    final manager = PackManagerService(preferences, rootDirectory: root);
    final fallbackGrammar = GrammarHubService(
      factory: databaseFactoryFfi,
      path: p.join(root.path, 'fallback_grammar.db'),
    );

    final runtime = await ActivePackRuntimeProvider(
      packManager: manager,
      languagePack: const GermanLanguagePack(),
      embeddedGrammar: fallbackGrammar,
      databaseFactory: databaseFactoryFfi,
    ).resolve();

    final languagePack = runtime.languagePack;
    final contentPack = languagePack.contentPack;
    final corpus = contentPack.items;
    final verbIndex = contentPack.verbIndex;
    final searchIndex = SearchIndex(
      corpus,
      verbIndex,
      languagePack.textNormalizer,
    );

    expect(runtime.state.origin, RuntimeContentOrigin.activePack);
    expect(runtime.state.activePackId, 'de-core');
    expect(corpus, hasLength(1));
    expect(corpus.single.sourceText, 'lernen');
    expect(searchIndex.search('تعلم').single.id, 'verb.lernen');
    expect(verbIndex.containsForm('lerne'), isTrue);
    expect(verbIndex.rowsFor('lernen').single.form, 'lerne');

    final topics = await runtime.grammarHubService.getTopicsByLevel('A1');
    expect(topics.single.id, 'pack_a1');
    expect(topics.single.titleDe, 'Pack Grammatik');

    await runtime.grammarHubService.saveTopicMastery('pack_a1', true);
    final mastered = await runtime.grammarHubService.getTopicDetail('pack_a1');
    expect(mastered?.isMastered, isTrue);

    await runtime.grammarHubService.close();
    manager.dispose();
    await root.delete(recursive: true);
  });

  test(
    'corrupt active SQLite fails closed to embedded last-known-good runtime',
    () async {
      final root = await Directory.systemTemp.createTemp('corrupt_pack_');
      final sqlite = File(_sqlitePath(root, 'de-core'));
      await sqlite.parent.create(recursive: true);
      await sqlite.writeAsBytes(<int>[1, 2, 3, 4], flush: true);
      SharedPreferences.setMockInitialValues(_installedPreferences('de-core'));
      final preferences = await PreferencesService.instance();
      final manager = PackManagerService(preferences, rootDirectory: root);
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
      expect(runtime.state.fallbackReason, 'active_pack_runtime_invalid');
      expect(runtime.languagePack.contentPack.items, isNotEmpty);

      await runtime.grammarHubService.close();
      manager.dispose();
      await root.delete(recursive: true);
    },
  );

  test(
    'admission or future signature rejection falls back before DB trust',
    () async {
      final root = await Directory.systemTemp.createTemp('rejected_pack_');
      final sqlite = File(_sqlitePath(root, 'de-core'));
      await sqlite.parent.create(recursive: true);
      await sqlite.writeAsBytes(<int>[0], flush: true);
      SharedPreferences.setMockInitialValues(_installedPreferences('de-core'));
      final preferences = await PreferencesService.instance();
      final manager = PackManagerService(preferences, rootDirectory: root);
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
        admissionGate: const _RejectingAdmissionGate('signature_failed'),
      ).resolve();

      expect(runtime.state.origin, RuntimeContentOrigin.embeddedFallback);
      expect(runtime.state.fallbackReason, 'signature_failed');
      expect(runtime.languagePack.contentPack.items, isNotEmpty);

      await runtime.grammarHubService.close();
      manager.dispose();
      await root.delete(recursive: true);
    },
  );

  test(
    'pack without Phase-1 grammar compatibility routes grammar to fallback',
    () async {
      final root = await Directory.systemTemp.createTemp('grammar_fallback_');
      final sqlitePath = _sqlitePath(root, 'de-core');
      await _createCompatiblePackDatabase(sqlitePath, includeGrammar: false);
      SharedPreferences.setMockInitialValues(_installedPreferences('de-core'));
      final preferences = await PreferencesService.instance();
      final manager = PackManagerService(preferences, rootDirectory: root);
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
      final topics = await runtime.grammarHubService.getTopicsByLevel('A1');
      expect(topics, isNotEmpty);
      expect(topics.first.id, 'a1_nominativ');

      await runtime.grammarHubService.close();
      manager.dispose();
      await root.delete(recursive: true);
    },
  );

  test(
    'legacy plaintext registered pack fails closed after Phase 7',
    () async {
      final root = await Directory.systemTemp.createTemp('plaintext_pack_');
      final sqlitePath = _sqlitePath(root, 'de-core');
      await _createCompatiblePackDatabase(sqlitePath, includeGrammar: true);
      SharedPreferences.setMockInitialValues(
        _installedPreferences('de-core', databaseEncrypted: false),
      );
      final preferences = await PreferencesService.instance();
      final manager = PackManagerService(preferences, rootDirectory: root);
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
      expect(runtime.state.fallbackReason, 'pack_database_unencrypted');

      await runtime.grammarHubService.close();
      manager.dispose();
      await root.delete(recursive: true);
    },
  );
}

Map<String, Object> _installedPreferences(
  String packId, {
  bool databaseEncrypted = true,
}) => <String, Object>{
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
      'manifestSignature': base64Encode(List<int>.filled(64, 4)),
      'databaseEncrypted': databaseEncrypted,
      'installedAt': '2026-10-02T12:00:00.000Z',
    }),
  ],
};

String _sqlitePath(Directory root, String packId) =>
    p.join(root.path, 'packs', packId, 'content', 'content.sqlite');

Future<void> _createCompatiblePackDatabase(
  String path, {
  required bool includeGrammar,
}) async {
  await Directory(p.dirname(path)).create(recursive: true);
  final db = await databaseFactoryFfi.openDatabase(path);
  await db.execute(
    'CREATE TABLE metadata (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
  );
  await db.execute(
    'CREATE TABLE lexicon ('
    'id TEXT PRIMARY KEY, surface TEXT NOT NULL, '
    'part_of_speech TEXT NOT NULL, direction TEXT NOT NULL, '
    'fields_json TEXT NOT NULL)',
  );
  for (final entry in <String, String>{
    'schemaVersion': '1',
    'packId': 'de-core',
    'languageCode': 'de',
    'version': '1.0.0',
    'contractVersion': '1.0.0',
    'textDirection': 'ltr',
  }.entries) {
    await db.insert('metadata', <String, Object>{
      'key': entry.key,
      'value': entry.value,
    });
  }
  await db.insert('lexicon', <String, Object>{
    'id': 'verb.lernen',
    'surface': 'lernen',
    'part_of_speech': 'verb',
    'direction': 'ltr',
    'fields_json': jsonEncode(<String, Object>{
      'translation': 'تعلم',
      'example': 'Ich lerne Deutsch.',
      'exampleTranslation': 'أنا أتعلم الألمانية.',
      'topic': 'study',
      'skill': 'recall',
      'accepted': <String>['lernen'],
      'verbRows': <Object>[
        <String, Object>{
          'infinitive': 'lernen',
          'arabic': 'تعلم',
          'group': 'regular',
          'person': 'ich',
          'personAr': 'أنا',
          'form': 'lerne',
          'past': 'habe gelernt',
          'pastArabic': 'تعلمت',
          'example': 'Ich lerne Deutsch.',
          'exampleAr': 'أنا أتعلم الألمانية.',
          'pastExample': 'Ich habe Deutsch gelernt.',
          'pastExampleAr': 'لقد تعلمت الألمانية.',
        },
      ],
    }),
  });

  if (includeGrammar) {
    await db.execute(
      'CREATE TABLE grammar_topics ('
      'id TEXT PRIMARY KEY, level TEXT NOT NULL, title_de TEXT NOT NULL, '
      'title_ar TEXT NOT NULL, explanation_markdown TEXT NOT NULL, '
      'formula_pattern TEXT, order_index INTEGER NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE grammar_quizzes ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, topic_id TEXT NOT NULL, '
      'question TEXT NOT NULL, options_json TEXT NOT NULL, '
      'correct_index INTEGER NOT NULL, explanation TEXT NOT NULL)',
    );
    await db.insert('grammar_topics', <String, Object>{
      'id': 'pack_a1',
      'level': 'A1',
      'title_de': 'Pack Grammatik',
      'title_ar': 'قواعد الحزمة',
      'explanation_markdown': 'Aus dem aktiven Paket.',
      'formula_pattern': 'A + B',
      'order_index': 1,
    });
    await db.insert('grammar_quizzes', <String, Object>{
      'topic_id': 'pack_a1',
      'question': 'Pack question?',
      'options_json': jsonEncode(<String>['A', 'B']),
      'correct_index': 0,
      'explanation': 'Pack explanation.',
    });
  }

  await db.close();
}
