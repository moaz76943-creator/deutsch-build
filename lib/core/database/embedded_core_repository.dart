class CoreWordItem {
  final int id;
  final String lemma;
  final String pos;
  final String? gender;
  final String cefrLevel;
  final String meaningAr;

  const CoreWordItem({
    required this.id,
    required this.lemma,
    required this.pos,
    this.gender,
    required this.cefrLevel,
    required this.meaningAr,
  });
}

/// Standalone repository reading directly from internal embedded database.
/// Completely decoupled from external downloads and third-party pack dependencies.
class EmbeddedCoreRepository {
  final String databasePath;

  const EmbeddedCoreRepository({this.databasePath = 'assets/database/polyglot_embedded_core.db'});

  /// استعلام البحث الداخلي المستقل
  String buildSearchQuery(String searchTerm) {
    final clean = searchTerm.replaceAll("'", "''").trim();
    return "SELECT id, lemma, pos, gender, cefr_level, meaning_ar "
           "FROM core_lexicon "
           "WHERE lemma LIKE '$clean%' OR meaning_ar LIKE '%$clean%' "
           "LIMIT 20;";
  }
}
