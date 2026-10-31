import 'package:deutsch_bilarabi/core/contracts/linguistic_capability.dart';
import 'package:deutsch_bilarabi/core/contracts/universal_scenario_contract.dart';

class Wave06Scenarios {
  // W06-01: الشاهدية ومعايرة اليقين المعرفي
  static const UniversalScenarioContract<Map<String, String>>
      evidentialityScenario = UniversalScenarioContract<Map<String, String>>(
    scenarioId: 'W06-01-EVID-DE',
    languagePair: LanguagePair(sourceIso: 'de', targetIso: 'ar'),
    requiredCapabilities: {LinguisticCapability.evidentiality},
    acceptedAnswers: ['Der Zug soll Verspätung haben.'],
    localExplanation:
        'صياغة الشائعة أو النقل تتطلب استخدام الفعل المساعد sollen لإخلاء مسؤولية المتحدث عن صحة الخبر.',
    isLinguisticallyVerified: true,
    payload: {
      'witness': 'Der Zug hat Verspätung.',
      'hearsay': 'Der Zug soll Verspätung haben.',
      'deduction': 'Der Zug muss Verspätung haben.',
    },
  );

  // W06-02: حقل التلازم اللفظي
  static const UniversalScenarioContract<List<String>> collocationScenario =
      UniversalScenarioContract<List<String>>(
    scenarioId: 'W06-02-COLLOC-DE',
    languagePair: LanguagePair(sourceIso: 'de', targetIso: 'ar'),
    requiredCapabilities: {LinguisticCapability.collocationalTension},
    acceptedAnswers: ['eine Entscheidung treffen'],
    localExplanation:
        'الاقتران الطبيعي هو treffen؛ استخدام machen يعد خطأ شائعاً ناتجاً عن النقل الحرفي.',
    isLinguisticallyVerified: true,
    payload: ['treffen', 'fällen', 'machen'],
  );

  // W06-03: كابح التفرع النحوي والتداخل المركزي
  static const UniversalScenarioContract<Map<String, dynamic>>
      centerEmbeddingScenario = UniversalScenarioContract<Map<String, dynamic>>(
    scenarioId: 'W06-03-EMBED-DE',
    languagePair: LanguagePair(sourceIso: 'de', targetIso: 'ar'),
    requiredCapabilities: {LinguisticCapability.syntacticBranching},
    acceptedAnswers: [
      'Das ist der Mann. Er sah den Hund.',
      'Das ist der Mann, der den Hund sah.'
    ],
    localExplanation:
        'تفكيك الجملة المتداخلة إلى جملتين متتابعتين يخفف العبء الإدراكي على الذاكرة العاملة بنسبة 40%.',
    isLinguisticallyVerified: true,
    payload: {
      'maxDepth': 2,
      'baseClause': 'Das ist der Mann',
      'subClause': 'der den Hund sah',
    },
  );

  // W06-04: مزلاق التلطيف وحفظ ماء الوجه
  static const UniversalScenarioContract<List<String>> faceSavingScenario =
      UniversalScenarioContract<List<String>>(
    scenarioId: 'W06-04-FACE-DE',
    languagePair: LanguagePair(sourceIso: 'de', targetIso: 'ar'),
    requiredCapabilities: {LinguisticCapability.pragmaticMitigation},
    acceptedAnswers: [
      'Ich würde gerne, aber leider schaffe ich es nicht.',
      'Das könnte schwierig werden.',
    ],
    localExplanation:
        'استخدام صيغة التمني (Konjunktiv II) وأدوات التخفيف (leider, vielleicht) يحفظ ماء الوجه للمخاطب.',
    isLinguisticallyVerified: true,
    payload: [
      'Nein, ich will nicht.',
      'Ich schaffe das nicht.',
      'Ich würde gerne, aber leider schaffe ich es nicht.',
    ],
  );

  // W06-05: ماسح الحذف والاختزال الدلالي (التكافؤ الصفري)
  static const UniversalScenarioContract<Map<String, String>>
      zeroEquivalenceScenario = UniversalScenarioContract<Map<String, String>>(
    scenarioId: 'W06-05-ZERO-DE',
    languagePair: LanguagePair(sourceIso: 'de', targetIso: 'ar'),
    requiredCapabilities: {LinguisticCapability.zeroEquivalence},
    acceptedAnswers: ['Ich höre Musik.', 'Ich höre die Musik.'],
    localExplanation:
        'الفعل hören متعدٍ بنفسه ولا يتطلب حرف جر (zu)؛ الترجمة الحرفية لحرف الجر العربي "إلى" تشكل حشواً خاطئاً.',
    isLinguisticallyVerified: true,
    payload: {
      'sourceText': 'أنا أستمع إلى الموسيقى',
      'targetVerb': 'hören',
      'voidElement': 'zu',
    },
  );
}
