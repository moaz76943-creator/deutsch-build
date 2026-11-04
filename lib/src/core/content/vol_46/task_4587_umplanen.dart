// Sovereign Polyglot Core - Task 4587 (Quality Assurance)
class Task4587Engine {
  static const int taskId = 4587;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'umplanen';
  static const String praeteritum = 'plante um';
  static const String perfekt = 'hat umgeplant';
  static const String arabicTranslation = 'إعادة هيكلة التخطيط (ضمان الجودة)';
  static const String ipaTranscription = '[umˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4587_umplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess umplanen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التخطيط في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
