import 'word_formation_models.dart';

abstract interface class WordFormationRepository {
  Future<List<WordDerivationItem>> getDrills({
    SuffixCategory? category,
  });

  Future<bool> checkDerivedWord(
    String drillId,
    String candidate,
  );

  Future<bool> checkArticle(
    String drillId,
    String article,
  );
}
