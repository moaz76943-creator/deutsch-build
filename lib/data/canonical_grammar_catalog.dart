import '../models/grammar.dart';

abstract final class CanonicalGrammarCatalog {
  static const List<GrammarTopic> allTopics = [
    GrammarTopic(
      id: 'a1_nominativ',
      level: 'A1',
      titleDe: 'Nominativ',
      titleAr: 'حالة الرفع',
      summaryAr: 'حالة الرفع هي الصيغة الأساسية للاسم وتُستخدم عادةً للفاعل.',
      rules: [
        GrammarRule(
          id: 'a1_nominativ_articles',
          title: 'أدوات التعريف في حالة الرفع',
          explanationAr:
              'في Nominativ نستخدم der للمذكر، die للمؤنث والجمع، وdas للمحايد.',
          table: [
            ['Maskulin', 'der'],
            ['Feminin', 'die'],
            ['Neutral', 'das'],
            ['Plural', 'die'],
          ],
        ),
      ],
      miniChecks: [
        MiniCheckQuestion(
          id: 'q_a1_nominativ_1',
          questionText: 'Welcher Artikel steht im Nominativ für maskulin?',
          options: ['der', 'den', 'dem', 'des'],
          correctAnswerIndex: 0,
          explanationAr: '"der" هو أداة التعريف للمذكر في Nominativ.',
        ),
        MiniCheckQuestion(
          id: 'q_a1_nominativ_2',
          questionText: 'Welcher Artikel steht im Nominativ für feminin?',
          options: ['der', 'die', 'das', 'den'],
          correctAnswerIndex: 1,
          explanationAr: '"die" هي أداة التعريف للمؤنث في Nominativ.',
        ),
        MiniCheckQuestion(
          id: 'q_a1_nominativ_3',
          questionText: 'Welcher Artikel steht im Nominativ für neutral?',
          options: ['das', 'der', 'dem', 'den'],
          correctAnswerIndex: 0,
          explanationAr: '"das" هي أداة التعريف للمحايد في Nominativ.',
        ),
      ],
    ),
    GrammarTopic(
      id: 'a1_pronouns',
      level: 'A1',
      titleDe: 'Personalpronomen',
      titleAr: 'الضمائر الشخصية',
      summaryAr:
          'تعرف على الضمائر الشخصية في حالة الرفع وكيفية استخدامها كفاعل في الجملة.',
      rules: [
        GrammarRule(
          id: 'a1_pronouns_nominative',
          title: 'الضمائر في حالة الرفع (Nominativ)',
          explanationAr:
              'تُستخدم الضمائر الشخصية كفاعل في الجملة وتحل محل الاسم.',
          table: [
            ['ich', 'أنا'],
            ['du', 'أنت (مفرد)'],
            ['er', 'هو'],
            ['sie', 'هي'],
            ['es', 'هو/هي للمحايد'],
            ['wir', 'نحن'],
            ['ihr', 'أنتم (جمع)'],
            ['sie', 'هم/هن'],
            ['Sie', 'حضرتك (للاحترام)'],
          ],
          examples: [
            GrammarExample(
              german: 'Ich lerne Deutsch.',
              arabic: 'أنا أتعلم الألمانية.',
            ),
            GrammarExample(german: 'Er ist Lehrer.', arabic: 'هو معلم.'),
          ],
        ),
      ],
      miniChecks: [
        MiniCheckQuestion(
          id: 'q_a1_pronouns_1',
          questionText: 'أي ضمير نستخدمه للاحترام؟',
          options: ['sie', 'Sie', 'ihr'],
          correctAnswerIndex: 1,
          explanationAr:
              'الضمير "Sie" المكتوب بحرف كبير يُستخدم لصيغة الاحترام.',
        ),
        MiniCheckQuestion(
          id: 'q_a1_pronouns_2',
          questionText: 'أكمل الجملة: ___ bin Student.',
          options: ['Er', 'Wir', 'Ich'],
          correctAnswerIndex: 2,
          explanationAr: 'الفعل "bin" يُستخدم مع الضمير "ich".',
        ),
        MiniCheckQuestion(
          id: 'q_a1_pronouns_3',
          questionText: 'ما هو الضمير المقابل لـ "أنتم" الجمع؟',
          options: ['wir', 'ihr', 'du'],
          correctAnswerIndex: 1,
          explanationAr: '"ihr" تعني أنتم للمخاطب الجمع.',
        ),
      ],
    ),
    GrammarTopic(
      id: 'a2_perfekt',
      level: 'A2',
      titleDe: 'Das Perfekt',
      titleAr: 'الماضي التام',
      summaryAr:
          'كيف تتحدث عن الماضي في المحادثات اليومية باستخدام الماضي التام.',
      rules: [
        GrammarRule(
          id: 'a2_perfect_formation',
          title: 'تكوين الماضي التام',
          explanationAr:
              'يتكون الماضي التام من فعل مساعد (haben أو sein) في المركز الثاني، والتصريف الثالث للفعل (Partizip II) في نهاية الجملة.',
          table: [
            ['Subjekt', 'Hilfsverb', '...', 'Partizip II'],
            ['Ich', 'habe', 'einen Apfel', 'gegessen.'],
            ['Er', 'ist', 'nach Hause', 'gegangen.'],
          ],
          examples: [
            GrammarExample(
              german: 'Wir haben gestern Fußball gespielt.',
              arabic: 'لقد لعبنا كرة القدم أمس.',
            ),
            GrammarExample(
              german: 'Sie ist nach Berlin gefahren.',
              arabic: 'لقد سافرت إلى برلين.',
            ),
          ],
        ),
      ],
      miniChecks: [
        MiniCheckQuestion(
          id: 'q_a2_perfect_1',
          questionText: 'أكمل الجملة: Ich ___ ein Buch gelesen.',
          options: ['habe', 'bin', 'ist'],
          correctAnswerIndex: 0,
          explanationAr: 'الفعل lesen يأخذ الفعل المساعد haben.',
        ),
      ],
    ),
    GrammarTopic(
      id: 'b1_relative_clauses',
      level: 'B1',
      titleDe: 'Relativsätze',
      titleAr: 'الجمل الموصولة',
      summaryAr: 'كيف تصف شخصاً أو شيئاً باستخدام جملة موصولة.',
      rules: [
        GrammarRule(
          id: 'b1_relative_pronouns_nominative',
          title: 'ضمائر الوصل في حالة الرفع',
          explanationAr:
              'تطابق ضمائر الوصل الاسم الموصوف في الجنس والعدد. ويكون الفعل المصرف في نهاية الجملة الموصولة.',
          table: [
            ['Maskulin', 'der'],
            ['Feminin', 'die'],
            ['Neutral', 'das'],
            ['Plural', 'die'],
          ],
          examples: [
            GrammarExample(
              german: 'Das ist der Mann, der hier arbeitet.',
              arabic: 'هذا هو الرجل الذي يعمل هنا.',
            ),
            GrammarExample(
              german: 'Die Frau, die dort steht, ist meine Mutter.',
              arabic: 'المرأة التي تقف هناك هي أمي.',
            ),
          ],
        ),
      ],
      miniChecks: [
        MiniCheckQuestion(
          id: 'q_b1_relative_1',
          questionText: 'Das ist das Buch, ___ ich gelesen habe.',
          options: ['der', 'die', 'das'],
          correctAnswerIndex: 2,
          explanationAr: 'كلمة Buch محايد، لذا نستخدم ضمير الوصل das.',
        ),
      ],
    ),
    GrammarTopic(
      id: 'b1_passiv',
      level: 'B1',
      titleDe: 'Das Passiv',
      titleAr: 'المبني للمجهول',
      summaryAr: 'التركيز على الحدث بدلاً من الفاعل باستخدام المبني للمجهول.',
      rules: [
        GrammarRule(
          id: 'b2_passive_present',
          title: 'المبني للمجهول في المضارع',
          explanationAr: 'يتكون من تصريف الفعل werden والتصريف الثالث للفعل.',
          table: [
            ['Subjekt', 'werden', '...', 'Partizip II'],
            ['Das Auto', 'wird', 'heute', 'repariert.'],
          ],
          examples: [
            GrammarExample(
              german: 'Der Brief wird geschrieben.',
              arabic: 'الرسالة تُكتب.',
            ),
          ],
        ),
      ],
      miniChecks: [
        MiniCheckQuestion(
          id: 'q_b2_passive_1',
          questionText: 'Das Haus ___ gebaut.',
          options: ['wird', 'werden', 'worden'],
          correctAnswerIndex: 0,
          explanationAr: 'Das Haus مفرد، لذا نستخدم wird.',
        ),
      ],
    ),
    GrammarTopic(
      id: 'c1_konjunktiv1',
      level: 'C1',
      titleDe: 'Konjunktiv I',
      titleAr: 'صيغة الاحتمال الأولى',
      summaryAr:
          'استخدام Konjunktiv I لنقل الكلام غير المباشر بأسلوب أكاديمي وصحفي.',
      rules: [
        GrammarRule(
          id: 'c1_konjunktiv1_formation',
          title: 'تكوين Konjunktiv I',
          explanationAr:
              'يُشتق من جذر الفعل في حالة المصدر مع إضافة نهايات محددة. يُستخدم بشكل أساسي في الأخبار والتقارير.',
          table: [
            ['ich', 'gehe'],
            ['du', 'gehest'],
            ['er/sie/es', 'gehe'],
            ['wir', 'gehen'],
            ['ihr', 'gehet'],
            ['sie/Sie', 'gehen'],
          ],
          examples: [
            GrammarExample(
              german:
                  'Der Sprecher sagte, der Präsident besuche morgen die Stadt.',
              arabic: 'قال المتحدث إن الرئيس سيزور المدينة غداً.',
            ),
          ],
        ),
      ],
      miniChecks: [
        MiniCheckQuestion(
          id: 'q_c1_konjunktiv1_1',
          questionText: 'Sie behauptet, er ___ krank.',
          options: ['ist', 'sei', 'wäre'],
          correctAnswerIndex: 1,
          explanationAr: 'sei هي صيغة Konjunktiv I من الفعل sein للضمير er.',
        ),
      ],
    ),
    GrammarTopic(
      id: 'c2_nominalization',
      level: 'C2',
      titleDe: 'Nominalisierung',
      titleAr: 'تحويل الأفعال والصفات إلى أسماء',
      summaryAr:
          'استخدام أسلوب التعبير الاسمي في الكتابة الأكاديمية والعلمية المعقدة.',
      rules: [
        GrammarRule(
          id: 'c2_nominalization_verbs',
          title: 'تحويل الأفعال لأسماء',
          explanationAr:
              'يتم غالباً بإضافة النهاية -ung، أو بتحويل الفعل المصدر إلى اسم بوضع أداة das.',
          table: [
            ['Verb', 'Nomen'],
            ['entwickeln', 'die Entwicklung'],
            ['lesen', 'das Lesen'],
          ],
          examples: [
            GrammarExample(
              german:
                  'Die schnelle Entwicklung der Technologie ist faszinierend.',
              arabic: 'التطور السريع للتكنولوجيا مذهل.',
            ),
          ],
        ),
      ],
      miniChecks: [
        MiniCheckQuestion(
          id: 'q_c2_nominalization_1',
          questionText: 'ما هو الاسم المشتق من الفعل "lösen"؟',
          options: ['die Lösung', 'die Lösen', 'der Löser'],
          correctAnswerIndex: 0,
          explanationAr: 'die Lösung تعني الحل وتأتي من lösen.',
        ),
      ],
    ),
    GrammarTopic(
      id: 'b2_konjunktiv2',
      level: 'B2',
      titleDe: 'Konjunktiv II',
      titleAr: 'صيغة الافتراض والتمني',
      summaryAr:
          'تُستخدم للتعبير عن الافتراضات والرغبات غير الواقعية والطلب المهذب.',
      rules: [
        GrammarRule(
          id: 'b2_konjunktiv2_core',
          title: 'Konjunktiv II في الاستعمال',
          explanationAr:
              'توجد صيغ شائعة مثل wäre وhätte، كما تُستخدم würde + Infinitiv كثيرًا.',
          table: [
            ['haben', 'hätte'],
            ['sein', 'wäre'],
            ['Ersatzform', 'würde + Infinitiv'],
          ],
        ),
      ],
      miniChecks: [
        MiniCheckQuestion(
          id: 'q_b2_konjunktiv2_1',
          questionText: 'Wie lautet der Konjunktiv II von "haben" (ich)?',
          options: ['habe', 'hätte', 'hatte', 'hätte gehabt'],
          correctAnswerIndex: 1,
          explanationAr: 'صيغة Konjunktiv II من haben هنا هي hätte.',
        ),
        MiniCheckQuestion(
          id: 'q_b2_konjunktiv2_2',
          questionText: 'Wie lautet der Konjunktiv II von "sein" (ich)?',
          options: ['wäre', 'war', 'bin', 'wurde'],
          correctAnswerIndex: 0,
          explanationAr: 'صيغة Konjunktiv II من sein هنا هي wäre.',
        ),
        MiniCheckQuestion(
          id: 'q_b2_konjunktiv2_3',
          questionText: 'Welche Ersatzform wird häufig verwendet?',
          options: [
            'wäre + Partizip II',
            'würde + Infinitiv',
            'hätte + Infinitiv',
            'wurde + Partizip II',
          ],
          correctAnswerIndex: 1,
          explanationAr: 'تُستخدم صيغة würde + Infinitiv كثيرًا كصيغة بديلة.',
        ),
      ],
    ),
    GrammarTopic(
      id: 'c1_partizipialattribute',
      level: 'C1',
      titleDe: 'Partizipialattribute',
      titleAr: 'صفات اسم الفاعل والمفعول',
      summaryAr: 'سمات موسعة تستخدم Partizip I أو Partizip II قبل الاسم.',
      rules: [
        GrammarRule(
          id: 'c1_partizipialattribute_core',
          title: 'Partizip I وPartizip II كصفة',
          explanationAr:
              'Partizip I يميل إلى معنى متزامن/فاعل، وPartizip II إلى معنى مكتمل أو مفعولي بحسب السياق.',
          table: [
            ['Partizip I', 'lesend'],
            ['Partizip II', 'gelesen'],
          ],
        ),
      ],
      miniChecks: [
        MiniCheckQuestion(
          id: 'q_c1_partizipialattribute_1',
          questionText:
              'Welches Partizip drückt oft Gleichzeitigkeit/Aktiv aus?',
          options: ['Partizip II', 'Partizip I', 'Infinitiv', 'Konjunktiv'],
          correctAnswerIndex: 1,
          explanationAr:
              'Partizip I مثل lesend يعبّر غالبًا عن حدث متزامن وفاعل.',
        ),
        MiniCheckQuestion(
          id: 'q_c1_partizipialattribute_2',
          questionText: 'Wie lautet das Partizip I von "schreiben"?',
          options: ['geschrieben', 'schreibend', 'schrieb', 'schreiben'],
          correctAnswerIndex: 1,
          explanationAr: 'نضيف d إلى المصدر: schreiben → schreibend.',
        ),
      ],
    ),
    GrammarTopic(
      id: 'c2_feste_nomen_verb',
      level: 'C2',
      titleDe: 'Feste Nomen-Verb-Verbindungen',
      titleAr: 'التراكيب الاسمية الفعلية الثابتة',
      summaryAr: 'تراكيب ثابتة من اسم وفعل يجب تعلمها كوحدة دلالية واستعمالية.',
      rules: [
        GrammarRule(
          id: 'c2_feste_nomen_verb_core',
          title: 'Nomen-Verb-Verbindungen',
          explanationAr:
              'لا يمكن استبدال الفعل بحرية دائمًا؛ التركيب الاصطلاحي هو الذي يحدد الاختيار.',
          table: [
            ['eine Entscheidung', 'treffen'],
            ['Abschied', 'nehmen'],
            ['in Frage', 'kommen'],
          ],
        ),
      ],
      miniChecks: [
        MiniCheckQuestion(
          id: 'q_c2_feste_nomen_verb_1',
          questionText: 'Welches Verb passt: "eine Entscheidung ___"?',
          options: ['machen', 'tun', 'treffen', 'geben'],
          correctAnswerIndex: 2,
          explanationAr: 'التعبير الثابت هو eine Entscheidung treffen.',
        ),
        MiniCheckQuestion(
          id: 'q_c2_feste_nomen_verb_2',
          questionText: 'Welches Verb passt: "Abschied ___"?',
          options: ['nehmen', 'machen', 'sagen', 'geben'],
          correctAnswerIndex: 0,
          explanationAr: 'التعبير الثابت هو Abschied nehmen.',
        ),
        MiniCheckQuestion(
          id: 'q_c2_feste_nomen_verb_3',
          questionText: 'Welches Verb passt: "in Frage ___"?',
          options: ['stehen', 'stellen', 'kommen', 'machen'],
          correctAnswerIndex: 2,
          explanationAr: 'in Frage kommen يعني أن يكون ممكنًا أو واردًا.',
        ),
      ],
    ),
  ];
}
