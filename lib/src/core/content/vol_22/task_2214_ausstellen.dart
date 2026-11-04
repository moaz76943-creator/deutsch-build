// Sovereign Polyglot Core - Task 2214 (Software Architecture)
class Task2214Engine {
  static const int taskId = 2214;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'ausstellen';
  static const String praeteritum = 'stellte aus';
  static const String perfekt = 'hat ausgestellt';
  static const String arabicTranslation = 'توسيع / استخراج التنظيم (هندسة البرمجيات)';
  static const String ipaTranscription = '[ausˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2214_ausstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review ausstellen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التنظيم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
