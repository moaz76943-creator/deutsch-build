enum ConjunctionCategory {
  coordinatingADUSO,
  subordinatingNebensatz,
  adverbialInversion,
}

final class ConjunctionDrillItem {
  const ConjunctionDrillItem({
    required this.id,
    required this.category,
    required this.mainClause,
    required this.linkedClause,
    required this.targetConnector,
    required this.correctVerbPosition,
    required this.arabicTranslation,
    required this.verbPositionExplanationAr,
  })  : assert(id.length > 0),
        assert(mainClause.length > 0),
        assert(linkedClause.length > 0),
        assert(targetConnector.length > 0),
        assert(
          correctVerbPosition == positionZero ||
              correctVerbPosition == positionOne ||
              correctVerbPosition == positionEnd,
        ),
        assert(arabicTranslation.length > 0),
        assert(verbPositionExplanationAr.length > 0);

  /// Coordinating conjunction occupies Position 0; the clause itself stays V2.
  static const int positionZero = 0;

  /// Adverbial connector occupies the first field and triggers inversion.
  static const int positionOne = 1;

  /// Sentinel for a finite verb placed at the end of a subordinate clause.
  static const int positionEnd = -1;

  final String id;
  final ConjunctionCategory category;
  final String mainClause;
  final String linkedClause;
  final String targetConnector;
  final int correctVerbPosition;
  final String arabicTranslation;
  final String verbPositionExplanationAr;

  static String verbPositionLabel(int position) => switch (position) {
        positionZero => 'Position 0',
        positionOne => 'Position 1',
        positionEnd => 'End',
        _ => 'Unknown',
      };
}
