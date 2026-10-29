import 'sentence_builder_models.dart';

abstract class SentenceBuilderRepository {
  Future<List<SentencePuzzle>> getPuzzlesByLevel(String level);

  Future<bool> validateArrangement(
    String puzzleId,
    List<String> arrangedTileIds,
  );
}
