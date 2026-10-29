import 'package:deutsch_bilarabi/core/contracts/linguistic_capability.dart';
import 'package:deutsch_bilarabi/core/contracts/universal_scenario_contract.dart';

class Wave08Scenarios {
  // W08-01: التناغم الصوتي والقيود الفونوتكتيكية
  static const UniversalScenarioContract<Map<String, dynamic>> harmonyScenario =
      UniversalScenarioContract<Map<String, dynamic>>(
    scenarioId: 'W08-01-HARM-TR',
    languagePair: LanguagePair(sourceIso: 'tr', targetIso: 'ar'),
    requiredCapabilities: {LinguisticCapability.phonotacticHarmony},
    acceptedAnswers: ['evler'],
    localExplanation: 'الاسم ev ينتهي بحركة أمامية رقيقة (e)، لذا فإن لاحقة الجمع المتوافقة صوتياً هي ler وليست lar.',
    isLinguisticallyVerified: true,
    payload: {
      'root': 'ev',
      'compatibleSuffix': 'ler',
      'incompatibleSuffix': 'lar',
    },
  );

  // W08-02: السلالم الدلالية وأدوات القطبية
  static const UniversalScenarioContract<List<String>> scalarScenario =
      UniversalScenarioContract<List<String>>(
    scenarioId: 'W08-02-SCALE-DE',
    languagePair: LanguagePair(sourceIso: 'de', targetIso: 'ar'),
    requiredCapabilities: {LinguisticCapability.scalarImplicature},
    acceptedAnswers: ['Ich habe überhaupt kein Geld.'],
    localExplanation: 'أداة القطبية السالبة überhaupt تعزز النفي التام وتغلق السلم الدلالي لأي احتمال متبقٍ.',
    isLinguisticallyVerified: true,
    payload: [
      'Ich habe kein Geld.',
      'Ich habe kaum Geld.',
      'Ich habe überhaupt kein Geld.',
    ],
  );

  // W08-03: النبر البؤري والتنغيم النغمي
  static const UniversalScenarioContract<Map<String, String>> prosodicScenario =
      UniversalScenarioContract<Map<String, String>>(
    scenarioId: 'W08-03-PROS-DE',
    languagePair: LanguagePair(sourceIso: 'de', targetIso: 'ar'),
    requiredCapabilities: {LinguisticCapability.prosodicFocus},
    acceptedAnswers: ['التأكيد على هوية الفاعل وليس غيره'],
    localExplanation: 'النبر المشدد على الضمير ICH ينقل بؤرة الجملة للمتكلم وينفي الفعل عن باقي الحاضرين.',
    isLinguisticallyVerified: true,
    payload: {
      'sentence': 'ICH habe das gesagt.',
      'focusTarget': 'ICH',
      'pragmaticMeaning': 'التأكيد على هوية الفاعل وليس غيره',
    },
  );

  // W08-04: التخصيص المعجمي ومستويات التجريد
  static const UniversalScenarioContract<List<String>> granularityScenario =
      UniversalScenarioContract<List<String>>(
    scenarioId: 'W08-04-GRAN-DE',
    languagePair: LanguagePair(sourceIso: 'de', targetIso: 'ar'),
    requiredCapabilities: {LinguisticCapability.taxonomicGranularity},
    acceptedAnswers: ['schlendern'],
    localExplanation: 'الفعل schlendern يحدد طريقة المشي بتمهل واسترخاء، وهو أعلى دقة تداولية من الفعل العام gehen.',
    isLinguisticallyVerified: true,
    payload: ['gehen', 'marschieren', 'schlendern'],
  );

  // W08-05: بوصلة الافتراض المضاد للواقع
  static const UniversalScenarioContract<Map<String, String>> counterfactualScenario =
      UniversalScenarioContract<Map<String, String>>(
    scenarioId: 'W08-05-COUNT-DE',
    languagePair: LanguagePair(sourceIso: 'de', targetIso: 'ar'),
    requiredCapabilities: {LinguisticCapability.counterfactualMood},
    acceptedAnswers: ['Wenn ich Zeit hätte, käme ich.'],
    localExplanation: 'صيغة Konjunktiv II تنقل الجملة إلى حيز اللاتحقق (Irrealis) لتعبر عن أمنية تخالف الواقع الحالي.',
    isLinguisticallyVerified: true,
    payload: {
      'realis': 'Ich habe keine Zeit, ich komme nicht.',
      'irrealis': 'Wenn ich Zeit hätte, käme ich.',
    },
  );
}
