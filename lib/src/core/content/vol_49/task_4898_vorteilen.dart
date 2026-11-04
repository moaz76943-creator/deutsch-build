// Sovereign Polyglot Core - Task 4898 (Quality Assurance)
class Task4898Engine {
  static const int taskId = 4898;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'vorteilen';
  static const String praeteritum = 'teilte vor';
  static const String perfekt = 'hat vorgeteilt';
  static const String arabicTranslation = 'تقديم / تحضير التقسيم (ضمان الجودة)';
  static const String ipaTranscription = '[vorˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4898_vorteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess vorteilen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التقسيم في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
