enum ComparisonDegree { positiv, komparativ, superlativ }

enum ComparisonRuleType { regular, umlautChange, irregular, stemChange }

final class ComparisonChallengeItem {
  const ComparisonChallengeItem({
    required this.id,
    required this.positiv,
    required this.komparativ,
    required this.superlativ,
    required this.ruleType,
    required this.positivSentence,
    required this.komparativSentence,
    required this.superlativSentence,
    required this.positivTranslationAr,
    required this.komparativTranslationAr,
    required this.superlativTranslationAr,
    required this.explanationAr,
    this.equalityConnector = 'wie',
    this.comparativeConnector = 'als',
    this.attributiveSuperlativ,
  });

  final String id;
  final String positiv;
  final String komparativ;
  final String superlativ;
  final String? attributiveSuperlativ;
  final ComparisonRuleType ruleType;
  final String equalityConnector;
  final String comparativeConnector;
  final String positivSentence;
  final String komparativSentence;
  final String superlativSentence;
  final String positivTranslationAr;
  final String komparativTranslationAr;
  final String superlativTranslationAr;
  final String explanationAr;

  String answerFor(ComparisonDegree degree) => switch (degree) {
        ComparisonDegree.positiv => positiv,
        ComparisonDegree.komparativ => komparativ,
        ComparisonDegree.superlativ => superlativ,
      };

  String sentenceFor(ComparisonDegree degree) => switch (degree) {
        ComparisonDegree.positiv => positivSentence,
        ComparisonDegree.komparativ => komparativSentence,
        ComparisonDegree.superlativ => superlativSentence,
      };

  String translationFor(ComparisonDegree degree) => switch (degree) {
        ComparisonDegree.positiv => positivTranslationAr,
        ComparisonDegree.komparativ => komparativTranslationAr,
        ComparisonDegree.superlativ => superlativTranslationAr,
      };

  String? connectorFor(ComparisonDegree degree) => switch (degree) {
        ComparisonDegree.positiv => equalityConnector,
        ComparisonDegree.komparativ => comparativeConnector,
        ComparisonDegree.superlativ => null,
      };
}
