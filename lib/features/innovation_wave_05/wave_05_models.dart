import '../../core/contracts/linguistic_capability.dart';
import '../../core/contracts/universal_scenario_contract.dart';

class MorphemeBlock {
  final String text;
  final bool isRoot;
  final String type;

  const MorphemeBlock({
    required this.text,
    required this.isRoot,
    required this.type,
  });
}

class AmbiguityTask {
  final List<String> sentenceTokens;
  final List<int> blurredIndices;
  final String question;
  final String hint;

  const AmbiguityTask({
    required this.sentenceTokens,
    required this.blurredIndices,
    required this.question,
    required this.hint,
  });
}

class MetaphorConcept {
  final String coreConcept;
  final String sourceLanguageMetaphor;
  final String targetLanguageMetaphor;

  const MetaphorConcept({
    required this.coreConcept,
    required this.sourceLanguageMetaphor,
    required this.targetLanguageMetaphor,
  });
}

/// مستودع سيناريوهات Wave 05 المؤطرة بالعقد المشترك
class Wave05Scenarios {
  // W05-01: المغناطيسية الصرفية (موثق لسانياً ومتاح)
  static const UniversalScenarioContract<List<MorphemeBlock>> morphemicScenario =
      UniversalScenarioContract<List<MorphemeBlock>>(
    scenarioId: 'W05-01-MORPH-TR',
    languagePair: LanguagePair(sourceIso: 'tr', targetIso: 'ar'),
    requiredCapabilities: {LinguisticCapability.morphologicalStacking},
    acceptedAnswers: ['Evlerimde'],
    localExplanation: 'الترتيب الصرفي: الجذر (Ev) + الجمع (ler) + الملكية (im) + حرف الجر الموضعي (de).',
    isLinguisticallyVerified: true,
    payload: [
      MorphemeBlock(text: 'Ev', isRoot: true, type: 'بيت'),
      MorphemeBlock(text: 'ler', isRoot: false, type: 'جمع'),
      MorphemeBlock(text: 'im', isRoot: false, type: 'ملكية (ي)'),
      MorphemeBlock(text: 'de', isRoot: false, type: 'في'),
    ],
  );

  // W05-02: مقياس تحمل الغموض السياقي (موثق لسانياً ومتاح)
  static const UniversalScenarioContract<AmbiguityTask> ambiguityScenario =
      UniversalScenarioContract<AmbiguityTask>(
    scenarioId: 'W05-02-AMBIG-DE',
    languagePair: LanguagePair(sourceIso: 'de', targetIso: 'ar'),
    requiredCapabilities: {LinguisticCapability.syntacticBranching},
    acceptedAnswers: ['دخول مبنى', 'شخص دخل إلى مبنى', 'الدخول'],
    localExplanation: 'الكلمات المطموسة هي صفات وظروف ثانوية، بينما الهيكل الدلالي الأساسي قائم على الفاعل والفعل.',
    isLinguisticallyVerified: true,
    payload: AmbiguityTask(
      sentenceTokens: ['Der', 'Mann', 'ging', 'schnell', 'in', 'das', 'große', 'Gebäude.'],
      blurredIndices: [3, 6],
      question: 'ما هو الحدث الدلالي المحوري في الجملة؟',
      hint: 'ركز على الفعل الرئيسي والاسم المجرور وتجاهل الزوائد.',
    ),
  );

  // سيناريو تجريبي غير موثق لاختبار الـ Fail-Closed
  static const UniversalScenarioContract<String> unverifiedScenario =
      UniversalScenarioContract<String>(
    scenarioId: 'W05-06-EXPERIMENTAL',
    languagePair: LanguagePair(sourceIso: 'es', targetIso: 'ar'),
    requiredCapabilities: {LinguisticCapability.pragmaticMitigation},
    acceptedAnswers: ['Lo siento'],
    localExplanation: 'تلطيف الخطاب باللغة الإسبانية.',
    isLinguisticallyVerified: false, // غير موثق: يعطل الميزة فوراً
    payload: 'بيانات غير معتمدة لسانياً',
  );
}
