enum PassiversatzForm {
  sichLassen,
  seinZuInfinitiv,
  adjective,
}

extension PassiversatzFormLabels on PassiversatzForm {
  String get germanLabel => switch (this) {
        PassiversatzForm.sichLassen => 'sich lassen + Infinitiv',
        PassiversatzForm.seinZuInfinitiv => 'sein + zu + Infinitiv',
        PassiversatzForm.adjective => 'Adjektiv auf -bar/-lich',
      };

  String get arabicLabel => switch (this) {
        PassiversatzForm.sichLassen => 'إمكانية التنفيذ',
        PassiversatzForm.seinZuInfinitiv => 'إمكانية أو ضرورة حسب السياق',
        PassiversatzForm.adjective => 'صفة تعبّر عن القابلية',
      };
}

final class PassiversatzAlternative {
  const PassiversatzAlternative({
    required this.form,
    required this.sentence,
    required this.noteAr,
  });

  final PassiversatzForm form;
  final String sentence;
  final String noteAr;
}

final class PassiversatzChallenge {
  const PassiversatzChallenge({
    required this.id,
    required this.contextAr,
    required this.passiveSentence,
    required this.alternatives,
    required this.ruleAr,
  });

  final String id;
  final String contextAr;
  final String passiveSentence;
  final List<PassiversatzAlternative> alternatives;
  final String ruleAr;

  PassiversatzAlternative? alternativeFor(PassiversatzForm form) {
    for (final alternative in alternatives) {
      if (alternative.form == form) return alternative;
    }
    return null;
  }
}

final class PassiversatzEvaluation {
  const PassiversatzEvaluation({
    required this.form,
    required this.submitted,
    required this.expected,
    required this.isCorrect,
  });

  final PassiversatzForm form;
  final String submitted;
  final String expected;
  final bool isCorrect;
}
