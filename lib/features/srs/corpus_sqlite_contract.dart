final class SrsCorpusContract {
  const SrsCorpusContract._();

  /// Schema of the derived, language-neutral runtime SRS corpus.
  static const int schemaVersion = 2;

  static const String metadataTable = 'srs_corpus_metadata';
  static const String contentTable = 'srs_corpus_content';
  static const String acceptedTable = 'srs_corpus_accepted';
  static const String verbTable = 'srs_corpus_verb_rows';

  static const String metadataSchemaVersionKey = 'schemaVersion';
  static const String metadataStateKey = 'state';
  static const String metadataContentRowsKey = 'contentRows';
  static const String metadataVerbRowsKey = 'verbRows';
  static const String metadataSourceContentSha256Key = 'sourceContentSha256';

  static const Set<String> requiredIndexes = <String>{
    'idx_srs_content_topic_skill_id',
    'idx_srs_content_german',
    'idx_srs_content_cefr_id',
    'idx_srs_accepted_form',
    'idx_srs_verbs_infinitive_person',
  };

  static const List<String> createSchemaStatements = <String>[
    '''
CREATE TABLE srs_corpus_metadata (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
)
''',
    '''
CREATE TABLE srs_corpus_content (
  id TEXT PRIMARY KEY,
  german TEXT NOT NULL,
  arabic TEXT NOT NULL,
  sentence TEXT NOT NULL,
  sentence_ar TEXT NOT NULL,
  topic TEXT NOT NULL,
  skill TEXT NOT NULL,
  cefr TEXT NOT NULL CHECK (cefr IN ('unknown', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  article TEXT NOT NULL,
  plural TEXT NOT NULL
)
''',
    '''
CREATE TABLE srs_corpus_accepted (
  content_id TEXT NOT NULL
    REFERENCES srs_corpus_content(id) ON DELETE CASCADE,
  ordinal INTEGER NOT NULL,
  form TEXT NOT NULL,
  PRIMARY KEY (content_id, ordinal)
)
''',
    '''
CREATE TABLE srs_corpus_verb_rows (
  row_id INTEGER PRIMARY KEY AUTOINCREMENT,
  content_id TEXT NOT NULL
    REFERENCES srs_corpus_content(id) ON DELETE CASCADE,
  row_ordinal INTEGER NOT NULL,
  infinitive TEXT NOT NULL,
  arabic TEXT NOT NULL,
  group_name TEXT NOT NULL,
  person TEXT NOT NULL,
  person_ar TEXT NOT NULL,
  form TEXT NOT NULL,
  past TEXT NOT NULL,
  past_arabic TEXT NOT NULL,
  example TEXT NOT NULL,
  example_ar TEXT NOT NULL,
  past_example TEXT NOT NULL,
  past_example_ar TEXT NOT NULL,
  UNIQUE (content_id, row_ordinal)
)
''',
  ];

  static const List<String> createIndexStatements = <String>[
    '''
CREATE INDEX idx_srs_content_topic_skill_id
ON srs_corpus_content(topic, skill, id)
''',
    '''
CREATE INDEX idx_srs_content_german
ON srs_corpus_content(german, id)
''',
    '''
CREATE INDEX idx_srs_content_cefr_id
ON srs_corpus_content(cefr, id)
''',
    '''
CREATE INDEX idx_srs_accepted_form
ON srs_corpus_accepted(form, content_id)
''',
    '''
CREATE INDEX idx_srs_verbs_infinitive_person
ON srs_corpus_verb_rows(infinitive, person, content_id)
''',
  ];
}

/// Cardinality declared by an admitted language pack.
///
/// Content rows must be non-empty. Verb rows may legitimately be zero for
/// languages/packs that do not expose conjugation rows through the legacy
/// migration surface.
final class SrsCorpusCardinality {
  SrsCorpusCardinality({
    required this.contentRows,
    required this.verbRows,
  }) {
    if (contentRows < 1) {
      throw ArgumentError.value(
        contentRows,
        'contentRows',
        'must be positive',
      );
    }
    if (verbRows < 0) {
      throw ArgumentError.value(
        verbRows,
        'verbRows',
        'must not be negative',
      );
    }
  }

  final int contentRows;
  final int verbRows;
}

final class SrsCorpusVerification {
  const SrsCorpusVerification({
    required this.schemaVersion,
    required this.contentRows,
    required this.verbRows,
    required this.expectedContentRows,
    required this.expectedVerbRows,
    required this.sourceContentSha256,
    required this.indexes,
  });

  final int schemaVersion;
  final int contentRows;
  final int verbRows;
  final int expectedContentRows;
  final int expectedVerbRows;
  final String sourceContentSha256;
  final Set<String> indexes;

  bool get hasExpectedCardinality =>
      contentRows == expectedContentRows &&
      verbRows == expectedVerbRows;
}
