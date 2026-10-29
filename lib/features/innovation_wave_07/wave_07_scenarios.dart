import 'package:deutsch_bilarabi/core/contracts/linguistic_capability.dart';
import 'package:deutsch_bilarabi/core/contracts/universal_scenario_contract.dart';

class Wave07Scenarios {
  // W07-01: ناظم التزامن الإيقاعي
  static const UniversalScenarioContract<Map<String, dynamic>> rhythmScenario =
      UniversalScenarioContract<Map<String, dynamic>>(
    scenarioId: 'W07-01-RHYTHM-DE',
    languagePair: LanguagePair(sourceIso: 'de', targetIso: 'ar'),
    requiredCapabilities: {LinguisticCapability.phonologicalStress},
    acceptedAnswers: ['Ich GE-he in die SCHU-le.'],
    localExplanation:
        'الألمانية لغة موقوتة بالنبر؛ التركيز الزمني يقع على المقاطع المشددة مع تسريع المقاطع غير المشددة.',
    isLinguisticallyVerified: true,
    payload: {
      'stressPattern': [0, 1, 0, 0, 1, 0],
      'tokens': ['Ich', 'gehe', 'in', 'die', 'Schule.'],
    },
  );

  // W07-02: مقياس المسافة الاجتماعية وصيغ الخطاب
  static const UniversalScenarioContract<List<String>> honorificScenario =
      UniversalScenarioContract<List<String>>(
    scenarioId: 'W07-02-HONOR-DE',
    languagePair: LanguagePair(sourceIso: 'de', targetIso: 'ar'),
    requiredCapabilities: {LinguisticCapability.honorificDistance},
    acceptedAnswers: ['Könnten Sie mir bitte helfen?'],
    localExplanation:
        'في السياق الرسمي أو مع الغرباء، يُستخدم الضمير Sie مقترناً بصيغة التلطيف Könnten للحفاظ على المسافة الاجتماعية.',
    isLinguisticallyVerified: true,
    payload: [
      'Hilf mir mal.',
      'Kannst du mir helfen?',
      'Könnten Sie mir bitte helfen?',
    ],
  );

  // W07-03: شبكة الترابط الإحالي النصي
  static const UniversalScenarioContract<Map<String, String>> anaphoraScenario =
      UniversalScenarioContract<Map<String, String>>(
    scenarioId: 'W07-03-ANAPH-DE',
    languagePair: LanguagePair(sourceIso: 'de', targetIso: 'ar'),
    requiredCapabilities: {LinguisticCapability.anaphoraCohesion},
    acceptedAnswers: ['Es ist neu.'],
    localExplanation:
        'كلمة Auto محايدة دلالياً ونحوياً، لذا فإن الضمير العائد عليها يجب أن يكون Es حصراً.',
    isLinguisticallyVerified: true,
    payload: {
      'antecedent': 'das Auto',
      'correctPronoun': 'Es',
      'distractors': 'Er, Sie',
    },
  );

  // W07-04: مستشعر الاستلزام الحواري
  static const UniversalScenarioContract<Map<String, String>>
      implicatureScenario = UniversalScenarioContract<Map<String, String>>(
    scenarioId: 'W07-04-IMPLIC-DE',
    languagePair: LanguagePair(sourceIso: 'de', targetIso: 'ar'),
    requiredCapabilities: {LinguisticCapability.conversationalImplicature},
    acceptedAnswers: ['الطعام لم يعجبه'],
    localExplanation:
        'تجنب الإجابة المباشرة عن جودة الطعام والحديث عن النظافة فقط هو خرق لقرينة العلاقة، ويستلزم ضمنياً عدم الرضا.',
    isLinguisticallyVerified: true,
    payload: {
      'dialogue':
          'A: Hat dir das Essen geschmeckt?\nB: Das Restaurant war sehr sauber.',
      'implicitMeaning': 'الطعام لم يعجبه',
    },
  );

  // W07-05: مخزن حشوات التردد
  static const UniversalScenarioContract<List<String>> hesitationScenario =
      UniversalScenarioContract<List<String>>(
    scenarioId: 'W07-05-HESIT-DE',
    languagePair: LanguagePair(sourceIso: 'de', targetIso: 'ar'),
    requiredCapabilities: {LinguisticCapability.hesitationRepair},
    acceptedAnswers: ['sozusagen', 'also'],
    localExplanation:
        'استخدام sozusagen يمنح المتحدث وقتاً ذهنياً لإعادة صياغة الفكرة دون قطع التواصل أو إصدار أصوات تردد غير لغوية.',
    isLinguisticallyVerified: true,
    payload: ['sozusagen', 'also', 'quasi'],
  );
}
