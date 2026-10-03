enum SentenceStructureType {
  mainClause,
  subordinateWeil,
  questionInversion,
}

enum WordGrammaticalFunction {
  subject,
  verb,
  object,
  adverbial,
}

final class WordTileItem {
  const WordTileItem({
    required this.id,
    required this.germanText,
    required this.grammaticalFunction,
    required this.correctPosition,
  })  : assert(id.length > 0),
        assert(germanText.length > 0),
        assert(correctPosition >= 0);

  final String id;
  final String germanText;
  final WordGrammaticalFunction grammaticalFunction;
  final int correctPosition;
}

final class SentencePuzzle {
  SentencePuzzle({
    required this.id,
    required this.completedSentence,
    required this.arabicTranslation,
    required List<WordTileItem> shuffledTiles,
    required this.structureType,
    required this.ruleExplanation,
  }) : shuffledTiles = List<WordTileItem>.unmodifiable(shuffledTiles);

  final String id;
  final String completedSentence;
  final String arabicTranslation;
  final List<WordTileItem> shuffledTiles;
  final SentenceStructureType structureType;
  final String ruleExplanation;

  List<WordTileItem> get correctArrangement {
    final tiles = List<WordTileItem>.of(shuffledTiles)
      ..sort(
        (left, right) =>
            left.correctPosition.compareTo(right.correctPosition),
      );
    return List<WordTileItem>.unmodifiable(tiles);
  }
}
