// Sovereign Polyglot Core - Task 2220 (Software Architecture)
class Task2220Engine {
  static const int taskId = 2220;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'ueberstellen';
  static const String praeteritum = 'ueberstellte';
  static const String perfekt = 'hat ueberstellt';
  static const String arabicTranslation = 'مراجعة / نقل التنظيم (هندسة البرمجيات)';
  static const String ipaTranscription = '[ueberˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2220_ueberstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review ueberstellen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التنظيم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
