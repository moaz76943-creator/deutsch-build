// Sovereign Polyglot Core - Task 2440 (Software Architecture)
class Task2440Engine {
  static const int taskId = 2440;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'ueberweisen';
  static const String praeteritum = 'ueberwies';
  static const String perfekt = 'hat ueberwiesen';
  static const String arabicTranslation = 'مراجعة / نقل التوجيه (هندسة البرمجيات)';
  static const String ipaTranscription = '[ueberˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2440_ueberweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review ueberweisen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التوجيه في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
