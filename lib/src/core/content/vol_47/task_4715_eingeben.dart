// Sovereign Polyglot Core - Task 4715 (Quality Assurance)
class Task4715Engine {
  static const int taskId = 4715;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'eingeben';
  static const String praeteritum = 'gab ein';
  static const String perfekt = 'hat eingegeben';
  static const String arabicTranslation = 'إدراج / دمج التسليم (ضمان الجودة)';
  static const String ipaTranscription = '[einˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4715_eingeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess eingeben.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التسليم في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
