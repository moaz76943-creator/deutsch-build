// Sovereign Polyglot Core - Task 4640 (Quality Assurance)
class Task4640Engine {
  static const int taskId = 4640;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'ueberlegen';
  static const String praeteritum = 'ueberlegte';
  static const String perfekt = 'hat ueberlegt';
  static const String arabicTranslation = 'مراجعة / نقل التأسيس (ضمان الجودة)';
  static const String ipaTranscription = '[ueberˈˈleːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4640_ueberlegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess ueberlegen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التأسيس في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
