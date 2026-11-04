// Sovereign Polyglot Core - Task 4795 (Quality Assurance)
class Task4795Engine {
  static const int taskId = 4795;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'einziehen';
  static const String praeteritum = 'zog ein';
  static const String perfekt = 'hat eingezogen';
  static const String arabicTranslation = 'إدراج / دمج الاستنتاج (ضمان الجودة)';
  static const String ipaTranscription = '[einˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4795_einziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess einziehen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج الاستنتاج في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
