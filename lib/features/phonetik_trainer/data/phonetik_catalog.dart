import '../domain/phonetik_models.dart';

abstract final class PhonetikCatalog {
  static const List<PhonetikFocus> focuses = <PhonetikFocus>[
    PhonetikFocus(
      id: 'ich-ach',
      topic: PhonetikTopic.ichAch,
      titleDe: 'ich-Laut / ach-Laut',
      titleAr: 'الفرق بين صوتي ch',
      articulationAr:
          'في ich-Laut [ç] يرتفع وسط اللسان نحو الحنك من دون إغلاق كامل، ويظهر بعد '
          'أصوات أمامية مثل i وe وä وö وü وبعد كثير من الحروف الساكنة. '
          'في ach-Laut [x] يكون الاحتكاك أبعد إلى الخلف بعد أصوات مثل a وo وu وau.',
      examples: <PhonetikExample>[
        PhonetikExample(
          word: 'ich',
          ipa: '[ɪç]',
          hintAr: 'احتكاك أمامي خفيف؛ لا تحوله إلى شين أو كاف.',
        ),
        PhonetikExample(
          word: 'Milch',
          ipa: '[mɪlç]',
          hintAr: 'بعد l يأتي هنا ich-Laut الأمامي.',
        ),
        PhonetikExample(
          word: 'Buch',
          ipa: '[buːx]',
          hintAr: 'بعد u استخدم ach-Laut الخلفي.',
        ),
        PhonetikExample(
          word: 'auch',
          ipa: '[aʊ̯x]',
          hintAr: 'بعد au يأتي ach-Laut الخلفي.',
        ),
      ],
      exercise: PhonetikExercise(
        promptAr: 'أي كلمة تحتوي على ach-Laut [x]؟',
        choices: <String>['ich', 'Milch', 'Buch'],
        correctChoice: 'Buch',
        explanationAr: 'Buch فيها ch بعد u، لذلك الصوت الخلفي [x].',
      ),
    ),
    PhonetikFocus(
      id: 'umlaut-a',
      topic: PhonetikTopic.umlautA,
      titleDe: 'Umlaut ä',
      titleAr: 'نطق ä',
      articulationAr:
          'افتح الفم أقل من a واجعل اللسان إلى الأمام. طول الصوت يتغير بحسب الكلمة، '
          'لذلك ركز على موضع اللسان لا على كتابة الحرف وحدها.',
      examples: <PhonetikExample>[
        PhonetikExample(
          word: 'Käse',
          ipa: '[ˈkɛːzə]',
          hintAr: 'الصوت الأول أمامي وممدود.',
        ),
        PhonetikExample(
          word: 'Hände',
          ipa: '[ˈhɛndə]',
          hintAr: 'الصوت أقصر قبل مجموعة nd.',
        ),
      ],
      exercise: PhonetikExercise(
        promptAr: 'أي كلمة تبدأ بصوت ä الممدود في هذا التدريب؟',
        choices: <String>['Käse', 'Hände', 'Buch'],
        correctChoice: 'Käse',
        explanationAr: 'في Käse ندرّب [ɛː] الممدود.',
      ),
    ),
    PhonetikFocus(
      id: 'umlaut-o',
      topic: PhonetikTopic.umlautO,
      titleDe: 'Umlaut ö',
      titleAr: 'نطق ö',
      articulationAr:
          'ابدأ بوضع اللسان لصوت e ثم دوّر الشفتين كما في o من دون إرجاع اللسان للخلف.',
      examples: <PhonetikExample>[
        PhonetikExample(
          word: 'schön',
          ipa: '[ʃøːn]',
          hintAr: 'شفاه مدوّرة مع لسان أمامي وصوت طويل.',
        ),
        PhonetikExample(
          word: 'öffnen',
          ipa: '[ˈœfnən]',
          hintAr: 'ö هنا أقصر وأكثر انفتاحا.',
        ),
      ],
      exercise: PhonetikExercise(
        promptAr: 'أي كلمة تدرب ö الطويل [øː]؟',
        choices: <String>['öffnen', 'schön', 'grün'],
        correctChoice: 'schön',
        explanationAr: 'schön تحتوي على ö طويل [øː].',
      ),
    ),
    PhonetikFocus(
      id: 'umlaut-u',
      topic: PhonetikTopic.umlautU,
      titleDe: 'Umlaut ü',
      titleAr: 'نطق ü',
      articulationAr:
          'ضع اللسان كما لو أنك ستنطق i، ثم دوّر الشفتين كما في u. لا تحوّل الصوت إلى u خلفية.',
      examples: <PhonetikExample>[
        PhonetikExample(
          word: 'grün',
          ipa: '[ɡʁyːn]',
          hintAr: 'لسان أمامي، شفاه مدوّرة، وصوت طويل.',
        ),
        PhonetikExample(
          word: 'fünf',
          ipa: '[fʏnf]',
          hintAr: 'ü قصيرة مع بقاء اللسان إلى الأمام.',
        ),
      ],
      exercise: PhonetikExercise(
        promptAr: 'أي كلمة تحتوي على ü القصيرة [ʏ]؟',
        choices: <String>['grün', 'fünf', 'schön'],
        correctChoice: 'fünf',
        explanationAr: 'fünf تحتوي على ü قصيرة [ʏ].',
      ),
    ),
    PhonetikFocus(
      id: 'sp-st',
      topic: PhonetikTopic.spSt,
      titleDe: 'sp / st am Wortanfang',
      titleAr: 'sp وst في بداية الكلمة',
      articulationAr:
          'في بداية الكلمة أو المقطع الألمانيين تُنطق sp غالبا [ʃp] وst غالبا [ʃt]. '
          'داخل الكلمة قد تبقى [sp] أو [st]، لذلك راقب موقع المجموعة الصوتية.',
      examples: <PhonetikExample>[
        PhonetikExample(
          word: 'spielen',
          ipa: '[ˈʃpiːlən]',
          hintAr: 'في البداية: sp تصبح [ʃp].',
        ),
        PhonetikExample(
          word: 'Straße',
          ipa: '[ˈʃtʁaːsə]',
          hintAr: 'في البداية: st تصبح [ʃt].',
        ),
        PhonetikExample(
          word: 'Fenster',
          ipa: '[ˈfɛnstɐ]',
          hintAr: 'هنا st داخل الكلمة وتبقى [st].',
        ),
      ],
      exercise: PhonetikExercise(
        promptAr: 'أي كلمة تبدأ بالنطق [ʃt]؟',
        choices: <String>['Fenster', 'Straße', 'Milch'],
        correctChoice: 'Straße',
        explanationAr: 'st في بداية Straße تُنطق [ʃt].',
      ),
    ),
    PhonetikFocus(
      id: 'stress-intonation',
      topic: PhonetikTopic.stressIntonation,
      titleDe: 'Wortakzent & Intonation',
      titleAr: 'نبر الكلمة ونغمة الجملة',
      articulationAr:
          'اجعل المقطع المنبور أوضح وأقوى قليلا من المقاطع المحيطة. '
          'في الجملة الخبرية تميل النغمة إلى الهبوط، بينما يمكن أن ترتفع في سؤال نعم أو لا.',
      examples: <PhonetikExample>[
        PhonetikExample(
          word: 'Arbeit',
          ipa: '[ˈaʁbaɪ̯t]',
          hintAr: 'النبر على المقطع الأول.',
        ),
        PhonetikExample(
          word: 'lernen',
          ipa: '[ˈlɛʁnən]',
          hintAr: 'النبر على المقطع الأول.',
        ),
        PhonetikExample(
          word: 'Guten Morgen. ↘',
          ipa: '[ˈɡuːtn̩ ˈmɔʁɡn̩]',
          hintAr: 'تحية خبرية بنغمة هابطة طبيعية في النهاية.',
        ),
        PhonetikExample(
          word: 'Kommst du morgen? ↗',
          ipa: '[kɔmst duː ˈmɔʁɡn̩]',
          hintAr: 'سؤال نعم أو لا يمكن تدريبه بنغمة صاعدة في النهاية.',
        ),
      ],
      exercise: PhonetikExercise(
        promptAr: 'أين يقع النبر الأساسي في كلمة Arbeit؟',
        choices: <String>['Ar-', '-beit', 'النبر متساوٍ'],
        correctChoice: 'Ar-',
        explanationAr: 'Arbeit تُنطق [ˈaʁbaɪ̯t] والنبر الأساسي على المقطع الأول.',
      ),
    ),
  ];
}
