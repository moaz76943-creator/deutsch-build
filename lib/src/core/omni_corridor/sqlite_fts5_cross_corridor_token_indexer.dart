/// Task 1917: SQLite FTS5 cross-corridor token indexer for multi-language search
class CrossCorridorFtsIndexer {
  String sanitizeToken(String raw) => raw.replaceAll("'", "''");
}
