import '../domain/grammar_drill_models.dart';

final class LocalGrammarDrillRepository implements GrammarDrillRepository {
  const LocalGrammarDrillRepository();

  static const List<GrammarDrill> _drills = <GrammarDrill>[
    SentenceReorderExercise(
      id: 'a1-order-heute-deutsch',
      level: GrammarLevel.a1,
      titleAr: 'رتّب الجملة',
      instructionAr: 'رتّب الكلمات لتكوين جملة ألمانية صحيحة.',
      reinforcementAr: 'ممتاز — ثبتَّ قاعدة الفعل في الموقع الثاني.',
      translationAr: 'أنا أتعلم الألمانية اليوم.',
      tokens: <GrammarToken>[
        GrammarToken(id: 'a1o1', text: 'Heute', role: GrammarTokenRole.other),
        GrammarToken(id: 'a1o2', text: 'lerne', role: GrammarTokenRole.verb),
        GrammarToken(id: 'a1o3', text: 'ich', role: GrammarTokenRole.subject),
        GrammarToken(id: 'a1o4', text: 'Deutsch.', role: GrammarTokenRole.other),
      ],
      correctTokenIds: <String>['a1o1', 'a1o2', 'a1o3', 'a1o4'],
    ),
    VerbConjugationDrill(
      id: 'a1-verb-sein-ich',
      level: GrammarLevel.a1,
      titleAr: 'تصريف الفعل sein',
      instructionAr: 'اكتب التصريف الصحيح مع الضمير ich.',
      reinforcementAr: 'صحيح — ich bin.',
      infinitive: 'sein',
      pronoun: 'ich',
      sentencePrefix: 'Ich',
      sentenceSuffix: 'heute zu Hause.',
      expectedForm: 'bin',
    ),
    CaseSelectionDrill(
      id: 'a1-case-mantel',
      level: GrammarLevel.a1,
      titleAr: 'Akkusativ مع المذكر',
      instructionAr: 'اختر أداة التعريف الصحيحة.',
      reinforcementAr: 'صحيح — der يتحول إلى den في Akkusativ.',
      targetCase: GrammarCase.accusative,
      sentenceBefore: 'Ich kaufe',
      noun: 'Mantel.',
      sentenceAfter: '',
      options: <String>['der', 'den', 'dem'],
      expectedArticle: 'den',
      explanationAr: 'Mantel مذكر وهو مفعول به مباشر: der → den.',
    ),
    SentenceReorderExercise(
      id: 'a2-order-weil',
      level: GrammarLevel.a2,
      titleAr: 'جملة فرعية مع weil',
      instructionAr: 'رتّب الكلمات وانتبه لموقع الفعل في الجملة الفرعية.',
      reinforcementAr: 'رائع — في جملة weil ينتقل الفعل المصرف إلى النهاية.',
      translationAr: 'أبقى في البيت لأنني أعمل غدًا.',
      tokens: <GrammarToken>[
        GrammarToken(id: 'a2o1', text: 'Ich', role: GrammarTokenRole.subject),
        GrammarToken(id: 'a2o2', text: 'bleibe', role: GrammarTokenRole.verb),
        GrammarToken(id: 'a2o3', text: 'zu Hause,', role: GrammarTokenRole.other),
        GrammarToken(id: 'a2o4', text: 'weil', role: GrammarTokenRole.connector),
        GrammarToken(id: 'a2o5', text: 'ich', role: GrammarTokenRole.subject),
        GrammarToken(id: 'a2o6', text: 'morgen', role: GrammarTokenRole.other),
        GrammarToken(id: 'a2o7', text: 'arbeite.', role: GrammarTokenRole.verb),
      ],
      correctTokenIds: <String>[
        'a2o1',
        'a2o2',
        'a2o3',
        'a2o4',
        'a2o5',
        'a2o6',
        'a2o7',
      ],
    ),
    VerbConjugationDrill(
      id: 'a2-verb-fahren-du',
      level: GrammarLevel.a2,
      titleAr: 'تغيير حرف العلة',
      instructionAr: 'صرّف fahren مع du.',
      reinforcementAr: 'ممتاز — du fährst.',
      infinitive: 'fahren',
      pronoun: 'du',
      sentencePrefix: 'Du',
      sentenceSuffix: 'jeden Morgen zur Arbeit.',
      expectedForm: 'fährst',
    ),
    CaseSelectionDrill(
      id: 'a2-case-mit-bus',
      level: GrammarLevel.a2,
      titleAr: 'Dativ بعد mit',
      instructionAr: 'اختر أداة التعريف الصحيحة بعد mit.',
      reinforcementAr: 'صحيح — mit يأخذ Dativ، لذلك der → dem.',
      targetCase: GrammarCase.dative,
      sentenceBefore: 'Ich fahre mit',
      noun: 'Bus.',
      sentenceAfter: '',
      options: <String>['der', 'den', 'dem'],
      expectedArticle: 'dem',
      explanationAr: 'حرف الجر mit يطلب Dativ دائمًا: der Bus → mit dem Bus.',
    ),
    SentenceReorderExercise(
      id: 'b1-order-obwohl',
      level: GrammarLevel.b1,
      titleAr: 'جملة obwohl',
      instructionAr: 'كوّن الجملة الصحيحة مع obwohl.',
      reinforcementAr: 'ممتاز — حافظت على الفعل في نهاية الجملة الفرعية.',
      translationAr: 'مع أن الجو يمطر، أخرج للمشي.',
      tokens: <GrammarToken>[
        GrammarToken(id: 'b1o1', text: 'Obwohl', role: GrammarTokenRole.connector),
        GrammarToken(id: 'b1o2', text: 'es', role: GrammarTokenRole.subject),
        GrammarToken(id: 'b1o3', text: 'regnet,', role: GrammarTokenRole.verb),
        GrammarToken(id: 'b1o4', text: 'gehe', role: GrammarTokenRole.verb),
        GrammarToken(id: 'b1o5', text: 'ich', role: GrammarTokenRole.subject),
        GrammarToken(id: 'b1o6', text: 'spazieren.', role: GrammarTokenRole.other),
      ],
      correctTokenIds: <String>[
        'b1o1',
        'b1o2',
        'b1o3',
        'b1o4',
        'b1o5',
        'b1o6',
      ],
    ),
    VerbConjugationDrill(
      id: 'b1-verb-werden-er',
      level: GrammarLevel.b1,
      titleAr: 'تصريف werden',
      instructionAr: 'صرّف werden مع er.',
      reinforcementAr: 'صحيح — er wird.',
      infinitive: 'werden',
      pronoun: 'er',
      sentencePrefix: 'Er',
      sentenceSuffix: 'nächste Woche anfangen.',
      expectedForm: 'wird',
    ),
    CaseSelectionDrill(
      id: 'b1-case-mit-kollege',
      level: GrammarLevel.b1,
      titleAr: 'Dativ مع صفة',
      instructionAr: 'اختر أداة التعريف المناسبة.',
      reinforcementAr: 'صحيح — mit dem neuen Kollegen.',
      targetCase: GrammarCase.dative,
      sentenceBefore: 'Wir sprechen mit',
      noun: 'neuen Kollegen.',
      sentenceAfter: '',
      options: <String>['den', 'dem', 'der'],
      expectedArticle: 'dem',
      explanationAr: 'mit يأخذ Dativ؛ الاسم Kollege مذكر: der → dem.',
    ),
  ];

  @override
  List<GrammarDrill> forLevel(GrammarLevel level) =>
      List<GrammarDrill>.unmodifiable(
        _drills.where((drill) => drill.level == level),
      );

  @override
  GrammarDrill? byId(String id) {
    final normalized = id.trim();
    if (normalized.isEmpty) return null;
    for (final drill in _drills) {
      if (drill.id == normalized) return drill;
    }
    return null;
  }
}
