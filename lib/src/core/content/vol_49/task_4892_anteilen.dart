// Sovereign Polyglot Core - Task 4892 (Quality Assurance)
class Task4892Engine {
  static const int taskId = 4892;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'anteilen';
  static const String praeteritum = 'teilte an';
  static const String perfekt = 'hat angeteilt';
  static const String arabicTranslation = 'بدء / توجيه التقسيم (ضمان الجودة)';
  static const String ipaTranscription = '[anˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4892_anteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess anteilen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه التقسيم في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
