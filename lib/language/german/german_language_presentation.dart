import '../language_presentation.dart';
import '../../models/conversation.dart';

/// German-specific presentation data for the shared conversation UI.
final class GermanLanguagePresentation implements LanguagePresentation {
  const GermanLanguagePresentation();

  @override
  String get targetLanguageName => conversation.targetLanguageName;

  @override
  String get pronunciationTooltip => 'نطق بالألمانية';

  @override
  String get grammaticalMarkerLabel => 'Artikel';

  @override
  String get pluralLabel => 'Plural';

  @override
  ConversationPresentation get conversation =>
      const GermanConversationPresentation();

  @override
  RealWorldLearningPresentation get realWorld =>
      const GermanRealWorldLearningPresentation();

  @override
  PlacementPresentation get placement => const GermanPlacementPresentation();
}

final class GermanConversationPresentation implements ConversationPresentation {
  const GermanConversationPresentation();

  @override
  String get targetLanguageName => 'الألمانية';

  @override
  String get targetLanguageInstruction =>
      'تحدث بالألمانية، وسيقارن التطبيق إجابتك محليًا بالكلمات والمعنى المطلوبين.';

  @override
  String get speechPermissionError =>
      'تعذر تشغيل الميكروفون. تحقق من إذن التسجيل وإعداد اللغة الألمانية.';

  @override
  String get defaultSpeechStatus =>
      'استمع للسؤال ثم اضغط الميكروفون وأجب بالألمانية.';

  @override
  ConversationScenario get fallbackScenario => const ConversationScenario(
        id: 'safe_fallback',
        title: 'تدريب آمن',
        situation: 'تدريب محلي احتياطي عند تعذر تحميل موقف آخر.',
        turns: [
          ConversationTurn(
            id: 'safe_fallback_1',
            promptGerman: 'Wie geht es Ihnen?',
            promptArabic: 'كيف حالك؟',
            expected: ['Mir geht es gut.'],
            keywords: ['geht', 'gut'],
          ),
        ],
      );
}

final class GermanRealWorldLearningPresentation
    implements RealWorldLearningPresentation {
  const GermanRealWorldLearningPresentation();

  @override
  String get title => 'ألمانيا الحقيقية';

  @override
  String get subtitle => 'مواقف ستقابلها خارج الكتاب.';

  @override
  String get targetLanguageInstruction =>
      'اكتب العبارة الألمانية المناسبة للموقف.';

  @override
  List<RealWorldScenario> get scenarios => const [
        RealWorldScenario(
          title: 'محطة القطار',
          targetText: 'Gleis 4',
          sourceText: 'المنصة 4',
        ),
        RealWorldScenario(
          title: 'المواصلات',
          targetText: 'Der Zug hat Verspätung.',
          sourceText: 'القطار متأخر.',
        ),
        RealWorldScenario(
          title: 'السوبرماركت',
          targetText: 'Wie viel kostet das?',
          sourceText: 'كم سعر هذا؟',
        ),
        RealWorldScenario(
          title: 'الطبيب',
          targetText: 'Was fehlt Ihnen?',
          sourceText: 'ما الذي يؤلمك؟',
        ),
        RealWorldScenario(
          title: 'العمل',
          targetText: 'Wir haben um neun Uhr einen Termin.',
          sourceText: 'لدينا موعد الساعة التاسعة.',
        ),
        RealWorldScenario(
          title: 'السكن',
          targetText: 'Die Wohnung ist frei.',
          sourceText: 'الشقة متاحة.',
        ),
        RealWorldScenario(
          title: 'الهاتف',
          targetText: 'Können Sie das bitte wiederholen?',
          sourceText: 'هل يمكنك تكرار ذلك من فضلك؟',
        ),
        RealWorldScenario(
          title: 'رسالة',
          targetText: 'Kannst du heute kommen?',
          sourceText: 'هل تستطيع المجيء اليوم؟',
        ),
      ];
}

final class GermanPlacementPresentation implements PlacementPresentation {
  const GermanPlacementPresentation();

  @override
  String get title => 'تحديد المستوى';

  @override
  String get answerLabel => 'إجابتك';

  @override
  String get finishLabel => 'إنهاء';

  @override
  String get nextLabel => 'التالي';

  @override
  String get resultTitle => 'نتيجة أولية';

  @override
  String resultMessage(int score, int total) =>
      'أجبت بشكل صحيح عن $score من $total. هذه إشارة بداية وليست شهادة مستوى.';

  @override
  List<PlacementQuestion> get questions => const [
        PlacementQuestion(prompt: 'ما ترجمة: Haus؟', answer: 'بيت'),
        PlacementQuestion(prompt: 'ما الكلمة الصحيحة: ___ Arzt', answer: 'der'),
        PlacementQuestion(prompt: 'أكمل: Ich ___ Deutsch.', answer: 'lerne'),
        PlacementQuestion(prompt: 'ما ترجمة: Wasser؟', answer: 'ماء'),
        PlacementQuestion(
            prompt: 'أكمل: Ich fahre mit ___ Bus.', answer: 'dem'),
        PlacementQuestion(
          prompt: 'ما الصحيح: Ich habe ___ Problem.',
          answer: 'ein',
        ),
      ];
}
