// Sovereign Polyglot Core - Task 3782 (Financial Auditing)
class Task3782Engine {
  static const int taskId = 3782;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'verplanen';
  static const String praeteritum = 'verplante';
  static const String perfekt = 'hat verplant';
  static const String arabicTranslation = 'توثيق / معالجة التخطيط (التدقيق المالي)';
  static const String ipaTranscription = '[verˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3782_verplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung verplanen.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة التخطيط في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
