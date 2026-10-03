enum BureaucracySituation { buergeramt, bank, anmeldung }

enum DialogueSpeaker { official, learner }

final class OfficialDocumentBadge {
  const OfficialDocumentBadge({
    required this.id,
    required this.labelDe,
    required this.labelAr,
    required this.required,
  });

  final String id;
  final String labelDe;
  final String labelAr;
  final bool required;
}

final class DialogueChoice {
  const DialogueChoice({
    required this.id,
    required this.textDe,
    required this.translationAr,
    required this.feedbackAr,
    required this.isCorrect,
  });

  final String id;
  final String textDe;
  final String translationAr;
  final String feedbackAr;
  final bool isCorrect;
}

final class BureaucracyDialogueTurn {
  const BureaucracyDialogueTurn({
    required this.id,
    required this.speaker,
    required this.textDe,
    required this.translationAr,
    this.choices = const <DialogueChoice>[],
  });

  final String id;
  final DialogueSpeaker speaker;
  final String textDe;
  final String translationAr;
  final List<DialogueChoice> choices;
}

final class BureaucracyScenario {
  const BureaucracyScenario({
    required this.id,
    required this.type,
    required this.titleDe,
    required this.titleAr,
    required this.goalAr,
    required this.documents,
  });

  final String id;
  final BureaucracySituation type;
  final String titleDe;
  final String titleAr;
  final String goalAr;
  final List<OfficialDocumentBadge> documents;

  String get typeLabelDe => switch (type) {
        BureaucracySituation.buergeramt => 'Bürgeramt',
        BureaucracySituation.bank => 'Bank',
        BureaucracySituation.anmeldung => 'Anmeldung',
      };
}
