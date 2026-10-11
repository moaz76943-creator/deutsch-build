import 'package:sqflite/sqflite.dart';

import 'database_service.dart';

/// The choices exposed by the CEFR vocabulary bar.
enum VocabularyCefrFilter { all, a1, a2, b1, b2, advanced }

/// A small, parameterized query and its positional SQLite arguments.
class VocabularyFilterQuery {
  const VocabularyFilterQuery(this.sql, this.arguments);

  final String sql;
  final List<Object?> arguments;
}

enum _CefrSource { indexedColumn, concepts, legacyJson }

class _VocabularySchema {
  const _VocabularySchema(this.cefrSource, this.hasFrequencyRank);

  final _CefrSource cefrSource;
  final bool hasFrequencyRank;
}

/// Reads the installed, read-only offline content pack. No data is loaded into
/// Dart for filtering, and this service never modifies a database or its index.
class VocabularyFilterService {
  VocabularyFilterService({Future<Database> Function(String)? openContentDb})
      : _openContentDb = openContentDb ??
            ((code) => DatabaseService.instance.getContentDb(code));

  final Future<Database> Function(String) _openContentDb;
  final Expando<_VocabularySchema> _schemaCache =
      Expando<_VocabularySchema>('vocabularyFilterSchema');

  /// Paginated results retain the lexicon shape consumed by the dictionary.
  ///
  /// New packs with lexicon.cefr_level and lexicon.frequency_rank can use their
  /// existing indexes. Older packs use concepts.cefr or canonical JSON for CEFR
  /// only; these legacy paths are not index-accelerated. Frequency filtering
  /// fails explicitly if the pack has no frequency_rank rather than inventing
  /// frequency values.
  Future<List<Map<String, Object?>>> search({
    String languageCode = 'de',
    VocabularyCefrFilter level = VocabularyCefrFilter.all,
    int? maxFrequencyRank,
    int limit = 40,
    int offset = 0,
  }) async {
    _validatePagination(limit, offset);
    if (maxFrequencyRank != null && maxFrequencyRank < 1) {
      throw RangeError.value(maxFrequencyRank, 'maxFrequencyRank',
          'Must be a positive integer');
    }

    final db = await _openContentDb(languageCode);
    var schema = _schemaCache[db];
    if (schema == null) {
      schema = await _inspectSchema(db);
      _schemaCache[db] = schema;
    }
    if (maxFrequencyRank != null && !schema.hasFrequencyRank) {
      throw UnsupportedError(
        'This offline content pack has no lexicon.frequency_rank column. '
        'A frequency-ranked pack is required for frequency filtering.',
      );
    }

    final query = buildQuery(
      level: level,
      maxFrequencyRank: maxFrequencyRank,
      limit: limit,
      offset: offset,
      cefrSource: schema.cefrSource.name,
    );
    return db.rawQuery(query.sql, query.arguments);
  }

  /// Pure SQL builder, exposed for focused checks without opening a database.
  ///
  /// [cefrSource] is either indexedColumn, concepts, or legacyJson. In the
  /// normal search path it is detected from the active installed pack.
  static VocabularyFilterQuery buildQuery({
    VocabularyCefrFilter level = VocabularyCefrFilter.all,
    int? maxFrequencyRank,
    int limit = 40,
    int offset = 0,
    String cefrSource = 'indexedColumn',
  }) {
    _validatePagination(limit, offset);
    if (maxFrequencyRank != null && maxFrequencyRank < 1) {
      throw RangeError.value(maxFrequencyRank, 'maxFrequencyRank',
          'Must be a positive integer');
    }
    if (cefrSource != 'indexedColumn' &&
        cefrSource != 'concepts' &&
        cefrSource != 'legacyJson') {
      throw ArgumentError.value(cefrSource, 'cefrSource', 'Unknown CEFR source');
    }

    final args = <Object?>[];
    final sql = StringBuffer(
      'SELECT l.id, l.surface, l.part_of_speech, l.fields_json '
      'FROM lexicon AS l',
    );
    if (level != VocabularyCefrFilter.all && cefrSource == 'concepts') {
      sql.write(' INNER JOIN concepts AS c ON c.concept_id = l.id');
    }
    sql.write(' WHERE 1 = 1');

    if (level != VocabularyCefrFilter.all) {
      final expression = switch (cefrSource) {
        'indexedColumn' => 'l.cefr_level',
        'concepts' => 'c.cefr',
        _ => "COALESCE(json_extract(l.fields_json, '\$.canonical.cefr'), "
            "json_extract(l.fields_json, '\$.cefr'))",
      };

      if (level == VocabularyCefrFilter.advanced) {
        sql.write(' AND $expression IN (?, ?)');
        args.addAll(<String>['C1', 'C2']);
      } else {
        sql.write(' AND $expression = ?');
        args.add(switch (level) {
          VocabularyCefrFilter.a1 => 'A1',
          VocabularyCefrFilter.a2 => 'A2',
          VocabularyCefrFilter.b1 => 'B1',
          VocabularyCefrFilter.b2 => 'B2',
          _ => throw StateError('Unexpected filter level'),
        });
      }
    }

    if (maxFrequencyRank != null) {
      sql.write(' AND l.frequency_rank <= ?');
      args.add(maxFrequencyRank);
    }

    // Pagination is deterministic even on older packs with no frequency data.
    // For a single CEFR level, the indexed schema can order by the second
    // component of its (cefr_level, frequency_rank) index.
    if (cefrSource == 'indexedColumn' &&
        level != VocabularyCefrFilter.all &&
        level != VocabularyCefrFilter.advanced) {
      sql.write(' ORDER BY l.frequency_rank, l.id');
    } else {
      sql.write(' ORDER BY l.id');
    }
    sql.write(' LIMIT ? OFFSET ?');
    args.addAll(<int>[limit, offset]);
    return VocabularyFilterQuery(sql.toString(), args);
  }

  static Future<_VocabularySchema> _inspectSchema(Database db) async {
    final info = await db.rawQuery('PRAGMA table_info(lexicon)');
    final columns =
        info.map((row) => row['name']?.toString()).whereType<String>().toSet();
    if (!columns.containsAll(<String>{
      'id',
      'surface',
      'part_of_speech',
      'fields_json',
    })) {
      throw StateError('Installed content pack has an invalid lexicon schema');
    }

    if (columns.contains('cefr_level')) {
      return _VocabularySchema(
        _CefrSource.indexedColumn,
        columns.contains('frequency_rank'),
      );
    }

    final conceptTable = await db.rawQuery(
      "SELECT 1 FROM sqlite_master WHERE type = 'table' "
      "AND name = 'concepts' LIMIT 1",
    );
    if (conceptTable.isNotEmpty) {
      final conceptData = await db.rawQuery('SELECT 1 FROM concepts LIMIT 1');
      if (conceptData.isNotEmpty) {
        return _VocabularySchema(
          _CefrSource.concepts,
          columns.contains('frequency_rank'),
        );
      }
    }
    return _VocabularySchema(
      _CefrSource.legacyJson,
      columns.contains('frequency_rank'),
    );
  }

  static void _validatePagination(int limit, int offset) {
    if (limit < 1 || limit > 100) {
      throw RangeError.range(limit, 1, 100, 'limit');
    }
    if (offset < 0) {
      throw RangeError.value(offset, 'offset', 'Cannot be negative');
    }
  }
}
