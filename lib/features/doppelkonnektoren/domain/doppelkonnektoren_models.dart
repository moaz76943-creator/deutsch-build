enum DoppelConnectorType {
  jeDesto,
  sowohlAlsAuch,
  wederNoch,
}

enum DoppelConnectorTopic {
  studies,
  productivity,
  health,
  science,
}

extension DoppelConnectorTypeMetadata on DoppelConnectorType {
  String get firstPart => switch (this) {
        DoppelConnectorType.jeDesto => 'je',
        DoppelConnectorType.sowohlAlsAuch => 'sowohl',
        DoppelConnectorType.wederNoch => 'weder',
      };

  String get secondPart => switch (this) {
        DoppelConnectorType.jeDesto => 'desto',
        DoppelConnectorType.sowohlAlsAuch => 'als auch',
        DoppelConnectorType.wederNoch => 'noch',
      };

  String get formula => '$firstPart … $secondPart';

  bool get requiresComparative =>
      this == DoppelConnectorType.jeDesto;

  String get arabicLabel => switch (this) {
        DoppelConnectorType.jeDesto =>
          'كلما … كان / أصبح … أكثر',
        DoppelConnectorType.sowohlAlsAuch =>
          'كِلا … و … / بالإضافة إلى الاثنين',
        DoppelConnectorType.wederNoch =>
          'لا … ولا …',
      };

  String get grammarHint => switch (this) {
        DoppelConnectorType.jeDesto =>
          'je + Komparativ … desto + Komparativ',
        DoppelConnectorType.sowohlAlsAuch =>
          'sowohl + Element A … als auch + Element B',
        DoppelConnectorType.wederNoch =>
          'weder + Element A … noch + Element B',
      };
}

extension DoppelConnectorTopicLabel on DoppelConnectorTopic {
  String get arabicLabel => switch (this) {
        DoppelConnectorTopic.studies => 'الدراسة',
        DoppelConnectorTopic.productivity => 'الإنتاجية',
        DoppelConnectorTopic.health => 'الصحة',
        DoppelConnectorTopic.science => 'العلوم',
      };
}

final class DoppelConnectorChallengeItem {
  DoppelConnectorChallengeItem({
    required this.id,
    required this.type,
    required this.topic,
    required this.sourceIdea,
    required this.correctSentence,
    required this.arabicTranslation,
    required this.arabicExplanation,
  }) {
    if (id.trim().isEmpty ||
        sourceIdea.trim().isEmpty ||
        correctSentence.trim().isEmpty ||
        arabicTranslation.trim().isEmpty ||
        arabicExplanation.trim().isEmpty) {
      throw ArgumentError('Invalid Doppelkonnektor challenge.');
    }
  }

  final String id;
  final DoppelConnectorType type;
  final DoppelConnectorTopic topic;
  final String sourceIdea;
  final String correctSentence;
  final String arabicTranslation;
  final String arabicExplanation;

  String get formula => type.formula;
}
