import '../language_exercise_strategy.dart';
import '../../core/content_contract.dart';
import '../../models/assessment.dart';
import '../../models/conversation.dart';
import '../../models/mistake.dart';
import '../../models/production.dart';

/// German-specific exercise wording and scenario data.
final class GermanLanguageExerciseStrategy implements LanguageExerciseStrategy {
  const GermanLanguageExerciseStrategy();

  @override
  AssessmentQuestion assessmentQuestion(
    LearningContent x,
    int index,
    int seed,
  ) {
    final types = AssessmentQuestionType.values;
    final type = types[(index + seed + x.id.length) % types.length];
    switch (type) {
      case AssessmentQuestionType.recall:
        return AssessmentQuestion(
          id: 'q_${x.id}_r',
          itemId: x.id,
          prompt: 'ما الكلمة/العبارة الألمانية؟ ${x.translationText}',
          expected: x.sourceText,
          type: type,
          accepted: x.acceptedForms,
          skill: 'recall',
        );
      case AssessmentQuestionType.translation:
        return AssessmentQuestion(
          id: 'q_${x.id}_t',
          itemId: x.id,
          prompt: 'ترجم إلى الألمانية: ${x.exampleTranslationText}',
          expected: x.exampleText,
          type: type,
          accepted: [...x.acceptedForms, x.sourceText],
          skill: 'transfer',
        );
      case AssessmentQuestionType.listening:
        return AssessmentQuestion(
          id: 'q_${x.id}_l',
          itemId: x.id,
          prompt: 'استمع ثم اكتب الجملة الألمانية.',
          expected: x.exampleText,
          type: type,
          accepted: x.acceptedForms,
          skill: 'listening',
        );
      case AssessmentQuestionType.production:
        return AssessmentQuestion(
          id: 'q_${x.id}_p',
          itemId: x.id,
          prompt: 'اكتب جملة ألمانية مناسبة باستخدام: ${x.sourceText}',
          expected: x.exampleText,
          type: type,
          accepted: x.acceptedForms,
          skill: 'production',
        );
      case AssessmentQuestionType.grammar:
        return AssessmentQuestion(
          id: 'q_${x.id}_g',
          itemId: x.id,
          prompt: x.grammaticalMarker.isEmpty
              ? 'اكتب الكلمة الألمانية الصحيحة.'
              : 'اكتب الكلمة مع Artikel الصحيح: ${x.translationText}',
          expected: x.grammaticalMarker.isEmpty
              ? x.sourceText
              : '${x.grammaticalMarker} ${x.sourceText}',
          type: type,
          accepted: [...x.acceptedForms, x.sourceText],
          skill: 'recall',
        );
    }
  }

  @override
  ProductionTask? productionTask(
    LearningContent item, {
    MistakeRecord? mistake,
    ProductionMode? mode,
  }) {
    if (item.exampleText.trim().isEmpty) return null;
    final selected = mode ?? _modeFor(mistake);
    final expected = item.exampleText.trim();
    final accepted = <String>{
      expected,
      ...item.acceptedForms,
    }.where((x) => x.trim().isNotEmpty).toList();
    switch (selected) {
      case ProductionMode.recognize:
        return ProductionTask(
          itemId: item.id,
          mode: selected,
          prompt:
              'اختر الجملة الألمانية التي تعبّر عن: ${item.exampleTranslationText}',
          expected: expected,
          accepted: accepted,
          hint: item.sourceText,
        );
      case ProductionMode.guided:
        return ProductionTask(
          itemId: item.id,
          mode: selected,
          prompt:
              'اكتب جملة ألمانية باستخدام «${item.sourceText}» للتعبير عن: ${item.exampleTranslationText}',
          expected: expected,
          accepted: accepted,
          hint: 'ابدأ من معنى الجملة العربية، ثم ثبّت الفعل في موقعه الصحيح.',
        );
      case ProductionMode.free:
        return ProductionTask(
          itemId: item.id,
          mode: selected,
          prompt:
              'اكتب جملة ألمانية جديدة من إنشائك باستخدام «${item.sourceText}».',
          expected: expected,
          accepted: accepted,
          hint:
              'الجملة الجديدة لا يلزم أن تطابق المثال حرفيًا؛ المطلوب استعمال الكلمة استعمالًا صحيحًا.',
        );
    }
  }

  @override
  RepairDrill? repairDrill(LearningContent? item, MistakeRecord mistake) {
    if (item == null) {
      if (mistake.category != MistakeCategory.writing) return null;
      return RepairDrill(
        mistake: mistake,
        steps: [
          RepairStep(
            mode: RepairMode.recognize,
            prompt:
                'اقرأ المشكلة وحدد الجزء الذي تحتاج إلى إصلاحه: ${mistake.normalizedKey.replaceFirst('writing:', '')}',
            expected: 'أحدد الخطأ',
          ),
          RepairStep(
            mode: RepairMode.correct,
            prompt: 'اكتب الجملة الألمانية مصححة.',
            expected: 'جملة ألمانية صحيحة',
          ),
          RepairStep(
            mode: RepairMode.produce,
            prompt: 'اكتب جملة ألمانية جديدة تستخدم القاعدة نفسها.',
            expected: 'جملة ألمانية جديدة',
          ),
        ],
      );
    }
    final expected = mistake.category == MistakeCategory.article &&
            item.grammaticalMarker.isNotEmpty
        ? '${item.grammaticalMarker} ${item.sourceText}'
        : item.sourceText;
    final accepted = <String>{
      expected,
      item.sourceText,
      ...item.acceptedForms,
    }.where((x) => x.trim().isNotEmpty).toList();
    final firstPrompt = mistake.category == MistakeCategory.article
        ? 'حدّد Artikel الصحيح ثم اكتب الاسم كاملًا: ${item.translationText}'
        : mistake.category == MistakeCategory.grammar
            ? 'حدّد القاعدة التي أخطأت فيها ثم اختر الصيغة الصحيحة: ${item.translationText}'
            : 'استرجع الإجابة الصحيحة من المعنى: ${item.translationText}';
    final correctionPrompt = mistake.category == MistakeCategory.grammar
        ? 'طبّق القاعدة وصحّح العبارة كاملة.'
        : 'صحّح الخطأ ثم اكتب العبارة كاملة.';
    return RepairDrill(
      mistake: mistake,
      steps: [
        RepairStep(
          mode: RepairMode.recognize,
          prompt: firstPrompt,
          expected: expected,
          accepted: accepted,
        ),
        RepairStep(
          mode: RepairMode.correct,
          prompt: correctionPrompt,
          expected: expected,
          accepted: accepted,
        ),
        RepairStep(
          mode: RepairMode.produce,
          prompt: 'استخدم الكلمة في جملة ألمانية جديدة.',
          expected: item.exampleText,
          accepted: [item.exampleText, ...item.acceptedForms],
        ),
      ],
    );
  }

  @override
  List<ConversationScenario> get conversationScenarios => _scenarios;

  ProductionMode _modeFor(MistakeRecord? mistake) {
    if (mistake == null) return ProductionMode.guided;
    if (mistake.category == MistakeCategory.production ||
        mistake.category == MistakeCategory.writing ||
        mistake.category == MistakeCategory.wordOrder)
      return ProductionMode.guided;
    if (mistake.errorCount >= 3 || mistake.recentFailureRate >= .6)
      return ProductionMode.recognize;
    return ProductionMode.guided;
  }

  static const List<ConversationScenario> _scenarios = [
    ConversationScenario(
      id: 'restaurant',
      title: 'في المطعم',
      situation: 'اطلب مشروبًا ثم اسأل عن السعر.',
      turns: [
        ConversationTurn(
          id: 'restaurant_1',
          promptGerman: 'Guten Tag. Was möchten Sie?',
          promptArabic: 'مرحبًا. ماذا تريد؟',
          expected: ['Ich möchte einen Kaffee, bitte.'],
          keywords: ['möchte', 'Kaffee', 'bitte'],
        ),
        ConversationTurn(
          id: 'restaurant_2',
          promptGerman: 'Sonst noch etwas?',
          promptArabic: 'هل تريد شيئًا آخر؟',
          expected: ['Nein, danke. Das ist alles.'],
          keywords: ['nein', 'danke', 'alles'],
        ),
        ConversationTurn(
          id: 'restaurant_3',
          promptGerman: 'Das macht vier Euro.',
          promptArabic: 'السعر أربعة يورو.',
          expected: ['Wie viel kostet das?'],
          keywords: ['viel', 'kostet'],
        ),
      ],
    ),
    ConversationScenario(
      id: 'station',
      title: 'في محطة القطار',
      situation: 'اسأل عن الرصيف والوقت.',
      turns: [
        ConversationTurn(
          id: 'station_1',
          promptGerman: 'Entschuldigung. Was suchen Sie?',
          promptArabic: 'عذرًا. ماذا تبحث؟',
          expected: ['Wo ist Gleis vier?'],
          keywords: ['gleis', 'vier'],
        ),
        ConversationTurn(
          id: 'station_2',
          promptGerman: 'Der Zug fährt um zehn Uhr.',
          promptArabic: 'القطار يغادر الساعة العاشرة.',
          expected: ['Wann fährt der Zug ab?'],
          keywords: ['wann', 'fährt', 'zug'],
        ),
      ],
    ),
    ConversationScenario(
      id: 'supermarket',
      title: 'في السوبرماركت',
      situation: 'اسأل عن منتج ثم عن السعر.',
      turns: [
        ConversationTurn(
          id: 'market_1',
          promptGerman: 'Kann ich Ihnen helfen?',
          promptArabic: 'هل يمكنني مساعدتك؟',
          expected: ['Ja, wo finde ich die Milch?'],
          keywords: ['wo', 'finde', 'milch'],
        ),
        ConversationTurn(
          id: 'market_2',
          promptGerman: 'Die Milch ist im Kühlregal.',
          promptArabic: 'الحليب في الثلاجة.',
          expected: ['Wie viel kostet die Milch?'],
          keywords: ['viel', 'kostet', 'milch'],
        ),
      ],
    ),
    ConversationScenario(
      id: 'work',
      title: 'في العمل',
      situation: 'تحدث عن موعد مع زميل.',
      turns: [
        ConversationTurn(
          id: 'work_1',
          promptGerman: 'Wann können wir sprechen?',
          promptArabic: 'متى يمكننا التحدث؟',
          expected: ['Wir können um neun Uhr sprechen.'],
          keywords: ['können', 'neun', 'sprechen'],
        ),
        ConversationTurn(
          id: 'work_2',
          promptGerman: 'Passt Ihnen morgen?',
          promptArabic: 'هل يناسبك غدًا؟',
          expected: ['Ja, morgen passt mir gut.'],
          keywords: ['morgen', 'passt', 'gut'],
        ),
      ],
    ),
    ConversationScenario(
      id: 'doctor',
      title: 'عند الطبيب',
      situation: 'اشرح عرضًا بسيطًا للطبيب.',
      turns: [
        ConversationTurn(
          id: 'doctor_1',
          promptGerman: 'Was fehlt Ihnen?',
          promptArabic: 'ما الذي يؤلمك؟',
          expected: ['Ich habe Kopfschmerzen.'],
          keywords: ['habe', 'kopfschmerzen'],
        ),
        ConversationTurn(
          id: 'doctor_2',
          promptGerman: 'Seit wann haben Sie die Schmerzen?',
          promptArabic: 'منذ متى لديك الألم؟',
          expected: ['Seit zwei Tagen.'],
          keywords: ['seit', 'zwei', 'tagen'],
        ),
      ],
    ),
    ConversationScenario(
      id: 'hotel',
      title: 'في الفندق',
      situation: 'اطلب غرفة واسأل عن وقت تسجيل الخروج.',
      turns: [
        ConversationTurn(
          id: 'hotel_1',
          promptGerman: 'Guten Abend. Haben Sie ein Zimmer frei?',
          promptArabic: 'مساء الخير. هل لديكم غرفة شاغرة؟',
          expected: ['Ja, wir haben noch ein Zimmer frei.'],
          keywords: ['ja', 'zimmer', 'frei'],
        ),
        ConversationTurn(
          id: 'hotel_2',
          promptGerman: 'Wann möchten Sie auschecken?',
          promptArabic: 'متى تريد تسجيل المغادرة؟',
          expected: ['Am Sonntagmorgen.'],
          keywords: ['sonntag', 'morgen'],
        ),
      ],
    ),
    ConversationScenario(
      id: 'directions',
      title: 'السؤال عن الطريق',
      situation: 'اسأل عن محطة الحافلات ثم اشكر الشخص.',
      turns: [
        ConversationTurn(
          id: 'directions_1',
          promptGerman: 'Entschuldigung, wo ist die Bushaltestelle?',
          promptArabic: 'عذرًا، أين موقف الحافلة؟',
          expected: ['Die Bushaltestelle ist dort drüben.'],
          keywords: ['bushaltestelle', 'dort'],
        ),
        ConversationTurn(
          id: 'directions_2',
          promptGerman: 'Sie müssen geradeaus gehen.',
          promptArabic: 'يجب أن تمشي مباشرة.',
          expected: ['Vielen Dank für Ihre Hilfe.'],
          keywords: ['vielen', 'dank', 'hilfe'],
        ),
      ],
    ),
    ConversationScenario(
      id: 'pharmacy',
      title: 'في الصيدلية',
      situation: 'اطلب دواءً واسأل عن طريقة الاستخدام.',
      turns: [
        ConversationTurn(
          id: 'pharmacy_1',
          promptGerman: 'Was brauchen Sie?',
          promptArabic: 'ماذا تحتاج؟',
          expected: ['Ich brauche etwas gegen Kopfschmerzen.'],
          keywords: ['brauche', 'gegen', 'kopfschmerzen'],
        ),
        ConversationTurn(
          id: 'pharmacy_2',
          promptGerman: 'Nehmen Sie eine Tablette am Abend.',
          promptArabic: 'خذ حبة مساءً.',
          expected: ['Wie oft soll ich die Tabletten nehmen?'],
          keywords: ['oft', 'tabletten', 'nehmen'],
        ),
      ],
    ),
  ];
}
