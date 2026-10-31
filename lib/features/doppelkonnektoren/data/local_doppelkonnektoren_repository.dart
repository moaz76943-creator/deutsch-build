import '../domain/doppelkonnektoren_models.dart';
import '../domain/doppelkonnektoren_repository.dart';

final class LocalDoppelkonnektorenRepository
    implements DoppelkonnektorenRepository {
  const LocalDoppelkonnektorenRepository();

  static final List<DoppelConnectorChallengeItem> _bank =
      <DoppelConnectorChallengeItem>[
    DoppelConnectorChallengeItem(
      id: 'je_desto_focus',
      type: DoppelConnectorType.jeDesto,
      topic: DoppelConnectorTopic.productivity,
      sourceIdea:
          'Klare Lernziele verbessern die Effizienz eines Teams.',
      correctSentence:
          'Je klarer die Lernziele sind, desto effizienter arbeitet das Team.',
      arabicTranslation:
          'كلما كانت أهداف التعلم أوضح، عمل الفريق بكفاءة أكبر.',
      arabicExplanation:
          'في je … desto نستخدم عادة صيغة المقارنة Komparativ في الجزأين. بعد je تأتي جملة فرعية ويذهب الفعل المصرف sind إلى نهايتها، بينما تبدأ جملة desto بالعنصر المقارن ثم يأتي الفعل arbeitet في الموقع الثاني.',
    ),
    DoppelConnectorChallengeItem(
      id: 'je_desto_study_review',
      type: DoppelConnectorType.jeDesto,
      topic: DoppelConnectorTopic.studies,
      sourceIdea:
          'Regelmäßige Wiederholung verbessert die langfristige Erinnerung.',
      correctSentence:
          'Je regelmäßiger Lernende wiederholen, desto besser behalten sie neue Inhalte.',
      arabicTranslation:
          'كلما راجع المتعلمون بانتظام أكثر، احتفظوا بالمحتوى الجديد بصورة أفضل.',
      arabicExplanation:
          'je regelmäßiger وdesto besser كلاهما Komparativ. جملة je تضع الفعل wiederholen في النهاية، أما بعد desto فيأتي الفعل behalten في الموقع الثاني.',
    ),
    DoppelConnectorChallengeItem(
      id: 'je_desto_health_sleep',
      type: DoppelConnectorType.jeDesto,
      topic: DoppelConnectorTopic.health,
      sourceIdea:
          'Regelmäßiger Schlaf unterstützt die Konzentration am nächsten Tag.',
      correctSentence:
          'Je regelmäßiger der Schlafrhythmus ist, desto stabiler bleibt die Konzentration am nächsten Tag.',
      arabicTranslation:
          'كلما كان إيقاع النوم أكثر انتظاماً، بقي التركيز في اليوم التالي أكثر استقراراً.',
      arabicExplanation:
          'البناء يربط تغيرين متوازيين: regelmäßiger وstabiler. الفعل ist يقع في نهاية جزء je، وbleibt في الموقع الثاني بعد desto stabiler.',
    ),
    DoppelConnectorChallengeItem(
      id: 'sowohl_study_methods',
      type: DoppelConnectorType.sowohlAlsAuch,
      topic: DoppelConnectorTopic.studies,
      sourceIdea:
          'Eine Studie untersucht Lernzeit und Schlafqualität gemeinsam.',
      correctSentence:
          'Die Studie berücksichtigt sowohl die Lernzeit als auch die Schlafqualität.',
      arabicTranslation:
          'تأخذ الدراسة في الحسبان وقت التعلم وجودة النوم معاً.',
      arabicExplanation:
          'sowohl … als auch يربط عنصرين متوازيين ومثبتين معاً. هنا العنصران اسمان في الموقع النحوي نفسه: die Lernzeit وdie Schlafqualität، لذلك يبقى ترتيب الجملة الرئيسي عادياً.',
    ),
    DoppelConnectorChallengeItem(
      id: 'sowohl_productivity_plan',
      type: DoppelConnectorType.sowohlAlsAuch,
      topic: DoppelConnectorTopic.productivity,
      sourceIdea:
          'Ein Arbeitsplan soll Prioritäten und realistische Pausen enthalten.',
      correctSentence:
          'Ein guter Arbeitsplan enthält sowohl klare Prioritäten als auch realistische Pausen.',
      arabicTranslation:
          'تتضمن خطة العمل الجيدة أولويات واضحة واستراحات واقعية معاً.',
      arabicExplanation:
          'sowohl … als auch يضيف عنصرين من النوع نفسه. klare Prioritäten وrealistische Pausen مفعولان متوازيان ضمن الجملة نفسها، ولا يغيّر الرابط موقع الفعل enthält.',
    ),
    DoppelConnectorChallengeItem(
      id: 'sowohl_science_data',
      type: DoppelConnectorType.sowohlAlsAuch,
      topic: DoppelConnectorTopic.science,
      sourceIdea:
          'Eine belastbare Analyse nutzt quantitative und qualitative Daten.',
      correctSentence:
          'Die Analyse verwendet sowohl quantitative als auch qualitative Daten.',
      arabicTranslation:
          'يستخدم التحليل بيانات كمية ونوعية معاً.',
      arabicExplanation:
          'الرابط ينسق صفتين متوازيتين هما quantitative وqualitative قبل الاسم Daten. يجب الحفاظ على بنية متوازية بعد sowohl وبعد als auch.',
    ),
    DoppelConnectorChallengeItem(
      id: 'weder_science_bias',
      type: DoppelConnectorType.wederNoch,
      topic: DoppelConnectorTopic.science,
      sourceIdea:
          'Die Auswertung findet keinen Messfehler und keinen systematischen Bias.',
      correctSentence:
          'Die Auswertung zeigt weder einen Messfehler noch einen systematischen Bias.',
      arabicTranslation:
          'لا يُظهر التقييم خطأً في القياس ولا انحيازاً منهجياً.',
      arabicExplanation:
          'weder … noch ينفي عنصرين متوازيين دون الحاجة إلى nicht إضافية. einen Messfehler وeinen systematischen Bias كلاهما مفعول به، لذلك تبقى البنية متناظرة.',
    ),
    DoppelConnectorChallengeItem(
      id: 'weder_productivity_overload',
      type: DoppelConnectorType.wederNoch,
      topic: DoppelConnectorTopic.productivity,
      sourceIdea:
          'Das System soll keine unnötigen Meetings und keine doppelten Aufgaben erzeugen.',
      correctSentence:
          'Das System erzeugt weder unnötige Meetings noch doppelte Aufgaben.',
      arabicTranslation:
          'لا ينشئ النظام اجتماعات غير ضرورية ولا مهام مكررة.',
      arabicExplanation:
          'weder … noch ينسق نفي عنصرين على المستوى نفسه. لا نضيف nicht إلى الفعل erzeugt لأن النفي محمول بالفعل على الرابط المزدوج.',
    ),
    DoppelConnectorChallengeItem(
      id: 'weder_health_extremes',
      type: DoppelConnectorType.wederNoch,
      topic: DoppelConnectorTopic.health,
      sourceIdea:
          'Ein nachhaltiger Alltag braucht keine extremen Trainingspläne und keine unrealistischen Schlafziele.',
      correctSentence:
          'Ein nachhaltiger Alltag braucht weder extreme Trainingspläne noch unrealistische Schlafziele.',
      arabicTranslation:
          'لا يحتاج الروتين المستدام إلى خطط تدريب متطرفة ولا إلى أهداف نوم غير واقعية.',
      arabicExplanation:
          'weder … noch ينفي الاسمين المتوازيين extreme Trainingspläne وunrealistische Schlafziele. الفعل braucht يبقى في موقعه الطبيعي في Hauptsatz.',
    ),
  ];

  @override
  Future<List<DoppelConnectorChallengeItem>> getChallenges({
    DoppelConnectorType? type,
  }) async {
    final values = type == null
        ? _bank
        : _bank.where((item) => item.type == type);
    return List<DoppelConnectorChallengeItem>.unmodifiable(values);
  }

  @override
  Future<List<String>> getConnectorOptions(String challengeId) async {
    final challenge = _find(challengeId);
    if (challenge == null) return const <String>[];

    final expected = challenge.type.formula;
    final options = <String>[expected];
    for (final type in DoppelConnectorType.values) {
      if (type.formula != expected) options.add(type.formula);
    }
    return List<String>.unmodifiable(options);
  }

  @override
  Future<bool> validateConnectorPair(
    String challengeId,
    String firstPart,
    String secondPart,
  ) async {
    final challenge = _find(challengeId);
    if (challenge == null) return false;
    return _normalizeToken(firstPart) ==
            _normalizeToken(challenge.type.firstPart) &&
        _normalizeToken(secondPart) ==
            _normalizeToken(challenge.type.secondPart);
  }

  @override
  Future<bool> validateSentence(
    String challengeId,
    String sentence,
  ) async {
    final challenge = _find(challengeId);
    if (challenge == null) return false;
    return _normalizeSentence(sentence) ==
        _normalizeSentence(challenge.correctSentence);
  }

  static DoppelConnectorChallengeItem? _find(String id) {
    final normalizedId = id.trim();
    for (final item in _bank) {
      if (item.id == normalizedId) return item;
    }
    return null;
  }

  static String _normalizeToken(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  static String _normalizeSentence(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(' ,', ',')
        .replaceAll(' .', '.')
        .replaceAll(' ?', '?')
        .replaceAll(' !', '!')
        .replaceAll(RegExp(r'[.!?]+$'), '')
        .trim();
  }
}
