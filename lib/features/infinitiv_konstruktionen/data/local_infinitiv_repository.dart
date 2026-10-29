import '../domain/infinitiv_models.dart';
import '../domain/infinitiv_repository.dart';

final class LocalInfinitivRepository implements InfinitivRepository {
  static final List<InfinitivChallengeItem> _bank =
      <InfinitivChallengeItem>[
    InfinitivChallengeItem(
      id: 'zu_lernen',
      type: InfinitivClauseType.infinitivMitZu,
      mainClause: 'Ich versuche.',
      infinitivePhrase: 'jeden Tag Deutsch lernen',
      correctConstruction:
          'Ich versuche, jeden Tag Deutsch zu lernen',
      answerOptions: const <String>[
        'Ich versuche, jeden Tag Deutsch zu lernen',
        'Ich versuche, jeden Tag Deutsch lernen zu',
        'Ich versuche, zu jeden Tag Deutsch lernen',
      ],
      arabicTranslation:
          'أحاول أن أتعلم الألمانية كل يوم.',
      ruleExplanationAr:
          'بعد versuchen نستخدم مصدرًا مع zu. في المصدر البسيط تأتي zu مباشرة قبل الفعل: zu lernen.',
      requiresSameSubject: true,
    ),
    InfinitivChallengeItem(
      id: 'zu_schliessen',
      type: InfinitivClauseType.infinitivMitZu,
      mainClause: 'Er hat vergessen.',
      infinitivePhrase: 'die Tür schließen',
      correctConstruction:
          'Er hat vergessen, die Tür zu schließen',
      answerOptions: const <String>[
        'Er hat vergessen, die Tür zu schließen',
        'Er hat vergessen, zu die Tür schließen',
        'Er hat vergessen, die Tür schließen zu',
      ],
      arabicTranslation:
          'لقد نسي أن يغلق الباب.',
      ruleExplanationAr:
          'مع vergessen + Infinitiv يأتي zu قبل المصدر: die Tür zu schließen.',
      requiresSameSubject: true,
    ),
    InfinitivChallengeItem(
      id: 'zu_aufstehen',
      type: InfinitivClauseType.infinitivMitZu,
      mainClause: 'Wir planen.',
      infinitivePhrase: 'morgen früher aufstehen',
      correctConstruction:
          'Wir planen, morgen früher aufzustehen',
      answerOptions: const <String>[
        'Wir planen, morgen früher aufzustehen',
        'Wir planen, morgen früher zu aufstehen',
        'Wir planen, aufzustehen morgen früher',
      ],
      arabicTranslation:
          'نخطط أن نستيقظ أبكر غدًا.',
      ruleExplanationAr:
          'مع الفعل المنفصل aufstehen تدخل zu بين البادئة والفعل: auf + zu + stehen = aufzustehen.',
      requiresSameSubject: true,
    ),
    InfinitivChallengeItem(
      id: 'um_fit_zu_sein',
      type: InfinitivClauseType.umZu,
      mainClause: 'Ich gehe früh ins Bett.',
      infinitivePhrase: 'morgen fit sein',
      correctConstruction:
          'Ich gehe früh ins Bett, um morgen fit zu sein',
      answerOptions: const <String>[
        'Ich gehe früh ins Bett, um morgen fit zu sein',
        'Ich gehe früh ins Bett, weil morgen fit zu sein',
        'Ich gehe früh ins Bett, um zu morgen fit sein',
      ],
      arabicTranslation:
          'أذهب إلى السرير مبكرًا لكي أكون نشيطًا غدًا.',
      ruleExplanationAr:
          'um ... zu تعبّر عن الهدف عندما يكون فاعل الجملتين واحدًا. توضع um في البداية وzu قبل المصدر.',
      requiresSameSubject: true,
    ),
    InfinitivChallengeItem(
      id: 'um_pruefung_zu_bestehen',
      type: InfinitivClauseType.umZu,
      mainClause: 'Sie lernt viel.',
      infinitivePhrase: 'die Prüfung bestehen',
      correctConstruction:
          'Sie lernt viel, um die Prüfung zu bestehen',
      answerOptions: const <String>[
        'Sie lernt viel, um die Prüfung zu bestehen',
        'Sie lernt viel, um zu die Prüfung bestehen',
        'Sie lernt viel, die Prüfung um bestehen zu',
      ],
      arabicTranslation:
          'هي تدرس كثيرًا لكي تنجح في الامتحان.',
      ruleExplanationAr:
          'um ... zu تربط الهدف بالفعل الرئيسي، ولا نكرر الفاعل داخل عبارة المصدر.',
      requiresSameSubject: true,
    ),
    InfinitivChallengeItem(
      id: 'ohne_zu_sagen',
      type: InfinitivClauseType.ohneZu,
      mainClause: 'Er ging weg.',
      infinitivePhrase: 'etwas sagen',
      correctConstruction:
          'Er ging weg, ohne etwas zu sagen',
      answerOptions: const <String>[
        'Er ging weg, ohne etwas zu sagen',
        'Er ging weg, ohne zu etwas sagen',
        'Er ging weg, etwas ohne sagen zu',
      ],
      arabicTranslation:
          'غادر من دون أن يقول شيئًا.',
      ruleExplanationAr:
          'ohne ... zu تعني أن الفعل الثاني لم يحدث، ويكون الفاعل مفهومًا من الجملة الرئيسية.',
      requiresSameSubject: true,
    ),
    InfinitivChallengeItem(
      id: 'ohne_karte_zu_schauen',
      type: InfinitivClauseType.ohneZu,
      mainClause: 'Sie findet den Weg.',
      infinitivePhrase: 'auf die Karte schauen',
      correctConstruction:
          'Sie findet den Weg, ohne auf die Karte zu schauen',
      answerOptions: const <String>[
        'Sie findet den Weg, ohne auf die Karte zu schauen',
        'Sie findet den Weg, ohne zu auf die Karte schauen',
        'Sie findet den Weg, auf die Karte ohne schauen zu',
      ],
      arabicTranslation:
          'تجد الطريق من دون أن تنظر إلى الخريطة.',
      ruleExplanationAr:
          'بعد ohne نضع بقية عناصر العبارة ثم zu + Infinitiv في النهاية: ohne ... zu schauen.',
      requiresSameSubject: true,
    ),
    InfinitivChallengeItem(
      id: 'anstatt_zu_lernen',
      type: InfinitivClauseType.anstattZu,
      mainClause: 'Er spielt Computerspiele.',
      infinitivePhrase: 'für die Prüfung lernen',
      correctConstruction:
          'Er spielt Computerspiele, anstatt für die Prüfung zu lernen',
      answerOptions: const <String>[
        'Er spielt Computerspiele, anstatt für die Prüfung zu lernen',
        'Er spielt Computerspiele, anstatt zu für die Prüfung lernen',
        'Er spielt Computerspiele, für die Prüfung anstatt lernen zu',
      ],
      arabicTranslation:
          'يلعب ألعاب الكمبيوتر بدلًا من أن يدرس للامتحان.',
      ruleExplanationAr:
          'anstatt ... zu تعبّر عن بديل لم يحدث. تأتي anstatt في البداية وzu قبل المصدر.',
      requiresSameSubject: true,
    ),
    InfinitivChallengeItem(
      id: 'anstatt_auto_zu_nehmen',
      type: InfinitivClauseType.anstattZu,
      mainClause: 'Sie geht zu Fuß.',
      infinitivePhrase: 'das Auto nehmen',
      correctConstruction:
          'Sie geht zu Fuß, anstatt das Auto zu nehmen',
      answerOptions: const <String>[
        'Sie geht zu Fuß, anstatt das Auto zu nehmen',
        'Sie geht zu Fuß, anstatt zu das Auto nehmen',
        'Sie geht zu Fuß, das Auto anstatt nehmen zu',
      ],
      arabicTranslation:
          'تذهب مشيًا بدلًا من أن تأخذ السيارة.',
      ruleExplanationAr:
          'مع anstatt ... zu يبقى الفاعل نفسه، ويأتي المصدر مع zu في نهاية المجموعة.',
      requiresSameSubject: true,
    ),
  ];

  @override
  Future<List<InfinitivChallengeItem>> getChallenges({
    InfinitivClauseType? type,
  }) async {
    final result =
        type == null ? _bank : _bank.where((item) => item.type == type);
    return List<InfinitivChallengeItem>.unmodifiable(result);
  }

  @override
  Future<bool> validateAnswer(
    String challengeId,
    String constructedClause,
  ) async {
    final id = challengeId.trim();
    InfinitivChallengeItem? challenge;
    for (final item in _bank) {
      if (item.id == id) {
        challenge = item;
        break;
      }
    }
    if (challenge == null) return false;

    return _normalize(constructedClause) ==
        _normalize(challenge.correctConstruction);
  }

  static String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\s*,\s*'), ', ')
        .replaceAll(RegExp(r'[.!?]+$'), '')
        .trim();
  }
}
