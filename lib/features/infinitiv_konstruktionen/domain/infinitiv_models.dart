enum InfinitivClauseType {
  infinitivMitZu,
  umZu,
  ohneZu,
  anstattZu,
}

extension InfinitivClauseTypeMetadata on InfinitivClauseType {
  String get marker => switch (this) {
        InfinitivClauseType.infinitivMitZu => 'zu',
        InfinitivClauseType.umZu => 'um ... zu',
        InfinitivClauseType.ohneZu => 'ohne ... zu',
        InfinitivClauseType.anstattZu => 'anstatt ... zu',
      };

  String get labelAr => switch (this) {
        InfinitivClauseType.infinitivMitZu => 'Infinitiv mit zu',
        InfinitivClauseType.umZu => 'الغرض: um ... zu',
        InfinitivClauseType.ohneZu => 'بدون فعل: ohne ... zu',
        InfinitivClauseType.anstattZu => 'بدل فعل: anstatt ... zu',
      };
}

final class InfinitivChallengeItem {
  InfinitivChallengeItem({
    required this.id,
    required this.type,
    required this.mainClause,
    required this.infinitivePhrase,
    required this.correctConstruction,
    required List<String> answerOptions,
    required this.arabicTranslation,
    required this.ruleExplanationAr,
    required this.requiresSameSubject,
  }) : answerOptions = List<String>.unmodifiable(answerOptions) {
    if (id.trim().isEmpty || id.length > 160) {
      throw ArgumentError.value(id, 'id', 'invalid challenge id');
    }
    if (mainClause.trim().isEmpty ||
        infinitivePhrase.trim().isEmpty ||
        correctConstruction.trim().isEmpty) {
      throw ArgumentError('challenge text must not be empty');
    }
    if (this.answerOptions.length < 2) {
      throw ArgumentError('at least two answer options are required');
    }
    if (!this.answerOptions.contains(correctConstruction)) {
      throw ArgumentError(
        'answerOptions must contain correctConstruction exactly',
      );
    }
    if (arabicTranslation.trim().isEmpty ||
        ruleExplanationAr.trim().isEmpty) {
      throw ArgumentError('Arabic guidance must not be empty');
    }
  }

  final String id;
  final InfinitivClauseType type;
  final String mainClause;
  final String infinitivePhrase;
  final String correctConstruction;
  final List<String> answerOptions;
  final String arabicTranslation;
  final String ruleExplanationAr;
  final bool requiresSameSubject;

  String get marker => type.marker;
}
