final class SrsCorpusContract {
  const SrsCorpusContract._();

  static const int schemaVersion = 1;
  static const int expectedContentRows = 14813;
  static const int expectedVerbRows = 11718;

  static const String metadataTable = 'srs_corpus_metadata';
  static const String contentTable = 'srs_corpus_content';
  static const String acceptedTable = 'srs_corpus_accepted';
  static const String verbTable = 'srs_corpus_verb_rows';

  static const Set<String> requiredIndexes = <String>{
    'idx_srs_content_topic_skill_id',
    'idx_srs_content_german',
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
CREATE INDEX idx_srs_accepted_form
ON srs_corpus_accepted(form, content_id)
''',
    '''
CREATE INDEX idx_srs_verbs_infinitive_person
ON srs_corpus_verb_rows(infinitive, person, content_id)
''',
  ];
}

final class SrsCorpusVerification {
  const SrsCorpusVerification({
    required this.schemaVersion,
    required this.contentRows,
    required this.verbRows,
    required this.indexes,
  });

  final int schemaVersion;
  final int contentRows;
  final int verbRows;
  final Set<String> indexes;

  bool get hasExpectedCardinality =>
      contentRows == SrsCorpusContract.expectedContentRows &&
      verbRows == SrsCorpusContract.expectedVerbRows;
}
