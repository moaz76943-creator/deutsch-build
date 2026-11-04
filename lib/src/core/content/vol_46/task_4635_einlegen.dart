// Sovereign Polyglot Core - Task 4635 (Quality Assurance)
class Task4635Engine {
  static const int taskId = 4635;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'einlegen';
  static const String praeteritum = 'legte ein';
  static const String perfekt = 'hat eingelegt';
  static const String arabicTranslation = 'إدراج / دمج التأسيس (ضمان الجودة)';
  static const String ipaTranscription = '[einˈˈleːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4635_einlegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess einlegen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التأسيس في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
