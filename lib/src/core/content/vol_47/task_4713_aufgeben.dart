// Sovereign Polyglot Core - Task 4713 (Quality Assurance)
class Task4713Engine {
  static const int taskId = 4713;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'aufgeben';
  static const String praeteritum = 'gab auf';
  static const String perfekt = 'hat aufgegeben';
  static const String arabicTranslation = 'رفع / فتح التسليم (ضمان الجودة)';
  static const String ipaTranscription = '[aufˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4713_aufgeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess aufgeben.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التسليم في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
