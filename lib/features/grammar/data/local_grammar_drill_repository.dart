import '../../../core/explain_why/deterministic_explain_why_engine.dart';
import '../domain/grammar_drill_models.dart';

final class LocalGrammarDrillRepository implements GrammarDrillRepository {
  LocalGrammarDrillRepository({
    required this.explainWhyEngine,
  });

  @override
  final ExplainWhyEngine explainWhyEngine;

  static GrammarDrillRepository? forDirectedPair({
    required String sourceLocale,
    required String targetLocale,
    required ExplainWhyEngine explainWhyEngine,
  }) {
    final source = _languageCode(sourceLocale);
    final target = _languageCode(targetLocale);
    if (source == 'ar' && target == 'de') {
      return LocalGrammarDrillRepository(
        explainWhyEngine: explainWhyEngine,
      );
    }
    return null;
  }

  static String _languageCode(String locale) =>
      locale.trim().toLowerCase().split(RegExp('[-_]')).first;

  static const List<GrammarDrill> _drills = <GrammarDrill>[
    SentenceReorderExercise(
      id: 'a1-order-heute-deutsch',
      level: GrammarLevel.a1,
      titleAr: 'رتّب الجملة',
      instructionAr: 'رتّب الكلمات لتكوين جملة ألمانية صحيحة.',
      reasonCode: 'grammar.word_order.main_v2',
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
      reasonCode: 'grammar.verb.conjugation',
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
      reasonCode: 'grammar.case.direct_object',
      reasonArguments: <String, String>{'baseArticle': 'der'},
      targetCase: GrammarCase.accusative,
      sentenceBefore: 'Ich kaufe',
      noun: 'Mantel.',
      sentenceAfter: '',
      options: <String>['der', 'den', 'dem'],
      expectedArticle: 'den',
    ),
    SentenceReorderExercise(
      id: 'a2-order-weil',
      level: GrammarLevel.a2,
      titleAr: 'جملة فرعية مع weil',
      instructionAr: 'رتّب الكلمات وانتبه لموقع الفعل في الجملة الفرعية.',
      reasonCode: 'grammar.word_order.subordinate_final',
      reasonArguments: <String, String>{'connector': 'weil'},
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
      reasonCode: 'grammar.verb.conjugation',
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
      reasonCode: 'grammar.case.preposition',
      reasonArguments: <String, String>{
        'preposition': 'mit',
        'baseArticle': 'der',
      },
      targetCase: GrammarCase.dative,
      sentenceBefore: 'Ich fahre mit',
      noun: 'Bus.',
      sentenceAfter: '',
      options: <String>['der', 'den', 'dem'],
      expectedArticle: 'dem',
    ),
    SentenceReorderExercise(
      id: 'b1-order-obwohl',
      level: GrammarLevel.b1,
      titleAr: 'جملة obwohl',
      instructionAr: 'كوّن الجملة الصحيحة مع obwohl.',
      reasonCode: 'grammar.word_order.subordinate_final',
      reasonArguments: <String, String>{'connector': 'obwohl'},
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
      reasonCode: 'grammar.verb.conjugation',
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
      reasonCode: 'grammar.case.preposition',
      reasonArguments: <String, String>{
        'preposition': 'mit',
        'baseArticle': 'der',
      },
      targetCase: GrammarCase.dative,
      sentenceBefore: 'Wir sprechen mit',
      noun: 'neuen Kollegen.',
      sentenceAfter: '',
      options: <String>['den', 'dem', 'der'],
      expectedArticle: 'dem',
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
