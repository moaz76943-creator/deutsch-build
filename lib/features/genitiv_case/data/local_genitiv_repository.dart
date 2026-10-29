import '../domain/genitiv_models.dart';
import '../domain/genitiv_repository.dart';

final class LocalGenitivRepository implements GenitivRepository {
  static const List<GenitivChallengeItem> _bank =
      <GenitivChallengeItem>[
    GenitivChallengeItem(
      id: 'poss_mann',
      type: GenitivDrillType.possessionArticle,
      sentenceContext: 'Das ist das Fahrrad ___ Mann___.',
      targetNoun: 'Mann',
      gender: GenitivGender.maskulin,
      correctArticle: 'des',
      correctNounSuffix: 'es',
      suffixReasonAr:
          'Mann اسم مذكر قصير وشائع؛ صيغة Genitiv القياسية هنا Mannes بـ -es.',
      arabicTranslation: 'هذه دراجة الرجل.',
      explanationAr:
          'المذكر في Genitiv يأخذ des، والاسم Mann يصبح Mannes: das Fahrrad des Mannes.',
    ),
    GenitivChallengeItem(
      id: 'poss_haus',
      type: GenitivDrillType.possessionArticle,
      sentenceContext: 'Die Farbe ___ Haus___ ist weiß.',
      targetNoun: 'Haus',
      gender: GenitivGender.neutrum,
      correctArticle: 'des',
      correctNounSuffix: 'es',
      suffixReasonAr:
          'Haus محايد وينتهي بصوت s؛ إضافة -es تجعل الصيغة أوضح نطقًا: Hauses.',
      arabicTranslation: 'لون البيت أبيض.',
      explanationAr:
          'المحايد في Genitiv يأخذ des، وHaus يصبح Hauses: die Farbe des Hauses.',
    ),
    GenitivChallengeItem(
      id: 'poss_frau',
      type: GenitivDrillType.possessionArticle,
      sentenceContext: 'Das ist die Tasche ___ Frau.',
      targetNoun: 'Frau',
      gender: GenitivGender.feminin,
      correctArticle: 'der',
      correctNounSuffix: '',
      suffixReasonAr:
          'الأسماء المؤنثة لا تأخذ -s أو -es في Genitiv؛ التغيير يظهر في الأداة der.',
      arabicTranslation: 'هذه حقيبة المرأة.',
      explanationAr:
          'المؤنث في Genitiv يأخذ der بلا لاحقة على الاسم: die Tasche der Frau.',
    ),
    GenitivChallengeItem(
      id: 'poss_eltern',
      type: GenitivDrillType.possessionArticle,
      sentenceContext: 'Das Auto ___ Eltern steht draußen.',
      targetNoun: 'Eltern',
      gender: GenitivGender.plural,
      correctArticle: 'der',
      correctNounSuffix: '',
      suffixReasonAr:
          'الجمع في Genitiv يأخذ der، ولا نضيف -s أو -es إلى الاسم الجمع هنا.',
      arabicTranslation: 'سيارة الوالدين في الخارج.',
      explanationAr:
          'الجمع في Genitiv يأخذ der: das Auto der Eltern.',
    ),
    GenitivChallengeItem(
      id: 'poss_auto',
      type: GenitivDrillType.possessionArticle,
      sentenceContext: 'Die Tür ___ Auto___ ist offen.',
      targetNoun: 'Auto',
      gender: GenitivGender.neutrum,
      correctArticle: 'des',
      correctNounSuffix: 's',
      suffixReasonAr:
          'Auto اسم محايد منتهٍ بحرف صوتي؛ الاستخدام القياسي هنا Autos بـ -s.',
      arabicTranslation: 'باب السيارة مفتوح.',
      explanationAr:
          'المحايد يأخذ des، وAuto يصبح Autos: die Tür des Autos.',
    ),
    GenitivChallengeItem(
      id: 'poss_tisch',
      type: GenitivDrillType.possessionArticle,
      sentenceContext: 'Die Oberfläche ___ Tisch___ ist sauber.',
      targetNoun: 'Tisch',
      gender: GenitivGender.maskulin,
      correctArticle: 'des',
      correctNounSuffix: 'es',
      suffixReasonAr:
          'Tisch اسم مذكر قصير وينتهي بـ -sch؛ -es تعطي الصيغة الطبيعية Tisches.',
      arabicTranslation: 'سطح الطاولة نظيف.',
      explanationAr:
          'المذكر يأخذ des، وTisch يصبح Tisches: die Oberfläche des Tisches.',
    ),
    GenitivChallengeItem(
      id: 'prep_wegen_regen',
      type: GenitivDrillType.genitivPrepositions,
      sentenceContext: '___ ___ Regen___ bleiben wir zu Hause.',
      targetNoun: 'Regen',
      gender: GenitivGender.maskulin,
      correctArticle: 'des',
      correctNounSuffix: 's',
      suffixReasonAr:
          'Regen اسم مذكر؛ صيغة Genitiv الشائعة هي Regens بـ -s.',
      genitivPreposition: 'wegen',
      arabicTranslation: 'بسبب المطر نبقى في المنزل.',
      explanationAr:
          'wegen من حروف جر Genitiv: wegen des Regens.',
    ),
    GenitivChallengeItem(
      id: 'prep_waehrend_pause',
      type: GenitivDrillType.genitivPrepositions,
      sentenceContext: '___ ___ Pause sprechen wir leise.',
      targetNoun: 'Pause',
      gender: GenitivGender.feminin,
      correctArticle: 'der',
      correctNounSuffix: '',
      suffixReasonAr:
          'Pause مؤنث؛ Genitiv المؤنث يستخدم der بلا لاحقة اسمية.',
      genitivPreposition: 'während',
      arabicTranslation: 'أثناء الاستراحة نتحدث بهدوء.',
      explanationAr:
          'während يطلب Genitiv في هذا التدريب: während der Pause.',
    ),
    GenitivChallengeItem(
      id: 'prep_trotz_wetter',
      type: GenitivDrillType.genitivPrepositions,
      sentenceContext: '___ ___ Wetter___ gehen wir spazieren.',
      targetNoun: 'Wetter',
      gender: GenitivGender.neutrum,
      correctArticle: 'des',
      correctNounSuffix: 's',
      suffixReasonAr:
          'Wetter محايد؛ صيغة Genitiv القياسية هنا Wetters بـ -s.',
      genitivPreposition: 'trotz',
      arabicTranslation: 'رغم الطقس نذهب للتنزه.',
      explanationAr:
          'trotz من حروف جر Genitiv: trotz des Wetters.',
    ),
    GenitivChallengeItem(
      id: 'prep_anstatt_antwort',
      type: GenitivDrillType.genitivPrepositions,
      sentenceContext: '___ ___ Antwort kam nur eine Frage.',
      targetNoun: 'Antwort',
      gender: GenitivGender.feminin,
      correctArticle: 'der',
      correctNounSuffix: '',
      suffixReasonAr:
          'Antwort مؤنث؛ نستخدم der ولا نضيف -s أو -es.',
      genitivPreposition: 'anstatt',
      arabicTranslation: 'بدل الإجابة جاء سؤال فقط.',
      explanationAr:
          'anstatt يمكن أن يأتي مع Genitiv: anstatt der Antwort.',
    ),
  ];

  @override
  Future<List<GenitivChallengeItem>> getChallenges({
    GenitivDrillType? type,
  }) async {
    final result = type == null
        ? _bank
        : _bank.where((item) => item.type == type);
    return List<GenitivChallengeItem>.unmodifiable(result);
  }

  @override
  Future<bool> validateAnswer(
    String challengeId, {
    required String chosenArticle,
    required String chosenNounSuffix,
    String? chosenPreposition,
  }) async {
    final normalizedId = challengeId.trim();
    GenitivChallengeItem? challenge;
    for (final item in _bank) {
      if (item.id == normalizedId) {
        challenge = item;
        break;
      }
    }
    if (challenge == null) return false;

    final articleMatches =
        chosenArticle.trim().toLowerCase() == challenge.correctArticle;
    final suffixMatches =
        chosenNounSuffix.trim().toLowerCase() ==
            challenge.correctNounSuffix;

    final prepositionMatches =
        challenge.type == GenitivDrillType.possessionArticle
            ? true
            : chosenPreposition?.trim().toLowerCase() ==
                challenge.genitivPreposition;

    return articleMatches && suffixMatches && prepositionMatches;
  }
}
