import '../domain/placement_models.dart';
import '../domain/placement_repository.dart';

final class LocalPlacementRepository implements PlacementRepository {
  const LocalPlacementRepository();

  static final List<PlacementQuestionItem> _questionBank =
      <PlacementQuestionItem>[
    PlacementQuestionItem(
      id: 'a1_grammar_present',
      question: 'Ich ___ aus Jordanien.',
      options: <String>['komme', 'kommt', 'kommen'],
      correctAnswerIndex: 0,
      targetLevel: CefrLevel.a1,
      difficultyWeight: .65,
      skill: AssessmentSkillCategory.grammar,
      arabicExplanation:
          'مع الضمير ich يُصرّف الفعل kommen إلى komme في المضارع.',
    ),
    PlacementQuestionItem(
      id: 'a1_vocab_billig',
      question: 'Welches Wort passt zu „nicht teuer“?',
      options: <String>['billig', 'langsam', 'spät'],
      correctAnswerIndex: 0,
      targetLevel: CefrLevel.a1,
      difficultyWeight: .70,
      skill: AssessmentSkillCategory.vocabulary,
      arabicExplanation:
          'billig تعني رخيص، وهي المعنى المباشر لعبارة nicht teuer.',
    ),
    PlacementQuestionItem(
      id: 'a1_reading_time',
      question:
          'Lena arbeitet bis 16 Uhr. Um 17 Uhr trifft sie Sara. Wann trifft Lena Sara?',
      options: <String>['Um 15 Uhr', 'Um 16 Uhr', 'Um 17 Uhr'],
      correctAnswerIndex: 2,
      targetLevel: CefrLevel.a1,
      difficultyWeight: .75,
      skill: AssessmentSkillCategory.readingComprehension,
      arabicExplanation:
          'النص يذكر صراحة أن موعد لقاء Lena مع Sara هو الساعة 17.',
    ),
    PlacementQuestionItem(
      id: 'a1_practical_cafe',
      question: 'Im Café möchtest du Wasser. Was passt am besten?',
      options: <String>[
        'Ein Wasser, bitte.',
        'Ich Wasser.',
        'Wasser ist gestern.',
      ],
      correctAnswerIndex: 0,
      targetLevel: CefrLevel.a1,
      difficultyWeight: .80,
      skill: AssessmentSkillCategory.practicalContext,
      arabicExplanation:
          'Ein Wasser, bitte صيغة يومية سليمة ومباشرة للطلب في المقهى.',
    ),
    PlacementQuestionItem(
      id: 'a2_grammar_weil',
      question: 'Ich bleibe zu Hause, weil ich krank ___.',
      options: <String>['bin', 'bist', 'sein'],
      correctAnswerIndex: 0,
      targetLevel: CefrLevel.a2,
      difficultyWeight: 1.00,
      skill: AssessmentSkillCategory.grammar,
      arabicExplanation:
          'بعد weil يأتي الفعل المصرف في نهاية الجملة الفرعية؛ مع ich تكون الصيغة bin.',
    ),
    PlacementQuestionItem(
      id: 'a2_vocab_verschieben',
      question: 'Was bedeutet „einen Termin verschieben“?',
      options: <String>[
        'Einen Termin auf eine andere Zeit legen',
        'Einen Termin vergessen',
        'Einen Termin sofort beenden',
      ],
      correctAnswerIndex: 0,
      targetLevel: CefrLevel.a2,
      difficultyWeight: .95,
      skill: AssessmentSkillCategory.vocabulary,
      arabicExplanation:
          'verschieben يعني نقل الموعد إلى وقت آخر، وليس إلغاءه أو نسيانه.',
    ),
    PlacementQuestionItem(
      id: 'a2_reading_train',
      question:
          'Der Zug nach Köln fährt heute nicht um 14:10, sondern um 14:40. Was stimmt?',
      options: <String>[
        'Der Zug fährt dreißig Minuten später.',
        'Der Zug fährt dreißig Minuten früher.',
        'Der Zug fällt aus.',
      ],
      correctAnswerIndex: 0,
      targetLevel: CefrLevel.a2,
      difficultyWeight: 1.05,
      skill: AssessmentSkillCategory.readingComprehension,
      arabicExplanation:
          'الفرق بين 14:10 و14:40 هو ثلاثون دقيقة تأخير.',
    ),
    PlacementQuestionItem(
      id: 'a2_practical_appointment',
      question:
          'Du kannst morgen nicht zum Termin kommen. Welche Nachricht passt?',
      options: <String>[
        'Könnten wir den Termin bitte verschieben?',
        'Termin morgen nein.',
        'Sie müssen warten gestern.',
      ],
      correctAnswerIndex: 0,
      targetLevel: CefrLevel.a2,
      difficultyWeight: 1.10,
      skill: AssessmentSkillCategory.practicalContext,
      arabicExplanation:
          'Könnten wir ... bitte صيغة مهذبة وطبيعية لطلب تغيير الموعد.',
    ),
    PlacementQuestionItem(
      id: 'b1_grammar_obwohl',
      question: 'Welche Form ist richtig?',
      options: <String>[
        'Obwohl es regnet, gehe ich spazieren.',
        'Obwohl es regnet, ich gehe spazieren.',
        'Obwohl es regnen, gehe ich spazieren.',
      ],
      correctAnswerIndex: 0,
      targetLevel: CefrLevel.b1,
      difficultyWeight: 1.20,
      skill: AssessmentSkillCategory.grammar,
      arabicExplanation:
          'في جملة obwohl يذهب الفعل إلى النهاية، وبعد الجملة الفرعية يبدأ Hauptsatz بالفعل ثم الفاعل.',
    ),
    PlacementQuestionItem(
      id: 'b1_vocab_zuverlaessig',
      question: 'Eine zuverlässige Person ...',
      options: <String>[
        'hält Absprachen normalerweise ein.',
        'kommt absichtlich immer zu spät.',
        'ändert ständig ihre Meinung ohne Grund.',
      ],
      correctAnswerIndex: 0,
      targetLevel: CefrLevel.b1,
      difficultyWeight: 1.15,
      skill: AssessmentSkillCategory.vocabulary,
      arabicExplanation:
          'zuverlässig تصف الشخص الذي يمكن الاعتماد عليه ويلتزم عادة بما اتُّفق عليه.',
    ),
    PlacementQuestionItem(
      id: 'b1_reading_homeoffice',
      question:
          'Mara arbeitet zwei Tage pro Woche zu Hause. An den anderen Tagen fährt sie ins Büro. Welche Aussage stimmt?',
      options: <String>[
        'Mara arbeitet teilweise im Homeoffice.',
        'Mara arbeitet nie im Büro.',
        'Mara arbeitet nur am Wochenende.',
      ],
      correctAnswerIndex: 0,
      targetLevel: CefrLevel.b1,
      difficultyWeight: 1.25,
      skill: AssessmentSkillCategory.readingComprehension,
      arabicExplanation:
          'العمل يومين من المنزل وبقية الأيام من المكتب يعني نظاماً جزئياً للعمل من المنزل.',
    ),
    PlacementQuestionItem(
      id: 'b1_practical_complaint',
      question:
          'Ein bestelltes Gerät ist beschädigt. Welche E-Mail-Formulierung passt?',
      options: <String>[
        'Ich möchte Sie bitten, das beschädigte Gerät umzutauschen.',
        'Du gibst neues Gerät sofort.',
        'Gerät kaputt, machen Sie.',
      ],
      correctAnswerIndex: 0,
      targetLevel: CefrLevel.b1,
      difficultyWeight: 1.30,
      skill: AssessmentSkillCategory.practicalContext,
      arabicExplanation:
          'Ich möchte Sie bitten ... صياغة رسمية مهذبة ومناسبة لطلب الاستبدال في رسالة خدمة عملاء.',
    ),
    PlacementQuestionItem(
      id: 'b2_grammar_nachdem',
      question:
          'Nachdem sie den Bericht vollständig gelesen ___, schrieb sie die Zusammenfassung.',
      options: <String>['hatte', 'hätte', 'hat'],
      correctAnswerIndex: 0,
      targetLevel: CefrLevel.b2,
      difficultyWeight: 1.50,
      skill: AssessmentSkillCategory.grammar,
      arabicExplanation:
          'عندما يسبق حدثٌ ماضياً حدثاً آخر في الماضي، يستخدم Plusquamperfekt هنا: gelesen hatte.',
    ),
    PlacementQuestionItem(
      id: 'b2_vocab_erwaegen',
      question: '„Etwas in Betracht ziehen“ bedeutet ...',
      options: <String>[
        'etwas ernsthaft erwägen.',
        'etwas endgültig ablehnen.',
        'etwas zufällig vergessen.',
      ],
      correctAnswerIndex: 0,
      targetLevel: CefrLevel.b2,
      difficultyWeight: 1.55,
      skill: AssessmentSkillCategory.vocabulary,
      arabicExplanation:
          'in Betracht ziehen تعني أخذ الخيار بعين الاعتبار أو التفكير فيه بجدية، أي erwägen.',
    ),
    PlacementQuestionItem(
      id: 'b2_reading_mobility',
      question:
          'Die Stadt erweitert den Nahverkehr, obwohl die Fahrgastzahlen zuletzt stagnierten. Sie erwartet langfristig weniger Autoverkehr. Welche Schlussfolgerung ist am plausibelsten?',
      options: <String>[
        'Die Investition verfolgt ein langfristiges verkehrspolitisches Ziel.',
        'Die Stadt will den Nahverkehr kurzfristig abschaffen.',
        'Die Fahrgastzahlen steigen bereits stark.',
      ],
      correctAnswerIndex: 0,
      targetLevel: CefrLevel.b2,
      difficultyWeight: 1.60,
      skill: AssessmentSkillCategory.readingComprehension,
      arabicExplanation:
          'رغم ركود الأعداد حالياً، تتوقع المدينة تقليل السيارات مستقبلاً؛ إذن الهدف استراتيجي طويل المدى.',
    ),
    PlacementQuestionItem(
      id: 'b2_practical_register',
      question:
          'Du brauchst von einer Behörde eine schriftliche Rückmeldung. Welche Formulierung ist angemessen?',
      options: <String>[
        'Ich wäre Ihnen dankbar, wenn Sie mir die Auskunft schriftlich bestätigen könnten.',
        'Schicken Sie das jetzt, sonst ist es schlecht.',
        'Ich will Antwort. Sofort.',
      ],
      correctAnswerIndex: 0,
      targetLevel: CefrLevel.b2,
      difficultyWeight: 1.65,
      skill: AssessmentSkillCategory.practicalContext,
      arabicExplanation:
          'الصياغة الأولى تحافظ على سجل رسمي مهذب وتستخدم Konjunktiv II لتخفيف الطلب، وهو مناسب للمراسلات الإدارية.',
    ),
  ];

  @override
  Future<List<PlacementQuestionItem>> getQuestionBundle({
    CefrLevel? level,
  }) async {
    final values = level == null
        ? _questionBank
        : _questionBank.where((question) => question.targetLevel == level);
    return List<PlacementQuestionItem>.unmodifiable(values);
  }

  @override
  Future<PlacementQuestionItem?> nextAdaptiveQuestion({
    required CefrLevel targetLevel,
    required double targetDifficulty,
    required Set<String> excludeIds,
    required Map<AssessmentSkillCategory, int> skillAttempts,
  }) async {
    final available = _questionBank
        .where((question) => !excludeIds.contains(question.id))
        .toList(growable: false);
    if (available.isEmpty) return null;

    final ranked = List<PlacementQuestionItem>.of(available)
      ..sort((left, right) {
        final leftLevelDistance =
            (left.targetLevel.rank - targetLevel.rank).abs();
        final rightLevelDistance =
            (right.targetLevel.rank - targetLevel.rank).abs();
        final byLevel = leftLevelDistance.compareTo(rightLevelDistance);
        if (byLevel != 0) return byLevel;

        final leftAttempts = skillAttempts[left.skill] ?? 0;
        final rightAttempts = skillAttempts[right.skill] ?? 0;
        final byCoverage = leftAttempts.compareTo(rightAttempts);
        if (byCoverage != 0) return byCoverage;

        final leftDifficultyDistance =
            (left.difficultyWeight - targetDifficulty).abs();
        final rightDifficultyDistance =
            (right.difficultyWeight - targetDifficulty).abs();
        final byDifficulty =
            leftDifficultyDistance.compareTo(rightDifficultyDistance);
        if (byDifficulty != 0) return byDifficulty;

        return left.id.compareTo(right.id);
      });

    return ranked.first;
  }

  @override
  PlacementResult calculateStandardizedResult(
    List<PlacementAnswerRecord> answers,
  ) {
    if (answers.isEmpty) {
      return PlacementResult(
        finalLevel: CefrLevel.a1,
        standardizedScore: 0,
        skillAccuracy: <AssessmentSkillCategory, double>{
          for (final skill in AssessmentSkillCategory.values) skill: 0,
        },
        learningPlan: const <String>[
          'ابدأ من A1 لبناء أساس ثابت في الجمل اليومية والمفردات الأساسية.',
        ],
      );
    }

    var weightedEvidence = 0.0;
    var totalWeight = 0.0;
    final attempts = <AssessmentSkillCategory, int>{};
    final correctBySkill = <AssessmentSkillCategory, int>{};

    for (final answer in answers) {
      final weight = answer.difficultyWeight.clamp(.1, 3.0).toDouble();
      final boundaryEvidence =
          (answer.level.rank + (answer.isCorrect ? 1 : 0)) / 4;
      weightedEvidence += boundaryEvidence * weight;
      totalWeight += weight;
      attempts[answer.skill] = (attempts[answer.skill] ?? 0) + 1;
      if (answer.isCorrect) {
        correctBySkill[answer.skill] =
            (correctBySkill[answer.skill] ?? 0) + 1;
      }
    }

    final score = totalWeight == 0
        ? 0.0
        : (weightedEvidence / totalWeight * 100)
            .clamp(0.0, 100.0)
            .toDouble();
    final level = _levelForScore(score);
    final accuracy = <AssessmentSkillCategory, double>{
      for (final skill in AssessmentSkillCategory.values)
        skill: (attempts[skill] ?? 0) == 0
            ? 0
            : (correctBySkill[skill] ?? 0) / attempts[skill]!,
    };

    return PlacementResult(
      finalLevel: level,
      standardizedScore: score,
      skillAccuracy: accuracy,
      learningPlan: _learningPlan(
        level: level,
        skillAccuracy: accuracy,
        attempts: attempts,
      ),
    );
  }

  static CefrLevel _levelForScore(double score) {
    if (score >= 87.5) return CefrLevel.b2;
    if (score >= 62.5) return CefrLevel.b1;
    if (score >= 37.5) return CefrLevel.a2;
    return CefrLevel.a1;
  }

  static List<String> _learningPlan({
    required CefrLevel level,
    required Map<AssessmentSkillCategory, double> skillAccuracy,
    required Map<AssessmentSkillCategory, int> attempts,
  }) {
    final plan = <String>[
      switch (level) {
        CefrLevel.a1 =>
          'ابدأ من A1 مع تثبيت تراكيب الجملة الأساسية والمفردات عالية التكرار.',
        CefrLevel.a2 =>
          'ابدأ من A2 مع مراجعة انتقائية لثغرات A1 قبل رفع كثافة المهام.',
        CefrLevel.b1 =>
          'ابدأ من B1 وركّز على إنتاج جمل أطول وربط الأفكار والسياقات العملية.',
        CefrLevel.b2 =>
          'ابدأ من B2 مع تدريب مكثف على الدقة والأسلوب وفهم النصوص المركبة.',
      },
    ];

    final observed = AssessmentSkillCategory.values
        .where((skill) => (attempts[skill] ?? 0) > 0)
        .toList(growable: false)
      ..sort((left, right) {
        final byAccuracy =
            skillAccuracy[left]!.compareTo(skillAccuracy[right]!);
        if (byAccuracy != 0) return byAccuracy;
        return left.index.compareTo(right.index);
      });

    for (final skill in observed.take(2)) {
      if (skillAccuracy[skill]! >= .75) continue;
      plan.add(_recommendationFor(skill));
    }
    return List<String>.unmodifiable(plan);
  }

  static String _recommendationFor(AssessmentSkillCategory skill) =>
      switch (skill) {
        AssessmentSkillCategory.grammar =>
          'خصص مراجعات قصيرة للقواعد التي تغيّر ترتيب الفعل والحالات الإعرابية.',
        AssessmentSkillCategory.vocabulary =>
          'زد التعرض للمفردات الشائعة داخل جمل وسياقات بدل حفظ الكلمات منفردة.',
        AssessmentSkillCategory.readingComprehension =>
          'تدرّب على استخراج الفكرة والاستنتاج من نصوص قصيرة ثم أطول تدريجياً.',
        AssessmentSkillCategory.practicalContext =>
          'تدرّب على مواقف الحياة والعمل والرسائل بصيغ مناسبة للمقام.',
      };
}
