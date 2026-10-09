enum WordOrderTypology { svo, sov, vso, free }

class CrossLinguisticCognate {
  final String sourceWord;
  final String targetWord;
  final String sourceLang;
  final String targetLang;
  final bool isFalseFriend;
  final String nuanceNotes;

  const CrossLinguisticCognate({
    required this.sourceWord,
    required this.targetWord,
    required this.sourceLang,
    required this.targetLang,
    required this.isFalseFriend,
    required this.nuanceNotes,
  });
}

class TypologicalStructure {
  final String language;
  final WordOrderTypology typology;
  final String subject;
  final String verb;
  final String object;

  const TypologicalStructure({
    required this.language,
    required this.typology,
    required this.subject,
    required this.verb,
    required this.object,
  });

  String renderSequence() {
    switch (typology) {
      case WordOrderTypology.svo:
        return '$subject + $verb + $object';
      case WordOrderTypology.sov:
        return '$subject + $object + $verb';
      case WordOrderTypology.vso:
        return '$verb + $subject + $object';
      case WordOrderTypology.free:
        return '[$subject, $verb, $object] (مرن)';
    }
  }
}
