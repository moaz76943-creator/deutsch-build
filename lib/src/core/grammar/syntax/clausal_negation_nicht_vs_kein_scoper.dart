/// Task 1311: German clausal vs constituent negation ('nicht' vs 'kein')
class NegationScoper {
  String determineNegator(bool isNounWithIndefiniteArticle) => isNounWithIndefiniteArticle ? 'kein' : 'nicht';
}
