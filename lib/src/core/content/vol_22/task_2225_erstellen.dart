// Sovereign Polyglot Core - Task 2225 (Software Architecture)
class Task2225Engine {
  static const int taskId = 2225;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'erstellen';
  static const String praeteritum = 'erstellte';
  static const String perfekt = 'hat erstellt';
  static const String arabicTranslation = 'إنجاز / تحقيق التنظيم (هندسة البرمجيات)';
  static const String ipaTranscription = '[erˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2225_erstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review erstellen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التنظيم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
