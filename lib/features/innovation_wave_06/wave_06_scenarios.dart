import '../../core/contracts/linguistic_capability.dart';
import '../../core/contracts/universal_scenario_contract.dart';

class Wave06Scenarios {
  // W06-01: الشاهدية ومصدر المعرفة (ألماني - عربي)
  static const UniversalScenarioContract<Map<String, String>> evidentialityScenario =
      UniversalScenarioContract<Map<String, String>>(
    scenarioId: 'W06-01-EVID-DE',
    languagePair: LanguagePair(sourceIso: 'de', targetIso: 'ar'),
    requiredCapabilities: {LinguisticCapability.evidentiality},
    acceptedAnswers: ['Der Zug soll Verspätung haben.'],
    localExplanation: 'استخدام الفعل المساعد sollen لنقل معلومة مستقاة من الشائعات أو من طرف ثالث دون تبني صحتها.',
    isLinguisticallyVerified: true,
    payload: {
      'witness': 'Der Zug hat Verspätung.',
      'hearsay': 'Der Zug soll Verspätung haben.',
      'deduction': 'Der Zug muss Verspätung haben.',
    },
  );

  // W06-02: التلازم اللفظي (ألماني - عربي)
  static const UniversalScenarioContract<List<String>> collocationScenario =
      UniversalScenarioContract<List<String>>(
    scenarioId: 'W06-02-COLLOC-DE',
    languagePair: LanguagePair(sourceIso: 'de', targetIso: 'ar'),
    requiredCapabilities: {LinguisticCapability.collocationalTension},
    acceptedAnswers: ['eine Entscheidung treffen'],
    localExplanation: 'الفعل treffen هو المتلازم الطبيعي لكلمة Entscheidung، بينما الفعل machen يُعد نقلاً حرفياً غير سليم.',
    isLinguisticallyVerified: true,
    payload: ['treffen', 'fällen', 'machen'],
  );
}
