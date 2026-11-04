// Sovereign Polyglot Core - Task 2300 (Software Architecture)
class Task2300Engine {
  static const int taskId = 2300;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'uebernehmen';
  static const String praeteritum = 'uebernahm';
  static const String perfekt = 'hat uebernommen';
  static const String arabicTranslation = 'مراجعة / نقل الاستلام (هندسة البرمجيات)';
  static const String ipaTranscription = '[ueberˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2300_uebernehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review uebernehmen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل الاستلام في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
