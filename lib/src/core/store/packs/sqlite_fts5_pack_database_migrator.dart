class SqliteFts5PackDatabaseMigrator {
  const SqliteFts5PackDatabaseMigrator();
  String buildFts5Query(String term) => "SELECT * FROM dictionary_fts WHERE word MATCH '$term*';";
}
