// Sovereign Polyglot Core - Task 4897 (Quality Assurance)
class Task4897Engine {
  static const int taskId = 4897;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'nachteilen';
  static const String praeteritum = 'teilte nach';
  static const String perfekt = 'hat nachgeteilt';
  static const String arabicTranslation = 'تدقيق / متابعة التقسيم (ضمان الجودة)';
  static const String ipaTranscription = '[nachˈˈtaɪ̯lən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4897_nachteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess nachteilen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التقسيم في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
