/// Participle type used as an adjectival modifier.
enum ParticipleType { partizip1Present, partizip2Past }

/// Transformation analysis between participial attribute and relative clause.
class ParticipialAttributeAnalysis {
  final String noun;
  final String baseVerb;
  final ParticipleType type;
  final String adjectivalParticiple;
  final String nounPhrase;
  final String equivalentRelativeClause;

  ParticipialAttributeAnalysis({
    required this.noun,
    required this.baseVerb,
    required this.type,
    required this.adjectivalParticiple,
    required this.nounPhrase,
    required this.equivalentRelativeClause,
  });

  Map<String, dynamic> toJson() => {
        'noun': noun,
        'verb': baseVerb,
        'type': type.name,
        'adjectival': adjectivalParticiple,
        'phrase': nounPhrase,
        'rel_clause': equivalentRelativeClause,
      };
}

/// Offline rule engine for German participial attributes (Partizipialattribute).
/// Constructs Partizip I (infinitive + d + ending) for active simultaneous actions
/// and Partizip II + ending for completed passive actions, with relative clause translation.
class GermanParticipialAttributeEngine {
  /// Construct Partizip I modifier (e.g. spielen -> spielend -> das spielende Kind).
  static ParticipialAttributeAnalysis buildPartizipOne({
    required String article,
    required String noun,
    required String verbInfinitive,
    String ending = 'e',
  }) {
    final cleanVerb = verbInfinitive.trim().toLowerCase();
    final participle = '${cleanVerb}d$ending';
    final phrase = '$article $participle $noun';
    final relClause = '$article $noun, das ${cleanVerb}t';

    return ParticipialAttributeAnalysis(
      noun: noun,
      baseVerb: verbInfinitive,
      type: ParticipleType.partizip1Present,
      adjectivalParticiple: participle,
      nounPhrase: phrase,
      equivalentRelativeClause: relClause,
    );
  }

  /// Construct Partizip II modifier (e.g. reparieren -> repariert -> das reparierte Auto).
  static ParticipialAttributeAnalysis buildPartizipTwo({
    required String article,
    required String noun,
    required String verbInfinitive,
    required String partizipTwoRoot,
    String ending = 'e',
  }) {
    final participle = '$partizipTwoRoot$ending';
    final phrase = '$article $participle $noun';
    final relClause = '$article $noun, das $partizipTwoRoot wurde';

    return ParticipialAttributeAnalysis(
      noun: noun,
      baseVerb: verbInfinitive,
      type: ParticipleType.partizip2Past,
      adjectivalParticiple: participle,
      nounPhrase: phrase,
      equivalentRelativeClause: relClause,
    );
  }
}
