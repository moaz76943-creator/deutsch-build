enum ConjunctionType {
  positionZero,
  verbKicker,
  adverbialConnector,
}

final class ConnectorChallengeItem {
  const ConnectorChallengeItem({
    required this.id,
    required this.firstSentence,
    required this.secondSentence,
    required this.targetConnector,
    required this.correctCombinedSentence,
    required this.type,
    required this.arabicVerbPositionExplanation,
  })  : assert(id.length > 0),
        assert(firstSentence.length > 0),
        assert(secondSentence.length > 0),
        assert(targetConnector.length > 0),
        assert(correctCombinedSentence.length > 0),
        assert(arabicVerbPositionExplanation.length > 0);

  final String id;
  final String firstSentence;
  final String secondSentence;
  final String targetConnector;
  final String correctCombinedSentence;
  final ConjunctionType type;
  final String arabicVerbPositionExplanation;
}
