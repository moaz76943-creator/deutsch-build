enum PassivType { vorgangspassiv, zustandspassiv }

enum PassivTense { praesens, praeteritum, perfekt }

final class PassivDrillItem {
  const PassivDrillItem({
    required this.id,
    required this.activeSentence,
    required this.passiveSentence,
    required this.originalAgent,
    required this.agentPreposition,
    required this.agentCaseLabel,
    required this.akkusativObject,
    required this.nominativSubject,
    required this.auxiliaryForm,
    required this.partizipII,
    required this.type,
    required this.tense,
    required this.explanationAr,
  });

  final String id;
  final String activeSentence;
  final String passiveSentence;
  final String originalAgent;
  final String agentPreposition;
  final String agentCaseLabel;
  final String akkusativObject;
  final String nominativSubject;
  final String auxiliaryForm;
  final String partizipII;
  final PassivType type;
  final PassivTense tense;
  final String explanationAr;

  String get typeLabelAr => switch (type) {
        PassivType.vorgangspassiv => 'مجهول الحدث',
        PassivType.zustandspassiv => 'مجهول الحالة',
      };

  String get tenseLabel => switch (tense) {
        PassivTense.praesens => 'Präsens',
        PassivTense.praeteritum => 'Präteritum',
        PassivTense.perfekt => 'Perfekt',
      };

  String get structureLabel {
    return switch ((type, tense)) {
      (PassivType.vorgangspassiv, PassivTense.praesens) =>
        'werden (Präsens) + Partizip II',
      (PassivType.vorgangspassiv, PassivTense.praeteritum) =>
        'werden (Präteritum) + Partizip II',
      (PassivType.vorgangspassiv, PassivTense.perfekt) =>
        'sein + Partizip II + worden',
      (PassivType.zustandspassiv, PassivTense.praesens) =>
        'sein (Präsens) + Partizip II',
      (PassivType.zustandspassiv, PassivTense.praeteritum) =>
        'sein (Präteritum) + Partizip II',
      (PassivType.zustandspassiv, PassivTense.perfekt) =>
        'sein + Partizip II + gewesen',
    };
  }
}
