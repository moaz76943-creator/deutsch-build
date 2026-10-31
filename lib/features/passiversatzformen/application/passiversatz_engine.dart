import '../domain/passiversatz_models.dart';

final class PassiversatzEngine {
  const PassiversatzEngine();

  List<PassiversatzChallenge> get challenges => _challenges;

  PassiversatzChallenge byId(String id) {
    for (final challenge in _challenges) {
      if (challenge.id == id) return challenge;
    }
    throw StateError('Unknown Passiversatz challenge: $id');
  }

  PassiversatzChallenge challengeAt(int index) {
    if (_challenges.isEmpty) {
      throw StateError('No Passiversatz challenges are configured.');
    }
    return _challenges[index % _challenges.length];
  }

  PassiversatzEvaluation evaluate({
    required PassiversatzChallenge challenge,
    required PassiversatzForm form,
    required String answer,
  }) {
    final alternative = challenge.alternativeFor(form);
    if (alternative == null) {
      throw ArgumentError.value(
        form,
        'form',
        'The selected form is not valid for this challenge.',
      );
    }

    return PassiversatzEvaluation(
      form: form,
      submitted: answer,
      expected: alternative.sentence,
      isCorrect: _normalize(answer) == _normalize(alternative.sentence),
    );
  }

  static String _normalize(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[.!?]+$'), '')
        .toLowerCase();
  }

  static const List<PassiversatzChallenge> _challenges =
      <PassiversatzChallenge>[
    PassiversatzChallenge(
      id: 'problem_loesen',
      contextAr: 'سياق بحثي: تقييم قابلية حل مشكلة منهجية.',
      passiveSentence: 'Das Problem kann gelöst werden.',
      ruleAr:
          'مع können يمكن غالباً التعبير عن القابلية بـ sich lassen أو بصفة، '
          'وقد تأتي sein + zu بحسب السياق.',
      alternatives: <PassiversatzAlternative>[
        PassiversatzAlternative(
          form: PassiversatzForm.sichLassen,
          sentence: 'Das Problem lässt sich lösen.',
          noteAr:
              'sich lassen + Infinitiv يركّز على أن الفعل ممكن التنفيذ.',
        ),
        PassiversatzAlternative(
          form: PassiversatzForm.seinZuInfinitiv,
          sentence: 'Das Problem ist zu lösen.',
          noteAr:
              'sein + zu + Infinitiv قد يدل على الإمكان أو التكليف؛ '
              'السياق هو الذي يحدد المعنى.',
        ),
        PassiversatzAlternative(
          form: PassiversatzForm.adjective,
          sentence: 'Das Problem ist lösbar.',
          noteAr: 'اللاحقة -bar تحوّل الفعل إلى صفة تدل على القابلية.',
        ),
      ],
    ),
    PassiversatzChallenge(
      id: 'messwerte_interpretieren',
      contextAr: 'سياق علمي: تفسير قياسات تجربة.',
      passiveSentence: 'Die Messwerte können eindeutig interpretiert werden.',
      ruleAr:
          'عند الحديث عن قابلية تحليل البيانات، sich lassen والصفة على '
          '-bar بديلان طبيعيان ومباشران.',
      alternatives: <PassiversatzAlternative>[
        PassiversatzAlternative(
          form: PassiversatzForm.sichLassen,
          sentence: 'Die Messwerte lassen sich eindeutig interpretieren.',
          noteAr: 'يبقى الفعل في المصدر في نهاية التركيب.',
        ),
        PassiversatzAlternative(
          form: PassiversatzForm.adjective,
          sentence: 'Die Messwerte sind eindeutig interpretierbar.',
          noteAr: 'interpretierbar تصف البيانات بأنها قابلة للتفسير.',
        ),
      ],
    ),
    PassiversatzChallenge(
      id: 'sicherheitsregeln_beachten',
      contextAr: 'سياق مختبر: تعليمات سلامة ملزمة.',
      passiveSentence: 'Die Sicherheitsregeln müssen im Labor beachtet werden.',
      ruleAr:
          'عندما يكون المعنى إلزامياً، sein + zu + Infinitiv بديل رسمي '
          'شائع عن müssen + Passiv.',
      alternatives: <PassiversatzAlternative>[
        PassiversatzAlternative(
          form: PassiversatzForm.seinZuInfinitiv,
          sentence: 'Die Sicherheitsregeln sind im Labor zu beachten.',
          noteAr:
              'هنا sein + zu لا يعني مجرد الإمكان، بل ضرورة الالتزام بالقواعد.',
        ),
      ],
    ),
    PassiversatzChallenge(
      id: 'methode_anwenden',
      contextAr: 'سياق أكاديمي: وصف صلاحية طريقة داخل دراسة.',
      passiveSentence: 'Die Methode kann in der Studie angewendet werden.',
      ruleAr:
          'يمكن نقل معنى القابلية من Passiv مع können إلى sich lassen أو '
          'إلى صفة مشتقة بـ -bar.',
      alternatives: <PassiversatzAlternative>[
        PassiversatzAlternative(
          form: PassiversatzForm.sichLassen,
          sentence: 'Die Methode lässt sich in der Studie anwenden.',
          noteAr: 'الفعل anwenden يعود إلى المصدر بعد lassen.',
        ),
        PassiversatzAlternative(
          form: PassiversatzForm.adjective,
          sentence: 'Die Methode ist in der Studie anwendbar.',
          noteAr: 'anwendbar تعني قابلة للتطبيق.',
        ),
      ],
    ),
    PassiversatzChallenge(
      id: 'begruendung_verstehen',
      contextAr: 'سياق أكاديمي: وضوح تفسير مكتوب.',
      passiveSentence:
          'Die Begründung kann ohne Zusatzdaten verstanden werden.',
      ruleAr:
          'ليست كل الصفات البديلة منتهية بـ -bar؛ بعض المعاني الطبيعية '
          'تُعبّر عنها صفة على -lich.',
      alternatives: <PassiversatzAlternative>[
        PassiversatzAlternative(
          form: PassiversatzForm.sichLassen,
          sentence:
              'Die Begründung lässt sich ohne Zusatzdaten verstehen.',
          noteAr: 'التركيب يعبّر عن إمكان فهم التفسير.',
        ),
        PassiversatzAlternative(
          form: PassiversatzForm.adjective,
          sentence: 'Die Begründung ist ohne Zusatzdaten verständlich.',
          noteAr:
              'verständlich صفة على -lich ومعناها مفهوم أو قابل للفهم.',
        ),
      ],
    ),
    PassiversatzChallenge(
      id: 'quellen_angeben',
      contextAr: 'سياق بحثي: متطلبات توثيق المصادر.',
      passiveSentence: 'Die Quellen müssen im Bericht angegeben werden.',
      ruleAr:
          'في التعليمات الأكاديمية الرسمية، sein + zu + Infinitiv يختصر '
          'müssen + Passiv دون تغيير محور الجملة.',
      alternatives: <PassiversatzAlternative>[
        PassiversatzAlternative(
          form: PassiversatzForm.seinZuInfinitiv,
          sentence: 'Die Quellen sind im Bericht anzugeben.',
          noteAr:
              'الفعل المنفصل angeben يظهر هنا كمصدر مع zu داخلياً: anzugeben.',
        ),
      ],
    ),
  ];
}
