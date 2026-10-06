import 'package:sqflite_common/sqlite_api.dart';

import 'corpus_sqlite_contract.dart';

final class SrsCorpusItem {
  SrsCorpusItem({
    required this.id,
    required this.german,
    required this.arabic,
    required this.sentence,
    required this.sentenceAr,
    required this.topic,
    required this.skill,
    required this.cefr,
    required this.article,
    required this.plural,
    required this.accepted,
  });

  final String id;
  final String german;
  final String arabic;
  final String sentence;
  final String sentenceAr;
  final String topic;
  final String skill;
  final String cefr;
  final String article;
  final String plural;
  final List<String> accepted;
}

final class SrsVerbRow {
  SrsVerbRow({
    required this.contentId,
    required this.infinitive,
    required this.arabic,
    required this.group,
    required this.person,
    required this.personAr,
    required this.form,
    required this.past,
    required this.pastArabic,
    required this.example,
    required this.exampleAr,
    required this.pastExample,
    required this.pastExampleAr,
  });

  final String contentId;
  final String infinitive;
  final String arabic;
  final String group;
  final String person;
  final String personAr;
  final String form;
  final String past;
  final String pastArabic;
  final String example;
  final String exampleAr;
  final String pastExample;
  final String pastExampleAr;
}

final class IndexedSrsCorpusRepository {
  IndexedSrsCorpusRepository._(this._database, this.verification);

  final Database _database;
  final SrsCorpusVerification verification;

  static Future<IndexedSrsCorpusRepository> open(
    Database database, {
    required SrsCorpusCardinality expectedCardinality,
    required String sourceContentSha256,
  }) async {
    final verification = await verifyDatabase(
      database,
      expectedCardinality: expectedCardinality,
      sourceContentSha256: sourceContentSha256,
    );
    return IndexedSrsCorpusRepository._(database, verification);
  }

  static Future<SrsCorpusVerification> verifyDatabase(
    Database database, {
    required SrsCorpusCardinality expectedCardinality,
    required String sourceContentSha256,
  }) async {
    final metadata = await _metadata(database);
    if (metadata['state'] != 'ready') {
      throw StateError('srs_corpus_not_ready');
    }
    final schemaVersion = int.tryParse(
      metadata[SrsCorpusContract.metadataSchemaVersionKey] ?? '',
    );
    if (schemaVersion != SrsCorpusContract.schemaVersion) {
      throw StateError('srs_corpus_schema_mismatch');
    }

    final declaredContentRows = _requiredMetadataInt(
      metadata,
      SrsCorpusContract.metadataContentRowsKey,
      allowZero: false,
    );
    final declaredVerbRows = _requiredMetadataInt(
      metadata,
      SrsCorpusContract.metadataVerbRowsKey,
      allowZero: true,
    );
    if (declaredContentRows != expectedCardinality.contentRows ||
        declaredVerbRows != expectedCardinality.verbRows) {
      throw StateError('srs_corpus_declared_cardinality_mismatch');
    }

    final expectedSha256 = sourceContentSha256.trim().toLowerCase();
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(expectedSha256)) {
      throw StateError('srs_corpus_source_sha256_invalid');
    }
    final declaredSha256 =
        metadata[SrsCorpusContract.metadataSourceContentSha256Key]
            ?.trim()
            .toLowerCase();
    if (declaredSha256 != expectedSha256) {
      throw StateError('srs_corpus_source_sha256_mismatch');
    }

    final contentRows = await _count(
      database,
      SrsCorpusContract.contentTable,
    );
    final verbRows = await _count(
      database,
      SrsCorpusContract.verbTable,
    );

    if (contentRows != expectedCardinality.contentRows) {
      throw StateError(
        'srs_corpus_content_cardinality_mismatch:'
        '$contentRows/${expectedCardinality.contentRows}',
      );
    }
    if (verbRows != expectedCardinality.verbRows) {
      throw StateError(
        'srs_corpus_verb_cardinality_mismatch:'
        '$verbRows/${expectedCardinality.verbRows}',
      );
    }

    final indexRows = await database.rawQuery(
      "SELECT name FROM sqlite_master "
      "WHERE type = 'index' AND name LIKE 'idx_srs_%'",
    );
    final indexes = indexRows
        .map((row) => row['name']?.toString())
        .whereType<String>()
        .toSet();
    if (!indexes.containsAll(SrsCorpusContract.requiredIndexes)) {
      throw StateError('srs_corpus_required_index_missing');
    }

    await _verifySqliteIntegrity(database);

    return SrsCorpusVerification(
      schemaVersion: schemaVersion!,
      contentRows: contentRows,
      verbRows: verbRows,
      expectedContentRows: expectedCardinality.contentRows,
      expectedVerbRows: expectedCardinality.verbRows,
      sourceContentSha256: expectedSha256,
      indexes: Set<String>.unmodifiable(indexes),
    );
  }

  Future<List<SrsCorpusItem>> fetchPage({
    String? afterId,
    String? topic,
    String? skill,
    int limit = 32,
  }) async {
    final safeLimit = limit.clamp(1, 128).toInt();
    final clauses = <String>[];
    final args = <Object?>[];

    final cleanAfter = afterId?.trim();
    if (cleanAfter != null && cleanAfter.isNotEmpty) {
      clauses.add('id > ?');
      args.add(cleanAfter);
    }
    final cleanTopic = topic?.trim();
    if (cleanTopic != null && cleanTopic.isNotEmpty) {
      clauses.add('topic = ?');
      args.add(cleanTopic);
    }
    final cleanSkill = skill?.trim();
    if (cleanSkill != null && cleanSkill.isNotEmpty) {
      clauses.add('skill = ?');
      args.add(cleanSkill);
    }

    final rows = await _database.query(
      SrsCorpusContract.contentTable,
      columns: const <String>[
        'id',
        'german',
        'arabic',
        'sentence',
        'sentence_ar',
        'topic',
        'skill',
        'cefr',
        'article',
        'plural',
      ],
      where: clauses.isEmpty ? null : clauses.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'id ASC',
      limit: safeLimit,
    );
    return _hydrate(rows);
  }

  Future<List<SrsCorpusItem>> fetchByIds(Iterable<String> ids) async {
    final normalized = ids
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (normalized.isEmpty) return const <SrsCorpusItem>[];
    if (normalized.length > 128) {
      throw ArgumentError.value(
        normalized.length,
        'ids',
        'SRS corpus slices are bounded to 128 IDs',
      );
    }

    final placeholders =
        List<String>.filled(normalized.length, '?').join(',');
    final rows = await _database.rawQuery(
      '''
SELECT id, german, arabic, sentence, sentence_ar, topic, skill, cefr, article, plural
FROM ${SrsCorpusContract.contentTable}
WHERE id IN ($placeholders)
''',
      normalized,
    );

    final hydrated = await _hydrate(rows);
    final byId = <String, SrsCorpusItem>{
      for (final item in hydrated) item.id: item,
    };
    return normalized
        .map((id) => byId[id])
        .whereType<SrsCorpusItem>()
        .toList(growable: false);
  }

  Future<List<SrsCorpusItem>> searchContent({
    Iterable<String> terms = const <String>[],
    Set<String> cefrLevels = const <String>{},
    Set<String> articles = const <String>{},
    int limit = 80,
  }) async {
    final safeLimit = limit.clamp(1, 200).toInt();
    final normalizedTerms = terms
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty && value.length <= 200)
        .toSet()
        .take(6)
        .toList(growable: false);
    final normalizedLevels = cefrLevels
        .map((value) => value.trim().toUpperCase())
        .where(
          (value) => const <String>{'A1', 'A2', 'B1', 'B2'}.contains(value),
        )
        .toSet()
        .toList(growable: false);
    final normalizedArticles = articles
        .map((value) => value.trim().toLowerCase())
        .where((value) => const <String>{'der', 'die', 'das'}.contains(value))
        .toSet()
        .toList(growable: false);

    final clauses = <String>[];
    final args = <Object?>[];

    if (normalizedTerms.isNotEmpty) {
      final textClauses = <String>[];
      for (final term in normalizedTerms) {
        textClauses.add(
          '(german LIKE ? COLLATE NOCASE OR arabic LIKE ? '
          'OR EXISTS (SELECT 1 FROM ${SrsCorpusContract.acceptedTable} a '
          'WHERE a.content_id = ${SrsCorpusContract.contentTable}.id '
          'AND a.form LIKE ? COLLATE NOCASE))',
        );
        final pattern = '%$term%';
        args.addAll(<Object?>[pattern, pattern, pattern]);
      }
      clauses.add('(${textClauses.join(' OR ')})');
    }

    if (normalizedLevels.isNotEmpty) {
      final placeholders =
          List<String>.filled(normalizedLevels.length, '?').join(',');
      clauses.add('cefr IN ($placeholders)');
      args.addAll(normalizedLevels);
    }

    if (normalizedArticles.isNotEmpty) {
      final placeholders =
          List<String>.filled(normalizedArticles.length, '?').join(',');
      clauses.add('article IN ($placeholders)');
      args.addAll(normalizedArticles);
    }

    final where = clauses.isEmpty ? '' : 'WHERE ${clauses.join(' AND ')}';
    final rows = await _database.rawQuery(
      '''
SELECT id, german, arabic, sentence, sentence_ar, topic, skill, cefr, article, plural
FROM ${SrsCorpusContract.contentTable}
$where
ORDER BY german COLLATE NOCASE ASC, id ASC
LIMIT ?
''',
      <Object?>[...args, safeLimit],
    );
    return _hydrate(rows);
  }
  Future<List<SrsVerbRow>> fetchVerbRows({
    required String infinitive,
    int limit = 32,
  }) async {
    final clean = infinitive.trim();
    if (clean.isEmpty) return const <SrsVerbRow>[];

    final rows = await _database.query(
      SrsCorpusContract.verbTable,
      where: 'infinitive = ?',
      whereArgs: <Object?>[clean],
      orderBy: 'content_id ASC, row_ordinal ASC',
      limit: limit.clamp(1, 128).toInt(),
    );
    return rows.map(_verbFromRow).toList(growable: false);
  }

  Future<List<SrsCorpusItem>> _hydrate(
    List<Map<String, Object?>> rows,
  ) async {
    if (rows.isEmpty) return const <SrsCorpusItem>[];

    final ids = rows.map((row) => row['id']!.toString()).toList();
    final placeholders = List<String>.filled(ids.length, '?').join(',');
    final acceptedRows = await _database.rawQuery(
      '''
SELECT content_id, ordinal, form
FROM ${SrsCorpusContract.acceptedTable}
WHERE content_id IN ($placeholders)
ORDER BY content_id ASC, ordinal ASC
''',
      ids,
    );

    final accepted = <String, List<String>>{};
    for (final row in acceptedRows) {
      final id = row['content_id']!.toString();
      accepted.putIfAbsent(id, () => <String>[]).add(
            row['form']!.toString(),
          );
    }

    return rows
        .map(
          (row) => SrsCorpusItem(
            id: row['id']!.toString(),
            german: row['german']!.toString(),
            arabic: row['arabic']!.toString(),
            sentence: row['sentence']!.toString(),
            sentenceAr: row['sentence_ar']!.toString(),
            topic: row['topic']!.toString(),
            skill: row['skill']!.toString(),
            cefr: row['cefr']!.toString(),
            article: row['article']!.toString(),
            plural: row['plural']!.toString(),
            accepted: List<String>.unmodifiable(
              accepted[row['id']!.toString()] ?? const <String>[],
            ),
          ),
        )
        .toList(growable: false);
  }

  static Future<Map<String, String>> _metadata(Database database) async {
    final rows = await database.query(
      SrsCorpusContract.metadataTable,
      limit: 32,
    );
    return <String, String>{
      for (final row in rows)
        if (row['key'] != null && row['value'] != null)
          row['key'].toString(): row['value'].toString(),
    };
  }

  static int _requiredMetadataInt(
    Map<String, String> metadata,
    String key, {
    required bool allowZero,
  }) {
    final value = int.tryParse(metadata[key] ?? '');
    final minimum = allowZero ? 0 : 1;
    if (value == null || value < minimum) {
      throw StateError('srs_corpus_metadata_invalid:$key');
    }
    return value;
  }

  static Future<void> _verifySqliteIntegrity(Database database) async {
    final integrityRows = await database.rawQuery('PRAGMA quick_check');
    final integrityOk = integrityRows.length == 1 &&
        integrityRows.single.values.any(
          (value) => value?.toString().toLowerCase() == 'ok',
        );
    if (!integrityOk) {
      throw StateError('srs_corpus_integrity_check_failed');
    }

    final foreignKeyRows = await database.rawQuery('PRAGMA foreign_key_check');
    if (foreignKeyRows.isNotEmpty) {
      throw StateError('srs_corpus_foreign_key_check_failed');
    }
  }

  static Future<int> _count(Database database, String table) async {
    final rows = await database.rawQuery(
      'SELECT COUNT(*) AS count FROM $table',
    );
    if (rows.length != 1) {
      throw StateError('srs_corpus_count_failed:$table');
    }
    final raw = rows.single['count'];
    if (raw is int) return raw;
    return int.parse(raw.toString());
  }

  static SrsVerbRow _verbFromRow(Map<String, Object?> row) => SrsVerbRow(
        contentId: row['content_id']!.toString(),
        infinitive: row['infinitive']!.toString(),
        arabic: row['arabic']!.toString(),
        group: row['group_name']!.toString(),
        person: row['person']!.toString(),
        personAr: row['person_ar']!.toString(),
        form: row['form']!.toString(),
        past: row['past']!.toString(),
        pastArabic: row['past_arabic']!.toString(),
        example: row['example']!.toString(),
        exampleAr: row['example_ar']!.toString(),
        pastExample: row['past_example']!.toString(),
        pastExampleAr: row['past_example_ar']!.toString(),
      );
}
