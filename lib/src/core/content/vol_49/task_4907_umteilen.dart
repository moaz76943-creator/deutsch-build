// Sovereign Polyglot Core - Task 4907 (Quality Assurance)
class Task4907Engine {
  static const int taskId = 4907;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'umteilen';
  static const String praeteritum = 'teilte um';
  static const String perfekt = 'hat umgeteilt';
  static const String arabicTranslation = 'إعادة هيكلة التقسيم (ضمان الجودة)';
  static const String ipaTranscription = '[umˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4907_umteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess umteilen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التقسيم في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
