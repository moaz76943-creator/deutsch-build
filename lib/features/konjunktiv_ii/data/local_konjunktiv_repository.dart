import '../domain/konjunktiv_models.dart';
import '../domain/konjunktiv_repository.dart';

final class LocalKonjunktivRepository implements KonjunktivRepository {
  static const List<_KonjunktivRecord> _records = <_KonjunktivRecord>[
    _KonjunktivRecord(
      item: KonjunktivChallengeItem(
        id: 'polite_koennen_sie',
        indicativeSentence: 'Sie bringen mir die Rechnung.',
        konjunktivSentence:
            'Könnten Sie mir bitte die Rechnung bringen?',
        targetVerb: 'können',
        formType: KonjunktivFormType.coreOriginal,
        personalPronoun: 'Sie',
        usage: KonjunktivUsage.politeRequest,
        arabicTranslation:
            'هل يمكن أن تحضر لي الفاتورة من فضلك؟',
        arabicExplanation:
            'könnten هي Konjunktiv II من können مع Sie؛ تجعل الطلب ألطف وأقل مباشرة.',
      ),
      acceptedForms: <String>['könnten'],
      options: <String>[
        'könnten',
        'können',
        'konnten',
        'würden können',
      ],
    ),
    _KonjunktivRecord(
      item: KonjunktivChallengeItem(
        id: 'polite_schliessen_sie',
        indicativeSentence: 'Sie schließen das Fenster.',
        konjunktivSentence:
            'Würden Sie bitte das Fenster schließen?',
        targetVerb: 'schließen',
        formType: KonjunktivFormType.auxiliaryWuerde,
        personalPronoun: 'Sie',
        usage: KonjunktivUsage.politeRequest,
        arabicTranslation:
            'هل تتكرم بإغلاق النافذة من فضلك؟',
        arabicExplanation:
            'würden + Infinitiv مع Sie صيغة شائعة جداً للطلب المؤدب؛ schließen يبقى مصدراً في النهاية.',
      ),
      acceptedForms: <String>['würden schließen'],
      options: <String>[
        'würden schließen',
        'werden schließen',
        'würden geschlossen',
        'schließen',
      ],
    ),
    _KonjunktivRecord(
      item: KonjunktivChallengeItem(
        id: 'polite_geben_sie',
        indicativeSentence: 'Sie geben mir einen Termin.',
        konjunktivSentence:
            'Würden Sie mir bitte einen Termin geben?',
        targetVerb: 'geben',
        formType: KonjunktivFormType.auxiliaryWuerde,
        personalPronoun: 'Sie',
        usage: KonjunktivUsage.politeRequest,
        arabicTranslation:
            'هل تتكرم بإعطائي موعداً من فضلك؟',
        arabicExplanation:
            'würden تحمل علامة Konjunktiv II مع Sie، بينما geben يبقى في صيغة المصدر في نهاية الجملة.',
      ),
      acceptedForms: <String>['würden geben'],
      options: <String>[
        'würden geben',
        'werden geben',
        'würden gegeben',
        'geben',
      ],
    ),
    _KonjunktivRecord(
      item: KonjunktivChallengeItem(
        id: 'polite_helfen_du',
        indicativeSentence: 'Du hilfst mir beim Umzug.',
        konjunktivSentence:
            'Würdest du mir bitte beim Umzug helfen?',
        targetVerb: 'helfen',
        formType: KonjunktivFormType.auxiliaryWuerde,
        personalPronoun: 'du',
        usage: KonjunktivUsage.politeRequest,
        arabicTranslation:
            'هل يمكنك مساعدتي في الانتقال من فضلك؟',
        arabicExplanation:
            'مع du نستخدم würdest، ويأتي المصدر helfen في النهاية؛ الصيغة أخف من الطلب المباشر.',
      ),
      acceptedForms: <String>['würdest helfen'],
      options: <String>[
        'würdest helfen',
        'wirst helfen',
        'würdest geholfen',
        'hilfst',
      ],
    ),
    _KonjunktivRecord(
      item: KonjunktivChallengeItem(
        id: 'polite_bestellen_ich',
        indicativeSentence: 'Ich bestelle einen Kaffee.',
        konjunktivSentence:
            'Ich würde gern einen Kaffee bestellen.',
        targetVerb: 'bestellen',
        formType: KonjunktivFormType.auxiliaryWuerde,
        personalPronoun: 'ich',
        usage: KonjunktivUsage.politeRequest,
        arabicTranslation:
            'أود أن أطلب قهوة.',
        arabicExplanation:
            'würde gern + Infinitiv صياغة طبيعية ومؤدبة للرغبة في المطعم؛ bestellen يبقى مصدراً.',
      ),
      acceptedForms: <String>['würde bestellen'],
      options: <String>[
        'würde bestellen',
        'werde bestellen',
        'würde bestellt',
        'bestelle',
      ],
    ),
    _KonjunktivRecord(
      item: KonjunktivChallengeItem(
        id: 'polite_bezahlen_ich',
        indicativeSentence: 'Ich bezahle mit Karte.',
        konjunktivSentence:
            'Ich würde gern mit Karte bezahlen.',
        targetVerb: 'bezahlen',
        formType: KonjunktivFormType.auxiliaryWuerde,
        personalPronoun: 'ich',
        usage: KonjunktivUsage.politeRequest,
        arabicTranslation:
            'أود أن أدفع بالبطاقة.',
        arabicExplanation:
            'würde gern يخفف النبرة ويحوّل التصريح المباشر إلى طلب أو رغبة مهذبة؛ bezahlen مصدر في النهاية.',
      ),
      acceptedForms: <String>['würde bezahlen'],
      options: <String>[
        'würde bezahlen',
        'werde bezahlen',
        'würde bezahlt',
        'bezahle',
      ],
    ),
    _KonjunktivRecord(
      item: KonjunktivChallengeItem(
        id: 'advice_sollen_du',
        indicativeSentence: 'Du schläfst sehr wenig.',
        konjunktivSentence: 'Du solltest mehr schlafen.',
        targetVerb: 'sollen',
        formType: KonjunktivFormType.coreOriginal,
        personalPronoun: 'du',
        usage: KonjunktivUsage.advice,
        arabicTranslation:
            'ينبغي أن تنام أكثر.',
        arabicExplanation:
            'solltest هي Konjunktiv II من sollen مع du، وتستعمل كثيراً لإعطاء نصيحة دون أمر مباشر.',
      ),
      acceptedForms: <String>['solltest'],
      options: <String>[
        'solltest',
        'sollst',
        'solltestest',
        'würdest sollen',
      ],
    ),
    _KonjunktivRecord(
      item: KonjunktivChallengeItem(
        id: 'advice_schlafen_ich',
        indicativeSentence: 'Du schläfst zu wenig.',
        konjunktivSentence:
            'An deiner Stelle würde ich mehr schlafen.',
        targetVerb: 'schlafen',
        formType: KonjunktivFormType.auxiliaryWuerde,
        personalPronoun: 'ich',
        usage: KonjunktivUsage.advice,
        arabicTranslation:
            'لو كنت مكانك لنمت أكثر.',
        arabicExplanation:
            'An deiner Stelle + würde ich + Infinitiv صيغة نصيحة افتراضية؛ schlafen يبقى مصدراً.',
      ),
      acceptedForms: <String>['würde schlafen'],
      options: <String>[
        'würde schlafen',
        'werde schlafen',
        'würde geschlafen',
        'schlafe',
      ],
    ),
    _KonjunktivRecord(
      item: KonjunktivChallengeItem(
        id: 'advice_lernen_ich',
        indicativeSentence: 'Du lernst nur vor der Prüfung.',
        konjunktivSentence:
            'An deiner Stelle würde ich jeden Tag etwas lernen.',
        targetVerb: 'lernen',
        formType: KonjunktivFormType.auxiliaryWuerde,
        personalPronoun: 'ich',
        usage: KonjunktivUsage.advice,
        arabicTranslation:
            'لو كنت مكانك لدرست شيئاً كل يوم.',
        arabicExplanation:
            'würde ich ... lernen تعرض النصيحة كافتراض شخصي بدلاً من إعطاء أمر مباشر.',
      ),
      acceptedForms: <String>['würde lernen'],
      options: <String>[
        'würde lernen',
        'werde lernen',
        'würde gelernt',
        'lerne',
      ],
    ),
    _KonjunktivRecord(
      item: KonjunktivChallengeItem(
        id: 'advice_sprechen_ich',
        indicativeSentence: 'Du sprichst selten Deutsch.',
        konjunktivSentence:
            'An deiner Stelle würde ich öfter Deutsch sprechen.',
        targetVerb: 'sprechen',
        formType: KonjunktivFormType.auxiliaryWuerde,
        personalPronoun: 'ich',
        usage: KonjunktivUsage.advice,
        arabicTranslation:
            'لو كنت مكانك لتحدثت الألمانية أكثر.',
        arabicExplanation:
            'في النصيحة الافتراضية نصرف würde مع ich، بينما sprechen يأتي كمصدر في النهاية.',
      ),
      acceptedForms: <String>['würde sprechen'],
      options: <String>[
        'würde sprechen',
        'werde sprechen',
        'würde gesprochen',
        'spreche',
      ],
    ),
    _KonjunktivRecord(
      item: KonjunktivChallengeItem(
        id: 'advice_machen_ich',
        indicativeSentence: 'Du arbeitest ohne Pause.',
        konjunktivSentence:
            'An deiner Stelle würde ich regelmäßig eine Pause machen.',
        targetVerb: 'machen',
        formType: KonjunktivFormType.auxiliaryWuerde,
        personalPronoun: 'ich',
        usage: KonjunktivUsage.advice,
        arabicTranslation:
            'لو كنت مكانك لأخذت استراحة بانتظام.',
        arabicExplanation:
            'würde + machen تبني نصيحة افتراضية؛ علامة الزمن والمودال على würde والمصدر في النهاية.',
      ),
      acceptedForms: <String>['würde machen'],
      options: <String>[
        'würde machen',
        'werde machen',
        'würde gemacht',
        'mache',
      ],
    ),
    _KonjunktivRecord(
      item: KonjunktivChallengeItem(
        id: 'advice_gehen_ich',
        indicativeSentence: 'Du gehst sehr spät ins Bett.',
        konjunktivSentence:
            'An deiner Stelle würde ich früher ins Bett gehen.',
        targetVerb: 'gehen',
        formType: KonjunktivFormType.auxiliaryWuerde,
        personalPronoun: 'ich',
        usage: KonjunktivUsage.advice,
        arabicTranslation:
            'لو كنت مكانك لذهبت إلى السرير أبكر.',
        arabicExplanation:
            'würde ich ... gehen تجعل النصيحة أقل مباشرة؛ gehen مصدر ولا يُصرف هنا.',
      ),
      acceptedForms: <String>['würde gehen'],
      options: <String>[
        'würde gehen',
        'werde gehen',
        'würde gegangen',
        'gehe',
      ],
    ),
    _KonjunktivRecord(
      item: KonjunktivChallengeItem(
        id: 'wish_sein_ich',
        indicativeSentence: 'Ich bin nicht am Meer.',
        konjunktivSentence: 'Ich wäre gern am Meer.',
        targetVerb: 'sein',
        formType: KonjunktivFormType.coreOriginal,
        personalPronoun: 'ich',
        usage: KonjunktivUsage.unrealWish,
        arabicTranslation:
            'ليتني كنت عند البحر.',
        arabicExplanation:
            'wäre هي الصيغة الأصلية الشائعة لـ sein في Konjunktiv II، وتعبّر هنا عن واقع مرغوب لكنه غير حاصل.',
      ),
      acceptedForms: <String>['wäre'],
      options: <String>[
        'wäre',
        'war',
        'bin',
        'würde sein',
      ],
    ),
    _KonjunktivRecord(
      item: KonjunktivChallengeItem(
        id: 'wish_haben_ich',
        indicativeSentence: 'Ich habe kein eigenes Zimmer.',
        konjunktivSentence:
            'Ich hätte gern ein eigenes Zimmer.',
        targetVerb: 'haben',
        formType: KonjunktivFormType.coreOriginal,
        personalPronoun: 'ich',
        usage: KonjunktivUsage.unrealWish,
        arabicTranslation:
            'أتمنى لو كان لدي غرفة خاصة.',
        arabicExplanation:
            'hätte هي Konjunktiv II الأصلية من haben؛ مع gern تصبح صيغة رغبة شائعة وطبيعية.',
      ),
      acceptedForms: <String>['hätte'],
      options: <String>[
        'hätte',
        'hatte',
        'habe',
        'würde haben',
      ],
    ),
    _KonjunktivRecord(
      item: KonjunktivChallengeItem(
        id: 'wish_koennen_ich',
        indicativeSentence:
            'Ich kann heute nicht länger bleiben.',
        konjunktivSentence:
            'Ich wünschte, ich könnte heute länger bleiben.',
        targetVerb: 'können',
        formType: KonjunktivFormType.coreOriginal,
        personalPronoun: 'ich',
        usage: KonjunktivUsage.unrealWish,
        arabicTranslation:
            'ليتني أستطيع البقاء مدة أطول اليوم.',
        arabicExplanation:
            'könnte هي Konjunktiv II من können مع ich؛ تصف قدرة مرغوبة لكنها غير متاحة في الواقع الحالي.',
      ),
      acceptedForms: <String>['könnte'],
      options: <String>[
        'könnte',
        'kann',
        'konnte',
        'würde können',
      ],
    ),
    _KonjunktivRecord(
      item: KonjunktivChallengeItem(
        id: 'wish_bleiben_ich',
        indicativeSentence: 'Ich muss früh gehen.',
        konjunktivSentence: 'Ich würde gern länger bleiben.',
        targetVerb: 'bleiben',
        formType: KonjunktivFormType.auxiliaryWuerde,
        personalPronoun: 'ich',
        usage: KonjunktivUsage.unrealWish,
        arabicTranslation:
            'كنت أود أن أبقى مدة أطول.',
        arabicExplanation:
            'würde gern + bleiben تعبّر عن رغبة غير محققة أو غير مؤكدة؛ bleiben يبقى مصدراً.',
      ),
      acceptedForms: <String>['würde bleiben'],
      options: <String>[
        'würde bleiben',
        'werde bleiben',
        'würde geblieben',
        'bleibe',
      ],
    ),
    _KonjunktivRecord(
      item: KonjunktivChallengeItem(
        id: 'wish_wohnen_ich',
        indicativeSentence: 'Ich wohne nicht in Berlin.',
        konjunktivSentence:
            'Ich würde gern in Berlin wohnen.',
        targetVerb: 'wohnen',
        formType: KonjunktivFormType.auxiliaryWuerde,
        personalPronoun: 'ich',
        usage: KonjunktivUsage.unrealWish,
        arabicTranslation:
            'أود لو كنت أعيش في برلين.',
        arabicExplanation:
            'würde + wohnen تعرض السكن كرغبة أو تصور غير مطابق للواقع الحالي.',
      ),
      acceptedForms: <String>['würde wohnen'],
      options: <String>[
        'würde wohnen',
        'werde wohnen',
        'würde gewohnt',
        'wohne',
      ],
    ),
    _KonjunktivRecord(
      item: KonjunktivChallengeItem(
        id: 'hypothetical_reisen_ich',
        indicativeSentence:
            'Ich reise selten, weil ich wenig Urlaub habe.',
        konjunktivSentence:
            'Wenn ich mehr Urlaub hätte, würde ich öfter reisen.',
        targetVerb: 'reisen',
        formType: KonjunktivFormType.auxiliaryWuerde,
        personalPronoun: 'ich',
        usage: KonjunktivUsage.hypotheticalCondition,
        arabicTranslation:
            'لو كان لدي إجازة أكثر، لسافرت أكثر.',
        arabicExplanation:
            'في الشرط غير الواقعي نستخدم hätte في جملة wenn، ثم würde + Infinitiv في النتيجة: würde ... reisen.',
      ),
      acceptedForms: <String>['würde reisen'],
      options: <String>[
        'würde reisen',
        'werde reisen',
        'würde gereist',
        'reise',
      ],
    ),
    _KonjunktivRecord(
      item: KonjunktivChallengeItem(
        id: 'hypothetical_kaufen_ich',
        indicativeSentence:
            'Ich kaufe das Fahrrad nicht, weil es zu teuer ist.',
        konjunktivSentence:
            'Wenn es günstiger wäre, würde ich das Fahrrad kaufen.',
        targetVerb: 'kaufen',
        formType: KonjunktivFormType.auxiliaryWuerde,
        personalPronoun: 'ich',
        usage: KonjunktivUsage.hypotheticalCondition,
        arabicTranslation:
            'لو كان أرخص، لاشتريت الدراجة.',
        arabicExplanation:
            'wäre يضع الشرط خارج الواقع الحالي، وwürde + kaufen يصوغ النتيجة الافتراضية.',
      ),
      acceptedForms: <String>['würde kaufen'],
      options: <String>[
        'würde kaufen',
        'werde kaufen',
        'würde gekauft',
        'kaufe',
      ],
    ),
    _KonjunktivRecord(
      item: KonjunktivChallengeItem(
        id: 'hypothetical_kommen_ich',
        indicativeSentence:
            'Ich komme nicht, weil ich arbeiten muss.',
        konjunktivSentence:
            'Wenn ich nicht arbeiten müsste, würde ich kommen.',
        targetVerb: 'kommen',
        formType: KonjunktivFormType.auxiliaryWuerde,
        personalPronoun: 'ich',
        usage: KonjunktivUsage.hypotheticalCondition,
        arabicTranslation:
            'لو لم أكن مضطراً للعمل، لأتيت.',
        arabicExplanation:
            'müsste يغيّر ضرورة العمل إلى افتراض، والنتيجة تأتي مع würde ich kommen.',
      ),
      acceptedForms: <String>['würde kommen'],
      options: <String>[
        'würde kommen',
        'werde kommen',
        'würde gekommen',
        'komme',
      ],
    ),
    _KonjunktivRecord(
      item: KonjunktivChallengeItem(
        id: 'hypothetical_nehmen_er',
        indicativeSentence:
            'Er nimmt das Taxi, weil der Zug zu spät kommt.',
        konjunktivSentence:
            'Wenn der Zug pünktlich käme, würde er den Zug nehmen.',
        targetVerb: 'nehmen',
        formType: KonjunktivFormType.auxiliaryWuerde,
        personalPronoun: 'er',
        usage: KonjunktivUsage.hypotheticalCondition,
        arabicTranslation:
            'لو وصل القطار في موعده، لركب القطار.',
        arabicExplanation:
            'جملة الشرط افتراضية، والنتيجة مع er تُبنى بـ würde + nehmen.',
      ),
      acceptedForms: <String>['würde nehmen'],
      options: <String>[
        'würde nehmen',
        'wird nehmen',
        'würde genommen',
        'nimmt',
      ],
    ),
    _KonjunktivRecord(
      item: KonjunktivChallengeItem(
        id: 'hypothetical_arbeiten_ich',
        indicativeSentence:
            'Ich arbeite Vollzeit, deshalb habe ich wenig Freizeit.',
        konjunktivSentence:
            'Wenn ich weniger arbeiten würde, hätte ich mehr Freizeit.',
        targetVerb: 'arbeiten',
        formType: KonjunktivFormType.auxiliaryWuerde,
        personalPronoun: 'ich',
        usage: KonjunktivUsage.hypotheticalCondition,
        arabicTranslation:
            'لو كنت أعمل أقل، لكان لدي وقت فراغ أكثر.',
        arabicExplanation:
            'arbeiten فعل عادي؛ لذلك صيغة würde + Infinitiv طبيعية: arbeiten würde داخل جملة wenn.',
      ),
      acceptedForms: <String>['würde arbeiten'],
      options: <String>[
        'würde arbeiten',
        'werde arbeiten',
        'würde gearbeitet',
        'arbeite',
      ],
    ),
    _KonjunktivRecord(
      item: KonjunktivChallengeItem(
        id: 'hypothetical_muessen_ich',
        indicativeSentence: 'Ich muss morgen arbeiten.',
        konjunktivSentence:
            'Wenn ich morgen nicht arbeiten müsste, würde ich mitkommen.',
        targetVerb: 'müssen',
        formType: KonjunktivFormType.coreOriginal,
        personalPronoun: 'ich',
        usage: KonjunktivUsage.hypotheticalCondition,
        arabicTranslation:
            'لو لم أكن مضطراً للعمل غداً، لأتيت معكم.',
        arabicExplanation:
            'müsste هي الصيغة الأصلية الشائعة لـ müssen في Konjunktiv II، وتحوّل الإلزام إلى افتراض غير واقع.',
      ),
      acceptedForms: <String>['müsste'],
      options: <String>[
        'müsste',
        'muss',
        'musste',
        'würde müssen',
      ],
    ),
    _KonjunktivRecord(
      item: KonjunktivChallengeItem(
        id: 'hypothetical_sagen_ich',
        indicativeSentence:
            'Ich sage ihm nichts, weil ich unsicher bin.',
        konjunktivSentence:
            'Wenn ich sicher wäre, würde ich ihm die Wahrheit sagen.',
        targetVerb: 'sagen',
        formType: KonjunktivFormType.auxiliaryWuerde,
        personalPronoun: 'ich',
        usage: KonjunktivUsage.hypotheticalCondition,
        arabicTranslation:
            'لو كنت متأكداً، لقلت له الحقيقة.',
        arabicExplanation:
            'wäre يحدد الشرط الافتراضي، وwürde + sagen يصوغ النتيجة التي لم تحدث.',
      ),
      acceptedForms: <String>['würde sagen'],
      options: <String>[
        'würde sagen',
        'werde sagen',
        'würde gesagt',
        'sage',
      ],
    ),
  ];

  @override
  Future<List<KonjunktivChallengeItem>> getChallenges({
    KonjunktivUsage? usage,
  }) async {
    final items = usage == null
        ? _records
        : _records.where((record) => record.item.usage == usage);
    return List<KonjunktivChallengeItem>.unmodifiable(
      items.map((record) => record.item),
    );
  }

  @override
  Future<List<String>> getAnswerOptions(String challengeId) async {
    final record = _recordFor(challengeId);
    if (record == null) return const <String>[];
    return List<String>.unmodifiable(record.options);
  }

  @override
  Future<bool> validateConjugation(
    String challengeId,
    String conjugatedForm,
  ) async {
    final record = _recordFor(challengeId);
    if (record == null) return false;
    final submitted = _normalizeForm(conjugatedForm);
    return record.acceptedForms
        .map(_normalizeForm)
        .contains(submitted);
  }

  @override
  Future<bool> validateSentence(
    String challengeId,
    String constructedSentence,
  ) async {
    final record = _recordFor(challengeId);
    if (record == null) return false;
    return _normalizeSentence(constructedSentence) ==
        _normalizeSentence(record.item.konjunktivSentence);
  }

  static _KonjunktivRecord? _recordFor(String challengeId) {
    final id = challengeId.trim();
    for (final record in _records) {
      if (record.item.id == id) return record;
    }
    return null;
  }

  static String _normalizeForm(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String _normalizeSentence(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('„', '"')
        .replaceAll('“', '"')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\s+([,;:!?])'), r'$1')
        .replaceAll(RegExp(r'[.!?]+$'), '')
        .trim();
  }
}

final class _KonjunktivRecord {
  const _KonjunktivRecord({
    required this.item,
    required this.acceptedForms,
    required this.options,
  });

  final KonjunktivChallengeItem item;
  final List<String> acceptedForms;
  final List<String> options;
}
