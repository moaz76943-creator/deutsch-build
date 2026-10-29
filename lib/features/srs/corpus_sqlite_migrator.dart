import 'dart:convert';

import 'package:sqflite_common/sqlite_api.dart';

import 'corpus_sqlite_contract.dart';
import 'corpus_sqlite_repository.dart';

final class SrsCorpusMigrationReport {
  const SrsCorpusMigrationReport({
    required this.contentRows,
    required this.verbRows,
    required this.acceptedRows,
  });

  final int contentRows;
  final int verbRows;
  final int acceptedRows;

  bool matches(SrsCorpusCardinality expected) =>
      contentRows == expected.contentRows &&
      verbRows == expected.verbRows;
}

/// Deterministically migrates the admitted legacy SQLite lexicon table into
/// normalized, indexed SRS tables. The target is marked ready only after
/// exact cardinality and index verification succeeds.
final class SrsCorpusSqliteMigrator {
  const SrsCorpusSqliteMigrator({
    this.pageSize = 256,
  }) : assert(pageSize > 0 && pageSize <= 1024);

  final int pageSize;

  Future<SrsCorpusMigrationReport> migrate({
    required Database source,
    required Database target,
    required SrsCorpusCardinality expectedCardinality,
    required String sourceContentSha256,
  }) async {
    final normalizedSourceContentSha256 = _requireSha256(
      sourceContentSha256,
    );
    await _requireLegacySource(
      source,
      expectedCardinality: expectedCardinality,
    );
    await _requireEmptyTarget(target);

    await target.execute('PRAGMA foreign_keys=ON');
    for (final statement in SrsCorpusContract.createSchemaStatements) {
      await target.execute(statement);
    }

    final metadata = <String, String>{
      SrsCorpusContract.metadataSchemaVersionKey:
          SrsCorpusContract.schemaVersion.toString(),
      SrsCorpusContract.metadataStateKey: 'building',
      SrsCorpusContract.metadataContentRowsKey:
          expectedCardinality.contentRows.toString(),
      SrsCorpusContract.metadataVerbRowsKey:
          expectedCardinality.verbRows.toString(),
      SrsCorpusContract.metadataSourceContentSha256Key:
          normalizedSourceContentSha256,
    };
    for (final entry in metadata.entries) {
      await target.insert(
        SrsCorpusContract.metadataTable,
        <String, Object?>{
          'key': entry.key,
          'value': entry.value,
        },
      );
    }

    var contentRows = 0;
    var verbRows = 0;
    var acceptedRows = 0;
    String? afterId;

    while (true) {
      final rows = await source.query(
        'lexicon',
        columns: const <String>['id', 'surface', 'fields_json'],
        where: afterId == null ? null : 'id > ?',
        whereArgs: afterId == null ? null : <Object?>[afterId],
        orderBy: 'id ASC',
        limit: pageSize,
      );
      if (rows.isEmpty) break;

      final batch = target.batch();
      for (final row in rows) {
        final id = _requiredString(row['id'], 'id', maxLength: 160);
        final german = _requiredString(
          row['surface'],
          'surface',
          maxLength: 4000,
        );
        final fields = _decodeFields(row['fields_json']);
        final arabic = _firstString(
          fields,
          const <String>['translation', 'translationText', 'arabic'],
          required: true,
        );

        batch.insert(
          SrsCorpusContract.contentTable,
          <String, Object?>{
            'id': id,
            'german': german,
            'arabic': arabic,
            'sentence': _firstString(
              fields,
              const <String>['example', 'sentence'],
            ),
            'sentence_ar': _firstString(
              fields,
              const <String>['exampleTranslation', 'sentenceAr'],
            ),
            'topic': _firstString(
              fields,
              const <String>['topic'],
              fallback: 'pack',
            ),
            'skill': _firstString(
              fields,
              const <String>['skill'],
              fallback: 'recall',
            ),
            'article': _firstString(
              fields,
              const <String>['article', 'grammaticalMarker'],
            ),
            'plural': _firstString(
              fields,
              const <String>['plural'],
            ),
          },
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
        contentRows += 1;

        final accepted = _boundedStringList(
          fields['accepted'],
          maxEntries: 32,
          maxLength: 200,
        );
        for (var index = 0; index < accepted.length; index += 1) {
          batch.insert(
            SrsCorpusContract.acceptedTable,
            <String, Object?>{
              'content_id': id,
              'ordinal': index,
              'form': accepted[index],
            },
            conflictAlgorithm: ConflictAlgorithm.abort,
          );
          acceptedRows += 1;
        }

        final rawVerbRows = fields['verbRows'];
        if (rawVerbRows != null && rawVerbRows is! List) {
          throw StateError('srs_corpus_verb_rows_invalid:$id');
        }
        final nestedVerbRows =
            rawVerbRows is List ? rawVerbRows : const <Object?>[];
        if (nestedVerbRows.length > 128) {
          throw StateError('srs_corpus_verb_rows_excessive:$id');
        }

        for (var index = 0; index < nestedVerbRows.length; index += 1) {
          final raw = nestedVerbRows[index];
          if (raw is! Map) {
            throw StateError('srs_corpus_verb_row_invalid:$id');
          }
          final verb = Map<String, dynamic>.from(raw);
          batch.insert(
            SrsCorpusContract.verbTable,
            <String, Object?>{
              'content_id': id,
              'row_ordinal': index,
              'infinitive': _mapString(
                verb,
                'infinitive',
                fallback: german,
              ),
              'arabic': _mapString(
                verb,
                'arabic',
                fallback: arabic,
              ),
              'group_name': _mapString(
                verb,
                'group',
                fallback: 'pack',
              ),
              'person': _mapString(
                verb,
                'person',
                required: true,
              ),
              'person_ar': _mapString(verb, 'personAr'),
              'form': _mapString(
                verb,
                'form',
                required: true,
              ),
              'past': _mapString(verb, 'past'),
              'past_arabic': _mapString(verb, 'pastArabic'),
              'example': _mapString(verb, 'example'),
              'example_ar': _mapString(verb, 'exampleAr'),
              'past_example': _mapString(verb, 'pastExample'),
              'past_example_ar': _mapString(verb, 'pastExampleAr'),
            },
            conflictAlgorithm: ConflictAlgorithm.abort,
          );
          verbRows += 1;
        }

        afterId = id;
      }

      await batch.commit(noResult: true);
      if (rows.length < pageSize) break;
    }

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

    for (final statement in SrsCorpusContract.createIndexStatements) {
      await target.execute(statement);
    }
    await target.execute(
      'PRAGMA user_version=${SrsCorpusContract.schemaVersion}',
    );
    await target.update(
      SrsCorpusContract.metadataTable,
      const <String, Object?>{'value': 'ready'},
      where: 'key = ?',
      whereArgs: const <Object?>[SrsCorpusContract.metadataStateKey],
    );

    final verification = await IndexedSrsCorpusRepository.verifyDatabase(
      target,
      expectedCardinality: expectedCardinality,
      sourceContentSha256: normalizedSourceContentSha256,
    );
    if (!verification.hasExpectedCardinality) {
      throw StateError('srs_corpus_verification_failed');
    }

    return SrsCorpusMigrationReport(
      contentRows: contentRows,
      verbRows: verbRows,
      acceptedRows: acceptedRows,
    );
  }

  Future<void> _requireLegacySource(
    Database source, {
    required SrsCorpusCardinality expectedCardinality,
  }) async {
    final rows = await source.rawQuery(
      "SELECT name FROM sqlite_master "
      "WHERE type = 'table' AND name = 'lexicon'",
    );
    if (rows.length != 1) {
      throw StateError('srs_corpus_legacy_lexicon_missing');
    }
    final countRows = await source.rawQuery(
      'SELECT COUNT(*) AS count FROM lexicon',
    );
    final raw = countRows.length == 1 ? countRows.single['count'] : null;
    final actual = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
    if (actual != expectedCardinality.contentRows) {
      throw StateError(
        'srs_corpus_source_content_cardinality_mismatch:'
        '$actual/${expectedCardinality.contentRows}',
      );
    }
  }

  Future<void> _requireEmptyTarget(Database target) async {
    final rows = await target.rawQuery(
      "SELECT name FROM sqlite_master "
      "WHERE type = 'table' AND name LIKE 'srs_corpus_%'",
    );
    if (rows.isNotEmpty) {
      throw StateError('srs_corpus_target_not_empty');
    }
  }

  String _requireSha256(String raw) {
    final normalized = raw.trim().toLowerCase();
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(normalized)) {
      throw StateError('srs_corpus_source_sha256_invalid');
    }
    return normalized;
  }

  Map<String, dynamic> _decodeFields(Object? raw) {
    if (raw is! String || raw.length > 512 * 1024) {
      throw const FormatException('srs_corpus_fields_invalid');
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('srs_corpus_fields_not_object');
    }
    return Map<String, dynamic>.from(decoded);
  }

  String _requiredString(
    Object? raw,
    String field, {
    required int maxLength,
  }) {
    if (raw is! String) {
      throw StateError('srs_corpus_${field}_invalid');
    }
    final value = raw.trim();
    if (value.isEmpty || value.length > maxLength) {
      throw StateError('srs_corpus_${field}_invalid');
    }
    return value;
  }

  String _firstString(
    Map<String, dynamic> fields,
    List<String> keys, {
    bool required = false,
    String fallback = '',
  }) {
    for (final key in keys) {
      final raw = fields[key];
      if (raw is String) {
        final value = raw.trim();
        if (value.isNotEmpty && value.length <= 4000) {
          return value;
        }
      }
    }
    if (required) {
      throw StateError('srs_corpus_required_text_missing');
    }
    return fallback;
  }

  String _mapString(
    Map<String, dynamic> row,
    String key, {
    bool required = false,
    String fallback = '',
  }) {
    final raw = row[key];
    if (raw is String) {
      final value = raw.trim();
      if (value.isNotEmpty && value.length <= 4000) {
        return value;
      }
    }
    if (required) {
      throw StateError('srs_corpus_verb_required_text_missing:$key');
    }
    return fallback;
  }

  List<String> _boundedStringList(
    Object? raw, {
    required int maxEntries,
    required int maxLength,
  }) {
    if (raw is! List) return const <String>[];
    if (raw.length > maxEntries) {
      throw StateError('srs_corpus_string_list_excessive');
    }
    return raw
        .whereType<String>()
        .map((value) => value.trim())
        .where(
          (value) => value.isNotEmpty && value.length <= maxLength,
        )
        .toList(growable: false);
  }
}
