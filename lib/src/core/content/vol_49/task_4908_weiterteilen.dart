// Sovereign Polyglot Core - Task 4908 (Quality Assurance)
class Task4908Engine {
  static const int taskId = 4908;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'weiterteilen';
  static const String praeteritum = 'teilte weiter';
  static const String perfekt = 'hat weitergeteilt';
  static const String arabicTranslation = 'مواصلة / تمرير التقسيم (ضمان الجودة)';
  static const String ipaTranscription = '[weiterˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4908_weiterteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess weiterteilen.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير التقسيم في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
