/// Model defining a standalone SQLite pack table schema.
class SqliteTableDefinition {
  final String tableName;
  final List<String> columnDefinitions;

  const SqliteTableDefinition({
    required this.tableName,
    required this.columnDefinitions,
  });

  String toCreateSql() {
    return 'CREATE TABLE IF NOT EXISTS $tableName (${columnDefinitions.join(', ')});';
  }
}

/// Headless compiler generating SQLite/Drift schema definitions for offline language packs.
class SovereignSqlitePackBuilder {
  static const List<SqliteTableDefinition> standardPackTables = [
    SqliteTableDefinition(
      tableName: 'lexical_entries',
      columnDefinitions: [
        'id INTEGER PRIMARY KEY AUTOINCREMENT',
        'german_word TEXT NOT NULL',
        'arabic_meaning TEXT NOT NULL',
        'part_of_speech TEXT NOT NULL',
        'cefr_level TEXT NOT NULL',
        'example_de TEXT NOT NULL',
        'example_ar TEXT NOT NULL',
      ],
    ),
    SqliteTableDefinition(
      tableName: 'dialogue_turns',
      columnDefinitions: [
        'id INTEGER PRIMARY KEY AUTOINCREMENT',
        'scenario_id TEXT NOT NULL',
        'turn_index INTEGER NOT NULL',
        'speaker TEXT NOT NULL',
        'utterance_de TEXT NOT NULL',
        'utterance_ar TEXT NOT NULL',
        'tip_ar TEXT',
      ],
    ),
    SqliteTableDefinition(
      tableName: 'bitext_pairs',
      columnDefinitions: [
        'id INTEGER PRIMARY KEY AUTOINCREMENT',
        'pair_id INTEGER NOT NULL',
        'lang_code TEXT NOT NULL',
        'sentence_target TEXT NOT NULL',
        'sentence_native TEXT NOT NULL',
        'grammar_focus TEXT',
      ],
    ),
  ];

  /// Generates master SQLite initialization DDL script.
  String generateMasterDdl() {
    final buffer = StringBuffer();
    for (final table in standardPackTables) {
      buffer.writeln(table.toCreateSql());
    }
    return buffer.toString().trim();
  }
}
