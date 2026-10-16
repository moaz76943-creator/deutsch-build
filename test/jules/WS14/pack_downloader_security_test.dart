import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:deutsch_bilarabi/services/pack_downloader_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

/// Synthetic local SQLite v2 fixtures: no downloaded learner or public data.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    ffi.sqfliteFfiInit();
    databaseFactory = ffi.databaseFactoryFfi;
  });

  late Directory temporary;
  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('ws14_verified_pack_');
  });
  tearDown(() async {
    if (await temporary.exists()) {
      await temporary.delete(recursive: true);
    }
  });

  Future<List<int>> sqliteFixture(
    String language, {
    bool withFts5 = true,
    bool withLexemes = true,
  }) async {
    final file = File(path.join(temporary.path, 'source.sqlite'));
    if (await file.exists()) await file.delete();
    final db = await openDatabase(file.path, singleInstance: false);
    try {
      await db.execute('PRAGMA user_version = 2');
      await db.execute('CREATE TABLE metadata (key TEXT PRIMARY KEY, value TEXT)');
      await db.execute('CREATE TABLE schema_migrations (version TEXT)');
      await db.execute('CREATE TABLE concepts (concept_id TEXT PRIMARY KEY)');
      await db.execute('''
        CREATE TABLE lexicon (
          id TEXT PRIMARY KEY, surface TEXT, sort_key TEXT,
          part_of_speech TEXT, language_code TEXT, cefr_level TEXT,
          fields_json TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE senses (
          sense_id TEXT, lexeme_id TEXT, concept_id TEXT, payload_json TEXT
        )
      ''');
      await db.execute('CREATE TABLE translations (translation_id TEXT)');
      await db.execute('''
        CREATE TABLE examples (
          example_id TEXT, lexeme_id TEXT, language_code TEXT, text TEXT
        )
      ''');
      await db.execute('CREATE TABLE lexical_relations (relation_id TEXT)');
      await db.execute('CREATE TABLE grammar (grammar_id TEXT)');
      if (withLexemes) {
        await db.execute('''
          CREATE VIEW lexemes AS
          SELECT id, surface, part_of_speech, fields_json FROM lexicon
        ''');
      }
      if (withFts5) {
        await db.execute('''
          CREATE VIRTUAL TABLE lexicon_fts
          USING fts5(surface, lemma, gloss, language_code UNINDEXED)
        ''');
      }
      for (final item in <String, String>{
        'mapping_version': '2.0.0',
        'contract_version': '1.0.0',
        'language_code': language,
      }.entries) {
        await db.insert('metadata', <String, Object>{
          'key': item.key, 'value': item.value,
        });
      }
      await db.insert('lexicon', <String, Object>{
        'id': 'lex.fixture.1',
        'surface': 'fixture',
        'sort_key': 'fixture',
        'part_of_speech': 'noun',
        'language_code': language,
        'cefr_level': 'A1',
        'fields_json': '{}',
      });
    } finally {
      await db.close();
    }
    return file.readAsBytes();
  }

  Map<String, dynamic> manifestFor(
    String language,
    List<int> archive,
    List<int> sqlite,
  ) => <String, dynamic>{
    'schemaVersion': '2.0.0',
    'packs': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': language,
        'languageCode': language,
        'version': '2.0.0',
        'contractVersion': '1.0.0',
        'bundleFormat': 'json-gzip-v1',
        'archiveUrl': 'https://cdn.jsdelivr.net/gh/'
            'moaz76943-creator/-offline-packs-store@main/packs/'
            'fixture-2.0.0.pack.gz',
        'sha256': sha256.convert(archive).toString(),
        'contentSha256': sha256.convert(sqlite).toString(),
        'archiveSizeBytes': archive.length,
        'production_ready': true,
        'pack_verified': true,
        'content_available': true,
      },
    ],
  };

  List<int> envelope(
    String language,
    List<int> sqlite, {
    bool omitMetadata = false,
    String? alternateLanguage,
    String version = '2.0.0',
  }) {
    final files = <Map<String, String>>[
      <String, String>{
        'path': 'content/content.json',
        'contentBase64': base64Encode(utf8.encode(jsonEncode(
          <String, Object>{'languageCode': alternateLanguage ?? language,
            'version': version},
        ))),
      },
      <String, String>{
        'path': 'content/content.sqlite',
        'contentBase64': base64Encode(sqlite),
      },
      if (!omitMetadata)
        <String, String>{
          'path': 'metadata/pack.json',
          'contentBase64': base64Encode(utf8.encode(jsonEncode(
            <String, Object>{
              'languageCode': alternateLanguage ?? language,
              'version': version,
              'contractVersion': '1.0.0',
            },
          ))),
        },
    ];
    return gzip.encode(utf8.encode(jsonEncode(<String, Object>{
      'packId': language,
      'languageCode': language,
      'version': version,
      'contractVersion': '1.0.0',
      'files': files,
    })));
  }

  Future<bool> install(
    String language,
    List<int> archive,
    Map<String, dynamic> manifest,
  ) async {
    final source = File(path.join(temporary.path, 'fixture.pack.gz'));
    await source.writeAsBytes(archive, flush: true);
    return PackDownloaderService.installArchiveFixtureForTesting(
      languageCode: language,
      manifest: manifest,
      archive: source,
      packsDirectory: temporary,
    );
  }

  test('live manifest has no implicit legacy or production pack fallback', () {
    expect(
      PackDownloaderService.hasPublishedPackForTesting(
        <String, dynamic>{'schemaVersion': '2.0.0', 'packs': [],
          'languages': [<String, dynamic>{'code': 'fr',
            'pack_url': 'https://cdn.jsdelivr.net/legacy.gz'}]},
        'fr',
      ),
      isFalse,
    );
  });

  test('approved HTTPS origins reject untrusted hosts and redirect targets', () {
    expect(PackDownloaderService.isApprovedPackUriForTesting(
      Uri.parse('https://cdn.jsdelivr.net/gh/'
          'moaz76943-creator/-offline-packs-store@main/packs/fr-v2.pack.gz')),
      isTrue);
    expect(PackDownloaderService.isApprovedPackUriForTesting(
      Uri.parse('https://evil.example/packs/fr-v2.pack.gz')), isFalse);
    expect(PackDownloaderService.isApprovedPackUriForTesting(
      Uri.parse('http://cdn.jsdelivr.net/gh/'
          'moaz76943-creator/-offline-packs-store@main/packs/fr-v2.pack.gz')),
      isFalse);
  });

  test('verified SQLite v2 fixture installs and has correct metadata', () async {
    final sqlite = await sqliteFixture('fr');
    final archive = envelope('fr', sqlite);
    expect(await install('fr', archive, manifestFor('fr', archive, sqlite)), isTrue);
    expect(await File(path.join(temporary.path, 'fr.sqlite')).readAsBytes(),
        orderedEquals(sqlite));
  });

  test('corrupt archive digest is rejected without overwriting prior pack', () async {
    final sqlite = await sqliteFixture('fr');
    final good = envelope('fr', sqlite);
    expect(await install('fr', good, manifestFor('fr', good, sqlite)), isTrue);
    final prior = await File(path.join(temporary.path, 'fr.sqlite')).readAsBytes();
    final modified = List<int>.from(good)..[5] = good[5] ^ 1;
    expect(await install('fr', modified, manifestFor('fr', good, sqlite)), isFalse);
    expect(await File(path.join(temporary.path, 'fr.sqlite')).readAsBytes(),
        orderedEquals(prior));
  });

  test('missing envelope file and cross-language metadata fail closed', () async {
    final sqlite = await sqliteFixture('es');
    final missing = envelope('es', sqlite, omitMetadata: true);
    expect(await install('es', missing, manifestFor('es', missing, sqlite)), isFalse);
    final wrong = envelope('es', sqlite, alternateLanguage: 'de');
    expect(await install('es', wrong, manifestFor('es', wrong, sqlite)), isFalse);
    expect(await File(path.join(temporary.path, 'es.sqlite')).exists(), isFalse);
  });

  test('rejects invalid SQLite v2 FTS5 schema without installation', () async {
    final sqlite = await sqliteFixture('ar', withFts5: false);
    final archive = envelope('ar', sqlite);
    expect(await install('ar', archive, manifestFor('ar', archive, sqlite)), isFalse);
    expect(await File(path.join(temporary.path, 'ar.sqlite')).exists(), isFalse);
  });

  test('gzip expansion limit rejects zip bombs', () async {
    await expectLater(
      PackDownloaderService.decodeGzipEnvelope(
        Stream<List<int>>.value(gzip.encode(List<int>.filled(4096, 65))),
        maxExpandedBytes: 128,
      ),
      throwsStateError,
    );
  });
}
